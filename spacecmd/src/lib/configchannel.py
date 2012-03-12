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

from optparse import Option
from datetime import datetime
from time import strftime
from spacecmd.utils import *
import base64

def help_configchannel_list(self):
    print 'configchannel_list: List all configuration channels'
    print 'usage: configchannel_list'

def do_configchannel_list(self, args, doreturn = False):
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

    (args, options) = parse_arguments(args)

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

def do_configchannel_listfiles(self, args, doreturn = False):
    (args, options) = parse_arguments(args)

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
    print 'usage: configchannel_filedetails CHANNEL FILE [REVISION]'

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
    (args, options) = parse_arguments(args)

    if len(args) < 2:
        self.help_configchannel_filedetails()
        return

    channel = args[0]
    filename = args[1]
    revision = None

    try:
        revision = int(args[2])
    except:
        pass

    # the server return a null exception if an invalid file is passed
    valid_files = self.do_configchannel_listfiles(channel, True)
    if not filename in valid_files:
        logging.warning('%s is not in this configuration channel' % filename)
        return

    if revision:
        details = self.client.configchannel.lookupFileInfo(self.session,
                                                           channel,
                                                           filename,
                                                           revision)
    else:
        results = self.client.configchannel.lookupFileInfo(self.session,
                                                           channel,
                                                           [ filename ])

        # grab the first item since we only do one file
        details = results[0]

    print 'Path:     %s' % details.get('path')
    print 'Type:     %s' % details.get('type')
    print 'Revision: %i' % details.get('revision')
    print 'Created:  %s' % details.get('creation')
    print 'Modified: %s' % details.get('modified')

    if details.get('type') == 'symlink':
        print
        print 'Target Path:     %s' % details.get('target_path')
    else:
        print
        print 'Owner:           %s' % details.get('owner')
        print 'Group:           %s' % details.get('group')
        print 'Mode:            %s' % details.get('permissions_mode')

    print 'SELinux Context: %s' % details.get('selinux_ctx')

    if details.get('type') == 'file':
        print 'MD5:             %s' % details.get('md5')
        print 'Binary:          %s' % details.get('binary')

        if not details.get('binary'):
            print
            print 'Contents'
            print '--------'
            print details.get('contents')

####################

def help_configchannel_backup(self):
    print 'configchannel_backup: backup a config channel'
    print '''usage: configchannel_backup CHANNEL [OUTDIR]

OUTDIR defaults to $HOME/spacecmd-backup/configchannel/YYYY-MM-DD/CHANNEL
'''

def complete_configchannel_backup(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_configchannel_list('', True), text)

def do_configchannel_backup(self, args):
    (args, options) = parse_arguments(args)

    if len(args) < 1:
        self.help_configchannel_backup()
        return

    channel = args[0]
    revision = None

    # use an output base from the user if it was passed
    if len(args) == 2:
        outputpath_base = datetime.now().strftime(os.path.expanduser(args[1]))
    else:
        outputpath_base = os.path.expanduser('~/spacecmd-backup/configchannel')

        # make the final output path be <base>/date/channel
        outputpath_base = os.path.join( outputpath_base,
                                        datetime.now().strftime("%Y-%m-%d"),
                                        channel )

    try:
        if not os.path.isdir( outputpath_base ):
            os.makedirs( outputpath_base )
    except:
        logging.error('Could not create output directory')
        return

    # the server return a null exception if an invalid file is passed
    valid_files = self.do_configchannel_listfiles(channel, True)
    results = self.client.configchannel.lookupFileInfo(self.session,
                                                           channel,
                                                           valid_files )

    try:
        fh = open( outputpath_base + "/.metainfo", 'w' )
    except:
        logging.error('Could not create metainfo file')
        return

    for details in results:
        dumpfile = outputpath_base + details.get('path')
        dumpdir = dumpfile
        print 'Output Path:   %s' % dumpfile
        fh.write( '[%s]\n' % details.get('path') )
        fh.write( 'type = %s\n' % details.get('type') )
        fh.write( 'revision = %s\n' % details.get('revision') )
        fh.write( 'creation = %s\n' % details.get('creation') )
        fh.write( 'modified = %s\n' % details.get('modified') )

        if details.get('type') == 'symlink':
            fh.write( 'target_path = %s\n' % details.get('target_path'))
        else:
            fh.write( 'owner = %s\n' % details.get('owner') )
            fh.write( 'group = %s\n' % details.get('group') )
            fh.write( 'permissions_mode = %s\n' % details.get('permissions_mode') )

        fh.write( 'selinux_ctx = %s\n' % details.get('selinux_ctx') )

        if details.get('type') == 'file':
            dumpdir = os.path.dirname(dumpfile)

        if not os.path.isdir( dumpdir ):
            os.makedirs(dumpdir)

        if details.get('type') == 'file':
            fh.write( 'md5 = %s\n' % details.get('md5') )
            fh.write( 'binary = %s\n' % details.get('binary') )
            of = open( dumpfile, 'w' )
            of.write( details.get('contents') )
            of.close()

        fh.write( '\n' )

    fh.close()

