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
from optparse import Option
from spacecmd.utils import *

ARCH_LABELS = ['ia32', 'ia64', 'x86_64', 'ppc',
               'i386-sun-solaris', 'sparc-sun-solaris']

def help_softwarechannel_getentitlements(self):
    print 'softwarechannel_getentitlements: List the available ' + \
          'entitlements for a software channel'
    print 'usage: softwarechannel_getentitlements CHANNEL'

def complete_softwarechannel_getentitlements(self, text, line, beg, end):
    return tab_completer(self.do_softwarechannel_list('', True), text)

def do_softwarechannel_getentitlements(self, args):
    (args, options) = parse_arguments(args)

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

    # filter the list if arguments were passed
    if args:
        channels = filter_results(channels, args)

    if doreturn:
        return channels
    else:
        if len(channels):
            print '\n'.join(sorted(channels))

####################

def help_softwarechannel_listbasechannels(self):
    print 'softwarechannel_listbasechannels: List all base software channels'
    print 'usage: softwarechannel_listbasechannels'

def do_softwarechannel_listbasechannels(self, args):
    channels = self.list_base_channels()

    if len(channels):
        print '\n'.join(sorted(channels))

####################

def help_softwarechannel_listchildchannels(self):
    print 'softwarechannel_listchildchannels: List all child software channels'
    print 'usage: softwarechannel_listchildchannels'

def do_softwarechannel_listchildchannels(self, args):
    channels = self.list_child_channels()

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
    (args, options) = parse_arguments(args)

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
    (args, options) = parse_arguments(args)

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

def help_softwarechannel_listallpackages(self):
    print 'softwarechannel_listallpackages: List all packages in a channel'
    print 'usage: softwarechannel_listallpackages CHANNEL'

def complete_softwarechannel_listallpackages(self, text, line, beg, end):
    if len(line.split(' ')) == 2:
        return tab_completer(self.do_softwarechannel_list('', True),
                                  text)
    else:
        return []

def do_softwarechannel_listallpackages(self, args, doreturn=False):
    (args, options) = parse_arguments(args)

    if not len(args):
        self.help_softwarechannel_listallpackages()
        return

    channel = args[0]

    packages = self.client.channel.software.listAllPackages(self.session,
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
    print 'usage: softwarechannel_details <CHANNEL ...>'

def complete_softwarechannel_details(self, text, line, beg, end):
    return tab_completer(self.do_softwarechannel_list('', True), text)

def do_softwarechannel_details(self, args):
    (args, options) = parse_arguments(args)

    if not len(args):
        self.help_softwarechannel_details()
        return

    # allow globbing of software channel names
    channels = filter_results(self.do_softwarechannel_list('', True), args)

    add_separator = False

    for channel in channels:
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
            print 'Summary'
            print '-------'
            print '\n'.join(wrap(details.get('summary')))

        if details.get('description'):
            print
            print 'Description'
            print '-----------'
            print '\n'.join(wrap(details.get('description')))

        print
        print 'GPG Key:            %s' % details.get('gpg_key_id')
        print 'GPG Fingerprint:    %s' % details.get('gpg_key_fp')
        print 'GPG URL:            %s' % details.get('gpg_key_url')

        if len(trees):
            print
            print 'Kickstart Trees'
            print '---------------'
            for tree in trees:
                print tree.get('label')

####################

def help_softwarechannel_listerrata(self):
    print 'softwarechannel_listerrata: List the errata associated with a'
    print '                            software channel'
    print 'usage: softwarechannel_listerrata <CHANNEL ...> [from=yyyymmdd [to=yyyymmdd]]'

def complete_softwarechannel_listerrata(self, text, line, beg, end):
    return tab_completer(self.do_softwarechannel_list('', True), text)

def do_softwarechannel_listerrata(self, args):
    (args, options) = parse_arguments(args)

    if not len(args):
        self.help_softwarechannel_listerrata()
        return

    begin_date = None
    end_date = None

    # iterate over args and alter a copy of it (channels)
    channels = args[:]
    for arg in args:
        if arg[:5] == 'from=':
            begin_date = arg[5:]
            channels.remove(arg)
        elif arg[:3] == 'to=':
            end_date = arg[3:]
            channels.remove(arg)

    add_separator = False

    for channel in sorted(channels):
        if len(channels) > 1:
            print 'Channel: %s' % channel
            print

        if begin_date and end_date:
                errata = self.client.channel.software.listErrata(self.session,
                                         channel, parse_time_input(begin_date),
                                                  parse_time_input(end_date))
        elif begin_date:
                errata = self.client.channel.software.listErrata(self.session,
                                         channel, parse_time_input(begin_date))
        else:
            errata = self.client.channel.software.listErrata(self.session,
                                                         channel)

        print_errata_list(errata)

        if add_separator: print self.SEPARATOR
        add_separator = True

####################

def help_softwarechannel_delete(self):
    print 'softwarechannel_delete: Delete a software channel'
    print 'usage: softwarechannel_delete <CHANNEL ...>'

def complete_softwarechannel_delete(self, text, line, beg, end):
    return tab_completer(self.do_softwarechannel_list('', True), text)

def do_softwarechannel_delete(self, args):
    (args, options) = parse_arguments(args)

    if not len(args):
        self.help_softwarechannel_delete()
        return

    channels = args

    # find all matching channels
    to_delete = filter_results(self.do_softwarechannel_list('', True), channels)

    if not len(to_delete): return

    print 'Channels'
    print '--------'
    print '\n'.join(sorted(to_delete))

    if not self.user_confirm('Delete these channels [y/N]:'): return

    # delete child channels first to avoid errors
    parents = []
    children = []

    all_channels = self.client.channel.listSoftwareChannels(self.session)

    for channel in all_channels:
        if channel.get('label') in to_delete:
            if channel.get('parent_label'):
                children.append(channel.get('label'))
            else:
                parents.append(channel.get('label'))

    for channel in children + parents:
        self.client.channel.software.delete(self.session, channel)

####################

def help_softwarechannel_create(self):
    print 'softwarechannel_create: Create a software channel'
    print '''usage: softwarechannel_create [options]

options:
  -n NAME
  -l LABEL
  -p PARENT_CHANNEL
  -a ARCHITECTURE ['ia32', 'ia64', 'x86_64', 'ppc',
                  'i386-sun-solaris', 'sparc-sun-solaris']'''

def do_softwarechannel_create(self, args):
    options = [ Option('-n', '--name', action='store'),
                Option('-l', '--label', action='store'),
                Option('-p', '--parent-channel', action='store'),
                Option('-a', '--arch', action='store') ]

    (args, options) = parse_arguments(args, options)

    if is_interactive(options):
        options.name = prompt_user('Channel Name:', noblank = True)
        options.label = prompt_user('Channel Label:', noblank = True)

        print 'Base Channels'
        print '-------------'
        print '\n'.join(sorted(self.list_base_channels()))
        print

        options.parent_channel = \
            prompt_user('Select Parent [blank to create a base channel]:')

        print
        print 'Architecture'
        print '------------'
        print '\n'.join(sorted(self.ARCH_LABELS))
        print
        options.arch = prompt_user('Select:')
    else:
        if not options.name:
            logging.error('A channel name is required')
            return

        if not options.label:
            logging.error('A channel label is required')
            return

        if not options.arch:
            logging.error('An architecture is required')
            return

        # default to make this a base channel
        if not options.parent_channel:
            options.parent_channel = ''

    self.client.channel.software.create(self.session,
                                        options.label,
                                        options.name,
                                        options.name, # summary
                                        'channel-%s' % options.arch,
                                        options.parent_channel)

####################

def help_softwarechannel_clone(self):
    print 'softwarechannel_clone: Clone a software channel'
    print '''usage: softwarechannel_clone [options]

options:
  -s SOURCE_CHANNEL
  -n NAME
  -l LABEL
  -p PARENT_CHANNEL
  --gpg-url GPG_URL
  --gpg-id GPG_ID
  --gpg-fingerprint GPG_FINGERPRINT
  -o do not clone any errata'''

def do_softwarechannel_clone(self, args):
    options = [ Option('-n', '--name', action='store'),
                Option('-l', '--label', action='store'),
                Option('-s', '--source-channel', action='store'),
                Option('-p', '--parent-channel', action='store'),
                Option('-o', '--original-state', action='store_true'),
                Option('', '--gpg-url', action='store'),
                Option('', '--gpg-id', action='store'),
                Option('', '--gpg-fingerprint', action='store') ]

    (args, options) = parse_arguments(args, options)

    if is_interactive(options):
        print 'Source Channels:'
        print '\n'.join(sorted(self.list_base_channels()))
        print '\n'.join(sorted(self.list_child_channels()))

        options.source_channel =  prompt_user('Select source channel:',
                                              noblank = True)

        options.name = prompt_user('Channel Name:', noblank = True)
        options.label= prompt_user('Channel Label:', noblank = True)

        print 'Base Channels:'
        print '\n'.join(sorted(self.list_base_channels()))
        print

        options.parent_channel = \
            prompt_user('Select Parent [blank to create a base channel]:')

        options.gpg_url = prompt_user('GPG URL:')
        options.gpg_id = prompt_user('GPG ID:')
        options.gpg_fingerprint = prompt_user('GPG Fingerprint:')

        options.original_state = \
            self.user_confirm('Original State (No Errata) [y/N]:',
                              ignore_yes = True)
    else:
        if not options.source_channel:
            logging.error('A source channel is required')
            return

        if not options.name:
            logging.error('A channel name is required')
            return

        if not options.label:
            logging.error('A channel label is required')
            return

        if not options.original_state:
            options.original_state = False

    details = { 'name' : options.name,
                'label' : options.label,
                'summary' : options.name }

    if options.parent_channel:
        details['parent_label'] = options.parent_channel

    if options.gpg_id:
        details['gpg_id'] = options.gpg_id

    if options.gpg_url:
        details['gpg_url'] = options.gpg_url

    if options.gpg_fingerprint:
        details['gpg_fingerprint'] = options.gpg_fingerprint

    # remove empty strings from the structure
    to_remove = []
    for key in details:
        if details[key] == '':
            to_remove.append(key)

    for key in to_remove:
        del details[key]

    self.client.channel.software.clone(self.session,
                                       options.source_channel,
                                       details,
                                       options.original_state)

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
    (args, options) = parse_arguments(args)

    if len(args) < 2:
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

    if not len(package_ids):
        logging.warning('No packages to add')
        return

    print 'Packages'
    print '--------'
    print '\n'.join(sorted(package_names))

    if not self.user_confirm('Add these packages [y/N]:'): return

    self.client.channel.software.addPackages(self.session,
                                             channel,
                                             package_ids)

####################

def help_softwarechannel_removeerrata(self):
    print 'softwarechannel_removeerrata: Remove errata from a ' + \
          'software channel'
    print 'usage: softwarechannel_removeerrata CHANNEL <ERRATA:search:XXX ...>'

def complete_softwarechannel_removeerrata(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_softwarechannel_list('', True),
                                  text)
    elif len(parts) > 2:
        return self.tab_complete_errata(text)

def do_softwarechannel_removeerrata(self, args):
    (args, options) = parse_arguments(args)

    if not len(args):
        self.help_softwarechannel_removeerrata()
        return

    channel = args[0]
    errata_wanted = self.expand_errata(args[1:])

    logging.debug('Retrieving the list of errata from source channel')
    channel_errata = self.client.channel.software.listErrata(self.session,
                                                             channel)

    errata = filter_results([ e.get('advisory_name') for e in channel_errata ],
                            errata_wanted)

    # keep the details for our matching errata so we can use them later
    errata_details = []
    for erratum in channel_errata:
        if erratum.get('advisory_name') in errata:
            errata_details.append(erratum)

    # get the packages that resolve these errata so we can add them
    # to the channel afterwards
    package_ids = []
    for erratum in errata:
        logging.debug('Retrieving packages for errata %s' % erratum)

        # get the packages affected by this errata
        packages = self.client.errata.listPackages(self.session, erratum)

        # only add packages that exist in the source channel
        for package in packages:
            if channel in package.get('providing_channels'):
                package_ids.append(package.get('id'))

    if not len(errata_details):
        logging.warning('No errata to remove')
        return

    print_errata_list(errata_details)

    print
    print 'Packages'
    print '--------'
    print '\n'.join(sorted([ self.get_package_name(p) for p in package_ids ]))

    print
    print 'Total Errata:   %s' % str(len(errata)).rjust(3)
    print 'Total Packages: %s' % str(len(package_ids)).rjust(3)

    if not self.user_confirm('Remove these errata [y/N]:'): return

    # remove the errata and the packages they brought in
    self.client.channel.software.removeErrata(self.session,
                                              channel,
                                              errata,
                                              True)

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
    (args, options) = parse_arguments(args)

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

    if not len(package_ids):
        logging.warning('No packages to remove')
        return

    print 'Packages'
    print '--------'
    print '\n'.join(sorted(package_names))

    if not self.user_confirm('Remove these packages [y/N]:'): return

    self.client.channel.software.removePackages(self.session,
                                                channel,
                                                package_ids)

####################

def help_softwarechannel_adderratabydate(self):
    print 'softwarechannel_adderratabydate: Add errata from one channel ' + \
          'into another channel based on a date range'
    print 'usage: softwarechannel_adderratabydate SOURCE DEST BEGINDATE ENDDATE'

def complete_softwarechannel_adderratabydate(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) <= 3:
        return tab_completer(self.do_softwarechannel_list('', True),
                                  text)

def do_softwarechannel_adderratabydate(self, args):
    (args, options) = parse_arguments(args)

    if len(args) != 4:
        self.help_softwarechannel_adderratabydate()
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

    # get the errata that are in the given date range
    logging.debug('Retrieving list of errata from source channel')
    errata = \
        self.client.channel.software.listErrata(self.session,
                                                source_channel,
                                                parse_time_input(begin_date),
                                                parse_time_input(end_date))

    if not len(errata):
        logging.warning('No errata found between the given dates')
        return

    # call adderrata with the list of errata from the date range
    return self.do_softwarechannel_adderrata('%s %s %s' % (
                                             source_channel,
                                             dest_channel,
                ' '.join([ e.get('advisory_name') for e in errata ])))

####################

def help_softwarechannel_adderrata(self):
    print 'softwarechannel_adderrata: Add errata from one channel ' + \
          'into another channel'
    print 'usage: softwarechannel_adderrata SOURCE DEST <ERRATA|search:XXX ...>'

def complete_softwarechannel_adderrata(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) <= 3:
        return tab_completer(self.do_softwarechannel_list('', True), text)
    elif len(parts) > 3:
        return self.tab_complete_errata(text)

def do_softwarechannel_adderrata(self, args):
    (args, options) = parse_arguments(args)

    if len(args) < 3:
        self.help_softwarechannel_adderrata()
        return

    source_channel = args[0]
    dest_channel = args[1]
    errata_wanted = self.expand_errata(args[2:])

    logging.debug('Retrieving the list of errata from source channel')
    source_errata = self.client.channel.software.listErrata(self.session,
                                                            source_channel)

    errata = filter_results([ e.get('advisory_name') for e in source_errata ],
                            errata_wanted)

    # keep the details for our matching errata so we can use them later
    errata_details = []
    for erratum in source_errata:
        if erratum.get('advisory_name') in errata:
            errata_details.append(erratum)

    # get the packages that resolve these errata so we can add them
    # to the channel afterwards
    package_ids = []
    for erratum in errata:
        logging.debug('Retrieving packages for errata %s' % erratum)

        # get the packages affected by this errata
        packages = self.client.errata.listPackages(self.session, erratum)

        # only add packages that exist in the source channel
        for package in packages:
            if source_channel in package.get('providing_channels'):
                package_ids.append(package.get('id'))

    if not len(errata):
        logging.warning('No errata to add')
        return

    # show the user which errata will be added
    print_errata_list(errata_details)

    print
    print 'Packages'
    print '--------'
    print '\n'.join(sorted([ self.get_package_name(p) for p in package_ids ]))

    print
    print 'Total Errata:   %s' % str(len(errata)).rjust(3)
    print 'Total Packages: %s' % str(len(package_ids)).rjust(3)

    if not self.user_confirm('Add these errata and packages [y/N]:'): return

    if self.check_api_version('10.12'):
        merged = self.client.channel.software.mergeErrata(self.session,
                                                          source_channel,
                                                          dest_channel,
                                                          errata)

        # show the user which errata were actually merged
        if self.options.debug:
            print
            print "Errata Merged"
            print "-------------"
            print
            print_errata_list(merged)
    else:
        # clone each erratum individually because the process is slow and it can
        # lead to timeouts on the server
        for erratum in errata:
            logging.debug('Cloning %s' % erratum)
            self.client.errata.clone(self.session, dest_channel, [erratum])

    # add the affected packages to the channel
    logging.info('Adding required packages to %s' % dest_channel)
    self.client.channel.software.addPackages(self.session,
                                             dest_channel,
                                             package_ids)

    # regenerate the errata cache since we just cloned errata
    self.generate_errata_cache(True)

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
