#
# Copyright (c) 2008--2016 Red Hat, Inc.
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
# Database driver for cx_Oracle
#
# As much as possible, keep functionality out of here. These classes should
# inherit from this in sql_base and generally, just wrap to catch Oracle
# specific exceptions and return generic ones. (or to deal with other Oracle
# one-offs)

import sql_base
import sql_types
import cx_Oracle
import sys
import string
import os
import re
from spacewalk.common import usix

from rhn.UserDictCase import UserDictCase
from spacewalk.common.usix import raise_with_tb, next
from spacewalk.server import rhnSQL
from spacewalk.common import rhnConfig
from spacewalk.common.rhnLog import log_debug, log_error
from spacewalk.common.rhnException import rhnException
from spacewalk.common.stringutils import to_string
from const import ORACLE

ORACLE_TYPE_MAPPING = [
    (sql_types.NUMBER, cx_Oracle.NUMBER),
    (sql_types.STRING, cx_Oracle.STRING),
    (sql_types.BINARY, cx_Oracle.BINARY),
    (sql_types.LONG_BINARY, cx_Oracle.LONG_BINARY),
]


class Cursor(sql_base.Cursor):

    """
    Wrapper that should just transform Oracle specific exceptions into
    something generic from sql_base.
    """
    OracleError = cx_Oracle.DatabaseError

    def __init__(self, dbh, sql=None, force=None, blob_map=None):

        try:
            sql_base.Cursor.__init__(self, dbh=dbh, sql=sql,
                                     force=force)
            self._type_mapping = ORACLE_TYPE_MAPPING
            self.blob_map = blob_map
        except sql_base.SQLSchemaError:
            e = sys.exc_info()[1]
            (errno, errmsg) = e.errno, e.errmsg
            if 900 <= errno <= 999:
                # Per Oracle's documentation, SQL parsing error
                raise_with_tb(sql_base.SQLStatementPrepareError(self.dbh, errmsg, self.sql), sys.exc_info()[2])
            # XXX: we should be handling the lost connection cases
            # in here too, but we don't get that many of these and
            # besides, this is much harder to get right

            # XXX: Normally we expect the e.args to include a dump of
            # the SQL code we just passed in since we're dealing with
            # an OracleError. I hope this is always the case, of not,
            # we'll have to log the sql code here
            raise_with_tb(rhnException("Can not prepare statement", e.args), sys.exc_info()[2])

    def _prepare(self, force=None):
        try:
            return sql_base.Cursor._prepare(self, force)
        except self.OracleError:
            e = sys.exc_info()[1]
            raise_with_tb(self._build_exception(e), sys.exc_info()[2])

    def _prepare_sql(self):
        cursor = self.dbh.cursor()

        if self.sql is not None:
            # Oracle specific extension to the Python DB API:
            cursor.prepare(self.sql)

        return cursor

    def _execute_wrapper(self, function, *p, **kw):
        params = ','.join(["%s: %s" % (repr(key), repr(value)) for key, value
                           in list(kw.items())])
        log_debug(5, "Executing SQL: \"%s\" with bind params: {%s}"
                  % (self.sql, params))
        if self.sql is None:
            raise rhnException("Cannot execute empty cursor")
        if self.blob_map:
            blob_content = {}
            for orig_blob_var in list(self.blob_map.keys()):
                new_blob_var = orig_blob_var + '_blob'
                blob_content[new_blob_var] = kw[orig_blob_var]
                kw[new_blob_var] = self.var(cx_Oracle.BLOB)
                del kw[orig_blob_var]
        modified_params = self._munge_args(kw)

        try:
            retval = function(*p, **kw)
        except self.OracleError:
            e = sys.exc_info()[1]
            ret = self._get_oracle_error_info(e)
            if isinstance(ret, usix.StringType):
                raise_with_tb(sql_base.SQLError(self.sql, p, kw, ret), sys.exc_info()[2])
            (errno, errmsg) = ret[:2]
            if 900 <= errno <= 999:
                # Per Oracle's documentation, SQL parsing error
                raise_with_tb(sql_base.SQLStatementPrepareError(errno, errmsg, self.sql), sys.exc_info()[2])
            if errno == 1475:  # statement needs to be reparsed; force a prepare again
                if self.reparsed:  # useless, tried that already. give up
                    log_error("Reparsing cursor did not fix it", self.sql)
                    args = ("Reparsing tried and still got this",) + tuple(ret)
                    raise_with_tb(sql_base.SQLError(*args), sys.exc_info()[2])
                self._real_cursor = self.dbh.prepare(self.sql)
                self.reparsed = 1
                self._execute_wrapper(function, *p, **kw)
            elif 20000 <= errno <= 20999:  # error codes we know we raise as schema errors
                raise_with_tb(sql_base.SQLSchemaError(*ret), sys.exc_info()[2])
            raise_with_tb(sql_base.SQLError(*ret), sys.exc_info()[2])
        except ValueError:
            # this is not good.Let the user know
            raise
        else:
            self.reparsed = 0  # reset the reparsed counter

        if self.blob_map:
            for blob_var, content in blob_content.items():
                kw[blob_var].getvalue().write(content)
        # Munge back the values
        self._unmunge_args(kw, modified_params)
        return retval

    def _execute_(self, args, kwargs):
        """
        Oracle specific execution of the query.
        """
        # TODO: args appears unused, raise exception if we see any?

        # Only copy the arguments we're interested in
        _p = UserDictCase(kwargs)
        params = {}

        # Check that all required parameters were provided:
        # NOTE: bindnames() is Oracle specific:
        for k in self._real_cursor.bindnames():
            if not _p.has_key(k):
                # Raise the fault ourselves
                raise sql_base.SQLError(1008, 'Not all variables bound', k)
            params[k] = to_string(_p[k])

        # cx_Oracle expects the first arg to be the statement and no
        # positional args:
        self._real_cursor.execute(*(None, ), **params)
        self.description = self._real_cursor.description
        return self._real_cursor.rowcount

    def _executemany(self, *args, **kwargs):
        # cx_Oracle expects the first arg to be the statement
        if not kwargs:
            return 0
        # Compute number of values
        max_array_size = 25
        i = iter(list(kwargs.values()))
        firstval = next(i)
        array_size = len(firstval)
        if array_size == 0:
            return 0

        chunk_size = min(max_array_size, array_size)
        pdict = {}
        for k in kwargs.iterkeys():
            pdict[k] = None
        arr = []
        for i in range(chunk_size):
            arr.append(pdict.copy())

        # Now arr is an array of the desired size
        rowcount = 0
        start = 0
        while start < array_size:
            item_count = min(array_size - start, chunk_size)
            # Trim the array if it is too big
            if item_count != chunk_size:
                arr = arr[:item_count]

            for i in range(item_count):
                pdict = arr[i]
                for k, v in kwargs.items():
                    pdict[k] = to_string(v[start + i])

            # We clear self->bindVariables so that list of all nulls
            # in the previous chunk which caused the type to be set to
            # string does not affect our chunk which may have number
            # there.
            self._real_cursor.setinputsizes(**{})

            # arr is now a list of dictionaries. Each dictionary contains the
            # data for one execution of the query where the key is the column
            # name and the value self explanatory.
            self._real_cursor.executemany(None, arr)
            self.description = self._real_cursor.description

            rowcount = rowcount + self._real_cursor.rowcount
            start = start + chunk_size

        return rowcount

    def _get_oracle_error_info(self, error):
        if isinstance(error, cx_Oracle.DatabaseError):
            e = error[0]
            if isinstance(e, cx_Oracle._Error):
                return (e.code, e.message, self.sql)
        return (None, str(error), self.sql)

    # so we can "inherit" the self._real_cursor functions
    def __getattr__(self, name):
        if hasattr(self._real_cursor, name):
            return getattr(self._real_cursor, name)
        raise AttributeError(name)

    # deletion of the object
    def __del__(self):
        self.reparsed = 0
        self.dbh = self.sql = self._real_cursor = None

    def _build_exception(self, error):
        ret = self._get_oracle_error_info(error)
        if isinstance(ret, usix.StringType):
            return sql_base.SQLError(ret)
        return sql_base.SQLSchemaError(ret[0], ret[1])

    def _munge_arg(self, val):
        for sqltype, dbtype in self._type_mapping:
            if isinstance(val, sqltype):
                var = self._real_cursor.var(dbtype, val.size)
                var.setvalue(0, val.get_value())
                return var

        # TODO: Find out why somebody flagged this with XXX?
        # XXX
        return val.get_value()

    def _unmunge_args(self, kw_dict, modified_params):
        for k, v in modified_params:
            v.set_value(kw_dict[k].getvalue())

    # TODO: Don't think this is doing anything for PostgreSQL, maybe move to Oracle?
    def _munge_args(self, kw_dict):
        modified = []
        for k, v in kw_dict.items():
            if not isinstance(v, sql_types.DatabaseDataType):
                continue
            vv = self._munge_arg(v)
            modified.append((k, v))
            kw_dict[k] = vv
        return modified

    def update_blob(self, table_name, column_name, where_clause, data,
                    **kwargs):
        sql = "SELECT %s FROM %s %s FOR update of %s" % \
            (column_name, table_name, where_clause, column_name)
        c = rhnSQL.prepare(sql)
        c.execute(**kwargs)
        row = c.fetchone_dict()
        blob = row[column_name]
        blob.write(data)


