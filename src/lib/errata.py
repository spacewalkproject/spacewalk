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

    summary = []
    errata_to_apply = {}
    for errata in sorted(errata_list, reverse = True):
        try:
            errata_to_apply[errata] = \
                self.client.errata.listAffectedSystems(self.session, errata)
        except:
            logging.debug('%s does not affect any systems' % errata)
            continue
       
        if len(errata_to_apply[errata]):
            summary.append('%s        %s' % (errata.ljust(15), 
                           str(len(errata_to_apply[errata])).rjust(3)))
        else:
            logging.debug('%s does not affect any systems' % errata)
            del errata_to_apply[errata]
       
    if not len(errata_to_apply): 
        logging.warning('No errata to apply')
        return
    
    # a summary of which errata we're going to apply
    print 'Errata             Systems'
    print '--------------     -------'
    print '\n'.join(sorted(summary))

    if not self.user_confirm('Apply these errata [y/N]:'): return

    for errata in errata_to_apply.keys(): 
        # XXX: bugzilla 600691
        # there is not an API call to get the ID of an errata
        # based on the name, so we do it in a round-about way
        system_id = errata_to_apply[errata][0].get('id')
        system_errata = self.client.system.getRelevantErrata(self.session, 
                                                             system_id)

        pattern = re.compile(errata, re.I)
        for e in system_errata:
            if pattern.match(e.get('advisory_name')):
                errata_id = e.get('id')
                break

        if not errata_id:
            logging.error("Couldn't find ID for %s" % errata)
            return

        # schedule each errata individually for a system so that if 
        # one fails, they all don't fail
        for system in errata_to_apply[errata]:
            logging.debug('Applying %s to %s' % (errata, system.get('name')))

            try:
                self.client.system.scheduleApplyErrata(self.session,
                                                       system.get('id'),
                                                       [ errata_id ])
            except xmlrpclib.Fault:
                logging.warning('Failed to schedule %s for %s' % \
                                (errata, system.get('name')))
 
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
        print 'Product:    %s' % details.get('product')
        print 'Type:       %s' % details.get('type')
        print 'Issue Date: %s' % details.get('issue_date')
        print
        print 'Topic'
        print '-----'
        print '\n'.join(wrap(details.get('topic')))
        print
        print 'Description'
        print '-----------'
        print '\n'.join(wrap(details.get('description')))

        if details.get('notes'):
            print
            print 'Notes'
            print '-----'
            print '\n'.join(wrap(details.get('notes')))

        print
        print 'Solution'
        print '--------'
        print '\n'.join(wrap(details.get('solution')))
        print
        print 'References'
        print '----------'
        print '\n'.join(wrap(details.get('references')))
        print
        print 'Affected Channels'
        print '-----------------'
        print '\n'.join(sorted([c.get('label') for c in channels]))
        print
        print 'Affected Systems'
        print '----------------'
        print str(len(systems))
        print
        print 'Affected Packages'
        print '-----------------'
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
                   re.search(query, self.all_errata[name]['synopsis'], re.I):

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
