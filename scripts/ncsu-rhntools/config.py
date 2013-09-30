# config.py - Simple configuration parsers
# Copyright (C) 2007 NC State University
# Written by Jack Neely <jjneely@ncsu.edu>
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

import ConfigParser

class Configuration(object):

    type = ""

    def __init__(self):
        self.cfg = ConfigParser.ConfigParser()
        files = self.cfg.read(['rhn.conf'])

        #if files == None:
        #    raise Exception("Configuration file not found.")

    def get(self, key):
        return self.cfg.get(self.type, key)


class RHNConfig(Configuration):

    type = "rhn"

    def getURL(self):
        return self.get("url")

    def getUserName(self):
        return self.get("user")

    def getPassword(self):
        return self.get("password")


class DBConfig(Configuration):

    type = "db"

    def getDBType(self):
        return self.get("db_type")

    def DBFile(self):
        return self.get("db")

    #def ConfigDir(self):
    #    return self.get("configs")

