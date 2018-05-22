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
# Copyright (c) 2011--2018 Red Hat, Inc.
#

# NOTE: the 'self' variable is an instance of SpacewalkShell

# wildcard import
# pylint: disable=W0401,W0614

# unused argument
# pylint: disable=W0613

# invalid function name
# pylint: disable=C0103

try:
    from urllib import ContentTooShortError
except ImportError:
    from urllib.error import ContentTooShortError
try:
    from urllib import urlretrieve
except ImportError:
    from urllib.request import urlretrieve
try:
    from xmlrpc import client as xmlrpclib
except ImportError:
    import xmlrpclib
from spacecmd.utils import *


CHECKSUM = ['sha1', 'sha256', 'sha384', 'sha512']

def help_softwarechannel_list(self):
    print('softwarechannel_list: List all available software channels')
    print('''usage: softwarechannel_list [options]')
options:
  -v verbose (display label and summary)
  -t tree view (pretty-print(child-channels))
''')


def do_softwarechannel_list(self, args, doreturn=False):
    arg_parser = get_argument_parser()
    arg_parser.add_argument('-v', '--verbose', action='store_true')
    arg_parser.add_argument('-t', '--tree', action='store_true')

    (args, options) = parse_command_arguments(args, arg_parser)

    if (options.tree):
        labels = self.list_base_channels()
    else:
        channels = self.client.channel.listAllChannels(self.session)
        labels = [c.get('label') for c in channels]

    # filter the list if arguments were passed
    if args:
        labels = filter_results(labels, args, True)

    if doreturn:
        return labels
    elif labels:
        if (options.verbose):
            for l in sorted(labels):
                details = self.client.channel.software.getDetails(
                    self.session, l)
                print("%s : %s" % (l, details['summary']))
                if (options.tree):
                    for c in self.list_child_channels(parent=l):
                        cdetails = self.client.channel.software.getDetails(
                            self.session, c)
                        print(" |-%s : %s" % (c, cdetails['summary']))
        else:
            for l in sorted(labels):
                print("%s" % l)
                if (options.tree):
                    for c in self.list_child_channels(parent=l):
                        print(" |-%s" % c)

####################


def help_softwarechannel_listmanageablechannels(self):
    print('softwarechannel_listmanageablechannels: List all software channels')
    print('                                        manageable by current user')
    print('''usage: softwarechannel_listmanageablechannels [options]
options:
  -v verbose (display label and summary)''')


def do_softwarechannel_listmanageablechannels(self, args, doreturn=False):
    arg_parser = get_argument_parser()
    arg_parser.add_argument('-v', '--verbose', action='store_true')

    (args, options) = parse_command_arguments(args, arg_parser)

    channels = self.client.channel.listManageableChannels(self.session)
    labels = [c.get('label') for c in channels]

    # filter the list if arguments were passed
    if args:
        labels = filter_results(labels, args, True)

    if doreturn:
        return labels
    elif labels:
        if options.verbose:
            for l in sorted(labels):
                details = \
                    self.client.channel.software.getDetails(self.session, l)

                print("%s : %s" % (l, details['summary']))
        else:
            for l in sorted(labels):
                print("%s" % l)

####################


def help_softwarechannel_listbasechannels(self):
    print('softwarechannel_listbasechannels: List all base software channels')
    print('''usage: softwarechannel_listbasechannels [options])
options:
  -v verbose (display label and summary)''')


def do_softwarechannel_listbasechannels(self, args):
    arg_parser = get_argument_parser()
    arg_parser.add_argument('-v', '--verbose', action='store_true')

    (args, options) = parse_command_arguments(args, arg_parser)

    channels = self.list_base_channels()

    if channels:
        if (options.verbose):
            for c in sorted(channels):
                details = \
                    self.client.channel.software.getDetails(self.session, c)
                print("%s : %s" % (c, details['summary']))
        else:
            print('\n'.join(sorted(channels)))

####################


def help_softwarechannel_listchildchannels(self):
    print('softwarechannel_listchildchannels: List child software channels')
    print('usage:')
    print('softwarechannel_listchildchannels [options]')
    print('softwarechannel_listchildchannels : List all child channels')
    print('softwarechannel_listchildchannels CHANNEL : List children for a' +
          'specific base channel')
    print('options:\n -v verbose (display label and summary)')


def do_softwarechannel_listchildchannels(self, args):
    arg_parser = get_argument_parser()
    arg_parser.add_argument('-v', '--verbose', action='store_true')

    (args, options) = parse_command_arguments(args, arg_parser)
    if not args:
        channels = self.list_child_channels()
    else:
        channels = self.list_child_channels(parent=args[0])

    if channels:
        if (options.verbose):
            for c in sorted(channels):
                details = \
                    self.client.channel.software.getDetails(self.session, c)
                print("%s : %s" % (c, details['summary']))
        else:
            print('\n'.join(sorted(channels)))

####################


def help_softwarechannel_listsystems(self):
    print('softwarechannel_listsystems: List all systems subscribed to')
    print('                             a software channel')
    print('usage: softwarechannel_listsystems CHANNEL')


def complete_softwarechannel_listsystems(self, text, line, beg, end):
    return tab_completer(self.do_softwarechannel_list('', True), text)


def do_softwarechannel_listsystems(self, args, doreturn=False):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
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
        if systems:
            print('\n'.join(sorted(systems)))

####################


def help_softwarechannel_listpackages(self):
    print('softwarechannel_listpackages: List the most recent packages')
    print('                              available from a software channel')
    print('usage: softwarechannel_listpackages CHANNEL')


def complete_softwarechannel_listpackages(self, text, line, beg, end):
    if len(line.split(' ')) == 2:
        return tab_completer(self.do_softwarechannel_list('', True),
                             text)

    return []


def do_softwarechannel_listpackages(self, args, doreturn=False):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_softwarechannel_listpackages()
        return

    channel = args[0]

    packages = self.client.channel.software.listLatestPackages(self.session,
                                                               channel)

    packages = build_package_names(packages)

    if doreturn:
        return packages
    else:
        if packages:
            print('\n'.join(sorted(packages)))

####################


def help_softwarechannel_listallpackages(self):
    print('softwarechannel_listallpackages: List all packages in a channel')
    print('usage: softwarechannel_listallpackages CHANNEL')


def complete_softwarechannel_listallpackages(self, text, line, beg, end):
    if len(line.split(' ')) == 2:
        return tab_completer(self.do_softwarechannel_list('', True),
                             text)

    return []


def do_softwarechannel_listallpackages(self, args, doreturn=False):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_softwarechannel_listallpackages()
        return

    channel = args[0]

    packages = self.client.channel.software.listAllPackages(self.session,
                                                            channel)

    packages = build_package_names(packages)

    if doreturn:
        return packages
    else:
        if packages:
            print('\n'.join(sorted(packages)))

####################


def filter_latest_packages(pkglist):
    # This takes a list of package dicts, and returns a new list
    # which contains only the latest version, for each arch

    # First we generate a dict, indexed by a compound (tuple) key based on
    # arch and name, so we can store the latest version of each package
    # for each arch.  This approach avoids nested loops :)
    latest = {}
    for p in pkglist:
        tuplekey = p['name'], p['arch_label']
        if tuplekey not in latest:
            latest[tuplekey] = p
        else:
            # Already have this package, is p newer?
            if p == latest_pkg(p, latest[tuplekey]):
                latest[tuplekey] = p

    # Then return the dict items as a list
    return latest.values()


def help_softwarechannel_listlatestpackages(self):
    print('softwarechannel_listlatestpackages: List the newest version of all packages in a channel')
    print('usage: softwarechannel_listlatestpackages CHANNEL')


def complete_softwarechannel_listlatestpackages(self, text, line, beg, end):
    if len(line.split(' ')) == 2:
        return tab_completer(self.do_softwarechannel_list('', True),
                             text)

    return []


def do_softwarechannel_listlatestpackages(self, args, doreturn=False):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_softwarechannel_listlatestpackages()
        return

    channel = args[0]

    allpackages = self.client.channel.software.listAllPackages(self.session,
                                                               channel)

    latestpackages = filter_latest_packages(allpackages)

    packages = build_package_names(latestpackages)

    if doreturn:
        return packages
    else:
        if packages:
            print('\n'.join(sorted(packages)))

####################


def help_softwarechannel_setdetails(self):
    print('softwarechannel_setdetails: Modify details of a software channel')
    print('''usage: softwarechannel_setdetails [options] <CHANNEL ...>)

options, at least one of which must be given:
  -n NAME
  -d DESCRIPTION
  -s SUMMARY
  -c CHECKSUM %s
  -m MAINTAINER_NAME
  -e MAINTAINER_EMAIL
  -p MAINTAINER_PHONE
  -u GPG_URL
  -i GPG_ID
  -f GPG_FINGERPRINT''' % CHECKSUM)


