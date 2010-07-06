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

from operator import itemgetter
from spacecmd.utils import *

def help_kickstart_list(self):
    print 'kickstart_list: List the available Kickstart profiles'
    print 'usage: kickstart_list'

def do_kickstart_list(self, args, doreturn=False):
    kickstarts = self.client.kickstart.listKickstarts(self.session)
    kickstarts = [k.get('name') for k in kickstarts]

    if doreturn:
        return kickstarts
    else:
        if len(kickstarts):
            print '\n'.join(sorted(kickstarts))

####################

def help_kickstart_create(self):
    print 'kickstart_create: Create a Kickstart profile'
    print 'usage: kickstart_create [PROFILE]'

def do_kickstart_create(self, args):
    args = parse_arguments(args)

    if len(args):
        name = args[0]
    else:
        name = prompt_user('Name:', noblank = True)

    print 'Virtualization Types:'
    print '\n'.join(sorted(self.VIRT_TYPES))
    print

    virt = prompt_user('Virtualization Type [none]:')
    if virt == '' or virt not in self.VIRT_TYPES:
        virt = 'none'

    tree = ''
    while tree == '':
        trees = self.do_distribution_list('', True)
        print
        print 'Distributions:'
        print '\n'.join(sorted(trees))
        print

        tree = prompt_user('Select:')

    password = ''
    while password == '':
        print
        password1 = getpass('Root Password: ')
        password2 = getpass('Repeat Password: ')

        if password1 == password2:
            password = password1
        elif password1 == '':
            logging.warning('Password must be at least 5 characters')
        else:
            logging.warning("Passwords don't match") 

    # leave this blank to use the default server
    host = ''

    self.client.kickstart.createProfile(self.session,
                                        name,
                                        virt,
                                        tree,
                                        host,
                                        password) 

####################

def help_kickstart_delete(self):
    print 'kickstart_delete: Delete a Kickstart profile'
    print 'usage: kickstart_delete PROFILE'

def complete_kickstart_delete(self, text, line, beg, end):
    if len(line.split(' ')) <= 2:
        return tab_completer(self.do_kickstart_list('', True), text)

def do_kickstart_delete(self, args):
    args = parse_arguments(args)

    if len(args) != 1:
        self.help_kickstart_delete()
        return

    label = args[0]

    if self.user_confirm('Delete this profile [y/N]:'):
        self.client.kickstart.deleteProfile(self.session, label)

####################

def help_kickstart_import(self):
    print 'kickstart_import: Import a Kickstart profile from a file'
    print 'usage: kickstart_import PROFILE FILE'

def do_kickstart_import(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_kickstart_import()
        return

    name = args[0]
    file = args[1]

    print 'Virtualization Types:'
    print '\n'.join(sorted(self.VIRT_TYPES))
    print

    virt = prompt_user('Virtualization Type [none]:')
    if virt == '' or virt not in self.VIRT_TYPES:
        virt = 'none'

    tree = ''
    while tree == '':
        trees = self.do_distribution_list('', True)
        print
        print 'Distributions:'
        print '\n'.join(sorted(trees))
        print

        tree = prompt_user('Select:')

    if not os.path.isfile(file):
        logging.error("Couldn't read %s" % file)
        return

    contents = ''
    try:
        ksfile = open(file, 'r')
        contents = ksfile.read()
        ksfile.close()
    except IOError:
        logging.error("Couldn't read %s" % file)
        return 

    # use the default server
    host = ''

    self.client.kickstart.importFile(self.session,
                                     name,
                                     virt,
                                     tree,
                                     host,
                                     contents)

####################

def help_kickstart_details(self):
    print 'kickstart_details: Show the details of a Kickstart profile'
    print 'usage: kickstart_details PROFILE'

def complete_kickstart_details(self, text, line, beg, end):
    if len(line.split(' ')) <= 2:
        return tab_completer(self.do_kickstart_list('', True), text)

def do_kickstart_details(self, args):
    args = parse_arguments(args)

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

    variables = self.client.kickstart.profile.getVariables(self.session,
                                                           label)

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
        self.client.kickstart.profile.system.checkConfigManagement(\
            self.session, label)

    remote_commands = \
        self.client.kickstart.profile.system.checkRemoteCommands(\
            self.session, label)

    #XXX: Bugzilla 584860
    partitions = \
        self.client.kickstart.profile.system.getPartitioningScheme(\
            self.session, label)

    crypto_keys = \
        self.client.kickstart.profile.system.listKeys(self.session,
                                                      label)

    file_preservations = \
        self.client.kickstart.profile.system.listFilePreservations(\
            self.session, label)

    software = self.client.kickstart.profile.software.getSoftwareList(\
            self.session, label)

    scripts = self.client.kickstart.profile.listScripts(self.session,
                                                        label)

    print 'Name:        %s' % kickstart.get('name')
    print 'Label:       %s' % kickstart.get('label')
    print 'Tree:        %s' % kickstart.get('tree_label')
    print 'Active:      %s' % kickstart.get('active')
    print 'Advanced:    %s' % kickstart.get('advanced_mode')
    print 'Org Default: %s' % kickstart.get('org_default')

    print
    print 'Configuration Management: %s' % config_manage
    print 'Remote Commands:          %s' % remote_commands

    print
    print 'Software Channels:'
    print '  %s' % base_channel.get('label')

    for channel in sorted(child_channels):
        print '    |-- %s' % channel

    if len(advanced_options):
        print
        print 'Advanced Options:'
        for o in sorted(advanced_options, key=itemgetter('name')):
            if o.get('arguments'):
                print '  %s %s' % (o.get('name'), o.get('arguments'))

    if len(custom_options):
        print
        print 'Custom Options:'
        for o in sorted(custom_options, key=itemgetter('arguments')):
            print '  %s' % re.sub('\n', '', o.get('arguments'))

    if len(partitions):
        print
        print 'Partitioning:'
        for line in partitions:
            print '  %s' % line

    print
    print 'Software:'
    for s in software:
        print '  %s' % s

    if len(act_keys):
        print
        print 'Activation Keys:'
        for k in sorted(act_keys, key=itemgetter('key')):
            print '  %s' % k.get('key')

    if len(crypto_keys):
        print
        print 'Crypto Keys:'
        for k in sorted(crypto_keys, key=itemgetter('description')):
            print '  %s' % k.get('description')

    if len(file_preservations):
        print
        print 'File Preservations:'
        for fp in sorted(file_preservations, key=itemgetter('name')):
            print '  %s' % fp.get('name')
            for file in sorted(fp.get('file_names')):
                print '    |-- %s' % file

    if len(variables):
        print
        print 'Variables:'
        for k in sorted(variables.keys()):
            print '  %s=%s' %(k, str(variables[k]))

    if len(scripts):
        print
        print 'Scripts:'

        add_separator = False

        for s in scripts:
            if add_separator: print self.SEPARATOR
            add_separator = True

            print '  Type:        %s' % s.get('script_type')
            print '  Chroot:      %s' % s.get('chroot')

            if s.get('interpreter'):
                print '  Interpreter: %s' % s.get('interpreter')

            print
            print s.get('contents')

####################

def help_kickstart_getfile(self):
    print 'kickstart_getfile: Show the contents of a Kickstart profile'
    print '                   as they would be presented to a client'
    print 'usage: kickstart_getfile LABEL'

def complete_kickstart_getfile(self, text, line, beg, end):
    return tab_completer(self.do_kickstart_list('', True), text)

def do_kickstart_getfile(self, args, doreturn=False):
    args = parse_arguments(args)

    url = 'http://%s/ks/cfg/label/%s' %(self.server, args[0])

    try:
        if re.match('localhost', self.server, re.I):
            for p in ['http_proxy', 'HTTP_PROXY']:
                if len(os.environ[p]):
                    logging.debug('Disabling HTTP proxy')
                    os.environ[p] = ''

        logging.debug('Retrieving %s' % url)
        response = urllib2.urlopen(url)
        kickstart = response.read()
    except urllib2.HTTPError:
        logging.error('Could not retrieve the Kickstart file')
        return

    # XXX: Bugzilla 584864
    # the value returned here is uninterpreted by Cobbler
    # which makes it useless
    #kickstart = \
    #    self.client.kickstart.profile.downloadKickstart(self.session,
    #                                                    args[0],
    #                                                    self.server)

    print kickstart

####################

def help_kickstart_rename(self):
    print 'kickstart_rename: Rename a Kickstart profile'
    print 'usage: kickstart_rename OLDNAME NEWNAME'

def complete_kickstart_rename(self, text, line, beg, end):
    if len(line.split(' ')) <= 2:
        return tab_completer(self.do_kickstart_list('', True), text)

def do_kickstart_rename(self, args):
    args = parse_arguments(args)

    if len(args) != 2:
        self.help_kickstart_rename()
        return

    oldname = args[0]
    newname = args[1]

    self.client.kickstart.renameProfile(self.session, oldname, newname)

####################

def help_kickstart_listcryptokeys(self):
    print 'kickstart_listcryptokeys: List the crypto keys associated ' + \
          'with a Kickstart profile'
    print 'usage: kickstart_listcryptokeys PROFILE'

def complete_kickstart_listcryptokeys(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)

def do_kickstart_listcryptokeys(self, args, doreturn=False):
    args = parse_arguments(args)

    if not len(args):
        self.help_kickstart_listcryptokeys()
        return

    profile = args[0]

    keys = self.client.kickstart.profile.system.listKeys(self.session,
                                                         profile)
    keys = [ k.get('description') for k in keys ]

    if doreturn:
        return keys
    else:
        if len(keys):
            print '\n'.join(sorted(keys))

####################

def help_kickstart_addcryptokeys(self):
    print 'kickstart_addcryptokeys: Add crypto keys to a Kickstart profile'
    print 'usage: kickstart_addcryptokeys PROFILE <KEY ...>'

def complete_kickstart_addcryptokeys(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) > 2:
        return tab_completer(self.do_cryptokey_list('', True), text)

def do_kickstart_addcryptokeys(self, args):
    args = parse_arguments(args)

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
    print 'kickstart_removecryptokeys: Remove crypto keys from a ' + \
          'Kickstart profile'
    print 'usage: kickstart_removecryptokeys PROFILE <KEY ...>'

def complete_kickstart_removecryptokeys(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) > 2:
        # only tab complete keys currently assigned to the profile
        try:
            keys = self.do_kickstart_listcryptokeys(parts[1], True)
        except:
            keys = []

        return tab_completer(keys, text)

def do_kickstart_removecryptokeys(self, args):
    args = parse_arguments(args)

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
    print 'kickstart_listactivationkeys: List the activation keys ' + \
          'associated with a Kickstart profile'
    print 'usage: kickstart_listactivationkeys PROFILE'

def complete_kickstart_listactivationkeys(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)

def do_kickstart_listactivationkeys(self, args, doreturn=False):
    args = parse_arguments(args)

    if not len(args):
        self.help_kickstart_listactivationkeys()
        return

    profile = args[0]

    keys = \
        self.client.kickstart.profile.keys.getActivationKeys(self.session,
                                                             profile)

    keys = [ k.get('key') for k in keys ]

    if doreturn:
        return keys
    else:
        if len(keys):
            print '\n'.join(sorted(keys))

####################

def help_kickstart_addactivationkeys(self):
    print 'kickstart_addactivationkeys: Add activation keys to a ' + \
          'Kickstart profile'
    print 'usage: kickstart_addactivationkeys PROFILE <KEY ...>'

def complete_kickstart_addactivationkeys(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) > 2:
        return tab_completer(self.do_activationkey_list('', True), 
                                  text)

def do_kickstart_addactivationkeys(self, args):
    args = parse_arguments(args)

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
    print 'kickstart_removeactivationkeys: Remove activation keys from ' + \
          'a Kickstart profile'
    print 'usage: kickstart_removeactivationkeys PROFILE <KEY ...>'

def complete_kickstart_removeactivationkeys(self, text, line, beg, 
                                            end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) > 2:
        # only tab complete keys currently assigned to the profile
        try:
            keys = self.do_kickstart_listactivationkeys(parts[1], True)
        except:
            keys = []

        return tab_completer(keys, text)

def do_kickstart_removeactivationkeys(self, args):
    args = parse_arguments(args)

    if len(args) < 2:
        self.help_kickstart_removeactivationkeys()
        return

    profile = args[0]
    keys = args[1:]

    if not self.user_confirm('Remove these keys [y/N]:'): return

    for key in keys:
        self.client.kickstart.profile.keys.removeActivationKey(self.session,
                                                               profile,
                                                               key)

####################

def help_kickstart_enableconfigmanagement(self):
    print 'kickstart_enableconfigmanagement: Enable configuration ' + \
          'management on a Kickstart profile'
    print 'usage: kickstart_enableconfigmanagement PROFILE'

def complete_kickstart_enableconfigmanagement(self, text, line, beg, 
                                              end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)

def do_kickstart_enableconfigmanagement(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_kickstart_enableconfigmanagement()
        return

    profile = args[0]

    self.client.kickstart.profile.system.enableConfigManagement(\
        self.session, profile)

####################

def help_kickstart_disableconfigmanagement(self):
    print 'kickstart_disableconfigmanagement: Disable configuration ' + \
          'management on a Kickstart profile'
    print 'usage: kickstart_disableconfigmanagement PROFILE'

def complete_kickstart_disableconfigmanagement(self, text, line, beg, 
                                               end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)

def do_kickstart_disableconfigmanagement(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_kickstart_disableconfigmanagement()
        return

    profile = args[0]

    self.client.kickstart.profile.system.disableConfigManagement(\
        self.session, profile)

####################

def help_kickstart_enableremotecommands(self):
    print 'kickstart_enableremotecommands: Enable remote commands ' + \
          'on a Kickstart profile'
    print 'usage: kickstart_enableremotecommands PROFILE'

def complete_kickstart_enableremotecommands(self, text, line, beg, 
                                            end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)

def do_kickstart_enableremotecommands(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_kickstart_enableremotecommands()
        return

    profile = args[0]

    self.client.kickstart.profile.system.enableRemoteCommands(self.session,
                                                              profile)

####################

def help_kickstart_disableremotecommands(self):
    print 'kickstart_disableremotecommands: Disable remote commands ' + \
          'on a Kickstart profile'
    print 'usage: kickstart_disableremotecommands PROFILE'

def complete_kickstart_disableremotecommands(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)

def do_kickstart_disableremotecommands(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_kickstart_disableremotecommands()
        return

    profile = args[0]

    self.client.kickstart.profile.system.disableRemoteCommands(self.session,
                                                               profile)

####################
    
def help_kickstart_setlocale(self):
    print 'kickstart_setlocale: Set the locale for a Kickstart profile'
    print 'usage: kickstart_setlocale PROFILE LOCALE'

def complete_kickstart_setlocale(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) == 3:
        return tab_completer(list_locales(), text)

def do_kickstart_setlocale(self, args):
    args = parse_arguments(args)

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
    print 'kickstart_setselinux: Set the SELinux mode for a Kickstart ' + \
          'profile'
    print 'usage: kickstart_setselinux PROFILE MODE'

def complete_kickstart_setselinux(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) == 3:
        modes = ['enforcing', 'permissive', 'disabled']
        return tab_completer(modes, text)

def do_kickstart_setselinux(self, args):
    args = parse_arguments(args)

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
    print 'kickstart_setpartitions: Set the partitioning scheme for a ' + \
          'Kickstart profile'
    print 'usage: kickstart_setpartitions PROFILE'

def complete_kickstart_setpartitions(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)

def do_kickstart_setpartitions(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_kickstart_setpartitions()
        return

    profile = args[0]

    try:
        # get the current scheme so the user can edit it
        current = \
            self.client.kickstart.profile.system.getPartitioningScheme(\
                self.session, profile)

        template = '\n'.join(current)
    except:
        template = ''

    (partitions, ignore) = editor(template=template, delete=True)

    print partitions
    if not self.user_confirm(): return

    lines = partitions.split('\n')

    self.client.kickstart.profile.system.setPartitioningScheme(self.session,
                                                               profile,
                                                               lines)

####################
    
def help_kickstart_setdistribution(self):
    print 'kickstart_setdistribution: Set the distribution for a ' + \
          'Kickstart profile'
    print 'usage: kickstart_setdistribution PROFILE DISTRIBUTION'

def complete_kickstart_setdistribution(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) == 3:
        return tab_completer(self.do_distribution_list('', True), text)

def do_kickstart_setdistribution(self, args):
    args = parse_arguments(args)

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
    print 'kickstart_enablelogging: Enable logging for a Kickstart profile'
    print 'usage: kickstart_enablelogging PROFILE'

def complete_kickstart_enablelogging(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)

def do_kickstart_enablelogging(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_kickstart_enablelogging()
        return

    profile = args[0]
   
    self.client.kickstart.profile.setLogging(self.session,
                                             profile,
                                             True,
                                             True)

####################
    
def help_kickstart_addvariable(self):
    print 'kickstart_addvariable: Add a variable to a Kickstart profile'
    print 'usage: kickstart_addvariable PROFILE KEY VALUE'

def complete_kickstart_addvariable(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)

def do_kickstart_addvariable(self, args):
    args = parse_arguments(args)

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
    print 'kickstart_updatevariable: Update a variable in a Kickstart ' + \
          'profile'
    print 'usage: kickstart_updatevariable PROFILE KEY VALUE'

def complete_kickstart_updatevariable(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) > 2:
        variables = []
        try:
            variables = \
                self.client.kickstart.profile.getVariables(self.session,
                                                           parts[1])
        except:
            pass

        return tab_completer(variables.keys(), text)

def do_kickstart_updatevariable(self, args):
    args = parse_arguments(args)

    if len(args) < 3:
        self.help_kickstart_updatevariable()
        return

    return self.do_kickstart_addvariable(' '.join(args))

####################
    
def help_kickstart_removevariables(self):
    print 'kickstart_removevariables: Remove variables from a ' + \
          'Kickstart profile'
    print 'usage: kickstart_removevariables PROFILE <KEY ...>'

def complete_kickstart_removevariables(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) > 2:
        variables = []
        try:
            variables = \
                self.client.kickstart.profile.getVariables(self.session,
                                                           parts[1])
        except:
            pass

        return tab_completer(variables.keys(), text)

def do_kickstart_removevariables(self, args):
    args = parse_arguments(args)

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
    print 'kickstart_listvariables: List the variables of a Kickstart ' + \
          'profile'
    print 'usage: kickstart_listvariables PROFILE'

def complete_kickstart_listvariables(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)

def do_kickstart_listvariables(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_kickstart_listvariables()
        return

    profile = args[0]

    variables = self.client.kickstart.profile.getVariables(self.session,
                                                           profile)

    for v in variables:
        print '%s = %s' % (v, variables[v])

####################
    
def help_kickstart_addoption(self):
    print 'kickstart_addoption: Set an option for a Kickstart profile'
    print 'usage: kickstart_addoption PROFILE KEY [VALUE]'

def complete_kickstart_addoption(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) == 3:
        return tab_completer(sorted(self.KICKSTART_OPTIONS), text)

def do_kickstart_addoption(self, args):
    args = parse_arguments(args)

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

        advanced.append({'name' : key, 'arguments' : value})

        self.client.kickstart.profile.setAdvancedOptions(self.session,
                                                         profile,
                                                         advanced)
    else:
        logging.warning('%s needs to be set as a custom option' % key)
        return

####################
    
def help_kickstart_removeoptions(self):
    print 'kickstart_removeoptions: Remove options from a Kickstart profile'
    print 'usage: kickstart_removeoptions PROFILE <OPTION ...>'

def complete_kickstart_removeoptions(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) > 2:
        try:
            options = self.client.kickstart.profile.getAdvancedOptions(\
                                                    self.session, parts[1])

            options = [ o.get('name') for o in options ]
        except:
            options = self.KICKSTART_OPTIONS

        return tab_completer(sorted(options), text)

def do_kickstart_removeoptions(self, args):
    args = parse_arguments(args)

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
    print 'kickstart_listoptions: List the options of a Kickstart ' + \
          'profile'
    print 'usage: kickstart_listoptions PROFILE'

def complete_kickstart_listoptions(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)

def do_kickstart_listoptions(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_kickstart_listoptions()
        return

    profile = args[0]

    options = self.client.kickstart.profile.getAdvancedOptions(self.session,
                                                               profile)

    for o in sorted(options, key=itemgetter('name')):
        if o.get('arguments'):
            print '%s %s' % (o.get('name'), o.get('arguments'))

####################
    
def help_kickstart_listcustomoptions(self):
    print 'kickstart_listcustomoptions: List the custom options of a ' + \
          'Kickstart profile'
    print 'usage: kickstart_listcustomoptions PROFILE'

def complete_kickstart_listcustomoptions(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)

def do_kickstart_listcustomoptions(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_kickstart_listcustomoptions()
        return

    profile = args[0]

    options = self.client.kickstart.profile.getCustomOptions(self.session,
                                                             profile)

    for o in options:
        if 'arguments' in o:
            print o.get('arguments')

####################
    
def help_kickstart_setcustomoptions(self):
    print 'kickstart_setcustomoptions: Set custom options for a ' + \
          'Kickstart profile'
    print 'usage: kickstart_setcustomoptions PROFILE'

def complete_kickstart_setcustomoptions(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)

def do_kickstart_setcustomoptions(self, args):
    args = parse_arguments(args)

    if not len(args):
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
    (new_options, ignore) = editor(template = old_options, 
                                        delete = True)

    new_options = new_options.split('\n')

    self.client.kickstart.profile.setCustomOptions(self.session,
                                                   profile,
                                                   new_options)

####################
    
def help_kickstart_addchildchannels(self):
    print 'kickstart_addchildchannels: Add a child channels to a ' + \
          'Kickstart profile'
    print 'usage: kickstart_addchildchannels PROFILE <CHANNEL ...>'

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

            tree_details = self.client.kickstart.tree.getDetails(\
                                                      self.session, tree)

            base_channel = \
                self.client.channel.software.getDetails(self.session,
                                      tree_details.get('channel_id'))

            parent_channel = base_channel.get('label')
        except:
            return []
        
        return tab_completer(self.list_child_channels(\
                                  parent=parent_channel), text)

def do_kickstart_addchildchannels(self, args):
    args = parse_arguments(args)

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
    print 'kickstart_removechildchannels: Remove child channels from ' + \
          'a Kickstart profile'
    print 'usage: kickstart_removechildchannels PROFILE <CHANNEL ...>'

def complete_kickstart_removechildchannels(self, text, line, beg, 
                                           end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) > 2:
        return tab_completer(self.do_kickstart_listchildchannels(\
                                  parts[1], True), text)

def do_kickstart_removechildchannels(self, args):
    args = parse_arguments(args)

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
    print 'kickstart_listchildchannels: List the child channels of a ' + \
          'Kickstart profile'
    print 'usage: kickstart_listchildchannels PROFILE'

def complete_kickstart_listchildchannels(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)

def do_kickstart_listchildchannels(self, args, doreturn=False):
    args = parse_arguments(args)

    if not len(args):
        self.help_kickstart_listchildchannels()
        return

    profile = args[0]

    channels = self.client.kickstart.profile.getChildChannels(self.session,
                                                              profile)

    if doreturn:
        return channels
    else:
        if len(channels):
            print '\n'.join(sorted(channels))

####################

def help_kickstart_addfilepreservations(self):
    print 'kickstart_addfilepreservations: Add file preservations to a ' + \
          'Kickstart profile'
    print 'usage: kickstart_addfilepreservations PROFILE <FILELIST ...>'

def complete_kickstart_addfilepreservations(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)
    elif len(parts) == 3:
        return tab_completer(self.do_filepreservation_list('', True), 
                                  text)

def do_kickstart_addfilepreservations(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_kickstart_addfilepreservations()
        return

    profile = args[0]
    files = args[1:]

    self.client.kickstart.profile.system.addFilePreservations(self.session,
                                                              profile,
                                                              files)

####################

def help_kickstart_removefilepreservations(self):
    print 'kickstart_removefilepreservations: Remove file ' + \
          'preservations from a Kickstart profile'
    print 'usage: kickstart_removefilepreservations PROFILE <FILE ...>'

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
                self.client.kickstart.profile.system.listFilePreservations(\
                    self.session, parts[1])
            files = [ f.get('name') for f in files ]
        except:
            return []

        return tab_completer(files, text)

def do_kickstart_removefilepreservations(self, args):
    args = parse_arguments(args)

    if len(args) < 2:
        self.help_kickstart_removefilepreservations()
        return

    profile = args[0]
    files = args[1:]

    self.client.kickstart.profile.system.removeFilePreservations(\
        self.session, profile, files)

####################

def help_kickstart_listpackages(self):
    print 'kickstart_listpackages: List the packages for a Kickstart ' + \
          'profile'
    print 'usage: kickstart_listpackages PROFILE'

def complete_kickstart_listpackages(self, text, line, beg, end):
    return tab_completer(self.do_kickstart_list('', True), text)

def do_kickstart_listpackages(self, args, doreturn = False):
    args = parse_arguments(args)

    if not len(args):
        self.help_kickstart_listpackages()
        return

    profile = args[0]

    packages = \
        self.client.kickstart.profile.software.getSoftwareList(self.session,
                                                               profile)

    if doreturn:
        return packages
    else:
        if len(packages):
            print '\n'.join(packages)

####################

def help_kickstart_addpackages(self):
    print 'kickstart_addpackages: Add packages to a Kickstart profile'
    print 'usage: kickstart_addpackages PROFILE <PACKAGE ...>'

def complete_kickstart_addpackages(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text) 
    elif len(parts) > 2:
        return tab_completer(self.get_package_names(), text)

def do_kickstart_addpackages(self, args):
    args = parse_arguments(args)

    if not len(args) >= 2:
        self.help_kickstart_addpackages()
        return

    profile = args[0]
    packages = args[1:]

    self.client.kickstart.profile.software.appendToSoftwareList(\
        self.session, profile, packages)

####################

def help_kickstart_removepackages(self):
    print 'kickstart_removepackages: Remove packages from a Kickstart ' + \
          'profile'
    print 'usage: kickstart_removepackages PROFILE <PACKAGE ...>'

def complete_kickstart_removepackages(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), 
                                  text)
    elif len(parts) > 2:
        return tab_completer(self.do_kickstart_listpackages(\
                                  parts[1], True), text)

def do_kickstart_removepackages(self, args):
    args = parse_arguments(args)

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
    print 'kickstart_listscripts: List the scripts for a Kickstart ' + \
          'profile'
    print 'usage: kickstart_listscripts PROFILE'

def complete_kickstart_listscripts(self, text, line, beg, end):
    return tab_completer(self.do_kickstart_list('', True), text)

def do_kickstart_listscripts(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_kickstart_listscripts()
        return

    profile = args[0]

    scripts = \
        self.client.kickstart.profile.listScripts(self.session, profile)

    add_separator = False

    for script in scripts:
        if add_separator: print self.SEPARATOR
        add_separator = True

        print 'ID:          %i' % script.get('id')
        print 'Type:        %s' % script.get('script_type')
        print 'Chroot:      %s' % script.get('chroot')
        print 'Interpreter: %s' % script.get('interpreter')
        print 'Contents:'
        print script.get('contents')

####################

def help_kickstart_addscript(self):
    print 'kickstart_addscript: Add a script to a Kickstart profile'
    print 'usage: kickstart_addscript PROFILE'

def complete_kickstart_addscript(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)

def do_kickstart_addscript(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_kickstart_addscript()
        return

    profile = args[0]

    type = prompt_user('Pre/Post Script [post]:')
    chroot = prompt_user('Chrooted [Y/n]:')
    interpreter = prompt_user('Interpreter [/bin/bash]:')
    
    # get the contents of the script
    (contents, ignore) = editor(delete = True)
    
    # check user input
    if interpreter == '': interpreter = '/bin/bash'
    
    if re.match('pre', type, re.I):
        type = 'pre'
    else:
        type = 'post'

    if re.match('n', chroot, re.I):
        chroot = False
    else:
        chroot = True

    print
    print 'Type:        %s' % type
    print 'Chroot:      %s' % chroot
    print 'Interpreter: %s' % interpreter
    print 'Contents:'
    print contents

    if not self.user_confirm(): return

    self.client.kickstart.profile.addScript(self.session,
                                            profile,
                                            contents,
                                            interpreter,
                                            type,
                                            chroot)

####################

def help_kickstart_removescript(self):
    print 'kickstart_removescript: Add a script to a Kickstart profile'
    print 'usage: kickstart_removescript PROFILE [ID]'

def complete_kickstart_removescript(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_kickstart_list('', True), text)

def do_kickstart_removescript(self, args):
    args = parse_arguments(args)

    if not len(args):
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

    # print the scripts for the user to review
    self.do_kickstart_listscripts(profile)

    if not script_id:
        while script_id == 0:
            print
            input = prompt_user('Script ID:', noblank = True)
    
            try:
                script_id = int(input)
            except ValueError:
                logging.error('Invalid script ID')

    if not self.user_confirm('Remove this script [y/N]:'): return

    self.client.kickstart.profile.removeScript(self.session,
                                               profile,
                                               script_id)

# vim:ts=4:expandtab:
