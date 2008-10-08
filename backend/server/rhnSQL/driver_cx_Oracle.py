#!/usr/bin/env python
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
# Database driver for cx_Oracle
#

import sql_base
import sql_types
import int_oracle
import cx_Oracle
import types
import sys

from common import UserDictCase


# extract the name, value pair needed by ociDict and ociTuple functions
def __oci_name_value(names, value):
    # the format of the names is
    name, dbitype, dsize, dbsize, prec, scale, nullok = names
    name = name.lower()
    return name, value

# Adjust data types prior to calling execute()
def adjust_type(val):
    if type(val) in [types.IntType, types.FloatType]:
        # Convert it to strings to be uniform
        return str(val)
    if isinstance(val, types.UnicodeType):
        # Represent it as UTF8
        return val.encode("UTF8")
    return val

# create a ((row_name, row_value), ...) tuple for this data
# This has the advantage of returning the entries in the order requested in the
# select statement.
def ociTuple(names = None, row = None):
    data = []
    if not names:
        raise AttributeError, "Class initialization requires a description hash" 
    if row is None:
        return ()
    for x in range(len(names)):
        name, value = __oci_name_value(names[x], row[x])
        data.append((name, value))
    return tuple(data)


# create a dictionary from a row description and its values
def ociDict(names = None, row = None):
    data = {}
    if not names:
        raise AttributeError, "Class initialization requires a description hash"
    if row is None:
        return data
    for x in range(len(names)):
        name, value = __oci_name_value(names[x], row[x])
        data[name] = value
    return data


class Cursor(int_oracle.Cursor):
    OracleError = cx_Oracle.DatabaseError
    _cursor_cache = {}
    
    def __init__(self, dbh, sql=None, force_prepare=None):
        int_oracle.Cursor.__init__(self, dbh, sql=sql,
            force_prepare=force_prepare)
        # Save a copy of the description
        self.description = None

    def _prepare_sql(self):
        cursor = self.dbh.cursor()

        if self.sql is not None:
            cursor.prepare(self.sql)

        return cursor

    def _execute_(self, args, kwargs):
        # Only copy the arguments we're interested in
        _p = UserDictCase(kwargs)
        params = {}
        for k in self._real_cursor.bindnames():
            if not _p.has_key(k):
                # Raise the fault ourselves
                raise sql_base.SQLError(1008, 
                    'Not all variables bound', k)
            params[k] = adjust_type(_p[k])
        # cx_Oracle expects the first arg to be the statement and no
        # positional args
        self._real_cursor.execute(*(None, ), **params)
        self.description = self._real_cursor.description
        return self._real_cursor.rowcount

    def _executemany(self, *args, **kwargs):
        # cx_Oracle expects the first arg to be the statement
        if not kwargs:
            return 0
        # Compute number of values
        max_array_size = 100
        i = kwargs.itervalues()
        firstval = i.next()
        array_size = len(firstval)
        if array_size == 0:
            return 0
        chunk_size = min(max_array_size, array_size)
        pdict = {}
        for k in kwargs.iterkeys():
            pdict[k] = None
        arr = []
        for i in xrange(chunk_size):
            arr.append(pdict.copy())

        # Now arr is an array of the desired size
        rowcount = 0
        start = 0
        while start < array_size:
            item_count = min(array_size - start, chunk_size)
            # Trim the array if it is too big
            if item_count != chunk_size:
                arr = arr[:item_count]

            for i in xrange(item_count):
                pdict = arr[i]
                for k, v in kwargs.iteritems():
                    pdict[k] = adjust_type(v[start+i])
                
            self._real_cursor.executemany(None, arr)
            self.description = self._real_cursor.description
                
            rowcount = rowcount + self._real_cursor.rowcount
            start = start + chunk_size

        return rowcount

    def fetchone(self):
        return self._real_cursor.fetchone()

    def fetchone_dict(self):
        ret = ociDict(self.description, self._real_cursor.fetchone())

        if len(ret) == 0:
            return None
        return ret

    def fetchmany_dict(self, howmany=None):
        rows = self._real_cursor.fetchmany(howmany)

	ret = []
	for x in rows:
	    d = ociDict(self.description, x)
	    if len(d) > 0:
		ret.append(d)
	if ret == []:
	    return None
	return ret

    def fetchall(self):
        rows = self._real_cursor.fetchall()
        return rows

    def fetchall_dict(self):
        rows = self._real_cursor.fetchall()

        ret = []
        for x in rows:
            d = ociDict(self.description, x)
            if len(d) > 0:
                ret.append(d)
        if ret == []:
            return None
        return ret

    def fetchone_tuple(self):
        ret = ociTuple(self.description, 
            self._real_cursor.fetchone())

	if len(ret) == 0:
	    return None
	return ret

    def fetchmany_tuple(self, howmany=None):
        rows = self._real_cursor.fetchmany(howmany)

	ret = []
	for x in rows:
	    d = ociTuple(self.description, x)
	    if len(d) > 0:
		ret.append(d)
	if ret == []:
	    return None
	return ret

    def fetchall_tuple(self):
        rows = self._real_cursor.fetchall()
        
	ret = []
	for x in rows:
	    d = ociTuple(self.description, x)
	    if len(d) > 0:
		ret.append(d)
	if ret == []:
	    return None
	return ret

    def _get_oracle_error_info(self, error):
        if isinstance(error, cx_Oracle.DatabaseError):
            e = error[0]
            return (e.code, e.message, self.sql)
        return str(error)

    _munge_maps = [
        (sql_types.NUMBER, cx_Oracle.NUMBER),
        (sql_types.STRING, cx_Oracle.STRING),
        (sql_types.BINARY, cx_Oracle.BINARY),
        (sql_types.LONG_BINARY, cx_Oracle.LONG_BINARY),
    ]

    def _munge_arg(self, val):
        for sqltype, oracletype in self._munge_maps:
            if isinstance(val, sqltype):
                var = self._real_cursor.var(oracletype, val.size)
                var.setvalue(0, val.get_value())
                return var

        # XXX
        return val.get_value()

    def _unmunge_args(self, kw_dict, modified_params):
        for k, v in modified_params:
            v.set_value(kw_dict[k].getvalue())

class Procedure(int_oracle.Procedure):
    def _call_proc(self, args):
        return self._call_proc_ret(args, ret_type=None)

    def _call_proc_ret(self, args, ret_type=None):
        args = map(adjust_type, self._munge_args(args))
        if ret_type:
            for sqltype, oracletype in Cursor._munge_maps:
                if isinstance(ret_type, sqltype):
                    ret_type = oracletype
                    break
            else:
                raise Exception("Unknown type", ret_type)

        try:
            if ret_type:
                return self.proc.callfunc(self.name, ret_type, args)
            else:
                return self.proc.callproc(self.name, args)
        except cx_Oracle.NotSupportedError, error:
            raise apply(sql_base.SQLError, error.args)
        except cx_Oracle.DatabaseError, error:
            e = error[0]
            raise sql_base.SQLSchemaError(e.code, e.message, e.context)

    def __del__(self):
        if self.proc:
            self.proc.close()
            self.proc = None

    def _munge_args(self, args):
        new_args = []
        for arg in args:
            if not isinstance(arg, sql_types.DatabaseDataType):
                new_args.append(arg)
                continue
            new_args.append(self._munge_arg(arg))
        return new_args

    def _munge_arg(self, val):
        for sqltype, oracletype in Cursor._munge_maps:
                var = self.proc.var(oracletype, val.size)
                var.setvalue(0, val.get_value())
                return var

        # XXX
        return val.get_value()

class Function(Procedure):
    def __init__(self, name, proc, ret_type):
        Procedure.__init__(self, name, proc)
        self.ret_type = ret_type

    def _call_proc(self, args):
        return self._call_proc_ret(args, self.ret_type)

class Database(int_oracle.Database):
    _cursor_class = Cursor
    _procedure_class = Procedure
    TimestampFromTicks = cx_Oracle.TimestampFromTicks
    OracleError = cx_Oracle.DatabaseError

    def _connect(self):
        dbh = cx_Oracle.Connection(self.database)
        if hasattr(sys, "argv"):
          dbh.cursor().execute("BEGIN DBMS_APPLICATION_INFO.SET_MODULE('%s',NULL); END;" % sys.argv[0])  
        return dbh

    def procedure(self, name):
        try:
            c = self.dbh.cursor()
        except cx_Oracle.DatabaseError, error:
            e = error[0]
            raise sql_base.SQLSchemaError(e.code, e.message, e.context)
        # Pass the cursor in so we can close it after execute()
        return self._procedure_class(name, c)

    def _function(self, name, ret_type):
        try:
            c = self.dbh.cursor()
        except cx_Oracle.DatabaseError, error:
            e = error[0]
            raise sql_base.SQLSchemaError(e.code, e.message, e.context)
        return Function(name, c, ret_type)

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

