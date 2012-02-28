#!/usr/bin/python
"""
Delete Snapshots: Script to delete system snapshots.

This script using the XMLRPC APIs will connect to the Satellite and
list or delete system snapshots based on the parameters given by the user.

Copyright (c) 2009--2012 Red Hat, Inc.  Distributed under GPL.
Author: Brad Buckingham <bbuckingham@redhat.com>

# $Id: systemSnapshot.py
"""

import os
import sys
import xmlrpclib
from time import strptime
from datetime import datetime

_topdir = '/usr/share/rhn'
if _topdir not in sys.path:
    sys.path.append(_topdir)

from optparse import OptionParser, Option
from spacewalk.common.cli import getUsernamePassword, xmlrpc_login, xmlrpc_logout

client = None

options_table = [
    Option("-v", "--verbose",        action="count",
        help="Increase verbosity"),
    Option("-u", "--username",       action="store",
        help="Username"),
    Option("-p", "--password",       action="store",
        help="Password"),
    Option("-d", "--delete",         action="count",
        help="Delete snapshots."),
    Option("-l", "--list",           action="count",
        help="List snapshot summary."),
    Option("-a", "--all",            action="count",
        help="Include all snapshots based on criteria provided."),
    Option("--start-date",           action="store",
        help="Include only snapshots taken on or after this date.  Must be in the format 'YYYYMMDDHH24MISS'."),
    Option("--end-date",             action="store",
        help="Include only snapshots taken on or before this date. Must be in the format 'YYYYMMDDHH24MISS'."),
    Option("--satellite",            action="store",
        help="Server."),
    Option("--system-id",            action="append",
        help="System Id."),
    Option("--snapshot-id",          action="append",
        help="Snapshot Id."),
]

options = None

def main():

    global client, options

    parser = OptionParser(option_list=options_table)
    (options, _args) = parser.parse_args()
    processCommandLine()

    satellite_url = "http://%s/rpc/api" % options.satellite

    if options.verbose:
        print "start date=", options.start_date
        print "end date=", options.end_date
        print "connecting to %s" % satellite_url

    client = xmlrpclib.Server(satellite_url, verbose=0)

    username, password = getUsernamePassword(options.username, \
                            options.password)

    sessionKey = xmlrpc_login(client, username, password, options.verbose)

    if options.all:

        if options.start_date and options.end_date:
            deleteAllBetweenDates(sessionKey, options.start_date, \
                options.end_date)

        elif options.start_date:
            deleteAllAfterDate(sessionKey, options.start_date)

        else:
            deleteAll(sessionKey)

    elif options.system_id:

        if options.start_date and options.end_date:
            deleteBySystemBetweenDates(sessionKey, options.system_id, \
                options.start_date, options.end_date)

        elif options.start_date:
            deleteBySystemAfterDate(sessionKey, options.system_id, \
                options.start_date)

        else:
            deleteBySystem(sessionKey, options.system_id)

    elif options.snapshot_id:

        deleteBySnapshotId(sessionKey, options.snapshot_id)

    if options.verbose:
        print "Delete Snapshots Completed successfully"

    xmlrpc_logout(client, sessionKey, options.verbose)

def deleteAllBetweenDates(sessionKey, startDate, endDate):
    """
     Delete all snapshots where the snapshot was created either on or between
     the dates provided.
    """
    if options.verbose:
        print "...executing deleteAllBetweenDates..."

    systems = client.system.listSystems(sessionKey)

    for system in systems:

        snapshots = client.system.provisioning.snapshot.listSnapshots( \
                    sessionKey, system.get('id'), {"startDate":startDate, \
                    "endDate":endDate})

        if options.list:
            listSnapshots(system.get('id'), snapshots)

        else:
            client.system.provisioning.snapshot.deleteSnapshots(sessionKey, \
                {"startDate":startDate, "endDate":endDate})


def deleteAllAfterDate(sessionKey, startDate):
    """
     Delete all snapshots where the snapshot was created either on or after
     the date provided.
    """
    if options.verbose:
        print "...executing deleteAllAfterDate..."

    systems = client.system.listSystems(sessionKey)

    for system in systems:

        snapshots = client.system.provisioning.snapshot.listSnapshots( \
                    sessionKey, system.get('id'), {"startDate":startDate})

        if options.list:
            listSnapshots(system.get('id'), snapshots)

        else:
            client.system.provisioning.snapshot.deleteSnapshots(sessionKey, \
                {"startDate":startDate})


def deleteAll(sessionKey):
    """
     Delete all snapshots across all systems that the user has access to.
    """
    if options.verbose:
        print "...executing deleteAll..."

    systems = client.system.listSystems(sessionKey)

    for system in systems:

        snapshots = client.system.provisioning.snapshot.listSnapshots( \
                    sessionKey, system.get('id'), {})

        if options.list:
            listSnapshots(system.get('id'), snapshots)

        else:
            client.system.provisioning.snapshot.deleteSnapshots(sessionKey, \
                {})


def deleteBySystemBetweenDates(sessionKey, systemIds, startDate, endDate):
    """
     Delete the snapshots for the systems provided where the snapshot was
     created either on or between the dates provided.
    """
    if options.verbose:
        print "...executing deleteBySystemBetweenDates..."

    for systemId in systemIds:
        systemId = int(systemId)

        try:
            snapshots = client.system.provisioning.snapshot.listSnapshots( \
                        sessionKey, systemId, {"startDate":startDate, \
                        "endDate":endDate})

            if options.list:
                listSnapshots(systemId, snapshots)

            else:
                client.system.provisioning.snapshot.deleteSnapshots( \
                    sessionKey, systemId, \
                    {"startDate":startDate, "endDate":endDate})

        except xmlrpclib.Fault, e:
            # print an error and go to the next system
            sys.stderr.write("Error: %s\n" % e.faultString)


def deleteBySystemAfterDate(sessionKey, systemIds, startDate):
    """
     Delete the snapshots for the systems provided where the snapshot was
     created either on or after the date provided.
    """
    if options.verbose:
        print "...executing deleteBySystemAfterDate..."

    for systemId in systemIds:
        systemId = int(systemId)

        try:
            snapshots = client.system.provisioning.snapshot.listSnapshots( \
                        sessionKey, systemId, {"startDate":startDate})

            if options.list:
                listSnapshots(systemId, snapshots)

            else:
                client.system.provisioning.snapshot.deleteSnapshots( \
                    sessionKey, systemId, {"startDate":startDate})

        except xmlrpclib.Fault, e:
            # print an error and go to the next system
            sys.stderr.write("Error: %s\n" % e.faultString)


def deleteBySystem(sessionKey, systemIds):
    """
     Delete all snapshots for the systems provided.
    """
    if options.verbose:
        print "...executing deleteBySystem..."

    for systemId in systemIds:
        systemId = int(systemId)

        try:
            snapshots = client.system.provisioning.snapshot.listSnapshots( \
                        sessionKey, systemId, {})

            if options.list:
                listSnapshots(systemId, snapshots)

            else:
                client.system.provisioning.snapshot.deleteSnapshots( \
                    sessionKey, systemId, {})

        except xmlrpclib.Fault, e:
            # print an error and go to the next system
            sys.stderr.write("Error: %s\n" % e.faultString)


def deleteBySnapshotId(sessionKey, snapshotIds):
    """
     Delete the list of snapshots provided.  If the user does not have
     access to one or more of those snapshots, they will be ignored.
    """
    if options.verbose:
        print "...executing deleteBySnapshotId..."

    for snapshotId in snapshotIds:

        try:
            if options.list:
                print "snapshotId: ", snapshotId

            else:
                client.system.provisioning.snapshot.deleteSnapshot(sessionKey, \
                    int(snapshotId))

        except xmlrpclib.Fault, e:
            # print an error and go to the next system
            sys.stderr.write("Error: %s\n" % e.faultString)


def listSnapshots(systemId, snapshots):
    """
      List to stdout the snapshot summaries for the system provided.
      This will include:
        system id, # snapshots, date of oldest snapshot, date of newest snapshot
    """
    if len(snapshots) > 0:
        # obtain the dates of the oldest and newest snapshot...
        #
        # the dates will be in dateTime.iso8601 format
        # (e.g. 20090325T13:18:11); therefore, convert them to a
        # friendlier format (e.g. 2009-03-25 13:18:11) for output

        newest = snapshots[0].get('created')
        newest = datetime(*(strptime(newest.value, "%Y%m%dT%H:%M:%S")[0:6]))

        oldest = snapshots[len(snapshots)-1].get('created')
        oldest = datetime(*(strptime(oldest.value, "%Y%m%dT%H:%M:%S")[0:6]))

        print "systemId: %d, snapshots: %d, oldest: %s, newest: %s"  \
            % (systemId, len(snapshots), oldest, newest)

def processCommandLine():

    if not options.satellite:
        options.satellite = os.uname()[1]

    if not options.delete and not options.list:
        sys.stderr.write("Must include a command options (--list, --delete)\n")
        sys.exit(1)

    if not options.all and not options.system_id and not options.snapshot_id:
        sys.stderr.write("Must include one of the required parameters (--all, --system-id or --snapshot-id\n")
        sys.exit(1)

    if options.snapshot_id and (options.start_date or options.end_date):
        sys.stderr.write("--start-date and --end-date options do not apply when specifying --snapshot-id\n")
        sys.exit(1)

    if options.end_date and not options.start_date:
        sys.stderr.write("--end-date must be used with --start-date.\n")
        sys.exit(1)

    # convert the start / end dates to a format that usable by the xmlrpc api
    if options.start_date:
        options.start_date = datetime(*(strptime(options.start_date, "%Y%m%d%H%M%S")[0:6]))
        options.start_date = xmlrpclib.DateTime(options.start_date.timetuple())

    if options.end_date:
        options.end_date = datetime(*(strptime(options.end_date, "%Y%m%d%H%M%S")[0:6]))
        options.end_date = xmlrpclib.DateTime(options.end_date.timetuple())

if __name__ == '__main__':
    sys.exit(main() or 0)
