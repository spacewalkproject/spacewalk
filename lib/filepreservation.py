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

def help_filepreservation_list(self):
    print 'filepreservation_list: List all file preservations'
    print 'usage: filepreservation_list'

def do_filepreservation_list(self, args, doreturn=False):
    lists = \
        self.client.kickstart.filepreservation.listAllFilePreservations(\
            self.session)
    lists = [ l.get('name') for l in lists ]

    if doreturn:
        return lists
    else:
        if len(lists):
            print '\n'.join(sorted(lists))

####################

def help_filepreservation_create(self):
    print 'filepreservation_create: Create a file preservation list'
    print 'usage: filepreservation_create [NAME] [FILE ...]'

def do_filepreservation_create(self, args):
    args = parse_arguments(args)

    if len(args):
        name = args[0]
    else:
        name = prompt_user('Name:', noblank=True)

    if len(args) > 1:
        files = args[1:]
    else:
        files = []

        while True:
            print 'File List:'
            print '\n'.join(sorted(files))
            print

            input = prompt_user('File [blank to finish]:')

            if input == '':
                break
            else:
                if input not in files:
                    files.append(input)

    print
    print 'File List:'
    print '\n'.join(sorted(files))
    
    if not self.user_confirm(): return

    self.client.kickstart.filepreservation.create(self.session,
                                                  name,
                                                  files)

####################

def help_filepreservation_delete(self):
    print 'filepreservation_delete: Delete a file preservation list'
    print 'usage: filepreservation_delete NAME'

def complete_filepreservation_delete(self, text, line, beg, end):
    return tab_completer(self.do_filepreservation_list('', True), text)

def do_filepreservation_delete(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_filepreservation_delete()
        return

    name = args[0]

    if not self.user_confirm('Delete this list [y/N]:'): return

    self.client.kickstart.filepreservation.delete(self.session, name)

####################

def help_filepreservation_details(self):
    print 'filepreservation_details: Show the details of a file ' + \
          'preservation list'
    print 'usage: filepreservation_details NAME'

def complete_filepreservation_details(self, text, line, beg, end):
    return tab_completer(self.do_filepreservation_list('', True), text)

def do_filepreservation_details(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_filepreservation_details()
        return

    name = args[0]

    details = \
        self.client.kickstart.filepreservation.getDetails(self.session, 
                                                          name)

    print '\n'.join(sorted(details.get('file_names')))        

# vim:ts=4:expandtab:
