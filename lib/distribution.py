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

def help_distribution_create(self):
    print 'distribution_create: Create a Kickstart tree'
    print 'usage: distribution_create'

def do_distribution_create(self, args):
    name = prompt_user('Label:')

    base_path = prompt_user('Path to Kickstart Tree:')

    base_channel = ''
    while base_channel == '':
        print
        print 'Base Channels:'
        for c in self.list_base_channels():
            print '  %s' % c

        base_channel = prompt_user('Base Channel:')

        if base_channel not in self.list_base_channels():
            logging.warning('Invalid channel label')
            base_channel = ''

    install_types = \
        self.client.kickstart.tree.listInstallTypes(self.session)
   
    install_types = [ t.get('label') for t in install_types ]
 
    install_type = ''
    while install_type == '':
        print
        print 'Install Types:'
        for t in install_types:
            print '  %s' % t

        install_type = prompt_user('Install Type:')

        if install_type not in install_types:
            logging.warning('Invalid install type')
            install_type = '' 

    self.client.kickstart.tree.create(self.session,
                                      name,
                                      base_path,
                                      base_channel,
                                      install_type)

####################

def help_distribution_list(self):
    print 'distribution_list: List the available Kickstart trees'
    print 'usage: distribution_list'

def do_distribution_list(self, args, doreturn=False):
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
    args = parse_arguments(args)

    if len(args) != 1:
        self.help_distribution_delete()
        return

    label = args[0]

    if self.user_confirm('Delete this tree [y/N]:'):
        self.client.kickstart.tree.delete(self.session, label)

####################

def help_distribution_details(self):
    print 'distribution_details: Show the details of a Kickstart tree'
    print 'usage: distribution_details LABEL'

def complete_distribution_details(self, text, line, beg, end):
    return tab_completer(self.do_distribution_list('', True), text)

def do_distribution_details(self, args):
    args = parse_arguments(args)

    if len(args) != 1:
        self.help_distribution_details()
        return

    label = args[0]

    details = self.client.kickstart.tree.getDetails(self.session, label)

    channel = \
        self.client.channel.software.getDetails(self.session,
                                                details.get('channel_id'))

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
    args = parse_arguments(args)

    if len(args) != 2:
        self.help_distribution_rename()
        return

    oldname = args[0]
    newname = args[1]

    self.client.kickstart.tree.rename(self.session, oldname, newname)

####################

def help_distribution_update(self):
    print 'distribution_update: Update the path of a Kickstart tree'
    print 'usage: distribution_update LABEL'

def complete_distribution_update(self, text, line, beg, end):
    if len(line.split(' ')) <= 2:
        return tab_completer(self.do_distribution_list('', True), 
                                  text)

def do_distribution_update(self, args):
    args = parse_arguments(args)

    if len(args) != 1:
        self.help_distribution_update()
        return

    label = args[0]

    base_path = prompt_user('Path to Kickstart Tree:')

    base_channel = ''
    while base_channel == '':
        print
        print 'Base Channels:'
        for c in self.list_base_channels():
            print '  %s' % c

        base_channel = prompt_user('Base Channel:')

        if base_channel not in self.list_base_channels():
            logging.warning('Invalid channel label')
            base_channel = ''

    install_types = \
        self.client.kickstart.tree.listInstallTypes(self.session)
   
    install_types = [ t.get('label') for t in install_types ]
 
    install_type = ''
    while install_type == '':
        print
        print 'Install Types:'
        for t in install_types:
            print '  %s' % t

        install_type = prompt_user('Install Type:')

        if install_type not in install_types:
            logging.warning('Invalid install type')
            install_type = '' 

    self.client.kickstart.tree.update(self.session,
                                      label,
                                      base_path,
                                      base_channel,
                                      install_type)

# vim:ts=4:expandtab:
