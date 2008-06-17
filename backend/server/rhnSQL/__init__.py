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

# expose exceptions
from sql_base import SQLError, SQLSchemaError, SQLConnectError, \
    SQLStatementPrepareError, Statement, ModifiedRowError

# ths module works with a private global __DB object that is
# instantiated by the initDB call. This object/instance should NEVER,
# EVER be exposed to the calling applications.

# this is the actual function that establishes and checks the connection
# so we can wrap around it and handle exceptions
def __init__DB(db):
    # __DB global object created here and pushed into the global namespace.
    global __DB
    try:
        my_db = __DB
    except NameError: # __DB has not been set up
        db_class = dbi.get_database_class()
        __DB = db_class(db)
        __DB.connect()
        return
    else:
        del my_db
    if db == __DB.database: # this connection has been already made
        __DB.check_connection()       
        return
    __DB.commit()
    __DB.close()
    # now we have to get a different connection
    __DB = dbi.get_database_class()(db)
    __DB.connect()
    return 0

# initialize the database
def initDB(db = None):
    if not db:
        db = CFG.DEFAULT_DB
    log_debug(3, db)
    # Hide the password
    add_to_seclist(db)
    try:
        __init__DB(db)
    except (rhnException, SQLError):
        raise # pass on, we know those ones
    except (KeyboardInterrupt, SystemExit):
        raise
    except:
        e_type, e_value = sys.exc_info()[:2]
        raise rhnException("Could not initialize Oracle database connection",
                           str(e_type), str(e_value))
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
    return db.database

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
    _implementor = None

    def __init__(self, name):
        self._name = name

    def __getattr__(self, name):
        return self.__class__("%s.%s" % (self._name, name))
    
    def __call__(self, *args):
        proc = self._implementor.__call__(self._name)
        return proc(*args)


class _Procedure(_Callable):
   _implementor = Procedure 


class _Function(_Callable):
    _implementor = Function


class _CallableWrapper(object):

    def __init__(self, wrapped):
        self._wrapped = wrapped

    def __getattr__(self, x):
        return self._wrapped(x)

procedure = _CallableWrapper(_Procedure)
function = _CallableWrapper(_Function)
