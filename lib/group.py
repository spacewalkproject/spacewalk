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

from spacecmd.utils import *

def help_group_addsystems(self):
    print 'group_addsystems: Add systems to a group'
    print 'usage: group_addsystems GROUP <SYSTEMS>'
    print
    print self.HELP_SYSTEM_OPTS

def complete_group_addsystems(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_group_list('', True), text)
    elif len(parts) > 2:
        return self.tab_complete_systems(parts[1])

def do_group_addsystems(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_group_addsystems()
        return

    group_name = args.pop(0)

    # use the systems listed in the SSM
    if re.match('ssm', args[0], re.I):
        systems = self.ssm.keys()
    else:
        systems = self.expand_systems(args)

    system_ids = []
    for system in sorted(systems):
        system_id = self.get_system_id(system)
        if not system_id: return
        system_ids.append(system_id)

    self.client.systemgroup.addOrRemoveSystems(self.session,
                                               group_name,
                                               system_ids,
                                               True)

####################

def help_group_removesystems(self):
    print 'group_removesystems: Remove systems from a group'
    print 'usage: group_removesystems GROUP <SYSTEMS>'
    print
    print self.HELP_SYSTEM_OPTS

def complete_group_removesystems(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_group_list('', True), text)
    elif len(parts) > 2:
        return self.tab_complete_systems(parts[1])

def do_group_removesystems(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_group_removesystems()
        return

    group_name = args.pop(0)

    # use the systems listed in the SSM
    if re.match('ssm', args[0], re.I):
        systems = self.ssm.keys()
    else:
        systems = self.expand_systems(args)

    system_ids = []
    for system in sorted(systems):
        system_id = self.get_system_id(system)
        if not system_id: return
        system_ids.append(system_id)

    print 'Systems:'
    print '\n'.join(sorted(systems))

    if not self.user_confirm('Remove these systems [y/N]:'): return

    self.client.systemgroup.addOrRemoveSystems(self.session,
                                               group_name,
                                               system_ids,
                                               False)

####################

def help_group_create(self):
    print 'group_create: Create a system group'
    print 'usage: group_create [NAME] [DESCRIPTION]'

def do_group_create(self, args):
    args = parse_arguments(args)

    if len(args) > 0:
        name = args[0]
    else:
        name = prompt_user('Name:')

    if len(args) > 1:
        description = ' '.join(args[1:])
    else:
        description = prompt_user('Description:')

    group = self.client.systemgroup.create(self.session, name, description)

####################

def help_group_delete(self):
    print 'group_delete: Delete a system group'
    print 'usage: group_delete NAME ...'

def complete_group_delete(self, text, line, beg, end):
    return tab_completer(self.do_group_list('', True), text)

def do_group_delete(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_group_delete()
        return

    groups = args

    self.do_group_details('', True)
    if not self.user_confirm('Delete these groups [y/N]:'): return

    for group in groups:
        self.client.systemgroup.delete(self.session, group)

####################

def help_group_list(self):
    print 'group_list: List available system groups'
    print 'usage: group_list'

def do_group_list(self, args, doreturn=False):
    groups = self.client.systemgroup.listAllGroups(self.session)
    groups = [g.get('name') for g in groups]

    if doreturn:
        return groups
    else:
        if len(groups):
            print '\n'.join(sorted(groups))

####################

def help_group_listsystems(self):
    print 'group_listsystems: List the members of a group'
    print 'usage: group_listsystems GROUP'

def complete_group_listsystems(self, text, line, beg, end):
    return tab_completer(self.do_group_list('', True), text)

def do_group_listsystems(self, args, doreturn=False):
    args = parse_arguments(args)

    if not len(args):
        self.help_group_listsystems()
        return

    group = args[0]

    try:
        systems = self.client.systemgroup.listSystems(self.session,
                                                      group)

        systems = [s.get('profile_name') for s in systems]
    except:
        logging.warning('%s is not a valid group' % group)
        return []

    if doreturn:
        return systems
    else:
        if len(systems):
            print '\n'.join(sorted(systems))

####################

def help_group_details(self):
    print 'group_details: Show the details of a system group'
    print 'usage: group_details GROUP ...'

def complete_group_details(self, text, line, beg, end):
    return tab_completer(self.do_group_list('', True), text)

def do_group_details(self, args, short=False):
    args = parse_arguments(args)

    if not len(args):
        self.help_group_details()
        return

    add_separator = False

    for group in args:
        try:
            details = self.client.systemgroup.getDetails(self.session,
                                                         group)

            systems = self.client.systemgroup.listSystems(self.session,
                                                          group)

            systems = [s.get('profile_name') for s in systems]
        except:
            logging.warning('%s is not a valid group' % key)
            return

        if add_separator: print self.SEPARATOR
        add_separator = True

        print 'Name               %s' % details.get('name')
        print 'Description:       %s' % details.get('description')
        print 'Number of Systems: %s' % str(details.get('system_count'))

        if not short:
            print
            print 'Members:'
            for s in sorted(systems):
                print '  %s' % s

# vim:ts=4:expandtab:
