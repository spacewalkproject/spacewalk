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

import shlex
from getpass import getpass
from operator import itemgetter
from optparse import Option
from spacecmd.utils import *

_PREFIXES = ['Dr.', 'Mr.', 'Miss', 'Mrs.', 'Ms.']


def help_org_create(self):
    print 'org_create: Create an organization'
    print '''usage: org_create [options]

options:
  -n ORG_NAME
  -u USERNAME
  -P PREFIX (%s)
  -f FIRST_NAME
  -l LAST_NAME
  -e EMAIL
  -p PASSWORD
  --pam enable PAM authentication''' % ', '.join(_PREFIXES)


def do_org_create(self, args):
    options = [Option('-n', '--org-name', action='store'),
               Option('-u', '--username', action='store'),
               Option('-P', '--prefix', action='store'),
               Option('-f', '--first-name', action='store'),
               Option('-l', '--last-name', action='store'),
               Option('-e', '--email', action='store'),
               Option('-p', '--password', action='store'),
               Option('', '--pam', action='store_true')]

    (args, options) = parse_arguments(args, options)

    if is_interactive(options):
        options.org_name = prompt_user('Organization Name:', noblank=True)
        options.username = prompt_user('Username:', noblank=True)
        options.prefix = prompt_user('Prefix (%s):' % ', '.join(_PREFIXES),
                                     noblank=True)
        options.first_name = prompt_user('First Name:', noblank=True)
        options.last_name = prompt_user('Last Name:', noblank=True)
        options.email = prompt_user('Email:', noblank=True)
        options.pam = self.user_confirm('PAM Authentication [y/N]:',
                                        nospacer=True,
                                        integer=False,
                                        ignore_yes=True)

        options.password = ''
        while options.password == '':
            password1 = getpass('Password: ')
            password2 = getpass('Repeat Password: ')

            if password1 == password2:
                options.password = password1
            elif password1 == '':
                logging.warning('Password must be at least 5 characters')
            else:
                logging.warning("Passwords don't match")
    else:
        if not options.org_name:
            logging.error('An organization name is required')
            return

        if not options.username:
            logging.error('A username is required')
            return

        if not options.first_name:
            logging.error('A first name is required')
            return

        if not options.last_name:
            logging.error('A last name is required')
            return

        if not options.email:
            logging.error('An email address is required')
            return

        if not options.password:
            logging.error('A password is required')
            return

        if not options.pam:
            options.pam = False

        if not options.prefix:
            options.prefix = 'Dr.'

    if options.prefix[-1] != '.' and options.prefix != 'Miss':
        options.prefix = options.prefix + '.'

    self.client.org.create(self.session,
                           options.org_name,
                           options.username,
                           options.password,
                           options.prefix.capitalize(),
                           options.first_name,
                           options.last_name,
                           options.email,
                           options.pam)

####################


def help_org_delete(self):
    print 'org_delete: Delete an organization'
    print 'usage: org_delete NAME'


def complete_org_delete(self, text, line, beg, end):
    return tab_completer(self.do_org_list('', True), text)


def do_org_delete(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) != 1:
        self.help_org_delete()
        return

    name = args[0]
    org_id = self.get_org_id(name)

    if self.org_confirm('Delete this organization [y/N]:'):
        self.client.org.delete(self.session, org_id)

####################


def help_org_rename(self):
    print 'org_rename: Rename an organization'
    print 'usage: org_rename OLDNAME NEWNAME'


def complete_org_rename(self, text, line, beg, end):
    return tab_completer(self.do_org_list('', True), text)


def do_org_rename(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) != 2:
        self.help_org_rename()
        return

    org_id = self.get_org_id(args[0])
    new_name = args[1]

    self.client.org.updateName(self.session, org_id, new_name)

####################


def help_org_addtrust(self):
    print 'org_addtrust: Add a trust between two organizations'
    print 'usage: org_addtrust YOUR_ORG ORG_TO_TRUST'


def complete_org_addtrust(self, text, line, beg, end):
    return tab_completer(self.do_org_list('', True), text)


def do_org_addtrust(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) != 2:
        self.help_org_addtrust()
        return

    your_org_id = self.get_org_id(args[0])
    org_to_trust_id = self.get_org_id(args[1])

    self.client.org.trusts.addTrust(self.session, your_org_id, org_to_trust_id)

####################


def help_org_removetrust(self):
    print 'org_removetrust: Remove a trust between two organizations'
    print 'usage: org_removetrust YOUR_ORG TRUSTED_ORG'


def complete_org_removetrust(self, text, line, beg, end):
    return tab_completer(self.do_org_list('', True), text)


def do_org_removetrust(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) != 2:
        self.help_org_removetrust()
        return

    your_org_id = self.get_org_id(args[0])
    trusted_org_id = self.get_org_id(args[1])

    systems = self.client.org.trusts.listSystemsAffected(self.session,
                                                         your_org_id,
                                                         trusted_org_id)

    print 'Affected Systems'
    print '----------------'

    if len(systems):
        print '\n'.join(sorted([s.get('systemName') for s in systems]))
    else:
        print 'None'

    if not self.user_confirm('Remove this trust [y/N]:'):
        return

    self.client.org.trusts.removeTrust(self.session,
                                       your_org_id,
                                       trusted_org_id)

####################


def help_org_trustdetails(self):
    print 'org_trustdetails: Show the details of an organizational trust'
    print 'usage: org_trustdetails TRUSTED_ORG'


def complete_org_trustdetails(self, text, line, beg, end):
    return tab_completer(self.do_org_list('', True), text)


def do_org_trustdetails(self, args):
    (args, _options) = parse_arguments(args)

    if not len(args):
        self.help_org_trustdetails()
        return

    trusted_org = args[0]
    org_id = self.get_org_id(trusted_org)

    details = self.client.org.trusts.getDetails(self.session, org_id)
    consumed = self.client.org.trusts.listChannelsConsumed(self.session, org_id)
    provided = self.client.org.trusts.listChannelsProvided(self.session, org_id)

    print 'Trusted Organization:   %s' % trusted_org
    print 'Trusted Since:          %s' % details.get('trusted_since')
    print 'Systems Migrated From:  %i' % details.get('systems_migrated_from')
    print 'Systems Migrated To:    %i' % details.get('systems_migrated_to')
    print
    print 'Channels Consumed'
    print '-----------------'
    if len(consumed):
        print '\n'.join(sorted([c.get('name') for c in consumed]))

    print

    print 'Channels Provided'
    print '-----------------'
    if len(provided):
        print '\n'.join(sorted([c.get('name') for c in provided]))

####################


def help_org_list(self):
    print 'org_list: List all organizations'
    print 'usage: org_list'


def do_org_list(self, args, doreturn=False):
    orgs = self.client.org.listOrgs(self.session)
    orgs = [o.get('name') for o in orgs]

    if doreturn:
        return orgs
    else:
        if len(orgs):
            print '\n'.join(sorted(orgs))

####################


def help_org_listtrusts(self):
    print "org_listtrusts: List an organization's trusts"
    print 'usage: org_listtrusts NAME'


def complete_org_listtrusts(self, text, line, beg, end):
    return tab_completer(self.do_org_list('', True), text)


def do_org_listtrusts(self, args):
    (args, _options) = parse_arguments(args)

    if not len(args):
        self.help_org_listtrusts()
        return

    org_id = self.get_org_id(args[0])

    trusts = self.client.org.trusts.listTrusts(self.session, org_id)

    for trust in sorted(trusts, key=itemgetter('orgName')):
        if trust.get('trustEnabled'):
            print trust.get('orgName')

####################


def help_org_listusers(self):
    print "org_listusers: List an organization's users"
    print 'usage: org_listusers NAME'


def complete_org_listusers(self, text, line, beg, end):
    return tab_completer(self.do_org_list('', True), text)


def do_org_listusers(self, args):
    (args, _options) = parse_arguments(args)

    if not len(args):
        self.help_org_listusers()
        return

    org_id = self.get_org_id(args[0])

    users = self.client.org.listUsers(self.session, org_id)

    print '\n'.join(sorted([u.get('login') for u in users]))

####################


def help_org_details(self):
    print 'org_details: Show the details of an organization'
    print 'usage: org_details NAME'


def complete_org_details(self, text, line, beg, end):
    return tab_completer(self.do_org_list('', True), text)


def do_org_details(self, args):
    (args, _options) = parse_arguments(args)

    if not len(args):
        self.help_org_details()
        return

    name = args[0]

    details = self.client.org.getDetails(self.session, name)

    print 'Name:                   %s' % details.get('name')
    print 'Active Users:           %i' % details.get('active_users')
    print 'Systems:                %i' % details.get('systems')

    # trusts is optional, which is annoying...
    if details.has_key('trusts'):
        print 'Trusts:                 %i' % details.get('trusts')
    else:
        print 'Trusts:                 %i' % 0

    print 'System Groups:          %i' % details.get('system_groups')
    print 'Activation Keys:        %i' % details.get('activation_keys')
    print 'Kickstart Profiles:     %i' % details.get('kickstart_profiles')
    print 'Configuration Channels: %i' % details.get('configuration_channels')

####################


def help_org_setsystementitlements(self):
    print "org_setsystementitlements: Sets an organization's system",
    print "entitlements"
    print 'usage: org_setsystementitlements ORG ENTITLEMENT VALUE'


def complete_org_setsystementitlements(self, text, line, beg, end):
    parts = shlex.split(line)
    if line[-1] == ' ':
        parts.append('')

    if len(parts) == 2:
        return tab_completer(self.do_org_list('', True), text)


def do_org_setsystementitlements(self, args):
    (args, _options) = parse_arguments(args)

    if not len(args):
        self.help_org_setsystementitlements()
        return

    org_id = self.get_org_id(args[0])
    label = args[1]

    try:
        value = int(args[2])
    except ValueError:
        logging.error('Value must be an integer')
        return

    self.client.org.setSystemEntitlements(self.session, org_id, label, value)
