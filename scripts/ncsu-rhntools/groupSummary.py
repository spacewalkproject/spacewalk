#!/usr/bin/python
#
# groupSummary.py - Prints out summary of groups in RHN
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

import sys

from rhnapi import RHNClient

rhn = RHNClient("https://rhn.linux.ncsu.edu/rpc/api")
rhn.connect()

print "RHN API Version: %s" % rhn.server.api.system_version()

print "Session ID = %s" % rhn.session

s = rhn.server

group_tally = {}
ungrouped = []
systems = s.system.list_user_systems(rhn.session)
c = 0

for system in systems:
    sys.stderr.write("Working on: %s\n" % system["name"])
    sys.stderr.write("          : %s\n" % system["id"])

    c = c + 1
    grps = s.system.list_groups(rhn.session, int(system["id"]))
    flag = 0

    for grp in grps:
        name = grp["system_group_name"]
        if int(grp["subscribed"]) > 0:
            flag = 1
            if group_tally.has_key(name):
                group_tally[name] = group_tally[name] + 1
            else:
                group_tally[name] = 1

    if not flag:
        ungrouped.append(system)

# Print out the group_tally nicely
for key in group_tally.keys():
    print "%s: %s" % (key, group_tally[key])

print "Ungrouped Systems:"
for system in ungrouped:
    print "   %s" % system["name"]

print "Total Systems: " + str(c)

