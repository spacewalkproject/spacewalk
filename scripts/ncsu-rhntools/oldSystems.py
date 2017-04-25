#!/usr/bin/python

# oldSystems.py - Find and possibly remove inactive systems from RHN
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
import time
import optparse
from datetime import date
from datetime import timedelta
from rhnapi import RHNClient

# Stolen from Yum
# Copyright 2005 Duke University
def userconfirm():
    """gets a yes or no from the user, defaults to No"""

    while True:
        choice = raw_input('Is this ok [y/N]: ')
        choice = choice.lower()
        if len(choice) == 0 or choice[0] in ['y', 'n']:
            break

    if len(choice) == 0 or choice[0] != 'y':
        return False
    else:
        return True
# end stealage

def parseDate(s):
    tuple = time.strptime(s, "%Y-%m-%d")
    return date.fromtimestamp(time.mktime(tuple))

def cliOptions():
    usage = "%prog <URL> [options]"
    parser = optparse.OptionParser(usage=usage)

    parser.add_option("-d", "--days", action="store", default=30,
                      type="int", dest="days", help="Your RHN server.")
    parser.add_option("--delete", action="store_true", default=False,
                      dest="delete",
                      help="Delete these registrations from RHN.")
    parser.add_option("--noconfirm", action="store_true", default=False,
                      dest="noconfirm",
                      help="Don't ask for delete confirmation.")

    if len(sys.argv) == 1:
        parser.print_help()

    opts, args = parser.parse_args(sys.argv)

    if len(args) != 2:
        print "You must provide the URL to your RHN server."
        parser.print_help()
        sys.exit(1)

    # first arg is name of the program
    opts.server = args[1]
    return opts

def search(rhn, days):
    s = rhn.server
    delta = timedelta(days=days)
    today = date.today()
    oldsystems = []
    systems = s.system.list_user_systems(rhn.session)

    for system in systems:
        #sys.stderr.write("Working on: %s  ID: %s\n" % \
        #                 (system["name"], system["id"]))

        d = parseDate(system["last_checkin"])
        if today - delta > d:
            # This machine hasn't checked in
            oldsystems.append(system)

    return oldsystems

def delete(rhn, list, noconfirm=False):
    for server in list:
        print "Removing %s..." % server["name"]
        if noconfirm or userconfirm():
            ret = rhn.server.system.deleteSystems(rhn.session,
                                                  int(server["id"]))
            if ret != 1:
                print "Removing %s failed with error code: %s" % \
                        (server["name"], ret)
        else:
            print "Skipping %s" % server["name"]

def main():

    print "Search and Destroy old RHN registrations."
    print

    o = cliOptions()

    rhn = RHNClient(o.server)
    rhn.connect()

    print "RHN API Version: %s" % rhn.server.api.system_version()
    print "Today's date = %s" % date.today().isoformat()
    print

    list = search(rhn, o.days)
    for s in list:
        print s["name"]

    print "There are %s inactive systems." % len(list)

    if o.delete:
        print "Going to delete these registrations.  Hit ^C to abort now!"
        time.sleep(5)
        delete(rhn, list, o.noconfirm)

if __name__ == "__main__":
    main()

