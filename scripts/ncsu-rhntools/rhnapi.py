#!/usr/bin/python

# rhnapi.py - A simple connector for the RHN XMLRPC API
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

import xmlrpclib
import sys
import getpass

class RHNClient(object):

    def __init__(self, serverURL):
        self.url = serverURL


    def connect(self, user=None, password=None):
        self.server = xmlrpclib.ServerProxy(self.url)
        if user == None or password == None:
            user, password = self.auth()

        self.session = self.server.auth.login(user, password, 3600)


    def auth(self):
        sys.stdout.write("RHN User Name: ")
        id = sys.stdin.readline()
        id = id.strip()

        pw = getpass.getpass("RHN Password: ")

        return id, pw