####################

def help_configchannel_details(self):
    print 'configchannel_details: Show the details of a config channel'
    print 'usage: configchannel_details CHANNEL ...'

def complete_configchannel_details(self, text, line, beg, end):
    return tab_completer(self.do_configchannel_list('', True), text)

def do_configchannel_details(self, args):
    (args, options) = parse_arguments(args)

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
    print '''usage: configchannel_create [options]

options:
  -n NAME
  -d DESCRIPTION'''

def do_configchannel_create(self, args):
    options = [ Option('-n', '--name', action='store'),
                Option('-d', '--description', action='store') ]

    (args, options) = parse_arguments(args, options)

    if is_interactive(options):
        options.name = prompt_user('Name:', noblank = True)
        options.description = prompt_user('Description:')

        if options.description == '': options.description = options.name
    else:
        if not options.name:
            logging.error('A name is required')
            return

        if not options.description:
            options.description = options.name

    self.client.configchannel.create(self.session,
                                     options.name,
                                     options.name,
                                     options.description)

####################

def help_configchannel_delete(self):
    print 'configchannel_delete: Delete a configuration channel'
    print 'usage: configchannel_delete CHANNEL ...'

def complete_configchannel_delete(self, text, line, beg, end):
    return tab_completer(self.do_configchannel_list('', True), text)

def do_configchannel_delete(self, args):
    (args, options) = parse_arguments(args)

    if not len(args):
        self.help_configchannel_delete()
        return

    # allow globbing of configchannel channel names
    channels = filter_results(self.do_configchannel_list('', True), args)
    logging.debug("configchannel_delete called with args %s, channels=%s" % \
        (args, channels))

    if not len(channels):
        logging.error("No channels matched argument %s" % args)
        return

    # Print the channels prior to the confimation
    print '\n'.join(sorted(channels))

    if self.user_confirm('Delete these channels [y/N]:'):
        self.client.configchannel.deleteChannels(self.session, channels)

####################

def file_needs_b64_enc(self, contents):

    # we try to catch files automatically which will not work
    # correctly via the API so that they get uploaded correctly

    # Files with trailing newlines, which the API strips from files
    # uploaded as text, to avoid this we upload them as base64 encoded
    if contents != contents.rstrip():
        logging.info("trailing newlines detected, uploading as binary")
        return True

    # TODO : Add other exceptions here, e.g those containing characters which
    # are valid ascii but not valid XML (e.g the escape character)

    return False

def help_configchannel_addfile(self):
    print 'configchannel_addfile: Create a configuration file'
    print '''usage: configchannel_addfile [CHANNEL] [options]

options:
  -c CHANNEL
  -p PATH
  -r REVISION
  -o OWNER [default: root]
  -g GROUP [default: root]
  -m MODE [defualt: 0644]
  -x SELINUX_CONTEXT
  -d path is a directory
  -s path is a symlink
  -b path is a binary (or other file which needs base64 encoding)
  -t SYMLINK_TARGET
  -f local path to file contents

  Note re binary/base64: Some text files, notably those containing blank lines
  and those containing ASCII escape characters (or other charaters not allowed
  or processed correctly as text via the XMLRPC API) need to be sent as binary
'''

def complete_configchannel_addfile(self, text, line, beg, end):
    return tab_completer(self.do_configchannel_list('', True), text)

def do_configchannel_addfile(self, args, update_path=''):
    options = [ Option('-c', '--channel', action='store'),
                Option('-p', '--path', action='store'),
                Option('-o', '--owner', action='store'),
                Option('-g', '--group', action='store'),
                Option('-m', '--mode', action='store'),
                Option('-x', '--selinux-ctx', action='store'),
                Option('-t', '--target-path', action='store'),
                Option('-f', '--file', action='store'),
                Option('-r', '--revision', action='store'),
                Option('-s', '--symlink', action='store_true'),
                Option('-b', '--binary', action='store_true'),
                Option('-d', '--directory', action='store_true') ]

    (args, options) = parse_arguments(args, options)

    # initialize here instead of multiple times below
    contents = ''

    if is_interactive(options):
        # the channel name can be passed in
        if len(args):
            options.channel = args[0]
        else:
            while True:
                print 'Configuration Channels'
                print '----------------------'
                print '\n'.join(sorted(self.do_configchannel_list('', True)))
                print

                options.channel = prompt_user('Select:', noblank = True)

                # ensure the user enters a valid configuration channel
                if options.channel in self.do_configchannel_list('', True):
                    break
                else:
                    print
                    logging.warning('%s is not a valid channel' % \
                                    options.channel)
                    print

        if update_path:
            options.path = update_path
        else:
            options.path = prompt_user('Path:', noblank = True)

        # check if this file already exists
        try:
            fileinfo = \
                self.client.configchannel.lookupFileInfo(self.session,
                                                         options.channel,
                                                         [ options.path ])
        except:
            fileinfo = None

        # use existing values if available
        if fileinfo:
            for info in fileinfo:
                if info.get('path') == options.path:
                    logging.debug('Found existing file in channel')

                    options.owner = info.get('owner')
                    options.group = info.get('group')
                    options.mode = info.get('permissions_mode')
                    options.target_path = info.get('target_path')
                    options.selinux_ctx = info.get('selinux_ctx')
                    contents = info.get('contents')

                    if info.get('type') == 'symlink':
                        options.symlink = True

        if not options.owner: options.owner = 'root'
        if not options.group: options.group = 'root'
        if not options.mode: options.mode = '0644'

        # if this is a new file, ask if it's a symlink
        if not options.symlink:
            userinput = prompt_user('Symlink [y/N]:')
            if re.match('y', userinput, re.I):
                options.symlink = True
            else:
                options.symlink = False

        if options.symlink:
            target_input = prompt_user('Target Path:', noblank = True)
            selinux_input = prompt_user('SELinux Context [none]:')

            if target_input:
                options.target_path = target_input

            if selinux_input:
                options.selinux_ctx = selinux_input
        else:
            userinput = prompt_user('Directory [y/N]:')
            if re.match('y', userinput, re.I):
                options.directory = True
            else:
                options.directory = False

            owner_input = prompt_user('Owner [%s]:' % options.owner)
            group_input = prompt_user('Group [%s]:' % options.group)
            mode_input  = prompt_user('Mode [%s]:' % options.mode)
            selinux_input = \
                prompt_user('SELinux Context [%s]:' % options.selinux_ctx)
            revision_input  = prompt_user('Revision [next]:')

            if owner_input:
                options.owner = owner_input

            if group_input:
                options.group = group_input

            if mode_input:
                options.mode = mode_input

            if selinux_input:
                options.selinux_ctx = selinux_input

            if revision_input:
                try:
                    options.revision = int(revision_input)
                except:
                    logging.warning('The revision must be an integer')

            if not options.directory:
                if self.user_confirm('Read an existing file [y/N]:',
                                     nospacer = True, ignore_yes = True):
                    options.file = prompt_user('File:')
                    contents = read_file(options.file)
                else:
                    if contents:
                        template = contents
                    else:
                        template = ''

                    contents = editor(template = template, delete = True)
    else:
        # the channel name can be passed in without -c
        if len(args):
            options.channel = args[0]

        if not options.channel:
            logging.error("The channel name is required")
            return

        logging.debug("Using channel %s" % options.channel)

        if not options.path:
            logging.error('The path is required')
            return

        if not options.symlink and not options.directory:
            if options.file:
                contents = read_file(options.file)
                # If binary mode explicitly specified, we always base64 encode
                # we also check the file contents to see if we detect a file
                # which needs encoding
                if options.binary:
                    logging.debug("Binary selected, base64 encoding contents")
                    contents = base64.b64encode(contents)
                elif self.file_needs_b64_enc(contents):
                    logging.debug("Detected file needs base64 encoding")
                    contents = base64.b64encode(contents)
                    options.binary = True
            else:
                logging.error('You must provide the file contents')
                return

        if options.symlink and not options.target_path:
            logging.error('You must provide the target path for a symlink')
            return

    # selinux_ctx can't be None
    if not options.selinux_ctx:
        options.selinux_ctx = ''

    # directory can't be None
    if not options.directory:
        options.directory = False

    if options.symlink:
        file_info = { 'target_path' : options.target_path,
                      'selinux_ctx' : options.selinux_ctx }

        print 'Path:            %s' % options.path
        print 'Target Path:     %s' % file_info['target_path']
        print 'SELinux Context: %s' % file_info['selinux_ctx']
    else:
        if not options.owner: options.owner = 'root'
        if not options.group: options.group = 'root'
        if not options.mode:
            if options.directory:
                options.mode = '0755'
            else:
                options.mode = '0644'

        file_info = { 'contents'    : ''.join(contents),
                      'owner'       : options.owner,
                      'group'       : options.group,
                      'selinux_ctx' : options.selinux_ctx,
                      'permissions' : options.mode }

        if options.binary:
            file_info['contents_enc64'] = True

        print 'Path:            %s' % options.path
        print 'Directory:       %s' % options.directory
        print 'Owner:           %s' % file_info['owner']
        print 'Group:           %s' % file_info['group']
        print 'Mode:            %s' % file_info['permissions']
        print 'SELinux Context: %s' % file_info['selinux_ctx']

        # only add the revision field if the user supplied it
        if options.revision:
            file_info['revision'] = options.revision
            print 'Revision:        %i' % file_info['revision']

        if not options.directory:
            print
            if options.binary:
                print 'Contents (base64 encoded)'
            else:
                print 'Contents'
            print '--------'
            print file_info['contents']

    if self.user_confirm():
        if options.symlink:
            self.client.configchannel.createOrUpdateSymlink(self.session,
                                                            options.channel,
                                                            options.path,
                                                            file_info)
        else:
            # compatibility for Satellite 5.3
            if not self.check_api_version('10.11'):
                del file_info['selinux_ctx']

                if file_info.has_key('revision'):
                    del file_info['revision']

            self.client.configchannel.createOrUpdatePath(self.session,
                                                         options.channel,
                                                         options.path,
                                                         options.directory,
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
        return tab_completer(self.do_configchannel_listfiles(channel, True),
                             text)

def do_configchannel_updatefile(self, args):
    (args, options) = parse_arguments(args)

    if len(args) != 2:
        self.help_configchannel_updatefile()
        return

    return self.do_configchannel_addfile(args[0], update_path = args[1])

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
    (args, options) = parse_arguments(args)

    if len(args) < 2:
        self.help_configchannel_removefiles()
        return

    channel = args.pop(0)
    files = args

    if self.user_confirm('Remove these files [y/N]:'):
        self.client.configchannel.deleteFiles(self.session, channel, files)

####################

def help_configchannel_verifyfile(self):
    print 'configchannel_verifyfile: Verify a configuration file'
    print 'usage: configchannel_verifyfile CHANNEL FILE <SYSTEMS>'
    print
    print self.HELP_SYSTEM_OPTS


def complete_configchannel_verifyfile(self, text, line, beg, end):
    parts = line.split(' ')

    if len(parts) == 2:
        return tab_completer(self.do_configchannel_list('', True), text)
    elif len(parts) == 3:
        channel = parts[1]
        return tab_completer(self.do_configchannel_listfiles(channel, True),
                             text)
    elif len(parts) > 3:
        return self.tab_complete_systems(text)


def do_configchannel_verifyfile(self, args):
    (args, options) = parse_arguments(args)

    if len(args) < 3:
        self.help_configchannel_verifyfile()
        return

    channel = args[0]
    path = args[1]

    # use the systems listed in the SSM
    if re.match('ssm', args[2], re.I):
        systems = self.ssm.keys()
    else:
        systems = self.expand_systems(args[2:])

    system_ids = [ self.get_system_id(s) for s in systems ]

    action_id = \
        self.client.configchannel.scheduleFileComparisons(self.session,
                                                          channel,
                                                          path,
                                                          system_ids)

    logging.info('Action ID: %i' % action_id)

####################

def help_configchannel_export(self):
    print 'configchannel_export: export config channel(s) to json format file'
    print '''usage: configchannel_export <CHANNEL>... [options]
options:
    -f outfile.json : specify an output filename, defaults to <CHANNEL>.json
                      if exporting a single channel, ccs.json for multiple
                      channels, or cc_all.json if no CHANNEL specified
                      e.g (export ALL)

Note : CHANNEL list is optional, default is to export ALL'''

def complete_configchannel_export(self, text, line, beg, end):
    return tab_completer(self.do_configchannel_list('', True), text)

def export_configchannel_getdetails(self, channel):
    # Get the cc details
    logging.info("Getting config channel details for %s" % channel)
    details = self.client.configchannel.getDetails(self.session, channel)
    files = self.client.configchannel.listFiles(self.session, channel)
    details['files'] = []
    paths = [f['path'] for f in files]
    logging.debug("Found files %s for %s" % (paths, channel))
    fileinfo = self.client.configchannel.lookupFileInfo(self.session, \
                    channel, paths)
    # Now we strip the datetime fields from the Info structs, as they
    # are not JSON serializable with the default encoder, and we don't
    # need them on import anyway
    # We also strip some other fields which are not useful on import
    # This is a bit complicated because the createOrUpdateFoo functions
    # take two different struct formats, which are both different to 
    # the format returned by lookupFileInfo, doh!
    # We get:                         We need:
    #                                 (file/dir)      (symlink)
    # string "type"                   Y               Y
    # string "path"                   Y               Y
    # string "target_path"            N               Y
    # string "channel"                N               N
    # string "contents"               Y               N
    # int "revision"                  N (auto)        N (auto)
    # dateTime.iso8601 "creation"     N               N
    # dateTime.iso8601 "modified"     N               N
    # string "owner"                  Y               N
    # string "group"                  Y               N
    # int "permissions"               Y (as string!)  N
    # string "permissions_mode"       N               N
    # string "selinux_ctx"            Y               Y
    # boolean "binary"                N               N
    # string "md5"                    N               N
    # string "macro-start-delimiter"  Y               N
    # string "macro-end-delimiter"    Y               N
    for f in fileinfo:
        for k in [ 'channel', 'revision', 'creation', 'modified', \
                        'permissions_mode', 'binary', 'md5' ]:
            if f.has_key(k):
                del f[k]
        if f['type'] == 'symlink':
            for k in [ 'contents', 'owner', 'group', 'permissions', \
                            'macro-start-delimiter', 'macro-end-delimiter' ]:
                if f.has_key(k):
                    del f[k]
        else:
            if f.has_key('target_path'):
                del f['target_path']
            f['permissions'] = str(f['permissions'])

    details['files'] = fileinfo
    return details

def do_configchannel_export(self, args):
    options = [ Option('-f', '--file', action='store') ]
    (args, options) = parse_arguments(args, options)

    filename=""
    if options.file != None:
        logging.debug("Passed filename do_configchannel_export %s" % \
            options.file)
        filename=options.file

    # Get the list of ccs to export and sort out the filename if required
    ccs=[]
    if not len(args):
        if len(filename) == 0:
            filename="cc_all.json"
        logging.info("Exporting ALL config channels to %s" % filename)
        ccs = self.do_configchannel_list('', True)
    else:
        # allow globbing of configchannel channel names
        ccs = filter_results(self.do_configchannel_list('', True), args)
        logging.debug("configchannel_export called with args %s, ccs=%s" % \
            (args, ccs))
        if (len(ccs) == 0):
            logging.error("Error, no valid config channel passed, " + \
                "check name is  correct with spacecmd configchannel_list")
            return
        if len(filename) == 0:
            # No filename arg, so we try to do something sensible:
            # If we are exporting exactly one cc, we default to ccname.json
            # otherwise, generic ccs.json name
            if len(ccs) == 1:
                filename="%s.json" % ccs[0]
            else:
                filename="ccs.json"

    # Dump as a list of dict
    ccdetails_list=[]
    for c in ccs:
        logging.info("Exporting cc %s to %s" % (c, filename))
        ccdetails_list.append(self.export_configchannel_getdetails(c))

    logging.debug("About to dump %d ccs to %s" % \
        (len(ccdetails_list), filename))
    # Check if filepath exists, if it is an existing file
    # we prompt the user for confirmation
    if os.path.isfile(filename):
        if not self.user_confirm("File %s exists, " % filename + \
                    "confirm overwrite file? (y/n)"):
            return
    if json_dump_to_file(ccdetails_list, filename) != True:
        logging.error("Error saving exported config channels to file" % \
            filename)
        return

####################

def help_configchannel_import(self):
    print 'configchannel_import: import config channel(s) from json file'
    print '''usage: configchannel_import <JSONFILES...>'''

def do_configchannel_import(self, args):
    (args, options) = parse_arguments(args)

    if len(args) == 0:
        logging.error("Error, no filename passed")
        self.help_configchannel_import()
        return

    for filename in args:
        logging.debug("Passed filename do_configchannel_import %s" % filename)
        ccdetails_list = json_read_from_file(filename)
        if len(ccdetails_list) == 0:
            logging.error("Error, could not read json data from %s" % filename)
            return
        for ccdetails in ccdetails_list:
            if self.import_configchannel_fromdetails(ccdetails) != True:
                logging.error("Error importing configchannel %s" % \
                    ccdetails['name'])

# create a new cc based on the dict from export_configchannel_getdetails
def import_configchannel_fromdetails(self, ccdetails):

    # First we check that an existing channel with the same name does not exist
    existing_ccs = self.do_configchannel_list('', True)
    if ccdetails['name'] in existing_ccs:
        logging.warning("Config channel %s already exists! Skipping!" % \
            ccdetails['name'])
        return False
    else:
        # create the cc, we need to drop the org prefix from the cc name
        logging.info("Importing config channel  %s" % ccdetails['name'])

        # Create the channel
        self.client.configchannel.create(self.session,
                                 ccdetails['label'],
                                 ccdetails['name'],
                                 ccdetails['description'])
        for filedetails in ccdetails['files']:
            path = filedetails['path']
            del filedetails['path']
            logging.info("Found %s %s for cc %s" % \
                (filedetails['type'], path, ccdetails['name']))
            ret = None
            if filedetails['type'] == 'symlink':
                del filedetails['type']
                logging.debug("Adding symlink %s" % filedetails)
                ret = self.client.configchannel.createOrUpdateSymlink(\
                    self.session, ccdetails['label'], path, filedetails)
            else:
                if filedetails['type'] == 'directory':
                    isdir = True
                else:
                    isdir = False
                    # If binary files (or those containing characters which are
                    # invalid in XML, e.g the ascii escape character) are
                    # exported, you end up with a file with no "contents" key
                    # I guess the best thing to do here flag an error and
                    # import everything else
                    if not filedetails.has_key('contents'):
                        logging.error("Failed trying to import file %s" % path)
                        logging.error("if it is a binary file, or contains" +
                            " characters not valid in XML these can't be" +\
                            " exported correctly via the API")
                        continue
                    # Now we check if the file needs base64 encoding
                    # This will be because of trailing newlines (which get
                    # eaten by the API), since as mentioned above, binary
                    # and other problematic files can't be exported (there's
                    # no option to export in base64 encoded format AFAICS)
                    elif self.file_needs_b64_enc(filedetails['contents']):
                        logging.debug("Detected file needs base64 encoding")
                        filedetails['contents'] =\
                            base64.b64encode(filedetails['contents'])
                        filedetails['contents_enc64'] = True

                logging.debug("Creating %s %s" % \
                    (filedetails['type'], filedetails))
                if filedetails.has_key('type'):
                    del filedetails['type']
                if filedetails.has_key('binary'):
                    del filedetails['binary']
                ret = self.client.configchannel.createOrUpdatePath(\
                    self.session, ccdetails['label'], path, isdir, filedetails)
            if ret != None:
                logging.debug("Added file %s to %s" %\
                    (ret['path'],ccdetails['name']))
            else:
                logging.error("Error adding file %s to %s" % \
                    (filedetails['path'], ccdetails['label']))
                continue

    return True

####################

def help_configchannel_clone(self):
    print 'configchannel_clone: Clone config channel(s)'
    print '''usage examples:
                 configchannel_clone foo_label -c bar_label
                 configchannel_clone foo_label1 foo_label2 -c prefix
                 configchannel_clone foo_label -x "s/foo/bar"
                 configchannel_clone foo_label1 foo_label2 -x "s/foo/bar"

options:
  -c CLONE_LABEL : name/label of the resulting cc (note does not update
                   description, see -x option), treated as a prefix if
                   multiple keys are passed
  -x "s/foo/bar" : Optional regex replacement, replaces foo with bar in the
                   clone name, label and description
  Note : If no -c or -x option is specified, interactive is assumed'''

def complete_configchannel_clone(self, text, line, beg, end):
    return tab_completer(self.do_configchannel_list('', True), text)

def do_configchannel_clone(self, args):
    options = [ Option('-c', '--clonelabel', action='store'),
                Option('-x', '--regex', action='store') ]

    (args, options) = parse_arguments(args, options)
    allccs = self.do_configchannel_list('', True)

    if is_interactive(options):
        print
        print 'Config Channels'
        print '------------------'
        print '\n'.join(sorted(allccs))
        print

        if len(args) == 1:
            print "Channel to clone: %s" % args[0]
        else:
            # Clear out any args as interactive doesn't handle multiple ccs
            args = []
            args.append(prompt_user('Channel to clone:', noblank = True))
        options.clonelabel = prompt_user('Clone label:', noblank = True)
    else:
        if not options.clonelabel and not options.regex:
            logging.error("Error - must specify either -c or -x options!")
            self.help_configchannel_clone()
        else:
            logging.debug("%s : %s" % (options.clonelabel, options.regex))

    if not len(args):
        logging.error("Error no channel label passed!")
        self.help_configchannel_clone()
        return
    logging.debug("Got args=%s %d" % (args, len(args)))
    # allow globbing of configchannel channel names
    ccs = filter_results(self.do_configchannel_list('', True), args)
    logging.debug("Filtered ccs %s" % ccs)
    for cc in ccs:
        logging.debug("Cloning %s" % cc)
        ccdetails = self.export_configchannel_getdetails(cc)

        # If the -x/--regex option is passed, do a sed-style replacement over
        # the name, label and description.  This makes it easier to clone when
        # content is based on a known naming convention
        if options.regex:
            # Expect option to be formatted like a sed-replacement, s/foo/bar
            findstr = options.regex.split("/")[1]
            replacestr = options.regex.split("/")[2]
            logging.debug("--regex selected with %s, replacing %s with %s" % \
                (options.regex, findstr, replacestr))

            newname = re.sub(findstr, replacestr, ccdetails['name'])
            ccdetails['name'] = newname
            newlabel = re.sub(findstr, replacestr, ccdetails['label'])
            ccdetails['label'] = newlabel
            newdesc = re.sub(findstr, replacestr, ccdetails['description'])
            ccdetails['description'] = newdesc
            logging.debug("regex mode : %s %s %s" % (ccdetails['name'], \
                ccdetails['label'], ccdetails['description']))
        elif options.clonelabel:
            if len(ccs) > 1:
                newlabel = options.clonelabel + ccdetails['label']
                ccdetails['label'] = newlabel
                newname = options.clonelabel + ccdetails['name']
                ccdetails['name'] = newname
                logging.debug("clonelabel mode with >1 channel : %s" % \
                    ccdetails['label'])
            else:
                newlabel = options.clonelabel
                ccdetails['label'] = newlabel
                newname = options.clonelabel
                ccdetails['name'] = newname
                logging.debug("clonelabel mode with 1 channel : %s" % \
                    ccdetails['label'])

        # Finally : import the cc from the modified ccdetails
        if self.import_configchannel_fromdetails(ccdetails) != True:
            logging.error("Failed to clone %s to %s" % \
             (cc, ccdetails['label']))

# vim:ts=4:expandtab:
