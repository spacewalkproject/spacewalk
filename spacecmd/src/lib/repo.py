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
# Copyright 2011 Aron Parsons <aronparsons@gmail.com>
#

# NOTE: the 'self' variable is an instance of SpacewalkShell

# wildcard import
# pylint: disable=W0401,W0614

# unused argument
# pylint: disable=W0613

# invalid function name
# pylint: disable=C0103

import shlex
try:
    from xmlrpc import client as xmlrpclib
except ImportError:
    import xmlrpclib
from spacecmd.utils import *



def help_repo_list(self):
    print('repo_list: List all available user repos')
    print('usage: repo_list')


def do_repo_list(self, args, doreturn=False):
    repos = self.client.channel.software.listUserRepos(self.session)
    repos = [c.get('label') for c in repos]

    if doreturn:
        return repos
    else:
        if repos:
            print('\n'.join(sorted(repos)))

####################


def help_repo_details(self):
    print('repo_details: Show the details of a user repo')
    print('usage: repo_details <repo ...>')


def complete_repo_details(self, text, line, beg, end):
    return tab_completer(self.do_repo_list('', True), text)


def do_repo_details(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_repo_details()
        return

    # allow globbing of repo names
    repos = filter_results(self.do_repo_list('', True), args)

    add_separator = False

    for repo in repos:
        details = self.client.channel.software.getRepoDetails(
            self.session, repo)

        if add_separator:
            print(self.SEPARATOR)
        add_separator = True

        print('Repository Label:                  %s' % details.get('label'))
        print('Repository URL:                    %s' % details.get('sourceUrl'))
        print('Repository Type:                   %s' % details.get('type'))
        print('Repository SSL Ca Certificate:     %s' % (details.get('sslCaDesc') or "None"))
        print('Repository SSL Client Certificate: %s' % (details.get('sslCertDesc') or "None"))
        print('Repository SSL Client Key:         %s' % (details.get('sslKeyDesc') or "None"))

####################


def help_repo_listfilters(self):
    print('repo_listfilters: Show the filters for a user repo')
    print('usage: repo_listfilters repo')


def complete_repo_listfilters(self, text, line, beg, end):
    return tab_completer(self.do_repo_list('', True), text)


def do_repo_listfilters(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_repo_listfilters()
        return

    filters = \
        self.client.channel.software.listRepoFilters(self.session, args[0])

    for f in filters:
        print("%s%s" % (f.get('flag'), f.get('filter')))

####################


def help_repo_addfilters(self):
    print('repo_addfilters: Add filters for a user repo')
    print('usage: repo_addfilters repo <filter ...>')


def complete_repo_addfilters(self, text, line, beg, end):
    if len(line.split(' ')) <= 2:
        return tab_completer(self.do_repo_list('', True),
                             text)


def do_repo_addfilters(self, args):
    # arguments can start with -, so don't parse arguments in the normal way
    args = shlex.split(args)

    if not args:
        self.help_repo_addfilters()
        return

    repo = args[0]

    for arg in args[1:]:
        flag = arg[0]
        repofilter = arg[1:]

        if not (flag == '+' or flag == '-'):
            logging.error('Each filter must start with + or -')
            return

        self.client.channel.software.addRepoFilter(self.session,
                                                   repo,
                                                   {'filter': repofilter,
                                                    'flag': flag})

####################


def help_repo_removefilters(self):
    print('repo_removefilters: Remove filters from a user repo')
    print('usage: repo_removefilters repo <filter ...>')


def complete_repo_removefilters(self, text, line, beg, end):
    return tab_completer(self.do_repo_remove('', True), text)


def do_repo_removefilters(self, args):
    # arguments can start with -, so don't parse arguments in the normal way
    args = shlex.split(args)

    if not args:
        self.help_repo_removefilters()
        return

    repo = args[0]

    for arg in args[1:]:
        flag = arg[0]
        repofilter = arg[1:]

        if not (flag == '+' or flag == '-'):
            logging.error('Each filter must start with + or -')
            return

        self.client.channel.software.removeRepoFilter(self.session,
                                                      repo,
                                                      {'filter': repofilter,
                                                       'flag': flag})

####################


def help_repo_setfilters(self):
    print('repo_setfilters: Set the filters for a user repo')
    print('usage: repo_setfilters repo <filter ...>')


def complete_repo_setfilters(self, text, line, beg, end):
    return tab_completer(self.do_repo_set('', True), text)


def do_repo_setfilters(self, args):
    # arguments can start with -, so don't parse arguments in the normal way
    args = shlex.split(args)

    if not args:
        self.help_repo_setfilters()
        return

    repo = args[0]

    filters = []

    for arg in args[1:]:
        flag = arg[0]
        repofilter = arg[1:]

        if not (flag == '+' or flag == '-'):
            logging.error('Each filter must start with + or -')
            return

        filters.append({'filter': repofilter, 'flag': flag})

    self.client.channel.software.setRepoFilters(self.session, repo, filters)

####################


def help_repo_clearfilters(self):
    print('repo_clearfilters: Clears the filters for a user repo')
    print('usage: repo_clearfilters repo')


def complete_repo_clearfilters(self, text, line, beg, end):
    return tab_completer(self.do_repo_clear('', True), text)


def do_repo_clearfilters(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_repo_clearfilters()
        return

    if self.user_confirm('Remove these filters [y/N]:'):
        self.client.channel.software.clearRepoFilters(self.session, args[0])

####################


def help_repo_delete(self):
    print('repo_delete: Delete a user repo')
    print('usage: repo_delete <repo ...>')


def complete_repo_delete(self, text, line, beg, end):
    return tab_completer(self.do_repo_list('', True), text)


def do_repo_delete(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_repo_delete()
        return

    # allow globbing of repo names
    repos = filter_results(self.do_repo_list('', True), args)

    print('Repos')
    print('-----')
    print('\n'.join(sorted(repos)))

    if self.user_confirm('Delete these repos [y/N]:'):
        for repo in repos:
            try:
                self.client.channel.software.removeRepo(self.session, repo)
            except xmlrpclib.Fault:
                logging.error('Failed to remove repo %s' % repo)

####################


def help_repo_create(self):
    print('repo_create: Create a user repository')
    print('''usage: repo_create <options>)

options:
  -n, --name   name of repository
  -u, --url    url of repository
  -t, --type   type of repository (defaults to yum)

  --ca         SSL CA certificate (not required)
  --cert       SSL Client certificate (not required)
  --key        SSL Client key (not required)''')


def do_repo_create(self, args):
    arg_parser = get_argument_parser()
    arg_parser.add_argument('-n', '--name')
    arg_parser.add_argument('-u', '--url')
    arg_parser.add_argument('-t', '--type')
    arg_parser.add_argument('--ca', default='')
    arg_parser.add_argument('--cert', default='')
    arg_parser.add_argument('--key', default='')

    (args, options) = parse_command_arguments(args, arg_parser)

    if is_interactive(options):
        options.name = prompt_user('Name:', noblank=True)
        options.url = prompt_user('URL:', noblank=True)
        options.type = prompt_user('Type:', noblank=True)
        options.ca = prompt_user('SSL CA cert:')
        options.cert = prompt_user('SSL Client cert:')
        options.key = prompt_user('SSL Client key:')
    else:
        if not options.name:
            logging.error('A name is required')
            return

        if not options.url:
            logging.error('A URL is required')
            return

        if not options.type:
            options.type = 'yum'

    self.client.channel.software.createRepo(self.session,
                                            options.name,
                                            options.type,
                                            options.url,
                                            options.ca,
                                            options.cert,
                                            options.key)

####################


def help_repo_rename(self):
    print('repo_rename: Rename a user repository')
    print('usage: repo_rename OLDNAME NEWNAME')


def complete_repo_rename(self, text, line, beg, end):
    if len(line.split(' ')) <= 2:
        return tab_completer(self.do_repo_list('', True),
                             text)


def do_repo_rename(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if len(args) != 2:
        self.help_repo_rename()
        return

    try:
        details = self.client.channel.software.getRepoDetails(self.session, args[0])
        oldname = details.get('id')
    except xmlrpclib.Fault:
        logging.error('Could not find repo %s' % args[0])
        return False

    newname = args[1]

    self.client.channel.software.updateRepoLabel(self.session, oldname, newname)

####################


def help_repo_updateurl(self):
    print('repo_updateurl: Change the URL of a user repository')
    print('usage: repo_updateurl <repo> <url>')


def complete_repo_updateurl(self, text, line, beg, end):
    if len(line.split(' ')) == 2:
        return tab_completer(self.do_repo_list('', True),
                             text)


def do_repo_updateurl(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if len(args) != 2:
        self.help_repo_updateurl()
        return

    name = args[0]
    url = args[1]

    self.client.channel.software.updateRepoUrl(self.session, name, url)


def help_repo_updatessl(self):
    print('repo_updatessl: Change the SSL certificates of a user repository')
    print('''usage: repo_updatessl <options>)
options:
  --ca         SSL CA certificate (not required)
  --cert       SSL Client certificate (not required)
  --key        SSL Client key (not required)''')


def do_repo_updatessl(self, args):
    arg_parser = get_argument_parser()
    arg_parser.add_argument('-n', '--name')
    arg_parser.add_argument('--ca', default='')
    arg_parser.add_argument('--cert', default='')
    arg_parser.add_argument('--key', default='')

    (args, options) = parse_command_arguments(args, arg_parser)

    if is_interactive(options):
        options.name = prompt_user('Name:', noblank=True)
        options.ca = prompt_user('SSL CA cert:')
        options.cert = prompt_user('SSL Client cert:')
        options.key = prompt_user('SSL Client key:')
    else:
        if not options.name:
            logging.error('A name is required')
            return

    self.client.channel.software.updateRepoSsl(self.session,
                                               options.name,
                                               options.ca,
                                               options.cert,
                                               options.key)
