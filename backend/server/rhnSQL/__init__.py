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
# entry points for the rhnSQL module
#

import sys

from common import log_debug, rhnException, CFG, add_to_seclist

# SQL objects
import sql_table
import sql_row
import sql_sequence
import dbi
import sql_types
types = sql_types

from const import ORACLE, POSTGRESQL, SUPPORTED_BACKENDS

# expose exceptions
from sql_base import SQLError, SQLSchemaError, SQLConnectError, \
    SQLStatementPrepareError, Statement, ModifiedRowError

# ths module works with a private global __DB object that is
# instantiated by the initDB call. This object/instance should NEVER,
# EVER be exposed to the calling applications.

def __init__DB(backend, host, port, username, password, database):
    """
    Establish and check the connection so we can wrap it and handle
    exceptions.
    """
    # __DB global object created here and pushed into the global namespace.
    global __DB
    try:
        my_db = __DB
    except NameError: # __DB has not been set up
        db_class = dbi.get_database_class(backend=backend)
        __DB = db_class(host, port, username, password, database)
        __DB.connect()
        return
    else:
        del my_db

    if __DB.is_connected_to(backend, host, port, username, password,
            database):
        __DB.check_connection()       
        return

    __DB.commit()
    __DB.close()
    # now we have to get a different connection
    __DB = dbi.get_database_class(backend=backend)(host, port, username,
            password, database)
    __DB.connect()
    return 0

def initDB(dsn=None, backend=ORACLE, host="localhost", port=None, username=None,
        password=None, database=None):
    """
    Initialize the database.

    For Oracle connections: provide just a string dsn argument, or a username,
    password, and database. (sid in this case)
    """

    if not SUPPORTED_BACKENDS.has_key(backend):
        raise rhnException("Unsupported database backend", backend)

    if backend == ORACLE:
        # For Oracle, must provide either dsn or username, password,
        # and database.
        if not dsn and not (username and password and database):
            # Grab the default from the config file:
            dsn = CFG.DEFAULT_DB

        if dsn:
            # split the dsn up into username/pass/sid so we can call the rest of
            # the code in a uniform fashion for all database backends:
            (username, temp) = dsn.split("/")
            (password, database) = temp.split("@")

    if backend == POSTGRESQL:
        host = None
        port = None
        dsn = CFG.DEFAULT_DB
        (username, temp) = dsn.split("/")
        (password, dsn) = temp.split("@")
        for i in dsn.split(';'):
            (k, v) = i.split('=')
            if k == 'dbname':
                database = v
            elif k == 'host':
                host = v
            elif k == 'port':
                port = v
            else:
                raise rhnException("Unknown piece in default_db string", i)

    # Hide the password
    add_to_seclist(dsn)
    try:
        __init__DB(backend, host, port, username, password, database)
#    except (rhnException, SQLError):
#        raise # pass on, we know those ones
#    except (KeyboardInterrupt, SystemExit):
#        raise
    except:
        raise
        #e_type, e_value = sys.exc_info()[:2]
        #raise rhnException("Could not initialize Oracle database connection",
        #                   str(e_type), str(e_value))
    return 0

# close the database
def closeDB():
    global __DB
    try:
        my_db = __DB
    except NameError:
        return
    else:
        del my_db
    __DB.commit()
    __DB.close()
    del __DB
    return
    
# common function for testing the connection state (ie, __DB defined
def __test_DB():
    global __DB
    try:
        return __DB
    except NameError:
        raise SystemError, "Not connected to any database!"    

# wrapper for a Procedure callable class
def Procedure(name):
    db = __test_DB()
    return db.procedure(name)

# wrapper for a Procedure callable class
def Function(name, ret_type):
    db = __test_DB()
    return db.function(name, ret_type)

# Wrapper for the Sequence class
def Sequence(seq):
    db = __test_DB()
    return sql_sequence.Sequence(db, seq)

# Wrapper for the Row class
def Row(table, hash_name, hash_value = None):
    db = __test_DB()
    return sql_row.Row(db, table, hash_name, hash_value)

# Wrapper for the Table class
def Table(table, hash_name, local_cache = 0):
    db = __test_DB()
    return sql_table.Table(db, table, hash_name, local_cache)

# Returns the connection string to the DB
def database():
    db = __test_DB()
    return db.dsn

# Functions points of entry
def cursor():
    db = __test_DB()
    return db.cursor()
def prepare(sql):
    db = __test_DB()
    if isinstance(sql, Statement):
        sql = sql.statement
    return db.prepare(sql)
def execute(sql, *args, **kwargs):
    db = __test_DB()
    return apply(db.execute, (sql, ) + args, kwargs)
def commit():
    db = __test_DB()
    return db.commit()
def rollback(name = None):
    db = __test_DB()
    return db.rollback(name)
def transaction(name):
    db = __test_DB()
    return db.transaction(name)
def TimestampFromTicks(*args, **kwargs):
    db = __test_DB()
    return apply(db.TimestampFromTicks, args, kwargs)
def DateFromTicks(*args, **kwargs):
    db = __test_DB()
    return apply(db.DateFromTicks, args, kwargs)
def Date(*args, **kwargs):
    db = __test_DB()
    return apply(db.Date, args, kwargs)

def read_lob(lob):
    if not lob:
        return None
    db = __test_DB()
    return db._read_lob(lob)


class _Callable(object):

    def __init__(self, name):
        self._name = name
        self._implementor = None

    def __getattr__(self, name):
        return self.__class__("%s.%s" % (self._name, name))
    
    def __call__(self, *args):
        proc = self._implementor.__call__(self._name)
        return proc(*args)


class _Procedure(_Callable):
   def __init__(self, name):
       _Callable.__init__(self, name)
       self._implementor = Procedure

class _Function(_Callable):
    def __init__(self, name):
        _Callable.__init__(self, name)
        self._implementor = Function


class _CallableWrapper(object):

    def __init__(self, wrapped):
        self._wrapped = wrapped

    def __getattr__(self, x):
        return self._wrapped(x)

procedure = _CallableWrapper(_Procedure)
function = _CallableWrapper(_Function)
