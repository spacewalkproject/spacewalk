# pysqlite.py - Interface to the SQLite database
# Copyright (C) 2002 Hunter Matthews
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.


""" An implementation of currents backend as an sqlite database.

   Sqlite is a single file 'embedded' database that supports nearly all
   of the SQL-92 standard. Its a near perfect replacement for the old
   shelve implementation.

"""

import os
import os.path

import sqlite
import schema

class SQLite(Exception):
    pass

class PySqliteDB(object):

    def __init__(self, config):
        """ Initialize the new database object. """

        self.config = config
        self.conn = None
        self.cursor = None

        self.db_file = self.config.DBFile()

        if not os.path.exists(self.db_file):
            self.initdb()
        else:
            self.getConnection()


    def __del__(self):
        self.disconnect()


    def disconnect(self):
        """ Close down the database file. """
        if self.cursor:
            self.cursor.close()
            self.cursor = None
        if self.conn:
            self.conn.close()
            self.conn = None


    def initdb(self):
        """ Do the steps necessary to create an empty database.

        This should be enough to get the mod_python module working.
        """
        self.getConnection()
        self.getCursor()

        # initialize the database schema
        # FIXME: Naturally, we should require some extra 'force' variable
        # to overwrite the database here.
        self.cursor.execute(schema.INITDB)
        self.conn.commit()


    def getConnection(self):
        if self.conn == None:
            try:
                self.conn = sqlite.connect(db=self.db_file)
            except Exception, e:
                log("Exception raised in sqlite.connect()", MANDATORY)
                raise

        return self.conn


    def getCursor(self):
        if self.cursor == None:
            self.cursor = self.conn.cursor()

        return self.conn.cursor()


## END OF LINE ##