class Procedure(sql_base.Procedure):
    OracleError = cx_Oracle.DatabaseError

    def __init__(self, name, cursor):
        sql_base.Procedure.__init__(self, name, cursor)
        self._type_mapping = ORACLE_TYPE_MAPPING

    def __call__(self, *args):
        """
        Wrap the __call__ method from the parent class to catch Oracle specific
        actions and convert them to something generic.
        """
        log_debug(2, self.name, args)
        retval = None
        try:
            retval = self._call_proc(args)
        except cx_Oracle.DatabaseError:
            e = sys.exc_info()[1]
            if not hasattr(e, "args"):
                raise_with_tb(sql_base.SQLError(self.name, args), sys.exc_info()[2])
            elif 20000 <= e[0].code <= 20999:  # error codes we know we raise as schema errors

                raise_with_tb(sql_base.SQLSchemaError(e[0].code, str(e[0])), sys.exc_info()[2])

            raise_with_tb(sql_base.SQLError(e[0].code, str(e[0])), sys.exc_info()[2])
        except cx_Oracle.NotSupportedError:
            error = sys.exc_info()[1]
            raise_with_tb(sql_base.SQLError(*error.args), sys.exc_info()[2])
        return retval

    def _munge_args(self, args):
        """
        Converts database specific argument types to those defined in sql_base.
        """
        new_args = []
        for arg in args:
            if not isinstance(arg, sql_types.DatabaseDataType):
                new_args.append(arg)
                continue
            new_args.append(self._munge_arg(arg))
        return new_args

    def _munge_arg(self, val):
        for sqltype, db_specific_type in self._type_mapping:
            if isinstance(val, sqltype):
                var = self.cursor.var(db_specific_type, val.size)
                var.setvalue(0, val.get_value())
                return var

        # XXX
        return val.get_value()

    def _call_proc(self, args):
        return self._call_proc_ret(args, ret_type=None)

    def _call_proc_ret(self, args, ret_type=None):
        args = list(map(to_string, self._munge_args(args)))
        if ret_type:
            ret_type_mapped = False
            for sqltype, db_type in self._type_mapping:
                if isinstance(ret_type, sqltype):
                    ret_type = db_type
                    ret_type_mapped = True
                    break
            if not ret_type_mapped:
                raise Exception("Unknown type", ret_type)

        if ret_type:
            return self.cursor.callfunc(self.name, ret_type, args)
        else:
            return self.cursor.callproc(self.name, args)