def complete_softwarechannel_setdetails(self, text, line, beg, end):
    return tab_completer(self.do_softwarechannel_list('', True), text)


def do_softwarechannel_setdetails(self, args):
    # pylint: disable=R0911
    arg_parser = get_argument_parser()
    arg_parser.add_argument('-n', '--name')
    arg_parser.add_argument('-s', '--summary')
    arg_parser.add_argument('-d', '--description')
    arg_parser.add_argument('-c', '--checksum')
    arg_parser.add_argument('-m', '--maintainer_name')
    arg_parser.add_argument('-e', '--maintainer_email')
    arg_parser.add_argument('-p', '--maintainer_phone')
    arg_parser.add_argument('-u', '--gpg_url')
    arg_parser.add_argument('-i', '--gpg_id')
    arg_parser.add_argument('-f', '--gpg_fingerprint')

    (args, options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_softwarechannel_setdetails()
        return

    new_details = {}
    if options.name:
        new_details['name'] = options.name
    if options.summary:
        new_details['summary'] = options.summary
    if options.description:
        new_details['description'] = options.description
    if options.checksum:
        new_details['checksum_label'] = options.checksum
    if options.maintainer_name:
        new_details['maintainer_name'] = options.maintainer_name
    if options.maintainer_email:
        new_details['maintainer_email'] = options.maintainer_email
    if options.maintainer_phone:
        new_details['maintainer_phone'] = options.maintainer_phone
    if options.gpg_url:
        new_details['gpg_key_url'] = options.gpg_url
    if options.gpg_id:
        new_details['gpg_key_id'] = options.gpg_id
    if options.gpg_fingerprint:
        new_details['gpg_key_fp'] = options.gpg_fingerprint

    if not new_details:
        logging.error('At least one attribute to set must be given')
        return

    # allow globbing of software channel names
    channels = filter_results(self.do_softwarechannel_list('', True), args)
    if len(channels) < 1:
        logging.info('No channels matching that label')
        return

    # channel names must be unique, so if we are asked to set it,
    # take special precautions: first: check if we're doing this for
    # more than one channel (because if we do, first might succeed,
    # all the rest will obviously fail),
    # second: check if there's any other channel already using this name.
    # Not reusing softwarechannel_check_existing() here because it
    # also fails on same label.
    if new_details.get('name'):
        if len(channels) > 1:
            logging.error('Setting same name for more than ' + \
                          'one channel will fail')
            return
        logging.debug('checking other channels for name "%s"' %
                      new_details.get('name'))
        for c in self.list_base_channels() + self.list_child_channels():
            cd = self.client.channel.software.getDetails(self.session, c)
            if cd.get('name') == new_details.get('name'):
                logging.error('Name "%s" already in use by channel %s' %
                              (cd.get('name'), cd.get('label')))
                return

    # get confirmation
    print('Setting following attributes...')
    print('')
    if new_details.get('name'):
        print('Name:             %s' % new_details.get('name'))
    if new_details.get('summary'):
        print('Summary:          %s' % new_details.get('summary'))
    if new_details.get('description'):
        print('Description:      %s' % new_details.get('description'))
    if new_details.get('checksum_label'):
        print('Checksum:         %s' % new_details.get('checksum_label'))
    if new_details.get('maintainer_name'):
        print('Maintainer name:  %s' % new_details.get('maintainer_name'))
    if new_details.get('maintainer_email'):
        print('Maintainer email: %s' % new_details.get('maintainer_email'))
    if new_details.get('maintainer_phone'):
        print('Maintainer phone: %s' % new_details.get('maintainer_phone'))
    if new_details.get('gpg_key_id'):
        print('GPG Key:          %s' % new_details.get('gpg_key_id'))
    if new_details.get('gpg_key_fp'):
        print('GPG Fingerprint:  %s' % new_details.get('gpg_key_fp'))
    if new_details.get('gpg_key_url'):
        print('GPG URL:          %s' % new_details.get('gpg_key_url'))
    print('')
    print('... for the following channels:')
    print('\n'.join(channels))
    print('')
    if not self.user_confirm('Apply? [y/N]:'):
        return

    logging.debug('new channel details dictionary:')
    logging.debug(new_details)
    num_changed = 0
    for channel in channels:
        logging.debug('getting ID for channel %s' % channel)
        try:
            details = self.client.channel.software.getDetails(self.session,
                                                              channel)
        except xmlrpclib.Fault as e:
            logging.error('Could not get details for %s' % channel)
            logging.error(e)
            return
        channel_id = details.get('id')
        logging.debug('setting details for channel %s (%d)' % (channel,
                                                               channel_id))
        try:
            self.client.channel.software.setDetails(self.session,
                                                    channel_id,
                                                    new_details)
            num_changed += 1
        except xmlrpclib.Fault as e:
            logging.error('Error while setting details for %s' % channel)
            logging.error(e)
            return
    logging.info('Channels changed: %d' % num_changed)

####################


def help_softwarechannel_details(self):
    print('softwarechannel_details: Show the details of a software channel')
    print('usage: softwarechannel_details <CHANNEL ...>')


def complete_softwarechannel_details(self, text, line, beg, end):
    return tab_completer(self.do_softwarechannel_list('', True), text)


def do_softwarechannel_details(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_softwarechannel_details()
        return

    # allow globbing of software channel names
    channels = filter_results(self.do_softwarechannel_list('', True), args)

    add_separator = False

    for channel in channels:
        details = self.client.channel.software.getDetails(
            self.session, channel)

        systems = \
            self.client.channel.software.listSubscribedSystems(
                self.session, channel)

        trees = self.client.kickstart.tree.list(self.session,
                                                channel)

        packages = \
            self.client.channel.software.listAllPackages(
                self.session, channel)

        if add_separator:
            print(self.SEPARATOR)
        add_separator = True

        print('Label:              %s' % details.get('label'))
        print('Name:               %s' % details.get('name'))
        print('Architecture:       %s' % details.get('arch_name'))
        print('Parent:             %s' % details.get('parent_channel_label'))
        print('Systems Subscribed: %s' % len(systems))
        print('Number of Packages: %i' % len(packages))

        if details.get('summary'):
            print('')
            print('Summary')
            print('-------')
            print('\n'.join(wrap(details.get('summary'))))

        if details.get('description'):
            print('')
            print('Description')
            print('-----------')
            print('\n'.join(wrap(details.get('description'))))

        print('')
        print('GPG Key:            %s' % details.get('gpg_key_id'))
        print('GPG Fingerprint:    %s' % details.get('gpg_key_fp'))
        print('GPG URL:            %s' % details.get('gpg_key_url'))

        if trees:
            print('')
            print('Kickstart Trees')
            print('---------------')
            for tree in trees:
                print(tree.get('label'))

        if details.get('contentSources'):
            print('')
            print('Repos')
            print('-----')
            for repo in details.get('contentSources'):
                print(repo.get('label'))

####################


def help_softwarechannel_listerrata(self):
    print('softwarechannel_listerrata: List the errata associated with a')
    print('                            software channel')
    print('usage: softwarechannel_listerrata <CHANNEL ...> [from=yyyymmdd [to=yyyymmdd]]')


def complete_softwarechannel_listerrata(self, text, line, beg, end):
    return tab_completer(self.do_softwarechannel_list('', True), text)


def do_softwarechannel_listerrata(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
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
            print('Channel: %s' % channel)
            print('')

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

        if add_separator:
            print(self.SEPARATOR)
        add_separator = True

####################

def help_softwarechannel_listarches(self):
    print("softwarechannel_listarches: lists the potential software")
    print("                            channel architectures that can be created")
    print("usage: softwarechannel_listarches")
    print("options:")
    print("    -v verbose (display label and name)")

def do_softwarechannel_listarches(self, args):
    arg_parser = get_argument_parser()
    arg_parser.add_argument('-v', '--verbose', action='store_true')

    (args, options) = parse_command_arguments(args, arg_parser)

    arches = self.client.channel.software.listArches(self.session)

    for arch in sorted(arches):
        if (options.verbose):
            print("%s (%s)" % (arch["label"], arch["name"]))
        else:
            print("%s" % arch["label"])

####################

def help_softwarechannel_delete(self):
    print('softwarechannel_delete: Delete a software channel')
    print('usage: softwarechannel_delete <CHANNEL ...>')


def complete_softwarechannel_delete(self, text, line, beg, end):
    return tab_completer(self.do_softwarechannel_list('', True), text)


def do_softwarechannel_delete(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_softwarechannel_delete()
        return

    channels = args

    # find all matching channels
    to_delete = filter_results(
        self.do_softwarechannel_list('', True), channels)

    if not to_delete:
        return

    print('Channels')
    print('--------')
    print('\n'.join(sorted(to_delete)))

    if not self.user_confirm('Delete these channels [y/N]:'):
        return

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
def help_softwarechannel_update(self):
    print('softwarechannel_update: Update a software channel')
    print('''usage: softwarechannel_update LABEL(To identify the channel) [options]
options:
  -l LABEL(Required)
  -n NAME
  -s SUMMARY
  -d DESCRIPTION
  -c CHECKSUM %s
  -u GPG-URL
  -i GPG-ID
  -f GPG-FINGERPRINT''' % CHECKSUM)


def do_softwarechannel_update(self, args):
    arg_parser = get_argument_parser()
    arg_parser.add_argument('-n', '--name')
    arg_parser.add_argument('-l', '--label')
    arg_parser.add_argument('-s', '--summary')
    arg_parser.add_argument('-d', '--description')
    arg_parser.add_argument('-c', '--checksum')
    arg_parser.add_argument('-u', '--gpg_url')
    arg_parser.add_argument('-i', '--gpg_id')
    arg_parser.add_argument('-f', '--gpg_fingerprint')

    (args, options) = parse_command_arguments(args, arg_parser)

    if is_interactive(options):
        options.label = prompt_user('Channel Label:', noblank=True)

        print('')
        print('New Name (blank to keep unchanged)')
        print('------------')
        print('')
        options.name = prompt_user('Name:')

        print('')
        print('New Summary (blank to keep unchanged)')
        print('------------')
        print('')
        options.summary = prompt_user('Summary:')

        print('')
        print('New Description (blank to keep unchanged)')
        print('------------')
        print('')
        options.description = prompt_user('Description:')

        print('')
        print('New Checksum type (blank to keep unchanged)')
        print('------------')
        print('\n'.join(sorted(self.CHECKSUM)))
        print('')
        options.checksum = prompt_user('Select:')

        print('')
        print('New GPG URL (blank to keep unchanged)')
        print('------------')
        print('')
        options.gpg_url = prompt_user('GPG URL:')

        print('')
        print('New GPG ID (blank to keep unchanged)')
        print('------------')
        print('')
        options.gpg_id = prompt_user('GPG ID:')

        print('')
        print('New GPG Fingerprint (blank to keep unchanged)')
        print('------------')
        print('')
        options.gpg_fingerprint = prompt_user('GPG Fingerprint:')

    if not options.label:
        logging.error('A channel label is required to identify the channel')
        return

    details = {}
    if options.name:
        details['name'] = options.name

    if options.summary:
        details['summary'] = options.summary

    if options.description:
        details['description'] = options.description

    if options.checksum:
        details['checksum_label'] = options.checksum

    if options.gpg_id:
        details['gpg_key_id'] = options.gpg_id

    if options.gpg_url:
        details['gpg_key_url'] = options.gpg_url

    if options.gpg_fingerprint:
        details['gpg_key_fp'] = options.gpg_fingerprint

    self.client.channel.software.setDetails(self.session, options.label, details)
####################


def help_softwarechannel_create(self):
    print('softwarechannel_create: Create a software channel')
    print('''usage: softwarechannel_create [options])

options:
  -n NAME
  -l LABEL
  -s SUMMARY
  -p PARENT_CHANNEL
  -a ARCHITECTURE
  -c CHECKSUM %s
  -u GPG_URL
  -i GPG_ID
  -f GPG_FINGERPRINT''' % CHECKSUM)


def do_softwarechannel_create(self, args):
    arches = self.client.channel.software.listArches(self.session)
    self.ARCH_LABELS = [x["label"].replace("channel-","") for x in arches]
    arg_parser = get_argument_parser()
    arg_parser.add_argument('-n', '--name')
    arg_parser.add_argument('-l', '--label')
    arg_parser.add_argument('-s', '--summary')
    arg_parser.add_argument('-p', '--parent-channel')
    arg_parser.add_argument('-a', '--arch')
    arg_parser.add_argument('-c', '--checksum')
    arg_parser.add_argument('-u', '--gpg_url')
    arg_parser.add_argument('-i', '--gpg_id')
    arg_parser.add_argument('-f', '--gpg_fingerprint')

    (args, options) = parse_command_arguments(args, arg_parser)

    if is_interactive(options):
        options.name = prompt_user('Channel Name:', noblank=True)
        options.label = prompt_user('Channel Label:', noblank=True)
        options.summary = prompt_user('Channel Summary:', noblank=True)

        print('Base Channels')
        print('-------------')
        print('\n'.join(sorted(self.list_base_channels())))
        print('')

        options.parent_channel = \
            prompt_user('Select Parent [blank to create a base channel]:')

        print('')
        print('Architecture')
        print('------------')
        print('\n'.join(sorted(self.ARCH_LABELS)))
        print('')
        options.arch = prompt_user('Select:')

        print('')
        print('Checksum type')
        print('------------')
        print('\n'.join(sorted(self.CHECKSUM)))
        print('')
        options.checksum = prompt_user('Select:')

        print('')
        print('GPG URL')
        print('------------')
        print('')
        options.gpg_url = prompt_user('GPG URL:')

        print('')
        print('GPG ID')
        print('------------')
        print('')
        options.gpg_id = prompt_user('GPG ID:')

        print('')
        print('GPG Fingerprint')
        print('---------------')
        print('')
        options.gpg_fingerprint = prompt_user('GPG Fingerprint:')

    if validate_required_data(options):
        set_default_data(options)
        gpgData = get_gpg_data(options)
        self.client.channel.software.create(self.session, options.label, options.name, options.summary,
                                            'channel-%s' % options.arch, options.parent_channel,
                                            options.checksum, gpgData
                                           )

####################


def get_gpg_data(options):
    gpgData = {}

    if options.gpg_url:
        gpgData['url'] = options.gpg_url

    if options.gpg_id:
        gpgData['id'] = options.gpg_id

    if options.gpg_fingerprint:
        gpgData['fingerprint'] = options.gpg_fingerprint

    return gpgData
####################


def set_default_data(options):
    if not options.arch:
        options.arch = 'x86_64'

    if not options.checksum:
        options.checksum = 'sha256'

    if not options.parent_channel:
        options.parent_channel = ''

    # Summary is a required field,
    # but we don't want to break the interface
    # then if it is not provided it is set to the 'name' value
    if not options.summary:
        options.summary = options.name
####################


def validate_required_data(options):
    if not options.name:
        logging.error('A channel name is required')
        return False

    if not options.label:
        logging.error('A channel label is required')
        return False

    return True
######################


def softwarechannel_check_existing(self, name, label):
    # Catch label or name which already exists, duplicate label throws a
    # descriptive xmlrpc error, but duplicate name results in ISE
    for c in self.list_base_channels() + self.list_child_channels():
        cd = self.client.channel.software.getDetails(self.session, c)
        if cd['name'] == name:
            logging.error("Name %s already in use by channel %s" %
                          (name, cd['label']))
            return True
        if cd['label'] == label:
            logging.error("Label %s already in use by channel %s" %
                          (label, cd['label']))
            return True
    return False
########################


def help_softwarechannel_clone(self):
    print('softwarechannel_clone: Clone a software channel')
    print('''usage: softwarechannel_clone [options])

options:
  -s SOURCE_CHANNEL
  -n NAME
  -l LABEL
  -p PARENT_CHANNEL
  --gpg-copy/-g (copy SOURCE_CHANNEL GPG details)
  --gpg-url GPG_URL
  --gpg-id GPG_ID
  --gpg-fingerprint GPG_FINGERPRINT
  -o do not clone any errata
  --regex/-x "s/foo/bar" : Optional regex replacement,
        replaces foo with bar in the clone name and label''')


def do_softwarechannel_clone(self, args):
    arg_parser = get_argument_parser()
    arg_parser.add_argument('-n', '--name')
    arg_parser.add_argument('-l', '--label')
    arg_parser.add_argument('-s', '--source-channel')
    arg_parser.add_argument('-p', '--parent-channel')
    arg_parser.add_argument('-x', '--regex')
    arg_parser.add_argument('-o', '--original-state', action='store_true')
    arg_parser.add_argument('-g', '--gpg-copy', action='store_true')
    arg_parser.add_argument('--gpg-url')
    arg_parser.add_argument('--gpg-id')
    arg_parser.add_argument('--gpg-fingerprint')

    (args, options) = parse_command_arguments(args, arg_parser)

    if is_interactive(options):
        print('Source Channels:')
        print('\n'.join(sorted(self.list_base_channels())))
        print('\n'.join(sorted(self.list_child_channels())))

        options.source_channel = prompt_user('Select source channel:',noblank=True)
        options.name = prompt_user('Channel Name:', noblank=True)
        options.label = prompt_user('Channel Label:', noblank=True)

        print('Base Channels:')
        print('\n'.join(sorted(self.list_base_channels())))
        print('')

        options.parent_channel = \
            prompt_user('Select Parent [blank to create a base channel]:')

        options.gpg_copy = \
            self.user_confirm('Copy source channel GPG details? [y/N]:',
                              ignore_yes=True)
        if not options.gpg_copy:
            options.gpg_url = prompt_user('GPG URL:')
            options.gpg_id = prompt_user('GPG ID:')
            options.gpg_fingerprint = prompt_user('GPG Fingerprint:')

        options.original_state = \
            self.user_confirm('Original State (No Errata) [y/N]:',
                              ignore_yes=True)
    else:
        if not options.source_channel:
            logging.error('A source channel is required')
            return

        if not options.name and not options.regex:
            logging.error('A channel name is required')
            return

        if not options.label and not options.regex:
            logging.error('A channel label is required')
            return

        if not options.original_state:
            options.original_state = False

        if options.regex:
            newvalues =do_regx_replacement(self,options.source_channel, options)
            options.label = newvalues['label']
            if not options.name:
                options.name = newvalues['name']

    # Catch label or name which already exists
    if self.softwarechannel_check_existing(options.name, options.label):
        return

    details = {'name': options.name, 'label': options.label}
    if options.parent_channel:
        details['parent_label'] = options.parent_channel

    clone_channel(self,options.source_channel, options, details)


####################


def help_softwarechannel_clonetree(self):
    print('softwarechannel_clonetree: Clone a software channel and its child channels')
    print('''usage: softwarechannel_clonetree [options])
             e.g    softwarechannel_clonetree foobasechannel -p "my_"
                    softwarechannel_clonetree foobasechannel -x "s/foo/bar"
                    softwarechannel_clonetree foobasechannel -x "s/^/my_"

options:
  -s/--source-channel SOURCE_CHANNEL
  -p/--prefix PREFIX (is prepended to the label and name of all channels)
  --gpg-copy/-g (copy GPG details for correspondoing source channel))
  --gpg-url GPG_URL (applied to all channels)
  --gpg-id GPG_ID (applied to all channels)
  --gpg-fingerprint(GPG_FINGERPRINT (applied to all channels))
  -o do not clone any errata
  --regex/-x "s/foo/bar" : Optional regex replacement,
        replaces foo with bar in the clone name, label and description''')


def do_softwarechannel_clonetree(self, args):
    arg_parser = get_argument_parser()
    arg_parser.add_argument('-s', '--source-channel')
    arg_parser.add_argument('-p', '--prefix')
    arg_parser.add_argument('-x', '--regex')
    arg_parser.add_argument('-o', '--original-state', action='store_true')
    arg_parser.add_argument('-g', '--gpg-copy', action='store_true')
    arg_parser.add_argument('--gpg-url')
    arg_parser.add_argument('--gpg-id')
    arg_parser.add_argument('--gpg-fingerprint')

    (args, options) = parse_command_arguments(args, arg_parser)

    if is_interactive(options):
        print('Source Channels:')
        print('\n'.join(sorted(self.list_base_channels())))

        options.source_channel = prompt_user('Select source channel:',noblank=True)
        options.prefix = prompt_user('Prefix:', noblank=True)
        options.gpg_copy = \
            self.user_confirm('Copy source channel GPG details? [y/N]:', ignore_yes=True)
        if not options.gpg_copy:
            options.gpg_url = prompt_user('GPG URL:')
            options.gpg_id = prompt_user('GPG ID:')
            options.gpg_fingerprint = prompt_user('GPG Fingerprint:')

        options.original_state = \
            self.user_confirm('Original State (No Errata) [y/N]:', ignore_yes=True)
    else:
        if not options.source_channel:
            logging.error('A source channel is required')
            return

        if not options.prefix and not options.regex:
            logging.error('A prefix or regex is required')
            return

        if not options.original_state:
            options.original_state = False

    channels = [options.source_channel]
    if not options.source_channel in self.list_base_channels():
        logging.error("Channel does not exist or is not a base channel!")
        self.help_softwarechannel_clonetree()
        return
    logging.debug("--child mode specified, finding children of %s\n" % options.source_channel)
    children = self.list_child_channels(parent=options.source_channel)
    logging.debug("Found children %s\n" % children)
    for c in children:
        channels.append(c)

    logging.debug("channels=%s" % channels)
    parent_channel = None
    for ch in channels:
        logging.debug("Cloning %s" % ch)
        label = None
        name = None
        if options.regex:
            # Expect option to be formatted like a sed-replacement, s/foo/bar
            newvalues = do_regx_replacement(self, ch, options)
            label = newvalues['label']
            name = newvalues['name']

        elif options.prefix:
            srcdetails = self.client.channel.software.getDetails(self.session, ch)
            label = options.prefix + srcdetails['label']
            name = options.prefix + srcdetails['name']
        else:
            # Shouldn't ever get here due to earlier checks
            logging.error("called without prefix or regex option!")
            return

        # Catch label or name which already exists
        if self.softwarechannel_check_existing(name, label):
            return

        details = {'name': name, 'label': label}
        if parent_channel:
            details['parent_label'] = parent_channel
        clone_channel(self, ch, options, details)

        # If this is the first call we are on the base-channel clone and we
        # need to set parent_channel to the new cloned base-channel label
        if not parent_channel:
            parent_channel = details['label']

###################


def clone_channel(self, channel, options, details) :

    if options.gpg_copy:
        srcdetails = self.client.channel.software.getDetails(self.session, channel)
        copy_gpg_values_from_source(details, srcdetails)

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
    logging.info("Cloning %s as %s" % (channel, details['label']))
    self.client.channel.software.clone(self.session,
                                       channel,
                                       details,
                                       options.original_state)

###################


def copy_gpg_values_from_source(details, srcdetails):
    if srcdetails['gpg_key_url']:
        details['gpg_key_url'] = srcdetails['gpg_key_url']
        logging.debug("copying gpg_key_url=%s" % srcdetails['gpg_key_url'])
    if srcdetails['gpg_key_id']:
        details['gpg_key_id'] = srcdetails['gpg_key_id']
        logging.debug("copying gpg_key_id=%s" % srcdetails['gpg_key_id'])
    if srcdetails['gpg_key_fp']:
        details['gpg_key_fp'] = srcdetails['gpg_key_fp']
        logging.debug("copying gpg_key_fp=%s" % srcdetails['gpg_key_fp'])

####################


# If the -x/--regex option is passed, do a sed-style replacement over
# the name, label and description. from the source channel to create
# the name, label and description for the clone channel.
# This makes it easier to clone based on a known naming convention
def do_regx_replacement(self,channel, options):
    newvalues ={}
    # Expect option to be formatted like a sed-replacement, s/foo/bar
    findstr = options.regex.split("/")[1]
    replacestr = options.regex.split("/")[2]
    logging.debug("--regex selected with %s, replacing %s with %s" %(options.regex, findstr, replacestr))
    srcdetails = self.client.channel.software.getDetails(self.session, channel)

    newvalues['name'] = re.sub(findstr, replacestr, srcdetails['name'])
    newvalues['label'] = re.sub(findstr, replacestr, channel)
    logging.debug("regex mode : %s %s %s" % (options.source_channel,  newvalues['name'], newvalues['label']))

    return newvalues

####################


def help_softwarechannel_addpackages(self):
    print('softwarechannel_addpackages: Add packages to a software channel')
    print('usage: softwarechannel_addpackages CHANNEL <PACKAGE ...>')


def complete_softwarechannel_addpackages(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_softwarechannel_list('', True),
                             text)
    elif len(parts) > 2:
        return tab_completer(self.get_package_names(True), text)


def do_softwarechannel_addpackages(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if len(args) < 2:
        self.help_softwarechannel_addpackages()
        return

    # Take the first argument as the channel and validate it
    channel = args.pop(0)
    if not channel in self.do_softwarechannel_list('', True):
        logging.error("%s is not a valid channel" % channel)
        self.help_softwarechannel_addpackages()
        return

    # expand the arguments to search for packages
    package_names = []
    for item in args:
        package_names.extend(self.do_package_search(item, True))

    # get the package IDs from the names
    package_ids = []
    for package in package_names:
        package_ids += self.get_package_id(package)

    if not package_ids:
        logging.warning('No packages to add')
        return

    print('Packages')
    print('--------')
    print('\n'.join(sorted(package_names)))

    if not self.user_confirm('Add these packages [y/N]:'):
        return

    self.client.channel.software.addPackages(self.session,
                                             channel,
                                             package_ids)

####################


def help_softwarechannel_removeerrata(self):
    print('softwarechannel_removeerrata: Remove errata from a software channel')
    print('usage: softwarechannel_removeerrata CHANNEL <ERRATA:search:XXX ...>')


def complete_softwarechannel_removeerrata(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_softwarechannel_list('', True),
                             text)
    elif len(parts) > 2:
        return self.tab_complete_errata(text)


def do_softwarechannel_removeerrata(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_softwarechannel_removeerrata()
        return

    channel = args[0]
    errata_wanted = self.expand_errata(args[1:])

    logging.debug('Retrieving the list of errata from source channel')
    channel_errata = self.client.channel.software.listErrata(self.session,
                                                             channel)

    errata = filter_results([e.get('advisory_name') for e in channel_errata],
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

    if not errata_details:
        logging.warning('No errata to remove')
        return

    print_errata_list(errata_details)

    print('')
    print('Packages')
    print('--------')
    print('\n'.join(sorted([self.get_package_name(p) for p in package_ids])))

    print('')
    print('Total Errata:   %s' % str(len(errata)).rjust(3))
    print('Total Packages: %s' % str(len(package_ids)).rjust(3))

    if not self.user_confirm('Remove these errata [y/N]:'):
        return

    # remove the errata and the packages they brought in
    self.client.channel.software.removeErrata(self.session,
                                              channel,
                                              errata,
                                              True)

####################


def help_softwarechannel_removepackages(self):
    print('softwarechannel_removepackages: Remove packages from a ' +
          'software channel')
    print('usage: softwarechannel_removepackages CHANNEL <PACKAGE ...>')


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
        except xmlrpclib.Fault:
            package_names = []

        return tab_completer(package_names, text)


def do_softwarechannel_removepackages(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
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
        package_ids += self.get_package_id(package)

    if not package_ids:
        logging.warning('No packages to remove')
        return

    print('Packages')
    print('--------')
    print('\n'.join(sorted(package_names)))

    if not self.user_confirm('Remove these packages [y/N]:'):
        return

    self.client.channel.software.removePackages(self.session,
                                                channel,
                                                package_ids)

####################


def help_softwarechannel_adderratabydate(self):
    print('softwarechannel_adderratabydate: Add errata from one channel ' +
          'into another channel based on a date range')
    print('usage: softwarechannel_adderratabydate [options] SOURCE DEST BEGINDATE ENDDATE')
    print('Date format : YYYYMMDD')
    print('Options:')
    print('        -p/--publish : Publish errata to the channel (don\'t clone)')


def complete_softwarechannel_adderratabydate(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) <= 3:
        return tab_completer(self.do_softwarechannel_list('', True),
                             text)


def do_softwarechannel_adderratabydate(self, args):
    arg_parser = get_argument_parser()
    arg_parser.add_argument('-p', '--publish', action='store_true')

    (args, options) = parse_command_arguments(args, arg_parser)

    if len(args) != 4:
        self.help_softwarechannel_adderratabydate()
        return

    source_channel = args[0]
    dest_channel = args[1]
    begin_date = args[2]
    end_date = args[3]

    if not re.match(r'\d{8}', begin_date):
        logging.error('%s is an invalid date' % begin_date)
        self.help_softwarechannel_adderratabydate()
        return

    if not re.match(r'\d{8}', end_date):
        logging.error('%s is an invalid date' % end_date)
        self.help_softwarechannel_adderratabydate()
        return

    # get the errata that are in the given date range
    logging.debug('Retrieving list of errata from source channel')
    errata = \
        self.client.channel.software.listErrata(self.session,
                                                source_channel,
                                                parse_time_input(begin_date),
                                                parse_time_input(end_date))

    if not errata:
        logging.warning('No errata found between the given dates')
        return

    if options.publish:
        # Just publish the errata one-by-one, rather than calling
        # do_softwarechannel_adderrata which clones the errata
        for e in errata:
            logging.info("Publishing errata %s to %s" %
                         (e.get('advisory_name'), dest_channel))
            self.client.errata.publish(self.session, e.get('advisory_name'),
                                       [dest_channel])
    else:
        # call adderrata with the list of errata from the date range
        # this clones the errata and adds it to the channel
        return self.do_softwarechannel_adderrata('%s %s %s' % (
            source_channel,
            dest_channel,
            ' '.join([e.get('advisory_name') for e in errata])))

####################


def help_softwarechannel_listerratabydate(self):
    print('softwarechannel_listerratabydate: list errata from channel' +
          'based on a date range')
    print('usage: softwarechannel_listerratabydate CHANNEL BEGINDATE ENDDATE')
    print('Date format : YYYYMMDD')


def complete_softwarechannel_listerratabydate(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) <= 3:
        return tab_completer(self.do_softwarechannel_list('', True),
                             text)


def do_softwarechannel_listerratabydate(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if len(args) != 3:
        self.help_softwarechannel_listerratabydate()
        return

    channel = args[0]
    begin_date = args[1]
    end_date = args[2]

    if not re.match(r'\d{8}', begin_date):
        logging.error('%s is an invalid date' % begin_date)
        self.help_softwarechannel_listerratabydate()
        return

    if not re.match(r'\d{8}', end_date):
        logging.error('%s is an invalid date' % end_date)
        self.help_softwarechannel_listerratabydate()
        return

    # get the errata that are in the given date range
    logging.debug('Retrieving list of errata from channel %s' % channel)
    errata = \
        self.client.channel.software.listErrata(self.session,
                                                channel,
                                                parse_time_input(begin_date),
                                                parse_time_input(end_date))

    if not errata:
        logging.warning('No errata found between the given dates')
        return

    print_errata_list(errata)

####################


def help_softwarechannel_adderrata(self):
    print('softwarechannel_adderrata: Add errata from one channel ' +
          'into another channel')
    print('usage: softwarechannel_adderrata SOURCE DEST <ERRATA|search:XXX ...>')
    print('Options:')
    print('    -q/--quick : Don\'t display list of packages (slightly faster)')
    print('    -s/--skip :  Skip errata which appear to exist already in DEST')


def complete_softwarechannel_adderrata(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) <= 3:
        return tab_completer(self.do_softwarechannel_list('', True), text)
    elif len(parts) > 3:
        return self.tab_complete_errata(text)


def do_softwarechannel_adderrata(self, args):
    arg_parser = get_argument_parser()
    arg_parser.add_argument('-q', '--quick', action='store_true')
    arg_parser.add_argument('-s', '--skip', action='store_true')

    (args, options) = parse_command_arguments(args, arg_parser)

    if len(args) < 3:
        self.help_softwarechannel_adderrata()
        return

    allchannels = self.do_softwarechannel_list('', True)
    source_channel = args[0]
    if not source_channel in allchannels:
        logging.error("source channel %s does not exist!" % source_channel)
        self.help_softwarechannel_adderrata()
        return
    dest_channel = args[1]
    if not dest_channel in allchannels:
        logging.error("dest channel %s does not exist!" % dest_channel)
        self.help_softwarechannel_adderrata()
        return
    errata_wanted = self.expand_errata(args[2:])

    logging.debug('Retrieving the list of errata from source channel')
    source_errata = self.client.channel.software.listErrata(self.session,
                                                            source_channel)
    dest_errata = self.client.channel.software.listErrata(self.session,
                                                          dest_channel)

    errata = filter_results([e.get('advisory_name') for e in source_errata],
                            errata_wanted)
    logging.debug("errata = %s" % errata)
    if options.skip:
        # We just match the NNNN:MMMM of the XXXX-NNNN:MMMM as the
        # source errata will be RH[BES]A and the DEST errata will be CLA
        dest_errata_suffix = [x.get('advisory_name').split("-")[1]
                              for x in dest_errata]
        logging.debug("dest_errata_suffix = %s" % dest_errata_suffix)
        toremove = []
        for e in errata:
            if e.split("-")[1] in dest_errata_suffix:
                logging.debug("Skipping errata %s as it seems to be in %s" %
                              (e, dest_channel))
                toremove.append(e)
        for e in toremove:
            logging.debug("Removing %s from errata to be added" % e)
            errata.remove(e)
        logging.debug("skip-mode : reduced errata = %s" % errata)

    # keep the details for our matching errata so we can use them later
    errata_details = []
    for erratum in source_errata:
        if erratum.get('advisory_name') in errata:
            errata_details.append(erratum)

    if not options.quick:
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

    if not errata:
        logging.warning('No errata to add')
        return

    # show the user which errata will be added
    print_errata_list(errata_details)

    if not options.quick:
        print('')
        print('Packages')
        print('--------')
        print('\n'.join(
            sorted([self.get_package_name(p) for p in package_ids])))

        print('')
    print('Total Errata:   %s' % str(len(errata)).rjust(3))

    if not options.quick:
        print('Total Packages: %s' % str(len(package_ids)).rjust(3))

    if not self.user_confirm('Add these errata [y/N]:'):
        return

    # clone each erratum individually because the process is slow and it can
    # lead to timeouts on the server
    for erratum in errata:
        logging.debug('Cloning %s' % erratum)
        if self.check_api_version('10.11'):
            # This call is poorly documented, but it stops errata.clone
            # pushing EL6 packages into EL5 channels when the errata
            # package list contains both versions, ref bz678721
            self.client.errata.cloneAsOriginal(self.session, dest_channel,
                                               [erratum])
        else:
            logging.warning("Using the old errata.clone function")
            logging.warning("If you have base channels for multiple OS" +
                            " versions, check no unexpected packages have been added")
            self.client.errata.clone(self.session, dest_channel, [erratum])

    # regenerate the errata cache since we just cloned errata
    self.generate_errata_cache(True)

####################


def help_softwarechannel_getorgaccess(self):
    print('softwarechannel_getorgaccess: Get the org-access for the software channel')
    print('usage: softwarechannel_getorgaccess [CHANNEL ...]')


def complete_softwarechannel_getorgaccess(self, text, line, beg, end):
    return tab_completer(self.do_softwarechannel_listmanageablechannels('', doreturn=True),
                         text)


def do_softwarechannel_getorgaccess(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    # If no args are passed, we dump the org access for all channels
    if not args:
        channels = self.do_softwarechannel_listmanageablechannels('', doreturn=True)
    else:
        # allow globbing of software channel names
        channels = filter_results(
            self.do_softwarechannel_listmanageablechannels('', doreturn=True), args)

    for channel in channels:
        logging.debug("Getting org-access for channel %s" % channel)
        sharing = self.client.channel.access.getOrgSharing(
            self.session, channel)
        print("%s : %s" % (channel, sharing))
        if sharing == 'protected':
            # for protected channels list each organization's access status
            channel_orgs = self.client.channel.org.list(self.session, channel)
            for org in channel_orgs:
                print("\t%s : %s" % (org["org_name"], org["access_enabled"]))

####################


def help_softwarechannel_setorgaccess(self):
    print('softwarechannel_setorgaccess: Set the org-access for the software channel')
    print('''usage : softwarechannel_setorgaccess <CHANNEL> [options])
-d,--disable : disable org access (private, no org sharing)
-e,--enable : enable org access (public access to all trusted orgs)
-p,--protected ORG : protected org access for ORG only (multiple instances of -p ORG are allowed)''')


def complete_softwarechannel_setorgaccess(self, text, line, beg, end):
    return tab_completer(self.do_softwarechannel_listmanageablechannels('', doreturn=True),
                         text)


def do_softwarechannel_setorgaccess(self, args, options=None):
    if not args:
        self.help_softwarechannel_setorgaccess()
        return
    if not options:
        arg_parser = get_argument_parser()
        arg_parser.add_argument('-e', '--enable', action='store_true')
        arg_parser.add_argument('-d', '--disable', action='store_true')
        arg_parser.add_argument('-p', '--protected', action='append')

        (args, options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_softwarechannel_setorgaccess()
        return

    # allow globbing of software channel names
    channels = filter_results(self.do_softwarechannel_listmanageablechannels('', doreturn=True),
                              args)

    # get the list of trusted organizations when we are dealing with protected channels
    if (options.protected):
        org_trust_list = self.client.org.trusts.listOrgs(self.session)

    for channel in channels:
        # If they just specify a channel and --enable/--disable
        # this implies public/private access
        if (options.enable):
            logging.info(
                "Making org sharing public for channel : %s " % channel)
            self.client.channel.access.setOrgSharing(
                self.session, channel, 'public')
        elif (options.disable):
            logging.info(
                "Making org sharing private for channel : %s " % channel)
            self.client.channel.access.setOrgSharing(
                self.session, channel, 'private')
        elif (options.protected):
            logging.info(
                "Making org sharing protected for channel : %s " % channel)
            self.client.channel.access.setOrgSharing(
                self.session, channel, 'protected')
            for org in org_trust_list:
                if org["org_name"] in options.protected:
                    logging.info(
                        "Enabling %s access for channel : %s " % (org["org_name"],channel))
                    self.client.channel.org.enableAccess(
                        self.session, channel, org["org_id"])
                else:
                    logging.info(
                        "Disabling %s access for channel : %s " % (org["org_name"],channel))
                    self.client.channel.org.disableAccess(
                        self.session, channel, org["org_id"])
        else:
            self.help_softwarechannel_setorgaccess()
            return

####################


def help_softwarechannel_getorgaccesstree(self):
    print('softwarechannel_getorgaccesstree: Get the org-access for a software base channel and its children')
    print('usage: softwarechannel_getorgaccesstree [CHANNEL]')

def complete_softwarechannel_getorgaccesstree(self, text, line, beg, end):
    return tab_completer(self.list_base_channels(), text)

def do_softwarechannel_getorgaccesstree(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    # If no args are passed, we dump the org access for all base channels
    if not args:
        channels = self.list_base_channels()
    else:
        # allow globbing of software channel names
        channels = filter_results(self.list_base_channels(), args)

    if not channels:
        logging.error("Channel does not exist or is not a base channel!")
        self.help_softwarechannel_getorgaccesstree()
        return

    for channel in channels:
        do_softwarechannel_getorgaccess(self, channel)
        for child in self.list_child_channels(parent=channel):
            do_softwarechannel_getorgaccess(self, child)

####################


def help_softwarechannel_setorgaccesstree(self):
    print('softwarechannel_setorgaccesstree: set the org-access for a software base channel and its children')
    print('''usage: softwarechannel_setorgaccesstree <CHANNEL> [options])
-d,--disable : disable org access (private, no org sharing)
-e,--enable : enable org access (public access to all trusted orgs)
-p,--protected ORG : protected org access for ORG only (multiple instances of -p ORG are allowed)''')

def complete_softwarechannel_setorgaccesstree(self, text, line, beg, end):
    return tab_completer(self.list_base_channels(), text)

def do_softwarechannel_setorgaccesstree(self, args):
    arg_parser = get_argument_parser()
    arg_parser.add_argument('-e', '--enable', action='store_true')
    arg_parser.add_argument('-d', '--disable', action='store_true')
    arg_parser.add_argument('-p', '--protected', action='append')

    (args, options) = parse_command_arguments(args, arg_parser)

    if not args or not (options.enable or options.disable or options.protected):
        self.help_softwarechannel_setorgaccesstree()
        return

    # allow globbing of software channel names
    channels = filter_results(self.list_base_channels(), args)

    if not channels:
        logging.error("Channel does not exist or is not a base channel!")
        self.help_softwarechannel_setorgaccesstree()
        return

    for channel in channels:
        do_softwarechannel_setorgaccess(self, [channel], options)
        for child in self.list_child_channels(parent=channel):
            do_softwarechannel_setorgaccess(self, [child], options)

####################


def help_softwarechannel_regenerateneededcache(self):
    print('softwarechannel_regenerateneededcache: ')
    print('Regenerate the needed errata and package cache for all systems')
    print('')
    print('usage: softwarechannel_regenerateneededcache')


def do_softwarechannel_regenerateneededcache(self, args):
    if self.user_confirm('Are you sure [y/N]: '):
        self.client.channel.software.regenerateNeededCache(self.session)

####################


def help_softwarechannel_regenerateyumcache(self):
    print('softwarechannel_regenerateyumcache: ')
    print('Regenerate the YUM cache for a software channel')
    print('')
    print('usage: softwarechannel_regenerateyumcache <CHANNEL ...>')


def complete_softwarechannel_regenerateyumcache(self, text, line, beg, end):
    return tab_completer(self.do_softwarechannel_list('', True), text)


def do_softwarechannel_regenerateyumcache(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_softwarechannel_regenerateyumcache()
        return

    # allow globbing of software channel names
    channels = filter_results(self.do_softwarechannel_list('', True), args)

    for channel in channels:
        logging.debug('Regenerating YUM cache for %s' % channel)
        self.client.channel.software.regenerateYumCache(self.session, channel)

####################
# softwarechannel helper


def is_softwarechannel(self, name):
    if not name:
        return
    return name in self.do_softwarechannel_list(name, True)


def check_softwarechannel(self, name):
    if not name:
        logging.error("no softwarechannel label given")
        return False
    if not self.is_softwarechannel(name):
        logging.error("invalid softwarechannel label " + name)
        return False
    return True


def dump_softwarechannel(self, name, replacedict=None, excludes=None):
    excludes = excludes or []
    content = self.do_softwarechannel_listallpackages(name, doreturn=True)

    content = get_normalized_text(
        content, replacedict=replacedict, excludes=excludes)

    return content

####################


def help_softwarechannel_diff(self):
    print('softwarechannel_diff: diff softwarechannel files')
    print('')
    print('usage: softwarechannel_diff SOURCE_CHANNEL TARGET_CHANNEL')


def complete_softwarechannel_diff(self, text, line, beg, end):
    parts = shlex.split(line)
    if line[-1] == ' ':
        parts.append('')
    args = len(parts)

    if args == 2:
        return tab_completer(self.do_softwarechannel_list('', True), text)
    if args == 3:
        return tab_completer(self.do_softwarechannel_list('', True), text)
    return []


def do_softwarechannel_diff(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if len(args) != 1 and len(args) != 2:
        self.help_softwarechannel_diff()
        return

    source_channel = args[0]
    if not self.check_softwarechannel(source_channel):
        return

    target_channel = None
    if len(args) == 2:
        target_channel = args[1]
    elif hasattr(self, "do_softwarechannel_getcorresponding"):
        # can a corresponding channel name be found automatically?
        target_channel = self.do_softwarechannel_getcorresponding(
            source_channel)
    if not self.check_softwarechannel(target_channel):
        return

    # softwarechannel do not contain references to other components,
    # therefore there is no need to use replace dicts
    source_data = self.dump_softwarechannel(source_channel, None)
    target_data = self.dump_softwarechannel(target_channel, None)

    return diff(source_data, target_data, source_channel, target_channel)

####################


def dump_softwarechannel_errata(self, name):
    errata = self.client.channel.software.listErrata(self.session, name)
    result = []
    for erratum in errata:
        result.append('%s %s' % (
            erratum.get('advisory_name').ljust(14),
            wrap(erratum.get('advisory_synopsis'), 50)[0]))
    result.sort()
    return result


def help_softwarechannel_errata_diff(self):
    print('softwarechannel_errata_diff: diff softwarechannel files')
    print('')
    print('usage: softwarechannel_errata_diff SOURCE_CHANNEL TARGET_CHANNEL')


def complete_softwarechannel_errata_diff(self, text, line, beg, end):
    parts = shlex.split(line)
    if line[-1] == ' ':
        parts.append('')
    args = len(parts)

    if args == 2:
        return tab_completer(self.do_softwarechannel_list('', True), text)
    if args == 3:
        return tab_completer(self.do_softwarechannel_list('', True), text)
    return []


def do_softwarechannel_errata_diff(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if len(args) != 1 and len(args) != 2:
        self.help_softwarechannel_errata_diff()
        return

    source_channel = args[0]
    if not self.check_softwarechannel(source_channel):
        return

    target_channel = None
    if len(args) == 2:
        target_channel = args[1]
    elif hasattr(self, "do_softwarechannel_getcorresponding"):
        # try to find the corresponding channel automatically
        target_channel = self.do_softwarechannel_getcorresponding(
            source_channel)
    if not self.check_softwarechannel(target_channel):
        return

    # softwarechannel do not contain references to other components,
    # therefore there is no need to use replace dicts
    source_data = self.dump_softwarechannel_errata(source_channel)
    target_data = self.dump_softwarechannel_errata(target_channel)
    return diff(source_data, target_data, source_channel, target_channel)

####################


def help_softwarechannel_sync(self):
    print('softwarechannel_sync: ')
    print('sync the packages of two software channels')
    print('')
    print('''usage: softwarechannel_sync SOURCE_CHANNEL TARGET_CHANNEL [options])
    -q,--quiet : quiet mode (omits the output of common packages in both channels)''')


def complete_softwarechannel_sync(self, text, line, beg, end):
    parts = shlex.split(line)
    if line[-1] == ' ':
        parts.append('')
    args = len(parts)

    if args == 2:
        return tab_completer(self.do_softwarechannel_list('', True), text)
    if args == 3:
        return tab_completer(self.do_softwarechannel_list('', True), text)
    return []


def do_softwarechannel_sync(self, args):
    arg_parser = get_argument_parser()
    arg_parser.add_argument('-q', '--quiet', action='store_true')

    (args, options) = parse_command_arguments(args, arg_parser)

    if len(args) != 1 and len(args) != 2:
        self.help_softwarechannel_sync()
        return

    source_channel = args[0]
    if not self.check_softwarechannel(source_channel):
        return

    target_channel = None
    if len(args) == 2:
        target_channel = args[1]
    elif hasattr(self, "do_softwarechannel_getcorresponding"):
        # can a corresponding channel name be found automatically?
        target_channel = self.do_softwarechannel_getcorresponding(
            source_channel)
    if not self.check_softwarechannel(target_channel):
        return

    logging.info("syncing packages from softwarechannel " +
                 source_channel + " to " + target_channel)

    # use API call instead of spacecmd function
    # to get detailed infos about the packages
    # and not just there names
    source_packages = self.client.channel.software.listAllPackages(
        self.session,
        source_channel)
    target_packages = self.client.channel.software.listAllPackages(
        self.session,
        target_channel)

    # get the package IDs
    source_ids = set()
    for package in source_packages:
        try:
            source_ids.add(package['id'])
        except KeyError:
            logging.error("failed to read key id")
            continue

    target_ids = set()
    for package in target_packages:
        try:
            target_ids.add(package['id'])
        except KeyError:
            logging.error("failed to read key id")
            continue
    if not options.quiet:
        print("packages common in both channels:")
        for i in (source_ids & target_ids):
            print(self.get_package_name(i))
        print('')
    else:
        logging.info("Omitting common packages in both specified channels")

    # check for packages only in the source channel
    source_only = source_ids.difference(target_ids)
    if source_only:
        print('packages to add to channel "' + target_channel + '":')
        for i in source_only:
            print(self.get_package_name(i))
        print('')

    # check for packages only in the target channel
    target_only = target_ids.difference(source_ids)
    if target_only:
        print('packages to remove from channel "' + target_channel + '":')
        for i in target_only:
            print(self.get_package_name(i))
        print('')

    if source_only or target_only:
        print("summary:")
        print("  " + source_channel + ": " + str(len(source_ids)).rjust(5), "packages")
        print("  " + target_channel + ": " + str(len(target_ids)).rjust(5), "packages")
        print("    add   ", str(
            len(source_only)).rjust(5), "packages to  ", target_channel)
        print("    remove", str(
            len(target_only)).rjust(5), "packages from", target_channel)
        if not self.user_confirm('Perform these changes to channel ' + target_channel + ' [y/N]:'):
            return

        self.client.channel.software.addPackages(self.session,
                                                 target_channel,
                                                 list(source_only))
        self.client.channel.software.removePackages(self.session,
                                                    target_channel,
                                                    list(target_only))

####################


def help_softwarechannel_errata_sync(self):
    print('softwarechannel_errata_sync: ')
    print('sync errata of two software channels')
    print('')
    print('usage: softwarechannel_errata_sync SOURCE_CHANNEL TARGET_CHANNEL')


def complete_softwarechannel_errata_sync(self, text, line, beg, end):
    parts = shlex.split(line)
    if line[-1] == ' ':
        parts.append('')
    args = len(parts)

    if args == 2:
        return tab_completer(self.do_softwarechannel_list('', True), text)
    if args == 3:
        return tab_completer(self.do_softwarechannel_list('', True), text)
    return []


def do_softwarechannel_errata_sync(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if len(args) != 1 and len(args) != 2:
        self.help_softwarechannel_errata_sync()
        return

    source_channel = args[0]
    if not self.check_softwarechannel(source_channel):
        return

    target_channel = None
    if len(args) == 2:
        target_channel = args[1]
    elif hasattr(self, "do_softwarechannel_getcorresponding"):
        # try to find a corresponding channel name automatically
        target_channel = self.do_softwarechannel_getcorresponding(
            source_channel)
    if not self.check_softwarechannel(target_channel):
        return

    logging.info("syncing errata from softwarechannel " + source_channel +
                 " to " + target_channel)

    source_errata = self.client.channel.software.listErrata(
        self.session, source_channel)
    target_errata = self.client.channel.software.listErrata(
        self.session, target_channel)

    # store unique errata data in a set
    source_ids = set()
    for erratum in source_errata:
        try:
            source_ids.add(erratum.get('advisory_name'))
        except KeyError:
            logging.error("failed to read key id")
            continue

    target_ids = set()
    for erratum in target_errata:
        try:
            target_ids.add(erratum.get('advisory_name'))
        except KeyError:
            logging.error("failed to read key id")
            continue

    print("errata common in both channels:")
    for i in (source_ids & target_ids):
        print(i)
    print('')

    # check for errata only in the source channel
    source_only = list(source_ids.difference(target_ids))
    source_only.sort()
    if source_only:
        print('errata to add to channel "' + target_channel + '":')
        for i in source_only:
            print(i)
        print('')

    # check for errata only in the target channel
    target_only = list(target_ids.difference(source_ids))
    target_only.sort()
    if target_only:
        print('errata to remove from channel "' + target_channel + '":')
        for i in target_only:
            print(i)
        print('')

    if source_only or target_only:
        print("summary:")
        print("  " + source_channel + ": " + str(len(source_ids)).rjust(5), "errata")
        print("  " + target_channel + ": " + str(len(target_ids)).rjust(5), "errata")
        print("    add   ", str(
            len(source_only)).rjust(5), "errata to  ", target_channel)
        print("    remove", str(
            len(target_only)).rjust(5), "errata from", target_channel)

        if not self.user_confirm('Perform these changes to channel ' + target_channel + ' [y/N]:'):
            return

        for erratum in source_only:
            print(erratum)
            self.client.errata.publish(self.session, erratum, [target_channel])
        # alternative:
        # channel.software.mergeErrata: Merges all errata from one channel into another

        # channel.software.removeErrata:
        #    string channelLabel - target channel.
        #    array:
        #      string - advisoryName - name of an erratum to remove
        #    boolean removePackages - True to remove packages from the channel
        self.client.channel.software.removeErrata(self.session, target_channel,
                                                  target_only, False)

####################


def help_softwarechannel_syncrepos(self):
    print('softwarechannel_syncrepos: ')
    print('Sync users repos for a software channel')
    print('')
    print('usage: softwarechannel_syncrepos <CHANNEL ...>')


def complete_softwarechannel_syncrepos(self, text, line, beg, end):
    return tab_completer(self.do_softwarechannel_list('', True), text)


def do_softwarechannel_syncrepos(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_softwarechannel_syncrepos()
        return

    # allow globbing of software channel names
    channels = filter_results(self.do_softwarechannel_list('', True), args)

    for channel in channels:
        logging.debug('Syncing repos for %s' % channel)
        self.client.channel.software.syncRepo(self.session, channel)

####################


def help_softwarechannel_setsyncschedule(self):
    print('softwarechannel_setsyncschedule: ')
    print('Sets the repo sync schedule for a software channel')
    print('')
    print('usage: softwarechannel_setsyncschedule <CHANNEL> <SCHEDULE>')
    print('Options:')
    print('    -e/--no-errata : Do not sync errata')
    print('    -f/--fail : Terminate upon any error')
    print('    -k/--sync-kickstart : Create kickstartable tree')
    print('    -l/--latest : Only download latest package versions when repo syncs')
    print('')
    print('The schedule is specified in Quartz CronTrigger format without enclosing quotes.')
    print('For example, to set a schedule of every day at 1am, <SCHEDULE> would be 0 0 1 * * ?')
    print('If <SCHEDULE> is left empty, it will be disabled.')
    print('')


def complete_softwarechannel_setsyncschedule(self, text, line, beg, end):
    return tab_completer(self.do_softwarechannel_list('', True), text)


def do_softwarechannel_setsyncschedule(self, args):
    arg_parser = get_argument_parser()
    arg_parser.add_argument('-e', '--no-errata', action='store_true', default=False)
    arg_parser.add_argument('-f', '--fail', action='store_true', default=False)
    arg_parser.add_argument('-k', '--sync-kickstart', action='store_true', default=False)
    arg_parser.add_argument('-l', '--latest', action='store_true', default=False)

    # Set glob = false, otherwise this will generate a com.redhat.rhn.taskomatic.InvalidParamException: Cron trigger.
    (args, options) = parse_command_arguments(args, arg_parser, glob=False)

    params = dict((i.replace('_', '-'), getattr(options, i)) for i in ['no_errata', 'fail', 'sync_kickstart', 'latest'])

    if not len(args) in [1, 7]:
        self.help_softwarechannel_setsyncschedule()
        return

    channel = args[0]
    schedule = ' '.join(args[1:]) if len(args) == 7 else ''

    self.client.channel.software.syncRepo(self.session, channel, schedule, params)

####################


def help_softwarechannel_removesyncschedule(self):
    print('softwarechannel_removesyncschedule: ')
    print('Removes the repo sync schedule for a software channel')
    print('')
    print('usage: softwarechannel_removesyncschedule <CHANNEL>')


def complete_softwarechannel_removesyncschedule(self, text, line, beg, end):
    return tab_completer(self.do_softwarechannel_list('', True), text)


def do_softwarechannel_removesyncschedule(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not len(args) == 1:
        self.help_softwarechannel_removesyncschedule()
        return

    channel = args[0]

    self.client.channel.software.syncRepo(self.session, channel, '')

####################

def help_softwarechannel_listsyncschedule(self):
    print('softwarechannel_listsyncschedule: List sync schedules for all software channels')
    print('usage:')
    print('softwarechannel_listsyncschedule : List all channels')


def do_softwarechannel_listsyncschedule(self, args):

    # Get a list of all channels and sync schedules
    channels = self.client.channel.listAllChannels(self.session)
    schedules = self.client.taskomatic.org.listActiveSchedules(self.session)

    chan_name = {}
    chan_sched = {}

    # Build an array of channel names indexed by internal channel id number
    for c in channels:
        chan_name[ c['id'] ] = c['label']
        chan_sched[ c['id'] ] = ''

    # Build an array of schedules indexed by internal channel id number
    for s in schedules:
        chan_sched[int(s['data_map']['channel_id'])] = s['cron_expr']

    # Print headers
    csched_fmt = '{0:>5s}  {1:<40s} {2:<20s}'
    print(csched_fmt.format('key', 'Channel Name', 'Update Schedule'))
    print(csched_fmt.format('-----', '---------------------', '---------------'))

    # Sort and print(the channel names and associated repo-sync schedule (if any))
    for key,value in sorted(chan_name.items()):
        print(csched_fmt.format(str(key), value, chan_sched[int(key)]))

####################

def help_softwarechannel_addrepo(self):
    print('softwarechannel_addrepo: Add a repo to a software channel')
    print('usage: softwarechannel_addrepo CHANNEL REPO')


def complete_softwarechannel_addrepo(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_softwarechannel_list('', True),
                             text)
    elif len(parts) == 3:
        return tab_completer(self.do_repo_list('', True), text)


def do_softwarechannel_addrepo(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if len(args) < 2:
        self.help_softwarechannel_addrepo()
        return

    channel = args[0]
    repo = args[1]

    self.client.channel.software.associateRepo(self.session, channel, repo)

####################


def help_softwarechannel_removerepo(self):
    print('softwarechannel_removerepo: Remove a repo from a software channel')
    print('usage: softwarechannel_removerepo CHANNEL REPO')


def complete_softwarechannel_removerepo(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_softwarechannel_list('', True),
                             text)
    elif len(parts) == 3:
        try:
            details = self.client.channel.software.getDetails(self.session,
                                                              parts[1])
            repos = [r.get('label') for r in details.get('contentSources')]
        except xmlrpclib.Fault:
            return

        return tab_completer(repos, text)


def do_softwarechannel_removerepo(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if len(args) < 2:
        self.help_softwarechannel_removerepo()
        return

    channel = args[0]
    repo = args[1]

    self.client.channel.software.disassociateRepo(self.session, channel, repo)

####################


def help_softwarechannel_listrepos(self):
    print('softwarechannel_listrepos: List the repos for a software channel')
    print('usage: softwarechannel_listrepos CHANNEL')


def complete_softwarechannel_listrepos(self, text, line, beg, end):
    return tab_completer(self.do_softwarechannel_list('', True), text)


def do_softwarechannel_listrepos(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    details = self.client.channel.software.getDetails(self.session, args[0])
    repos = [r.get('label') for r in details.get('contentSources')]

    if repos:
        print('\n'.join(sorted(repos)))

####################


def help_softwarechannel_mirrorpackages(self):
    print('softwarechannel_mirrorpackages: Download packages of a given channel')
    print('usage: softwarechannel_mirrorpackages CHANNEL')
    print('Options:')
    print('    -l/--latest : Only mirror latest package version')


def complete_softwarechannel_mirrorpackages(self, text, line, beg, end):
    return tab_completer(self.do_softwarechannel_list('', True), text)


def do_softwarechannel_mirrorpackages(self, args):
    arg_parser = get_argument_parser()
    arg_parser.add_argument('-l', '--latest', action='store_true')

    (args, options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_softwarechannel_mirrorpackages()
        return
    channel = args[0]
    if not (options.latest):
        packages = \
            self.client.channel.software.listAllPackages(self.session, channel)
    else:
        packages = \
            self.client.channel.software.listLatestPackages(
                self.session, channel)

    for package in packages:
        package_url = self.client.packages.getPackageUrl(
            self.session, package['id'])
        package_file = self.client.packages.getDetails(
            self.session, package['id']).get('file')
        if os.path.isfile(package_file):
            print("Skipping", package_file)
        else:
            print("Fetching package", package_file)
            try:
                urlretrieve(package_url, package_file)
            except ContentTooShortError:
                logging.error(
                    "Received package %s from channel %s is broken. Content is too short",
                    package_file, channel)
            except IOError:
                logging.error("Could not fetch package %s from channel %s" %
                              (package_file, channel))
