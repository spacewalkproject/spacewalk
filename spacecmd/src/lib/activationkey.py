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

import re
from spacecmd.utils import *

def help_activationkey_addpackages(self):
    print 'activationkey_addpackages: Add packages to an activation key'
    print 'usage: activationkey_addpackages KEY <PACKAGE ...>'

def complete_activationkey_addpackages(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_activationkey_list('', True), 
                                  text)
    elif len(parts) > 2:
        return tab_completer(self.get_package_names(), text)

def do_activationkey_addpackages(self, args):
    args = parse_arguments(args)

    if not len(args) >= 2:
        self.help_activationkey_addpackages()
        return

    key = args.pop(0)
    packages = [{'name' : a} for a in args]

    self.client.activationkey.addPackages(self.session, key, packages)

####################

def help_activationkey_removepackages(self):
    print 'activationkey_removepackages: Remove packages from an ' + \
          'activation key'
    print 'usage: activationkey_removepackages KEY <PACKAGE ...>'

def complete_activationkey_removepackages(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_activationkey_list('', True), 
                                  text)
    elif len(parts) > 2:
        details = self.client.activationkey.getDetails(self.session, 
                                                       parts[1])
        packages = [ p['name'] for p in details.get('packages') ]
        return tab_completer(packages, text)

def do_activationkey_removepackages(self, args):
    args = parse_arguments(args)

    if not len(args) >= 2:
        self.help_activationkey_removepackages()
        return

    key = args.pop(0)
    packages = [{'name' : a} for a in args]

    self.client.activationkey.removePackages(self.session, key, packages)

####################

def help_activationkey_addgroups(self):
    print 'activationkey_addgroups: Add groups to an activation key'
    print 'usage: activationkey_addgroups KEY <GROUP ...>'

def complete_activationkey_addgroups(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_activationkey_list('', True), 
                                  text)
    elif len(parts) > 2:
        return tab_completer(self.do_group_list('', True), text)

def do_activationkey_addgroups(self, args):
    args = parse_arguments(args)

    if not len(args) >= 2:
        self.help_activationkey_addgroups()
        return

    key = args.pop(0)

    groups = []
    for a in args:
        details = self.client.systemgroup.getDetails(self.session, a)
        groups.append(details.get('id'))

    self.client.activationkey.addServerGroups(self.session, key, groups)

####################

def help_activationkey_removegroups(self):
    print 'activationkey_removegroups: Remove groups from an activation key'
    print 'usage: activationkey_removegroups KEY <GROUP ...>'

def complete_activationkey_removegroups(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_activationkey_list('', True), 
                                  text)
    elif len(parts) > 2:
        key_details = self.client.activationkey.getDetails(self.session, 
                                                           parts[1])

        groups = []
        for group in key_details.get('server_group_ids'):
            details = self.client.systemgroup.getDetails(self.session, 
                                                         group)
            groups.append(details.get('name'))                

        return tab_completer(groups, text)

def do_activationkey_removegroups(self, args):
    args = parse_arguments(args)

    if not len(args) >= 2:
        self.help_activationkey_removegroups()
        return

    key = args.pop(0)

    groups = []
    for a in args:
        details = self.client.systemgroup.getDetails(self.session, a)
        groups.append(details.get('id'))

    self.client.activationkey.removeServerGroups(self.session, key, groups)

####################

def help_activationkey_addentitlements(self):
    print 'activationkey_addentitlements: Add entitlements to an ' + \
          'activation key'
    print 'usage: activationkey_addentitlements KEY <ENTITLEMENT ...>'

def complete_activationkey_addentitlements(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_activationkey_list('', True),
                                  text)
    elif len(parts) > 2:
        return tab_completer(self.ENTITLEMENTS, text)

def do_activationkey_addentitlements(self, args):
    args = parse_arguments(args)

    if not len(args) >= 2:
        self.help_activationkey_addentitlements()
        return

    key = args.pop(0)
    entitlements = args

    self.client.activationkey.addEntitlements(self.session, 
                                              key, 
                                              entitlements)

####################

def help_activationkey_removeentitlements(self):
    print 'activationkey_removeentitlements: Remove entitlements from an ' \
          'activation key'
    print 'usage: activationkey_removeentitlements KEY <ENTITLEMENT ...>'

def complete_activationkey_removeentitlements(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_activationkey_list('', True), text)
    elif len(parts) > 2:
        details = \
            self.client.activationkey.getDetails(self.session, parts[1])

        entitlements = details.get('entitlements')
        return tab_completer(entitlements, text)

def do_activationkey_removeentitlements(self, args):
    args = parse_arguments(args)

    if not len(args) >= 2:
        self.help_activationkey_removeentitlements()
        return

    key = args.pop(0)
    entitlements = args

    self.client.activationkey.removeEntitlements(self.session, 
                                                 key, 
                                                 entitlements)

####################

def help_activationkey_addchildchannels(self):
    print 'activationkey_addchildchannels: Add child channels to an ' \
          'activation key'
    print 'usage: activationkey_addchildchannels KEY <CHANNEL ...>'

def complete_activationkey_addchildchannels(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_activationkey_list('', True),
                                  text)
    elif len(parts) > 2:
        key_details = \
            self.client.activationkey.getDetails(self.session, parts[1])
        base_channel = key_details.get('base_channel_label')

        all_channels = \
            self.client.channel.listSoftwareChannels(self.session)

        child_channels = []
        for c in all_channels:
            if base_channel == 'none':
                # this gets all child channels
                if c.get('parent_label'):
                    child_channels.append(c.get('label'))
            else:
                if c.get('parent_label') == base_channel:
                    child_channels.append(c.get('label'))

        return tab_completer(child_channels, text)

def do_activationkey_addchildchannels(self, args):
    args = parse_arguments(args)

    if not len(args) >= 2:
        self.help_activationkey_addchildchannels()
        return

    key = args.pop(0)
    channels = args

    self.client.activationkey.addChildChannels(self.session, key, channels)

####################

def help_activationkey_removechildchannels(self):
    print 'activationkey_removechildchannels: Remove child channels from ' \
          'an activation key'
    print 'usage: activationkey_removechildchannels KEY <CHANNEL ...>'

def complete_activationkey_removechildchannels(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_activationkey_list('', True), text)
    elif len(parts) > 2:
        key_details = \
            self.client.activationkey.getDetails(self.session, parts[1])

        return tab_completer(key_details.get('child_channel_labels'), text)

def do_activationkey_removechildchannels(self, args):
    args = parse_arguments(args)

    if not len(args) >= 2:
        self.help_activationkey_removechildchannels()
        return

    key = args.pop(0)
    channels = args

    self.client.activationkey.removeChildChannels(self.session, 
                                                  key, 
                                                  channels)

####################

def help_activationkey_listchildchannels(self):
    print 'activationkey_listchildchannels: List the child channels ' + \
          'for an activation key'
    print 'usage: activationkey_listchildchannels KEY'

def complete_activationkey_listchildchannels(self, text, line, beg, end):
    return tab_completer(self.do_activationkey_list('', True), text)

def do_activationkey_listchildchannels(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_activationkey_listchildchannels()
        return

    key = args[0]

    details = self.client.activationkey.getDetails(self.session, key)

    if len(details.get('child_channel_labels')):
        print '\n'.join(details.get('child_channel_labels'))

####################

def help_activationkey_listbasechannel(self):
    print 'activationkey_listbasechannel: List the base channels ' + \
          'for an activation key'
    print 'usage: activationkey_listbasechannel KEY'

def complete_activationkey_listbasechannel(self, text, line, beg, end):
    return tab_completer(self.do_activationkey_list('', True), text)

def do_activationkey_listbasechannel(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_activationkey_listbasechannel()
        return

    key = args[0]

    details = self.client.activationkey.getDetails(self.session, key)

    print details.get('base_channel_label')

####################

def help_activationkey_listgroups(self):
    print 'activationkey_listgroups: List the groups for an ' + \
          'activation key'
    print 'usage: activationkey_listgroups KEY'

def complete_activationkey_listgroups(self, text, line, beg, end):
    return tab_completer(self.do_activationkey_list('', True), text)

def do_activationkey_listgroups(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_activationkey_listgroups()
        return

    key = args[0]

    details = self.client.activationkey.getDetails(self.session, key)

    for group in details.get('server_group_ids'):
        group_details = self.client.systemgroup.getDetails(self.session,
                                                           group)
        print group_details.get('name')

####################

def help_activationkey_listentitlements(self):
    print 'activationkey_listentitlements: List the entitlements ' + \
          'for an activation key'
    print 'usage: activationkey_listentitlements KEY'

def complete_activationkey_listentitlements(self, text, line, beg, end):
    return tab_completer(self.do_activationkey_list('', True), text)

def do_activationkey_listentitlements(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_activationkey_listentitlements()
        return

    key = args[0]

    details = self.client.activationkey.getDetails(self.session, key)

    if len(details.get('entitlements')):
        print '\n'.join(details.get('entitlements'))

####################

def help_activationkey_listpackages(self):
    print 'activationkey_listpackages: List the packages for an ' + \
          'activation key'
    print 'usage: activationkey_listpackages KEY'

def complete_activationkey_listpackages(self, text, line, beg, end):
    return tab_completer(self.do_activationkey_list('', True), text)

def do_activationkey_listpackages(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_activationkey_listpackages()
        return

    key = args[0]

    details = self.client.activationkey.getDetails(self.session, key)

    for package in details.get('packages'):
        if 'arch' in package:
            print '%s.%s' % (package['name'], package['arch'])
        else:
            print package['name']

####################

def help_activationkey_listconfigchannels(self):
    print 'activationkey_listconfigchannels: List the configuration ' + \
          'channels for an activation key'
    print 'usage: activationkey_listconfigchannels KEY'

def complete_activationkey_listconfigchannels(self, text, line, beg, end):
    return tab_completer(self.do_activationkey_list('', True), text)

def do_activationkey_listconfigchannels(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_activationkey_listconfigchannels()
        return

    key = args[0]

    channels = \
        self.client.activationkey.listConfigChannels(self.session,
                                                     key)

    channels = sorted([ c.get('label') for c in channels])

    if len(channels):
        print '\n'.join(channels)

####################

def help_activationkey_addconfigchannels(self):
    print 'activationkey_addconfigchannels: Add config channels ' \
          'to an activation key'
    print 'usage: activationkey_addconfigchannels KEY <CHANNEL ...>'

def complete_activationkey_addconfigchannels(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_activationkey_list('', True), text)
    elif len(parts) > 2:
        return tab_completer(self.do_configchannel_list('', True), text)

def do_activationkey_addconfigchannels(self, args):
    args = parse_arguments(args)

    if len(args) < 2:
        self.help_activationkey_addconfigchannels()
        return

    key = [ args.pop(0) ]
    channels = args

    answer = prompt_user('Add to top or bottom? [T/b]:')
    if re.match('b', answer, re.I):
        location = False
    else:
        location = True

    self.client.activationkey.addConfigChannels(self.session, 
                                                key, 
                                                channels, 
                                                location)

####################

def help_activationkey_removeconfigchannels(self):
    print 'activationkey_removeconfigchannels: Remove config channels ' \
          'from an activation key'
    print 'usage: activationkey_removeconfigchannels KEY <CHANNEL ...>'

def complete_activationkey_removeconfigchannels(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_activationkey_list('', True), text)
    elif len(parts) > 2:
        key_channels = \
            self.client.activationkey.listConfigChannels(self.session, 
                                                         parts[1])

        config_channels = [c.get('label') for c in key_channels]
        return tab_completer(config_channels, text)

def do_activationkey_removeconfigchannels(self, args):
    args = parse_arguments(args)

    if not len(args) >= 2:
        self.help_activationkey_removeconfigchannels()
        return

    key = [ args.pop(0) ]
    channels = args

    self.client.activationkey.removeConfigChannels(self.session, 
                                                   key, 
                                                   channels)

####################

def help_activationkey_setconfigchannelorder(self):
    print 'activationkey_setconfigchannelorder: Set the ranked order of ' \
          'configuration channels'
    print 'usage: activationkey_setconfigchannelorder KEY'

def complete_activationkey_setconfigchannelorder(self, text, line, beg, 
                                                 end):
    return tab_completer(self.do_activationkey_list('', True), text)

def do_activationkey_setconfigchannelorder(self, args):
    args = parse_arguments(args)

    if len(args) != 1:
        self.help_activationkey_setconfigchannelorder()
        return

    key = args[0]

    # get the current configuration channels from the first activationkey
    # in the list
    new_channels = \
        self.client.activationkey.listConfigChannels(self.session, key)
    new_channels = [ c.get('label') for c in new_channels ]

    # call an interface for the user to make selections
    all_channels = self.do_configchannel_list('', True)
    new_channels = config_channel_order(all_channels, new_channels)

    print
    print 'New Configuration Channels:'
    for i in range(len(new_channels)):
        print '[%i] %s' % (i + 1, new_channels[i])

    if not user_confirm(self): return        

    self.client.activationkey.setConfigChannels(self.session, 
                                                [key], 
                                                new_channels)

####################

def help_activationkey_create(self):
    print 'activationkey_create: Create an activation key'
    print 'usage: activationkey_create'

def do_activationkey_create(self, args):
    name = prompt_user('Name (blank to autogenerate):')
    description = prompt_user('Description [None]:')

    print
    print 'Base Channels'
    print '-------------'
    print '\n'.join(sorted(self.list_base_channels()))
    print

    base_channel = prompt_user('Base Channel (blank for default):')

    entitlements = []
    for e in self.ENTITLEMENTS:
        if e == 'enterprise_entitled': continue

        if self.user_confirm('%s Entitlement [y/N]:' % e):
            entitlements.append(e)

    default = self.user_confirm('Universal Default [y/N]:')

    new_key = self.client.activationkey.create(self.session,
                                               name,
                                               description,
                                               base_channel,
                                               entitlements,
                                               default)

    logging.info('Created activation key %s' % new_key)

####################

def help_activationkey_delete(self):
    print 'activationkey_delete: Delete an activation key'
    print 'usage: activationkey_delete KEY'

def complete_activationkey_delete(self, text, line, beg, end):
    return tab_completer(self.do_activationkey_list('', True), text)

def do_activationkey_delete(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_activationkey_delete()
        return

    key = args[0]

    if not self.user_confirm('Delete this activation key [y/N]:'): return

    self.client.activationkey.delete(self.session, key)

####################

def help_activationkey_list(self):
    print 'activationkey_list: List all activation keys'
    print 'usage: activationkey_list'

def do_activationkey_list(self, args, doreturn=False):
    all_keys = self.client.activationkey.listActivationKeys(self.session)

    keys = []
    for k in all_keys:
        # don't list auto-generated re-activation keys
        if not re.match('Kickstart re-activation', k.get('description')):
            keys.append(k.get('key'))

    if doreturn:
        return keys
    else:
        if len(keys):
            print '\n'.join(sorted(keys))

####################

def help_activationkey_listsystems(self):
    print 'activationkey_listsystems: List systems registered with a key'
    print 'usage: activationkey_listsystems KEY'

def complete_activationkey_listsystems(self, text, line, beg, end):
    return tab_completer(self.do_activationkey_list('', True), text)

def do_activationkey_listsystems(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_activationkey_listsystems()
        return

    key = args[0]

    try:
        systems = \
            self.client.activationkey.listActivatedSystems(self.session,
                                                           key)
    except:
        logging.warning('%s is not a valid activation key' % key)
        return

    systems = sorted([s.get('hostname') for s in systems])

    if len(systems):
        print '\n'.join(systems)

####################

def help_activationkey_details(self):
    print 'activationkey_details: Show the details of an activation key'
    print 'usage: activationkey_details KEY ...'

def complete_activationkey_details(self, text, line, beg, end):
    return tab_completer(self.do_activationkey_list('', True), text)

def do_activationkey_details(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_activationkey_details()
        return

    add_separator = False

    for key in args:
        try:
            details = self.client.activationkey.getDetails(self.session,
                                                           key)

            # an exception is thrown if provisioning is not enabled and we
            # attempt to get configuration channel information
            try:
                config_channels = \
                    self.client.activationkey.listConfigChannels(\
                                               self.session, key)

                config_channel_deploy = \
                    self.client.activationkey.checkConfigDeployment(\
                                                  self.session, key)
            except:
                config_channels = []
                config_channel_deploy = 0

            # API returns 0/1 instead of boolean
            if config_channel_deploy == 1:
                config_channel_deploy = True
            else:
                config_channel_deploy = False
        except:
            logging.warning('%s is not a valid activation key' % key)
            return

        groups = []
        for group in details.get('server_group_ids'):
            group_details = self.client.systemgroup.getDetails(self.session,
                                                               group)
            groups.append(group_details.get('name'))

        if add_separator: print self.SEPARATOR
        add_separator = True

        print 'Key:                    %s' % details.get('key')
        print 'Description:            %s' % details.get('description')
        print 'Universal Default:      %s' % details.get('universal_default')
        print 'Deploy Config Channels: %s' % config_channel_deploy

        print
        print 'Software Channels'
        print '-----------------'
        print details.get('base_channel_label')

        for channel in details.get('child_channel_labels'):
            print ' |-- %s' % channel

        print
        print 'Configuration Channels'
        print '----------------------'
        for channel in config_channels:
            print channel.get('label')

        print
        print 'Entitlements'
        print '------------'
        print '\n'.join(sorted(details.get('entitlements')))

        print
        print 'System Groups'
        print '-------------'
        print '\n'.join(sorted(groups))

        print
        print 'Packages'
        print '--------'
        for package in details.get('packages'):
            name = package.get('name')

            if package.get('arch'):
                name += '.%s' % package.get('arch')

            print name

####################

def help_activationkey_enableconfigdeployment(self):
    print 'activationkey_enableconfigdeployment: Enable config ' + \
          'channel deployment'
    print 'usage: activationkey_enableconfigdeployment KEY'

def complete_activationkey_enableconfigdeployment(self, text, line, beg, 
                                                  end):
    return tab_completer(self.do_activationkey_list('', True), text)

def do_activationkey_enableconfigdeployment(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_activationkey_enableconfigdeployment()
        return

    for key in args:
        logging.debug('Enabling config file deployment for %s' % key)
        self.client.activationkey.enableConfigDeployment(self.session, key)

####################

def help_activationkey_disableconfigdeployment(self):
    print 'activationkey_disableconfigdeployment: Disable config ' + \
          'channel deployment'
    print 'usage: activationkey_disableconfigdeployment KEY'

def complete_activationkey_disableconfigdeployment(self, text, line, beg, 
                                                   end):
    return tab_completer(self.do_activationkey_list('', True), text)

def do_activationkey_disableconfigdeployment(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_activationkey_disableconfigdeployment()
        return

    for key in args:
        logging.debug('Disabling config file deployment for %s' % key)
        self.client.activationkey.disableConfigDeployment(self.session, key)

####################

def help_activationkey_setbasechannel(self):
    print 'activationkey_setbasechannel: Set the base channel of an ' + \
          'activation key'
    print 'usage: activationkey_setbasechannel KEY CHANNEL'

def complete_activationkey_setbasechannel(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_activationkey_list('', True), text)
    elif len(parts) > 2:
        return tab_completer(list_base_channels(self), text)

def do_activationkey_setbasechannel(self, args):
    args = parse_arguments(args)

    if not len(args) >= 2:
        self.help_activationkey_setbasechannel()
        return

    key = args.pop(0)
    channel = args[0]

    current_details = self.client.activationkey.getDetails(self.session, 
                                                           key)

    details = { 'description' : current_details.get('description'),
                'base_channel_label' : channel,
                'usage_limit' : current_details.get('usage_limit'),
                'universal_default' : \
                current_details.get('universal_default') }

    self.client.activationkey.setDetails(self.session, key, details)

####################

def help_activationkey_setuniversaldefault(self):
    print 'activationkey_setuniversaldefault: Set this key as the ' \
          'universal default'
    print 'usage: activationkey_setuniversaldefault KEY'

def complete_activationkey_setuniversaldefault(self, text, line, beg, end):
    return tab_completer(self.do_activationkey_list('', True), text)

def do_activationkey_setuniversaldefault(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_activationkey_setuniversaldefault()
        return

    key = args.pop(0)

    current_details = self.client.activationkey.getDetails(self.session, 
                                                           key)

    details = { 'description' : current_details.get('description'),
                'base_channel_label' : \
                                  current_details.get('base_channel_label'),
                'usage_limit' : current_details.get('usage_limit'),
                'universal_default' : True }

    self.client.activationkey.setDetails(self.session, key, details)

# vim:ts=4:expandtab:
