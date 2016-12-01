#!/usr/bin/python
"""
Multi-Org: Script to migrate server from one org to another

Script that connects to a given satellite db and migrates the
server and its history from source org to the destination org.

Copyright (c) 2008--2015 Red Hat, Inc.  Distributed under GPL.
Author: Pradeep Kilambi <pkilambi@redhat.com>

"""

import os
import sys
import xmlrpclib

from optparse import OptionParser, Option
from spacewalk.common.cli import getUsernamePassword, xmlrpc_login, xmlrpc_logout

_topdir = '/usr/share/rhn'
if _topdir not in sys.path:
    sys.path.append(_topdir)

client = None
DEBUG = 0

options_table = [
    Option("-v", "--verbose",       action="count",
           help="Increase verbosity"),
    Option("-u", "--username",       action="store",
           help="Satellite/Org Admin username"),
    Option("-p", "--password",       action="store",
           help="Satellite/Org Admin password"),
    Option("--satellite",       action="store",
           help="Satellite server to run migration"),
    Option("--systemId",               action="append",
           help="client system to migrate"),
    Option("--to-org-id",          action="store",
           help="Destination Org ID"),
    Option("--csv",                action="store",
           help="CSV File to process"),
]

_csv_fields = ['systemId', 'to-org-id']


def main():
    global client, DEBUG
    parser = OptionParser(option_list=options_table)

    (options, _args) = parser.parse_args()

    if options.satellite:
        satellite_host = options.satellite
    else:
        satellite_host = os.uname()[1]

    if options.verbose:
        DEBUG = 1

    satellite_url = "http://%s/rpc/api" % satellite_host
    if DEBUG:
        print "Connecting to %s" % satellite_url

    client = xmlrpclib.Server(satellite_url, verbose=0)

    if options.csv:
        migrate_data = read_csv_file(options.csv)
    else:
        migrate_data = []

    if not options.csv:
        if not options.systemId:
            print "Missing --systemId"
            return 1

        if not options.to_org_id:
            print "Missing Destination org id"
            return
        else:
            to_org_id = options.to_org_id or None

        migrate_data = [[options.systemId, to_org_id]]

    username, password = getUsernamePassword(options.username,
                                             options.password)

    sessionKey = xmlrpc_login(client, username, password)

    if not migrate_data:
        sys.stderr.write("Nothing to migrate. Exiting.. \n")
        sys.exit(1)

    for server_id, to_org_id in migrate_data:
        if isinstance(server_id, type([])):
            server_id = map(int, server_id)
        else:
            server_id = [int(server_id)]
        try:
            migrate_system(sessionKey, int(to_org_id), server_id)
        except Exception:
            raise

    if DEBUG:
        print "Migration Completed successfully"
    xmlrpc_logout(client, sessionKey)


def migrate_system(key, newOrgId, server_ids):
    """
    Call to migrate given system to new org
    """
    if DEBUG:
        print "Migrating systemIds %s to Org %s" % (server_ids, newOrgId)
    try:
        client.org.migrateSystems(key, newOrgId, server_ids)
    except xmlrpclib.Fault, e:
        sys.stderr.write("Error: %s\n" % e.faultString)
        sys.exit(-1)

    return


def lookup_server(key, from_org_id):
    # Get the org id
    # TODO: replace with an api call
    rows = client.org.listServerByOrg(key, from_org_id)
    if not rows:
        sys.stderr.write("No Systems registered for Org-ID %s \n" % from_org_id)
        sys.exit(1)
    print "                                    "
    print "Available Systems for Org-ID: %s " % from_org_id
    print "------------------------------------"
    print " Server-ID      Server-Name         "
    print "------------------------------------"
    for row in rows:
        print " %s   %s " % (row['id'], row['name'])
    print "--------------------------------------------"

    return rows


def read_csv_file(csv_file):
    """
     Parse the fields in the given csv
    """
    import csv
    csv_data = []
    f_csv = open(csv_file)
    reader = csv.reader(f_csv)
    for data in reader:
        if len(data) != len(_csv_fields):
            sys.stderr.write("Invalid Data.Skipping line .. \n"
                             % data)
            continue
        csv_data.append(data)
    return csv_data

if __name__ == '__main__':
    sys.exit(main() or 0)
