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
#
# Database driver for PostgreSQL
#

import sys
import pgsql

import sql_base

from common import log_debug, log_error

class Database(sql_base.Database):
    """ Class for PostgreSQL database operations. """

    def __init__(self, host=None, port=None, username=None,
        password=None, database=None):

        self.host = host
        self.port = port

        # pgsql module prefers -1 for an unspecified port:
        if not port:
            self.port = -1

        self.username = username
        self.password = password
        self.database = database

        # Minimum requirements to connect to a PostgreSQL db:
        if not (self.username and self.database):
            raise AttributeError, "PostgreSQL requires at least a user and database name."

        sql_base.Database.__init__(self, host, port, username, password, database)

    def connect(self, reconnect=1):
        self.dbh = pgsql.connect(self.database, self.username, self.password,
                self.host, self.port)

    def prepare(self, sql, force=0):
        return Cursor(dbh=self.dbh, sql=sql, force=force)

    def commit(self):
        self.dbh.commit()

class Cursor(sql_base.Cursor):
    """ PostgreSQL specific wrapper over sql_base.Cursor. """

    def _prepare_sql(self):
        cursor = self.dbh.cursor()
        return cursor

    def _execute_wrapper(self, function, *p, **kw):
        params =  ','.join(["%s: %s" % (str(key), str(value)) for key, value \
                in kw.items()])
        log_debug(5, "Executing SQL: \"%s\" with bind params: {%s}"
                % (self.sql, params))
        if self.sql is None:
            raise rhnException("Cannot execute empty cursor")

        modified_params = self._munge_args(kw)
        #try:
        retval = apply(function, p, kw)
        #except Exception, e:
        #    log_error("PostgreSQL exception", e)
        #    raise e
            #ret = self._get_oracle_error_info(e)
            #if isinstance(ret, StringType):
            #    raise sql_base.SQLError(self.sql, p, kw, ret)
            #(errno, errmsg) = ret[:2]
            #if 900 <= errno <= 999:
            #    # Per Oracle's documentation, SQL parsing error
            #    args = (errno, errmsg, self.sql)
            #    raise apply(sql_base.SQLStatementPrepareError, args)
            #if errno == 1475: # statement needs to be reparsed; force a prepare again
            #    if self.reparsed: # useless, tried that already. give up
            #        log_error("Reparsing cursor did not fix it", self.sql)
            #        args = ("Reparsing tried and still got this",) + tuple(ret)
            #        raise apply(sql_base.SQLError, args)
            #    self._real_cursor = self.dbh.prepare(self.sql)
            #    self.reparsed = 1
            #    apply(self._execute_wrapper, (function, ) + p, kw)
            #elif 20000 <= errno <= 20999: # error codes we know we raise as schema errors
            #    raise apply(sql_base.SQLSchemaError, ret)
            #raise apply(sql_base.SQLError, ret)
        #else:
        #    self.reparsed = 0 # reset the reparsed counter
        # Munge back the values
        self._unmunge_args(kw, modified_params)
        return retval

    def _execute_(self, args, kwargs):
        """ Oracle specific execution of the query. """
        if len(kwargs.keys()) > 0:
            raise sql_base.SQLError(
                    "PostgreSQL driver does not support named query parameters")
        # bindnames() is Oracle specific:
        #for k in self._real_cursor.bindnames():
        #    if not _p.has_key(k):
        #        # Raise the fault ourselves
        #        raise sql_base.SQLError(1008,
        #            'Not all variables bound', k)
        #    params[k] = adjust_type(_p[k])

        self._real_cursor.execute(self.sql, args)
        self.description = self._real_cursor.description
        return self._real_cursor.rowcount

    def _executemany(self, *args, **kwargs):
        """
        Execute query multiple times.

        For PostgreSQL only positional arguments are supported.

        Example: for query "INSERT INTO foo(fooid, fooname) VALUES($1, $2)"
        args would be: [[1, 2, 3], ["foo1", "foo2", "foo3"]]
        """
        if len(kwargs.keys()) > 0:
            raise sql_base.SQLError(
                    "PostgreSQL driver does not support named query parameters")

        self._real_cursor.executemany(self.sql, args)
        self.description = self._real_cursor.description
        rowcount = self._real_cursor.rowcount
        return rowcount
