#!/usr/bin/python
#
# rhnstats.py - Generate db/web/csv statistics for RHN usage.
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

# The rhnapi module is a directory above
sys.path.append("../")

from rhnapi import RHNClient
import rhndb
import pysqlite
import config
import time
import optparse
import kid
from sets import Set

# What channels define Realm Linux?
RLChannels = Set(["realmlinux-as4",
                  "realmlinux-ws4",
                  "realmlinux-as3",
                  "realmlinux-ws3",
                  "realmlinux-ws4-amd64",
                  "realmlinux-as4-amd64",
                  "realmlinux-ws3-amd64",
                  "realmlinux-as3-amd64",
                  "realmlinux-server5-i386",
                  "realmlinux-client5-i386",
                  "realmlinux-server5-x86_64",
                  "realmlinux-client5-x86_64",
                 ])

def parseOpts():
    opts = optparse.OptionParser()
    opts.add_option("", "--csv", action="store_true", default=False,
                    dest="csv", help="Output in CSV Format")
    opts.add_option("", "--localdb", action="store_true", default=False,
                    dest="localdb", help="Don't Query RHN")

    opts, args = opts.parse_args(sys.argv)
    return opts

def main():

    opts = parseOpts()
    dbcfg = config.DBConfig()
    rhncfg = config.RHNConfig()

    sdb = pysqlite.PySqliteDB(dbcfg)
    db = rhndb.RHNStore(sdb)

    if not opts.localdb:
        rhn = RHNClient(rhncfg.getURL())
        rhn.connect(rhncfg.getUserName(), rhncfg.getPassword())

        populate(db, rhn)

    if opts.csv:
        print "Writing CSV file..."
        doCSV(db)
    else:
        doHTML(db)

def populate(db, rhn):
    clients = []
    rlclients = []
    systems = rhn.server.system.list_user_systems(rhn.session)

    for system in systems:
        #sys.stderr.write("Working on: %s\n" % system["name"])
        system["id"] = int(system["id"])
        clientid = db.addSystem(system)
        subscribedTo = []
        clients.append(clientid)

        # Sub Channels available for subscription, does not include
        # already subscribed sub channels.
        channels =  rhn.server.system.list_child_channels(rhn.session,
                                                          system["id"])
        chanLabels = Set([ i['LABEL'] for i in channels ])

        if len(RLChannels.intersection(chanLabels)) == 0:
            rlclients.append(clientid)

        grps = rhn.server.system.list_groups(rhn.session, system["id"])
        flag = 0

        for grp in grps:
            groupid = db.addGroup(grp)
            name = grp["system_group_name"]
            if int(grp["subscribed"]) > 0:
                flag = 1
                subscribedTo.append(groupid)

        db.subscribeGroup(clientid, subscribedTo)

    db.markActive(clients)
    db.markRL(rlclients)
    db.commit()

def doCSV(db):
    file = "rhn.csv"
    table = [["Name", "Number of Licenses", "Number of Realm Linux Clients",
              "Percentage of Total Licnese"]]

    total = db.getTotalCount()

    for group in db.getGroups():
        row = []
        row.append(db.getGroupName(group))
        row.append(db.getGroupCount(group))
        row.append(db.getGroupRLCount(group))
        p = int(10000 * float(db.getGroupCount(group)) / float(total))
        row.append(p / 100.0)

        table.append(row)

    fd = open(file, 'w')
    for row in table:
        for field in row:
            if field == row[0]:
                fd.write("%s" % field)
            else:
                fd.write(",%s" % field)
        fd.write("\n")

    fd.write("\nTotal Licenes,%s" % total)
    fd.close()

def doHTML(db):
    file = "rhn.phtml"
    templatefile = "template.kid"
    table = []

    total = db.getTotalCount()

    for group in db.getGroups():
        d = {}
        d["name"] = db.getGroupName(group)
        d["count"] = db.getGroupCount(group)
        d["rlcount"] = db.getGroupRLCount(group)
        p = int(10000 * float(d["count"]) / float(total))
        d["percent"] = p / 100.0

        table.append(d)

    template = kid.Template(file=templatefile)
    template.total = total
    template.totalrl = db.getTotalRLCount()
    template.table = table
    template.date = time.strftime("%A %B %d %H:%M:%S %Z %Y")

    template.write(file, fragment=True)


if __name__ == "__main__":
    main()

