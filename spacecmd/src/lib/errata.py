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

from operator import itemgetter
try:
    from xmlrpc import client as xmlrpclib
except ImportError:
    import xmlrpclib

from spacecmd.utils import *


def help_errata_list(self):
    print('errata_list: List all errata')
    print('usage: errata_list')


def do_errata_list(self, args, doreturn=False):
    self.generate_errata_cache()

    if doreturn:
        return self.all_errata.keys()
    else:
        if self.all_errata.keys():
            print('\n'.join(sorted(self.all_errata.keys())))

####################


def help_errata_summary(self):
    print('errata_summary: Print a summary of all errata')
    print('usage: errata_summary')


def do_errata_summary(self, args):
    self.generate_errata_cache()

    map(print_errata_summary, sorted(self.all_errata.values(),
                                     key=itemgetter('advisory_name')))

####################


def help_errata_apply(self):
    print('errata_apply: Apply an erratum to all affected systems')
    print('''usage: errata_apply [options] ERRATA|search:XXX ...)

options:
  -s START_TIME''')
    print('')
    print(self.HELP_TIME_OPTS)


def complete_errata_apply(self, text, line, beg, end):
    return self.tab_complete_errata(text)


def do_errata_apply(self, args, only_systems=None):
    arg_parser = get_argument_parser()
    arg_parser.add_argument('-s', '--start-time')

    (args, options) = parse_command_arguments(args, arg_parser)
    only_systems = only_systems or []

    if not args:
        self.help_errata_apply()
        return

    # get the start time option
    # skip the prompt if we are running with --yes
    # use "now" if no start time was given
    if is_interactive(options) and self.options.yes != True:
        options.start_time = prompt_user('Start Time [now]:')
        options.start_time = parse_time_input(options.start_time)
    else:
        if not options.start_time:
            options.start_time = parse_time_input('now')
        else:
            options.start_time = parse_time_input(options.start_time)

    # allow globbing and searching via arguments
    errata_list = self.expand_errata(args)

    systems = []
    summary = []
    to_apply_by_name = {}
    for erratum in errata_list:
        try:
            # get the systems affected by each errata
            affected_systems = \
                self.client.errata.listAffectedSystems(self.session, erratum)

            # build a list of systems that we will schedule errata for,
            # indexed by errata name
            for system in affected_systems:
                # add this system to the list of systems affected by
                # this erratum if we were not passed a list of systems
                # (and therefore all systems are to be touched) or we were
                # passed a list of systems and this one is part of that list
                if not only_systems or system.get('name') in only_systems:
                    if erratum not in to_apply_by_name:
                        to_apply_by_name[erratum] = []
                    if system.get('name') not in to_apply_by_name[erratum]:
                        to_apply_by_name[erratum].append(system.get('name'))
        except xmlrpclib.Fault:
            logging.debug('%s does not affect any systems' % erratum)
            continue

        # make a summary list to show the user
        if erratum in to_apply_by_name:
            summary.append('%s        %s' % (erratum.ljust(15),
                                             str(len(to_apply_by_name[erratum])).rjust(3)))
        else:
            logging.debug('%s does not affect any systems' % erratum)

    # get a unique list of all systems we need to touch
    for systemlist in to_apply_by_name.values():
        systems += systemlist
    systems = list(set(systems))

    if not systems:
        logging.warning('No errata to apply')
        return

    # a summary of which errata we're going to apply
    print('Errata             Systems')
    print('--------------     -------')
    print('\n'.join(sorted(summary)))
    print('')
    print('Start Time: %s' % options.start_time)

    if not self.user_confirm('Apply these errata [y/N]:'):
        return

    # if the API supports it, try to schedule multiple systems for one erratum
    # in order to reduce the number of actions scheduled
    if self.check_api_version('10.11'):
        to_apply = {}

        for system in systems:
            system_id = self.get_system_id(system)

            # only attempt to schedule unscheduled errata
            system_errata = self.client.system.getUnscheduledErrata(self.session,
                                                                    system_id)

            # make a list of systems for each erratum
            for erratum in system_errata:
                erratum_id = erratum.get('id')

                if erratum.get('advisory_name') in errata_list:
                    if erratum_id not in to_apply:
                        to_apply[erratum_id] = []

                    to_apply[erratum_id].append(system_id)

        # apply the errata
        for erratum in to_apply:
            self.client.system.scheduleApplyErrata(self.session,
                                                   to_apply[erratum],
                                                   [erratum],
                                                   options.start_time)

            logging.info('Scheduled %i system(s) for %s' %
                         (len(to_apply[erratum]),
                          self.get_erratum_name(erratum)))
    else:
        for system in systems:
            system_id = self.get_system_id(system)

            # only schedule unscheduled errata
            system_errata = self.client.system.getUnscheduledErrata(self.session,
                                                                    system_id)

            # if an errata specified for installation is unscheduled for
            # this system, add it to the list to schedule
            errata_to_apply = []
            for erratum in errata_list:
                for e in system_errata:
                    if erratum == e.get('advisory_name'):
                        errata_to_apply.append(e.get('id'))
                        break

            if not errata_to_apply:
                logging.warning('No errata to schedule for %s' % system)
                continue

            # this results in one action per erratum for each server
            self.client.system.scheduleApplyErrata(self.session,
                                                   system_id,
                                                   errata_to_apply,
                                                   options.start_time)

            logging.info('Scheduled %i errata for %s' %
                         (len(errata_to_apply), system))

