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

import time
import string
import sql_base
import sql_types
import int_oracle
import DCOracle

class Procedure(int_oracle.Procedure):
    def _call_proc(self, args):
        return self._call_proc_ret(args, ret=None)

    def _call_proc_ret(self, args, ret=None):
        assert (ret is None or isinstance(ret, sql_types.DatabaseDataType))
        # Build a query
        args_dict = {}
        if ret is not None:
            query_templ = "begin :ret := %s(%s); end;"
            args_dict['ret'] = ret
        else:
            query_templ = "begin %s(%s); end;"
            
        args_list = []
        args_count = len(args)
        for i in range(args_count):
            key = "p%d" % i
            args_list.append(':' + key)
            args_dict[key] = args[i]

        query = query_templ % (self.name, string.join(args_list, ', '))

        cursor = self.proc
        try:
            cursor.prepare(query)
            apply(cursor.execute, (), args_dict)
        except DCOracle.OracleError, error:
            if hasattr(error, "args"):
                raise apply(sql_base.SQLSchemaError, error.args)
            raise sql_base.SQLError(str(error))

        if ret is not None:
            # Returns the function's return value
            ret = args_dict['ret']
            return ret.get_value()
            
        # Now fetch the results
        results = []
        for i in range(args_count):
            val = args_dict["p%d" % i]
            if isinstance(val, sql_types.DatabaseDataType):
                results.append(val.get_value())
            else:
                results.append(val)

        # XXX function case?
        return results
    

class Function(Procedure):  
    def _call_proc(self, args):
        # self.ret_type is set in Database.function() - ignore pychecker
        return self._call_proc_ret(args, ret=self.ret_type)
    

class Cursor(int_oracle.Cursor):
    OracleError = DCOracle.OracleError
    _cursor_cache = {}
    
    def _prepare_sql(self):
        if self.sql is None:
            return None
        cursor = self.dbh.prepare(self.sql)
        return cursor

    def _get_oracle_error_info(self, error):
        if hasattr(error, "args"):
            return error.args
        return str(error)

    def _munge_arg(self, val):
        v = None
        if isinstance(val, sql_types.NUMBER):
            v = DCOracle.Buffer(val.size, "i")
            val_value = val.get_value()
            if val_value is not None:
                v[0] = val_value
            return v
        if isinstance(val, sql_types.STRING):
            v = DCOracle.Buffer(1, val.size)
            # XXX How in the world do I set the value here?
            # If I try to do v[0] = 'aa' I get back:
            # TypeError: assignment would change the size of the buffer
            # Not setting it for now
            return v
        if isinstance(val, sql_types.BINARY) or \
                isinstance(val, sql_types.LONG_BINARY):
            return DCOracle.dbi.dbiRaw(val.get_value())
        # XXX
        return val.get_value()

    def _unmunge_args(self, kw_dict, modified_params):
        for k, v in modified_params:
            value = kw_dict[k]
            # Is it a RAW?
            if isinstance(v, sql_types.BINARY) or \
                    isinstance(v, sql_types.LONG_BINARY):
                v.set_value(value._v)
                continue
            
            # It's a buffer
            value = value[0]
            if isinstance(value, type("")):
                # Strip the trailing null chars
                v.set_value(value[:string.find(value, '\000')])
            else:
                v.set_value(value)


class Database(int_oracle.Database):
    _cursor_class = Cursor
    _procedure_class = Procedure
    _function_class = Function
    TimestampFromTicks = DCOracle.dbi.dbiDate
    DateFromTicks = DCOracle.dbi.dbiDate
    OracleError = DCOracle.OracleError

    def _connect(self):
        dbh = DCOracle.Connect(self.database)
        return dbh

    def procedure(self, name):
        return self._procedure_class(name, self.cursor())

    def _function(self, name, ret_type):
        p = self._function_class(name, self.cursor())
        p.ret_type = ret_type
        return p
    
    def _get_oracle_error_info(self, error):
        if hasattr(error, "args"):
            return error.args
        return str(error)

    def _read_lob(self, lob):
        if not lob:
            return None
        
        lob_len = lob.length()
        # XXX
        # For some reason, Oracle thinks my character set is multibyte; not
        # passing csid will make the thing read just a third of the characters.
        # Forcing the character set for now
        return lob.read(lob_len, 1, 1)

    def Date(self, year, month, day):
        seconds = time.mktime(year, month, day, 0, 0, 0, 0, 0, -1)
        return self.DateFromTicks(seconds)
