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

def help_custominfo_createkey(self):
    print 'custominfo_createkey: Create a custom key'
    print 'usage: custominfo_createkey [NAME] [DESCRIPTION]'

def do_custominfo_createkey(self, args):
    args = parse_arguments(args)

    if len(args) > 0:
        key = args[0]
    else:
        key = ''

    while key == '':
        key = prompt_user('Name:')

    if len(args) > 1:
        description = ' '.join(args[1:])
    else:
        description = prompt_user('Description:')
        if description == '':
            description = key

    self.client.system.custominfo.createKey(self.session,
                                            key,
                                            description)

####################

def help_custominfo_deletekey(self):
    print 'custominfo_deletekey: Delete a custom key'
    print 'usage: custominfo_deletekey KEY ...'

def complete_custominfo_deletekey(self, text, line, beg, end):
    return tab_completer(self.do_custominfo_listkeys('', True), text)

def do_custominfo_deletekey(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_custominfo_deletekey()
        return
        
    if not self.user_confirm('Delete these keys [y/N]:'): return

    for key in args:
        self.client.system.custominfo.deleteKey(self.session, key)

####################

def help_custominfo_listkeys(self):
    print 'custominfo_listkeys: List all custom keys'
    print 'usage: custominfo_listkeys'

def do_custominfo_listkeys(self, args, doreturn=False):
    keys = self.client.system.custominfo.listAllKeys(self.session)
    keys = [k.get('label') for k in keys]

    if doreturn:
        return keys
    else:
        if len(keys):
            print '\n'.join(sorted(keys))

####################

def help_custominfo_details(self):
    print 'custominfo_details: Show the details of a custom key'
    print 'usage: custominfo_details KEY ...'

def complete_custominfo_details(self, text, line, beg, end):
    return tab_completer(self.do_custominfo_listkeys('', True), text)

def do_custominfo_details(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_custominfo_details()
        return

    add_separator = False

    all_keys = self.client.system.custominfo.listAllKeys(self.session)

    for key in args:
        for k in all_keys:
            if k.get('label') == key:
                details = k

        if add_separator: print self.SEPARATOR
        add_separator = True

        print 'Label:        %s' % details.get('label')
        print 'Description:  %s' % details.get('description')
        print 'Modified:     %s' % \
                             format_time(details.get('last_modified').value)
        print 'System Count: %i' % details.get('system_count')

# vim:ts=4:expandtab:
