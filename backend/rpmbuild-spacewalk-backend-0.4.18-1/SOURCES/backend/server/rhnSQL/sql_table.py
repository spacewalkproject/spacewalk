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
# classes definitions for working with a sql table
#
# 

import string

from common import UserDictCase, rhnException

import sql_base
import sql_lib

# A class to handle row updates transparently
class RowData(UserDictCase):
    def __init__(self, dict, db, sql, rowid, cache = None):
        UserDictCase.__init__(self, dict)
        if not isinstance(db, sql_base.Database):
            raise TypeError, "Second argument needs to be a database handle"
        self.__db = db
        self.__sql = sql
        self.__rowid = rowid
        self.__cache = cache

    # now the real function that supports updating
    def __setitem__(self, key, value):
        sql = self.__sql % key
        h = self.__db.prepare(sql)
        h.execute(new_val=value, row_id=self.__rowid)
        # keep self.data in sync
        self.data[key] = value
        if self.__cache: # maintain cache consistency
            try: self.__cache[self.__rowid][key] = value
            except: pass

# A class to handle operations on a table.
#
# While this class allows you to perform queries and updates on a row
# within a table, it is recommended you use the Row class if you ever
# need to touch a single row of data. On the other hand, if you need
# to jump a lot in the table from one row to another this class is
# more efficient because it works as a hash of hashes, if you will...
#
# Some day we'll figure out how to reduce confusion...
class Table:
    def __init__(self, db, table, hashid, cache = 0):
        if not table or not type(table) == type(""):
            raise rhnException("First argument needs to be a table name",
                               table)
        self.__table = table
        if not hashid or not type(hashid) == type(""):
            raise rhnException("Second argument needs to be the name of the unique index column",
                               hashid)
        self.__hashid = hashid
        if not isinstance(db, sql_base.Database):
            raise rhnException("Argument db is not a database instance", db)
        self.__db = db
        self.__cache = None
        if cache:
            self.__cache = {}

	# see if the table exists
	sql = "select %s from %s where rownum = 0" % (self.__hashid, self.__table)
	try:
	    h = self.__db.prepare(sql)
	except:
	    raise ValueError,"Invalid table or column"
	del h

    def set_cache(self, value):
        if not value:
            self.__cache = None
            return
        if self.__cache is not None: # already enabled
            return
        self.__cache = {}

    # insert row(s) into the table
    def insert(self, rows):
        # insert a single row into the table
        def insert_row(row, self = self):
            if self.__cache is not None:
                self.__cache[row[self.__hashid]] = row
            return self.__setitem__(None, row)
        if type(rows) == type({}) or isinstance(rows, UserDictCase):
            return insert_row(rows)
        if type(rows) == type([]):
            for x in rows:
                insert_row(x)
	    return None
        raise rhnException("Invalid data %s passed" % type(rows), rows)

    # select from the whole table all the entries that match the
    # valuies of the hash provided (kind of a complex select)
    def select(self, row):
        if not type(row) == type({}) and not isinstance(row, UserDictCase):
            raise rhnException("Expecting hash argument. %s is invalid" % type(row),
                               row)
        if row == {}:
	    raise rhnException("The hash argument is empty", row)
        keys = row.keys()
        # Sort the list of keys, to always get the same list of arguments
        keys.sort()
        args = []
        for col in keys:
            if row[col] in (None, ''):
                clause = "%s is null" % col
            else:
                clause = "%s = :%s" % (col, col)
            args.append(clause)
	sql = "select * from %s where " % self.__table
	cursor = self.__db.prepare(sql + string.join(args, " and "))
	apply(cursor.execute, (), row)
	rows = cursor.fetchall_dict()
        if rows is None:
            return None
        # fill up the cache
        if self.__cache is not None:
            for row in rows:
                self.__cache[row[self.__hashid]] = row
        return map(lambda a: UserDictCase(a), rows)

    # print it out
    def __repr__(self):
        return "<%s> instance for table `%s' keyed on `%s'" % (
            self.__class__, self.__table, self.__hashid)

    # make this table look like a dictionary
    def __getitem__(self, key):
        if self.__cache and self.__cache.has_key(key):
	    return self.__cache[key]
        h = self.__db.prepare("select * from %s where %s = :p1" % (
            self.__table, self.__hashid))
        h.execute(p1=key)
        ret = h.fetchone_dict()
        if ret is None:
	    if self.__cache is not None:
		self.__cache[key] = None
            return None
        xret = UserDictCase(ret)
        if self.__cache is not None:
            self.__cache[key] = xret
        return xret

    # this one is pretty much like __getitem__, but returns a nice
    # reference to a RowData instance that allows the returned hash to
    # be modified.
    def get(self, key):
        ret = self.__getitem__(key)
        if self.__cache and self.__cache.has_key(key):
	    del self.__cache[key]
        sql = "update %s set %%s = :new_val where %s = :row_id" % (
            self.__table, self.__hashid)
        return RowData(ret, self.__db, sql, key, self.__cache)

    # database insertion, dictionary style (pass in the hash with the
    # values for all columns except the one that functions as the
    # primary key identifier
    def __setitem__(self, key, value):
        if not type(value) == type({}) and not isinstance(value, UserDictCase):
            raise TypeError, "Expected value to be a hash"
        if value.has_key(self.__hashid): # we don't need that
            if key is None:
                key = value[self.__hashid]
            del value[self.__hashid]

        if key is None:
            raise KeyError, "Can not insert entry with NULL key"
        items = value.items()
        if items == []: # quick check for noop
            return
	sql = None
        if self.has_key(key):
            sql, pdict = sql_lib.build_sql_update(self.__table, self.__hashid, items)
        else:
            sql, pdict = sql_lib.build_sql_insert(self.__table, self.__hashid, items)
        # import the value of the hash key
        pdict["p0"] =  key
        h = self.__db.prepare(sql)
        apply(h.execute, (), pdict)
	try:
	    value[self.__hashid] = key
	    self.__cache[key] = value
	except:
	    pass

    # length
    def __len__(self):
        h = self.__db.prepare("select count(*) as ID from %s" % self.__table)
        h.execute()
        row = h.fetchone_dict()
        if row is None:
            return 0
        return int(row["id"])

    # delete an entry by the key
    def __delitem__(self, key):
        h = self.__db.prepare("delete from %s where %s = :p1" % (
            self.__table, self.__hashid))
        h.execute(p1=key)
	try: del self.__cache[key]
	except: pass
        return 0

    # get all keys
    def keys(self):
        h = self.__db.prepare("select %s NAME from %s" % (
            self.__hashid, self.__table))
        h.execute()
        data = h.fetchall_dict()
        if data is None:
            return []
        return map(lambda a: a["name"], data)

    # has_key
    # if we're caching, fetch the row and cache it; else, fetch the
    # smaller value
    def has_key(self, key):
        if self.__cache is not None:
            h = self.__db.prepare("select * from %s where %s = :p1" %
                                  (self.__table, self.__hashid))
        else:
            h = self.__db.prepare("select %s from %s where %s = :p1" %
                                  (self.__hashid, self.__table, self.__hashid))
        h.execute(p1=key)
        row = h.fetchone_dict()
        if not row:
            return 0
        # stuff it in the cache if we need to do so
        if self.__cache is not None:
            self.__cache[key] = row
        # XXX: can this thing fail in any other way?
        return 1

    # flush the cache. if cache is off, then noop
    def flush(self):
        if self.__cache is not None: # avoid turning caching on when flushing
            self.__cache = {}

    # passthrough commit
    def commit(self):
        return self.__db.commit()
    # passthrough rollback
    def rollback(self):
	self.flush()
        return self.__db.rollback()

    def printcache(self):
	print self.__cache
        return
