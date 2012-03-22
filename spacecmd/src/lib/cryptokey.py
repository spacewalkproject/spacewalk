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

def help_cryptokey_create(self):
    print 'cryptokey_create: Create a cryptographic key'
    print '''usage: cryptokey_create [options]

options:
  -t GPG or SSL
  -d DESCRIPTION
  -f KEY_FILE'''

def do_cryptokey_create(self, args):
    options = [ Option('-t', '--type', action='store'),
                Option('-d', '--description', action='store'),
                Option('-f', '--file', action='store') ]

    (args, options) = parse_arguments(args, options)

    if is_interactive(options):
        options.type = prompt_user('GPG or SSL [G/S]:')

        options.description = ''
        while options.description == '':
            options.description = prompt_user('Description:')
       
        if self.user_confirm('Read an existing file [y/N]:',
                             nospacer = True, ignore_yes = True):
            options.file = prompt_user('File:')
        else:
            options.contents = editor(delete=True)
    else:
        if not options.type:
            logging.error('The key type is required')
            return

        if not options.description:
            logging.error('A description is required')
            return

        if not options.file:
            logging.error('A file containing the key is required')
            return

    # read the file the user specified
    if options.file:
        options.contents = read_file(options.file)

    # translate the key type to what the server expects
    if re.match('G', options.type, re.I):
        options.type = 'GPG'
    elif re.match('S', options.type, re.I):
        options.type = 'SSL'
    else:
        logging.error('Invalid key type')
        return

    self.client.kickstart.keys.create(self.session,
                                      options.description,
                                      options.type,
                                      options.contents)

####################

def help_cryptokey_delete(self):
    print 'cryptokey_delete: Delete a cryptographic key'
    print 'usage: cryptokey_delete NAME'

def complete_cryptokey_delete(self, text, line, beg, end):
    if len(line.split(' ')) <= 2:
        return tab_completer(self.do_cryptokey_list('', True), 
                                  text)

def do_cryptokey_delete(self, args):
    (args, options) = parse_arguments(args)

    if not len(args):
        self.help_cryptokey_delete()
        return

    # allow globbing of cryptokey names
    keys = filter_results(self.do_cryptokey_list('', True), args)
    logging.debug("cryptokey_delete called with args %s, keys=%s" % \
        (args, keys))

    if not len(keys):
        logging.error("No keys matched argument %s" % args)
        return

    # Print the keys prior to the confirmation
    print '\n'.join(sorted(keys))

    if self.user_confirm('Delete key(s) [y/N]:'):
        for key in keys:
            self.client.kickstart.keys.delete(self.session, key)

####################

def help_cryptokey_list(self):
    print 'cryptokey_list: List all cryptographic keys (SSL, GPG)'
    print 'usage: cryptokey_list'

def do_cryptokey_list(self, args, doreturn = False):
    keys = self.client.kickstart.keys.listAllKeys(self.session)
    keys = [k.get('description') for k in keys]

    if doreturn:
        return keys
    else:
        if len(keys):
            print '\n'.join(sorted(keys))

####################

def help_cryptokey_details(self):
    print 'cryptokey_details: Show the contents of a cryptographic key'
    print 'usage: cryptokey_details KEY ...'

def complete_cryptokey_details(self, text, line, beg, end):
    return tab_completer(self.do_cryptokey_list('', True), text)

def do_cryptokey_details(self, args):
    (args, options) = parse_arguments(args)

    if not len(args):
        self.help_cryptokey_details()
        return

    # allow globbing of cryptokey names
    keys = filter_results(self.do_cryptokey_list('', True), args)
    logging.debug("cryptokey_details called with args %s, keys=%s" % \
        (args, keys))

    if not len(keys):
        logging.error("No keys matched argument %s" % args)
        return

    add_separator = False

    for key in keys:
        try:
            details = self.client.kickstart.keys.getDetails(self.session,
                                                            key)
        except:
            logging.warning('%s is not a valid crypto key' % key)
            return

        if add_separator: print self.SEPARATOR
        add_separator = True

        print 'Description: %s' % details.get('description')
        print 'Type:        %s' % details.get('type')

        print
        print details.get('content')

# vim:ts=4:expandtab:
