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
# Copyright (c) 2011--2012 Red Hat, Inc.
#

# NOTE: the 'self' variable is an instance of SpacewalkShell

import re, shlex
from optparse import Option
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
    (args, options) = parse_arguments(args)

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
    (args, options) = parse_arguments(args)

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
    parts = shlex.split(line)
    if line[-1] == ' ': parts.append('')

    if len(parts) == 2:
        return tab_completer(self.do_activationkey_list('', True), text)
    elif len(parts) > 2:
        return tab_completer(self.do_group_list('', True), parts[-1])

def do_activationkey_addgroups(self, args):
    (args, options) = parse_arguments(args)

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
    parts = shlex.split(line)
    if line[-1] == ' ': parts.append('')

    if len(parts) == 2:
        return tab_completer(self.do_activationkey_list('', True), text)
    elif len(parts) > 2:
        key_details = self.client.activationkey.getDetails(self.session, 
                                                           parts[-1])

        groups = []
        for group in key_details.get('server_group_ids'):
            details = self.client.systemgroup.getDetails(self.session, 
                                                         group)
            groups.append(details.get('name'))                

        return tab_completer(groups, text)

def do_activationkey_removegroups(self, args):
    (args, options) = parse_arguments(args)

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
    (args, options) = parse_arguments(args)

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
    (args, options) = parse_arguments(args)

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
    (args, options) = parse_arguments(args)

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
    (args, options) = parse_arguments(args)

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
    (args, options) = parse_arguments(args)

    if not len(args):
        self.help_activationkey_listchildchannels()
        return

    key = args[0]

    details = self.client.activationkey.getDetails(self.session, key)

    if len(details.get('child_channel_labels')):
        print '\n'.join(sorted(details.get('child_channel_labels')))

####################

def help_activationkey_listbasechannel(self):
    print 'activationkey_listbasechannel: List the base channels ' + \
          'for an activation key'
    print 'usage: activationkey_listbasechannel KEY'

def complete_activationkey_listbasechannel(self, text, line, beg, end):
    return tab_completer(self.do_activationkey_list('', True), text)

def do_activationkey_listbasechannel(self, args):
    (args, options) = parse_arguments(args)

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
    (args, options) = parse_arguments(args)

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
    (args, options) = parse_arguments(args)

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
    (args, options) = parse_arguments(args)

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
    (args, options) = parse_arguments(args)

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
    print '''usage: activationkey_addconfigchannels KEY <CHANNEL ...> [options]

options:
  -t add channels to the top of the list
  -b add channels to the bottom of the list'''

def complete_activationkey_addconfigchannels(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_activationkey_list('', True), text)
    elif len(parts) > 2:
        return tab_completer(self.do_configchannel_list('', True), text)

def do_activationkey_addconfigchannels(self, args):
    options = [ Option('-t', '--top', action='store_true'),
                Option('-b', '--bottom', action='store_true') ]

    (args, options) = parse_arguments(args, options)

    if len(args) < 2:
        self.help_activationkey_addconfigchannels()
        return

    key = [ args.pop(0) ]
    channels = args

    if is_interactive(options):
        answer = prompt_user('Add to top or bottom? [T/b]:')
        if re.match('b', answer, re.I):
            options.top = False
        else:
            options.top = True
    else:
        if options.bottom:
            options.top = False
        else:
            options.top = True

    self.client.activationkey.addConfigChannels(self.session, 
                                                key, 
                                                channels, 
                                                options.top)

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
    (args, options) = parse_arguments(args)

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
    (args, options) = parse_arguments(args)

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
    print '''usage: activationkey_create [options]

options:
  -n NAME
  -d DESCRIPTION
  -b BASE_CHANNEL
  -u set key as universal default
  -e [provisioning_entitled,enterprise_entitled,monitoring_entitled,
      virtualization_host,virtualization_host_platform]'''

def do_activationkey_create(self, args):
    options = [ Option('-n', '--name', action='store'),
                Option('-d', '--description', action='store'),
                Option('-b', '--base-channel', action='store'),
                Option('-e', '--entitlements', action='store'),
                Option('-u', '--universal', action='store_true') ]

    (args, options) = parse_arguments(args, options)

    if is_interactive(options):
        options.name = prompt_user('Name (blank to autogenerate):')
        options.description = prompt_user('Description [None]:')

        print
        print 'Base Channels'
        print '-------------'
        print '\n'.join(sorted(self.list_base_channels()))
        print

        options.base_channel = prompt_user('Base Channel (blank for default):')

        options.entitlements = []

        for e in self.ENTITLEMENTS:
            if e == 'enterprise_entitled': continue

            if self.user_confirm('%s Entitlement [y/N]:' % e,
                                 ignore_yes = True):
                options.entitlements.append(e)

        options.universal = self.user_confirm('Universal Default [y/N]:',
                                              ignore_yes = True)
    else:
        if not options.name: options.name = ''
        if not options.description: options.description = ''
        if not options.base_channel: options.base_channel = ''
        if not options.universal: options.universal = False
        if options.entitlements:
            options.entitlements = options.entitlements.split(',')

            # remove empty strings from the list
            try:
                options.entitlements.remove('')
            except:
                pass
        else:
            options.entitlements = []

    new_key = self.client.activationkey.create(self.session,
                                               options.name,
                                               options.description,
                                               options.base_channel,
                                               options.entitlements,
                                               options.universal)

    logging.info('Created activation key %s' % new_key)

####################

def help_activationkey_delete(self):
    print 'activationkey_delete: Delete an activation key'
    print 'usage: activationkey_delete KEY'

def complete_activationkey_delete(self, text, line, beg, end):
    return tab_completer(self.do_activationkey_list('', True), text)

def do_activationkey_delete(self, args):
    (args, options) = parse_arguments(args)

    if not len(args):
        self.help_activationkey_delete()
        return

    # allow globbing of activationkey names
    keys = filter_results(self.do_activationkey_list('', True), args)
    logging.debug("activationkey_delete called with args %s, keys=%s" % \
        (args,keys))

    if not len(keys):
        logging.error("No keys matched argument %s" % args)
        return

    # Print the keys prior to the confimation
    print '\n'.join(sorted(keys))

    if not self.user_confirm('Delete activation key(s) [y/N]:'): return

    for key in keys:
        logging.debug("Deleting key %s" % key)
        self.client.activationkey.delete(self.session, key)

####################

def help_activationkey_list(self):
    print 'activationkey_list: List all activation keys'
    print 'usage: activationkey_list'

def do_activationkey_list(self, args, doreturn = False):
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
    (args, options) = parse_arguments(args)

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
    (args, options) = parse_arguments(args)

    if not len(args):
        self.help_activationkey_details()
        return

    add_separator = False

    result = []
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

        result.append( 'Key:                    %s' % details.get('key') )
        result.append( 'Description:            %s' % details.get('description') )
        result.append( 'Universal Default:      %s' % details.get('universal_default') )
        result.append( 'Usage Limit:            %s' % details.get('usage_limit') )
        result.append( 'Deploy Config Channels: %s' % config_channel_deploy )

        result.append( '' )
        result.append( 'Software Channels' )
        result.append( '-----------------' )
        result.append( details.get('base_channel_label') )

        for channel in sorted(details.get('child_channel_labels')):
            result.append( ' |-- %s' % channel )

        result.append( '' )
        result.append( 'Configuration Channels' )
        result.append( '----------------------' )
        for channel in config_channels:
            result.append( channel.get('label') )

        result.append( '' )
        result.append( 'Entitlements' )
        result.append( '------------' )
        result.append( '\n'.join(sorted(details.get('entitlements'))) )

        result.append( '' )
        result.append( 'System Groups' )
        result.append( '-------------' )
        result.append( '\n'.join(sorted(groups)) )

        result.append( '' )
        result.append( 'Packages' )
        result.append( '--------' )
        for package in sorted(details.get('packages')):
            name = package.get('name')

            if package.get('arch'):
                name += '.%s' % package.get('arch')

            result.append( name )
    return result

####################

def help_activationkey_enableconfigdeployment(self):
    print 'activationkey_enableconfigdeployment: Enable config ' + \
          'channel deployment'
    print 'usage: activationkey_enableconfigdeployment KEY'

def complete_activationkey_enableconfigdeployment(self, text, line, beg, 
                                                  end):
    return tab_completer(self.do_activationkey_list('', True), text)

def do_activationkey_enableconfigdeployment(self, args):
    (args, options) = parse_arguments(args)

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
    (args, options) = parse_arguments(args)

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
    (args, options) = parse_arguments(args)

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

    # getDetails returns a usage_limit of 0 unlimited, which is then
    # interpreted literally as zero when passed into setDetails, doh!
    # Setting it to -1 seems to keep the usage limit unlimited
    if details['usage_limit'] == 0:
        details['usage_limit'] = -1

    self.client.activationkey.setDetails(self.session, key, details)

####################

def help_activationkey_setusagelimit(self):
    print 'activationkey_setusagelimit: Set the usage limit of an ' + \
          'activation key, can be a number or \"unlimited\"'
    print 'usage: activationkey_setbasechannel KEY <usage limit>'
    print 'usage: activationkey_setbasechannel KEY unlimited '

def complete_activationkey_setusagelimit(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_activationkey_list('', True), text)
    elif len(parts) > 2:
        return "unlimited"

def do_activationkey_setusagelimit(self, args):
    (args, options) = parse_arguments(args)

    if not len(args) >= 2:
        self.help_activationkey_setusagelimit()
        return

    key = args.pop(0)
    usage_limit = -1
    if args[0] == 'unlimited':
        logging.debug("Setting usage for key %s unlimited" % key)
    else:
        try:
            usage_limit = int(args[0])
            logging.debug("Setting usage for key %s to %d" % (key, usage_limit))
        except Exception, E:
            logging.error("Couldn't convert argument %s to an integer" %\
                args[0])
            self.help_activationkey_setusagelimit()
            return

    current_details = self.client.activationkey.getDetails(self.session,
                                                           key)
    details = { 'description' : current_details.get('description'),
                'base_channel_label' : \
                current_details.get('base_channel_label'),\
                'usage_limit' : usage_limit,\
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
    (args, options) = parse_arguments(args)

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

    # getDetails returns a usage_limit of 0 unlimited, which is then
    # interpreted literally as zero when passed into setDetails, doh!
    # Setting it to -1 seems to keep the usage limit unlimited
    if details['usage_limit'] == 0:
        details['usage_limit'] = -1

    self.client.activationkey.setDetails(self.session, key, details)

####################

def help_activationkey_export(self):
    print 'activationkey_export: Export activation key(s) to JSON format file'
    print '''usage: activationkey_export [options] [<KEY> ...]

options:
    -f outfile.json : specify an output filename, defaults to <KEY>.json
                      if exporting a single key, akeys.json for multiple keys,
                      or akey_all.json if no KEY specified (export ALL)

Note : KEY list is optional, default is to export ALL keys '''

def complete_activationkey_export(self, text, line, beg, end):
    return tab_completer(self.do_activationkey_list('', True), text)

def export_activationkey_getdetails(self, key):
    # Get the key details
    logging.info("Getting activation key details for %s" % key)
    details = self.client.activationkey.getDetails(self.session, key)

    # Get the key config-channel data, add it to the existing details
    logging.debug("activationkey.listConfigChannels %s" % key)
    ccdlist = []
    try:
        ccdlist = self.client.activationkey.listConfigChannels(self.session, \
            key)
    except Exception, E:
        logging.debug("activationkey.listConfigChannel threw an exeception, \
            probably not provisioning entitled, setting config_channels=False")

    cclist = [ c['label'] for c in ccdlist ]
    logging.debug("Got config channel label list of %s" % cclist)
    details['config_channels'] = cclist

    logging.debug("activationkey.checkConfigDeployment %s" % key) 
    details['config_deploy'] = \
        self.client.activationkey.checkConfigDeployment(self.session, key)

    # Get group details, as the server group IDs are not necessarily the same
    # across servers, so we need the group name on import
    details['server_groups'] = []
    if len(details['server_group_ids']) != 0:
        grp_detail_list=[]
        for grp in details['server_group_ids']:
            grp_details = self.client.systemgroup.getDetails(self.session, grp)

            if grp_details:
                grp_detail_list.append(grp_details)

        details['server_groups'] = [ g['name'] for g in grp_detail_list ]

    # Now append the details dict describing the key to the specified file
    return details

def do_activationkey_export(self, args):
    options = [ Option('-f', '--file', action='store') ]
    (args, options) = parse_arguments(args, options)

    filename=""
    if options.file != None:
        logging.debug("Passed filename do_activationkey_export %s" % \
            options.file)
        filename=options.file

    # Get the list of keys to export and sort out the filename if required
    keys=[]
    if not len(args):
        if len(filename) == 0:
            filename="akey_all.json"
        logging.info("Exporting ALL activation keys to %s" % filename)
        keys = self.do_activationkey_list('', True)
    else:
        # allow globbing of activationkey names
        keys = filter_results(self.do_activationkey_list('', True), args)
        logging.debug("activationkey_export called with args %s, keys=%s" % \
            (args, keys))

        if (len(keys) == 0):
            logging.error("Invalid activation key passed")
            return

        if len(filename) == 0:
            # No filename arg, so we try to do something sensible:
            # If we are exporting exactly one key, we default to keyname.json
            # otherwise, generic akeys.json name
            if len(keys) == 1:
                filename="%s.json" % keys[0]
            else:
                filename="akeys.json"

    # Dump as a list of dict
    keydetails_list=[]
    for k in keys:
        logging.info("Exporting key %s to %s" % (k, filename))
        keydetails_list.append(self.export_activationkey_getdetails(k))

    logging.debug("About to dump %d keys to %s" % \
        (len(keydetails_list), filename))

    # Check if filepath exists, if it is an existing file
    # we prompt the user for confirmation
    if os.path.isfile(filename):
        if not self.user_confirm("File %s exists, confirm overwrite file? (y/n)" % \
                    filename):
            return 

    if json_dump_to_file(keydetails_list, filename) != True:
        logging.error("Failed to save exported keys to file" % filename)
        return

####################

def help_activationkey_import(self):
    print 'activationkey_import: import activation key(s) from JSON file(s)'
    print '''usage: activationkey_import <JSONFILE ...>'''

def do_activationkey_import(self, args):
    (args, options) = parse_arguments(args)

    if len(args) == 0:
        logging.error("No filename passed")
        self.help_activationkey_import() 
        return

    for filename in args:
        logging.debug("Passed filename do_activationkey_import %s" % filename)
        keydetails_list = json_read_from_file(filename)

        if len(keydetails_list) == 0:
            logging.error("Could not read json data from %s" % filename)
            return

        for keydetails in keydetails_list:
            if self.import_activationkey_fromdetails(keydetails) != True:
                logging.error("Failed to import key %s" % \
                    keydetails['key'])

# create a new key based on the dict from export_activationkey_getdetails
def import_activationkey_fromdetails(self, keydetails):
    # First we check that an existing key with the same name does not exist
    existing_keys = self.do_activationkey_list('', True)

    if keydetails['key'] in existing_keys:
        logging.warning("%s already exists! Skipping!" % keydetails['key'])
        return False
    else:
        # create the key, we need to drop the org prefix from the key name
        keyname = re.sub('^[0-9]-', '', keydetails['key'])
        logging.debug("Found key %s, importing as %s" % \
            (keydetails['key'], keyname))

        # Channel label must be an empty-string for "RHN Satellite Default"
        # The export to json maps this to a unicode string "none"
        # To avoid changing the json format now, just fix it up here...
        if keydetails['base_channel_label'] == "none":
            keydetails['base_channel_label'] = ''

        if keydetails['usage_limit'] != 0:
            newkey = self.client.activationkey.create(self.session,
                                           keyname,
                                           keydetails['description'],
                                           keydetails['base_channel_label'],
                                           keydetails['usage_limit'],
                                           keydetails['entitlements'],
                                           keydetails['universal_default'])
        else:
            newkey = self.client.activationkey.create(self.session,
                                           keyname,
                                           keydetails['description'],
                                           keydetails['base_channel_label'],
                                           keydetails['entitlements'],
                                           keydetails['universal_default'])
        if len(newkey) == 0:
            logging.error("Failed to import key %s" % \
                keyname)
            return False

        # add child channels
        self.client.activationkey.addChildChannels(self.session, newkey,\
            keydetails['child_channel_labels'])

        # set config channel options and channels (missing are skipped)
        if keydetails['config_deploy'] != 0:
            self.client.activationkey.enableConfigDeployment(self.session,\
                newkey)
        else:
            self.client.activationkey.disableConfigDeployment(self.session,\
                newkey)

        if len(keydetails['config_channels']) > 0:
            self.client.activationkey.addConfigChannels(self.session, [newkey],\
                keydetails['config_channels'], False)

        # set groups (missing groups are created)
        gids = []
        for grp in keydetails['server_groups']:
            grpdetails = self.client.systemgroup.getDetails(self.session, grp)
            if grpdetails == None:
                logging.info("System group %s doesn't exist, creating" % grp)
                grpdetails = self.client.systemgroup.create(self.session, grp,\
                     grp)
            gids.append(grpdetails.get('id'))

        logging.debug("Adding groups %s to key %s" % (gids, newkey)) 
        self.client.activationkey.addServerGroups(self.session, newkey, gids)

        # Finally add the package list
        self.client.activationkey.addPackages(self.session, newkey, \
            keydetails['packages'])

        return True

####################

def help_activationkey_clone(self):
    print 'activationkey_clone: Clone an activation key'
    print '''usage examples:
                 activationkey_clone foo_key -c bar_key
                 activationkey_clone foo_key1 foo_key2 -c prefix
                 activationkey_clone foo_key -x "s/foo/bar"
                 activationkey_clone foo_key1 foo_key2 -x "s/foo/bar"

options:
  -c CLONE_NAME  : Name of the resulting key, treated as a prefix for multiple
                   keys
  -x "s/foo/bar" : Optional regex replacement, replaces foo with bar in the
                   clone description, base-channel label, child-channel
                   labels, config-channel names '''

def complete_activationkey_clone(self, text, line, beg, end):
    return tab_completer(self.do_activationkey_list('', True), text)

def do_activationkey_clone(self, args):
    options = [ Option('-c', '--clonename', action='store'),
                Option('-x', '--regex', action='store') ]

    (args, options) = parse_arguments(args, options)
    allkeys = self.do_activationkey_list('', True)

    if is_interactive(options):
        print
        print 'Activation Keys'
        print '------------------'
        print '\n'.join(sorted(allkeys))
        print

        if len(args) == 1:
            print "Key to clone: %s" % args[0]
        else:
            # Clear out any args as interactive doesn't handle multiple keys
            args = []
            args.append(prompt_user('Original Key:', noblank = True))

        options.clonename = prompt_user('Cloned Key:', noblank = True)
    else:
        if not options.clonename and not options.regex:
            logging.error("Error - must specify either -c or -x options!")
            self.help_activationkey_clone()
            return

    if options.clonename in allkeys:
        logging.error("Key %s already exists" % options.clonename)
        return

    if not len(args):
        logging.error("Error no activationkey to clone passed!")
        self.help_activationkey_clone()
        return

    logging.debug("Got args=%s %d" % (args, len(args)))
    # allow globbing of configchannel channel names
    akeys = filter_results(allkeys, args)
    logging.debug("Filtered akeys %s" % akeys)
    logging.debug("all akeys %s" % allkeys)
    for ak in akeys:
        logging.debug("Cloning %s" % ak)
        # Replace the key-name with the clonename specified by the user
        keydetails = self.export_activationkey_getdetails(ak)

        # If the -x/--regex option is passed, do a sed-style replacement over
        # everything contained by the key.  This makes it easier to clone when
        # content is based on a known naming convention
        if options.regex:
            # formatted like a sed-replacement, s/foo/bar
            findstr = options.regex.split("/")[1]
            replacestr = options.regex.split("/")[2]
            logging.debug("Regex option with %s, replacing %s with %s" % \
                (options.regex, findstr, replacestr))

            # First we do the key name
            newkey = re.sub(findstr, replacestr, keydetails['key'])
            keydetails['key'] = newkey

            # Then the description
            newdesc = re.sub(findstr, replacestr, keydetails['description'])
            keydetails['description'] = newdesc

            # Then the base-channel label
            newbasech = re.sub(findstr, replacestr, \
                keydetails['base_channel_label'])
            if newbasech in self.list_base_channels():
                keydetails['base_channel_label'] = newbasech
                # Now iterate over any child-channel labels
                # we have the new base-channel, we can check if the new child
                # label exists under the new base-channel:
                # If it doesn't we can only skip it and print a warning
                all_childch = self.list_child_channels(system=None,\
                    parent=newbasech, subscribed=False)

                new_child_channel_labels = []
                for c in keydetails['child_channel_labels']:
                    newc = re.sub(findstr, replacestr, c)
                    if newc in all_childch:
                        logging.debug("Found child channel %s for key %s, " % \
                             (c, keydetails['key']) + \
                             "replacing with %s" % newc)

                        new_child_channel_labels.append(newc)
                    else:
                        logging.warning("Found child channel %s key %s, %s" % \
                             (c, keydetails['key'], newc) + \
                             " does not exist, skipping!")

                logging.debug("Processed all child channels, " + \
                     "new_child_channel_labels=%s" % new_child_channel_labels)

                keydetails['child_channel_labels'] = new_child_channel_labels
            else:
                logging.error("Regex-replacement results in new " + \
                    "base-channel %s which does not exist!" % newbasech)

            # Finally, any config-channels
            new_config_channels = []
            allccs =  self.do_configchannel_list('', True)
            for cc in keydetails['config_channels']:
                newcc = re.sub(findstr, replacestr, cc)

                if newcc in allccs:
                    logging.debug("Found config channel %s for key %s, " % \
                        (cc, keydetails['key']) + \
                        "replacing with %s" % newcc)

                    new_config_channels.append(newcc)
                else:
                    logging.warning("Found config channel %s for key %s, %s " \
                         % (cc, keydetails['key'], newcc) + \
                        "does not exist, skipping!")

            logging.debug("Processed all config channels, " + \
                "new_config_channels = %s" % new_config_channels)

            keydetails['config_channels'] = new_config_channels

        # Not regex mode
        elif options.clonename:
            if len(akeys) > 1:
                # We treat the clonename as a prefix for multiple keys
                # However we need to insert the prefix after the org-
                newkey = re.sub(r'^([0-9]-)', r'\1' + options.clonename,
                    keydetails['key'])
                keydetails['key'] = newkey
            else:
                keydetails['key'] = options.clonename

        logging.info("Cloning key %s as %s" % (ak, keydetails['key']))

        # Finally : import the key from the modified keydetails dict
        if self.import_activationkey_fromdetails(keydetails) != True:
            logging.error("Failed to clone %s to %s" % \
             (ak, keydetails['key']))

####################
# activationkey helper

def is_activationkey( self, name ):
    if not name: return
    return name in self.do_activationkey_list( name, True )

def check_activationkey( self, name ):
    if not name:
        logging.error( "no activationkey label given" )
        return False
    if not self.is_activationkey( name ):
        logging.error( "invalid activationkey label " + name )
        return False
    return True

def dump_activationkey(self, name, replacedict=None, excludes=[ "Universal Default:" ]):
    content = self.do_activationkey_details( name )

    content = get_normalized_text( content, replacedict=replacedict, excludes=excludes )

    return content

####################

def help_activationkey_diff(self):
    print 'activationkeyt_diff: diff activationkeys'
    print ''
    print 'usage: activationkey_diff SOURCE_ACTIVATIONKEY TARGET_ACTIVATIONKEY'

def complete_activationkey_diff(self, text, line, beg, end):
    parts = shlex.split(line)
    if line[-1] == ' ': parts.append('')
    args = len(parts)

    if args == 2:
        return tab_completer(self.do_activationkey_list('', True), text)
    if args == 3:
        return tab_completer(self.do_activationkey_list('', True), text)
    return []

def do_activationkey_diff(self, args):
    options = []

    (args, options) = parse_arguments(args, options)

    if len(args) != 1 and len(args) != 2:
        self.help_activationkey_diff()
        return

    source_channel = args[0]
    if not self.check_activationkey( source_channel ): return

    target_channel = None
    if len(args) == 2:
        target_channel = args[1]
    elif hasattr( self, "do_activationkey_getcorresponding" ):
        # can a corresponding channel name be found automatically?
        target_channel=self.do_activationkey_getcorresponding( source_channel )
    if not self.check_activationkey( target_channel ): return

    source_replacedict, target_replacedict = get_string_diff_dicts( source_channel, target_channel )

    source_data = self.dump_activationkey( source_channel, source_replacedict )
    target_data = self.dump_activationkey( target_channel, target_replacedict )

    return diff( source_data, target_data, source_channel, target_channel )


# vim:ts=4:expandtab:
