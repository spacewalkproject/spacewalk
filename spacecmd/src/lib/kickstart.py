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
# Copyright (c) 2013--2017 Red Hat, Inc.
#

# NOTE: the 'self' variable is an instance of SpacewalkShell

# wildcard import
# pylint: disable=W0401,W0614

# unused argument
# pylint: disable=W0613

# invalid function name
# pylint: disable=C0103

from getpass import getpass
from operator import itemgetter
from optparse import Option
from urllib2 import urlopen, HTTPError
import re
import xmlrpclib
from spacecmd.utils import *

KICKSTART_OPTIONS = ['autostep', 'interactive', 'install', 'upgrade',
                     'text', 'network', 'cdrom', 'harddrive', 'nfs',
                     'url', 'lang', 'langsupport keyboard', 'mouse',
                     'device', 'deviceprobe', 'zerombr', 'clearpart',
                     'bootloader', 'timezone', 'auth', 'rootpw', 'selinux',
                     'reboot', 'firewall', 'xconfig', 'skipx', 'key',
                     'ignoredisk', 'autopart', 'cmdline', 'firstboot',
                     'graphical', 'iscsi', 'iscsiname', 'logging',
                     'monitor', 'multipath', 'poweroff', 'halt', 'service',
                     'shutdown', 'user', 'vnc', 'zfcp']

VIRT_TYPES = ['none', 'para_host', 'qemu', 'xenfv', 'xenpv']

UPDATE_TYPES = ['red_hat', 'all', 'none']


def help_kickstart_list(self):
    print('kickstart_list: List the available Kickstart profiles')
    print('usage: kickstart_list')


def do_kickstart_list(self, args, doreturn=False):
    kickstarts = self.client.kickstart.listKickstarts(self.session)
    kickstarts = [k.get('name') for k in kickstarts]

    if doreturn:
        return kickstarts
    else:
        if kickstarts:
            print('\n'.join(sorted(kickstarts)))

####################


def help_kickstart_create(self):
    print('kickstart_create: Create a Kickstart profile')
    print('''usage: kickstart_create [options])

options:
  -n NAME
  -d DISTRIBUTION
  -p ROOT_PASSWORD
  -v VIRT_TYPE ['none', 'para_host', 'qemu', 'xenfv', 'xenpv']''')


def do_kickstart_create(self, args):
    options = [Option('-n', '--name', action='store'),
               Option('-d', '--distribution', action='store'),
               Option('-v', '--virt-type', action='store'),
               Option('-p', '--root-password', action='store')]

    (args, options) = parse_arguments(args, options)

    if is_interactive(options):
        options.name = prompt_user('Name:', noblank=True)

        print('Virtualization Types')
        print('--------------------')
        print('\n'.join(sorted(self.VIRT_TYPES)))
        print()

        options.virt_type = prompt_user('Virtualization Type [none]:')
        if options.virt_type == '' or options.virt_type not in self.VIRT_TYPES:
            options.virt_type = 'none'

        options.distribution = ''
        while options.distribution == '':
            trees = self.do_distribution_list('', True)
            print()
            print('Distributions')
            print('-------------')
            print('\n'.join(sorted(trees)))
            print()

            options.distribution = prompt_user('Select:')

        options.root_password = ''
        while options.root_password == '':
            print()
            password1 = getpass('Root Password: ')
            password2 = getpass('Repeat Password: ')

            if password1 == password2:
                options.root_password = password1
            elif password1 == '':
                logging.warning('Password must be at least 5 characters')
            else:
                logging.warning("Passwords don't match")
    else:
        if not options.name:
            logging.error('The Kickstart name is required')
            return

        if not options.distribution:
            logging.error('The distribution is required')
            return

        if not options.virt_type:
            options.virt_type = 'none'

        if not options.root_password:
            logging.error('A root password is required')
            return

    # leave this blank to use the default server
    host = ''

    self.client.kickstart.createProfile(self.session,
                                        options.name,
                                        options.virt_type,
                                        options.distribution,
                                        host,
                                        options.root_password)

####################


def help_kickstart_delete(self):
    print('kickstart_delete: Delete kickstart profile(s)')
    print('usage: kickstart_delete PROFILE')
    print('usage: kickstart_delete PROFILE1 PROFILE2')
    print('usage: kickstart_delete \"PROF*\"')


def complete_kickstart_delete(self, text, line, beg, end):
    if len(line.split(' ')) <= 2:
        return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_delete(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) < 1:
        self.help_kickstart_delete()
        return

    # allow globbing of kickstart labels
    all_labels = self.do_kickstart_list('', True)
    labels = filter_results(all_labels, args)
    logging.debug("Got labels to delete of %s" % labels)

    if not labels:
        logging.error("No valid kickstart labels passed as arguments!")
        self.help_kickstart_delete()
        return

    for label in labels:
        if not label in all_labels:
            logging.error("kickstart label %s doesn't exist!" % label)
            continue

        if self.user_confirm("Delete profile %s [y/N]:" % label):
            self.client.kickstart.deleteProfile(self.session, label)

####################


def help_kickstart_import(self):
    print('kickstart_import: Import a Kickstart profile from a file')
    print('''usage: kickstart_import [options])

options:
  -f FILE
  -n NAME
  -d DISTRIBUTION
  -v VIRT_TYPE ['none', 'para_host', 'qemu', 'xenfv', 'xenpv']''')


def do_kickstart_import(self, args):
    self.kickstart_import_file(raw=False, args=args)


def kickstart_import_file(self, raw, args):
    options = [Option('-n', '--name', action='store'),
               Option('-d', '--distribution', action='store'),
               Option('-v', '--virt-type', action='store'),
               Option('-f', '--file', action='store')]

    (args, options) = parse_arguments(args, options)

    if is_interactive(options):
        options.name = prompt_user('Name:', noblank=True)
        options.file = prompt_user('File:', noblank=True)

        print('Virtualization Types')
        print('--------------------')
        print('\n'.join(sorted(self.VIRT_TYPES)))
        print()

        options.virt_type = prompt_user('Virtualization Type [none]:')
        if options.virt_type == '' or options.virt_type not in self.VIRT_TYPES:
            options.virt_type = 'none'

        options.distribution = ''
        while options.distribution == '':
            trees = self.do_distribution_list('', True)
            print()
            print('Distributions')
            print('-------------')
            print('\n'.join(sorted(trees)))
            print()

            options.distribution = prompt_user('Select:')
    else:
        if not options.name:
            logging.error('The Kickstart name is required')
            return

        if not options.distribution:
            logging.error('The distribution is required')
            return

        if not options.file:
            logging.error('A filename is required')
            return

        if not options.virt_type:
            options.virt_type = 'none'

    # read the contents of the Kickstart file
    options.contents = read_file(options.file)

    if raw:
        self.client.kickstart.importRawFile(self.session,
                                            options.name,
                                            options.virt_type,
                                            options.distribution,
                                            options.contents)
    else:
        # use the default server
        host = ''

        self.client.kickstart.importFile(self.session,
                                         options.name,
                                         options.virt_type,
                                         options.distribution,
                                         host,
                                         options.contents)

####################


def help_kickstart_import_raw(self):
    print('kickstart_import_raw: Import a raw Kickstart or autoyast profile from a file')
    print('''usage: kickstart_import_raw [options])

options:
  -f FILE
  -n NAME
  -d DISTRIBUTION
  -v VIRT_TYPE ['none', 'para_host', 'qemu', 'xenfv', 'xenpv']''')


def do_kickstart_import_raw(self, args):
    self.kickstart_import_file(raw=True, args=args)

####################


def help_kickstart_details(self):
    print('kickstart_details: Show the details of a Kickstart profile')
    print('usage: kickstart_details PROFILE')


def complete_kickstart_details(self, text, line, beg, end):
    if len(line.split(' ')) <= 2:
        return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_details(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) != 1:
        self.help_kickstart_details()
        return

    label = args[0]
    kickstart = None

    profiles = self.client.kickstart.listKickstarts(self.session)
    for p in profiles:
        if p.get('label') == label:
            kickstart = p
            break

    if not kickstart:
        logging.warning('Invalid Kickstart profile')
        return

    act_keys = \
        self.client.kickstart.profile.keys.getActivationKeys(self.session,
                                                             label)

    try:
        variables = self.client.kickstart.profile.getVariables(self.session,
                                                               label)
    except xmlrpclib.Fault:
        variables = {}

    tree = \
        self.client.kickstart.tree.getDetails(self.session,
                                              kickstart.get('tree_label'))

    base_channel = \
        self.client.channel.software.getDetails(self.session,
                                                tree.get('channel_id'))

    child_channels = \
        self.client.kickstart.profile.getChildChannels(self.session,
                                                       label)

    custom_options = \
        self.client.kickstart.profile.getCustomOptions(self.session,
                                                       label)

    advanced_options = \
        self.client.kickstart.profile.getAdvancedOptions(self.session,
                                                         label)

    config_manage = \
        self.client.kickstart.profile.system.checkConfigManagement(
            self.session, label)

    remote_commands = \
        self.client.kickstart.profile.system.checkRemoteCommands(
            self.session, label)

    partitions = \
        self.client.kickstart.profile.system.getPartitioningScheme(
            self.session, label)

    crypto_keys = \
        self.client.kickstart.profile.system.listKeys(self.session,
                                                      label)

    file_preservations = \
        self.client.kickstart.profile.system.listFilePreservations(
            self.session, label)

    software = self.client.kickstart.profile.software.getSoftwareList(
        self.session, label)

    scripts = self.client.kickstart.profile.listScripts(self.session,
                                                        label)

    result = []
    result.append('Name:        %s' % kickstart.get('name'))
    result.append('Label:       %s' % kickstart.get('label'))
    result.append('Tree:        %s' % kickstart.get('tree_label'))
    result.append('Active:      %s' % kickstart.get('active'))
    result.append('Advanced:    %s' % kickstart.get('advanced_mode'))
    result.append('Org Default: %s' % kickstart.get('org_default'))

    result.append('')
    result.append('Configuration Management: %s' % config_manage)
    result.append('Remote Commands:          %s' % remote_commands)

    result.append('')
    result.append('Software Channels')
    result.append('-----------------')
    result.append(base_channel.get('label'))

    for channel in sorted(child_channels):
        result.append('  |-- %s' % channel)

    if advanced_options:
        result.append('')
        result.append('Advanced Options')
        result.append('----------------')
        for o in sorted(advanced_options, key=itemgetter('name')):
            if o.get('arguments'):
                result.append('%s %s' % (o.get('name'), o.get('arguments')))

    if custom_options:
        result.append('')
        result.append('Custom Options')
        result.append('--------------')
        for o in sorted(custom_options, key=itemgetter('arguments')):
            result.append(re.sub('\n', '', o.get('arguments')))

    if partitions:
        result.append('')
        result.append('Partitioning')
        result.append('------------')
        result.append('\n'.join(partitions))

    result.append('')
    result.append('Software')
    result.append('--------')
    result.append('\n'.join(software))

    if act_keys:
        result.append('')
        result.append('Activation Keys')
        result.append('---------------')
        for k in sorted(act_keys, key=itemgetter('key')):
            result.append(k.get('key'))

    if crypto_keys:
        result.append('')
        result.append('Crypto Keys')
        result.append('-----------')
        for k in sorted(crypto_keys, key=itemgetter('description')):
            result.append(k.get('description'))

    if file_preservations:
        result.append('')
        result.append('File Preservations')
        result.append('------------------')
        for fp in sorted(file_preservations, key=itemgetter('name')):
            result.append(fp.get('name'))
            for profile_name in sorted(fp.get('file_names')):
                result.append('    |-- %s' % profile_name)

    if variables:
        result.append('')
        result.append('Variables')
        result.append('---------')
        for k in sorted(variables.keys()):
            result.append('%s = %s' % (k, str(variables[k])))

    if scripts:
        result.append('')
        result.append('Scripts')
        result.append('-------')

        add_separator = False

        for s in scripts:
            if add_separator:
                result.append(self.SEPARATOR)
            add_separator = True

            result.append('Type:        %s' % s.get('script_type'))
            result.append('Chroot:      %s' % s.get('chroot'))

            if s.get('interpreter'):
                result.append('Interpreter: %s' % s.get('interpreter'))

            result.append('')
            result.append(s.get('contents'))

    return result

####################


def kickstart_getcontents(self, profile):

    kickstart = None
    if self.check_api_version('10.11'):
        kickstart = self.client.kickstart.profile.downloadRenderedKickstart(
            self.session, profile)
    else:
        # old versions of th API don't return a rendered Kickstart,
        # so grab it in a hacky way
        url = 'http://%s/ks/cfg/label/%s' % (self.server, profile)

        try:
            logging.debug('Retrieving %s' % url)
            response = urlopen(url)
            kickstart = response.read()
        except HTTPError:
            logging.error('Could not retrieve the Kickstart file')

    return kickstart


def help_kickstart_getcontents(self):
    print('kickstart_getcontents: Show the contents of a Kickstart profile')
    print('                   as they would be presented to a client')
    print('usage: kickstart_getcontents LABEL')


def complete_kickstart_getcontents(self, text, line, beg, end):
    return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_getcontents(self, args):
    (args, _options) = parse_arguments(args)

    if not args:
        self.help_kickstart_getcontents()
        return

    profile = args[0]

    kickstart = self.kickstart_getcontents(profile)

    if kickstart:
        # We try to encode the output as UTF8, which is what we expect from
        # the API.  This avoids "'ascii' codec can't encode character" errors
        try:
            print(kickstart.encode('UTF8'))
        except UnicodeDecodeError:
            print(kickstart)

####################


def help_kickstart_rename(self):
    print('kickstart_rename: Rename a Kickstart profile')
    print('usage: kickstart_rename OLDNAME NEWNAME')


def complete_kickstart_rename(self, text, line, beg, end):
    if len(line.split(' ')) <= 2:
        return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_rename(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) != 2:
        self.help_kickstart_rename()
        return

    oldname = args[0]
    newname = args[1]

    self.client.kickstart.renameProfile(self.session, oldname, newname)

####################


def help_kickstart_listcryptokeys(self):
    print('kickstart_listcryptokeys: List the crypto keys associated ' +
          'with a Kickstart profile')
    print('usage: kickstart_listcryptokeys PROFILE')


