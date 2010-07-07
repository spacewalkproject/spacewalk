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
# Copyright 2010 Aron Parsons <aron@redhat.com>
#

# NOTE: the 'self' variable is an instance of SpacewalkShell

import xmlrpclib
from spacecmd.utils import *

def help_errata_list(self):
    print 'errata_list: List all errata' 
    print 'usage: errata_list'

def do_errata_list(self, args, doreturn=False):
    self.generate_errata_cache()

    if doreturn:
        return self.all_errata.keys()
    else:
        if len(self.all_errata.keys()):
            print '\n'.join(sorted(self.all_errata.keys()))

####################

def help_errata_apply(self):
    print 'errata_apply: Apply an errata to all affected systems' 
    print 'usage: errata_apply ERRATA|search:XXX ...'

def complete_errata_apply(self, text, line, beg, end):
    return self.tab_complete_errata(text)

def do_errata_apply(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_errata_apply()
        return

    # allow globbing and searching via arguments
    errata_list = self.expand_errata(args)

    add_separator = False

    errata_to_remove = []    
    for errata in sorted(errata_list, reverse = True):
        try:
            systems = self.client.errata.listAffectedSystems(self.session, 
                                                             errata)
        except:
            systems = []
        
        if len(systems):
            if add_separator: print self.SEPARATOR
            add_separator = True

            # print the list of systems
            print '%s:' % errata
            for system in sorted([s.get('name') for s in systems]):
                print system
        else:
            logging.warning('%s does not affect any systems' % errata)
            errata_to_remove.append(errata)

    # remove errata that didn't have any affected systems
    for errata in errata_to_remove:
        errata_list.remove(errata)
       
    if len(errata_list): 
        if not self.user_confirm('Apply these errata [y/N]:'): return
    else:
        logging.warning('No errata to apply')
        return

    for errata in errata_list: 
        systems = self.client.errata.listAffectedSystems(self.session, 
                                                         errata)
        
        # XXX: bugzilla 600691
        # there is not an API call to get the ID of an errata
        # based on the name, so we do it in a round-about way
        for system in systems:
            system_id = system.get('id')
            avail = self.client.system.getRelevantErrata(self.session, 
                                                         system_id)

            for e in avail:
                if re.match(errata, e.get('advisory_name'), re.I):
                    errata_id = e.get('id')
                    break

            if errata_id: break

        if not errata_id:
            logging.error("Couldn't find ID for %s" % errata)
            return

        for system in systems:
            try:
                self.client.system.scheduleApplyErrata(self.session,
                                                       system.get('id'),
                                                       [errata_id])
            except xmlrpclib.Fault:
                logging.warning('Failed to schedule %s' % system.get('name'))
 
####################

def help_errata_listaffectedsystems(self):
    print 'errata_listaffectedsystems: List of systems affected by an ' + \
          'errata'
    print 'usage: errata_listaffectedsystems ERRATA|search:XXX ...'

def complete_errata_listaffectedsystems(self, text, line, beg, end):
    return self.tab_complete_errata(text)

def do_errata_listaffectedsystems(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_errata_listaffectedsystems()
        return

    # allow globbing and searching via arguments
    errata_list = self.expand_errata(args)

    add_separator = False

    for errata in errata_list:
        systems = self.client.errata.listAffectedSystems(self.session, 
                                                         errata)

        if len(systems):
            if add_separator: print self.SEPARATOR
            add_separator = True

            print '%s:' % errata
            print '\n'.join(sorted([ s.get('name') for s in systems ]))
    
####################

def help_errata_details(self):
    print 'errata_details: Show the details of an errata'
    print 'usage: errata_details ERRATA|search:XXX ...'

def complete_errata_details(self, text, line, beg, end):
    return self.tab_complete_errata(text)

def do_errata_details(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_errata_details()
        return

    # allow globbing and searching via arguments
    errata_list = self.expand_errata(args)

    add_separator = False

    for errata in errata_list:
        try:
            details = self.client.errata.getDetails(self.session, errata)

            packages = self.client.errata.listPackages(self.session, errata)

            systems = self.client.errata.listAffectedSystems(self.session, 
                                                             errata)

            channels = \
                self.client.errata.applicableToChannels(self.session, 
                                                        errata)
        except:
            logging.warning('%s is not a valid errata' % errata)
            continue

        if add_separator: print self.SEPARATOR
        add_separator = True

        print 'Name:       %s' % errata
        print
        print 'Product:    %s' % details.get('product')
        print 'Type:       %s' % details.get('type')
        print 'Issue Date: %s' % details.get('issue_date')
        print
        print 'Topic: '
        print '\n'.join(wrap(details.get('topic')))
        print
        print 'Description: '
        print '\n'.join(wrap(details.get('description')))

        if details.get('notes'):
            print
            print 'Notes:'
            print '\n'.join(wrap(details.get('notes')))

        print
        print 'Solution:'
        print '\n'.join(wrap(details.get('solution')))
        print
        print 'References:'
        print '\n'.join(wrap(details.get('references')))
        print
        print 'Affected Channels:'
        print '\n'.join(sorted([c.get('label') for c in channels]))
        print
        print 'Affected Systems:'
        print '%i' % len(systems)
        print
        print 'Affected Packages:'
        print '\n'.join(sorted(build_package_names(packages)))


####################

def help_errata_search(self):
    print 'errata_search: List errata that meet the given criteria'
    print 'usage: errata_search CVE|RHSA|RHBA|RHEA|CLA ...'
    print
    print 'Example:'
    print '> errata_search CVE-2009:1674'
    print '> errata_search RHSA-2009:1674'

def complete_errata_search(self, text, line, beg, end):
    return tab_completer(self.do_errata_list('', True), text)

def do_errata_search(self, args, doreturn=False):
    args = parse_arguments(args)

    if not len(args):
        self.help_errata_search()
        return

    add_separator = False

    for query in args:
        errata = []

        #XXX: Bugzilla 584855
        if re.match('CVE', query, re.I):
            errata = self.client.errata.findByCve(self.session, 
                                                  query.upper())
        else:
            self.generate_errata_cache()

            for name in self.all_errata.keys():
                if re.search(query, name, re.I) or \
                   re.search(query, 
                             self.all_errata[name]['synopsis'], re.I):
                    match = self.all_errata[name]

                    # build a structure to pass to print_errata_summary()
                    errata.append( {'advisory_name'     : name,
                                    'advisory_type'     : match['type'],
                                    'advisory_synopsis' : match['synopsis'],
                                    'date'              : match['date'] } )

        if add_separator: print self.SEPARATOR
        add_separator = True

        if len(errata):
            if doreturn:
                return [ e['advisory_name'] for e in errata ]
            else:
                map(print_errata_summary, sorted(errata, reverse=True))
        else:
            return []

# vim:ts=4:expandtab:
