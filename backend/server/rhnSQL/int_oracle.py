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
# Base class for Oracle database operations
#

import os
import sys
import string
from types import ListType, TupleType, StringType

import sql_base
import sql_types
from common import rhnException, log_debug, log_error, rhnConfig


class OracleError(Exception):
    pass

# handling of procedure calls
class Procedure(sql_base.Procedure):
    def __call__(self, *args):
        log_debug(2, self.name, args)
        try:
            retval = self._call_proc(args)
        except OracleError, e:
            if not hasattr(e, "args"):
                raise sql_base.SQLError(self.name, args)
            elif 20000 <= e[0] <= 20999: # error codes we know we raise as schema errors
                raise apply(sql_base.SQLSchemaError, tuple(e.args))
            raise apply(sql_base.SQLError, tuple(e.args))
        return retval

    def _call_proc(self, args):
        raise NotImplementedError()

# this curor class is functioning as a wrapper mainly for the
# execute() calls so we can transform OracleError exceptions into
# apropiate generic exceptions defined in sql_base
class Cursor(sql_base.Cursor):
    OracleError = None
    # The cursor cache is a hash of:
    #   id(dbh) as keys
    #   hash with the sql statement as a key and the cursor as a value
    _cursor_cache = {}
    def __init__(self, dbh, sql=None, force_prepare=None):
        sql_base.Cursor.__init__(self, sql=sql)
        self.dbh = dbh
        self.reparsed = 0
        self._real_cursor = None
        self._dbh_id = id(dbh)
        if not self._cursor_cache.has_key(self._dbh_id):
            self._cursor_cache[self._dbh_id] = {}

        try:
            self._real_cursor = self._prepare(force_prepare=force_prepare)
        except sql_base.SQLSchemaError, e:
            (errno, errmsg) = e.errno, e.errmsg
            if 900 <= errno <= 999: 
                # Per Oracle's documentation, SQL parsing error
                args = (self.dbh, errmsg, self.sql)
                raise apply(sql_base.SQLStatementPrepareError, args)
            # XXX: we should be handling the lost connection cases
            # in here too, but we don't get that many of these and
            # besides, this is much harder to get right

            # XXX: Normally we expect the e.args to include a dump of
            # the SQL code we just passed in since we're dealing with
            # an OracleError. I hope this is always the case, of not,
            # we'll have to log the sql code here            
            raise rhnException("Can not prepare statement", e.args)

    def prepare(self, sql, force_prepare=None):
        """Prepares the current statement"""
        if sql is None:
            raise Exception("XXX Unable to prepare None")
        self.sql = sql
        self._real_cursor = self._prepare(force_prepare=force_prepare)

    def _prepare(self, force_prepare=None):
        if self.sql:
            # Check the cache
            _h = self._cursor_cache[self._dbh_id]
            if not force_prepare and _h.has_key(self.sql):
                return _h[self.sql]
        try:
            cursor = self._prepare_sql()
        except self.OracleError, e:
            raise self._build_exception(e)
        if self.sql:
            _h[self.sql] = cursor
        return cursor

    def _prepare_sql(self):
        """Prepares a sql statement"""
        return None
        
    def execute(self, *p, **kw):
        return apply(self._execute_wrapper, (self._execute, ) + p, kw)

    def executemany(self, *p, **kw):
        return apply(self._execute_wrapper, (self._executemany, ) + p, kw)

    def execute_bulk(self, dict, chunk_size=100):
        """
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

    # we try to stop from propagating the OracleError upstream and
    # return something more generic
    def _execute_wrapper(self, function, *p, **kw):
        params =  ','.join(["%s: %s" % (str(key), str(value)) for key, value \
                in kw.items()])
        log_debug(5, "Executing SQL: \"%s\" with bind params: {%s}"
                % (self.sql, params))
        if self.sql is None:
            raise rhnException("Cannot execute empty cursor")
        modified_params = self._munge_args(kw)
        try:
            retval = apply(function, p, kw)
        except self.OracleError, e:
            ret = self._get_oracle_error_info(e)
            if isinstance(ret, StringType):
                raise sql_base.SQLError(self.sql, p, kw, ret)
            (errno, errmsg) = ret[:2]
            if 900 <= errno <= 999: 
                # Per Oracle's documentation, SQL parsing error
                args = (errno, errmsg, self.sql)
                raise apply(sql_base.SQLStatementPrepareError, args)
            if errno == 1475: # statement needs to be reparsed; force a prepare again
                if self.reparsed: # useless, tried that already. give up
                    log_error("Reparsing cursor did not fix it", self.sql)
                    args = ("Reparsing tried and still got this",) + tuple(ret)
                    raise apply(sql_base.SQLError, args)
                self._real_cursor = self.dbh.prepare(self.sql)
                self.reparsed = 1
                apply(self._execute_wrapper, (function, ) + p, kw)
            elif 20000 <= errno <= 20999: # error codes we know we raise as schema errors
                raise apply(sql_base.SQLSchemaError, ret)
            raise apply(sql_base.SQLError, ret)
        else:
            self.reparsed = 0 # reset the reparsed counter
        # Munge back the values
        self._unmunge_args(kw, modified_params)
        return retval

    def _munge_args(self, kw_dict):
        modified = []
        for k, v in kw_dict.items():
            if not isinstance(v, sql_types.DatabaseDataType):
                continue
            vv = self._munge_arg(v)
            modified.append((k, v))
            kw_dict[k] = vv
        return modified
            
    def _munge_arg(self, v):
        raise NotImplementedError()

    def _unmunge_args(self, kw_dict, modified_params):
        raise NotImplementedError()

    def fetchone(self):
        try:
            return self._real_cursor.fetchone()
        except self.OracleError, e:
            raise self._build_exception(e)
        
    def fetchone_dict(self):
        try:
            return self._real_cursor.fetchone_dict()
        except self.OracleError, e:
            raise self._build_exception(e)

    def fetchmany_dict(self, howmany=1):
        try:
            return self._real_cursor.fetchmany_dict(howmany)
        except self.OracleError, e:
            raise self._build_exception(e)

    def fetchall(self):
        try:
            return self._real_cursor.fetchall()
        except self.OracleError, e:
            raise self._build_exception(e)
    
    def fetchall_dict(self):
        try:
            return self._real_cursor.fetchall_dict()
        except self.OracleError, e:
            raise self._build_exception(e)
    
    def fetchone_tuple(self):
        try:
            return self._real_cursor.fetchone_tuple()
        except self.OracleError, e:
            raise self._build_exception(e)
    
    def fetchmany_tuple(self, howmany=1):
        try:
            return self._real_cursor.fetchmany_tuple()
        except self.OracleError, e:
            raise self._build_exception(e)

    def fetchall_tuple(self):
        try:
            return self._real_cursor.fetchall_tuple()
        except self.OracleError, e:
            raise self._build_exception(e)
    
    def _execute(self, *args, **kwargs):
        if kwargs:
            val = kwargs.values()[0]
            if self._is_sequence_type(val):
                sys.stderr.write("WARNING: calling execute with named bound arrays\n")
        return self._execute_(args, kwargs)

    def _execute_(self, args, kwargs):
        return apply(self._real_cursor.execute, args, kwargs)

    def _executemany(self, *args, **kwargs):
        return apply(self._real_cursor.execute, args, kwargs)

    # so we can "inherit" the self._real_cursor functions
    def __getattr__(self, name):
        if hasattr(self._real_cursor, name):
            return getattr(self._real_cursor, name)
        raise AttributeError, name

    # deletion of the object
    def __del__(self):
        self.reparsed = 0
        self.dbh = self.sql = self._real_cursor = None

    def _is_sequence_type(self, val):
        if type(val) in (ListType, TupleType):
            return 1
        return 0

    # Virtual
    # Should return a sequence [code, message, ...] or an error message if no
    # code is to be found
    def _get_oracle_error_info(self, error):
        return ""

    def _build_exception(self, error):
        ret = self._get_oracle_error_info(error)
        if isinstance(ret, StringType):
            return sql_base.SQLError(ret)
        return sql_base.SQLSchemaError(ret[0], ret[1])

# The main database class
class Database(sql_base.Database):
    _cursor_class = Cursor
    _procedure_class = Procedure
    OracleError = None

    def __init__(self, host=None, port=None, username=None,
        password=None, database=None):

        # Oracle requires enough info to assembled a dsn:
        if not (username and password and database):
            raise AttributeError, "A valid Oracle username, password, and SID are required."

        sql_base.Database.__init__(self, host, port, username, password, database)
        # dbtxt is the connection string without the password
        self.dbtxt = self.database
        if '@' in self.database:
            self.dbtxt = string.split(self.database, '@')[-1]
        self.dbh = None 

        # self.stderr keeps the sys.stderr handle alive in case it gets 
        # collected too early.
        self.stderr = sys.stderr

    def connect(self, reconnect=1):
        log_debug(1, "Connecting to database", self.dbtxt)
        self._fix_environment_vars()
        try:
            self.dbh = self._connect()
        except self.OracleError, e:
            ret = self._get_oracle_error_info(e)
            if isinstance(ret, StringType):
                raise sql_base.SQLConnectError(self.dbtxt, -1, 
                    "Unable to connect to database", ret)
            (errno, errmsg) = ret[:2]
            log_error("Connection attempt failed", errno, errmsg)
            if reconnect:
                # we don't try to reconnect blindly.  We have a list of
                # known "good" failure codes that warrant a reconnect
                # attempt
                if errno in [ 12547 ] : # lost contact
                    return self.connect(reconnect=0)
                err_args = [self.dbtxt, errno, errmsg]
                err_args.extend(list(ret[2:]))
                raise apply(sql_base.SQLConnectError, err_args)
            # else, this is a reconnect attempt
            raise apply(sql_base.SQLConnectError, 
                [self.dbtxt, errno, errmsg,
                "Attempting Re-Connect to the database failed", ] + ret[2:])
        dbh_id = id(self.dbh)
        # Reset the statement cache for this database connection
        self._cursor_class._cursor_cache[dbh_id] = {}

    def _connect(self):
        pass
        
    # try to close it first nicely
    def close(self):
        if self.dbh is not None:
            try:
                self.dbh.close()
            except:
                pass
        log_debug(1, "Closed DB database connection to %s" % self.dbtxt)
        dbh_id = id(self.dbh)
        _cursor_cache = self._cursor_class._cursor_cache
        if _cursor_cache.has_key(dbh_id):
            _cache = _cursor_cache[dbh_id]
            for sql, cursor in _cache.items():
                # Close cursors
                try:
                    cursor.close()
                except:
                    pass
            del _cursor_cache[dbh_id]
        self.dbh = self.database = None

    def cursor(self):
        return self._cursor_class(dbh=self.dbh)
        
    # psss-through functions for when you want to do SQL yourself
    def prepare(self, sql, force=0):
        # Abuse the map calls to get rid of SQL comments and extra spaces
        sql = string.join(filter(lambda a: len(a),
            map(string.strip,
                map(lambda a: (a + " ")[:string.find(a, '--')],
                    string.split(sql, "\n")))),
            " ")
        # this way we only hit the network once for each sql statement
        return self._cursor_class(dbh=self.dbh, sql=sql, force_prepare=force)

    # why would anybody need this?!
    def execute(self, sql, *args, **kwargs):
        cursor = self.prepare(sql)
        apply(cursor.execute, args, kwargs)
        return cursor

    def procedure(self, name):
        try:
            c = self.cursor()
        except self.OracleError, error:
            e = self._get_oracle_error_info(error)
            raise apply(sql_base.SQLSchemaError, e)
        # Pass the cursor in so we can close it after execute()
        return self._procedure_class(name, c)
    
    def function(self, name, ret_type):
        if not isinstance(ret_type, sql_types.DatabaseDataType):
            raise sql_base.SQLError("Invalid return type specified", ret_type)
        return self._function(name, ret_type)

    def _function(self, name, ret_type):
        raise NotImplementedError()

    def commit(self):
        log_debug(3, self.dbtxt)
        return self.dbh.commit()

    def rollback(self, name = None):
        log_debug(3, self.dbtxt, name)
        if name: # we need to roll back to a savepoint
            return self.execute("rollback to savepoint %s" % name)
	return self.dbh.rollback()

    # transaction support
    def transaction(self, name):
        if not name:
            raise rhnException("Can not set a transaction without a name", name)
        return self.execute("savepoint %s" % name)
        
    def check_connection(self):
        # check that this connection is valid
        try:
            h = self.prepare("select sysdate as ID from dual")
            h.execute()
        except: # try to reconnect, that one MUST WORK always
            log_error("DATABASE CONNECTION TO '%s' LOST" % self.dbtxt,
                      "Exception information: %s" % sys.exc_info()[1])
            self.connect() # only allow one try
        return 0

    # function that attempts to fix the environment variables
    def _fix_environment_vars(self):
        # Bugzilla 150452  On RHEL 4, for some reason, mod_perl tries to free
        # an invalid pointer if we set an environment variable.
        # If the environment variables are already set, this will be a noop

        if not os.environ.has_key("NLS_LANG"):
            value = None
            # Do we have a config object?
            if rhnConfig.CFG.is_initialized():
                if rhnConfig.CFG.has_key("nls_lang"):
                    # Get the value from the configuration object
                    value = rhnConfig.CFG.nls_lang
            if not value:
                # Assign a default value
                value = "english.UTF8"
            os.environ["NLS_LANG"] = value

        if not os.environ.has_key("ORACLE_HOME"):
            os.environ["ORACLE_HOME"] = os.popen("dbhome '*'").read()

    # Virtual
    # Should return a sequence [code, message, ...] or an error message if no
    # code is to be found
    def _get_oracle_error_info(self, error):
        return ""

    def _build_exception(self, error):
        ret = self._get_oracle_error_info(error)
        if isinstance(ret, StringType):
            return sql_base.SQLError(ret)
        return sql_base.SQLSchemaError(ret.code, ret.message, ret.context)
