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

def help_snippet_list(self):
    print 'snippet_list: List the available Kickstart snippets'
    print 'usage: snippet_list'

def do_snippet_list(self, args, doreturn=False):
    snippets = self.client.kickstart.snippet.listCustom(self.session)
    snippets = [s.get('name') for s in snippets]

    if doreturn:
        return snippets
    else:
        if len(snippets):
            print '\n'.join(sorted(snippets))

####################

def help_snippet_details(self):
    print 'snippet_details: Show the contents of a snippet'
    print 'usage: snippet_details SNIPPET ...'

def complete_snippet_details(self, text, line, beg, end):
    return tab_completer(self.do_snippet_list('', True),
                              text)

def do_snippet_details(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_snippet_details()
        return

    add_separator = False

    snippets = self.client.kickstart.snippet.listCustom(self.session)

    snippet = ''
    for name in args:
        for s in snippets:
            if s.get('name') == name:
                snippet = s
                break

        if not snippet:
            logging.warning('%s is not a valid snippet' % name)
            continue

        if add_separator: print self.SEPARATOR
        add_separator = True

        print 'Name:   %s' % snippet.get('name')
        print 'Macro:  %s' % snippet.get('fragment')
        print 'File:   %s' % snippet.get('file')

        print
        print snippet.get('contents')

####################

def help_snippet_create(self):
    print 'snippet_create: Create a Kickstart snippet'
    print 'usage: snippet_create'

def do_snippet_create(self, args, name=''):
    args = parse_arguments(args)

    template = ''
    if name:
        snippets = self.client.kickstart.snippet.listCustom(self.session)
        for s in snippets:
            if s.get('name') == name:
                template = s.get('contents')
                break
    else:
        name = prompt_user('Name:', noblank = True)

    (contents, ignore) = editor(template = template, delete = True)

    print
    print 'Contents:'
    print contents

    if self.user_confirm():
        self.client.kickstart.snippet.createOrUpdate(self.session,
                                                     name,
                                                     contents)

####################

def help_snippet_update(self):
    print 'snippet_update: Update a Kickstart snippet'
    print 'usage: snippet_update NAME'

def complete_snippet_update(self, text, line, beg, end):
    return tab_completer(self.do_snippet_list('', True), text)

def do_snippet_update(self, args):
    args = parse_arguments(args)
    
    if not len(args):
        self.help_snippet_update()
        return

    return self.do_snippet_create('', name=args[0])

####################

def help_snippet_delete(self):
    print 'snippet_removefile: Delete a Kickstart snippet'
    print 'usage: snippet_removefile NAME'

def complete_snippet_delete(self, text, line, beg, end):
    return tab_completer(self.do_snippet_list('', True), text)

def do_snippet_delete(self, args):
    args = parse_arguments(args)
    
    if not len(args):
        self.help_snippet_delete()
        return

    snippet = args[0]

    if self.user_confirm('Remove this snippet [y/N]:'):
        self.client.kickstart.snippet.delete(self.session, snippet)

# vim:ts=4:expandtab:
