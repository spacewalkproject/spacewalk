#!/usr/bin/python
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
# Generic DB backend data structures
#

import time
import string

from UserDict import UserDict
from types import ListType, StringType, DictType, IntType

# A function that formats a UNIX timestamp to the session's format
def gmtime(timestamp):
    return _format_time(time.gmtime(float(timestamp)))

def localtime(timestamp):
    return _format_time(time.localtime(float(timestamp)))

def _format_time(time_tuple):
    return "%d-%02d-%02d %02d:%02d:%02d" % time_tuple[:6]

# Database datatypes
class DBtype:
    pass

class DBint(DBtype):
    pass

class DBstring(DBtype):
    def __init__(self, limit):
        self.limit = limit

class DBblob(DBtype):
    pass

class DBdate(DBtype):
    pass

class DBdateTime(DBtype):
    pass

# Database objects
class Table:
    # A list of supported keywords
    keywords = {
        'fields'    : DictType,
        'pk'        : ListType, 
        'attribute' : StringType,
        'map'       : DictType,
        'nullable'  : ListType, # Will become a hash eventually
        'severityHash'      : DictType,
        'defaultSeverity'   : IntType,
        'sequenceColumn'    : StringType,
    }

    def __init__(self, name, **kwargs):
        self.name = name
        for k in kwargs.keys():
            if not self.keywords.has_key(k):
                raise TypeError("Unknown keyword attribute '%s'" % k)
        # Initialize stuff
        # Fields
        self.fields = {}
        # Primary keys
        self.pk = []
        # Mapping from database fields to generic attribute names
        self.map = {}
        # Name of the attribute this table links back to
        self.attribute = None
        # Nullable columns; will become a hash
        self.nullable = []
        # Compute the diff
        self.severityHash = {}
        self.defaultSeverity = 4
        # Sequence column - a column that is populated off a sequence
        self.sequenceColumn = None

        for k, v in kwargs.items():
            datatype = self.keywords[k]
            if not isinstance(v, datatype):
                raise TypeError("%s expected to be %s; got %s" % (
                    k, datatype, type(v)))
            setattr(self, k, v)

        # Fix nullable
        nullable = self.nullable
        self.nullable = {}
        if nullable:
            for field in nullable:
                if not self.fields.has_key(field):
                    raise TypeError("Unknown nullable field %s in table %s" % (
                        field, name))
                self.nullable[field] = None
        
        # Now analyze pk
        for field in self.pk:
            if not self.fields.has_key(field):
                raise TypeError("Unknown primary key field %s" % field)

    def isNullable(self, field):
        if not self.fields.has_key(field):
            raise TypeError("Unknown field %s" % field)
        return self.nullable.has_key(field)

    def getPK(self):
        return self.pk

    def getFields(self):
        return self.fields

    def getAttribute(self):
        return self.attribute

    def getObjectAttribute(self, attribute):
        if self.map.has_key(attribute):
            return self.map[attribute]
        return attribute

    def getSeverityHash(self):
        for field in self.fields.keys():
            if not self.severityHash.has_key(field):
                self.severityHash[field] = self.defaultSeverity
        return self.severityHash
    
# A collection of tables
class TableCollection(UserDict):
    def __init__(self, *list):
        UserDict.__init__(self)
        # Verify if the list's items are the right format
        for table in list:
            if not isinstance(table, Table):
                raise TypeError("Expected a Table instance; got %s" %
                    type(table))
        # Now initialize the collection
        for table in list:
            self.__setitem__(table.name, table)

# Lookup class
# The problem stems from the different way we're supposed to build a query if
# the value is nullable
class BaseTableLookup:
    def __init__(self, table, dbmodule):
        # Generates a bunch of queries that look up data based on the primary
        # keys of this table
        self.dbmodule = dbmodule
        self.table = table
        self.pks = self.table.getPK()
        self.whereclauses = {}
        self.queries = {}
        self._buildWhereClauses()

    def _buildWhereClauses(self):
        # Keys is a list of lists of 0/1, 0 if the column is not nullable
        keys = [[]]
        # The corresponding query arguments
        queries = [[]]
        for col in self.pks:
            k = []
            q = []
            for i in range(len(keys)):
                key = keys[i]
                query = queries[i]
                k.append(key + [0])
                q.append(query + ["%s = :%s" % (col, col)])
                if self.table.isNullable(col):
                    k.append(key + [1])
                    q.append(query + ["%s is null" % col])
            keys = k
            queries = q
        # Now put the queries in self.sqlqueries, keyed on the list of 0/1
        for i in range(len(keys)):
            key = tuple(keys[i])
            query = string.join(queries[i], ' and ')
            self.whereclauses[key] = query

    def _selectQueryKey(self, value):
        # Determine which query should we use
        # Build the key first
        hash = {}
        key = []
        for col in self.pks:
            if self.table.isNullable(col) and value[col] in [None, '']:
                key.append(1)
            else:
                key.append(0)
                hash[col] = value[col]
        key = tuple(key)
        return key, hash

    def _buildQuery(self, key):
        # Stub
        return None

    def _getCachedQuery(self, key):
        if self.queries.has_key(key):
            # Serve it from the pool
            return self.queries[key]

        statement = self.dbmodule.prepare(self._buildQuery(key))
        # And save it to the cached queries pool
        self.queries[key] = statement
        return statement
    
    def query(self, values):
        key, values = self._selectQueryKey(values)
        statement = self._getCachedQuery(key)
        apply(statement.execute, (), values)
        return statement


