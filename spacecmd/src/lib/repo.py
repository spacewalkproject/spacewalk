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
# Copyright 2011 Aron Parsons <aron@redhat.com>
#

# NOTE: the 'self' variable is an instance of SpacewalkShell

from spacecmd.utils import *

def help_repo_list(self):
    print 'repo_list: List all available user repos'
    print 'usage: repo_list'

def do_repo_list(self, args, doreturn=False):
    repos = self.client.channel.software.listUserRepos(self.session)
    repos = [c.get('label') for c in repos]

    if doreturn:
        return repos
    else:
        if len(repos):
            print '\n'.join(sorted(repos))

####################

def help_repo_details(self):
    print 'repo_details: Show the details of a user repo'
    print 'usage: repo_details <repo ...>'

def complete_repo_details(self, text, line, beg, end):
    return tab_completer(self.do_repo_list('', True), text)

def do_repo_details(self, args):
    (args, options) = parse_arguments(args)

    if not len(args):
        self.help_repo_details()
        return

    # allow globbing of repo names
    repos = filter_results(self.do_repo_list('', True), args)

    add_separator = False

    for repo in repos:
        details = self.client.channel.software.getRepoDetails(\
                                    self.session, repo)

        if add_separator: print self.SEPARATOR
        add_separator = True

        print 'Repository Label:   %s' % details.get('label')
        print 'Repository URL:     %s' % details.get('sourceUrl')
        print 'Repository Type:    %s' % details.get('type')
