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

__author__  = 'Aron Parsons <aron@redhat.com>'
__license__ = 'GPL'

import atexit, logging, os, readline, sys
from cmd import Cmd
from pwd import getpwuid
from spacecmd.utils import *

class SpacewalkShell(Cmd):
    __module_list = [ 'activationkey', 'configchannel', 'cryptokey',
                      'custominfo', 'distribution', 'errata',
                      'filepreservation', 'group', 'kickstart',
                      'misc', 'package', 'report', 'schedule',
                      'snippet', 'softwarechannel', 'ssm',
                      'system', 'user', 'utils' ]

    # a SyntaxError is thrown if we don't wrap this in an 'exec'
    for module in __module_list:
        exec 'from %s import *' % module

    MINIMUM_API_VERSION = 10.8

    HISTORY_LENGTH = 1024

    # life of caches in seconds
    SYSTEM_CACHE_TTL = 300
    PACKAGE_CACHE_TTL = 3600
    ERRATA_CACHE_TTL = 3600

    SEPARATOR = '\n' + '#' * 30 + '\n'

    ENTITLEMENTS = ['provisioning_entitled',
                    'enterprise_entitled',
                    'monitoring_entitled',
                    'virtualization_host',
                    'virtualization_host_platform']

    ARCH_LABELS = ['ia32', 'ia64', 'x86_64', 'ppc',
                   'i386-sun-solaris', 'sparc-sun-solaris']

    VIRT_TYPES = ['none', 'para_host', 'qemu', 'xenfv', 'xenpv']

    KICKSTART_OPTIONS = ['autostep', 'interactive', 'install', 'upgrade', 
                         'text', 'network', 'cdrom', 'harddrive', 'nfs', 
                         'url', 'lang', 'langsupport keyboard', 'mouse', 
                         'device', 'deviceprobe', 'zerombr', 'clearpart', 
                         'bootloader', 'timezone', 'auth', 'rootpw', 'selinux',
                         'reboot', 'firewall', 'xconfig', 'skipx', 'key', 
                         'ignoredisk', 'autopart', 'cmdline', 'firstboot', 
                         'graphical', 'iscsi', 'iscsiname', 'logging', 
                         'monitor', 'multipath', 'poweroff', 'halt', 'service',
                         'shutdown', 'user', 'vnc', 'zfcp']
    
    SYSTEM_SEARCH_FIELDS = ['id', 'name', 'ip', 'hostname', 
                            'device', 'vendor', 'driver']
    
    # list of system selection options for the help output
    HELP_SYSTEM_OPTS = '''<SYSTEMS> can be any of the following:
name
ssm (see 'help ssm')
search:QUERY (see 'help system_search')
group:GROUP
channel:CHANNEL
'''

    intro = '''
Welcome to spacecmd, a command-line interface to Spacewalk.

Type: 'help' for a list of commands
      'help <cmd>' for command-specific help
      'quit' to quit
'''
    cmdqueue = []
    completekey = 'tab'
    stdout = sys.stdout
    prompt = 'spacecmd> '

    # do nothing on an empty line
    emptyline = lambda self: None

    def __init__(self, options):
        self.session = ''
        self.username = ''
        self.server = ''

        # make the options available everywhere
        self.options = options

        userinfo = getpwuid(os.getuid())
        conf_dir = os.path.join(userinfo[5], '.spacecmd')

        try:
            if not os.path.isdir(conf_dir):
                os.mkdir(conf_dir, 0700)
        except OSError:
            logging.error('Could not create directory %s' % conf_dir) 

        self.ssm_cache_file = os.path.join(conf_dir, 'ssm')
        self.system_cache_file = os.path.join(conf_dir, 'systems')
        self.errata_cache_file = os.path.join(conf_dir, 'errata')
        self.packages_long_cache_file = os.path.join(conf_dir, 'packages_long')
        self.packages_by_id_cache_file = \
            os.path.join(conf_dir, 'packages_by_id')
        self.packages_short_cache_file = \
            os.path.join(conf_dir, 'packages_short')

        # load self.ssm from disk
        (self.ssm, ignore) = load_cache(self.ssm_cache_file)
        
        # load self.all_systems from disk
        (self.all_systems, self.system_cache_expire) = \
            load_cache(self.system_cache_file)

        # load self.all_errata from disk
        (self.all_errata, self.errata_cache_expire) = \
            load_cache(self.errata_cache_file)
      
        # load self.all_packages_short from disk 
        (self.all_packages_short, self.package_cache_expire) = \
            load_cache(self.packages_short_cache_file)
        
        # load self.all_packages from disk 
        (self.all_packages, self.package_cache_expire) = \
            load_cache(self.packages_long_cache_file)

        # load self.all_packages_by_id from disk 
        (self.all_packages_by_id, self.package_cache_expire) = \
            load_cache(self.packages_by_id_cache_file)
        
        self.session_file = os.path.join(conf_dir, 'session')
        self.history_file = os.path.join(conf_dir, 'history')

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


    # handle commands that exit the shell
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
            return line

        # login before attempting to run a command
        if not self.session:
            self.do_login('')
            if self.session == '': return ''
        
        parts = line.split()

        if len(parts):
            command = parts[0]
        else:
            return ''

        if len(parts[1:]):
            args = ' '.join(parts[1:])
        else:
            args = ''

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
            line += ' %s' % args
            parse_arguments(line)

            readline.add_history(line)
            print line
            return line
        else:
            logging.warning('%s: event not found' % command)
            return ''

# vim:ts=4:expandtab:
