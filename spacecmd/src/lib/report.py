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
#

# NOTE: the 'self' variable is an instance of SpacewalkShell

# wildcard import
# pylint: disable=W0401,W0614

# unused argument
# pylint: disable=W0613

# invalid function name
# pylint: disable=C0103

from operator import itemgetter
from spacecmd.utils import *


def help_report_inactivesystems(self):
    print 'report_inactivesystems: List all inactive systems'
    print 'usage: report_inactivesystems [DAYS]'


def do_report_inactivesystems(self, args):
    (args, _options) = parse_arguments(args)

    # allow the user to set a limit on the number of days
    if len(args) == 1:
        try:
            days = int(args[0])
        except ValueError:
            # default to a week when passed a bad argument
            days = 7

        systems = self.client.system.listInactiveSystems(self.session, days)
    else:
        # use the server's default period if no argument was passed
        systems = self.client.system.listInactiveSystems(self.session)

    if len(systems):
        max_size = max_length([s.get('name') for s in systems])

        print '%s  %s' % ('System'.ljust(max_size), 'Last Checkin')
        print ('-' * max_size) + '  ------------'

        for s in sorted(systems, key=itemgetter('name')):
            print '%s  %s' % (s.get('name').ljust(max_size),
                              s.get('last_checkin'))

####################


def help_report_outofdatesystems(self):
    print 'report_outofdatesystems: List all out-of-date systems'
    print 'usage: report_outofdatesystems'


def do_report_outofdatesystems(self, args):
    systems = self.client.system.listOutOfDateSystems(self.session)

    max_size = max_length([s.get('name') for s in systems])

    report = {}
    for system in systems:
        system_id = system.get('id')

        packages = \
            self.client.system.listLatestUpgradablePackages(self.session,
                                                            system_id)

        report[system.get('name')] = len(packages)

    if len(report):
        print '%s  %s' % ('System'.ljust(max_size), 'Packages')
        print ('-' * max_size) + '  --------'

        for system in sorted(report):
            print '%s       %s' % \
                  (system.ljust(max_size), str(report[system]).rjust(3))

####################


def help_report_ungroupedsystems(self):
    print 'report_ungroupedsystems: List all ungrouped systems'
    print 'usage: report_ungroupedsystems'


def do_report_ungroupedsystems(self, args):
    systems = self.client.system.listUngroupedSystems(self.session)
    systems = [s.get('name') for s in systems]

    if len(systems):
        print '\n'.join(sorted(systems))

####################


def help_report_errata(self):
    print 'report_errata: List all errata and how many systems they affect'
    print 'usage: report_errata [ERRATA|search:XXX ...]'

# XXX: performance is terrible due to all the API calls


def do_report_errata(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) == 0:
        print 'All errata requested - this may take a few minutes, please be patient!'

    errata_list = self.expand_errata(args)

    report = {}
    for erratum in errata_list:
        logging.debug('Getting affected systems for %s' % erratum)

        affected = self.client.errata.listAffectedSystems(self.session, erratum)

        num_affected = len(affected)
        if num_affected:
            report[erratum] = num_affected

    # XXX: max(list, key=len) in >2.5
    max_size = 0
    for e in report.keys():
        size = len(e)
        if size > max_size:
            max_size = size

    if len(report):
        print '%s  # Systems' % ('Errata'.ljust(max_size))
        print '%s  ---------' % ('------'.ljust(max_size))
        for erratum in sorted(report):
            print '%s        %s' % \
                  (erratum.ljust(max_size), str(report[erratum]).rjust(3))

####################


def help_report_ipaddresses(self):
    print 'report_network: List the hostname and IP of each system'
    print 'usage: report_network [<SYSTEMS>]'
    print
    print self.HELP_SYSTEM_OPTS


def do_report_ipaddresses(self, args):
    (args, _options) = parse_arguments(args)

    if len(args):
        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)
    else:
        systems = self.get_system_names()

    report = {}
    for system in systems:
        system_id = self.get_system_id(system)
        network = self.client.system.getNetwork(self.session, system_id)
        report[system] = {'hostname': network.get('hostname'),
                          'ip': network.get('ip')}

    # XXX: max(list, key=len) in >2.5
    system_max_size = 0
    for s in report.keys():
        size = len(s)
        if size > system_max_size:
            system_max_size = size

    hostname_max_size = 0
    for h in [report[h]['hostname'] for h in report]:
        size = len(h)
        if size > hostname_max_size:
            hostname_max_size = size

    if len(report):
        print '%s  %s  IP' % ('System'.ljust(system_max_size),
                              'Hostname'.ljust(hostname_max_size))

        print '%s  %s  --' % ('------'.ljust(system_max_size),
                              '--------'.ljust(hostname_max_size))

        for system in sorted(report):
            print '%s  %s  %s' % \
                (system.ljust(system_max_size),
                 report[system]['hostname'].ljust(hostname_max_size),
                 report[system]['ip'].ljust(15))

####################


def help_report_kernels(self):
    print 'report_network: List the running kernel of each system'
    print 'usage: report_network [<SYSTEMS>]'
    print
    print self.HELP_SYSTEM_OPTS


def do_report_kernels(self, args):
    (args, _options) = parse_arguments(args)

    if len(args):
        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)
    else:
        systems = self.get_system_names()

    report = {}
    for system in systems:
        system_id = self.get_system_id(system)
        kernel = self.client.system.getRunningKernel(self.session, system_id)
        report[system] = kernel

    # XXX: max(list, key=len) in >2.5
    system_max_size = 0
    for s in report.keys():
        size = len(s)
        if size > system_max_size:
            system_max_size = size

    if len(report):
        print '%s  Kernel' % ('System'.ljust(system_max_size))

        print '%s  ------' % ('------'.ljust(system_max_size))

        for system in sorted(report):
            print '%s  %s' % (system.ljust(system_max_size), report[system])

####################


def help_report_duplicates(self):
    print 'report_duplicates: List duplicate system profiles'
    print 'usage: report_duplicates'


def do_report_duplicates(self, args):
    add_separator = False

    dupes_by_profile = []
    for system in self.get_system_names():
        if self.get_system_names().count(system) > 1:
            if system not in dupes_by_profile:
                dupes_by_profile.append(system)

    if len(dupes_by_profile):
        add_separator = True

        for item in dupes_by_profile:
            print '%s:' % item

            # get some details for each duplicate
            systems = self.client.system.searchByName(self.session,
                                                      '^%s$' % item)

            print 'System ID   Last Checkin'
            print '----------  -----------------'

            for dupe in systems:
                print '%i  %s' % (dupe.get('id'), dupe.get('last_checkin'))

            if len(dupes_by_profile) > 1:
                print

    if self.check_api_version('10.11'):
        dupes_by_ip = self.client.system.listDuplicatesByIp(self.session)
        dupes_by_mac = self.client.system.listDuplicatesByMac(self.session)
        dupes_by_hostname = \
            self.client.system.listDuplicatesByHostname(self.session)

        if len(dupes_by_ip):
            if add_separator:
                print self.SEPARATOR
            add_separator = True

            for item in dupes_by_ip:
                print '%s:' % item.get('ip')

                print 'System ID   Last Checkin'
                print '----------  -----------------'

                for dupe in item.get('systems'):
                    print '%i  %s' % (dupe.get('systemId'),
                                      dupe.get('last_checkin'))

                if len(dupes_by_ip) > 1:
                    print

        if len(dupes_by_mac):
            if add_separator:
                print self.SEPARATOR
            add_separator = True

            for item in dupes_by_mac:
                print '%s:' % item.get('mac').upper()

                print 'System ID   Last Checkin'
                print '----------  -----------------'

                for dupe in item.get('systems'):
                    print '%i  %s' % (dupe.get('systemId'),
                                      dupe.get('last_checkin'))

                if len(dupes_by_mac) > 1:
                    print

        if len(dupes_by_hostname):
            if add_separator:
                print self.SEPARATOR
            add_separator = True

            for item in dupes_by_hostname:
                print '%s:' % item.get('hostname')

                print 'System ID   Last Checkin'
                print '----------  -----------------'

                for dupe in item.get('systems'):
                    print '%i  %s' % (dupe.get('systemId'),
                                      dupe.get('last_checkin'))

                if len(dupes_by_hostname) > 1:
                    print