####################


def help_errata_listaffectedsystems(self):
    print('errata_listaffectedsystems: List of systems affected by an erratum')
    print('usage: errata_listaffectedsystems ERRATA|search:XXX ...')


def complete_errata_listaffectedsystems(self, text, line, beg, end):
    return self.tab_complete_errata(text)


def do_errata_listaffectedsystems(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_errata_listaffectedsystems()
        return

    # allow globbing and searching via arguments
    errata_list = self.expand_errata(args)

    add_separator = False

    for erratum in errata_list:
        systems = self.client.errata.listAffectedSystems(self.session, erratum)

        if systems:
            if add_separator:
                print(self.SEPARATOR)
            add_separator = True

            print('%s:' % erratum)
            print('\n'.join(sorted([s.get('name') for s in systems])))

####################


def help_errata_listcves(self):
    print('errata_listcves: List of CVEs addressed by an erratum')
    print('usage: errata_listcves ERRATA|search:XXX ...')


def complete_errata_listcves(self, text, line, beg, end):
    return self.tab_complete_errata(text)


def do_errata_listcves(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_errata_listcves()
        return

    # allow globbing and searching via arguments
    errata_list = self.expand_errata(args)

    add_separator = False

    for erratum in errata_list:
        cves = self.client.errata.listCves(self.session, erratum)

        if cves:
            if len(errata_list) > 1:
                if add_separator:
                    print(self.SEPARATOR)
                add_separator = True

                print('%s:' % erratum)

            print('\n'.join(sorted(cves)))

####################


def help_errata_findbycve(self):
    print('errata_findbycve: List errata addressing a CVE')
    print('usage: errata_findbycve CVE-YYYY-NNNN ...')


def complete_errata_findbycve(self, text, line, beg, end):
    return self.tab_complete_errata(text)


def do_errata_findbycve(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_errata_findbycve()
        return

    # More than one CVE may be specified
    cve_list = args
    logging.debug("Got CVE list %s" % cve_list)

    add_separator = False

    # Then iterate over the requested CVEs and dump the errata which match
    for c in cve_list:
        if add_separator:
            print(self.SEPARATOR)
        add_separator = True

        print("%s:" % c)
        errata = self.client.errata.findByCve(self.session, c)
        if errata:
            for e in errata:
                print("%s" % e.get('advisory_name'))

####################


def help_errata_details(self):
    print('errata_details: Show the details of an erratum')
    print('usage: errata_details ERRATA|search:XXX ...')


def complete_errata_details(self, text, line, beg, end):
    return self.tab_complete_errata(text)


def do_errata_details(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_errata_details()
        return

    # allow globbing and searching via arguments
    errata_list = self.expand_errata(args)

    add_separator = False

    for erratum in errata_list:
        try:
            details = self.client.errata.getDetails(self.session, erratum)

            packages = self.client.errata.listPackages(self.session, erratum)

            systems = self.client.errata.listAffectedSystems(self.session,
                                                             erratum)

            cves = self.client.errata.listCves(self.session, erratum)

            channels = \
                self.client.errata.applicableToChannels(self.session, erratum)
        except xmlrpclib.Fault:
            logging.warning('%s is not a valid erratum' % erratum)
            continue

        if add_separator:
            print(self.SEPARATOR)
        add_separator = True

        print('Name:       %s' % erratum)
        print('Product:    %s' % details.get('product'))
        print('Type:       %s' % details.get('type'))
        print('Issue Date: %s' % details.get('issue_date'))
        print('')
        print('Topic')
        print('-----')
        print('\n'.join(wrap(details.get('topic'))))
        print('')
        print('Description')
        print('-----------')
        print('\n'.join(wrap(details.get('description'))))

        if details.get('notes'):
            print('')
            print('Notes')
            print('-----')
            print('\n'.join(wrap(details.get('notes'))))

        print('')
        print('CVEs')
        print('----')
        print('\n'.join(sorted(cves)))
        print('')
        print('Solution')
        print('--------')
        print('\n'.join(wrap(details.get('solution'))))
        print('')
        print('References')
        print('----------')
        print('\n'.join(wrap(details.get('references'))))
        print('')
        print('Affected Channels')
        print('-----------------')
        print('\n'.join(sorted([c.get('label') for c in channels])))
        print('')
        print('Affected Systems')
        print('----------------')
        print(str(len(systems)))
        print('')
        print('Affected Packages')
        print('-----------------')
        print('\n'.join(sorted(build_package_names(packages))))

####################


def help_errata_delete(self):
    print('errata_delete: Delete an erratum')
    print('usage: errata_delete ERRATA|search:XXX ...')


def complete_errata_delete(self, text, line, beg, end):
    return self.tab_complete_errata(text)


def do_errata_delete(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_errata_delete()
        return

    # allow globbing and searching via arguments
    errata = self.expand_errata(args)

    if not errata:
        logging.warning('No errata to delete')
        return

    print('Erratum            Channels')
    print('-------            --------')

    # tell the user how many channels each erratum affects
    for erratum in sorted(errata):
        channels = self.client.errata.applicableToChannels(self.session, erratum)
        print('%s    %s' % (erratum.ljust(20), str(len(channels)).rjust(3)))

    if not self.user_confirm('Delete these errata [y/N]:'):
        return

    for erratum in errata:
        self.client.errata.delete(self.session, erratum)

    logging.info('Deleted %i errata' % len(errata))

    self.generate_errata_cache(True)

####################


def help_errata_publish(self):
    print('errata_publish: Publish an erratum to a channel')
    print('usage: errata_publish ERRATA|search:XXX <CHANNEL ...>')


def complete_errata_publish(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return self.tab_complete_errata(text)
    elif len(parts) > 2:
        return tab_completer(self.do_softwarechannel_list('', True), text)


def do_errata_publish(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if len(args) < 2:
        self.help_errata_publish()
        return

    # allow globbing and searching via arguments
    errata = self.expand_errata(args[0])

    channels = args[1:]

    if not errata:
        logging.warning('No errata to publish')
        return

    print('\n'.join(sorted(errata)))

    if not self.user_confirm('Publish these errata [y/N]:'):
        return

    for erratum in errata:
        self.client.errata.publish(self.session, erratum, channels)

####################


def help_errata_search(self):
    print('errata_search: List errata that meet the given criteria')
    print('usage: errata_search CVE|RHSA|RHBA|RHEA|CLA ...')
    print('')
    print('Example:')
    print('> errata_search CVE-2009:1674')
    print('> errata_search RHSA-2009:1674')


def complete_errata_search(self, text, line, beg, end):
    return tab_completer(self.do_errata_list('', True), text)


def do_errata_search(self, args, doreturn=False):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_errata_search()
        return

    add_separator = False

    for query in args:
        errata = []

        if re.match('CVE', query, re.I):
            errata = self.client.errata.findByCve(self.session,
                                                  query.upper())
        else:
            self.generate_errata_cache()

            for name in self.all_errata.keys():
                if re.search(query, name, re.I) or \
                   re.search(query, self.all_errata[name]['advisory_synopsis'],
                             re.I):

                    match = self.all_errata[name]

                    # build a structure to pass to print_errata_summary()
                    errata.append({'advisory_name': name,
                                   'advisory_type': match['advisory_type'],
                                   'advisory_synopsis': match['advisory_synopsis'],
                                   'date': match['date']})

        if add_separator:
            print(self.SEPARATOR)
        add_separator = True

        if errata:
            if doreturn:
                return [erratum['advisory_name'] for erratum in errata]
            else:
                map(print_errata_summary, sorted(errata, reverse=True))
        else:
            return []