class Function(Procedure):

    def __init__(self, name, proc, ret_type):
        Procedure.__init__(self, name, proc)
        self.ret_type = ret_type

    def _call_proc(self, args):
        return self._call_proc_ret(args, self.ret_type)


class Database(sql_base.Database):
    _cursor_class = Cursor
    _procedure_class = Procedure
    TimestampFromTicks = cx_Oracle.TimestampFromTicks
    OracleError = cx_Oracle.DatabaseError

    def __init__(self, host=None, port=None, username=None,
                 password=None, database=None, sslmode=None, sslrootcert=None):

        # Oracle requires enough info to connect
        if not (username and password and database):
            raise AttributeError("A valid Oracle username, password, and SID are required.")
        if sslmode is not None:
            raise AttributeError("Option sslmode is not supported for Oracle database backend.")
        if sslrootcert is not None:
            raise AttributeError("Option sslrootcert is not supported for Oracle database backend.")

        sql_base.Database.__init__(self)

        self.username = username
        self.password = password
        self.database = database

        # dbtxt is the connection string without the password, to be used in exceptions
        self.dbtxt = self.username + '@' + self.database

        self.dbh = None

        # self.stderr keeps the sys.stderr handle alive in case it gets
        # collected too early.
        self.stderr = sys.stderr

    def connect(self, reconnect=1):
        log_debug(1, "Connecting to database", self.dbtxt)
        self._fix_environment_vars()
        try:
            self.dbh = self._connect()
        except self.OracleError:
            e = sys.exc_info()[1]
            ret = self._get_oracle_error_info(e)
            if isinstance(ret, usix.StringType):
                raise_with_tb(sql_base.SQLConnectError(self.dbtxt, -1,
                                               "Unable to connect to database", ret), sys.exc_info()[2])
            (errno, errmsg) = ret[:2]
            log_error("Connection attempt failed", errno, errmsg)
            if reconnect:
                # we don't try to reconnect blindly.  We have a list of
                # known "good" failure codes that warrant a reconnect
                # attempt
                if errno in [12547]:  # lost contact
                    return self.connect(reconnect=0)
                err_args = [self.dbtxt, errno, errmsg]
                err_args.extend(list(ret[2:]))
                raise_with_tb(sql_base.SQLConnectError(*err_args), sys.exc_info()[2])
            # else, this is a reconnect attempt
            raise_with_tb(sql_base.SQLConnectError(*(
                [self.dbtxt, errno, errmsg,
                 "Attempting Re-Connect to the database failed", ] + ret[2:])), sys.exc_info()[2])
        dbh_id = id(self.dbh)
        # Reset the statement cache for this database connection
        self._cursor_class._cursor_cache[dbh_id] = {}

    def _connect(self):
        dbh = cx_Oracle.Connection(self.username, self.password, self.database)
        if hasattr(sys, "argv"):
            dbh.cursor().execute(
                "BEGIN DBMS_APPLICATION_INFO.SET_MODULE('%s',NULL); END;"
                % sys.argv[0])
        return dbh

    def is_connected_to(self, backend, host, port, username, password,
                        database, sslmode, sslrootcert):
        # NOTE: host and port are unused for Oracle:
        return (backend == ORACLE) and (self.username == username) and \
            (self.password == password) and (self.database == database) and \
            (sslmode is None) and (sslrootcert is None)

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
        if dbh_id in _cursor_cache:
            _cache = _cursor_cache[dbh_id]
            for sql, cursor in _cache.items():
                # Close cursors
                try:
                    cursor.close()
                except:
                    pass
            del _cursor_cache[dbh_id]
        self.dbh = None

    def cursor(self):
        return self._cursor_class(dbh=self.dbh)

    # pass-through functions for when you want to do SQL yourself
    def prepare(self, sql, force=0, blob_map=None):
        # Abuse the map calls to get rid of SQL comments and extra spaces
        sql = string.join([a for a in list(map(string.strip,
                                     [(a + " ")[:string.find(a, '--')] for a in string.split(sql, "\n")])) if len(a)],
                          " ")
        if blob_map:
            col_list = []
            bind_list = []
            for bind_var, column in blob_map.items():
                r = re.compile(":%s" % bind_var)
                sql = re.sub(r, 'empty_blob()', sql)
                col_list.append(column)
                bind_list.append(":%s_blob" % bind_var)
            sql += " returning %s into %s" % (','.join(col_list), ','.join(bind_list))
        # this way we only hit the network once for each sql statement
        return self._cursor_class(dbh=self.dbh, sql=sql, force=force, blob_map=blob_map)

    def procedure(self, name):
        try:
            c = self.dbh.cursor()
        except cx_Oracle.DatabaseError:
            error = sys.exc_info()[1]
            e = error[0]
            raise_with_tb(sql_base.SQLSchemaError(e.code, e.message, e.context), sys.exc_info()[2])
        # Pass the cursor in so we can close it after execute()
        return self._procedure_class(name, c)

    def _function(self, name, ret_type):
        try:
            c = self.dbh.cursor()
        except cx_Oracle.DatabaseError:
            error = sys.exc_info()[1]
            e = error[0]
            raise_with_tb(sql_base.SQLSchemaError(e.code, e.message, e.context), sys.exc_info()[2])
        return Function(name, c, ret_type)

    # why would anybody need this?!
    def execute(self, sql, *args, **kwargs):
        cursor = self.prepare(sql)
        cursor.execute(*args, **kwargs)
        return cursor

    # transaction support
    def transaction(self, name):
        if not name:
            raise rhnException("Can not set a transaction without a name", name)
        return self.execute("savepoint %s" % name)

    def commit(self):
        log_debug(3, self.dbtxt)
        if self.dbh is not None:
            return self.dbh.commit()

    def rollback(self, name=None):
        log_debug(3, self.dbtxt, name)
        if name:  # we need to roll back to a savepoint
            return self.execute("rollback to savepoint %s" % name)
        return self.dbh.rollback()

    def check_connection(self):
        try:
            h = self.prepare("select 1 from dual")
            h.execute()
        except:  # try to reconnect, that one MUST WORK always
            log_error("DATABASE CONNECTION TO '%s' LOST" % self.dbtxt,
                      "Exception information: %s" % sys.exc_info()[1])
            self.connect()  # only allow one try
        return 0

    # function that attempts to fix the environment variables
    def _fix_environment_vars(self):
        # Bugzilla 150452  On RHEL 4, for some reason, mod_perl tries to free
        # an invalid pointer if we set an environment variable.
        # If the environment variables are already set, this will be a noop

        if "NLS_LANG" not in os.environ:
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

    # Should return a sequence [code, message, ...] or an error message if no
    # code is to be found
    def _get_oracle_error_info(self, error):
        if isinstance(error, cx_Oracle.DatabaseError):
            e = error[0]
            return (e.code, e.message, e.context)
        return str(error)

    def _read_lob(self, lob):
        if not lob:
            return None
        return lob.read()

    def Date(self, year, month, day):
        return cx_Oracle.Date(year, month, day)

    def DatetimeFromTicks(self, ticks):
        return cx_Oracle.DatetimeFromTicks(ticks)
