#
# Licensed under the GNU General Public License Version 3
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# Copyright 2013 Aron Parsons <aronparsons@gmail.com>
# Copyright (c) 2013--2018 Red Hat, Inc.
#

# NOTE: the 'self' variable is an instance of SpacewalkShell

# wildcard import
# pylint: disable=W0401,W0614

# unused argument
# pylint: disable=W0613

# invalid function name
# pylint: disable=C0103

from spacecmd.utils import *


def help_scap_listxccdfscans(self):
    print('scap_listxccdfscans: Return a list of finished OpenSCAP scans for given systems')
    print('usage: scap_listxccdfscans <SYSTEMS>')


def complete_system_scap_listxccdfscans(self, text, line, beg, end):
    return self.tab_complete_systems(text)


def do_scap_listxccdfscans(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_scap_listxccdfscans()
        return

    # use the systems listed in the SSM
    if re.match('ssm', args[0], re.I):
        systems = self.ssm.keys()
    else:
        systems = self.expand_systems(args)

    add_separator = False

    for system in sorted(systems):
        if add_separator:
            print(self.SEPARATOR)
        add_separator = True

        if len(systems) > 1:
            print('System: %s' % system)
            print('')

        system_id = self.get_system_id(system)
        if not system_id:
            continue

        scan_list = self.client.system.scap.listXccdfScans(self.session, system_id)

        for s in scan_list:
            print('XID: %d Profile: %s Path: (%s) Completed: %s' % (s['xid'], s['profile'], s['path'], s['completed']))

####################


def help_scap_getxccdfscanruleresults(self):
    print('scap_getxccdfscanruleresults: Return a full list of RuleResults for given OpenSCAP XCCDF scan')
    print('usage: scap_getxccdfscanruleresults <XID>')


def do_scap_getxccdfscanruleresults(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_scap_getxccdfscanruleresults()
        return

    add_separator = False

    for xid in args:
        if add_separator:
            print(self.SEPARATOR)
        add_separator = True

        if len(args) > 1:
            print('XID: %s' % xid)
            print('')

        xid = int(xid)
        scan_results = self.client.system.scap.getXccdfScanRuleResults(self.session, xid)

        for s in scan_results:
            print('IDref: %s Result: %s Idents: (%s)' % (s['idref'], s['result'], s['idents']))

####################


def help_scap_getxccdfscandetails(self):
    print('scap_getxccdfscandetails: Get details of given OpenSCAP XCCDF scan')
    print('usage: scap_getxccdfscandetails <XID>')


def do_scap_getxccdfscandetails(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_scap_getxccdfscandetails()
        return

    add_separator = False

    for xid in args:
        if add_separator:
            print(self.SEPARATOR)
        add_separator = True

        if len(args) > 1:
            print('XID: %s' % xid)
            print('')

        xid = int(xid)
        scan_details = self.client.system.scap.getXccdfScanDetails(self.session, xid)

        print("XID:", scan_details['xid'], "SID:", scan_details['sid'], "Action_ID:",
              scan_details['action_id'], "Path:", scan_details['path'], \
              "OSCAP_Parameters:", scan_details['oscap_parameters'], \
              "Test_Result:", scan_details['test_result'], "Benchmark:", \
              scan_details['benchmark'], "Benchmark_Version:", \
              scan_details['benchmark_version'], "Profile:", scan_details['profile'], \
              "Profile_Title:", scan_details['profile_title'], "Start_Time:", \
              scan_details['start_time'], "End_Time:", scan_details['end_time'], \
              "Errors:", scan_details['errors'])

####################


def help_scap_schedulexccdfscan(self):
    print('scap_schedulexccdfscan: Schedule Scap XCCDF scan')
    print('usage: scap_schedulexccdfscan PATH_TO_XCCDF_FILE XCCDF_OPTIONS SYSTEMS')
    print('')
    print('Example:')
    print('> scap_schedulexccdfscan \'/usr/share/openscap/scap-security-xccdf.xml\'' +
          ' \'profile Web-Default\' system-scap.example.com')


def do_scap_schedulexccdfscan(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if len(args) < 3:
        self.help_scap_schedulexccdfscan()
        return

    path = args[0]
    param = "--"
    param += args[1]

    # use the systems listed in the SSM
    if re.match('ssm', args[0], re.I):
        systems = self.ssm.keys()
    else:
        systems = self.expand_systems(args[2:])

    for system in systems:
        system_id = self.get_system_id(system)
        if not system_id:
            continue

        self.client.system.scap.scheduleXccdfScan(self.session, system_id, path, param)
