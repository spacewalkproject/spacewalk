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

from spacecmd.utils import *

def help_configchannel_list(self):
    print 'configchannel_list: List all configuration channels'
    print 'usage: configchannel_list'

def do_configchannel_list(self, args, doreturn=False):
    channels = self.client.configchannel.listGlobals(self.session)
    channels = [c.get('label') for c in channels]

    if doreturn:
        return channels
    else:
        if len(channels):
            print '\n'.join(sorted(channels))

####################

def help_configchannel_listsystems(self):
    print 'configchannel_listsystems: List the systems subscribed to a'
    print '                           configuration channel'
    print 'usage: configchannel_listsystems CHANNEL'

def complete_configchannel_listsystems(self, text, line, beg, end):
    return tab_completer(self.do_configchannel_list('', True), text)

def do_configchannel_listsystems(self, args):
    if not self.check_api_version('10.11'):
        logging.warning("This version of the API doesn't support this method")
        return

    args = parse_arguments(args)

    if not len(args):
        self.help_configchannel_listsystems()
        return

    channel = args[0]

    systems = self.client.configchannel.listSubscribedSystems(self.session,
                                                              channel)

    systems = sorted([s.get('name') for s in systems])

    if len(systems):
        print '\n'.join(systems)

####################

def help_configchannel_listfiles(self):
    print 'configchannel_listfiles: List the files in a config channel'
    print 'usage: configchannel_listfiles CHANNEL ...'

def complete_configchannel_listfiles(self, text, line, beg, end):
    return tab_completer(self.do_configchannel_list('', True), text)

def do_configchannel_listfiles(self, args, doreturn=False):
    args = parse_arguments(args)

    if not len(args):
        self.help_configchannel_listfiles()
        return []

    for channel in args:
        files = self.client.configchannel.listFiles(self.session,
                                                    channel)
        files = [f.get('path') for f in files]

        if doreturn:
            return files
        else:
            if len(files):
                print '\n'.join(sorted(files))

####################

def help_configchannel_filedetails(self):
    print 'configchannel_filedetails: Show the details of a file'
    print 'in a configuration channel'
    print 'usage: configchannel_filedetails CHANNEL <FILE ...>'

def complete_configchannel_filedetails(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_configchannel_list('', True),
                                  text)
    elif len(parts) > 2:
        return tab_completer(\
            self.do_configchannel_listfiles(parts[1], True), text)
    else:
        return []

def do_configchannel_filedetails(self, args):
    args = parse_arguments(args)

    if len(args) < 2:
        self.help_configchannel_filedetails()
        return

    add_separator = False

    channel = args[0]
    filenames = args[1:]

    # the server return a null exception if an invalid file is passed
    valid_files = self.do_configchannel_listfiles(channel, True)
    for f in filenames:
        if not f in valid_files:
            filenames.remove(f)
            logging.warning('%s is not in this configuration channel' % f)
            continue

    files = self.client.configchannel.lookupFileInfo(self.session,
                                                     channel,
                                                     filenames)

    for f in files:
        if add_separator: print self.SEPARATOR
        add_separator = True

        print 'File:     %s' % f.get('path')
        print 'Type:     %s' % f.get('type')
        print 'Revision: %i' % f.get('revision')
        print 'Created:  %s' % f.get('creation')
        print 'Modified: %s' % f.get('modified')

        print
        print 'Owner:    %s' % f.get('owner')
        print 'Group:    %s' % f.get('group')
        print 'Mode:     %s' % f.get('permissions_mode')

        if f.get('type') == 'file':
            print 'MD5:      %s' % f.get('md5')
            print 'Binary:   %s' % f.get('binary')

            if not f.get('binary'):
                print
                print 'Contents'
                print '--------'
                print f.get('contents')

####################

def help_configchannel_details(self):
    print 'configchannel_details: Show the details of a config channel'
    print 'usage: configchannel_details CHANNEL ...'

def complete_configchannel_details(self, text, line, beg, end):
    return tab_completer(self.do_configchannel_list('', True), text)

