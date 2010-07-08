#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
# 
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation. 
#
#

import math
import gzip
import string
import cPickle
import cStringIO

from common import rhnCache, log_debug, log_error
from common.rhnLib import timestamp

from server import rhnSQL

# XXX Although it would have been much easier to do it all in python, we want
# this code to commit as soon as possible. Also, we cannot just commit
# ourselves, there may be data outside of this module that wasn't committed
# yet, and that may have to be rolled back at a later point. The only solution
# is using stored procedures that are marked as doing autonomous transactions.
# Such procedures don't see the changes in the same transaction, and commiting
# doesn't commit the outer transaction.

### The following functions expose this module as a dictionary

def has_key(name, modified = None):
    # We have to rely on the same entity generating the time and comparing it;
    # we are generating UNIX timestamps on the app side, and we store them in
    # the database as DATE fields. The trick is to make both conversions in
    # the same way.
    # One second differences seem to be returned as zero, presumably because
    # 1 means one day for Oracle; 1/86400 is silently converted by DCOracle to
    # 0, which is bad; so scale the response to number_of_seconds instead of
    # days.

    # Even though we set now as time.time(), we don't actually use it; the
    # database will set its own time if modified is not specified; in this
    # case we only need a placeholder value so that the query can correctly
    # compute the time delta
    h = _fetch_cursor(key=name, modified=modified)

    row = h.fetchone_dict()
    if not row:
        # Key not found
        return 0
    
    # has_key behaves as stat(): the access time doesn't change just by
    # poking around to see if the key is there
    
    if modified and row['delta'] != 0:
        # Different version
        return 0
    # Same copy
    return 1
    
def get(name, modified = None, raw = None, compressed = None):
    # Check to see if the entry is in the database, with the right version
    h = _fetch_cursor(key=name, modified=modified)

    row = h.fetchone_dict()

    if not row:
        # Key not found
        return None

    if modified and row['delta'] != 0:
        # Different version
        log_debug(4, "database cache: different version")
        return None

    if modified is None:
        # The caller doesn't care about the modified time, but we do, since we
        # want to fetch the same version from the disk cache
        modified = row['modified']

    if rhnCache.has_key(name, modified):
        # We have the value
        log_debug(4, "Filesystem cache HIT")
        return rhnCache.get(name, modified=modified, raw=raw)

    log_debug(4, "Filesystem cache MISS")

    # The disk cache doesn't have this key at all, or it's a modified value
    # Fetch the value from the database

    v = row['value']
    # Update the accessed field
    rhnSQL.Procedure("rhn_cache_update_accessed")(name)

    if compressed:
        io = cStringIO.StringIO()

        io.write(rhnSQL.read_lob(v))
        io.seek(0, 0)

        # XXX For about 40M of compressed data sometimes we get:
        # zlib.error: Error -3 while decompressing: incomplete dynamic bit lengths tree
        v = gzip.GzipFile(None, "r", 0, io)

    try:
        data = v.read()
    except (ValueError, IOError, gzip.zlib.error), e:
        # XXX poking at gzip.zlib may not be that well-advised
        log_error("rhnDatabaseCache: gzip error for key %s: %s" % (
            name, e))
        # Ignore this entry in the database cache, it has invalid data
        return None

    # We store the data in the database cache, in raw format
    rhnCache.set(name, data, modified=modified, raw=1)
    
    # Unpickle the data, unless raw access was requested
    if not raw:
        return cPickle.loads(data)

    return data


def delete(name):
    # Uses the stored procedure. Quite simple
    rhnSQL.Procedure("rhn_cache_delete")(name)
    # Delete it from the disk cache too, just in case
    rhnCache.delete(name)
    
# We only set the database cache value
# The local disk one will be cached when get() is called for the first time
def set(name, value, modified = None, raw = None, compressed = None):
    if modified is not None:
        modified = timestamp(modified)
    if raw:
        val = value
    else:
        val = cPickle.dumps(value, 1)

    if compressed:
        # Since most of the data is kept in memory anyway, don't bother to
        # write it to a temp file at this point - it's probably much smaller
        # anyway
        io = cStringIO.StringIO()

        f = gzip.GzipFile(None, "w", 5, io)
        f.write(val)
        f.close()

        val = io.getvalue()
        io.close()

    data_length = len(val)
    chunk_size = 32512
    chunks = int(math.ceil(float(data_length) / chunk_size))
    #if chunks > 256:
    #    raise Exception, "Data too big"

    plsql_template = r"""
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    blob_val BLOB;
    modified_date DATE;
    now DATE := sysdate;
    our_key_id number;
%s
BEGIN
    our_key_id := lookup_cache_key(:key);
    BEGIN
        SELECT value INTO blob_val
          FROM rhnCache
         WHERE key_id = our_key_id
           FOR UPDATE OF value;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- The entry is not here yet, let's create it
            INSERT INTO rhnCache (key_id, value, created, modified)
            VALUES (our_key_id, EMPTY_BLOB(), sysdate, sysdate)
            RETURNING value INTO blob_val;
    END;
    -- If we want to write less data than currently available, trim the blob
    IF :data_len < DBMS_LOB.getlength(blob_val) THEN
        DBMS_LOB.TRIM(blob_val, :data_len);
    END IF;
    
%s

    -- Now update last_modified and last_accessed
    if :modified IS NULL THEN
        modified_date := now;
    ELSE
        modified_date := TO_DATE('1970-01-01 00:00:00', 
            'YYYY-MM-DD HH24:MI:SS') + :modified / 86400;
    END IF;
    UPDATE rhnCache SET modified = modified_date WHERE key_id = our_key_id;
    -- Update accessed too
    UPDATE rhnCacheTimestamps
       SET accessed = now
     WHERE key_id = our_key_id;
    if SQL%%ROWCOUNT = 0 THEN
        -- No entry in rhnCacheTimestamps; insert it
        INSERT INTO rhnCacheTimestamps (key_id, accessed)
        VALUES (our_key_id, now);
    END IF;
    COMMIT;
END;
"""

    decl_template = "    arg_%s LONG RAW := :val_%s;"
    dbms_lob_template = "   DBMS_LOB.WRITE(blob_val, %s, %s, arg_%s);"

    indices = range(chunks)
    start_pos = map(lambda x, cs=chunk_size: x * cs + 1, indices)
    sizes = [ chunk_size ] * (chunks - 1) + \
        [ 'length(rawtohex(arg_%s)) / 2' % (chunks - 1) ]

    query = plsql_template % (
        string.join(
            map(lambda x, y, t=decl_template: t % (x, y),
                indices, indices),
            "\n"
        ),
        string.join(
            map(lambda x, y, z, t=dbms_lob_template: t % (x, y, z), 
                sizes, start_pos, indices),
            "\n"
        ),
    )
    params = {
        'modified'  : modified,
        'data_len'  : data_length,
        'key'       : name,
    }
    for i in indices:
        start = i * chunk_size
        end = (i + 1) * chunk_size
        params['val_%s' % i] = rhnSQL.types.LONG_BINARY(val[start:end])

    h = rhnSQL.prepare(query)
    tries = 3
    while tries:
        tries = tries - 1
        try:
            apply(h.execute, (), params)
        except rhnSQL.SQLSchemaError, e:
            if e.errno == 1:
                # Unique constraint violated - probably someone else was
                # doing the same thing at the same time
                # Try again
                continue
        # No errors - we're done
        # We're done
        break
    else:
        # Kept raising Unique constraint violated - something else may be
        # wrong; re-raise the last exception
        raise
    
def _fetch_cursor(key=None, modified=None):
    if modified is not None:
        modified = timestamp(modified)
           
    # Computing the number of seconds since Jan 1 1970
    
    h = rhnSQL.prepare("""
    select c.key_id, c.value, nvl(
             (c.modified - 
                TO_DATE('1970-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) *
                86400 - :modified, 
             0) delta,
           (c.modified - TO_DATE('1970-01-01 00:00:00', 
             'YYYY-MM-DD HH24:MI:SS')) * 86400 modified
      from rhnCache c
     where c.key_id = LOOKUP_CACHE_KEY(:key)
    """)
    h.execute(key=key, modified=modified)
    return h