class TableLookup(BaseTableLookup):
    def __init__(self, table, dbmodule):
        BaseTableLookup.__init__(self, table, dbmodule)
        self.queryTemplate = "select * from %s where %s"

    def _buildQuery(self, key):
        return self.queryTemplate % (self.table.name, self.whereclauses[key])


class TableUpdate(BaseTableLookup):
    def __init__(self, table, dbmodule):
        BaseTableLookup.__init__(self, table, dbmodule)
        self.queryTemplate = "update %s set %s where %s"
        self.fields = self.table.getFields().keys()
        self.count = 1000
        # Fields minus pks
        self.otherfields = []
        # BLOBs cannot be PKs, and have to be updated differently
        self.blob_fields = []
        for field in self.fields:
            if field in self.pks:
                continue
            datatype = self.table.fields[field]
            if isinstance(datatype, DBblob):
                self.blob_fields.append(field)
            else:
                self.otherfields.append(field)
        self.updateclause = string.join(
            map(lambda x: "%s = :%s" % (x, x), self.otherfields), ', ')
        # key
        self.firstkey = None
        for pk in self.pks:
            if not self.table.isNullable(pk):
                # This is it
                self.firstkey = pk
                break

    def _buildQuery(self, key):
        return self.queryTemplate % (self.table.name, self.updateclause, 
            self.whereclauses[key])

    def _split_blob_values(self, values, blob_only=0):
        # Splits values that have to be inserted
        # Blobs will be in a separate hash
        valuesHash = {}
        # blobValuesHash is a hash keyed on the primary key fields
        # should only have one element if the primary key has no nullable
        # fields
        blobValuesHash = {}
        for key in self.whereclauses.keys():
            hash = {}
            for i in range(len(key)):
                pk = self.pks[i]
                # Only add the PK if it's non-null
                if not key[i]:
                    hash[pk] = []
            # And then add everything else
            for k in self.otherfields:
                hash[k] = []
            valuesHash[key] = hash
            blobValuesHash[key] = []

        # Split the query values on key components
        for i in range(len(values[self.firstkey])):
            # Build the value
            pk_val = {}
            val = {}
            for k in self.pks:
                pk_val[k] = val[k] = values[k][i]
            key, val = self._selectQueryKey(val)
            
            if not blob_only:
                # Add the rest of the values
                for k in self.otherfields:
                    val[k] = values[k][i]
                addHash(valuesHash[key], val)
            
            if not self.blob_fields:
                # Nothing else to do
                continue
            val = {}
            for k in self.blob_fields:
                val[k] = values[k][i]
            blobValuesHash[key].append((pk_val, val))

        return valuesHash, blobValuesHash


    def query(self, values):
        valuesHash, blobValuesHash = self._split_blob_values(values, blob_only=0)
        # And now do the actual update for non-blobs
        if self.otherfields:
            for key, val in valuesHash.items():
                if not val[self.firstkey]:
                    # Nothing to do
                    continue
                statement = self._getCachedQuery(key)
                executeStatement(statement, val, self.count)

        if not self.blob_fields:
            return

        self._update_blobs(blobValuesHash)

    def _update_blobs(self, blobValuesHash):
        # Now update BLOB fields
        template = "select %s from %s where %s for update"
        blob_fields_string = string.join(self.blob_fields, ", ")
        for key, val in blobValuesHash.items():
            statement = template % (blob_fields_string, self.table.name,
                self.whereclauses[key])
            h = self.dbmodule.prepare(statement)
            for lookup_hash, blob_hash in val:
                apply(h.execute, (), lookup_hash)
                # Should have exactly one row here
                row = h.fetchone_dict()
                if not row:
                    # XXX This should normally not happen
                    raise ValueError("BLOB query did not retrieve a value")
                for k, v in blob_hash.items():
                    blob = row[k]
                    len_v = len(v)
                    # If new value is shorter than old value, we have to trim
                    # the blob
                    if blob.size() > len_v:
                        blob.trim(len_v)
                    # blobs don't like to write the empty string
                    if len_v:
                        blob.write(v)
                # Is this the only row?
                row = h.fetchone_dict()
                if row is not None:
                    # XXX This should not happen, the primary key was not
                    # unique
                    raise ValueError("Primary key not unique",
                        self.table.name, lookup_hash)
            
class TableDelete(TableLookup):
    def __init__(self, table, dbmodule):
        TableLookup.__init__(self, table, dbmodule)
        self.queryTemplate = "delete from %s where %s"
        self.count = 1000

    def query(self, values):
        # Build the values hash
        valuesHash = {}
        for key in self.whereclauses.keys():
            hash = {}
            for i in range(len(key)):
                pk = self.pks[i]
                # Only add the PK if it's non-null
                if not key[i]:
                    hash[pk] = []
            valuesHash[key] = hash

        # Split the query values on key components
        firstkey = self.pks[0]
        for i in range(len(values[firstkey])):
            # Build the value
            val = {}
            for k in self.pks:
                val[k] = values[k][i]
            key, val = self._selectQueryKey(val)
            addHash(valuesHash[key], val)

        # And now do the actual delete
        for key, val in valuesHash.items():
            firstkey = val.keys()[0]
            if not val[firstkey]:
                # Nothing to do
                continue
            statement = self._getCachedQuery(key)
            executeStatement(statement, val, self.count)
        

class TableInsert(TableUpdate):
    def __init__(self, table, dbmodule):
        TableUpdate.__init__(self, table, dbmodule)
        self.queryTemplate = "insert into %s (%s) values (%s)"
        self.count = 1000

        self.insert_fields = self.pks + self.otherfields + self.blob_fields
        self.insert_values = map(lambda x: ':%s' % x, self.pks + self.otherfields)
        for f in self.blob_fields:
            self.insert_values.append('empty_blob()')
    
    def _buildQuery(self, key):
        q = self.queryTemplate % (self.table.name, 
            string.join(self.insert_fields, ', '),
            string.join(self.insert_values, ', '))
        return q

    def query(self, values):
        # Take the blob values out of the hash
        blob_values = {}
        for f in self.blob_fields:
            blob_values[f] = values[f]
            del values[f]
        # Copy the primary keys too
        for f in self.pks:
            blob_values[f] = values[f][:]

        # Do the insert
        statement = self._getCachedQuery(None)
        executeStatement(statement, values, self.count)

        if not self.blob_fields:
            # Nothing else to do
            return
        
        valuesHash, blobValuesHash = self._split_blob_values(blob_values, blob_only=1)

        self._update_blobs(blobValuesHash)

    
def executeStatement(statement, valuesHash, chunksize):
    # Executes a statement with chunksize values at the time
    chunksize = 1000
    if not valuesHash:
        # Empty hash
        return
    count = 0
    while 1:
        tempdict = {}
        for k, vals in valuesHash.items():
            if not vals:
                # Empty
                break
            tempdict[k] = vals[:chunksize]
            del vals[:chunksize]
        if not tempdict:
            # Empty dictionary: we're done
            break
        # Now execute it
        count = count + apply(statement.executemany, (), tempdict)
    return count


def sanitizeValue(value, datatype):
    if isinstance(datatype, DBstring):
        if value is None:
            value = ''
        return value[:datatype.limit]
    if isinstance(datatype, DBblob):
        if value is None:
            value = ''
        if isinstance(value, unicode):
            value = unicode.encode(value, 'utf-8')
        return str(value)
    if value in [None, '']:
        return None
    if isinstance(datatype, DBdateTime):
        s = str(value)
        if len(s) == 10:
            # Pad it to be a real datetime
            s = s + " 00:00:00"
        return s
    if isinstance(datatype, DBdate):
        return str(value)[:10]
    if isinstance(datatype, DBint):
        return int(value)
    return value

def addHash(hasharray, hash):
    # hasharray is a hash of arrays
    # add hash's values to hasharray
    for k, v in hash.items():
        if hasharray.has_key(k):
            hasharray[k].append(v)