def do_configchannel_details(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_configchannel_details()
        return

    add_separator = False

    for channel in args:
        details = self.client.configchannel.getDetails(self.session,
                                                       channel)

        files = self.client.configchannel.listFiles(self.session,
                                                    channel)

        if add_separator: print self.SEPARATOR
        add_separator = True

        print 'Label:       %s' % details.get('label')
        print 'Name:        %s' % details.get('name')
        print 'Description: %s' % details.get('description')

        print
        print 'Files'
        print '-----'
        for f in files:
            print f.get('path')

####################

def help_configchannel_create(self):
    print 'configchannel_create: Create a configuration channel'
    print 'usage: configchannel_create [NAME] [DESCRIPTION]'

def do_configchannel_create(self, args):
    args = parse_arguments(args)

    if len(args) > 0:
        name = args[0]
    else:
        name = ''

    while name == '':
        name = prompt_user('Name:')

    if len(args) > 1:
        description = ' '.join(args[1:])
    else:
        description = prompt_user('Description:')

    if description == '':
        description = name

    self.client.configchannel.create(self.session,
                                     name,
                                     name,
                                     description)

####################

def help_configchannel_delete(self):
    print 'configchannel_delete: Delete a configuration channel'
    print 'usage: configchannel_delete CHANNEL ...'

def complete_configchannel_delete(self, text, line, beg, end):
    return tab_completer(self.do_configchannel_list('', True), text)

def do_configchannel_delete(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_configchannel_delete()
        return

    channels = args

    if self.user_confirm('Delete these channels [y/N]:'):
        self.client.configchannel.deleteChannels(self.session, channels)

####################

def help_configchannel_addfile(self):
    print 'configchannel_addfile: Create a configuration file'
    print 'usage: configchannel_addfile CHANNEL'

def complete_configchannel_addfile(self, text, line, beg, end):
    return tab_completer(self.do_configchannel_list('', True), text)

def do_configchannel_addfile(self, args, path=''):
    args = parse_arguments(args)

    if len(args) != 1:
        self.help_configchannel_addfile()
        return

    channel = args[0]

    # defaults   
    owner = 'root'
    group = 'root'
    mode = '644'
    contents = ''

    while path == '':
        path = prompt_user('Path:')

    # check if this file already exists
    try:
        fileinfo = self.client.configchannel.lookupFileInfo(self.session,
                                                            channel,
                                                            [ path ])
    except:
        fileinfo = None

    # use existing values if available
    if fileinfo:
        for info in fileinfo:
            if info.get('path') == path:
                owner = info.get('owner')
                group = info.get('group')
                mode = info.get('permissions_mode')
                contents = info.get('contents')

    userinput = prompt_user('Directory [y/N]:')
    if re.match('y', userinput, re.I):
        directory = True
    else:
        directory = False

    owner_input = prompt_user('Owner [%s]:' % owner)
    group_input = prompt_user('Group [%s]:' % group)
    mode_input  = prompt_user('Permissions [%s]:' % mode)
    
    if owner_input:
        owner = owner_input

    if group_input: 
        group = group_input

    if mode_input:
        mode = mode_input

    binary = False

    if not directory:
        objecttype = 'text'

        #XXX: Bugzilla 606982
        # Satellite doesn't pick up on the base64 encoded string
        #type = prompt_user('Text or binary [T/b]:')
        
        if re.match('b', objecttype, re.I):
            binary = True

            while contents == '':
                filename = prompt_user('File:')

                try:
                    handle = open(filename, 'rb')
                    contents = handle.read().encode('base64')
                    handle.close()
                except IOError:
                    contents = ''
                    logging.warning('Could not read %s' % filename)
        else:
            binary = False

            if contents:
                template = contents
            else:
                template = ''

            contents = editor(template = template, delete = True)

    file_info = { 'contents'    : ''.join(contents),
                  'owner'       : owner,
                  'group'       : group,
                  'permissions' : mode }

    print 'File:        %s' % path
    print 'Directory:   %s' % directory
    print 'Owner:       %s' % file_info['owner']
    print 'Group:       %s' % file_info['group']
    print 'Mode:        %s' % file_info['permissions']

    if not directory:
        if binary:
            print 'Binary File: %s' % binary
        else:
            print
            print 'Contents'
            print '--------'
            print file_info['contents']

    if self.user_confirm():
        self.client.configchannel.createOrUpdatePath(self.session,
                                                     channel,
                                                     path,
                                                     directory,
                                                     file_info)

####################

def help_configchannel_updatefile(self):
    print 'configchannel_updatefile: Update a configuration file'
    print 'usage: configchannel_updatefile CHANNEL FILE'

def complete_configchannel_updatefile(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_configchannel_list('', True), 
                                  text)
    elif len(parts) > 2:
        channel = parts[1]
        return tab_completer(self.do_configchannel_listfiles(channel,
                                                                  True), 
                                  text)

def do_configchannel_updatefile(self, args):
    args = parse_arguments(args)
    
    if len(args) != 2:
        self.help_configchannel_updatefile()
        return

    return self.do_configchannel_addfile(args[0], path=args[1])

####################

def help_configchannel_removefiles(self):
    print 'configchannel_removefile: Remove configuration files'
    print 'usage: configchannel_removefile CHANNEL <FILE ...>'

def complete_configchannel_removefiles(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_configchannel_list('', True), 
                                  text)
    elif len(parts) > 2:
        channel = parts[1]
        return tab_completer(self.do_configchannel_listfiles(channel,
                                                                  True), 
                                  text)

def do_configchannel_removefiles(self, args):
    args = parse_arguments(args)
    
    if len(args) < 2:
        self.help_configchannel_removefiles()
        return

    channel = args.pop(0)
    files = args

    if self.user_confirm('Remove these files [y/N]:'):
        self.client.configchannel.deleteFiles(self.session, channel, files)

# vim:ts=4:expandtab:
