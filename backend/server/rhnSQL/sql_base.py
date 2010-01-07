#
# Copyright (c) 2008--2009 Red Hat, Inc.
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
# This file defines the base classes for the objects and classes used
# by the generic SQL interfaces so we can make sure that all backends
# adhere and provide the same API to the generic layer
#
# This file provides a skeleton defnition of functions RHN uses and
# expects to be available. The interface drivers should only inherit
# from the Database class and feel free to use their own cursors,
# provided they make available the methods defined by the Cursor
# class.
#

import string

import sql_types
import types

from common import log_debug

def adjust_type(val):
    """ Adjust data types prior to calling execute(). """
    if type(val) in [types.IntType, types.FloatType]:
        # Convert it to strings to be uniform
        return str(val)
    if isinstance(val, types.UnicodeType):
        # Represent it as UTF8
        return val.encode("UTF8")
    return val

def ociDict(names=None, row=None):
    """ Create a dictionary from a row description and its values. """
    data = {}
    if not names:
        raise AttributeError, "Class initialization requires a description hash"
    if row is None:
        return data
    for x in range(len(names)):
        name, value = __oci_name_value(names[x], row[x])
        data[name] = value
    return data

def __oci_name_value(names, value):
    """ Extract the name, value pair needed by ociDict function. """
    # the format of the names is
    name, dbitype, dsize, dbsize, prec, scale, nullok = names
    name = name.lower()
    return name, value

# this is for when an execute statement went bad...
class SQLError(Exception):
    def __init__(self, *args):
        apply(Exception.__init__, (self, ) + args)



# other Schema Errors
class SQLSchemaError(SQLError):
    def __init__(self, errno, errmsg, *args):
        self.errno = errno       
        (self.errmsg, errmsg)  = string.split(errmsg, '\n', 1)
        if len(args):
            apply(SQLError.__init__, (self, self.errno, self.errmsg, errmsg) + args)
        else:
            apply(SQLError.__init__, (self, errno, self.errmsg) + (errmsg,))



# SQL connect error
class SQLConnectError(SQLError):
    def __init__(self, db, errno, errmsg, *args):
        self.db = db
        self.errno = errno
        self.errmsg = errmsg
        if len(args):
            apply(SQLError.__init__, (self, errno, errmsg, db) + args)
        else:
            SQLError.__init__(self, errno, errmsg, db)



# Cannot prepare statement
class SQLStatementPrepareError(SQLError):
    def __init__(self, db, errmsg, *args):
        self.db = db
        self.errmsg = errmsg
        apply(SQLError.__init__, (self, errmsg, db) + args)



class ModifiedRowError(SQLError):
    pass
            


class Cursor:
    """ A class to implement generic SQL Cursor operations. """

    # The cursor cache is a hash of:
    #   id(dbh) as keys
    #   hash with the sql statement as a key and the cursor as a value
    _cursor_cache = {}

    def __init__(self, dbh=None, sql=None, force=None):
        self.sql = sql
        self.dbh = dbh

        self.reparsed = 0
        self._real_cursor = None
        self._dbh_id = id(dbh)

        self.description = None

        if not self._cursor_cache.has_key(self._dbh_id):
            self._cursor_cache[self._dbh_id] = {}

        # Store a reference to the underlying Python DB API Cursor:
        self._real_cursor = self._prepare(force=force)
        
    def _prepare_sql(self):
        raise NotImplementedError

    def _prepare(self, force=None):
        if self.sql:
            # Check the cache
            _h = self._cursor_cache[self._dbh_id]
            if not force and _h.has_key(self.sql):
                return _h[self.sql]
        cursor = self._prepare_sql()
        if self.sql:
            _h[self.sql] = cursor
        return cursor

    def prepare(self, sql, force=None):
        """
        Prepares the current statement.

        Must be called prior to execute even if the underlying database driver
        does not support an explicit prepare before execution.
        """
        if sql is None:
            raise Exception("XXX Unable to prepare None")
        self.sql = sql
        self._real_cursor = self._prepare(force=force)

    def update_blob(self, table_name, column_name, where_clause, 
            data, **kwargs):
        """
        Abstraction for the update of a blob column which can vary wildly
        between different database implementations.
        """
        raise NotImplementedError

    def execute(self, *p, **kw):
        """ Execute a single query. """
        return apply(self._execute_wrapper, (self._execute, ) + p, kw)

    def executemany(self, *p, **kw):
        """
        Execute a query multiple times with different data sets.

        Call with keyword arguments mapping to ordered lists.
        i.e. cursor.executemany(id=[1, 2], name=["Bill", "Mary"])
        """
        return apply(self._execute_wrapper, (self._executemany, ) + p, kw)

    def execute_bulk(self, dict, chunk_size=100):
        """
        Uses executemany but chops the incoming dict into chunks for each
        call.

        When attempting to execute bulk operations with a lot of rows in the
        arrays,
        Oracle may occasionally lock (probably the oracle client library).
        I noticed this previously with the import code. -- misa
        This function executes bulk operations in smaller chunks
        dict is supposed to be the dictionary that we normally apply to
        statement.execute.
        """
        ret = 0
        start_chunk = 0
        while 1:
            subdict = {}
            for k, arr in dict.items():
                subarr = arr[start_chunk:start_chunk + chunk_size]
                if not subarr:
                    # Nothing more to do here - we exhausted the array(s)
                    return ret
                subdict[k] = subarr
            ret = ret + apply(self.executemany, (), subdict)
            start_chunk = start_chunk + chunk_size

        # Should never reach this point
        return ret

    def _execute_wrapper(self, function, *p, **kw):
        """ 
        Database specific execute wrapper. Mostly used just to catch DB 
        exceptions and wrap them.

        Must be subclasses by database specific drivers.
        """
        raise NotImplementedError

    def _execute(self, *args, **kwargs):
        if kwargs:
            val = kwargs.values()[0]
            if self._is_sequence_type(val):
                sys.stderr.write("WARNING: calling execute with named bound arrays\n")
        return self._execute_(args, kwargs)

    def _executemany(self, *args, **kwargs):
        raise NotImplementedError

    def _execute_(self, args, kwargs):
        """ Database specific execution of the query. """
        raise NotImplementedError


    # DATA RETRIEVAL
    # Please note: these functions return None if no data is available,
    # not an empty tuple or a list of empty tuples, or an empty list
    # or any other combination you can imagine with the word "empty" in it.
    
    def fetchone(self):
        return self._real_cursor.fetchone()

    def fetchall(self):
        rows = self._real_cursor.fetchall()
        return rows
    
    def fetchone_dict(self):
        """ 
        Return a dictionary for the row returned mapping column name to
        it's value.
        """
        ret = ociDict(self.description, self._real_cursor.fetchone())

        if len(ret) == 0:
            return None
        return ret

    def fetchall_dict(self):
        """
        Fetch all rows as a list of dictionaries.
        """
        rows = self._real_cursor.fetchall()

        ret = []
        for x in rows:
            d = ociDict(self.description, x)
            if len(d) > 0:
                ret.append(d)
        if ret == []:
            return None
        return ret

    def _is_sequence_type(self, val):
        if type(val) in (types.ListType, types.TupleType):
            return 1
        return 0



class Procedure:
    """ 
    Class for calling out to stored procedures.

    Written to behave very much like a Python function in that these
    Procedure objects are "callable".

    See database specific implementations for more details.
    """
    def __init__(self, name, cursor):
        self.name = name
        self.cursor = cursor

    def __del__(self):
        if self.cursor:
            self.cursor.close()
            self.cursor = None



class Database:
    """
    Base class for handling database operations.

    Inherited from by the backend specific classes for Oracle, PostgreSQL, etc.
    """
    _procedure_class = Procedure
    TimestampFromTicks = None

    def __init__(self, host=None, port=None, username=None,
        password=None, database=None):
        # TODO: For now, keep assuming incoming args are used to assemble a dsn.
        # (really not sure what might be using this)
        self.dsn = "%s/%s@%s" % (username, password, database)

    def connect(self, reconnect=1):
        """ Opens a connection to the database. """
        raise NotImplementedError

    def check_connection(self):
        """ Check that this connection is still valid. """
        # Delegates to sub-classes as this is usually done with a DB specific
        # query:
        raise NotImplementedError

    def prepare(self, sql, force=0):
        """ Prepare an SQL statement. """
        raise NotImplementedError

    def commit(self):
        """ Commit changes """
        raise NotImplementedError

    def procedure(self, name):
        """Return a pointer to a callable instance for a given stored
        procedure.
        The return value is a (possibly modified) copy of the arguments passed
        in. see cx_Oracle's Cursor.callproc for more details"""
        return self._procedure_class(name, None)
    
        return self._procedure_class(name, None)

    def function(self, name, ret_type):
        """
        Return a pointer to a callable instance for a given stored
        function.

        The return value is the return value of the function.
        One has to properly define the return type for the function, since
        usually the database drivers do not allow for auto-discovery.
        See cx_Oracle's Cursor.callfunc for more details.
        """
        if not isinstance(ret_type, sql_types.DatabaseDataType):
            raise sql_base.SQLError("Invalid return type specified", ret_type)
        return self._function(name, ret_type)

    def _function(self, name, ret_type):
        raise NotImplementedError

    
    def transaction(self, name):
        "set a transaction point to which we can rollback to"
        pass
    
    def rollback(self, name = None):
        "rollback changes, optionally to a previously set transaction point"
        pass

    def check(self):
        "check the connection"
        return self.dsn is not None
    
    def close(self):
        "Close the connection"
        pass

    def cursor(self):
        "return an empty Cursor object"
        return Cursor()

    def _fix_environment_vars(self):
        "Fix environment variables (to be redefined in subclasses)"
        pass

    def _read_lob(self, lob):
        "Reads a lob's contents"
        return None

    def is_connected_to(self, backend, host, port, username, password,
            database):
        """
        Check if this database matches the given connection parameters.
        """
        raise NotImplementedError

    def Date(self, year, month, day):
        "Returns a Date object"
        raise NotImplementedError

    def DateFromTicks(self, ticks):
        "Returns a Date object"
        raise NotImplementedError



# Class that we use just as a markup for queries/statements; if the statement
# is available upon import, we can automatically check for the statements'
# correctness
class Statement:
    def __init__(self, statement):
        self.statement = statement

    def __repr__(self):
        return "<%s instance at %s; statement=%s" % (
            self.__class__, id(self), self.statement)

    def __str__(self):
        return self.statement
