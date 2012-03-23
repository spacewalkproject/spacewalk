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

from optparse import Option
from spacecmd.utils import *

def help_distribution_create(self):
    print 'distribution_create: Create a Kickstart tree'
    print '''usage: distribution_create [options]

options:
  -n NAME
  -p path to tree
  -b base channel to associate with
  -t install type [fedora|rhel_4/5/6|generic_rpm]'''

def do_distribution_create(self, args, update = False):
    options = [ Option('-n', '--name', action='store'),
                Option('-p', '--path', action='store'),
                Option('-b', '--base-channel', action='store'),
                Option('-t', '--install-type', action='store') ]

    (args, options) = parse_arguments(args, options)

    # fill in the name of the distribution when updating
    if update:
        if len(args):
            options.name = args[0]
        elif not options.name:
            logging.error('The name of the distribution is required')
            return

    if is_interactive(options):
        if not update:
            options.name = prompt_user('Name:', noblank = True)

        options.path = prompt_user('Path to Kickstart Tree:', noblank = True)

        options.base_channel = ''
        while options.base_channel == '':
            print
            print 'Base Channels'
            print '-------------'
            print '\n'.join(sorted(self.list_base_channels()))
            print

            options.base_channel = prompt_user('Base Channel:')

        if options.base_channel not in self.list_base_channels():
            logging.warning('Invalid channel label')
            options.base_channel = ''

        install_types = \
            self.client.kickstart.tree.listInstallTypes(self.session)
   
        install_types = [ t.get('label') for t in install_types ]
 
        options.install_type = ''
        while options.install_type == '':
            print
            print 'Install Types'
            print '-------------'
            print '\n'.join(sorted(install_types))
            print

            options.install_type = prompt_user('Install Type:')

            if options.install_type not in install_types:
                logging.warning('Invalid install type')
                options.install_type = ''
    else:
        if not options.name:
            logging.error('A name is required')
            return

        if not options.path:
            logging.error('A path is required')
            return

        if not options.base_channel:
            logging.error('A base channel is required')
            return

        if not options.install_type:
            logging.error('An install type is required')
            return

    if update:
        self.client.kickstart.tree.update(self.session,
                                          options.name,
                                          options.path,
                                          options.base_channel,
                                          options.install_type)
    else:
        self.client.kickstart.tree.create(self.session,
                                          options.name,
                                          options.path,
                                          options.base_channel,
                                          options.install_type)

####################

def help_distribution_list(self):
    print 'distribution_list: List the available Kickstart trees'
    print 'usage: distribution_list'

def do_distribution_list(self, args, doreturn = False):
    channels = self.client.kickstart.listKickstartableChannels(self.session)

    avail_trees = []
    for c in channels:
        trees = self.client.kickstart.tree.list(self.session,
                                                c.get('label'))

        for t in trees:
            label = t.get('label')
            if label not in avail_trees:
                avail_trees.append(label)

    if doreturn:
        return avail_trees
    else:
        if len(avail_trees):
            print '\n'.join(sorted(avail_trees))

####################

def help_distribution_delete(self):
    print 'distribution_delete: Delete a Kickstart tree'
    print 'usage: distribution_delete LABEL'

def complete_distribution_delete(self, text, line, beg, end):
    if len(line.split(' ')) <= 2:
        return tab_completer(self.do_distribution_list('', True), 
                                  text)

def do_distribution_delete(self, args):
    (args, options) = parse_arguments(args)

    if not len(args):
        self.help_distribution_delete()
        return

    # allow globbing of distribution names
    dists = filter_results(self.do_distribution_list('', True), args)
    logging.debug("distribution_delete called with args %s, dists=%s" % \
        (args, dists))

    if not len(dists):
        logging.error("No distributions matched argument %s" % args)
        return

    # Print the distributions prior to the confirmation
    print '\n'.join(sorted(dists))

    if self.user_confirm('Delete distribution tree(s) [y/N]:'):
        for d in dists:
            self.client.kickstart.tree.delete(self.session, d)

####################

def help_distribution_details(self):
    print 'distribution_details: Show the details of a Kickstart tree'
    print 'usage: distribution_details LABEL'

def complete_distribution_details(self, text, line, beg, end):
    return tab_completer(self.do_distribution_list('', True), text)

def do_distribution_details(self, args):
    (args, options) = parse_arguments(args)

    if not len(args):
        self.help_distribution_details()
        return

    # allow globbing of distribution names
    dists = filter_results(self.do_distribution_list('', True), args)
    logging.debug("distribution_details called with args %s, dists=%s" % \
        (args, dists))

    if not len(dists):
        logging.error("No distributions matched argument %s" % args)
        return

    add_separator = False

    for label in dists:
        details = self.client.kickstart.tree.getDetails(self.session, label)

        channel = \
            self.client.channel.software.getDetails(self.session,
                                                details.get('channel_id'))

        if add_separator: print self.SEPARATOR
        add_separator = True

        print 'Name:    %s' % details.get('label')
        print 'Path:    %s' % details.get('abs_path')
        print 'Channel: %s' % channel.get('label')

####################

def help_distribution_rename(self):
    print 'distribution_rename: Rename a Kickstart tree'
    print 'usage: distribution_rename OLDNAME NEWNAME'

def complete_distribution_rename(self, text, line, beg, end):
    if len(line.split(' ')) <= 2:
        return tab_completer(self.do_distribution_list('', True), 
                                  text)

def do_distribution_rename(self, args):
    (args, options) = parse_arguments(args)

    if len(args) != 2:
        self.help_distribution_rename()
        return

    oldname = args[0]
    newname = args[1]

    self.client.kickstart.tree.rename(self.session, oldname, newname)

####################

def help_distribution_update(self):
    print 'distribution_update: Update the path of a Kickstart tree'
    print '''usage: distribution_update NAME [options]

options:
  -d path to tree
  -b base channel to associate with
  -t install type [fedora|rhel_4/5/6|generic_rpm]'''

def complete_distribution_update(self, text, line, beg, end):
    if len(line.split(' ')) <= 2:
        return tab_completer(self.do_distribution_list('', True), 
                                  text)

def do_distribution_update(self, args):
    return self.do_distribution_create(args, update = True)

# vim:ts=4:expandtab:
