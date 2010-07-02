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

from spacecmd.utils import *

def help_cryptokey_create(self):
    print 'cryptokey_create: Create a cryptographic key'
    print 'usage: cryptokey_create'

def do_cryptokey_create(self, args):
    key_type = ''
    while not re.match('GPG|SSL', key_type):
        key_type = prompt_user('GPG or SSL [G/S]:')
       
        if re.match('G', key_type, re.I):
            key_type = 'GPG'
        elif re.match('S', key_type, re.I):
            key_type = 'SSL'
        else:
            logging.warning('Invalid key type')
            key_type = '' 

    description = ''
    while description == '':
        description = prompt_user('Description:')

    content = editor(delete=True)

    self.client.kickstart.keys.create(self.session,
                                      description,
                                      key_type,
                                      content)

####################

def help_cryptokey_delete(self):
    print 'cryptokey_delete: Delete a cryptographic key'
    print 'usage: cryptokey_delete NAME'

def complete_cryptokey_delete(self, text, line, beg, end):
    if len(line.split(' ')) <= 2:
        return tab_completer(self.do_cryptokey_list('', True), 
                                  text)

def do_cryptokey_delete(self, args):
    args = parse_arguments(args)

    if len(args) != 1:
        self.help_cryptokey_delete()
        return

    name = args[0]

    if self.user_confirm('Delete this key [y/N]:'):
        self.client.kickstart.keys.delete(self.session, name)

####################

def help_cryptokey_list(self):
    print 'cryptokey_list: List all cryptographic keys (SSL, GPG)'
    print 'usage: cryptokey_list'

def do_cryptokey_list(self, args, doreturn=False):
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
    args = parse_arguments(args)

    if not len(args):
        self.help_cryptokey_details()
        return

    add_separator = False

    for key in args:
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
