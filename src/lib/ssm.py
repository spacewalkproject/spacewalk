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

from spacecmd.utils import *

def help_ssm(self):
    print 'The System Set Manager (SSM) is a group of systems that you '
    print 'can perform tasks on as a group.'
    print
    print 'Adding Systems:'
    print '> ssm_add group:rhel5-x86_64'
    print '> ssm_add channel:rhel-x86_64-server-5'
    print '> ssm_add search:device:vmware'
    print '> ssm_add host.example.com'
    print
    print 'Intersections:'
    print '> ssm_add group:rhel5-x86_64'
    print '> ssm_intersect group:web-servers'
    print
    print 'Using the SSM:'
    print '> system_installpackage ssm zsh'
    print '> system_runscript ssm'

####################

def help_ssm_add(self):
    print 'ssm_add: Add systems to the SSM'
    print 'usage: ssm_add <SYSTEMS>'
    print
    print "see 'help ssm' for more details"
    print
    print self.HELP_SYSTEM_OPTS

def complete_ssm_add(self, text, line, beg, end):
    return self.tab_complete_systems(text)

def do_ssm_add(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_ssm_add()
        return

    systems = self.expand_systems(args)

    if not len(systems):
        logging.warning('No systems found')
        return

    for system in systems:
        if system in self.ssm:
            logging.warning('%s is already in the list' % system)
            continue
        else:
            self.ssm[system] = self.get_system_id(system)
            logging.debug('Added %s' % system)

    if len(self.ssm):
        logging.info('Systems Selected: %i' % len(self.ssm))
    
    # save the SSM for use between sessions
    save_cache(self.ssm_cache_file, self.ssm)

####################

def help_ssm_intersect(self):
    print 'ssm_intersect: Replace the current SSM with the intersection'
    print '               of the current list of systems and the list of'
    print '               systems passed as arguments'
    print 'usage: ssm_intersect <SYSTEMS>'
    print
    print "see 'help ssm' for more details"
    print
    print self.HELP_SYSTEM_OPTS

def complete_ssm_intersect(self, text, line, beg, end):
    return self.tab_complete_systems(text)

def do_ssm_intersect(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_ssm_intersect()
        return

    systems = self.expand_systems(args)

    if not len(systems):
        logging.warning('No systems found')
        return

    # tmp_ssm placeholder to gather systems that are both in original ssm
    # selection and newly selected group
    tmp_ssm = []
    for system in systems:
        if system in self.ssm:
            logging.debug('%s is in both groups: leaving in SSM' % system)
            tmp_ssm.append(system)

    # set self.ssm to tmp_ssm, which now holds the intersection
    self.ssm = tmp_ssm

    if len(self.ssm):
        logging.info('Systems Selected: %i' % len(self.ssm))

####################

def help_ssm_remove(self):
    print 'ssm_remove: Remove systems from the SSM'
    print 'usage: ssm_remove <SYSTEMS>'
    print
    print "see 'help ssm' for more details"
    print
    print self.HELP_SYSTEM_OPTS

def complete_ssm_remove(self, text, line, beg, end):
    return self.tab_complete_systems(text)

def do_ssm_remove(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_ssm_remove()
        return

    systems = self.expand_systems(args)

    if not len(systems):
        logging.warning('No systems found')
        return

    for system in systems:
        # double-check for existance in case of duplicate names
        if system in self.ssm:
            logging.debug('Removed %s' % system)
            del self.ssm[system]

    logging.info('Systems Selected: %i' % len(self.ssm))

    # save the SSM for use between sessions
    save_cache(self.ssm_cache_file, self.ssm)

####################

def help_ssm_list(self):
    print 'ssm_list: List the systems currently in the SSM'
    print 'usage: ssm_list'
    print
    print "see 'help ssm' for more details"

def do_ssm_list(self, args):
    systems = sorted(self.ssm)

    if len(systems):
        print '\n'.join(systems)
        logging.info('Systems Selected: %i' % len(systems))

####################

def help_ssm_clear(self):
    print 'ssm_clear: Remove all systems from the SSM'
    print 'usage: ssm_clear'

def do_ssm_clear(self, args):
    self.ssm = {}

    # save the SSM for use between sessions
    save_cache(self.ssm_cache_file, self.ssm)

# vim:ts=4:expandtab:
