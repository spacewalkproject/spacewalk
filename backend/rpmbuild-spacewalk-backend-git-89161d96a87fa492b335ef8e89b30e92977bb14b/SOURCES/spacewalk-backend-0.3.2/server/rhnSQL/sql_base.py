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
            
# A class to implement generic SQL Cursor operations
class Cursor:
    def __init__(self, dbh=None, sql=None):
        self.sql = sql
        self.dbh = dbh
        
    # execute this statement with a given list of values for bound
    # parameters
    def execute(self, *args, **kw):
        return 0

    # executemany() should be different eventually
    executemany = execute

    # DATA RETRIEVAL
    # Please note: these functions return None if no data is available,
    # not an empty tuple otr a list of empty tuples, or an empty list
    # or any other combination you can imagine with the word "empty" in it.
    
    # one row of data in a tuple
    def fetchone(self):
        return ()
    # a list of rows of data as tuples in a list :-)
    def fetchmany(self, howmany=1):
        # return [()] * howmany
        return []
    # like fetchmany() for all rows
    def fetchall(self):
        return []
    
    # Like the ones above, but return dictinaries instead of tuples
    def fetchone_dict(self):
        return {}
    def fetchmany_dict(self, howmany=1):
        return []
    def fetchall_dict(self):
        return []

    # Likewise, but return a list of (name, value) tuples for each column
    def fetchone_tuple(self):
        return None
    def fetchmany_tuple(self, howmany=1):
        return []
    def fetchall_tuple(self):
        return []

# A class to handle calls to the SQL functions and procedures
class Procedure:
    def __init__(self, name, proc):
        self.name = name
        self.proc = proc
        
    def __call__(self, *args):
        if self.proc is None:
            raise LookupError, "Could not find procedure '%s'" % self.name
        apply(self.proc, args)

# A class to handle database operations
class Database:
    _procedure_class = Procedure
    TimestampFromTicks = None
    def __init__(self, db):
        if not db:
            raise AttributeError, "A valid database connection string is required"
        self.database = db

    def connect(self, reconnect=1):
        "Opens a connection to the database"
        raise NotImplementedError

    def prepare(self, sql, force_reparse = 0):
        "Prepare a SQL statement"
        return Cursor(sql=sql)

    # commit changes
    def commit(self):
        "Commit changes"
        pass

    # return a pointer to a callable instance for the given SQL procedure/
    def procedure(self, name):
        """Return a pointer to a callable instance for a given stored
        procedure.
        The return value is a (possibly modified) copy of the arguments passed
        in. see cx_Oracle's Cursor.callproc for more details"""
        return self._procedure_class(name, None)
    
    # return a pointer to a callable instance for the given SQL function
    def function(self, name, ret_type):
        """Return a pointer to a callable instance for a given stored
        function.
        The return value is the return value of the function.
        One has to properly define the return type for the function, since
        usually the database drivers do not allow for auto-discovery.
        See cx_Oracle's Cursor.callfunc for more details"""
        return self._procedure_class(name, None)
    
    # set a transaction point to which we can rollback to
    def transaction(self, name):
        "set a transaction point to which we can rollback to"
        pass
    
    # rollback changes, optionally to a previously set transaction point
    def rollback(self, name = None):
        "rollback changes, optionally to a previously set transaction point"
        pass

    # check the connection
    def check(self):
        "check the connection"
        return self.database is not None
    
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
