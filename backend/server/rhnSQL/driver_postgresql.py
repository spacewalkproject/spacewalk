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
import re
import pgsql

import sql_base

from common import log_debug, log_error

NAMED_PARAM_REGEX = re.compile(":\w+")

def convert_named_query_params(query):
    """ 
    Convert a query with named parameters (i.e. :id, :name, etc) into one
    that uses $1 .. $n positional parameters instead.

    python-pgsql requires parameters to be in this form, so to keep our 
    existing queries intact we'll convert them when provided to the 
    postgresql driver.

    RETURNS: tuple of the new query with parameters replaced, and a hash of 
    each named parameter to an ordered list of the positional indicies where 
    it was used. (to accomodate any situations where the same named param was
    used multiple times in the query)
    """
    log_debug(3, "Converting query for PostgreSQL: %s" % query)
    pattern = NAMED_PARAM_REGEX

    
    # Apologies for getting a little crazy here. Using the patterns sub method
    # allows us to specify a function as the replacement value, but this 
    # function will only be called with a match parameter. In this case we
    # also need to maintain a running counter of which index we're on (as we
    # increment from $1 to $n each time we encounter a :param) as well as a 
    # hash of the parameters we replaced and their new index number.
    #
    # To get around this I defined a param_matcher function which takes a list
    # (note: mutable object to get around Python's normal pass by value 
    # behavior) with two items. (see below)
    #
    # A lambda function is then used to call this helper function with the
    # desired number of arguments.

    # List with index counter and the running param to index hash:
    index_data = [1, {}]
    f = lambda m: param_replacer(m, index_data)

    new_query = pattern.sub(f, query)
    log_debug(3, "New query: %s" % new_query)
    return (new_query, index_data[1])

def param_replacer(match, index_data):
    """ 
    Helper function for replacing named query params in a string.

    Intended to be passed to sub, but only indirectly via another lambda 
    function, which must exist to pass us additional arguments as the
    call to sub would only provide us with a match object. (we need the
    positional index of the argument as well)

    index_data is a list with two elements, the first is a counter 
    representing the next argument number to be used. (increments $1 to $2, 
    etc) The second is a hash of parameter name to it's new index number.
    """
    matched_param = match.group()[1:]

    counter = index_data[0] # don't increment this var directly
    param_index = index_data[1]

    # if the index doesn't yet have this parameter, add it and hash to an
    # empty list:
    if not param_index.has_key(matched_param):
        param_index[matched_param] = []
    param_index[matched_param].append(counter)
    index_data[0] = index_data[0] + 1
    return "$%s" % counter

    

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

    # TODO: Need to implement execute_bulk but the existing syntax for Oracle
    # is all but useless in PostgreSQL due to the keyword arguments.