def complete_kickstart_listcryptokeys(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_listcryptokeys(self, args, doreturn=False):
    (args, _options) = parse_arguments(args)

    if not args:
        self.help_kickstart_listcryptokeys()
        return

    profile = args[0]

    keys = self.client.kickstart.profile.system.listKeys(self.session,
                                                         profile)
    keys = [k.get('description') for k in keys]

    if doreturn:
        return keys
    else:
        if keys:
            print('\n'.join(sorted(keys)))

####################


def help_kickstart_addcryptokeys(self):
    print('kickstart_addcryptokeys: Add crypto keys to a Kickstart profile')
    print('usage: kickstart_addcryptokeys PROFILE <KEY ...>')


def complete_kickstart_addcryptokeys(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) > 2:
        return tab_completer(self.do_cryptokey_list('', True), text)


def do_kickstart_addcryptokeys(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) < 2:
        self.help_kickstart_addcryptokeys()
        return

    profile = args[0]
    keys = args[1:]

    self.client.kickstart.profile.system.addKeys(self.session,
                                                 profile,
                                                 keys)

####################


def help_kickstart_removecryptokeys(self):
    print('kickstart_removecryptokeys: Remove crypto keys from a ' +
          'Kickstart profile')
    print('usage: kickstart_removecryptokeys PROFILE <KEY ...>')


def complete_kickstart_removecryptokeys(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) > 2:
        # only tab complete keys currently assigned to the profile
        try:
            keys = self.do_kickstart_listcryptokeys(parts[1], True)
        except xmlrpclib.Fault:
            keys = []

        return tab_completer(keys, text)


def do_kickstart_removecryptokeys(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) < 2:
        self.help_kickstart_removecryptokeys()
        return

    profile = args[0]
    keys = args[1:]

    self.client.kickstart.profile.system.removeKeys(self.session,
                                                    profile,
                                                    keys)

####################


def help_kickstart_listactivationkeys(self):
    print('kickstart_listactivationkeys: List the activation keys ' +
          'associated with a Kickstart profile')
    print('usage: kickstart_listactivationkeys PROFILE')


def complete_kickstart_listactivationkeys(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_listactivationkeys(self, args, doreturn=False):
    (args, _options) = parse_arguments(args)

    if not args:
        self.help_kickstart_listactivationkeys()
        return

    profile = args[0]

    keys = \
        self.client.kickstart.profile.keys.getActivationKeys(self.session,
                                                             profile)

    keys = [k.get('key') for k in keys]

    if doreturn:
        return keys
    else:
        if keys:
            print('\n'.join(sorted(keys)))

####################


def help_kickstart_addactivationkeys(self):
    print('kickstart_addactivationkeys: Add activation keys to a ' +
          'Kickstart profile')
    print('usage: kickstart_addactivationkeys PROFILE <KEY ...>')


def complete_kickstart_addactivationkeys(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) > 2:
        return tab_completer(self.do_activationkey_list('', True),
                             text)


def do_kickstart_addactivationkeys(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) < 2:
        self.help_kickstart_addactivationkeys()
        return

    profile = args[0]
    keys = args[1:]

    for key in keys:
        self.client.kickstart.profile.keys.addActivationKey(self.session,
                                                            profile,
                                                            key)

####################


def help_kickstart_removeactivationkeys(self):
    print('kickstart_removeactivationkeys: Remove activation keys from ' +
          'a Kickstart profile')
    print('usage: kickstart_removeactivationkeys PROFILE <KEY ...>')


def complete_kickstart_removeactivationkeys(self, text, line, beg,
                                            end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) > 2:
        # only tab complete keys currently assigned to the profile
        try:
            keys = self.do_kickstart_listactivationkeys(parts[1], True)
        except xmlrpclib.Fault:
            keys = []

        return tab_completer(keys, text)


def do_kickstart_removeactivationkeys(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) < 2:
        self.help_kickstart_removeactivationkeys()
        return

    profile = args[0]
    keys = args[1:]

    if not self.user_confirm('Remove these keys [y/N]:'):
        return

    for key in keys:
        self.client.kickstart.profile.keys.removeActivationKey(self.session,
                                                               profile,
                                                               key)

####################


def help_kickstart_enableconfigmanagement(self):
    print('kickstart_enableconfigmanagement: Enable configuration ' +
          'management on a Kickstart profile')
    print('usage: kickstart_enableconfigmanagement PROFILE')


def complete_kickstart_enableconfigmanagement(self, text, line, beg,
                                              end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_enableconfigmanagement(self, args):
    (args, _options) = parse_arguments(args)

    if not args:
        self.help_kickstart_enableconfigmanagement()
        return

    profile = args[0]

    self.client.kickstart.profile.system.enableConfigManagement(
        self.session, profile)

####################


def help_kickstart_disableconfigmanagement(self):
    print('kickstart_disableconfigmanagement: Disable configuration ' +
          'management on a Kickstart profile')
    print('usage: kickstart_disableconfigmanagement PROFILE')


def complete_kickstart_disableconfigmanagement(self, text, line, beg,
                                               end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_disableconfigmanagement(self, args):
    (args, _options) = parse_arguments(args)

    if not args:
        self.help_kickstart_disableconfigmanagement()
        return

    profile = args[0]

    self.client.kickstart.profile.system.disableConfigManagement(
        self.session, profile)

####################


def help_kickstart_enableremotecommands(self):
    print('kickstart_enableremotecommands: Enable remote commands ' +
          'on a Kickstart profile')
    print('usage: kickstart_enableremotecommands PROFILE')


def complete_kickstart_enableremotecommands(self, text, line, beg,
                                            end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_enableremotecommands(self, args):
    (args, _options) = parse_arguments(args)

    if not args:
        self.help_kickstart_enableremotecommands()
        return

    profile = args[0]

    self.client.kickstart.profile.system.enableRemoteCommands(self.session,
                                                              profile)

####################


def help_kickstart_disableremotecommands(self):
    print('kickstart_disableremotecommands: Disable remote commands ' +
          'on a Kickstart profile')
    print('usage: kickstart_disableremotecommands PROFILE')


def complete_kickstart_disableremotecommands(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_disableremotecommands(self, args):
    (args, _options) = parse_arguments(args)

    if not args:
        self.help_kickstart_disableremotecommands()
        return

    profile = args[0]

    self.client.kickstart.profile.system.disableRemoteCommands(self.session,
                                                               profile)

####################


def help_kickstart_setlocale(self):
    print('kickstart_setlocale: Set the locale for a Kickstart profile')
    print('usage: kickstart_setlocale PROFILE LOCALE')


def complete_kickstart_setlocale(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) == 3:
        return tab_completer(list_locales(), text)


def do_kickstart_setlocale(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) != 2:
        self.help_kickstart_setlocale()
        return

    profile = args[0]
    locale = args[1]

    # always use UTC
    utc = True

    self.client.kickstart.profile.system.setLocale(self.session,
                                                   profile,
                                                   locale,
                                                   utc)

####################


def help_kickstart_setselinux(self):
    print('kickstart_setselinux: Set the SELinux mode for a Kickstart ' +
          'profile')
    print('usage: kickstart_setselinux PROFILE MODE')


def complete_kickstart_setselinux(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) == 3:
        modes = ['enforcing', 'permissive', 'disabled']
        return tab_completer(modes, text)


def do_kickstart_setselinux(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) != 2:
        self.help_kickstart_setselinux()
        return

    profile = args[0]
    mode = args[1]

    self.client.kickstart.profile.system.setSELinux(self.session,
                                                    profile,
                                                    mode)

####################


def help_kickstart_setpartitions(self):
    print('kickstart_setpartitions: Set the partitioning scheme for a ' +
          'Kickstart profile')
    print('usage: kickstart_setpartitions PROFILE')


def complete_kickstart_setpartitions(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_setpartitions(self, args):
    (args, _options) = parse_arguments(args)

    if not args:
        self.help_kickstart_setpartitions()
        return

    profile = args[0]

    try:
        # get the current scheme so the user can edit it
        current = \
            self.client.kickstart.profile.system.getPartitioningScheme(
                self.session, profile)

        template = '\n'.join(current)
    except xmlrpclib.Fault:
        template = ''

    (partitions, _ignore) = editor(template=template, delete=True)

    print(partitions)
    if not self.user_confirm():
        return

    lines = partitions.split('\n')

    self.client.kickstart.profile.system.setPartitioningScheme(self.session,
                                                               profile,
                                                               lines)

####################


def help_kickstart_setdistribution(self):
    print('kickstart_setdistribution: Set the distribution for a ' +
          'Kickstart profile')
    print('usage: kickstart_setdistribution PROFILE DISTRIBUTION')


def complete_kickstart_setdistribution(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) == 3:
        return tab_completer(self.do_distribution_list('', True), text)


def do_kickstart_setdistribution(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) != 2:
        self.help_kickstart_setdistribution()
        return

    profile = args[0]
    distribution = args[1]

    self.client.kickstart.profile.setKickstartTree(self.session,
                                                   profile,
                                                   distribution)

####################


def help_kickstart_enablelogging(self):
    print('kickstart_enablelogging: Enable logging for a Kickstart profile')
    print('usage: kickstart_enablelogging PROFILE')


def complete_kickstart_enablelogging(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_enablelogging(self, args):
    (args, _options) = parse_arguments(args)

    if not args:
        self.help_kickstart_enablelogging()
        return

    profile = args[0]

    self.client.kickstart.profile.setLogging(self.session,
                                             profile,
                                             True,
                                             True)

####################


def help_kickstart_addvariable(self):
    print('kickstart_addvariable: Add a variable to a Kickstart profile')
    print('usage: kickstart_addvariable PROFILE KEY VALUE')


def complete_kickstart_addvariable(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_addvariable(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) < 3:
        self.help_kickstart_addvariable()
        return

    profile = args[0]
    key = args[1]
    value = ' '.join(args[2:])

    variables = self.client.kickstart.profile.getVariables(self.session,
                                                           profile)

    variables[key] = value

    self.client.kickstart.profile.setVariables(self.session,
                                               profile,
                                               variables)

####################


def help_kickstart_updatevariable(self):
    print('kickstart_updatevariable: Update a variable in a Kickstart ' +
          'profile')
    print('usage: kickstart_updatevariable PROFILE KEY VALUE')


def complete_kickstart_updatevariable(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) > 2:
        variables = {}
        try:
            variables = \
                self.client.kickstart.profile.getVariables(self.session,
                                                           parts[1])
        except xmlrpclib.Fault:
            pass

        return tab_completer(variables.keys(), text)


def do_kickstart_updatevariable(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) < 3:
        self.help_kickstart_updatevariable()
        return

    return self.do_kickstart_addvariable(' '.join(args))

####################


def help_kickstart_removevariables(self):
    print('kickstart_removevariables: Remove variables from a ' +
          'Kickstart profile')
    print('usage: kickstart_removevariables PROFILE <KEY ...>')


def complete_kickstart_removevariables(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) > 2:
        variables = {}
        try:
            variables = \
                self.client.kickstart.profile.getVariables(self.session,
                                                           parts[1])
        except xmlrpclib.Fault:
            pass

        return tab_completer(variables.keys(), text)


def do_kickstart_removevariables(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) < 2:
        self.help_kickstart_removevariables()
        return

    profile = args[0]
    keys = args[1:]

    variables = self.client.kickstart.profile.getVariables(self.session,
                                                           profile)

    for key in keys:
        if key in variables:
            del variables[key]

    self.client.kickstart.profile.setVariables(self.session,
                                               profile,
                                               variables)

####################


def help_kickstart_listvariables(self):
    print('kickstart_listvariables: List the variables of a Kickstart ' +
          'profile')
    print('usage: kickstart_listvariables PROFILE')


def complete_kickstart_listvariables(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_listvariables(self, args):
    (args, _options) = parse_arguments(args)

    if not args:
        self.help_kickstart_listvariables()
        return

    profile = args[0]

    variables = self.client.kickstart.profile.getVariables(self.session,
                                                           profile)

    for v in variables:
        print('%s = %s' % (v, variables[v]))

####################


def help_kickstart_addoption(self):
    print('kickstart_addoption: Set an option for a Kickstart profile')
    print('usage: kickstart_addoption PROFILE KEY [VALUE]')


def complete_kickstart_addoption(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) == 3:
        return tab_completer(sorted(self.KICKSTART_OPTIONS), text)


def do_kickstart_addoption(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) < 2:
        self.help_kickstart_addoption()
        return

    profile = args[0]
    key = args[1]

    if len(args) > 2:
        value = ' '.join(args[2:])
    else:
        value = ''

    # only pre-defined options can be set as 'advanced options'
    if key in self.KICKSTART_OPTIONS:
        advanced = \
            self.client.kickstart.profile.getAdvancedOptions(self.session,
                                                             profile)

        # remove any instances of this key from the current list
        for item in advanced:
            if item.get('name') == key:
                advanced.remove(item)
                break

        advanced.append({'name': key, 'arguments': value})

        self.client.kickstart.profile.setAdvancedOptions(self.session,
                                                         profile,
                                                         advanced)
    else:
        logging.warning('%s needs to be set as a custom option' % key)
        return

####################


def help_kickstart_removeoptions(self):
    print('kickstart_removeoptions: Remove options from a Kickstart profile')
    print('usage: kickstart_removeoptions PROFILE <OPTION ...>')


def complete_kickstart_removeoptions(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) > 2:
        try:
            options = self.client.kickstart.profile.getAdvancedOptions(
                self.session, parts[1])

            options = [o.get('name') for o in options]
        except xmlrpclib.Fault:
            options = self.KICKSTART_OPTIONS

        return tab_completer(sorted(options), text)


def do_kickstart_removeoptions(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) < 2:
        self.help_kickstart_removeoptions()
        return

    profile = args[0]
    keys = args[1:]

    advanced = \
        self.client.kickstart.profile.getAdvancedOptions(self.session,
                                                         profile)

    # remove any instances of this key from the current list
    for key in keys:
        for item in advanced:
            if item.get('name') == key:
                advanced.remove(item)

    self.client.kickstart.profile.setAdvancedOptions(self.session,
                                                     profile,
                                                     advanced)

####################


def help_kickstart_listoptions(self):
    print('kickstart_listoptions: List the options of a Kickstart ' +
          'profile')
    print('usage: kickstart_listoptions PROFILE')


def complete_kickstart_listoptions(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_listoptions(self, args):
    (args, options) = parse_arguments(args)

    if not args:
        self.help_kickstart_listoptions()
        return

    profile = args[0]

    options = self.client.kickstart.profile.getAdvancedOptions(self.session,
                                                               profile)

    for o in sorted(options, key=itemgetter('name')):
        if o.get('arguments'):
            print('%s %s' % (o.get('name'), o.get('arguments')))

####################


def help_kickstart_listcustomoptions(self):
    print('kickstart_listcustomoptions: List the custom options of a ' +
          'Kickstart profile')
    print('usage: kickstart_listcustomoptions PROFILE')


def complete_kickstart_listcustomoptions(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_listcustomoptions(self, args):
    (args, options) = parse_arguments(args)

    if not args:
        self.help_kickstart_listcustomoptions()
        return

    profile = args[0]

    options = self.client.kickstart.profile.getCustomOptions(self.session,
                                                             profile)

    for o in options:
        if 'arguments' in o:
            print(o.get('arguments'))

####################


def help_kickstart_setcustomoptions(self):
    print('kickstart_setcustomoptions: Set custom options for a ' +
          'Kickstart profile')
    print('usage: kickstart_setcustomoptions PROFILE')


def complete_kickstart_setcustomoptions(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_setcustomoptions(self, args):
    (args, options) = parse_arguments(args)

    if not args:
        self.help_kickstart_setcustomoptions()
        return

    profile = args[0]

    options = self.client.kickstart.profile.getCustomOptions(self.session,
                                                             profile)

    # the first item in the list is missing the 'arguments' key
    old_options = []
    for o in options:
        if 'arguments' in o:
            old_options.append(o.get('arguments'))

    old_options = '\n'.join(old_options)

    # let the user edit the custom options
    (new_options, _ignore) = editor(template=old_options,
                                    delete=True)

    new_options = new_options.split('\n')

    self.client.kickstart.profile.setCustomOptions(self.session,
                                                   profile,
                                                   new_options)

####################


def help_kickstart_addchildchannels(self):
    print('kickstart_addchildchannels: Add a child channels to a ' +
          'Kickstart profile')
    print('usage: kickstart_addchildchannels PROFILE <CHANNEL ...>')


def complete_kickstart_addchildchannels(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) > 2:
        profile = parts[1]

        try:
            tree = \
                self.client.kickstart.profile.getKickstartTree(self.session,
                                                               profile)

            tree_details = self.client.kickstart.tree.getDetails(
                self.session, tree)

            base_channel = \
                self.client.channel.software.getDetails(self.session,
                                                        tree_details.get('channel_id'))

            parent_channel = base_channel.get('label')
        except xmlrpclib.Fault:
            return []

        return tab_completer(self.list_child_channels(
            parent=parent_channel), text)


def do_kickstart_addchildchannels(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) < 2:
        self.help_kickstart_addchildchannels()
        return

    profile = args[0]
    new_channels = args[1:]

    channels = self.client.kickstart.profile.getChildChannels(self.session,
                                                              profile)

    channels.extend(new_channels)

    self.client.kickstart.profile.setChildChannels(self.session,
                                                   profile,
                                                   channels)

####################


def help_kickstart_removechildchannels(self):
    print('kickstart_removechildchannels: Remove child channels from ' +
          'a Kickstart profile')
    print('usage: kickstart_removechildchannels PROFILE <CHANNEL ...>')


def complete_kickstart_removechildchannels(self, text, line, beg,
                                           end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) > 2:
        return tab_completer(self.do_kickstart_listchildchannels(
            parts[1], True), text)


def do_kickstart_removechildchannels(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) < 2:
        self.help_kickstart_removechildchannels()
        return

    profile = args[0]
    to_remove = args[1:]

    channels = self.client.kickstart.profile.getChildChannels(self.session,
                                                              profile)

    for channel in to_remove:
        if channel in channels:
            channels.remove(channel)

    self.client.kickstart.profile.setChildChannels(self.session,
                                                   profile,
                                                   channels)

####################


def help_kickstart_listchildchannels(self):
    print('kickstart_listchildchannels: List the child channels of a ' +
          'Kickstart profile')
    print('usage: kickstart_listchildchannels PROFILE')


def complete_kickstart_listchildchannels(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_listchildchannels(self, args, doreturn=False):
    (args, _options) = parse_arguments(args)

    if not args:
        self.help_kickstart_listchildchannels()
        return

    profile = args[0]

    channels = self.client.kickstart.profile.getChildChannels(self.session,
                                                              profile)

    if doreturn:
        return channels
    else:
        if channels:
            print('\n'.join(sorted(channels)))

####################


def help_kickstart_addfilepreservations(self):
    print('kickstart_addfilepreservations: Add file preservations to a ' +
          'Kickstart profile')
    print('usage: kickstart_addfilepreservations PROFILE <FILELIST ...>')


def complete_kickstart_addfilepreservations(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) == 3:
        return tab_completer(self.do_filepreservation_list('', True),
                             text)


def do_kickstart_addfilepreservations(self, args):
    (args, _options) = parse_arguments(args)

    if not args:
        self.help_kickstart_addfilepreservations()
        return

    profile = args[0]
    files = args[1:]

    self.client.kickstart.profile.system.addFilePreservations(self.session,
                                                              profile,
                                                              files)

####################


def help_kickstart_removefilepreservations(self):
    print('kickstart_removefilepreservations: Remove file ' +
          'preservations from a Kickstart profile')
    print('usage: kickstart_removefilepreservations PROFILE <FILE ...>')


def complete_kickstart_removefilepreservations(self, text, line, beg,
                                               end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) > 2:
        files = []

        try:
            # only tab complete files currently assigned to the profile
            files = \
                self.client.kickstart.profile.system.listFilePreservations(
                    self.session, parts[1])
            files = [f.get('name') for f in files]
        except xmlrpclib.Fault:
            return []

        return tab_completer(files, text)


def do_kickstart_removefilepreservations(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) < 2:
        self.help_kickstart_removefilepreservations()
        return

    profile = args[0]
    files = args[1:]

    self.client.kickstart.profile.system.removeFilePreservations(
        self.session, profile, files)

####################


def help_kickstart_listpackages(self):
    print('kickstart_listpackages: List the packages for a Kickstart ' +
          'profile')
    print('usage: kickstart_listpackages PROFILE')


def complete_kickstart_listpackages(self, text, line, beg, end):
    return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_listpackages(self, args, doreturn=False):
    (args, _options) = parse_arguments(args)

    if not args:
        self.help_kickstart_listpackages()
        return

    profile = args[0]

    packages = \
        self.client.kickstart.profile.software.getSoftwareList(self.session,
                                                               profile)

    if doreturn:
        return packages
    else:
        if packages:
            print('\n'.join(packages))

####################


def help_kickstart_addpackages(self):
    print('kickstart_addpackages: Add packages to a Kickstart profile')
    print('usage: kickstart_addpackages PROFILE <PACKAGE ...>')


def complete_kickstart_addpackages(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) > 2:
        return tab_completer(self.get_package_names(), text)


def do_kickstart_addpackages(self, args):
    (args, _options) = parse_arguments(args)

    if not len(args) >= 2:
        self.help_kickstart_addpackages()
        return

    profile = args[0]
    packages = args[1:]

    self.client.kickstart.profile.software.appendToSoftwareList(
        self.session, profile, packages)

####################


def help_kickstart_removepackages(self):
    print('kickstart_removepackages: Remove packages from a Kickstart ' +
          'profile')
    print('usage: kickstart_removepackages PROFILE <PACKAGE ...>')


def complete_kickstart_removepackages(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True),
                             text)
    elif len(parts) > 2:
        return tab_completer(self.do_kickstart_listpackages(
            parts[1], True), text)


def do_kickstart_removepackages(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) < 2:
        self.help_kickstart_removepackages()
        return

    profile = args[0]
    to_remove = args[1:]

    # setSoftwareList requires a new list of packages, so grab
    # the old list and remove the list of packages from the user
    packages = self.do_kickstart_listpackages(profile, True)
    for package in to_remove:
        if package in packages:
            packages.remove(package)

    self.client.kickstart.profile.software.setSoftwareList(self.session,
                                                           profile,
                                                           packages)

####################


def help_kickstart_listscripts(self):
    print('kickstart_listscripts: List the scripts for a Kickstart ' +
          'profile')
    print('usage: kickstart_listscripts PROFILE')


def complete_kickstart_listscripts(self, text, line, beg, end):
    return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_listscripts(self, args):
    (args, _options) = parse_arguments(args)

    if not args:
        self.help_kickstart_listscripts()
        return

    profile = args[0]

    scripts = \
        self.client.kickstart.profile.listScripts(self.session, profile)

    add_separator = False

    for script in scripts:
        if add_separator:
            print(self.SEPARATOR)
        add_separator = True

        print('ID:          %i' % script.get('id'))
        print('Type:        %s' % script.get('script_type'))
        print('Chroot:      %s' % script.get('chroot'))
        print('Interpreter: %s' % script.get('interpreter'))
        print()
        print('Contents')
        print('--------')
        print(script.get('contents'))

####################


def help_kickstart_addscript(self):
    print('kickstart_addscript: Add a script to a Kickstart profile')
    print('''usage: kickstart_addscript PROFILE [options])

options:
  -p PROFILE
  -e EXECUTION_TIME ['pre', 'post']
  -i INTERPRETER
  -f FILE
  -c execute in a chroot environment
  -t ENABLING_TEMPLATING''')


def complete_kickstart_addscript(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_addscript(self, args):
    options = [Option('-p', '--profile', action='store'),
               Option('-e', '--execution-time', action='store'),
               Option('-c', '--chroot', action='store_true'),
               Option('-t', '--template', action='store_true'),
               Option('-i', '--interpreter', action='store'),
               Option('-f', '--file', action='store')]

    (args, options) = parse_arguments(args, options)

    if is_interactive(options):
        if args:
            options.profile = args[0]
        else:
            options.profile = prompt_user('Profile Name:', noblank=True)

        options.execution_time = prompt_user('Pre/Post Script [post]:')
        options.chroot = prompt_user('Chrooted [Y/n]:')
        options.interpreter = prompt_user('Interpreter [/bin/bash]:')

        # get the contents of the script
        if self.user_confirm('Read an existing file [y/N]:',
                             nospacer=True, ignore_yes=True):
            options.file = prompt_user('File:')
        else:
            (options.contents, _ignore) = editor(delete=True)

        # check user input
        if options.interpreter == '':
            options.interpreter = '/bin/bash'

        if re.match('n', options.chroot, re.I):
            options.chroot = False
        else:
            options.chroot = True

        if re.match('n', options.template, re.I):
            options.template = False
        else:
            options.template = True

        if re.match('pre', options.execution_time, re.I):
            options.execution_time = 'pre'
        else:
            options.execution_time = 'post'
    else:
        if not options.profile:
            logging.error('The Kickstart name is required')
            return

        if not options.file:
            logging.error('A filename is required')
            return

        if not options.execution_time:
            logging.error('The execution time is required')
            return

        if not options.chroot:
            options.chroot = False

        if not options.interpreter:
            options.interpreter = '/bin/bash'

        if not options.template:
            options.template = False

    if options.file:
        options.contents = read_file(options.file)

    print()
    print('Profile Name:   %s' % options.profile)
    print('Execution Time: %s' % options.execution_time)
    print('Chroot:         %s' % options.chroot)
    print('Template:       %s' % options.template)
    print('Interpreter:    %s' % options.interpreter)
    print('Contents:')
    print(options.contents)

    if not self.user_confirm():
        return

    self.client.kickstart.profile.addScript(self.session,
                                            options.profile,
                                            options.contents,
                                            options.interpreter,
                                            options.execution_time,
                                            options.chroot,
                                            options.template)

####################


def help_kickstart_removescript(self):
    print('kickstart_removescript: Remove a script from a Kickstart profile')
    print('usage: kickstart_removescript PROFILE [ID]')


def complete_kickstart_removescript(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_removescript(self, args):
    (args, _options) = parse_arguments(args)

    if not args:
        self.help_kickstart_removescript()
        return

    profile = args[0]

    script_id = 0

    # allow a script ID to be passed in
    if len(args) == 2:
        try:
            script_id = int(args[1])
        except ValueError:
            logging.error('Invalid script ID')

    # print(the scripts for the user to review)
    self.do_kickstart_listscripts(profile)

    if not script_id:
        while script_id == 0:
            print()
            userinput = prompt_user('Script ID:', noblank=True)

            try:
                script_id = int(userinput)
            except ValueError:
                logging.error('Invalid script ID')

    if not self.user_confirm('Remove this script [y/N]:'):
        return

    self.client.kickstart.profile.removeScript(self.session,
                                               profile,
                                               script_id)

####################


def help_kickstart_clone(self):
    print('kickstart_clone: Clone a Kickstart profile')
    print('''usage: kickstart_clone [options])

options:
  -n NAME
  -c CLONE_NAME''')


def complete_kickstart_clone(self, text, line, beg, end):
    return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_clone(self, args):
    options = [Option('-n', '--name', action='store'),
               Option('-c', '--clonename', action='store')]

    (args, options) = parse_arguments(args, options)

    if is_interactive(options):
        profiles = self.do_kickstart_list('', True)
        print()
        print('Kickstart Profiles')
        print('------------------')
        print('\n'.join(sorted(profiles)))
        print()

        options.name = prompt_user('Original Profile:', noblank=True)

        options.clonename = prompt_user('Cloned Profile:', noblank=True)
    else:

        if not options.name:
            logging.error('The Kickstart name is required')
            return

        if not options.clonename:
            logging.error('The Kickstart clone name is required')
            return

    self.client.kickstart.cloneProfile(self.session,
                                       options.name,
                                       options.clonename)

####################


def help_kickstart_export(self):
    print('kickstart_export: export kickstart profile(s) to json format file')
    print('''usage: kickstart_export <KSPROFILE>... [options])
options:
    -f outfile.json : specify an output filename, defaults to <KSPROFILE>.json
                      if exporting a single kickstart, profiles.json for multiple
                      kickstarts, or ks_all.json if no KSPROFILE specified
                      e.g (export ALL)

Note : KSPROFILE list is optional, default is to export ALL''')


def complete_kickstart_export(self, text, line, beg, end):
    return tab_completer(self.do_kickstart_list('', True), text)


def export_kickstart_getdetails(self, profile, kickstarts):

    # Get the initial ks details struct from the kickstarts list-of-struct,
    # which is returned from kickstart.listKickstarts()
    logging.debug("Getting kickstart profile details for %s" % profile)
    details = None
    for k in kickstarts:
        if k.get('label') == profile:
            details = k
            break
    logging.debug("Got basic details for %s : %s" % (profile, details))

    # Now use the various other API functions to build up a more complete
    # details struct for export.  Note there are a some ommisions from the API
    # e.g the "template" option which enables cobbler templating on scripts
    details['child_channels'] = \
        self.client.kickstart.profile.getChildChannels(self.session, profile)
    details['advanced_opts'] = \
        self.client.kickstart.profile.getAdvancedOptions(self.session, profile)
    details['software_list'] = \
        self.client.kickstart.profile.software.getSoftwareList(self.session,
                                                               profile)
    details['custom_opts'] = \
        self.client.kickstart.profile.getCustomOptions(self.session, profile)
    details['script_list'] = \
        self.client.kickstart.profile.listScripts(self.session, profile)
    details['ip_ranges'] = \
        self.client.kickstart.profile.listIpRanges(self.session, profile)
    logging.debug("About to get variable_list for %s" % profile)
    details['variable_list'] = \
        self.client.kickstart.profile.getVariables(self.session, profile)
    logging.debug("done variable_list for %s = %s" % (profile,
                                                      details['variable_list']))
    # just export the key names, then look for one with the same name on import
    details['activation_keys'] = [k['key'] for k in
                                  self.client.kickstart.profile.keys.getActivationKeys(self.session,
                                                                                       profile)]
    details['partitioning_scheme'] = \
        self.client.kickstart.profile.system.getPartitioningScheme(
            self.session, profile)
    if self.check_api_version('10.11'):
        details['reg_type'] = \
            self.client.kickstart.profile.system.getRegistrationType(self.session,
                                                                     profile)
    else:
        details['reg_type'] = "none"
    details['config_mgmt'] = \
        self.client.kickstart.profile.system.checkConfigManagement(
            self.session, profile)
    details['remote_cmds'] = \
        self.client.kickstart.profile.system.checkRemoteCommands(
            self.session, profile)
    # Just export the file preservation list names, then look for one with the
    # same name on import
    details['file_preservations'] = [
        f['name'] for f in self.client.kickstart.profile.system.listFilePreservations(
            self.session, profile)]
    # just export the key description/names , then look for one with the same
    # name on import
    details['gpg_ssl_keys'] = [k['description'] for k in
                               self.client.kickstart.profile.system.listKeys(self.session, profile)]

    # There's a setLogging() but no getLogging(), so we look in the rendered
    # kickstart to figure out if pre/post logging is enabled
    kscontents = self.kickstart_getcontents(profile)
    if re.search("pre --logfile", kscontents):
        logging.debug("Detected pre script logging")
        details['pre_logging'] = True
    else:
        details['pre_logging'] = False
    if re.search("post --logfile", kscontents):
        logging.debug("Detected post script logging")
        details['post_logging'] = True
    else:
        details['post_logging'] = False

    # There's also no way to get the "Kernel Options" and "Post Kernel Options"
    # The Post options can be derived from the grubby --default-kernel` --args
    # line in the kickstart, ugly but at least we can then show some of what's
    # missing in the warnings that get printed on import
    if re.search("`/sbin/grubby --default-kernel` --args=", kscontents):
        post_kopts = \
            kscontents.split("`/sbin/grubby --default-kernel` --args=")[1].\
            split("\"")[1]
        logging.debug("Post kernel options %s detected" % post_kopts)
        details['post_kopts'] = post_kopts

    # and now sort all the lists
    for i in details.keys():
        if isinstance(details[i], list):
            details[i].sort()

    return details


def do_kickstart_export(self, args):
    options = [Option('-f', '--file', action='store')]
    (args, options) = parse_arguments(args, options)

    filename = ""
    if options.file != None:
        logging.debug("Passed filename do_kickstart_export %s" %
                      options.file)
        filename = options.file

    # Get the list of profiles to export and sort out the filename if required
    profiles = []
    if not args:
        if not filename:
            filename = "ks_all.json"
        logging.info("Exporting ALL kickstart profiles to %s" % filename)
        profiles = self.do_kickstart_list('', True)
    else:
        # allow globbing of kickstart kickstart names
        profiles = filter_results(self.do_kickstart_list('', True), args)
        logging.debug("kickstart_export called with args %s, profiles=%s" %
                      (args, profiles))
        if not profiles:
            logging.error("Error, no valid kickstart profile passed, " +
                          "check name is  correct with spacecmd kickstart_list")
            return
        if not filename:
            # No filename arg, so we try to do something sensible:
            # If we are exporting exactly one ks, we default to ksname.json
            # otherwise, generic ks_profiles.json name
            if len(profiles) == 1:
                filename = "%s.json" % profiles[0]
            else:
                filename = "ks_profiles.json"

    # First grab the list of basic details about all kickstarts because you
    # can't get details-per-label, call here to avoid potential duplicate calls
    # in export_kickstart_getdetails for multi-profile exports
    kickstarts = self.client.kickstart.listKickstarts(self.session)

    # Dump as a list of dict
    ksdetails_list = []
    for p in profiles:
        logging.info("Exporting ks %s to %s" % (p, filename))
        ksdetails_list.append(self.export_kickstart_getdetails(p, kickstarts))

    logging.debug("About to dump %d ks profiles to %s" %
                  (len(ksdetails_list), filename))
    # Check if filepath exists, if an existing file we prompt for confirmation
    if os.path.isfile(filename):
        if not self.user_confirm("File %s exists, " % filename +
                                 "confirm overwrite file? (y/n)"):
            return
    if json_dump_to_file(ksdetails_list, filename) != True:
        logging.error("Error saving exported kickstart profiles to file" %
                      filename)
        return

####################


def help_kickstart_importjson(self):
    print('kickstart_import: import kickstart profile(s) from json file')
    print('''usage: kickstart_import <JSONFILES...>''')


def do_kickstart_importjson(self, args):
    (args, _options) = parse_arguments(args)

    if not args:
        logging.error("Error, no filename passed")
        self.help_kickstart_import()
        return

    for filename in args:
        logging.debug("Passed filename do_kickstart_import %s" % filename)
        ksdetails_list = json_read_from_file(filename)
        if not ksdetails_list:
            logging.error("Error, could not read json data from %s" % filename)
            return
        for ksdetails in ksdetails_list:
            if self.import_kickstart_fromdetails(ksdetails) != True:
                logging.error("Error importing kickstart %s" %
                              ksdetails['name'])

# create a new ks based on the dict from export_kickstart_getdetails


def import_kickstart_fromdetails(self, ksdetails):

    # First we check that an existing kickstart with the same name does not exist
    existing_profiles = self.do_kickstart_list('', True)
    if ksdetails['name'] in existing_profiles:
        logging.error("ERROR : kickstart profile %s already exists! Skipping!"
                      % ksdetails['name'])
        return False
    # create the ks, we need to drop the org prefix from the ks name
    logging.info("Found ks %s" % ksdetails['name'])

    # Create the kickstart
    # for adding new profiles, we require a root password.
    # This is overridden when we set the 'advanced options'
    tmppw = 'foobar'
    virt_type = 'none'  # assume none as there's no API call to read this info
    ks_host = ''
    self.client.kickstart.createProfile(self.session, ksdetails['label'],
                                        virt_type, ksdetails['tree_label'], ks_host, tmppw)
    # Now set other options
    self.client.kickstart.profile.setChildChannels(
        self.session, ksdetails['label'], ksdetails['child_channels'])
    self.client.kickstart.profile.setAdvancedOptions(
        self.session, ksdetails['label'], ksdetails['advanced_opts'])
    self.client.kickstart.profile.system.setPartitioningScheme(
        self.session, ksdetails['label'], ksdetails['partitioning_scheme'])
    self.client.kickstart.profile.software.setSoftwareList(
        self.session, ksdetails['label'], ksdetails['software_list'])
    self.client.kickstart.profile.setCustomOptions(
        self.session, ksdetails['label'], [o and o.get('arguments') or "\n" for o in ksdetails['custom_opts']])
    self.client.kickstart.profile.setVariables(
        self.session, ksdetails['label'], ksdetails['variable_list'])
    self.client.kickstart.profile.system.setRegistrationType(
        self.session, ksdetails['label'], ksdetails['reg_type'])
    if ksdetails['config_mgmt']:
        self.client.kickstart.profile.system.enableConfigManagement(
            self.session, ksdetails['label'])
    if ksdetails['remote_cmds']:
        self.client.kickstart.profile.system.enableRemoteCommands(
            self.session, ksdetails['label'])
    # Add the scripts
    for script in ksdetails['script_list']:
        # Somewhere between spacewalk-java-1.2.39-85 and 1.2.39-108,
        # two new versions of listScripts and addScripts were added, which
        # allows us to correctly set the "template" checkbox on import
        # However, we can't detect this capability via API version since
        # the API version number is the same (10.11)
        # So, we look for the template key in the script dict and use the "new"
        # API call if we find it.  This will obviously break if migrating
        # kickstarts from a server with the new API call to one without it,
        # so ensure the target satellite is at least as up-to-date as the
        # satellite where the export was performed.
        if script.has_key('template'):
            ret = self.client.kickstart.profile.addScript(self.session,
                                                          ksdetails['label'], script['name'], script['contents'],
                                                          script['interpreter'], script[
                                                              'script_type'], script['chroot'],
                                                          script['template'])
        else:
            ret = self.client.kickstart.profile.addScript(
                self.session, ksdetails['label'], script['name'], script['contents'],
                script['interpreter'], script['script_type'], script['chroot'])
        if ret:
            logging.debug("Added %s script to profile" % script['script_type'])
        else:
            logging.error("Error adding %s script" % script['script_type'])
    # Specify ip ranges
    for iprange in ksdetails['ip_ranges']:
        if self.client.kickstart.profile.addIpRange(self.session,
                                                    ksdetails['label'], iprange['min'], iprange['max']):
            logging.debug("added ip range %s-%s" %
                          iprange['min'], iprange['max'])
        else:
            logging.warning("failed to add ip range %s-%s, continuing" %
                            iprange['min'], iprange['max'])
            continue
    # File preservations, only if the list exists
    existing_file_preservations = [
        x['name'] for x in self.client.kickstart.filepreservation.listAllFilePreservations(
            self.session)]
    if ksdetails['file_preservations']:
        for fp in ksdetails['file_preservations']:
            if fp in existing_file_preservations:
                if self.client.kickstart.profile.system.addFilePreservations(
                        self.session, ksdetails['label'], [fp]):
                    logging.debug("added file preservation '%s'" % fp)
                else:
                    logging.warning("failed to add file preservation %s, skipping" % fp)
            else:
                logging.warning("file preservation list %s doesn't exist, skipping" % fp)

    # Now add activationkeys, only if they exist
    existing_act_keys = [k['key'] for k in
                         self.client.activationkey.listActivationKeys(self.session)]
    for akey in ksdetails['activation_keys']:
        if akey in existing_act_keys:
            logging.debug("Adding activation key %s to profile" % akey)
            self.client.kickstart.profile.keys.addActivationKey(self.session,
                                                                ksdetails['label'], akey)
        else:
            logging.warning("Actvationkey %s does not exist on the " % akey +
                            "satellite, skipping")

    # The GPG/SSL keys, only if they exist
    existing_gpg_ssl_keys = [x['description'] for x in self.client.kickstart.keys.listAllKeys(self.session)]
    for key in ksdetails['gpg_ssl_keys']:
        if key in existing_gpg_ssl_keys:
            logging.debug("Adding GPG/SSL key %s to profile" % key)
            self.client.kickstart.profile.system.addKeys(self.session,
                                                         ksdetails['label'], [key])
        else:
            logging.warning("GPG/SSL key %s does not exist on the " % key +
                            "satellite, skipping")

    # The pre/post logging settings
    self.client.kickstart.profile.setLogging(self.session, ksdetails['label'],
                                             ksdetails['pre_logging'], ksdetails['post_logging'])

    # There are some frustrating ommisions from the API which means we can't
    # export/import some settings, so we post a warning that some manual
    # fixup may be required
    logging.warning("Due to API ommissions, there are some settings which" +
                    " cannot be imported, please check and fixup manually if necessary")
    logging.warning(" * Details->Preserve ks.cfg")
    logging.warning(" * Details->Comment")
    # Org default gets exported but no way to set it, so we can just show this
    # warning if they are trying to import an org_default profile
    if ksdetails['org_default']:
        logging.warning(" * Details->Organization Default Profile")
    # No way to set the kernel options
    logging.warning(" * Details->Kernel Options")
    # We can export Post kernel options (sort of, see above)
    # if they exist on import, flag a warning
    if ksdetails.has_key('post_kopts'):
        logging.warning(" * Details->Post Kernel Options : %s" %
                        ksdetails['post_kopts'])
    return True

####################
# kickstart helper


def is_kickstart(self, name):
    if not name:
        return
    return name in self.do_kickstart_list(name, True)


def check_kickstart(self, name):
    if not name:
        logging.error("no kickstart label given")
        return False
    if not self.is_kickstart(name):
        logging.error("invalid kickstart label " + name)
        return False
    return True


def dump_kickstart(self, name, replacedict=None, excludes=None):
    excludes = excludes or ["Org Default:"]
    content = self.do_kickstart_details(name)

    content = get_normalized_text(content, replacedict=replacedict, excludes=excludes)

    return content

####################


def help_kickstart_diff(self):
    print('kickstart_diff: diff kickstart files')
    print('')
    print('usage: kickstart_diff SOURCE_CHANNEL TARGET_CHANNEL')


def complete_kickstart_diff(self, text, line, beg, end):
    parts = shlex.split(line)
    if line[-1] == ' ':
        parts.append('')
    args = len(parts)

    if args == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    if args == 3:
        return tab_completer(self.do_kickstart_list('', True), text)
    return []


def do_kickstart_diff(self, args):
    options = []

    (args, options) = parse_arguments(args, options)

    if len(args) != 1 and len(args) != 2:
        self.help_kickstart_diff()
        return

    source_channel = args[0]
    if not self.check_kickstart(source_channel):
        return

    target_channel = None
    if len(args) == 2:
        target_channel = args[1]
    elif hasattr(self, "do_kickstart_getcorresponding"):
        # can a corresponding channel name be found automatically?
        target_channel = self.do_kickstart_getcorresponding(source_channel)
    if not self.check_kickstart(target_channel):
        return

    source_replacedict, target_replacedict = get_string_diff_dicts(source_channel, target_channel)

    source_data = self.dump_kickstart(source_channel, source_replacedict)
    target_data = self.dump_kickstart(target_channel, target_replacedict)

    return diff(source_data, target_data, source_channel, target_channel)

####################


def help_kickstart_getupdatetype(self):
    print('kickstart_getupdatetype: Get the update type for a kickstart profile(s)')
    print('usage: kickstart_getupdatetype PROFILE')
    print('usage: kickstart_getupdatetype PROFILE1 PROFILE2')
    print('usage: kickstart_getupdatetype \"PROF*\"')


def complete_kickstart_getupdatetype(self, text, line, beg, end):
    if len(line.split(' ')) <= 2:
        return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_getupdatetype(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) < 1:
        self.help_kickstart_getupdatetype()
        return

    # allow globbing of kickstart labels
    all_labels = self.do_kickstart_list('', True)
    labels = filter_results(all_labels, args)
    logging.debug("Got labels to list the update type %s" % labels)

    if not labels:
        logging.error("No valid kickstart labels passed as arguments!")
        self.help_kickstart_getupdatetype()
        return

    for label in labels:
        if not label in all_labels:
            logging.error("kickstart label %s doesn't exist!" % label)
            continue

        updatetype = self.client.kickstart.profile.getUpdateType(self.session, label)

        if len(labels) == 1:
            print(updatetype)
        elif len(labels) > 1:
            print(label, ":", updatetype)

####################


def help_kickstart_setupdatetype(self):
    print('kickstart_setupdatetype: Set the update type for a kickstart profile(s)')
    print('''usage: kickstart_setupdatetype [options] KS_LABEL)

options:
    -u UPDATE_TYPE ['red_hat', 'all', 'none']''')


def do_kickstart_setupdatetype(self, args):
    options = [Option('-u', '--update-type', action='store')]

    (args, options) = parse_arguments(args, options)

    if is_interactive(options):

        print('Update Types')
        print('--------------------')
        print('\n'.join(sorted(self.UPDATE_TYPES)))
        print()

        options.update_type = prompt_user('Update Type [none]:')
        if options.update_type == '' or options.update_type not in self.UPDATE_TYPES:
            options.update_type = 'none'

    else:
        if not options.update_type:
            options.update_type = 'none'

    # allow globbing of kickstart labels
    all_labels = self.do_kickstart_list('', True)
    labels = filter_results(all_labels, args)
    logging.debug("Got labels to set the update type %s" % labels)

    if not labels:
        logging.error("No valid kickstart labels passed as arguments!")
        self.help_kickstart_setupdatetype()
        return

    for label in labels:
        if not label in all_labels:
            logging.error("kickstart label %s doesn't exist!" % label)
            continue

        self.client.kickstart.profile.setUpdateType(self.session, label, options.update_type)

####################


def help_kickstart_getsoftwaredetails(self):
    print('kickstart_getsoftwaredetails: Gets kickstart profile software details')
    print('usage: kickstart_getsoftwaredetails KS_LABEL')
    print('usage: kickstart_getsoftwaredetails KS_LABEL KS_LABEL2 ...')


def complete_kickstart_getsoftwaredetails(self, text, line, beg, end):
    if len(line.split(' ')) >= 2:
        return tab_completer(self.do_kickstart_list('', True), text)


def do_kickstart_getsoftwaredetails(self, args):
    (args, _options) = parse_arguments(args)

    if len(args) < 1:
        self.help_kickstart_getsoftwaredetails()
        return

    # allow globbing of kickstart labels
    all_labels = self.do_kickstart_list('', True)
    labels = filter_results(all_labels, args)
    logging.debug("Got labels to set the update type %s" % labels)

    if not labels:
        logging.error("No valid kickstart labels passed as arguments!")
        self.help_kickstart_getsoftwaredetails()
        return

    for label in labels:
        if not label in all_labels:
            logging.error("kickstart label %s doesn't exist!" % label)
            continue

        software_details = self.client.kickstart.profile.software.getSoftwareDetails(self.session, label)

        if len(labels) == 1:
            print("noBase:        %s" % software_details.get("noBase"))
            print("ignoreMissing: %s" % software_details.get("ignoreMissing"))
        elif len(labels) > 1:
            print("Kickstart Label: %s" % label)
            print("noBase:          %s" % software_details.get("noBase"))
            print("ignoreMissing:   %s" % software_details.get("ignoreMissing"))
            print()

####################


def help_kickstart_setsoftwaredetails(self):
    print('kickstart_setsoftwaredetails: Sets kickstart profile software details.')
    print('usage: kickstart_setsoftwaredetails PROFILE KICKSTART_PACKAGES_INFO VALUE')
    print('usage: kickstart_setsoftwaredetails PROFILE KICKSTART_PACKAGES_INFO VALUE KICKSTART_PACKAGES_INFO VALUE')

def complete_kickstart_setsoftwaredetails(self, text, line, beg, end):
    parts = line.split(' ')
    length = len(parts)

    if length == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    if length in [3, 5]:
        if 'noBase' in parts:
            return tab_completer(['ignoreMissing'], text)
        if 'ignoreMissing' in parts:
            return tab_completer(['noBase'], text)

        kspkginfo = ['noBase', 'ignoreMissing']
        return tab_completer(kspkginfo, text)
    if length in [4, 6]:
        mode= ['True', 'False']
        return tab_completer(mode, text)


def do_kickstart_setsoftwaredetails(self, args):
    (args, _options) = parse_arguments(args)
    length = len(args)
    kspkginfo = ['noBase', 'ignoreMissing']
    mode = ['True', 'False']

    if length < 1 or length not in [3, 5]:
        self.help_kickstart_setsoftwaredetails()
        return

    if args[0] not in self.do_kickstart_list('', True):
        print("Selected profile does not exist")
        return
    if args[1] not in kspkginfo or args[2] not in mode:
        print("Enter valid input")
        self.help_kickstart_setsoftwaredetails()
        return
    if length==5:
        if (args[3] not in kspkginfo or args[4] not in mode) or args[1] == args[3]:
            print("Enter valid input")
            self.help_kickstart_setsoftwaredetails()
            return

    args[2] = string_to_bool(args[2])
    if length == 5:
        args[4] = string_to_bool(args[4])

    profile = args[0]
    if length == 3:
        software_details = self.client.kickstart.profile.software.getSoftwareDetails(self.session, profile)

        if args[1] == 'noBase':
            kspkginfo= {'noBase': args[2], 'ignoreMissing': string_to_bool(software_details.get("ignoreMissing"))}
        elif args[1] == 'ignoreMissing':
            kspkginfo= {'noBase': string_to_bool(software_details.get("noBase")), 'ignoreMissing':args[2]}
    else:
        if args[3] == 'noBase':
            kspkginfo= {'noBase': args[4], 'ignoreMissing': args[2]}
        elif args[3] == 'ignoreMissing':
            kspkginfo= {'noBase': args[2], 'ignoreMissing':args[4]}

    self.client.kickstart.profile.software.setSoftwareDetails(self.session,
                                                              profile,
                                                              kspkginfo)
