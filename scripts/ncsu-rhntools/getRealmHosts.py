#!/usr/bin/python

# getRealmHosts.py - Suck a list of hosts out of the RLMTools database
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


import pickle
import MySQLdb
import getpass

host="mysql02.unity.ncsu.edu"
user="realmlinux"
passwd = getpass.getpass("CLS Mysql Password:")
db="realmlinux"

conn = MySQLdb.connect(host=host, user=user, passwd=passwd, db=db)
cursor = conn.cursor()
cursor.execute("select hostname from realmlinux")

l = []

for row in cursor.fetchall():
    print row[0]
    l.append(row[0])

s = pickle.dumps(l)
fd = open("hosts.pic", "w")
fd.write(s)
fd.close()

print len(l)

