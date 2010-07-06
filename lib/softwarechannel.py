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

from operator import itemgetter
from spacecmd.utils import *

def help_softwarechannel_getentitlements(self):
    print 'softwarechannel_getentitlements: List the available ' + \
          'entitlements for a software channel'
    print 'usage: softwarechannel_getentitlements CHANNEL'

def complete_softwarechannel_getentitlements(self, text, line, beg, 
                                             end):
    return tab_completer(self.do_softwarechannel_list('', True), text)

def do_softwarechannel_getentitlements(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_softwarechannel_getentitlements()
        return

    channel = args[0]

    entitlements = \
        self.client.channel.software.availableEntitlements(self.session, 
                                                           channel)

    print entitlements

####################

def help_softwarechannel_list(self):
    print 'softwarechannel_list: List all available software channels'
    print 'usage: softwarechannel_list'

def do_softwarechannel_list(self, args, doreturn=False):
    channels = self.client.channel.listAllChannels(self.session)
    channels = [c.get('label') for c in channels]

    if doreturn:
        return channels
    else:
        if len(channels):
            print '\n'.join(sorted(channels))

####################

def help_softwarechannel_listsystems(self):
    print 'softwarechannel_listsystems: List all systems subscribed to'
    print '                             a software channel'
    print 'usage: softwarechannel_listsystems CHANNEL'

def complete_softwarechannel_listsystems(self, text, line, beg, end):
    return tab_completer(self.do_softwarechannel_list('', True), text)

def do_softwarechannel_listsystems(self, args, doreturn=False):
    args = parse_arguments(args)

    if not len(args):
        self.help_softwarechannel_listsystems()
        return

    channel = args[0]

    systems = \
        self.client.channel.software.listSubscribedSystems(self.session,
                                                           channel)

    systems = [s.get('name') for s in systems]

    if doreturn:
        return systems
    else:
        if len(systems):
            print '\n'.join(sorted(systems))

####################

def help_softwarechannel_listpackages(self):
    print 'softwarechannel_listpackages: List the most recent packages'
    print '                              available from a software channel'
    print 'usage: softwarechannel_listpackages CHANNEL'

def complete_softwarechannel_listpackages(self, text, line, beg, end):
    if len(line.split(' ')) == 2:
        return tab_completer(self.do_softwarechannel_list('', True), 
                                  text)
    else:
        return []

def do_softwarechannel_listpackages(self, args, doreturn=False):
    args = parse_arguments(args)

    if not len(args):
        self.help_softwarechannel_listpackages()
        return

    channel = args[0]

    packages = self.client.channel.software.listLatestPackages(self.session,
                                                               channel)

    packages = build_package_names(packages)

    if doreturn:
        return packages
    else:
        if len(packages):
            print '\n'.join(sorted(packages))

####################

def help_softwarechannel_details(self):
    print 'softwarechannel_details: Show the details of a software channel'
    print 'usage: softwarechannel_details CHANNEL ...'

def complete_softwarechannel_details(self, text, line, beg, end):
    return tab_completer(self.do_softwarechannel_list('', True), text)

def do_softwarechannel_details(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_softwarechannel_details()
        return

    add_separator = False

    for channel in args:
        details = self.client.channel.software.getDetails(\
                                    self.session, channel)

        systems = \
            self.client.channel.software.listSubscribedSystems(\
                                          self.session, channel)

        trees = self.client.kickstart.tree.list(self.session, 
                                                channel)

        packages = \
            self.client.channel.software.listAllPackages(\
                                   self.session, channel)

        if add_separator: print self.SEPARATOR
        add_separator = True

        print 'Label:              %s' % details.get('label')
        print 'Name:               %s' % details.get('name')
        print 'Architecture:       %s' % details.get('arch_name')
        print 'Parent:             %s' % details.get('parent_channel_label')
        print 'Systems Subscribed: %s' % len(systems)
        print 'Number of Packages: %i' % len(packages)

        if details.get('summary'):
            print
            print 'Summary:'
            print '\n'.join(wrap(details.get('summary')))

        if details.get('description'):
            print
            print 'Description:'
            print '\n'.join(wrap(details.get('description')))

        print
        print 'GPG Key:            %s' % details.get('gpg_key_id')
        print 'GPG Fingerprint:    %s' % details.get('gpg_key_fp')
        print 'GPG URL:            %s' % details.get('gpg_key_url')

        if len(trees):
            print
            print 'Kickstart Trees:'
            for tree in trees:
                print '  %s' % tree.get('label')

####################

def help_softwarechannel_listerrata(self):
    print 'softwarechannel_listerrata: List the errata associated with a'
    print '                            software channel'
    print 'usage: softwarechannel_listerrata CHANNEL ...'

def complete_softwarechannel_listerrata(self, text, line, beg, end):
    return tab_completer(self.do_softwarechannel_list('', True), text)

def do_softwarechannel_listerrata(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.do_help_softwarechannel_listerrata()
        return

    channels = args

    add_separator = False

    for channel in sorted(channels):
        if len(channels) > 1:
            print 'Channel: %s' % channel
            print

        errata = self.client.channel.software.listErrata(self.session,
                                                         channel)

        print_errata_list(errata)

        if add_separator: print self.SEPARATOR
        add_separator = True

####################

def help_softwarechannel_delete(self):
    print 'softwarechannel_delete: Delete a software channel'
    print 'usage: softwarechannel_delete CHANNEL'

def complete_softwarechannel_delete(self, text, line, beg, end):
    return tab_completer(self.do_softwarechannel_list('', True), text)

def do_softwarechannel_delete(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_softwarechannel_delete()
        return

    channel = args[0]

    if not self.user_confirm('Delete this channel [y/N]:'): return

    self.client.channel.software.delete(self.session, channel)

####################

def help_softwarechannel_create(self):
    print 'softwarechannel_create: Create a software channel'
    print 'usage: softwarechannel_create'

def do_softwarechannel_create(self, args):
    name = prompt_user('Channel Name:', noblank = True)
    label = prompt_user('Channel Label:', noblank = True)
    summary = prompt_user('Summary:', noblank = True)

    print 'Base Channels:'
    print '\n'.join(sorted(self.list_base_channels()))
    print

    parent = \
        prompt_user('Select Parent [blank to create a base channel]:')

    print
    print 'Architecture:'
    print '\n'.join(sorted(self.ARCH_LABELS))
    print
    arch = prompt_user('Select:')

    self.client.channel.software.create(self.session,
                                        label,
                                        name,
                                        summary,
                                        'channel-%s' % arch,
                                        parent)

####################

def help_softwarechannel_clone(self):
    print 'softwarechannel_clone: Clone a software channel'
    print 'usage: softwarechannel_clone SOURCE'

def complete_softwarechannel_clone(self, text, line, beg, end):
    return tab_completer(self.do_softwarechannel_list('', True), text)

def do_softwarechannel_clone(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_softwarechannel_clone()
        return

    source = args[0]

    details = {}

    details['name'] = prompt_user('Channel Name:', noblank = True)
    details['label'] = prompt_user('Channel Label:', noblank = True)
    details['summary'] = prompt_user('Summary:', noblank = True)
    details['description'] = prompt_user('Description:')

    print 'Base Channels:'
    print '\n'.join(sorted(self.list_base_channels()))
    print

    details['parent_label'] = \
        prompt_user('Select Parent [blank to create a base channel]:')

    details['gpg_url'] = prompt_user('GPG URL:')
    details['gpg_id'] = prompt_user('GPG ID:')
    details['gpg_fingerprint'] = prompt_user('GPG Fingerprint:')

    orig_state = self.user_confirm('Original State [y/N]:')

    # remove empty strings from the structure
    to_remove = []
    for key in details:
        if details[key] == '':
            to_remove.append(key)

    for key in to_remove:
        del details[key]

    self.client.channel.software.clone(self.session,
                                       source,
                                       details,
                                       orig_state) 

####################

def help_softwarechannel_addpackages(self):
    print 'softwarechannel_addpackages: Add packages to a software channel'
    print 'usage: softwarechannel_addpackages CHANNEL <PACKAGE ...>'

def complete_softwarechannel_addpackages(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_softwarechannel_list('', True), 
                                  text)
    elif len(parts) > 2:
        return tab_completer(self.get_package_names(True), text)

def do_softwarechannel_addpackages(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_softwarechannel_addpackages()
        return

    channel = args.pop(0)

    # expand the arguments to search for packages
    package_names = []
    for item in args:
        package_names.extend(self.do_package_search(item, True))

    # get the package IDs from the names
    package_ids = []
    for package in package_names:
        package_ids.append(self.get_package_id(package))

    print 'Packages:'
    print '\n'.join(sorted(package_names))

    if not self.user_confirm('Add these packages [y/N]:'): return

    self.client.channel.software.addPackages(self.session, 
                                             channel, 
                                             package_ids)

####################

def help_softwarechannel_removepackages(self):
    print 'softwarechannel_removepackages: Remove packages from a ' + \
          'software channel'
    print 'usage: softwarechannel_removepackages CHANNEL <PACKAGE ...>'

def complete_softwarechannel_removepackages(self, text, line, beg, 
                                            end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_softwarechannel_list('', True), 
                                  text)
    elif len(parts) > 2:
        # only tab complete packages in the channel
        package_names = []
        try:
            packages = \
                self.client.channel.software.listAllPackages(self.session,
                                                             parts[1])

            package_names = build_package_names(packages)
        except:
            package_names = []

        return tab_completer(package_names, text)

def do_softwarechannel_removepackages(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_softwarechannel_removepackages()
        return

    channel = args.pop(0)
    package_list = args

    # get all the packages in the channel
    packages = \
        self.client.channel.software.listAllPackages(self.session,
                                                     channel)

    # build full names for those packages
    installed_packages = build_package_names(packages)

    # find matching packages that are in the channel
    package_names = filter_results(installed_packages, package_list)

    # get the package IDs from the names
    package_ids = []
    for package in package_names:
        package_ids.append(self.get_package_id(package))

    print 'Packages:'
    print '\n'.join(sorted(package_names))

    if not self.user_confirm('Remove these packages [y/N]:'): return

    self.client.channel.software.removePackages(self.session, 
                                                channel, 
                                                package_ids)

####################

#XXX: Bugzilla 609684
# this is currently the only way to add errata
def help_softwarechannel_mergeerrata(self):
    print 'softwarechannel_mergeerrata: Merge errata from one channel ' + \
          'into another channel'
    print 'usage: softwarechannel_mergeerrata SOURCE DEST BEGINDATE ENDDATE'

def complete_softwarechannel_mergeerrata(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) <= 3:
        return tab_completer(self.do_softwarechannel_list('', True), 
                                  text)

def do_softwarechannel_mergeerrata(self, args):
    args = parse_arguments(args)

    if len(args) != 4:
        self.help_softwarechannel_mergeerrata()
        return

    source_channel = args[0]
    dest_channel = args[1]
    begin_date = args[2]
    end_date = args[3]

    if not re.match('\d{8}', begin_date):
        logging.error('%s is an invalid date' % begin_date)
        return

    if not re.match('\d{8}', end_date):
        logging.error('%s is an invalid date' % end_date)
        return
 
    errata = \
        self.client.channel.software.listErrata(self.session,
                           source_channel,
                           parse_time_input(begin_date),
                           parse_time_input(end_date))

    # get the packages that resolve these errata so we can add them
    # to the channel afterwards
    package_ids = []
    for e in errata:
        logging.debug('Getting packages for errata %s' % \
                      e.get('advisory_name'))

        packages = self.client.errata.listPackages(self.session,
                                                   e.get('advisory_name'))

        package_ids.extend( [p.get('id') for p in packages] ) 

    print 'Errata:'
    for e in sorted(errata, key=itemgetter('advisory_name')):
        print_errata_summary(e)

    if not self.user_confirm('Add these errata [y/N]:'): return

    # add the errata to the destination channel
    self.client.channel.software.mergeErrata(self.session, 
                                             source_channel, 
                                             dest_channel,
                                             begin_date,
                                             end_date)

    # add the affected packages to the channel
    self.client.channel.software.addPackages(self.session,
                                             dest_channel,
                                             package_ids)

####################

def help_softwarechannel_regenerateneededcache(self):
    print 'softwarechannel_regenerateneededcache: '
    print 'Regenerate the needed errata and package cache for all systems'
    print
    print 'usage: softwarechannel_regnerateneededcache'

def do_softwarechannel_regenerateneededcache(self, args):
    if self.user_confirm('Are you sure [y/N]: '):
        self.client.channel.software.regenerateNeededCache(self.session)

# vim:ts=4:expandtab:
