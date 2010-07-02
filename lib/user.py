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

def help_user_delete(self):
    print 'user_delete: Delete a user'
    print 'usage: user_delete NAME'

def complete_user_delete(self, text, line, beg, end):
    return tab_completer(self.do_user_list('', True), text)

def do_user_delete(self, args):
    args = parse_arguments(args)

    if len(args) != 1:
        self.help_user_delete()
        return

    name = args[0]

    if self.user_confirm('Delete this user [y/N]:'):
        self.client.user.delete(self.session, name)

####################

def help_user_disable(self):
    print 'user_disable: Disable an user account'
    print 'usage: user_disable NAME'

def complete_user_disable(self, text, line, beg, end):
    return tab_completer(self.do_user_list('', True), text)

def do_user_disable(self, args):
    args = parse_arguments(args)

    if len(args) != 1:
        self.help_user_disable()
        return

    name = args[0]

    self.client.user.disable(self.session, name)

####################

def help_user_enable(self):
    print 'user_enable: Enable an user account'
    print 'usage: user_enable NAME'

def complete_user_enable(self, text, line, beg, end):
    return tab_completer(self.do_user_list('', True), text)

def do_user_enable(self, args):
    args = parse_arguments(args)

    if len(args) != 1:
        self.help_user_enable()
        return

    name = args[0]

    self.client.user.enable(self.session, name)

####################

def help_user_list(self):
    print 'user_list: List all users'
    print 'usage: user_list'

def do_user_list(self, args, doreturn=False):
    users = self.client.user.listUsers(self.session)
    users = [u.get('login') for u in users]

    if doreturn:
        return users
    else:
        if len(users):
            print '\n'.join(sorted(users))

####################

def help_user_listavailableroles(self):
    print 'user_list: List all available roles for users'
    print 'usage: user_listavailableroles'

def do_user_listavailableroles(self, args, doreturn=False):
    roles = self.client.user.listAssignableRoles(self.session)

    if doreturn:
        return roles
    else:
        if len(roles):
            print '\n'.join(sorted(roles))

####################

def help_user_addrole(self):
    print 'user_addrole: Add a role to an user account'
    print 'usage: user_addrole USER ROLE'

def complete_user_addrole(self, text, line, beg, end):
    parts = line.split(' ')
    
    if len(parts) == 2:
        return tab_completer(self.do_user_list('', True), text)
    elif len(parts) == 3:
        return tab_completer(self.do_user_listavailableroles('', True), 
                                  text)

def do_user_addrole(self, args):
    args = parse_arguments(args)

    if len(args) != 2:
        self.help_user_addrole()
        return

    user = args[0]
    role = args[1]

    self.client.user.addRole(self.session, user, role)

####################

def help_user_removerole(self):
    print 'user_removerole: Remove a role from an user account'
    print 'usage: user_removerole USER ROLE'

def complete_user_removerole(self, text, line, beg, end):
    parts = line.split(' ')
    
    if len(parts) == 2:
        return tab_completer(self.do_user_list('', True), text)
    elif len(parts) == 3:
        # only list the roles currently assigned to this user
        roles = self.client.user.listRoles(self.session, parts[1])
        return tab_completer(roles, text)

def do_user_removerole(self, args):
    args = parse_arguments(args)

    if len(args) != 2:
        self.help_user_removerole()
        return

    user = args[0]
    role = args[1]

    self.client.user.removeRole(self.session, user, role)

####################

def help_user_details(self):
    print 'user_details: Show the details of a user'
    print 'usage: user_details USER ...'

def complete_user_details(self, text, line, beg, end):
    return tab_completer(self.do_user_list('', True), text)

def do_user_details(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_user_details()
        return

    add_separator = False

    for user in args:
        try:
            details = self.client.user.getDetails(self.session, user)

            roles = self.client.user.listRoles(self.session, user)

            groups = \
                self.client.user.listAssignedSystemGroups(self.session,
                                                                user)

            default_groups = \
                self.client.user.listDefaultSystemGroups(self.session,
                                                         user)
        except:
            logging.warning('%s is not a valid user' % user)
            continue

        org_details = self.client.org.getDetails(self.session, 
                                                 details.get('org_id'))
        organization = org_details.get('name')

        if add_separator: print self.SEPARATOR
        add_separator = True

        print 'Username:      %s' % user
        print 'First Name:    %s' % details.get('first_name')
        print 'Last Name:     %s' % details.get('last_name')
        print 'Email Address: %s' % details.get('email')
        print 'Organization:  %s' % organization
        print 'Last Login:    %s' % details.get('last_login_date')
        print 'Created:       %s' % details.get('created_date')
        print 'Enabled:       %s' % details.get('enabled')

        if len(roles):
            print
            print 'Roles:'
            print '\n'.join(sorted(roles))

        if len(groups):
            print
            print 'Assigned Groups:'
            print '\n'.join(sorted([g.get('name') for g in groups]))
        
        if len(default_groups):
            print
            print 'Default Groups:'
            print '\n'.join(sorted([g.get('name') for g in default_groups]))

####################

def help_user_addgroup(self):
    print 'user_addgroup: Add a group to an user account'
    print 'usage: user_addgroup USER <GROUP ...>'

def complete_user_addgroup(self, text, line, beg, end):
    parts = line.split(' ')
    
    if len(parts) == 2:
        return tab_completer(self.do_user_list('', True), text)
    elif len(parts) > 2:
        return tab_completer(self.do_group_list('', True), text)

def do_user_addgroup(self, args):
    args = parse_arguments(args)

    if len(args) != 2:
        self.help_user_addgroup()
        return

    user = args.pop(0)
    groups = args

    self.client.user.addAssignedSystemGroups(self.session, 
                                             user, 
                                             groups, 
                                             False)

####################

def help_user_adddefaultgroup(self):
    print 'user_adddefaultgroup: Add a default group to an user account'
    print 'usage: user_adddefaultgroup USER <GROUP ...>'

def complete_user_adddefaultgroup(self, text, line, beg, end):
    parts = line.split(' ')
    
    if len(parts) == 2:
        return tab_completer(self.do_user_list('', True), text)
    elif len(parts) > 2:
        return tab_completer(self.do_group_list('', True), text)

def do_user_adddefaultgroup(self, args):
    args = parse_arguments(args)

    if len(args) != 2:
        self.help_user_adddefaultgroup()
        return

    user = args.pop(0)
    groups = args

    self.client.user.addDefaultSystemGroups(self.session, 
                                            user, 
                                            groups)

####################

def help_user_removegroup(self):
    print 'user_removegroup: Remove a group to an user account'
    print 'usage: user_removegroup USER <GROUP ...>'

def complete_user_removegroup(self, text, line, beg, end):
    parts = line.split(' ')
    
    if len(parts) == 2:
        return tab_completer(self.do_user_list('', True), text)
    elif len(parts) > 2:
        # only list the groups currently assigned to this user
        groups = self.client.user.listAssignedSystemGroups(self.session, 
                                                           parts[1])
        return tab_completer([ g.get('name') for g in groups ], text)

def do_user_removegroup(self, args):
    args = parse_arguments(args)

    if len(args) != 2:
        self.help_user_removegroup()
        return

    user = args.pop(0)
    groups = args

    self.client.user.removeAssignedSystemGroups(self.session, 
                                                user, 
                                                groups, 
                                                True)

####################

def help_user_removedefaultgroup(self):
    print 'user_removedefaultgroup: Remove a default group from an ' + \
          'user account'
    print 'usage: user_removedefaultgroup USER <GROUP ...>'

def complete_user_removedefaultgroup(self, text, line, beg, end):
    parts = line.split(' ')
    
    if len(parts) == 2:
        return tab_completer(self.do_user_list('', True), text)
    elif len(parts) > 2:
        # only list the groups currently assigned to this user
        groups = self.client.user.listDefaultSystemGroups(self.session, 
                                                          parts[1])
        return tab_completer([ g.get('name') for g in groups ], text)

def do_user_removedefaultgroup(self, args):
    args = parse_arguments(args)

    if len(args) != 2:
        self.help_user_removedefaultgroup()
        return

    user = args.pop(0)
    groups = args

    self.client.user.removeDefaultSystemGroups(self.session, 
                                               user, 
                                               groups)

# vim:ts=4:expandtab:
