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

__author__  = 'Aron Parsons <aron@redhat.com>'
__license__ = 'GPL'

# spacecmd.utils
from utils import *

import atexit, logging, os, re, readline
import sys, urllib2, xml, xmlrpclib

from cmd import Cmd
from datetime import datetime, timedelta
from getpass import getpass
from operator import itemgetter
from pwd import getpwuid
from textwrap import wrap

class SpacewalkShell(Cmd):
    __module_list = [ 'activationkey', 'configchannel', 'cryptokey',
                      'custominfo', 'distribution', 'errata',
                      'filepreservation', 'group', 'kickstart',
                      'misc', 'package', 'report', 'schedule',
                      'snippet', 'softwarechannel', 'ssm',
                      'system', 'user', 'utils' ]

    for module in __module_list:
        exec 'from %s import *' % module

    MINIMUM_API_VERSION = 10.8

    HISTORY_LENGTH = 1024

    # life of caches in seconds
    SYSTEM_CACHE_TTL = 300
    PACKAGE_CACHE_TTL = 3600
    ERRATA_CACHE_TTL = 3600

    SEPARATOR = '\n--------------------\n'

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
Welcome to spacecmd, a command line interface to Spacewalk.

For a full set of commands, type 'help' on the prompt.
For help for a specific command try 'help <cmd>'.
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
      
        # load self.all_package_shortnames from disk 
        (self.all_package_shortnames, self.package_cache_expire) = \
            load_cache(self.packages_short_cache_file)
        
        # load self.all_package_longnames from disk 
        (self.all_package_longnames, self.package_cache_expire) = \
            load_cache(self.packages_long_cache_file)
        
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

####################

    def tab_complete_errata(self, text):
        options = self.do_errata_list('', True)
        options.append('search:')

        return tab_completer(options, text)


    def tab_complete_systems(self, text):
        if re.match('group:', text):
            # prepend 'group' to each item for tab completion
            groups = ['group:%s' % g for g in self.do_group_list('', True)]

            return tab_completer(groups, text)
        elif re.match('channel:', text):
            # prepend 'channel' to each item for tab completion
            channels = ['channel:%s' % s \
                for s in self.do_softwarechannel_list('', True)]

            return tab_completer(channels, text)
        elif re.match('search:', text):
            # prepend 'search' to each item for tab completion
            fields = ['search:%s:' % f for f in self.SYSTEM_SEARCH_FIELDS]
            return tab_completer(fields, text)
        else:
            options = self.get_system_names()

            # add our special search options
            options.extend([ 'group:', 'channel:', 'search:' ])

            return tab_completer(options, text)


    def remove_last_history_item(self):
        last = readline.get_current_history_length() - 1

        if last >= 0:
            readline.remove_history_item(last)


    def clear_errata_cache(self):
        self.all_errata = []
        self.errata_cache_expire = datetime.now()

    def generate_errata_cache(self, force=False):
        if not force and datetime.now() < self.errata_cache_expire:
            return

        logging.debug('Regenerating internal errata cache')

        channels = self.client.channel.listSoftwareChannels(self.session)
        channels = [c.get('label') for c in channels]

        for c in channels:
            errata = \
                self.client.channel.software.listErrata(self.session, c)

            for e in errata:
                if e.get('advisory_name') not in self.all_errata: 
                    self.all_errata[e.get('advisory_name')] = \
                        { 'type' : e.get('advisory_type'),
                          'date' : e.get('date'),
                          'synopsis' : e.get('advisory_synopsis') }

        self.errata_cache_expire = \
            datetime.now() + timedelta(self.ERRATA_CACHE_TTL)

        # store the cache to disk to speed things up
        save_cache(self.errata_cache_file, self.all_errata, 
                        self.errata_cache_expire)


    def clear_package_cache(self):
        self.all_package_shortnames = {}
        self.all_package_longnames = {}
        self.package_cache_expire = datetime.now()

    def generate_package_cache(self, force=False):
        if not force and datetime.now() < self.package_cache_expire:
            return

        logging.debug('Regenerating internal package cache')

        channels = self.client.channel.listSoftwareChannels(self.session)
        channels = [c.get('label') for c in channels]

        for c in channels:
            packages = \
                self.client.channel.software.listAllPackages(self.session, c)

            for p in packages:
                if not p.get('name') in self.all_package_shortnames:
                    self.all_package_shortnames[p.get('name')] = ''

                longname = build_package_names(p)

                if not longname in self.all_package_longnames:
                    self.all_package_longnames[longname] = p.get('id')

        self.package_cache_expire = \
            datetime.now() + timedelta(seconds=self.PACKAGE_CACHE_TTL)

        # store the cache to disk to speed things up
        save_cache(self.packages_short_cache_file,
                        self.all_package_shortnames, 
                        self.package_cache_expire)
        
        save_cache(self.packages_long_cache_file, 
                        self.all_package_longnames, 
                        self.package_cache_expire)


    # create a global list of all available package names
    def get_package_names(self, longnames=False):
        self.generate_package_cache()

        if longnames:
            return self.all_package_longnames.keys()
        else:
            return self.all_package_shortnames


    def get_package_id(self, name):
        if name in self.all_package_longnames:
            return self.all_package_longnames[name]


    def clear_system_cache(self):
        self.all_systems = {}
        self.system_cache_expire = datetime.now()


    def generate_system_cache(self, force=False):
        if not force and datetime.now() < self.system_cache_expire:
            return

        logging.debug('Regenerating internal system cache')

        systems = self.client.system.listSystems(self.session)

        self.all_systems = {}
        for s in systems:
            self.all_systems[s.get('id')] = s.get('name')

        self.system_cache_expire = \
            datetime.now() + timedelta(seconds=self.SYSTEM_CACHE_TTL)

        # store the cache to disk to speed things up
        save_cache(self.system_cache_file, self.all_systems, 
                        self.system_cache_expire)


    def get_system_names(self):
        self.generate_system_cache()
        return self.all_systems.values()


    # check for duplicate system names and return the system ID
    def get_system_id(self, name):
        self.generate_system_cache()

        try:
            # check if we were passed a system instead of a name
            id = int(name)
            if id in self.all_systems: return id
        except ValueError:
            pass

        # get a set of matching systems to check for duplicate names
        systems = []
        for id in self.all_systems:
            if name == self.all_systems[id]:
                systems.append(id)

        if len(systems) == 1:
            return systems[0]
        elif not len(systems):
            logging.warning("Can't find system ID for %s" % name)
            return 0
        else:
            logging.warning('Multiple systems found with the same name')

            for id in systems:
                logging.warning('%s = %s' % (name, str(id)))

            return 0


    def expand_errata(self, args):
        if not isinstance(args, list):
            args = args.split()

        errata = []
        for item in args:
            if re.match('search:', item):
                item = re.sub('search:', '', item)
                errata.extend(self.do_errata_search(item, True))
            else:
                errata.append(item)

        self.generate_errata_cache()
        matches = filter_results(self.all_errata, errata)

        return matches


    def expand_systems(self, args):
        if not isinstance(args, list):
            args = args.split()

        systems = []
        for item in args:
            if re.match('group:', item):
                item = re.sub('group:', '', item)
                members = self.do_group_listsystems(item, True)

                if len(members):
                    systems.extend(members)
                else:
                    logging.warning('No systems in group %s' % item)
            elif re.match('search:', item):
                query = item.split(':', 1)[1]
                results = self.do_system_search(query, True)

                if len(results):
                    systems.extend(results)
            elif re.match('channel:', item):
                item = re.sub('channel:', '', item)
                members = self.do_softwarechannel_listsystems(item, True)

                if len(members):
                    systems.extend(members)
                else:
                    logging.warning('No systems subscribed to %s' % item)
            else:
                try:
                    # determine the system name if passed an ID
                    id = int(item)
                    name = self.client.system.getName(self.session, id)
                    item = name.get('name')
                except ValueError:
                    pass

                systems.append(item)
        
        matches = filter_results(self.get_system_names(), systems)

        return matches


    def manipulate_child_channels(self, args, remove=False):
        args = parse_arguments(args)

        if len(args) != 2:
            if remove:
                self.help_system_removechildchannel()
            else:
                self.help_system_addchildchannel()
            return

        new_channel = args.pop()

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)
    
        print 'Systems:'
        for s in sorted(systems):
            print '  %s' % s

        print

        if remove:
            print 'Removing Channel:'
        else:
            print 'Adding Channel:'

        print '  %s' % new_channel

        if not self.user_confirm(): return

        for system in systems:
            system_id = self.get_system_id(system)
            if not system_id: continue

            child_channels = \
                self.client.system.listSubscribedChildChannels(self.session, 
                                                               system_id)

            child_channels = [c.get('label') for c in child_channels]

            if remove:
                if new_channel in child_channels:
                    child_channels.remove(new_channel)
            else:
                if new_channel not in child_channels:
                    child_channels.append(new_channel)

            self.client.system.setChildChannels(self.session,
                                                system_id,
                                                child_channels)

# vim:ts=4:expandtab:
