#
# Copyright (c) 2008--2010 Red Hat, Inc.
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
import re
import psycopg2
import hashlib

import sql_base
from server import rhnSQL
from server.rhnSQL import sql_types

from common import log_debug, log_error
from common import UserDictCase
from const import POSTGRESQL

def convert_named_query_params(query):
    """ 
    Convert a query with named parameters (i.e. :id, :name, etc) into one
    that uses %(id)s, %(name)s parameters instead.

    python-psycopg2 requires parameters to be in this form, so to keep our
    existing queries intact we'll convert them when provided to the 
    postgresql driver.

    RETURNS: tuple with:
        - the new query with parameters replaced
        - hash of each named parameter to an ordered list of the positions
          where it was used.
        - number of arguments found and replaced
    """
    log_debug(3, "Converting query for PostgreSQL: %s" % query)
    new_query = re.sub(r'(\W):(\w+)', r'\1%(\2)s', query.replace('%', '%%'))
    log_debug(3, "New query: %s" % new_query)
    return new_query


class Procedure(sql_base.Procedure):
    """
    PostgreSQL functions are somewhat different than stored procedures in
    other databases. As a result the python-pgsql does not even implement
    the Python DBI API callproc method.

    To workaround this and keep rhnSQL database independent, we'll translate
    any incoming requests to call a procedure into a PostgreSQL query.
    """

    def __init__(self, name, cursor):
        sql_base.Procedure.__init__(self, name, cursor)

    def __call__(self, *args):
        log_debug(2, self.name, args)

        # Buildup a string for the positional arguments to the procedure:
        positional_args = ""
        i = 1
        for arg in args:
            if len(positional_args) == 0:
                positional_args = "%s"
            else:
                positional_args = positional_args + ", %s"
            i += 1
        query = "SELECT %s(%s)" % (self.name, positional_args)

        # Ugh, unicode strings coming in here, PostgreSQL doesn't like
        # getting them as such:
        new_args = []
        for arg in args:
            if type(arg) == type(u""):
                new_args.append(str(arg))
            else:
                new_args.append(arg)

        # TODO: pgsql.Cursor returned here, what to do with it?
        results = self.cursor.execute(query, new_args)

        return None



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
        try:
            if self.host is None:
                self.dbh = psycopg2.connect(database=self.database, user=self.username,
                    password=self.password)
            else:
                self.dbh = psycopg2.connect(database=self.database, user=self.username,
                    password=self.password, host=self.host, port=self.port)
        except Exception, e:
            if reconnect:
                # Try one more time:
                return self.connect(reconnect=0)

            # Failed reconnect, time to error out:
            raise apply(sql_base.SQLConnectError,
                [self.database, -1, e.message])

    def is_connected_to(self, backend, host, port, username, password,
            database):
        if not port:
            adjusted_port = -1
        return (backend == POSTGRESQL) and (self.host == host) and \
                (self.port == adjusted_port) and (self.username == username) \
                and (self.password == password) and (self.database == database)

    def check_connection(self):
        try:
            c = self.prepare("select 1")
            c.execute()
        except: # try to reconnect, that one MUST WORK always
            log_error("DATABASE CONNECTION TO '%s' LOST" % self.database,
                      "Exception information: %s" % sys.exc_info()[1])
            self.connect() # only allow one try

    def prepare(self, sql, force=0, params=None):
        if params != None:              # support for anonymour plpgsql
            sql = re.sub(r'/\*pg_cs\*/\s*cursor', '', sql)
            sql = re.sub(r'/\*pg (.+?)\*/', '\g<1>', sql)
            s = hashlib.new('sha1')
            s.update(sql)
            sha1 = s.hexdigest()
            c = self.prepare("select 1 from information_schema.routines where routine_name = 'rhn_asdf_' || :sha1");
            c.execute(sha1=sha1)
            if not c.fetchone():
                c = self.prepare("create function rhn_asdf_%s (%s) returns void as $%s$%s$%s$ language plpgsql" % ( sha1, ','.join(params), sha1, sql, sha1 ))
                c.execute()
            sql = "select rhn_asdf_%s()" % sha1
        return Cursor(dbh=self.dbh, sql=sql, force=force)

    def commit(self):
        self.dbh.commit()

    def rollback(self, name=None):
        if name:
            # PostgreSQL doesn't support savepoints, raise exception:
            # TODO: investigate this
            raise SQLError("PostgreSQL unable to rollback to savepoint: %s" % name)
        self.dbh.rollback()

    def procedure(self, name):
        c = self.dbh.cursor()
        # Pass the cursor in so we can close it after execute()
        return Procedure(name, c)

    def cursor(self):
        return Cursor(dbh=self.dbh)

    def _read_lob(self, lob):
        return str(lob)



class Cursor(sql_base.Cursor):
    """ PostgreSQL specific wrapper over sql_base.Cursor. """

    def __init__(self, dbh=None, sql=None, force=None):

        sql_base.Cursor.__init__(self, dbh, sql, force)

        # Accept Oracle style named query params, but convert for python-pgsql
        # under the hood:
        temp_sql = ""
        if self.sql is not None:
            temp_sql = self.sql
        self.sql = convert_named_query_params(temp_sql)

    def _prepare_sql(self):
        cursor = self.dbh.cursor()
        return cursor

    def _execute_wrapper(self, function, *p, **kw):
        # PostgreSQL really doesn't like getting unicode strings:
        for key, value in kw.items():
            if type(value) == type(u""):
                kw[key] = str(value)

        params =  ','.join(["%s: %s" % (str(key), str(value)) for key, value \
                in kw.items()])
        log_debug(5, "Executing SQL: \"%s\" with bind params: {%s}"
                % (self.sql, params))
        if self.sql is None:
            raise rhnException("Cannot execute empty cursor")

        try:
            retval = apply(function, p, kw)
        except psycopg2.ProgrammingError, e:
            # TODO: Constructor for this exception expects a first arg of db,
            # and yet the Oracle driver passes it an errno? Suspect it's not
            # even used.
            raise rhnSQL.SQLStatementPrepareError(0, str(e), self.sql)
        return retval

    def _execute_(self, args, kwargs):
        """
        PostgreSQL specific execution of the query.
        """
        params = UserDictCase(kwargs)
        self._real_cursor.execute(self.sql, params)
        self.description = self._real_cursor.description
        return self._real_cursor.rowcount

    def _executemany(self, *args, **kwargs):
        if not kwargs:
            return 0

        params = UserDictCase(kwargs)

        # First break all the incoming keyword arg lists into individual
        # hashes:
        all_kwargs = []
        for key in params.keys():
            if len(all_kwargs) < len(params[key]):
                for i in range(len(params[key])):
                    all_kwargs.append({})

            i = 0
            for val in params[key]:
                all_kwargs[i][key] = val
                i = i + 1

        self._real_cursor.executemany(self.sql, all_kwargs)
        self.description = self._real_cursor.description
        rowcount = self._real_cursor.rowcount
        return rowcount

    def update_blob(self, table_name, column_name, where_clause, data, 
            **kwargs):
        """ 
        PostgreSQL uses bytea columns instead of blobs. Nothing special
        needs to be done to insert text into one.
        """
        # NOTE: Injecting a :column_name parameter here
        sql = "UPDATE %s SET %s = :%s %s" % (table_name, column_name,
            column_name, where_clause)
        c = rhnSQL.prepare(sql)
        kwargs[column_name] = data
        apply(c.execute, (), kwargs)
