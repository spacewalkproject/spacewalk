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

import atexit, logging, os, readline, re, shlex, sys
from cmd import Cmd
from spacecmd.utils import *

class SpacewalkShell(Cmd):
    __module_list = [ 'activationkey', 'configchannel', 'cryptokey',
                      'custominfo', 'distribution', 'errata',
                      'filepreservation', 'group', 'kickstart',
                      'misc', 'org', 'package', 'repo', 'report', 'schedule',
                      'snippet', 'softwarechannel', 'ssm', 'api',
                      'system', 'user', 'utils' ]

    # a SyntaxError is thrown if we don't wrap this in an 'exec'
    for module in __module_list:
        exec 'from %s import *' % module

    # maximum length of history file
    HISTORY_LENGTH = 1024

    cmdqueue = []
    completekey = 'tab'
    stdout = sys.stdout
    prompt_template = 'spacecmd {SSM:##}> '
    current_line = ''

    # do nothing on an empty line
    emptyline = lambda self: None

    def __init__(self, options, conf_dir, config_parser):
        self.session = ''
        self.current_user = ''
        self.server = ''
        self.ssm = {}
        self.config = {}

        self.postcmd(False, '')

        # make the options available everywhere
        self.options = options

        # make the configuration file available everywhere
        self.config_parser = config_parser

        # this is used when loading and saving caches
        self.conf_dir = conf_dir

        self.history_file = os.path.join(self.conf_dir, 'history')

        try:
            # don't split on hyphens or colons during tab completion
            newdelims = readline.get_completer_delims()
            newdelims = re.sub(':|-|/', '', newdelims)
            readline.set_completer_delims(newdelims)

            if not options.nohistory:
                try:
                    if os.path.isfile(self.history_file):
                        readline.read_history_file(self.history_file)

                    readline.set_history_length(self.HISTORY_LENGTH)

                    # always write the history file on exit
                    atexit.register(readline.write_history_file,
                                    self.history_file)
                except IOError:
                    logging.error('Could not read history file')
        except:
            pass


    # handle shell exits and history substitution
    def precmd(self, line):
        # remove leading/trailing whitespace
        line = re.sub('^\s+|\s+$', '', line)

        # don't do anything on empty lines
        if line == '':
            return ''

        # terminate the shell
        if re.match('quit|exit|eof', line, re.I):
            print
            sys.exit(0)

        # don't attempt to login for some commands
        if re.match('help|login|logout|whoami|history|clear', line, re.I):
            # login required for clear_caches or it fails with:
            # "SpacewalkShell instance has no attribute 'system_cache_file'"
            if not re.match('clear_caches', line, re.I):
                return line

        # login before attempting to run a command
        if not self.session:
            self.do_login('')
            if self.session == '': return ''

        parts = shlex.split(line)

        if len(parts):
            command = parts[0]
        else:
            return ''

        # print the help message for a command if the user passed --help
        if '--help' in parts:
            return 'help %s' % command

        # should we look for an item in the history?
        if command[0] != '!' or len(command) < 2:
            return line

        # remove the '!*' line from the history
        self.remove_last_history_item()

        history_match = False

        if command[1] == '!':
            # repeat the last command
            line = readline.get_history_item(
                       readline.get_current_history_length())

            if line:
                history_match = True
            else:
                logging.warning('%s: event not found' % command)
                return ''

        # attempt to find a numbered history item
        if not history_match:
            try:
                number = int(command[1:])
                line = readline.get_history_item(number)
                if line:
                    history_match = True
                else:
                    raise Exception
            except IndexError:
                pass
            except ValueError:
                pass

        # attempt to match the beginning of the string with a history item
        if not history_match:
            history_range = range(1, readline.get_current_history_length())
            history_range.reverse()

            for i in history_range:
                item = readline.get_history_item(i)
                if re.match(command[1:], item):
                    line = item
                    history_match = True
                    break

        # append the arguments to the substituted command
        if history_match:
            if len(parts[1:]):
                for arg in parts[1:]:
                    line += " '%s'" % arg

            readline.add_history(line)
            print line
            return line
        else:
            logging.warning('%s: event not found' % command)
            return ''


    # update the prompt with the SSM size
    def postcmd(self, cmdresult, cmd):
        self.print_result( cmdresult, cmd )
        self.prompt = re.sub('##', str(len(self.ssm)), self.prompt_template)

    def print_result( self, cmdresult, cmd ):
        logging.debug( cmd + ": " + repr(cmdresult) )
        if cmd:
            try:
                for i in cmdresult:
                    print i
            except TypeError:
                pass


# vim:ts=4:expandtab:
