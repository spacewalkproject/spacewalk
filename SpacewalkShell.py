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

import atexit, base64, logging, os, pickle, re, readline
import sys, urllib2, xml, xmlrpclib

from cmd import Cmd
from datetime import datetime, timedelta
from getpass import getpass
from operator import itemgetter
from pwd import getpwuid
from tempfile import mkstemp
from textwrap import wrap

class SpacewalkShell(Cmd):
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

    EDITORS = ['vim', 'vi', 'nano', 'emacs']
    
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
        except:
            logging.error('Could not create directory %s' % conf_dir) 

        self.ssm_cache_file = os.path.join(conf_dir, 'ssm')
        self.system_cache_file = os.path.join(conf_dir, 'systems')
        self.errata_cache_file = os.path.join(conf_dir, 'errata')
        self.packages_long_cache_file = os.path.join(conf_dir, 'packages_long')
        self.packages_short_cache_file = \
            os.path.join(conf_dir, 'packages_short')

        # load self.ssm from disk
        (self.ssm, ignore) = self.load_cache(self.ssm_cache_file)
        
        # load self.all_systems from disk
        (self.all_systems, self.system_cache_expire) = \
            self.load_cache(self.system_cache_file)

        # load self.all_errata from disk
        (self.all_errata, self.errata_cache_expire) = \
            self.load_cache(self.errata_cache_file)
      
        # load self.all_package_shortnames from disk 
        (self.all_package_shortnames, self.package_cache_expire) = \
            self.load_cache(self.packages_short_cache_file)
        
        # load self.all_package_longnames from disk 
        (self.all_package_longnames, self.package_cache_expire) = \
            self.load_cache(self.packages_long_cache_file)
        
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
                except:
                    logging.error('Could not read history file')
                    logging.debug(sys.exc_info())
        except:
            logging.debug(sys.exc_info())


    def preloop(self):
        if not self.session:
            self.do_login('')


    def parse_arguments(self, args):
        try:
            parts = args.split()

            # allow simple globbing
            parts = [re.sub('\*', '.*', a) for a in parts]

            return parts
        except IndexError:
            return []


    # handle commands that exit the shell
    def precmd(self, line, nohistory=False):
        # terminate the shell
        if re.match('quit|exit|eof', line, re.I):
            print
            sys.exit(0)

        if not re.match('help|login', line) and not self.session:
            logging.warning('You are not logged in')
            return ''

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
            except:
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
            self.parse_arguments(line)

            readline.add_history(line)
            print line
            return line
        else:
            logging.warning('%s: event not found' % command)
            return ''

####################

    def load_cache(self, file):
        data = {}
        expire = datetime.now()

        logging.debug('Loading cache from %s' % file)

        if os.path.isfile(file):
            try:
                input = open(file, 'r')
                data = pickle.load(input)
                input.close()
            except:
                logging.debug(sys.exc_info())
                logging.error("Couldn't load cache from %s" % file)

            if isinstance(data, list) or isinstance(data, dict):
                if 'expire' in data:
                    expire = data['expire']
                    del data['expire']
        else:
            logging.debug('%s does not exist' % file)

        return data, expire


    def save_cache(self, file, data, expire = None):
        if expire:
            data['expire'] = expire

        try:
            output = open(file, 'wb')
            pickle.dump(data, output, pickle.HIGHEST_PROTOCOL)
            output.close()
        except:
            logging.debug(sys.exc_info())
            logging.error("Couldn't write to %s" % file)

        if 'expire' in data:
            del data['expire']


    def tab_completer(self, options, text):
        return [o for o in options if re.match(text, o)]


    def tab_complete_systems(self, text):
        if re.match('group:', text):
            # prepend 'group' to each item for tab completion
            groups = ['group:%s' % g for g in self.do_group_list('', True)]

            return self.tab_completer(groups, text)
        elif re.match('channel:', text):
            # prepend 'channel' to each item for tab completion
            channels = ['channel:%s' % s \
                for s in self.do_softwarechannel_list('', True)]

            return self.tab_completer(channels, text)
        elif re.match('search:', text):
            # prepend 'search' to each item for tab completion
            fields = ['search:%s:' % f for f in self.SYSTEM_SEARCH_FIELDS]
            return self.tab_completer(fields, text)
        else:
            options = self.get_system_names()

            # add our special search options
            options.extend([ 'group:', 'channel:', 'search:' ])

            return self.tab_completer(options, text)


    def filter_results(self, list, patterns, search = False):
        matches = []
        for item in list:
            for pattern in patterns:
                if search:
                    result = re.search(pattern, item, re.I)
                else:
                    result = re.match(pattern, item, re.I)

                if result:
                    matches.append(item)
                    break

        return matches


    def editor(self, template = '', delete = False):
        # create a temporary file
        (descriptor, file_name) = mkstemp(prefix='spacecmd.')

        if template and descriptor:
            try:
                file = os.fdopen(descriptor, 'w')
                file.write(template)
                file.close()
            except:
                logging.warning('Could not open the temporary file')
                pass

        # use the user's specified editor
        if 'EDITOR' in os.environ:
            if self.EDITORS[0] != os.environ['EDITOR']:
                self.EDITORS.insert(0, os.environ['EDITOR'])

        success = False
        for editor_cmd in self.EDITORS:
            try:
                exit_code = os.spawnlp(os.P_WAIT, editor_cmd,
                                       editor_cmd, file_name)

                if exit_code == 0:
                    success = True
                    break
                else:
                    logging.error('Editor exited with code %s' % str(exit_code))
            except:
                logging.error(sys.exc_info()[1])
                logging.debug(sys.exc_info())

        if not success:
            logging.error('No editors found')
            return ''

        if os.path.isfile(file_name) and exit_code == 0:
            try:
                # read the session (format = username:session)
                file = open(file_name, 'r')
                contents = file.read()
                file.close()

                if delete:
                    try:
                        os.remove(file_name)
                        file_name = ''
                    except:
                        logging.error('Could not remove %s' % file_name)

                return (contents, file_name)
            except:
                logging.error('Could not read %s' % file_name)
                logging.debug(sys.exc_info())
                return ''


    def remove_last_history_item(self):
        last = readline.get_current_history_length() - 1

        if last >= 0:
            readline.remove_history_item(last)


    def prompt_user(self, prompt, noblank = False):
        try:
            while True:
                input = raw_input('%s ' % prompt)
                if noblank:
                    if input != '':
                        break
                else:
                    break
        except EOFError:
            print
            return ''

        if input != '':
            self.remove_last_history_item()

        return input


    def user_confirm(self, prompt='Is this ok [y/N]:'):
        if self.options.yes: return True

        answer = self.prompt_user('\n%s' % prompt)

        if re.match('y', answer, re.I):
            return True
        else:
            return False


    def format_time(self, time):
        return re.sub('T', ' ', time)


    # parse time input from the userand return xmlrpclib.DateTime
    def parse_time_input(self, time):
        if time == '' or re.match('now', time, re.I):
            time = datetime.now()
        else:
            # parse the time provided
            match = re.search('^\+?(\d+)(s|m|h|d)$', time, re.I)

            if not match or len(match.groups()) != 2:
                logging.error('Invalid time provided')
                return

            number = int(match.group(1))
            unit = match.group(2)

            if re.match('s', unit, re.I):
                delta = timedelta(seconds=number)
            elif re.match('m', unit, re.I):
                delta = timedelta(minutes=number)
            elif re.match('h', unit, re.I):
                delta = timedelta(hours=number)
            elif re.match('d', unit, re.I):
                delta = timedelta(days=number)

            time = datetime.now() + delta

        time = xmlrpclib.DateTime(time.timetuple())

        if time:
            return time
        else:
            logging.error('Invalid time provided')
            return


    # build a proper RPM name from the various parts
    def build_package_names(self, packages):
        single = False

        if not isinstance(packages, list):
            packages = [packages]
            single = True

        package_names = []
        for p in packages:
            package = '%s-%s-%s' % (
                      p.get('name'), p.get('version'), p.get('release'))

            if p.get('epoch') != ' ' and p.get('epoch') != '':
                package += ':%s' % p.get('epoch')

            if p.get('arch'):
                # system.listPackages uses AMD64 instead of x86_64
                arch = re.sub('AMD64', 'x86_64', p.get('arch'))

                package += '.%s' % arch
            elif p.get('arch_label'):
                package += '.%s' % p.get('arch_label')

            package_names.append(package)

        if single:
            return package_names[0]
        else:
            package_names.sort()
            return package_names


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
        self.save_cache(self.errata_cache_file, self.all_errata, 
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

                longname = self.build_package_names(p)

                if not longname in self.all_package_longnames:
                    self.all_package_longnames[longname] = p.get('id')

        self.package_cache_expire = \
            datetime.now() + timedelta(seconds=self.PACKAGE_CACHE_TTL)

        # store the cache to disk to speed things up
        self.save_cache(self.packages_short_cache_file,
                        self.all_package_shortnames, 
                        self.package_cache_expire)
        
        self.save_cache(self.packages_long_cache_file, 
                        self.all_package_longnames, 
                        self.package_cache_expire)


    # create a global list of all available package names
    def get_package_names(self, longnames=False):
        self.generate_package_cache()

        if longnames:
            return self.all_package_longnames.keys()
        else:
            return self.all_package_shortnames


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
        self.save_cache(self.system_cache_file, self.all_systems, 
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
        except:
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
                except:
                    pass

                systems.append(item)
        
        matches = self.filter_results(self.get_system_names(), systems)

        return matches


    def list_base_channels(self):
        all_channels = self.client.channel.listSoftwareChannels(self.session)

        base_channels = []
        for c in all_channels:
            if not c.get('parent_label'):
                base_channels.append(c.get('label'))

        return base_channels


    def list_child_channels(self, system, subscribed=False):
        if re.match('ssm', system, re.I):
            if len(self.ssm):
                system = self.ssm.keys()[0]

        system_id = self.get_system_id(system)
        if not system_id: return

        if subscribed:
            channels = \
                self.client.system.listSubscribedChildChannels(self.session,
                                                               system_id)
        else:
            channels = \
                self.client.system.listSubscribableChildChannels(self.session,
                                                                 system_id)

        return [c.get('label') for c in channels]   


    def print_errata_summary(self, errata):
        date_parts = errata.get('date').split()

        if len(date_parts) > 1:
            errata['date'] = date_parts[0]

        print '%s  %s  %s'  % (
              errata.get('advisory_name').ljust(14),
              wrap(errata.get('advisory_synopsis'), 50)[0].ljust(50),
              errata.get('date').rjust(8))


    def manipulate_child_channels(self, args, remove=False):
        args = self.parse_arguments(args)

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


    def print_errata_list(self, errata):
            rhsa = []
            rhea = []
            rhba = []

            for e in errata:
                if re.match('security', e.get('advisory_type'), re.I):
                    rhsa.append(e)
                elif re.match('bug fix', e.get('advisory_type'), re.I):
                    rhba.append(e)
                elif re.match('enhancement', e.get('advisory_type'), re.I):
                    rhea.append(e)
                else:
                    logging.warning('%s is an unknown errata type' % (
                                    e.get('advisory_name')))
                    continue

            if not len(errata): return

            if len(rhsa):
                print 'Security Errata:'
                map(self.print_errata_summary, rhsa)

            if len(rhba):
                if len(rhsa):
                    print

                print 'Bug Fix Errata:'
                map(self.print_errata_summary, rhba)

            if len(rhea):
                if len(rhsa) or len(rhba):
                    print

                print 'Enhancement Errata:'
                map(self.print_errata_summary, rhea)


    def print_action_summary(self, action, systems=[]):
        print 'ID:         %i' % action.get('id')
        print 'Type:       %s' % action.get('type')
        print 'Scheduler:  %s' % action.get('scheduler')
        print 'Start Time: %s' % self.format_time(action.get('earliest').value)
        print 'Systems:    %i' % len(systems)


    #XXX: Bugzilla 608868
    def print_action_output(self, action):
        print 'System:    %s' % action.get('server_name')
        print 'Completed: %s' % self.format_time(action.get('timestamp').value)
        print 'Output:'
        print action.get('message')
        

    def config_channel_order(self, new_channels=[]):
        all_channels = self.do_configchannel_list('', True)

        while True:
            print 'Current Selections:'
            for i in range(len(new_channels)):
                print '%i. %s' % (i + 1, new_channels[i])
  
            print 
            action = self.prompt_user('a[dd], r[emove], c[lear], d[one]:')

            if re.match('a', action, re.I):
                print 
                print 'Available Configuration Channels:'
                for c in sorted(all_channels):
                    print c

                print
                channel = self.prompt_user('Channel:')
                
                if channel not in all_channels:
                    logging.warning('Invalid channel')
                    continue
            
                try:
                    rank = int(self.prompt_user('New Rank:'))

                    if channel in new_channels:
                        new_channels.remove(channel)

                    new_channels.insert(rank - 1, channel)
                except IndexError, ValueError:
                    logging.warning('Invalid rank')
                    continue
            elif re.match('r', action, re.I):
                channel = self.prompt_user('Channel:')

                if channel not in all_channels:
                    logging.warning('Invalid channel')
                    continue

                new_channels.remove(channel)
            elif re.match('c', action, re.I):
                print 'Clearing current selections'
                new_channels = []
                continue
            elif re.match('d', action, re.I):
                break

            print

        return new_channels


    def list_locales(self):
        if not os.path.isdir('/usr/share/zoneinfo'): return []

        zones = []

        for item in os.listdir('/usr/share/zoneinfo'):
            path = os.path.join('/usr/share/zoneinfo', item)

            if os.path.isdir(path):
                for subitem in os.listdir(path):
                    zones.append(os.path.join(item, subitem))
            else:
                zones.append(item)

        return zones

####################

    def help_activationkey_addpackages(self):
        print 'activationkey_addpackages: Add packages to an activation key'
        print 'usage: activationkey_addpackages KEY <PACKAGE ...>'

    def complete_activationkey_addpackages(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_activationkey_list('', True), 
                                      text)
        elif len(parts) > 2:
            return self.tab_completer(self.get_package_names(), text)

    def do_activationkey_addpackages(self, args):
        args = self.parse_arguments(args)

        if not len(args) >= 2:
            self.help_activationkey_addpackages()
            return

        key = args.pop(0)
        packages = [{'name' : a} for a in args]

        self.client.activationkey.addPackages(self.session, key, packages)

####################

    def help_activationkey_removepackages(self):
        print 'activationkey_removepackages: Remove packages from an ' + \
              'activation key'
        print 'usage: activationkey_removepackages KEY <PACKAGE ...>'

    def complete_activationkey_removepackages(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_activationkey_list('', True), 
                                      text)
        elif len(parts) > 2:
            details = self.client.activationkey.getDetails(self.session, 
                                                           parts[1])
            packages = [ p['name'] for p in details.get('packages') ]
            return self.tab_completer(packages, text)

    def do_activationkey_removepackages(self, args):
        args = self.parse_arguments(args)

        if not len(args) >= 2:
            self.help_activationkey_removepackages()
            return

        key = args.pop(0)
        packages = [{'name' : a} for a in args]

        self.client.activationkey.removePackages(self.session, key, packages)

####################

    def help_activationkey_addgroups(self):
        print 'activationkey_addgroups: Add groups to an activation key'
        print 'usage: activationkey_addgroups KEY <GROUP ...>'

    def complete_activationkey_addgroups(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_activationkey_list('', True), 
                                      text)
        elif len(parts) > 2:
            return self.tab_completer(self.do_group_list('', True), text)

    def do_activationkey_addgroups(self, args):
        args = self.parse_arguments(args)

        if not len(args) >= 2:
            self.help_activationkey_addgroups()
            return

        key = args.pop(0)

        groups = []
        for a in args:
            details = self.client.systemgroup.getDetails(self.session, a)
            groups.append(details.get('id'))

        self.client.activationkey.addServerGroups(self.session, key, groups)

####################

    def help_activationkey_removegroups(self):
        print 'activationkey_removegroups: Remove groups from an activation key'
        print 'usage: activationkey_removegroups KEY <GROUP ...>'

    def complete_activationkey_removegroups(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_activationkey_list('', True), 
                                      text)
        elif len(parts) > 2:
            key_details = self.client.activationkey.getDetails(self.session, 
                                                               parts[1])

            groups = []
            for group in key_details.get('server_group_ids'):
                details = self.client.systemgroup.getDetails(self.session, 
                                                             group)
                groups.append(details.get('name'))                

            return self.tab_completer(groups, text)

    def do_activationkey_removegroups(self, args):
        args = self.parse_arguments(args)

        if not len(args) >= 2:
            self.help_activationkey_removegroups()
            return

        key = args.pop(0)

        groups = []
        for a in args:
            details = self.client.systemgroup.getDetails(self.session, a)
            groups.append(details.get('id'))

        self.client.activationkey.removeServerGroups(self.session, key, groups)

####################

    def help_activationkey_addentitlements(self):
        print 'activationkey_addentitlements: Add entitlements to an ' + \
              'activation key'
        print 'usage: activationkey_addentitlements KEY <ENTITLEMENT ...>'

    def complete_activationkey_addentitlements(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_activationkey_list('', True),
                                      text)
        elif len(parts) > 2:
            return self.tab_completer(self.ENTITLEMENTS, text)

    def do_activationkey_addentitlements(self, args):
        args = self.parse_arguments(args)

        if not len(args) >= 2:
            self.help_activationkey_addentitlements()
            return

        key = args.pop(0)
        entitlements = args

        self.client.activationkey.addEntitlements(self.session, 
                                                  key, 
                                                  entitlements)

####################

    def help_activationkey_removeentitlements(self):
        print 'activationkey_removeentitlements: Remove entitlements from an ' \
              'activation key'
        print 'usage: activationkey_removeentitlements KEY <ENTITLEMENT ...>'

    def complete_activationkey_removeentitlements(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_activationkey_list('', True), text)
        elif len(parts) > 2:
            details = \
                self.client.activationkey.getDetails(self.session, parts[1])

            entitlements = details.get('entitlements')
            return self.tab_completer(entitlements, text)

    def do_activationkey_removeentitlements(self, args):
        args = self.parse_arguments(args)

        if not len(args) >= 2:
            self.help_activationkey_removeentitlements()
            return

        key = args.pop(0)
        entitlements = args

        self.client.activationkey.removeEntitlements(self.session, 
                                                     key, 
                                                     entitlements)

####################

    def help_activationkey_addchildchannels(self):
        print 'activationkey_addchildchannels: Add child channels to an ' \
              'activation key'
        print 'usage: activationkey_addchildchannels KEY <CHANNEL ...>'

    def complete_activationkey_addchildchannels(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_activationkey_list('', True),
                                      text)
        elif len(parts) > 2:
            key_details = \
                self.client.activationkey.getDetails(self.session, parts[1])
            base_channel = key_details.get('base_channel_label')

            all_channels = \
                self.client.channel.listSoftwareChannels(self.session)

            child_channels = []
            for c in all_channels:
                if base_channel == 'none':
                    # this gets all child channels
                    if c.get('parent_label'):
                        child_channels.append(c.get('label'))
                else:
                    if c.get('parent_label') == base_channel:
                        child_channels.append(c.get('label'))

            return self.tab_completer(child_channels, text)

    def do_activationkey_addchildchannels(self, args):
        args = self.parse_arguments(args)

        if not len(args) >= 2:
            self.help_activationkey_addchildchannels()
            return

        key = args.pop(0)
        channels = args

        self.client.activationkey.addChildChannels(self.session, key, channels)

####################

    def help_activationkey_removechildchannels(self):
        print 'activationkey_removechildchannels: Remove child channels from ' \
              'an activation key'
        print 'usage: activationkey_removechildchannels KEY <CHANNEL ...>'

    def complete_activationkey_removechildchannels(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_activationkey_list('', True), text)
        elif len(parts) > 2:
            key_details = \
                self.client.activationkey.getDetails(self.session, parts[1])

            return self.tab_completer(key_details.get('child_channel_labels'), text)

    def do_activationkey_removechildchannels(self, args):
        args = self.parse_arguments(args)

        if not len(args) >= 2:
            self.help_activationkey_removechildchannels()
            return

        key = args.pop(0)
        channels = args

        self.client.activationkey.removeChildChannels(self.session, 
                                                      key, 
                                                      channels)

####################

    def help_activationkey_listchildchannels(self):
        print 'activationkey_listchildchannels: List the child channels ' + \
              'for an activation key'
        print 'usage: activationkey_listchildchannels KEY'

    def complete_activationkey_listchildchannels(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_activationkey_list('', True), text)

    def do_activationkey_listchildchannels(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_activationkey_listchildchannels()
            return

        key = args[0]

        details = self.client.activationkey.getDetails(self.session, key)

        if len(details.get('child_channel_labels')):
            print '\n'.join(details.get('child_channel_labels'))

####################

    def help_activationkey_listbasechannel(self):
        print 'activationkey_listbasechannel: List the base channels ' + \
              'for an activation key'
        print 'usage: activationkey_listbasechannel KEY'

    def complete_activationkey_listbasechannel(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_activationkey_list('', True), text)

    def do_activationkey_listbasechannel(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_activationkey_listbasechannel()
            return

        key = args[0]

        details = self.client.activationkey.getDetails(self.session, key)

        print details.get('base_channel_label')

####################

    def help_activationkey_listgroups(self):
        print 'activationkey_listgroups: List the groups for an ' + \
              'activation key'
        print 'usage: activationkey_listgroups KEY'

    def complete_activationkey_listgroups(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_activationkey_list('', True), text)

    def do_activationkey_listgroups(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_activationkey_listgroups()
            return

        key = args[0]

        details = self.client.activationkey.getDetails(self.session, key)

        for group in details.get('server_group_ids'):
            group_details = self.client.systemgroup.getDetails(self.session,
                                                               group)
            print group_details.get('name')

####################

    def help_activationkey_listentitlements(self):
        print 'activationkey_listentitlements: List the entitlements ' + \
              'for an activation key'
        print 'usage: activationkey_listentitlements KEY'

    def complete_activationkey_listentitlements(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_activationkey_list('', True), text)

    def do_activationkey_listentitlements(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_activationkey_listentitlements()
            return

        key = args[0]

        details = self.client.activationkey.getDetails(self.session, key)

        if len(details.get('entitlements')):
            print '\n'.join(details.get('entitlements'))

####################

    def help_activationkey_listpackages(self):
        print 'activationkey_listpackages: List the packages for an ' + \
              'activation key'
        print 'usage: activationkey_listpackages KEY'

    def complete_activationkey_listpackages(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_activationkey_list('', True), text)

    def do_activationkey_listpackages(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_activationkey_listpackages()
            return

        key = args[0]

        details = self.client.activationkey.getDetails(self.session, key)

        for package in details.get('packages'):
            if 'arch' in package:
                print '%s.%s' % (package['name'], package['arch'])
            else:
                print package['name']

####################

    def help_activationkey_listconfigchannels(self):
        print 'activationkey_listconfigchannels: List the configuration ' + \
              'channels for an activation key'
        print 'usage: activationkey_listconfigchannels KEY'

    def complete_activationkey_listconfigchannels(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_activationkey_list('', True), text)

    def do_activationkey_listconfigchannels(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_activationkey_listconfigchannels()
            return

        key = args[0]

        channels = \
            self.client.activationkey.listConfigChannels(self.session,
                                                         key)

        channels = sorted([ c.get('label') for c in channels])

        if len(channels):
            print '\n'.join(channels)

####################

    def help_activationkey_addconfigchannels(self):
        print 'activationkey_addconfigchannels: Add config channels ' \
              'to an activation key'
        print 'usage: activationkey_addconfigchannels KEY <CHANNEL ...>'

    def complete_activationkey_addconfigchannels(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_activationkey_list('', True), text)
        elif len(parts) > 2:
            return self.tab_completer(self.do_configchannel_list('', True), text)

    def do_activationkey_addconfigchannels(self, args):
        args = self.parse_arguments(args)

        if not len(args) >= 2:
            self.help_activationkey_addconfigchannels()
            return

        key = [ args.pop(0) ]
        channels = args

        answer = self.prompt_user('Add to top or bottom? [T/b]:')
        if re.match('b', answer, re.I):
            location = False
        else:
            location = True

        self.client.activationkey.addConfigChannels(self.session, 
                                                    key, 
                                                    channels, 
                                                    location)

####################

    def help_activationkey_removeconfigchannels(self):
        print 'activationkey_removeconfigchannels: Remove config channels ' \
              'from an activation key'
        print 'usage: activationkey_removeconfigchannels KEY <CHANNEL ...>'

    def complete_activationkey_removeconfigchannels(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_activationkey_list('', True), text)
        elif len(parts) > 2:
            key_channels = \
                self.client.activationkey.listConfigChannels(self.session, 
                                                             parts[1])

            config_channels = [c.get('label') for c in key_channels]
            return self.tab_completer(config_channels, text)

    def do_activationkey_removeconfigchannels(self, args):
        args = self.parse_arguments(args)

        if not len(args) >= 2:
            self.help_activationkey_removeconfigchannels()
            return

        key = [ args.pop(0) ]
        channels = args

        self.client.activationkey.removeConfigChannels(self.session, key, channels)

####################

    def help_activationkey_setconfigchannelorder(self):
        print 'activationkey_setconfigchannelorder: Set the ranked order of ' \
              'configuration channels'
        print 'usage: activationkey_setconfigchannelorder KEY'

    def complete_activationkey_setconfigchannelorder(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_activationkey_list('', True), text)

    def do_activationkey_setconfigchannelorder(self, args):
        args = self.parse_arguments(args)

        if len(args) != 1:
            self.help_activationkey_setconfigchannelorder()
            return

        key = args[0]

        # get the current configuration channels from the first activationkey
        # in the list
        new_channels = \
            self.client.activationkey.listConfigChannels(self.session, key)
        new_channels = [ c.get('label') for c in new_channels ]

        # call an interface for the user to make selections
        new_channels = self.config_channel_order(new_channels)

        print
        print 'New Configuration Channels:'
        for i in range(len(new_channels)):
            print '[%i] %s' % (i + 1, new_channels[i])

        if not self.user_confirm(): return        

        self.client.activationkey.setConfigChannels(self.session, 
                                                    [key], 
                                                    new_channels)

####################

    def help_activationkey_create(self):
        print 'activationkey_create: Create an activation key'
        print 'usage: activationkey_create'

    def do_activationkey_create(self, args):
        name = self.prompt_user('Name (blank to autogenerate):')
        description = self.prompt_user('Description [None]:')

        print
        print 'Base Channels:'
        for c in self.list_base_channels():
            print '  %s' % c

        base_channel = self.prompt_user('Base Channel (blank for default):')

        entitlements = []
        for e in self.ENTITLEMENTS:
            if e == 'enterprise_entitled': continue

            if self.user_confirm('%s Entitlement [y/N]:' % e):
                entitlements.append(e)

        default = self.user_confirm('Universal Default [y/N]:')

        new_key = self.client.activationkey.create(self.session,
                                                   name,
                                                   description,
                                                   base_channel,
                                                   entitlements,
                                                   default)

        print
        print 'Created activation key %s' % new_key

####################

    def help_activationkey_delete(self):
        print 'activationkey_delete: Delete an activation key'
        print 'usage: activationkey_delete KEY'

    def complete_activationkey_delete(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_activationkey_list('', True), text)

    def do_activationkey_delete(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_activationkey_delete()
            return

        key = args[0]

        if not self.user_confirm('Delete this activation key [y/N]:'): return

        self.client.activationkey.delete(self.session, key)

####################

    def help_activationkey_list(self):
        print 'activationkey_list: List all activation keys'
        print 'usage: activationkey_list'

    def do_activationkey_list(self, args, doreturn=False):
        all_keys = self.client.activationkey.listActivationKeys(self.session)

        keys = []
        for k in all_keys:
            # don't list auto-generated re-activation keys
            if not re.match('Kickstart re-activation', k.get('description')):
                keys.append(k.get('key'))

        if doreturn:
            return keys
        else:
            if len(keys):
                print '\n'.join(sorted(keys))

####################

    def help_activationkey_listsystems(self):
        print 'activationkey_listsystems: List systems registered with a key'
        print 'usage: activationkey_listsystems KEY'

    def complete_activationkey_listsystems(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_activationkey_list('', True), text)

    def do_activationkey_listsystems(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_activationkey_listsystems()
            return

        key = args[0]

        try:
            systems = \
                self.client.activationkey.listActivatedSystems(self.session,
                                                               key)
        except:
            logging.warning('%s is not a valid activation key' % key)
            logging.debug(sys.exc_info())
            return

        systems = sorted([s.get('hostname') for s in systems])

        if len(systems):
            print '\n'.join(systems)

####################

    def help_activationkey_details(self):
        print 'activationkey_details: Show the details of an activation key'
        print 'usage: activationkey_details KEY ...'

    def complete_activationkey_details(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_activationkey_list('', True), text)

    def do_activationkey_details(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_activationkey_details()
            return

        add_separator = False

        for key in args:
            try:
                details = self.client.activationkey.getDetails(self.session,
                                                               key)

                # an exception is thrown if provisioning is not enabled and we
                # attempt to get configuration channel information
                try:
                    config_channels = \
                        self.client.activationkey.listConfigChannels(self.session,
                                                                     key)

                    config_channel_deploy = \
                        self.client.activationkey.checkConfigDeployment(self.session,
                                                                        key)
                except:
                    config_channels = []
                    config_channel_deploy = 0

                # API returns 0/1 instead of boolean
                if config_channel_deploy == 1:
                    config_channel_deploy = True
                else:
                    config_channel_deploy = False
            except:
                logging.warning('%s is not a valid activation key' % key)
                logging.debug(sys.exc_info())
                return

            groups = []
            for group in details.get('server_group_ids'):
                group_details = self.client.systemgroup.getDetails(self.session,
                                                                   group)
                groups.append(group_details.get('name'))

            if add_separator: print self.SEPARATOR
            add_separator = True

            print 'Key:               %s' % details.get('key')
            print 'Description:       %s' % details.get('description')
            print 'Universal Default: %s' % \
                  str(details.get('universal_default'))

            print
            print 'Software Channels:'
            print '  %s' % details.get('base_channel_label')

            for channel in details.get('child_channel_labels'):
                print '   |-- %s' % channel

            print
            print 'Configuration Channel Deployment: %s' % \
                  str(config_channel_deploy)

            print
            print 'Configuration Channels:'

            for channel in config_channels:
                print '  %s' % channel.get('label')

            print
            print 'Entitlements:'
            for entitlement in sorted(details.get('entitlements')):
                print '  %s' % entitlement

            print
            print 'System Groups:'
            for group in groups:
                print '  %s' % group

            print
            print 'Packages:'
            for package in details.get('packages'):
                name = package.get('name')

                if package.get('arch'):
                    name += '.%s' % package.get('arch')

                print '  %s' % name

####################

    def help_activationkey_enableconfigdeployment(self):
        print 'activationkey_enableconfigdeployment: Enable config channel deployment'
        print 'usage: activationkey_enableconfigdeployment KEY'

    def complete_activationkey_enableconfigdeployment(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_activationkey_list('', True), text)

    def do_activationkey_enableconfigdeployment(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_activationkey_enableconfigdeployment()
            return

        for key in args:
            logging.info('Enabling config file deployment for %s' % key)
            self.client.activationkey.enableConfigDeployment(self.session, key)

####################

    def help_activationkey_disableconfigdeployment(self):
        print 'activationkey_disableconfigdeployment: Disable config channel deployment'
        print 'usage: activationkey_disableconfigdeployment KEY'
    
    def complete_activationkey_disableconfigdeployment(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_activationkey_list('', True), text)

    def do_activationkey_disableconfigdeployment(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_activationkey_disableconfigdeployment()
            return

        for key in args:
            logging.info('Disabling config file deployment for %s' % key)
            self.client.activationkey.disableConfigDeployment(self.session, key)

####################

    def help_activationkey_setbasechannel(self):
        print 'activationkey_setbasechannel: Set the base channel of an activation key'
        print 'usage: activationkey_setbasechannel KEY CHANNEL'

    def complete_activationkey_setbasechannel(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_activationkey_list('', True), text)
        elif len(parts) > 2:
            return self.tab_completer(self.list_base_channels(), text)

    def do_activationkey_setbasechannel(self, args):
        args = self.parse_arguments(args)

        if not len(args) >= 2:
            self.help_activationkey_setbasechannel()
            return

        key = args.pop(0)
        channel = args[0]

        current_details = self.client.activationkey.getDetails(self.session, 
                                                               key)

        details = { 'description' : current_details.get('description'),
                    'base_channel_label' : channel,
                    'usage_limit' : current_details.get('usage_limit'),
                    'universal_default' : current_details.get('universal_default') }

        self.client.activationkey.setDetails(self.session, key, details)

####################

    def help_activationkey_setuniversaldefault(self):
        print 'activationkey_setuniversaldefault: Set this key as the ' \
              'universal default'
        print 'usage: activationkey_setuniversaldefault KEY'

    def complete_activationkey_setuniversaldefault(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_activationkey_list('', True), text)

    def do_activationkey_setuniversaldefault(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_activationkey_setuniversaldefault()
            return

        key = args.pop(0)

        current_details = self.client.activationkey.getDetails(self.session, 
                                                               key)

        details = { 'description' : current_details.get('description'),
                    'base_channel_label' : current_details.get('base_channel_label'),
                    'usage_limit' : current_details.get('usage_limit'),
                    'universal_default' : True }

        self.client.activationkey.setDetails(self.session, key, details)

####################

    def help_clear(self):
        print 'clear: clear the screen'
        print 'usage: clear'

    def do_clear(self, args):
        os.system('clear')

####################

    def help_clear_caches(self):
        print 'clear_caches: Clear the internal caches kept for systems' + \
              ' and packages'
        print 'usage: clear_caches'

    def do_clear_caches(self, args):
        self.clear_system_cache()
        self.clear_package_cache()
        self.clear_errata_cache()

####################

    def help_configchannel_list(self):
        print 'configchannel_list: List all configuration channels'
        print 'usage: configchannel_list'

    def do_configchannel_list(self, args, doreturn=False):
        channels = self.client.configchannel.listGlobals(self.session)
        channels = [c.get('label') for c in channels]

        if doreturn:
            return channels
        else:
            if len(channels):
                print '\n'.join(sorted(channels))

####################

    def help_configchannel_listsystems(self):
        print 'configchannel_listsystems: List the systems subscribed to a'
        print '                           configuration channel'
        print 'usage: configchannel_listsystems CHANNEL'

    def complete_configchannel_listsystems(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_configchannel_list('', True), text)

    def do_configchannel_listsystems(self, args):
        #XXX: Bugzilla 584852
        print 'configchannel.listSubscribedSystems is not implemented'
        return

        args = self.parse_arguments(args)

        if not len(args):
            self.help_configchannel_listsystems()
            return

        systems = \
            self.client.configchannel.listSubscribedSystems(self.session,
                                                            args[0])

        systems = sorted([s.get('name') for s in systems])

        if len(systems):
            print '\n'.join(systems)

####################

    def help_configchannel_listfiles(self):
        print 'configchannel_listfiles: List the files in a config channel'
        print 'usage: configchannel_listfiles CHANNEL ...'

    def complete_configchannel_listfiles(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_configchannel_list('', True), text)

    def do_configchannel_listfiles(self, args, doreturn=False):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_configchannel_listfiles()
            return []

        for channel in args:
            files = self.client.configchannel.listFiles(self.session,
                                                        channel)
            files = [f.get('path') for f in files]

            if doreturn:
                return files
            else:
                if len(files):
                    print '\n'.join(sorted(files))

####################

    def help_configchannel_filedetails(self):
        print 'help_configchannel_filedetails: Show the details of a file'
        print '                                in a configuration channel'
        print 'usage: configchannel_filedetails CHANNEL <FILE ...>'

    def complete_configchannel_filedetails(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_configchannel_list('', True),
                                      text)
        elif len(parts) > 2:
            return self.tab_completer(\
                self.do_configchannel_listfiles(parts[1], True), text)
        else:
            return []

    def do_configchannel_filedetails(self, args):
        args = self.parse_arguments(args)

        if len(args) < 2:
            self.help_configchannel_filedetails()
            return

        add_separator = False

        channel = args[0]
        filenames = args[1:]

        # the server return a null exception if an invalid file is passed
        valid_files = self.do_configchannel_listfiles(channel, True)
        for f in filenames:
            if not f in valid_files:
                filenames.remove(f)
                logging.warning('%s is not in this configuration channel' % f)
                continue

        files = self.client.configchannel.lookupFileInfo(self.session,
                                                         channel,
                                                         filenames)

        for file in files:
            if add_separator: print self.SEPARATOR
            add_separator = True

            print 'File:     %s' % file.get('path')
            print 'Type:     %s' % file.get('type')
            print 'Revision: %s' % str(file.get('revision'))
            print 'Created:  %s' % self.format_time(file.get('creation').value)
            print 'Modified: %s' % self.format_time(file.get('modified').value)

            print
            print 'Owner:    %s' % file.get('owner')
            print 'Group:    %s' % file.get('group')
            print 'Mode:     %s' % file.get('permissions_mode')

            if file.get('type') == 'file':
                print 'MD5:      %s' % file.get('md5')
                print 'Binary:   %s' % str(file.get('binary'))

                if not file.get('binary'):
                    print
                    print 'Contents:'
                    print file.get('contents')

####################

    def help_configchannel_details(self):
        print 'configchannel_details: Show the details of a config channel'
        print 'usage: configchannel_details CHANNEL ...'

    def complete_configchannel_details(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_configchannel_list('', True), text)

    def do_configchannel_details(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_configchannel_details()
            return

        add_separator = False

        for channel in args:
            details = self.client.configchannel.getDetails(self.session,
                                                           channel)

            files = self.client.configchannel.listFiles(self.session,
                                                        channel)

            if add_separator: print self.SEPARATOR
            add_separator = True

            print 'Label:       %s' % details.get('label')
            print 'Name:        %s' % details.get('name')
            print 'Description: %s' % details.get('description')

            print
            print 'Files:'
            for file in files:
                print '  %s' % file.get('path')

####################

    def help_configchannel_create(self):
        print 'configchannel_create: Create a configuration channel'
        print 'usage: configchannel_create [NAME] [DESCRIPTION]'

    def do_configchannel_create(self, args):
        args = self.parse_arguments(args)

        if len(args) > 0:
            name = args[0]
        else:
            name = ''

        while name == '':
            name = self.prompt_user('Name:')

        if len(args) > 1:
            description = ' '.join(args[1:])
        else:
            description = self.prompt_user('Description:')

        if description == '':
            description = name

        self.client.configchannel.create(self.session,
                                         name,
                                         name,
                                         description)

####################

    def help_configchannel_delete(self):
        print 'configchannel_delete: Delete a configuration channel'
        print 'usage: configchannel_delete CHANNEL ...'

    def complete_configchannel_delete(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_configchannel_list('', True), text)

    def do_configchannel_delete(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_configchannel_delete()
            return

        channels = args

        if self.user_confirm('Delete these channels [y/N]:'):
            self.client.configchannel.deleteChannels(self.session, channels)

####################

    def help_configchannel_addfile(self):
        print 'configchannel_addfile: Create a configuration file'
        print 'usage: configchannel_addfile CHANNEL'

    def complete_configchannel_addfile(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_configchannel_list('', True), text)

    def do_configchannel_addfile(self, args, path=''):
        args = self.parse_arguments(args)

        if len(args) != 1:
            self.help_configchannel_addfile()
            return

        channel = args[0]
       
        while path == '':
            path = self.prompt_user('Path:')
        
        input = self.prompt_user('Directory [y/N]:')
        if re.match('y', input, re.I):
            directory = True
        else:
            directory = False

        owner = self.prompt_user('Owner [root]:')
        group = self.prompt_user('Group [root]:')
        mode  = self.prompt_user('Permissions [644]:')
        
        # defaults
        if not owner: owner = 'root'
        if not group: group = 'root'
        if not mode:  mode  = '644'
        contents = ''
        binary = False

        if not directory:
            type = 'text'

            #XXX: Bugzilla 606982
            # Satellite doesn't pick up on the base64 encoded string
            #type = self.prompt_user('Text or binary [T/b]:')
            
            if re.match('b', type, re.I):
                binary = True

                contents = ''
                while contents == '':
                    file = self.prompt_user('File:')

                    try:
                        handle = open(file, 'rb')
                        contents = handle.read().encode('base64')
                        handle.close()
                    except:
                        contents = ''
                        logging.debug(sys.exc_info())
                        logging.warning('Could not read %s' % file)
            else:
                binary = False

                template = ''
                try:
                    channel_files = \
                        self.client.configchannel.listFiles(self.session, 
                                                            channel)

                    for f in channel_files:
                        if path == f.get('path'):
                            file_details = \
                                self.client.configchannel.lookupFileInfo( \
                                                                  self.session,
                                                                  channel,
                                                                  [ path ])

                            template = file_details[0].get('contents')
                            break
                except:
                    logging.warning('Could not retrieve existing contents')

                contents = self.editor(template = template, delete = True)

        file_info = { 'contents'    : ''.join(contents),
                      'owner'       : owner,
                      'group'       : group,
                      'permissions' : mode }

        print 'File:        %s' % path
        print 'Directory:   %s' % directory
        print 'Owner:       %s' % file_info['owner']
        print 'Group:       %s' % file_info['group']
        print 'Mode:        %s' % file_info['permissions']

        if not directory:
            if binary:
                print 'Binary File: %s' % binary
            else:
                print
                print 'Contents:'
                print file_info['contents']

        if self.user_confirm():
            self.client.configchannel.createOrUpdatePath(self.session,
                                                         channel,
                                                         path,
                                                         directory,
                                                         file_info)

####################

    def help_configchannel_updatefile(self):
        print 'configchannel_updatefile: Update a configuration file'
        print 'usage: configchannel_updatefile CHANNEL FILE'

    def complete_configchannel_updatefile(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_configchannel_list('', True), 
                                      text)
        elif len(parts) > 2:
            channel = parts[1]
            return self.tab_completer(self.do_configchannel_listfiles(channel,
                                                                      True), 
                                      text)

    def do_configchannel_updatefile(self, args):
        args = self.parse_arguments(args)
        
        if len(args) != 2:
            self.help_configchannel_updatefile()
            return

        return self.do_configchannel_addfile(args[0], path=args[1])

####################

    def help_configchannel_removefiles(self):
        print 'configchannel_removefile: Remove configuration files'
        print 'usage: configchannel_removefile CHANNEL <FILE ...>'

    def complete_configchannel_removefiles(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_configchannel_list('', True), 
                                      text)
        elif len(parts) > 2:
            channel = parts[1]
            return self.tab_completer(self.do_configchannel_listfiles(channel,
                                                                      True), 
                                      text)

    def do_configchannel_removefiles(self, args):
        args = self.parse_arguments(args)
        
        if len(args) < 2:
            self.help_configchannel_removefiles()
            return

        channel = args.pop(0)
        files = args

        if self.user_confirm('Remove these files [y/N]:'):
            self.client.configchannel.deleteFiles(self.session, channel, files)

####################

    def help_cryptokey_create(self):
        print 'cryptokey_create: Create a cryptographic key'
        print 'usage: cryptokey_create'

    def do_cryptokey_create(self, args):
        key_type = ''
        while not re.match('GPG|SSL', key_type):
            key_type = self.prompt_user('GPG or SSL [G/S]:')
           
            if re.match('G', key_type, re.I):
                key_type = 'GPG'
            elif re.match('S', key_type, re.I):
                key_type = 'SSL'
            else:
                logging.warning('Invalid key type')
                key_type = '' 

        description = ''
        while description == '':
            description = self.prompt_user('Description:')

        content = self.editor(delete=True)

        self.client.kickstart.keys.create(self.session,
                                          description,
                                          key_type,
                                          content)

####################

    def help_cryptokey_delete(self):
        print 'cryptokey_delete: Delete a cryptographic key'
        print 'usage: cryptokey_delete NAME'

    def complete_cryptokey_delete(self, text, line, begidx, endidx):
        if len(line.split(' ')) <= 2:
            return self.tab_completer(self.do_cryptokey_list('', True), 
                                      text)

    def do_cryptokey_delete(self, args):
        args = self.parse_arguments(args)

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

    def complete_cryptokey_details(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_cryptokey_list('', True), text)

    def do_cryptokey_details(self, args):
        args = self.parse_arguments(args)

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
                logging.debug(sys.exc_info())
                return

            if add_separator: print self.SEPARATOR
            add_separator = True

            print 'Description: %s' % details.get('description')
            print 'Type:        %s' % details.get('type')

            print
            print details.get('content')

####################

    def help_custominfo_createkey(self):
        print 'custominfo_createkey: Create a custom key'
        print 'usage: custominfo_createkey [NAME] [DESCRIPTION]'

    def do_custominfo_createkey(self, args):
        args = self.parse_arguments(args)

        if len(args) > 0:
            key = args[0]
        else:
            key = ''

        while key == '':
            key = self.prompt_user('Name:')

        if len(args) > 1:
            description = ' '.join(args[1:])
        else:
            description = self.prompt_user('Description:')
            if description == '':
                description = key

        self.client.system.custominfo.createKey(self.session,
                                                key,
                                                description)

####################

    def help_custominfo_deletekey(self):
        print 'custominfo_deletekey: Delete a custom key'
        print 'usage: custominfo_deletekey KEY ...'

    def complete_custominfo_deletekey(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_custominfo_listkeys('', True), text)

    def do_custominfo_deletekey(self, args):
        args = self.parse_arguments(args)

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

    def complete_custominfo_details(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_custominfo_listkeys('', True), text)

    def do_custominfo_details(self, args):
        args = self.parse_arguments(args)

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
            print 'Modified:     %s' % self.format_time(details.get('last_modified').value)
            print 'System Count: %i' % details.get('system_count')

####################

    def help_distribution_create(self):
        print 'distribution_create: Create a Kickstart tree'
        print 'usage: distribution_create'

    def do_distribution_create(self, args):
        name = self.prompt_user('Label:')

        base_path = self.prompt_user('Path to Kickstart Tree:')

        base_channel = ''
        while base_channel == '':
            print
            print 'Base Channels:'
            for c in self.list_base_channels():
                print '  %s' % c

            base_channel = self.prompt_user('Base Channel:')

            if base_channel not in self.list_base_channels():
                logging.warning('Invalid channel label')
                base_channel = ''

        install_types = \
            self.client.kickstart.tree.listInstallTypes(self.session)
       
        install_types = [ t.get('label') for t in install_types ]
 
        install_type = ''
        while install_type == '':
            print
            print 'Install Types:'
            for t in install_types:
                print '  %s' % t

            install_type = self.prompt_user('Install Type:')
    
            if install_type not in install_types:
                logging.warning('Invalid install type')
                install_type = '' 

        self.client.kickstart.tree.create(self.session,
                                          name,
                                          base_path,
                                          base_channel,
                                          install_type)

####################

    def help_distribution_list(self):
        print 'distribution_list: List the available Kickstart trees'
        print 'usage: distribution_list'

    def do_distribution_list(self, args, doreturn=False):
        channels = self.client.kickstart.listKickstartableChannels(self.session)

        avail_trees = []
        for c in channels:
            trees = self.client.kickstart.tree.list(self.session,
                                                    c.get('label'))

            for t in trees:
                label = t.get('label')
                if label not in avail_trees:
                    avail_trees.append(label)

        if doreturn:
            return avail_trees
        else:
            if len(avail_trees):
                print '\n'.join(sorted(avail_trees))

####################

    def help_distribution_delete(self):
        print 'distribution_delete: Delete a Kickstart tree'
        print 'usage: distribution_delete LABEL'

    def complete_distribution_delete(self, text, line, begidx, endidx):
        if len(line.split(' ')) <= 2:
            return self.tab_completer(self.do_distribution_list('', True), 
                                      text)

    def do_distribution_delete(self, args):
        args = self.parse_arguments(args)

        if len(args) != 1:
            self.help_distribution_delete()
            return

        label = args[0]

        if self.user_confirm('Delete this tree [y/N]:'):
            self.client.kickstart.tree.delete(self.session, label)

####################

    def help_distribution_rename(self):
        print 'distribution_rename: Rename a Kickstart tree'
        print 'usage: distribution_rename OLDNAME NEWNAME'

    def complete_distribution_rename(self, text, line, begidx, endidx):
        if len(line.split(' ')) <= 2:
            return self.tab_completer(self.do_distribution_list('', True), 
                                      text)

    def do_distribution_rename(self, args):
        args = self.parse_arguments(args)

        if len(args) != 2:
            self.help_distribution_rename()
            return

        oldname = args[0]
        newname = args[1]

        self.client.kickstart.tree.rename(self.session, oldname, newname)

####################

    def help_distribution_update(self):
        print 'distribution_update: Update the path of a Kickstart tree'
        print 'usage: distribution_update LABEL'
    
    def complete_distribution_update(self, text, line, begidx, endidx):
        if len(line.split(' ')) <= 2:
            return self.tab_completer(self.do_distribution_list('', True), 
                                      text)

    def do_distribution_update(self, args):
        args = self.parse_arguments(args)

        if len(args) != 1:
            self.help_distribution_update()
            return

        label = args[0]

        base_path = self.prompt_user('Path to Kickstart Tree:')

        base_channel = ''
        while base_channel == '':
            print
            print 'Base Channels:'
            for c in self.list_base_channels():
                print '  %s' % c

            base_channel = self.prompt_user('Base Channel:')

            if base_channel not in self.list_base_channels():
                logging.warning('Invalid channel label')
                base_channel = ''

        install_types = \
            self.client.kickstart.tree.listInstallTypes(self.session)
       
        install_types = [ t.get('label') for t in install_types ]
 
        install_type = ''
        while install_type == '':
            print
            print 'Install Types:'
            for t in install_types:
                print '  %s' % t

            install_type = self.prompt_user('Install Type:')
    
            if install_type not in install_types:
                logging.warning('Invalid install type')
                install_type = '' 

        self.client.kickstart.tree.update(self.session,
                                          label,
                                          base_path,
                                          base_channel,
                                          install_type)

####################

    def help_errata_list(self):
        print 'errata_list: List all errata' 
        print 'usage: errata_list'

    def do_errata_list(self, args, doreturn=False):
        self.generate_errata_cache()

        if doreturn:
            return self.all_errata.keys()
        else:
            if len(self.all_errata.keys()):
                print '\n'.join(sorted(self.all_errata.keys()))

####################

    def help_errata_apply(self):
        print 'errata_apply: Apply an errata to all affected systems' 
        print 'usage: errata_apply ERRATA|search:XXX ...'

    def complete_errata_apply(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_errata_list('', True), text)

    def do_errata_apply(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_errata_apply()
            return

        errata_list = []
        for a in args:
            if re.match('search:', a):
                a = re.sub('search:', '', a)
                errata_list.extend(self.do_errata_search(a, True))
            else:
                errata_list.append(a)

        self.generate_errata_cache()
        errata_list = self.filter_results(self.all_errata, errata_list)

        if not len(errata_list):
            logging.warning('No errata found')
            return

        errata_to_remove = []    

        add_separator = False

        for errata in sorted(errata_list, reverse = True):
            try:
                systems = self.client.errata.listAffectedSystems(self.session, 
                                                                 errata)
            except:
                systems = []
            
            if len(systems):
                if add_separator: print self.SEPARATOR
                add_separator = True

                print '%s:' % errata
                for system in sorted([s.get('name') for s in systems]):
                    print system
            else:
                logging.debug('%s does not affect any systems' % errata)
                errata_to_remove.append(errata)

        # remove errata that didn't have any affected systems
        for errata in errata_to_remove:
            errata_list.remove(errata)
           
        if len(errata_list): 
            if not self.user_confirm('Apply these errata [y/N]:'): return
        else:
            logging.warning('No errata found')
            return

        for errata in errata_list: 
            systems = self.client.errata.listAffectedSystems(self.session, 
                                                             errata)
            
            # XXX: bugzilla 600691
            # there is not an API call to get the ID of an errata
            # based on the name, so we do it in a round-about way
            avail = self.client.system.getRelevantErrata(self.session,
                                                         systems[0].get('id'))

            for e in avail:
                if re.match(errata, e.get('advisory_name'), re.I):
                    errata_id = e.get('id')
                    break

            if not errata_id:
                logging.critical("Couldn't find ID for %s" % errata)
                return

            for system in systems:
                try:
                    self.client.system.scheduleApplyErrata(self.session,
                                                           system.get('id'),
                                                           [errata_id])
                except:
                    logging.warning('Failed to schedule %s' % \
                                    system.get('name'))
 
####################

    def help_errata_listaffectedsystems(self):
        print 'errata_listaffectedsystems: List of systems affected by this' + \
              ' errata'
        print 'usage: errata_listaffectedsystems ERRATA'

    def complete_errata_listaffectedsystems(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_errata_list('', True), text)

    def do_errata_listaffectedsystems(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_errata_listaffectedsystems()
            return

        add_separator = False

        query = args[0]

        if add_separator: print self.SEPARATOR
        add_separator = True

        errata_names = []
        try:
            results = self.client.errata.getDetails(self.session, query)
        except:
            logging.warning('No errata found')
            return

        errata_names.append(query)

        systems = []
        for name in sorted(errata_names):
            results = self.client.errata.listAffectedSystems(self.session, 
                                                             name)

            for r in results:
                if r.get('name') not in systems:
                    systems.append(r.get('name'))

        if len(systems):
            for system in sorted(systems):
                print '  %s' % system
        
####################

    def help_errata_details(self):
        print 'errata_details: Show the details of an errata'
        print 'usage: errata_details NAME ...'
    
    def complete_errata_details(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_errata_list('', True), text)

    def do_errata_details(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_errata_details()
            return

        name = args[0]

        add_separator = False

        for errata in args:
            try:
                details = self.client.errata.getDetails(self.session, name)

                packages = self.client.errata.listPackages(self.session, name)

                channels = \
                    self.client.errata.applicableToChannels(self.session, name)
            except:
                logging.warning('%s is not a valid errata' % name)
                logging.debug(sys.exc_info())
                continue

            if add_separator: print self.SEPARATOR
            add_separator = True

            print 'Name:       %s' % name
            print
            print 'Product:    %s' % details.get('product')
            print 'Type:       %s' % details.get('type')
            print 'Issue Date: %s' % details.get('issue_date')
            print
            print 'Topic: '
            print '\n'.join(wrap(details.get('topic')))
            print
            print 'Description: '
            print '\n'.join(wrap(details.get('description')))

            if details.get('notes'):
                print
                print 'Notes:'
                print '\n'.join(wrap(details.get('notes')))

            print
            print 'Solution:'
            print '\n'.join(wrap(details.get('solution')))
            print
            print 'References:'
            print '\n'.join(wrap(details.get('references')))
            print
            print 'Affected Channels:'
            print '\n'.join(sorted([c.get('label') for c in channels]))
            print
            print 'Affected Packages:'
            print '\n'.join(sorted(self.build_package_names(packages)))


####################

    def help_errata_search(self):
        print 'errata_search: List errata that meet the given criteria'
        print 'usage: errata_search CVE|RHSA|RHBA|RHEA|CLA ...'
        print
        print 'Example:'
        print '> errata_search CVE-2009:1674'
        print '> errata_search RHSA-2009:1674'

    def complete_errata_search(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_errata_list('', True), text)

    def do_errata_search(self, args, doreturn=False):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_errata_search()
            return

        add_separator = False

        for query in args:
            errata = []

            #XXX: Bugzilla 584855
            if re.match('CVE', query, re.I):
                errata = self.client.errata.findByCve(self.session, 
                                                      query.upper())
            else:
                self.generate_errata_cache()

                for name in self.all_errata.keys():
                    if re.search(query, name, re.I) or \
                       re.search(query, 
                                 self.all_errata[name]['synopsis'], re.I):
                        match = self.all_errata[name]

                        # build a structure to pass to print_errata_summary()
                        errata.append( {'advisory_name'     : name,
                                        'advisory_type'     : match['type'],
                                        'advisory_synopsis' : match['synopsis'],
                                        'date'              : match['date'] } )

            if add_separator: print self.SEPARATOR
            add_separator = True

            if len(errata):
                if doreturn:
                    return [ e['advisory_name'] for e in errata ]
                else:
                    map(self.print_errata_summary, sorted(errata, reverse=True))
            else:
                return []

####################

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
        args = self.parse_arguments(args)

        if len(args):
            name = args[0]
        else:
            name = self.prompt_user('Name:', noblank=True)

        if len(args) > 1:
            files = args[1:]
        else:
            files = []

            while True:
                print 'File List:'
                print '\n'.join(sorted(files))
                print

                input = self.prompt_user('File [blank to finish]:')

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

    def complete_filepreservation_delete(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_filepreservation_list('', True), text)

    def do_filepreservation_delete(self, args):
        args = self.parse_arguments(args)

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

    def complete_filepreservation_details(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_filepreservation_list('', True), text)

    def do_filepreservation_details(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_filepreservation_details()
            return

        name = args[0]

        details = \
            self.client.kickstart.filepreservation.getDetails(self.session, 
                                                              name)

        print '\n'.join(sorted(details.get('file_names')))        

####################

    def help_get_apiversion(self):
        print 'get_apiversion: Display the API version of the server'
        print 'usage: get_apiversion'


    def do_get_apiversion(self, args):
        print self.client.api.getVersion()

####################

    def help_get_serverversion(self):
        print 'get_serverversion: Display the version of the server'
        print 'usage: get_serverversion'

    def do_get_serverversion(self, args):
        print self.client.api.systemVersion()

####################

    def help_get_certificateexpiration(self):
        print 'get_certificateexpiration: Print the expiration date of the'
        print "                           server's entitlement certificate"
        print 'usage: get_certificateexpiration'

    def do_get_certificateexpiration(self, args):
        date = self.client.satellite.getCertificateExpirationDate(self.session)
        print date.value

####################

    def help_get_entitlements(self):
        print 'get_entitlements: Show the current entitlement usage'
        print 'usage: get_entitlements'

    def do_get_entitlements(self, args):
        entitlements = self.client.satellite.listEntitlements(self.session)

        print 'System:'
        for e in entitlements.get('system'):
            print '%s: %s/%s' % (
                  e.get('label'),
                  str(e.get('used_slots')),
                  str(e.get('total_slots')))

        print
        print 'Channel:'
        for e in entitlements.get('channel'):
            print '%s: %s/%s' % (
                  e.get('label'),
                  str(e.get('used_slots')),
                  str(e.get('total_slots')))

####################

    def help_group_addsystems(self):
        print 'group_addsystems: Add systems to a group'
        print 'usage: group_addsystems GROUP <SYSTEMS>'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_group_addsystems(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_group_list('', True), text)
        elif len(parts) > 2:
            return self.tab_complete_systems(parts[1])

    def do_group_addsystems(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_group_addsystems()
            return

        group_name = args.pop(0)

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)

        system_ids = []
        for system in sorted(systems):
            system_id = self.get_system_id(system)
            if not system_id: return
            system_ids.append(system_id)

        self.client.systemgroup.addOrRemoveSystems(self.session,
                                                   group_name,
                                                   system_ids,
                                                   True)

####################

    def help_group_removesystems(self):
        print 'group_removesystems: Remove systems from a group'
        print 'usage: group_removesystems GROUP <SYSTEMS>'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_group_removesystems(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_group_list('', True), text)
        elif len(parts) > 2:
            return self.tab_complete_systems(parts[1])

    def do_group_removesystems(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_group_removesystems()
            return

        group_name = args.pop(0)

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)

        system_ids = []
        for system in sorted(systems):
            system_id = self.get_system_id(system)
            if not system_id: return
            system_ids.append(system_id)

        print 'Systems:'
        print '\n'.join(sorted(systems))

        if not self.user_confirm('Remove these systems [y/N]:'): return

        self.client.systemgroup.addOrRemoveSystems(self.session,
                                                   group_name,
                                                   system_ids,
                                                   False)

####################

    def help_group_create(self):
        print 'group_create: Create a system group'
        print 'usage: group_create [NAME] [DESCRIPTION]'

    def do_group_create(self, args):
        args = self.parse_arguments(args)

        if len(args) > 0:
            name = args[0]
        else:
            name = self.prompt_user('Name:')

        if len(args) > 1:
            description = ' '.join(args[1:])
        else:
            description = self.prompt_user('Description:')

        group = self.client.systemgroup.create(self.session, name, description)

####################

    def help_group_delete(self):
        print 'group_delete: Delete a system group'
        print 'usage: group_delete NAME ...'

    def complete_group_delete(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_group_list('', True), text)

    def do_group_delete(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_group_delete()
            return

        groups = args

        self.do_group_details('', True)
        if not self.user_confirm('Delete these groups [y/N]:'): return

        for group in groups:
            self.client.systemgroup.delete(self.session, group)

####################

    def help_group_list(self):
        print 'group_list: List available system groups'
        print 'usage: group_list'

    def do_group_list(self, args, doreturn=False):
        groups = self.client.systemgroup.listAllGroups(self.session)
        groups = [g.get('name') for g in groups]

        if doreturn:
            return groups
        else:
            if len(groups):
                print '\n'.join(sorted(groups))

####################

    def help_group_listsystems(self):
        print 'group_listsystems: List the members of a group'
        print 'usage: group_listsystems GROUP'

    def complete_group_listsystems(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_group_list('', True), text)

    def do_group_listsystems(self, args, doreturn=False):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_group_listsystems()
            return

        group = args[0]

        try:
            systems = self.client.systemgroup.listSystems(self.session,
                                                          group)

            systems = [s.get('profile_name') for s in systems]
        except:
            logging.warning('%s is not a valid group' % group)
            logging.debug(sys.exc_info())
            return []

        if doreturn:
            return systems
        else:
            if len(systems):
                print '\n'.join(sorted(systems))

####################

    def help_group_details(self):
        print 'group_details: Show the details of a system group'
        print 'usage: group_details GROUP ...'

    def complete_group_details(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_group_list('', True), text)

    def do_group_details(self, args, short=False):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_group_details()
            return

        add_separator = False

        for group in args:
            try:
                details = self.client.systemgroup.getDetails(self.session,
                                                             group)

                systems = self.client.systemgroup.listSystems(self.session,
                                                              group)

                systems = [s.get('profile_name') for s in systems]
            except:
                logging.warning('%s is not a valid group' % key)
                logging.debug(sys.exc_info())
                return

            if add_separator: print self.SEPARATOR
            add_separator = True

            print 'Name               %s' % details.get('name')
            print 'Description:       %s' % details.get('description')
            print 'Number of Systems: %s' % str(details.get('system_count'))

            if not short:
                print
                print 'Members:'
                for s in sorted(systems):
                    print '  %s' % s

####################

    def help_help(self):
        print 'help: Show help for the given command'
        print 'usage: help COMMAND'

####################

    def help_history(self):
        print 'history: List your command history'
        print 'usage: history'

    def do_history(self, args):
        for i in range(1, readline.get_current_history_length()):
            print '%s  %s' % (str(i).rjust(4), readline.get_history_item(i))

####################

    def help_kickstart_list(self):
        print 'kickstart_list: List the available Kickstart profiles'
        print 'usage: kickstart_list'

    def do_kickstart_list(self, args, doreturn=False):
        kickstarts = self.client.kickstart.listKickstarts(self.session)
        kickstarts = [k.get('name') for k in kickstarts]

        if doreturn:
            return kickstarts
        else:
            if len(kickstarts):
                print '\n'.join(sorted(kickstarts))

####################

    def help_kickstart_delete(self):
        print 'kickstart_delete: Delete a Kickstart profile'
        print 'usage: kickstart_delete PROFILE'

    def complete_kickstart_delete(self, text, line, begidx, endidx):
        if len(line.split(' ')) <= 2:
            return self.tab_completer(self.do_kickstart_list('', True), text)

    def do_kickstart_delete(self, args):
        args = self.parse_arguments(args)

        if len(args) != 1:
            self.help_kickstart_delete()
            return

        label = args[0]

        if self.user_confirm('Delete this profile [y/N]:'):
            self.client.kickstart.deleteProfile(self.session, label)

####################

    def help_kickstart_details(self):
        print 'kickstart_details: Show the details of a Kickstart profile'
        print 'usage: kickstart_details PROFILE'

    def complete_kickstart_details(self, text, line, begidx, endidx):
        if len(line.split(' ')) <= 2:
            return self.tab_completer(self.do_kickstart_list('', True), text)

    def do_kickstart_details(self, args):
        args = self.parse_arguments(args)

        if len(args) != 1:
            self.help_kickstart_details()
            return

        label = args[0]
        kickstart = None

        profiles = self.client.kickstart.listKickstarts(self.session)
        for p in profiles:
            if p.get('label') == label:
                kickstart = p
                break

        if not kickstart:
            logging.warning('Invalid Kickstart profile')
            return

        act_keys = \
            self.client.kickstart.profile.keys.getActivationKeys(self.session,
                                                                 label)

        variables = self.client.kickstart.profile.getVariables(self.session,
                                                               label)

        tree = \
            self.client.kickstart.tree.getDetails(self.session,
                                                  kickstart.get('tree_label'))

        base_channel = \
            self.client.channel.software.getDetails(self.session,
                                                    tree.get('channel_id'))

        child_channels = \
            self.client.kickstart.profile.getChildChannels(self.session,
                                                           label)

        custom_options = \
            self.client.kickstart.profile.getCustomOptions(self.session,
                                                           label)

        advanced_options = \
            self.client.kickstart.profile.getAdvancedOptions(self.session,
                                                             label)

        config_manage = \
            self.client.kickstart.profile.system.checkConfigManagement(\
                self.session, label)

        remote_commands = \
            self.client.kickstart.profile.system.checkRemoteCommands(\
                self.session, label)

        #XXX: Bugzilla 584860
        partitions = \
            self.client.kickstart.profile.system.getPartitioningScheme(\
                self.session, label)

        crypto_keys = \
            self.client.kickstart.profile.system.listKeys(self.session,
                                                          label)

        file_preservations = \
            self.client.kickstart.profile.system.listFilePreservations(\
                self.session, label)

        software = self.client.kickstart.profile.software.getSoftwareList(\
                self.session, label)

        scripts = self.client.kickstart.profile.listScripts(self.session,
                                                            label)

        print 'Name:        %s' % kickstart.get('name')
        print 'Label:       %s' % kickstart.get('label')
        print 'Tree:        %s' % kickstart.get('tree_label')
        print 'Active:      %s' % str(kickstart.get('active'))
        print 'Advanced:    %s' % str(kickstart.get('advanced_mode'))
        print 'Org Default: %s' % str(kickstart.get('org_default'))

        print
        print 'Config Management: %s' % str(config_manage)
        print 'Remote Commands:   %s' % str(remote_commands)

        print
        print 'Software Channels:'
        print '  %s' % base_channel.get('label')

        for channel in sorted(child_channels):
            print '    |-- %s' % channel

        if len(advanced_options):
            print
            print 'Advanced Options:'
            for o in sorted(advanced_options, key=itemgetter('name')):
                if o.get('arguments'):
                    print '  %s %s' % (o.get('name'), o.get('arguments'))

        if len(custom_options):
            print
            print 'Custom Options:'
            for o in sorted(custom_options, key=itemgetter('arguments')):
                print '  %s' % re.sub('\n', '', o.get('arguments'))

        if len(partitions):
            print
            print 'Partitioning:'
            for line in partitions:
                print '  %s' % line

        print
        print 'Software:'
        for s in software:
            print '  %s' % s

        if len(act_keys):
            print
            print 'Activation Keys:'
            for k in sorted(act_keys, key=itemgetter('key')):
                print '  %s' % k.get('key')

        if len(crypto_keys):
            print
            print 'Crypto Keys:'
            for k in sorted(crypto_keys, key=itemgetter('description')):
                print '  %s' % k.get('description')

        if len(file_preservations):
            print
            print 'File Preservations:'
            for fp in sorted(file_preservations, key=itemgetter('name')):
                print '  %s' % fp.get('name')
                for file in sorted(fp.get('file_names')):
                    print '    |-- %s' % file

        if len(variables):
            print
            print 'Variables:'
            for k in sorted(variables.keys()):
                print '  %s=%s' %(k, str(variables[k]))

        if len(scripts):
            print
            print 'Scripts:'

            add_separator = False

            for s in scripts:
                if add_separator: print self.SEPARATOR
                add_separator = True

                print '  Type:        %s' % s.get('script_type')
                print '  Chroot:      %s' % str(s.get('chroot'))

                if s.get('interpreter'):
                    print '  Interpreter: %s' % s.get('interpreter')

                print
                print s.get('contents')

####################

    def help_kickstart_getfile(self):
        print 'kickstart_getfile: Show the contents of a Kickstart profile'
        print '                   as they would be presented to a client'
        print 'usage: kickstart_getfile LABEL'

    def complete_kickstart_getfile(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_kickstart_list('', True), text)

    def do_kickstart_getfile(self, args, doreturn=False):
        args = self.parse_arguments(args)

        url = 'http://%s/ks/cfg/label/%s' %(self.server, args[0])

        try:
            if re.match('localhost', self.server, re.I):
                for p in ['http_proxy', 'HTTP_PROXY']:
                    if len(os.environ[p]):
                        logging.debug('Disabling HTTP proxy')
                        os.environ[p] = ''

            logging.debug('Retrieving %s' % url)
            response = urllib2.urlopen(url)
            kickstart = response.read()
        except urllib2.HTTPError:
            logging.error(sys.exc_info()[1])
            logging.error('Could not retrieve the Kickstart file')
            return

        # XXX: Bugzilla 584864
        # the value returned here is uninterpreted by Cobbler
        # which makes it useless
        #kickstart = \
        #    self.client.kickstart.profile.downloadKickstart(self.session,
        #                                                    args[0],
        #                                                    self.server)

        print kickstart

####################

    def help_kickstart_rename(self):
        print 'kickstart_rename: Rename a Kickstart profile'
        print 'usage: kickstart_rename OLDNAME NEWNAME'

    def complete_kickstart_rename(self, text, line, begidx, endidx):
        if len(line.split(' ')) <= 2:
            return self.tab_completer(self.do_kickstart_list('', True), text)

    def do_kickstart_rename(self, args):
        args = self.parse_arguments(args)

        if len(args) != 2:
            self.help_kickstart_rename()
            return

        oldname = args[0]
        newname = args[1]

        self.client.kickstart.renameProfile(self.session, oldname, newname)

####################

    def help_kickstart_listcryptokeys(self):
        print 'kickstart_listcryptokeys: List the crypto keys associated ' + \
              'with a Kickstart profile'
        print 'usage: kickstart_listcryptokeys PROFILE'
    
    def complete_kickstart_listcryptokeys(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_kickstart_list('', True), text)

    def do_kickstart_listcryptokeys(self, args, doreturn=False):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_kickstart_listcryptokeys()
            return

        profile = args[0]

        keys = self.client.kickstart.profile.system.listKeys(self.session,
                                                             profile)
        keys = [ k.get('description') for k in keys ]

        if doreturn:
            return keys
        else:
            if len(keys):
                print '\n'.join(sorted(keys))

####################

    def help_kickstart_addcryptokeys(self):
        print 'kickstart_addcryptokeys: Add crypto keys to a Kickstart profile'
        print 'usage: kickstart_addcryptokeys PROFILE <KEY ...>'

    def complete_kickstart_addcryptokeys(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_kickstart_list('', True), text)
        elif len(parts) > 2:
            return self.tab_completer(self.do_cryptokey_list('', True), text)

    def do_kickstart_addcryptokeys(self, args):
        args = self.parse_arguments(args)

        if len(args) < 2:
            self.help_kickstart_addcryptokeys()
            return

        profile = args[0]
        keys = args[1:]

        self.client.kickstart.profile.system.addKeys(self.session,
                                                     profile,
                                                     keys)

####################

    def help_kickstart_removecryptokeys(self):
        print 'kickstart_removecryptokeys: Remove crypto keys from a ' + \
              'Kickstart profile'
        print 'usage: kickstart_removecryptokeys PROFILE <KEY ...>'

    def complete_kickstart_removecryptokeys(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_kickstart_list('', True), text)
        elif len(parts) > 2:
            # only tab complete keys currently assigned to the profile
            try:
                keys = self.do_kickstart_listcryptokeys(parts[1], True)
            except:
                keys = []

            return self.tab_completer(keys, text)

    def do_kickstart_removecryptokeys(self, args):
        args = self.parse_arguments(args)

        if len(args) < 2:
            self.help_kickstart_removecryptokeys()
            return

        profile = args[0]
        keys = args[1:]

        self.client.kickstart.profile.system.removeKeys(self.session,
                                                        profile,
                                                        keys)

####################

    def help_kickstart_listactivationkeys(self):
        print 'kickstart_listactivationkeys: List the activation keys ' + \
              'associated with a Kickstart profile'
        print 'usage: kickstart_listactivationkeys PROFILE'
    
    def complete_kickstart_listactivationkeys(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_kickstart_list('', True), text)

    def do_kickstart_listactivationkeys(self, args, doreturn=False):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_kickstart_listactivationkeys()
            return

        profile = args[0]

        keys = \
            self.client.kickstart.profile.keys.getActivationKeys(self.session,
                                                                 profile)

        keys = [ k.get('key') for k in keys ]

        if doreturn:
            return keys
        else:
            if len(keys):
                print '\n'.join(sorted(keys))

####################

    def help_kickstart_addactivationkeys(self):
        print 'kickstart_addactivationkeys: Add activation keys to a ' + \
              'Kickstart profile'
        print 'usage: kickstart_addactivationkeys PROFILE <KEY ...>'

    def complete_kickstart_addactivationkeys(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_kickstart_list('', True), text)
        elif len(parts) > 2:
            return self.tab_completer(self.do_activationkey_list('', True), 
                                      text)

    def do_kickstart_addactivationkeys(self, args):
        args = self.parse_arguments(args)

        if len(args) < 2:
            self.help_kickstart_addactivationkeys()
            return

        profile = args[0]
        keys = args[1:]

        for key in keys:
            self.client.kickstart.profile.keys.addActivationKey(self.session,
                                                                profile,
                                                                key)

####################

    def help_kickstart_removeactivationkeys(self):
        print 'kickstart_removeactivationkeys: Remove activation keys from ' + \
              'a Kickstart profile'
        print 'usage: kickstart_removeactivationkeys PROFILE <KEY ...>'

    def complete_kickstart_removeactivationkeys(self, text, line, begidx, 
                                                endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_kickstart_list('', True), text)
        elif len(parts) > 2:
            # only tab complete keys currently assigned to the profile
            try:
                keys = self.do_kickstart_listactivationkeys(parts[1], True)
            except:
                keys = []

            return self.tab_completer(keys, text)

    def do_kickstart_removeactivationkeys(self, args):
        args = self.parse_arguments(args)

        if len(args) < 2:
            self.help_kickstart_removeactivationkeys()
            return

        profile = args[0]
        keys = args[1:]

        if not self.user_confirm('Remove these keys [y/N]:'): return

        for key in keys:
            self.client.kickstart.profile.keys.removeActivationKey(self.session,
                                                                   profile,
                                                                   key)

####################

    def help_kickstart_enableconfigmanagement(self):
        print 'kickstart_enableconfigmanagement: Enable configuration ' + \
              'management on a Kickstart profile'
        print 'usage: kickstart_enableconfigmanagement PROFILE'

    def complete_kickstart_enableconfigmanagement(self, text, line, begidx, 
                                                  endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_kickstart_list('', True), text)

    def do_kickstart_enableconfigmanagement(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_kickstart_enableconfigmanagement()
            return

        profile = args[0]

        self.client.kickstart.profile.system.enableConfigManagement(\
            self.session, profile)

####################

    def help_kickstart_disableconfigmanagement(self):
        print 'kickstart_disableconfigmanagement: Disable configuration ' + \
              'management on a Kickstart profile'
        print 'usage: kickstart_disableconfigmanagement PROFILE'

    def complete_kickstart_disableconfigmanagement(self, text, line, begidx, 
                                                   endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_kickstart_list('', True), text)

    def do_kickstart_disableconfigmanagement(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_kickstart_disableconfigmanagement()
            return

        profile = args[0]

        self.client.kickstart.profile.system.disableConfigManagement(\
            self.session, profile)

####################

    def help_kickstart_enableremotecommands(self):
        print 'kickstart_enableremotecommands: Enable remote commands ' + \
              'on a Kickstart profile'
        print 'usage: kickstart_enableremotecommands PROFILE'

    def complete_kickstart_enableremotecommands(self, text, line, begidx, 
                                                endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_kickstart_list('', True), text)

    def do_kickstart_enableremotecommands(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_kickstart_enableremotecommands()
            return

        profile = args[0]

        self.client.kickstart.profile.system.enableRemoteCommands(self.session,
                                                                  profile)

####################

    def help_kickstart_disableremotecommands(self):
        print 'kickstart_disableremotecommands: Disable remote commands ' + \
              'on a Kickstart profile'
        print 'usage: kickstart_disableremotecommands PROFILE'

    def complete_kickstart_disableremotecommands(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_kickstart_list('', True), text)

    def do_kickstart_disableremotecommands(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_kickstart_disableremotecommands()
            return

        profile = args[0]

        self.client.kickstart.profile.system.disableRemoteCommands(self.session,
                                                                   profile)

####################
        
    def help_kickstart_setlocale(self):
        print 'kickstart_setlocale: Set the locale for a Kickstart profile'
        print 'usage: kickstart_setlocale PROFILE LOCALE'

    def complete_kickstart_setlocale(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_kickstart_list('', True), text)
        elif len(parts) == 3:
            return self.tab_completer(self.list_locales(), text)

    def do_kickstart_setlocale(self, args):
        args = self.parse_arguments(args)

        if len(args) != 2:
            self.help_kickstart_setlocale()
            return

        profile = args[0]
        locale = args[1]

        # always use UTC        
        utc = True

        self.client.kickstart.profile.system.setLocale(self.session,
                                                       profile,
                                                       locale,
                                                       utc)

####################

    def help_kickstart_setselinux(self):
        print 'kickstart_setselinux: Set the SELinux mode for a Kickstart ' + \
              'profile'
        print 'usage: kickstart_setselinux PROFILE MODE'

    def complete_kickstart_setselinux(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_kickstart_list('', True), text)
        elif len(parts) == 3:
            modes = ['enforcing', 'permissive', 'disabled']
            return self.tab_completer(modes, text)

    def do_kickstart_setselinux(self, args):
        args = self.parse_arguments(args)

        if len(args) != 2:
            self.help_kickstart_setselinux()
            return

        profile = args[0]
        mode = args[1]

        self.client.kickstart.profile.system.setSELinux(self.session,
                                                        profile,
                                                        mode)

####################

    def help_kickstart_setpartitions(self):
        print 'kickstart_setpartitions: Set the partitioning scheme for a ' + \
              'Kickstart profile'
        print 'usage: kickstart_setpartitions PROFILE'

    def complete_kickstart_setpartitions(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_kickstart_list('', True), text)

    def do_kickstart_setpartitions(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_kickstart_setpartitions()
            return

        profile = args[0]

        try:
            # get the current scheme so the user can edit it
            current = \
                self.client.kickstart.profile.system.getPartitioningScheme(\
                    self.session, profile)

            template = '\n'.join(current)
        except:
            template = ''

        (partitions, ignore) = self.editor(template=template, delete=True)

        print partitions
        if not self.user_confirm(): return

        lines = partitions.split('\n')

        self.client.kickstart.profile.system.setPartitioningScheme(self.session,
                                                                   profile,
                                                                   lines)

####################

    def help_kickstart_addfilepreservations(self):
        print 'kickstart_addfilepreservations: Add file preservations to a ' + \
              'Kickstart profile'
        print 'usage: kickstart_addfilepreservations PROFILE <FILELIST ...>'

    def complete_kickstart_addfilepreservations(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_kickstart_list('', True), text)
        elif len(parts) == 3:
            return self.tab_completer(self.do_filepreservation_list('', True), 
                                      text)

    def do_kickstart_addfilepreservations(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_kickstart_addfilepreservations()
            return

        profile = args[0]
        files = args[1:]

        self.client.kickstart.profile.system.addFilePreservations(self.session,
                                                                  profile,
                                                                  files)

####################

    def help_kickstart_removefilepreservations(self):
        print 'kickstart_removefilepreservations: Remove file ' + \
              'preservations from a Kickstart profile'
        print 'usage: kickstart_removefilepreservations PROFILE <FILE ...>'

    def complete_kickstart_removefilepreservations(self, text, line, begidx, 
                                                   endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_kickstart_list('', True), text)
        elif len(parts) > 2:
            files = []

            try:
                # only tab complete files currently assigned to the profile
                files = \
                    self.client.kickstart.profile.system.listFilePreservations(\
                        self.session, parts[1])
                files = [ f.get('name') for f in files ]
            except:
                return []

            return self.tab_completer(files, text)

    def do_kickstart_removefilepreservations(self, args):
        args = self.parse_arguments(args)

        if len(args) < 2:
            self.help_kickstart_removefilepreservations()
            return

        profile = args[0]
        files = args[1:]

        self.client.kickstart.profile.system.removeFilePreservations(\
            self.session, profile, files)

####################

    def help_kickstart_listpackages(self):
        print 'kickstart_listpackages: List the packages for a Kickstart ' + \
              'profile'
        print 'usage: kickstart_listpackages PROFILE'

    def complete_kickstart_listpackages(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_kickstart_list('', True), text)

    def do_kickstart_listpackages(self, args, doreturn = False):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_kickstart_listpackages()
            return

        profile = args[0]

        packages = \
            self.client.kickstart.profile.software.getSoftwareList(self.session,
                                                                   profile)

        if doreturn:
            return packages
        else:
            if len(packages):
                print '\n'.join(packages)

####################

    def help_kickstart_addpackages(self):
        print 'kickstart_addpackages: Add packages to a Kickstart profile'
        print 'usage: kickstart_addpackages PROFILE <PACKAGE ...>'

    def complete_kickstart_addpackages(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_kickstart_list('', True), text) 
        elif len(parts) > 2:
            return self.tab_completer(self.get_package_names(), text)

    def do_kickstart_addpackages(self, args):
        args = self.parse_arguments(args)

        if not len(args) >= 2:
            self.help_kickstart_addpackages()
            return

        profile = args[0]
        packages = args[1:]

        self.client.kickstart.profile.software.appendToSoftwareList(\
            self.session, profile, packages)

####################

    def help_kickstart_removepackages(self):
        print 'kickstart_removepackages: Remove packages from a Kickstart ' + \
              'profile'
        print 'usage: kickstart_removepackages PROFILE <PACKAGE ...>'

    def complete_kickstart_removepackages(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_kickstart_list('', True), 
                                      text)
        elif len(parts) > 2:
            return self.tab_completer(self.do_kickstart_listpackages(\
                                      parts[1], True), text)

    def do_kickstart_removepackages(self, args):
        args = self.parse_arguments(args)

        if not len(args) >= 2:
            self.help_kickstart_removepackages()
            return

        profile = args[0]
        to_remove = args[1:]

        # setSoftwareList requires a new list of packages, so grab
        # the old list and remove the list of packages from the user
        packages = self.do_kickstart_listpackages(profile, True)
        for package in to_remove:
            if package in packages:
                packages.remove(package)

        logging.debug(packages)

        if not self.user_confirm('Remove these packages [y/N]:'): return

        self.client.kickstart.profile.software.setSoftwareList(self.session,
                                                               profile,
                                                               packages)

####################

    def help_login(self):
        print 'login: Connect to a Spacewalk server'
        print 'usage: login [USERNAME] [SERVER]'

    def do_login(self, args):
        args = self.parse_arguments(args)

        self.session = ''

        if self.options.nossl:
            proto = 'http'
        else:
            proto = 'https'

        if len(args) == 2 and args[1]:
            server = args[1]
        elif self.options.server:
            server = self.options.server
        else:
            logging.warning('No server specified')
            return

        serverurl = '%s://%s/rpc/api' % (proto, server)

        # connect to the server
        logging.debug('Connecting to %s' % (serverurl))
        self.client = xmlrpclib.Server(serverurl)

        try:
            api_version = self.client.api.getVersion()
        except:
            logging.error(sys.exc_info()[1])
            logging.debug(sys.exc_info())
            logging.error('API version check failed')
            self.client = None
            return

        # ensure the server is recent enough
        if api_version < self.MINIMUM_API_VERSION:
            logging.error('API (%s) is too old (>= %s required)'
                          % (api_version, self.MINIMUM_API_VERSION))

            self.client = None
            return

        # retrieve a cached session
        if not self.options.nocache:
            if os.path.isfile(self.session_file):
                try:
                    # read the session (format = username:session)
                    sessionfile = open(self.session_file, 'r')
                    parts = sessionfile.read().split(':')
                    sessionfile.close()

                    username = parts[0]
                    self.session = parts[1]
                except:
                    logging.error('Could not read %s' % self.session_file)
                    logging.debug(sys.exc_info())

                try:
                    logging.info('Using cached credentials from %s' %
                                 self.session_file)

                    self.client.user.listUsers(self.session)
                except:
                    logging.info('Cached credentials are invalid')
                    self.session = ''

                    try:
                        os.remove(self.session_file)
                    except:
                        logging.debug(sys.exc_info())
                        pass

        # attempt to login if we don't have a valid session yet
        if not self.session:
            if self.options.username:
                username = self.options.username
                self.options.username = None
            elif len(args) and args[0]:
                username = args[0]
            else:
                username = self.prompt_user('Username:')

                # don't store the username in the command history
                self.remove_last_history_item()

            if self.options.password:
                password = self.options.password
                self.options.password = None
            else:
                password = getpass('Password: ')

            try:
                self.session = self.client.auth.login(username,
                                                      password)
            except:
                logging.warning('Invalid credentials')
                logging.debug(sys.exc_info())
                return

            # write the session to a cache
            if not self.options.nocache:
                try:
                    logging.debug('Writing session cache to %s' %
                                  self.session_file)
                    sessionfile = open(self.session_file, 'w')
                    sessionfile.write('%s:%s' % (username, self.session))
                    sessionfile.close()
                except:
                    logging.error('Could not write cache file')
                    logging.debug(sys.exc_info())

        # disable caching of subsequent logins
        self.options.nocache = True

        # keep track of who we are and who we're connected to
        self.username = username
        self.server = server

        logging.info('Connected to %s as %s' % (serverurl, username))

####################

    def help_logout(self):
        print 'logout: Disconnect from a Spacewalk server'
        print 'usage: logout'

    def do_logout(self, args):
        if self.session:
            self.client.auth.logout(self.session)
            self.session = ''
            self.username = ''
            self.server = ''
            self.clear_system_cache()
            self.clear_package_cache()

            if os.path.isfile(self.session_file):
                try:
                    os.remove(self.session_file)
                except:
                    logging.debug(sys.exc_info())
        else:
            logging.warning("You're not logged in")

####################

    def help_package_details(self):
        print 'package_details: Show the details of a software package'
        print 'usage: package_details PACKAGE ...'

    def complete_package_details(self, text, line, begidx, endidx):
        return self.tab_completer(self.get_package_names(True), text)

    def do_package_details(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_package_details()
            return

        add_separator = False

        self.generate_package_cache()

        for package in args:
            if add_separator: print self.SEPARATOR
            add_separator = True

            if package in self.all_package_longnames:
                id = self.all_package_longnames[package]
            else:
                logging.warning('%s is not a valid package' % package)
                continue

            details = self.client.packages.getDetails(self.session, id)

            channels = \
                self.client.packages.listProvidingChannels(self.session, id)

            print 'Name:    %s' % details.get('name')
            print 'Version: %s' % details.get('version')
            print 'Release: %s' % details.get('release')
            print 'Epoch:   %s' % details.get('epoch')
            print 'Arch:    %s' % details.get('arch_label')

            print
            print 'Description: '
            print '\n'.join(wrap(details.get('description')))

            print
            print 'File:    %s' % details.get('file')
            print 'Size:    %s' % details.get('size')
            print 'MD5:     %s' % details.get('md5sum')

            print
            print 'Available From:'
            print '\n'.join(sorted([c.get('label') for c in channels]))

####################

    def help_package_search(self):
        print 'package_search: Find packages that meet the given criteria'
        print 'usage: package_search NAME|QUERY'
        print
        print 'Example: package_search kernel'
        print
        print 'Advanced Search:'
        print 'Available Fields: name, epoch, version, release, arch, ' + \
              'description, summary'
        print 'Example: name:kernel AND version:2.6.18 AND -description:devel'

    def do_package_search(self, args, doreturn = False):
        if not len(args):
            self.help_package_search()
            return

        fields = ('name', 'epoch', 'version', 'release',
                  'arch', 'description', 'summary')

        advanced = False
        for f in fields:
            if re.match('%s:' % f, args):
                logging.debug('Using advanced search')
                advanced = True
                break

        if advanced:
            packages = self.client.packages.search.advanced(self.session, args)
            packages = self.build_package_names(packages)
        else:
            # for non-advanced searches, use local regex instead of
            # the APIs for searching; this is done because the fuzzy
            # search on the server gives a lot of garbage back
            self.generate_package_cache()
            packages = self.filter_results(self.all_package_longnames.keys(),
                                           [ args ], search = True)

        if len(packages):
            if doreturn:
                return packages
            else:
                print '\n'.join(sorted(packages))

####################

    def help_report_inactivesystems(self):
        print 'report_inactivesystems: List all inactive systems'
        print 'usage: report_inactivesystems [DAYS]'

    def do_report_inactivesystems(self, args):
        args = self.parse_arguments(args)
    
        if len(args) == 1:
            try:
                days = int(args[0])
            except:
                days = 365

            systems = self.client.system.listInactiveSystems(self.session, days)
        else:
            systems = self.client.system.listInactiveSystems(self.session)

        systems = [ s.get('name') for s in systems ]

        if len(systems):
            print '\n'.join(sorted(systems))

####################

    def help_report_outofdatesystems(self):
        print 'report_outofdatesystems: List all out-of-date systems'
        print 'usage: report_outofdatesystems'

    def do_report_outofdatesystems(self, args):
        systems = self.client.system.listOutOfDateSystems(self.session)

        #XXX: max(list, key=len) in >2.5
        max_size = 0
        for system in systems:
            size = len(system.get('name'))
            if size > max_size: max_size = size

        report = {}
        for system in systems:
            id = system.get('id')

            packages = \
                self.client.system.listLatestUpgradablePackages(self.session,
                                                                id)

            report[system.get('name')] = len(packages)

        if len(report):
            print '%s  Packages' % ('System'.ljust(max_size))
            print '%s  --------' % ('------'.ljust(max_size))
            for system in sorted(report):
                print '%s       %s' % \
                      (system.ljust(max_size), str(report[system]).rjust(3))

####################

    def help_report_activesystems(self):
        print 'report_activesystems: List all active systems'
        print 'usage: report_activesystems'

    def do_report_activesystems(self, args):
        systems = self.client.system.listActiveSystems(self.session)
        systems = [ s.get('name') for s in systems ]

        if len(systems):
            print '\n'.join(sorted(systems))

####################

    def help_report_ungroupedsystems(self):
        print 'report_ungroupedsystems: List all ungrouped systems'
        print 'usage: report_ungroupedsystems'

    def do_report_ungroupedsystems(self, args):
        systems = self.client.system.listUngroupedSystems(self.session)
        systems = [ s.get('name') for s in systems ]

        if len(systems):
            print '\n'.join(sorted(systems))

####################

    def help_report_errata(self):
        print 'report_errata: List all out-of-date systems'
        print 'usage: report_errata'

    #XXX: performance is terrible due to all the API calls
    def do_report_errata(self, args):
        self.generate_errata_cache()

        report = {}
        for errata in self.all_errata:
            affected = self.client.errata.listAffectedSystems(self.session,
                                                              errata)

            num_affected = len(affected)
            if num_affected:
                report[errata] = num_affected

        #XXX: max(list, key=len) in >2.5
        max_size = 0
        for e in report.keys():
            size = len(e)
            if size > max_size: max_size = size

        if len(report):
            print '%s  # Systems' % ('Errata'.ljust(max_size))
            print '%s  ---------' % ('------'.ljust(max_size))
            for errata in sorted(report):
                print '%s     %s' % \
                      (errata.ljust(max_size), str(report[errata]).rjust(3))

####################

    def help_report_ipaddresses(self):
        print 'report_network: List the hostname and IP of each system'
        print 'usage: report_network [<SYSTEMS>]'
        print
        print self.HELP_SYSTEM_OPTS

    def do_report_ipaddresses(self, args):
        args = self.parse_arguments(args)

        if len(args):
            # use the systems listed in the SSM
            if re.match('ssm', args[0], re.I):
                systems = self.ssm.keys()
            else:
                systems = self.expand_systems(args)
        else:
            systems = self.get_system_names()

        report = {}
        for system in systems:
            id = self.get_system_id(system)
            network = self.client.system.getNetwork(self.session, id)
            report[system] = {'hostname' : network.get('hostname'),
                              'ip'       : network.get('ip') }

        #XXX: max(list, key=len) in >2.5
        system_max_size = 0
        for s in report.keys():
            size = len(s)
            if size > system_max_size: system_max_size = size
        
        hostname_max_size = 0
        for h in [report[h]['hostname'] for h in report]:
            size = len(h)
            if size > hostname_max_size: hostname_max_size = size


        if len(report):
            print '%s  %s  IP' % ('System'.ljust(system_max_size),
                                  'Hostname'.ljust(hostname_max_size))

            print '%s  %s  --' % ('------'.ljust(system_max_size),
                                  '--------'.ljust(hostname_max_size))

            for system in sorted(report):
                print '%s  %s  %s' % \
                    (system.ljust(system_max_size), 
                     report[system]['hostname'].ljust(hostname_max_size),
                     report[system]['ip'].ljust(15))

####################

    def help_report_kernels(self):
        print 'report_network: List the running kernel of each system'
        print 'usage: report_network [<SYSTEMS>]'
        print
        print self.HELP_SYSTEM_OPTS

    def do_report_kernels(self, args):
        args = self.parse_arguments(args)

        if len(args):
            # use the systems listed in the SSM
            if re.match('ssm', args[0], re.I):
                systems = self.ssm.keys()
            else:
                systems = self.expand_systems(args)
        else:
            systems = self.get_system_names()

        report = {}
        for system in systems:
            id = self.get_system_id(system)
            kernel = self.client.system.getRunningKernel(self.session, id)
            report[system] = kernel

        #XXX: max(list, key=len) in >2.5
        system_max_size = 0
        for s in report.keys():
            size = len(s)
            if size > system_max_size: system_max_size = size
        
        if len(report):
            print '%s  Kernel' % ('System'.ljust(system_max_size))

            print '%s  ------' % ('------'.ljust(system_max_size))

            for system in sorted(report):
                print '%s  %s' % (system.ljust(system_max_size), kernel)

####################

    def help_schedule_cancel(self):
        print 'schedule_cancel: Cancel a scheduled action'
        print 'usage: schedule_cancel ID|* ...'

    def complete_schedule_cancel(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_schedule_listpending('', True),
                                  text)

    def do_schedule_cancel(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_schedule_cancel()
            return

        # cancel all actions
        if '.*' in args:
            prompt = 'Do you really want to cancel all pending actions?'

            if self.user_confirm(prompt):
                strings = self.do_schedule_listpending('', True)
            else:
                return
        else:
            strings = args

        # convert strings to integers
        actions = []
        for a in strings:
            try:
                actions.append(int(a))
            except ValueError:
                logging.warning('%s is not a valid ID' % str(a))
                continue

        self.client.schedule.cancelActions(self.session, actions)

        for a in actions:
            logging.info('Canceled action %s' % str(a))

        print 'Canceled %s actions' % str(len(actions))

####################

    def help_schedule_details(self):
        print 'schedule_details: Show the details of a scheduled action'
        print 'usage: schedule_details ID'

    def do_schedule_details(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_schedule_details()
            return

        try:
            id = int(args[0])
        except:
            logging.warning('%s is not a valid ID' % str(a))
            return

        completed = self.client.schedule.listCompletedSystems(self.session, id)
        failed = self.client.schedule.listFailedSystems(self.session, id)
        pending = self.client.schedule.listInProgressSystems(self.session, id)

        # put all the system arrays together for the summary
        all_systems = []
        all_systems.extend(completed)
        all_systems.extend(failed)
        all_systems.extend(pending)

        # schedule.getAction() API call would make this easier
        all_actions = self.client.schedule.listAllActions(self.session)
        action = 0
        for a in all_actions:
            if a.get('id') == id:
                action = a
                del all_actions
                break

        self.print_action_summary(action, systems = all_systems)
        
        print
        print 'Completed: %s' % str(len(completed))
        print 'Failed:    %s' % str(len(failed))
        print 'Pending:   %s' % str(len(pending))

        if len(completed):
            print
            print 'Completed Systems:'
            for s in completed:
                print '  %s' % s.get('server_name')

        if len(failed):
            print
            print 'Failed Systems:'
            for s in failed:
                print '  %s' % s.get('server_name')

        if len(pending):
            print
            print 'Pending Systems:'
            for s in pending:
                print '  %s' % s.get('server_name')

####################

    def help_schedule_getoutput(self):
        print 'schedule_getoutput: Show the output from an action'
        print 'usage: schedule_getoutput ID'

    def do_schedule_getoutput(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_schedule_getoutput()
            return
        elif len(args) > 1:
            systems = args[1:]
        else:
            systems = []

        try:
            action_id = int(args[0])
        except:
            logging.error('%s is not a valid action ID' % str(a))
            return

        script_results = None
        try:
            #XXX: Bugzilla 584869
            script_results = \
                self.client.system.getScriptResults(self.session, action_id)
        except:
            pass

        # scripts have a different data structure than other actions
        if script_results:
            add_separator = False
            for r in script_results:
                if add_separator: print self.SEPARATOR
                add_separator = True

                print 'System:      %s' % 'UNKNOWN'
                print 'Start Time:  %s' % self.format_time(r.get('startDate').value)
                print 'Stop Time:   %s' % self.format_time(r.get('stopDate').value)
                print 'Return Code: %s' % str(r.get('returnCode'))
                print 'Output:'
                print r.get('output')
        else:
            add_separator = False

            completed = self.client.schedule.listCompletedSystems(self.session, action_id)
            failed = self.client.schedule.listFailedSystems(self.session, action_id)

            #XXX: Bugzilla 608868
            for action in completed + failed:
                if add_separator: print self.SEPARATOR
                add_separator = True

                self.print_action_output(action)

#        completed = self.client.schedule.listCompletedSystems(self.session, id)
#
#        if len(completed):
#            print
#            print 'Completed Systems:'
#
#            add_separator = False
#            for r in completed:
#                if add_separator:
#                    print self.SEPARATOR
#
#                add_separator = True
#
#                print 'System:      %s' % r.get('server_name')
#                print 'Completed:   %s' % re.sub('T', ' ',
#                                                 r.get('timestamp').value)
#
#                print
#                print r.get('message')
#
#        failed = self.client.schedule.listFailedSystems(self.session, id)
#
#        if len(failed):
#            print
#            print 'Failed Systems:'
#
#            add_separator = False
#            for r in failed:
#                if add_separator:
#                    print self.SEPARATOR
#
#                add_separator = True
#
#                print 'System:      %s' % r.get('server_name')
#                print 'Completed:   %s' % re.sub('T', ' ',
#                                                 r.get('timestamp').value)
#
#                print
#                print r.get('message')

####################

    def help_schedule_listpending(self):
        print 'schedule_listpending: List pending actions'
        print 'usage: schedule_listpending [LIMIT]'

    def do_schedule_listpending(self, args, doreturn=False):
        actions = self.client.schedule.listInProgressActions(self.session)

        if not len(actions): return

        if doreturn:
            return [str(a.get('id')) for a in actions]
        else:
            try:
                limit = int(args[0])
            except:
                limit = len(actions)

            add_separator = False

            for i in range(0, limit):
                if add_separator: print self.SEPARATOR
                add_separator = True

                systems = self.client.schedule.listInProgressSystems(\
                              self.session, actions[i].get('id'))

                self.print_action_summary(actions[i], systems)

####################

    def help_schedule_listcompleted(self):
        print 'schedule_listcompleted: List completed actions'
        print 'usage: schedule_listcompleted [LIMIT]'

    def do_schedule_listcompleted(self, args, doreturn=False):
        actions = self.client.schedule.listCompletedActions(self.session)

        if not len(actions): return

        if doreturn:
            return [str(a.get('id')) for a in actions]
        else:
            try:
                limit = int(args[0])
            except:
                limit = len(actions)

            add_separator = False

            for i in range(0, limit):
                if add_separator: print self.SEPARATOR
                add_separator = True

                systems = self.client.schedule.listCompletedSystems(\
                              self.session, actions[i].get('id'))

                self.print_action_summary(actions[i], systems)

####################

    def help_schedule_listfailed(self):
        print 'schedule_listfailed: List failed actions'
        print 'usage: schedule_listfailed [LIMIT]'

    def do_schedule_listfailed(self, args, doreturn=False):
        actions = self.client.schedule.listFailedActions(self.session)

        if not len(actions): return

        if doreturn:
            return [str(a.get('id')) for a in actions]
        else:
            try:
                limit = int(args[0])
            except:
                limit = len(actions)

            add_separator = False

            for i in range(0, limit):
                if add_separator: print self.SEPARATOR
                add_separator = True

                systems = self.client.schedule.listFailedSystems(\
                              self.session, actions[i].get('id'))

                self.print_action_summary(actions[i], systems)

####################

    def help_schedule_listarchived(self):
        print 'schedule_listarchived: List archived actions'
        print 'usage: schedule_listarchived [LIMIT]'

    def do_schedule_listarchived(self, args, doreturn=False):
        actions = self.client.schedule.listArchivedActions(self.session)

        if not len(actions): return

        if doreturn:
            return [str(a.get('id')) for a in actions]
        else:
            try:
                limit = int(args[0])
            except:
                limit = len(actions)

            add_separator = False

            for i in range(0, limit):
                if add_separator: print self.SEPARATOR
                add_separator = True

                completed = \
                    self.client.schedule.listCompletedSystems(self.session,
                                                       actions[i].get('id'))
                failed = \
                    self.client.schedule.listFailedSystems(self.session,
                                                           actions[i].get('id'))
                pending = \
                    self.client.schedule.listInProgressSystems(self.session,
                                                       actions[i].get('id'))

                all_systems = completed + failed + pending

                self.print_action_summary(actions[i], all_systems)

####################

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

    def complete_snippet_details(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_snippet_list('', True),
                                  text)

    def do_snippet_details(self, args):
        args = self.parse_arguments(args)

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
        args = self.parse_arguments(args)

        template = ''
        if name:
            snippets = self.client.kickstart.snippet.listCustom(self.session)
            for s in snippets:
                if s.get('name') == name:
                    template = s.get('contents')
                    break
        else:
            name = self.prompt_user('Name:', noblank = True)

        (contents, ignore) = self.editor(template = template, delete = True)

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

    def complete_snippet_update(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_snippet_list('', True), text)

    def do_snippet_update(self, args):
        args = self.parse_arguments(args)
        
        if not len(args):
            self.help_snippet_update()
            return

        return self.do_snippet_create('', name=args[0])

####################

    def help_snippet_delete(self):
        print 'snippet_removefile: Delete a Kickstart snippet'
        print 'usage: snippet_removefile NAME'

    def complete_snippet_delete(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_snippet_list('', True), text)

    def do_snippet_delete(self, args):
        args = self.parse_arguments(args)
        
        if not len(args):
            self.help_snippet_delete()
            return

        snippet = args[0]

        if self.user_confirm('Remove this snippet [y/N]:'):
            self.client.kickstart.snippet.delete(self.session, snippet)

####################

    def help_softwarechannel_list(self):
        print 'softwarechannel_list: List all available software channels'
        print 'usage: softwarechannel_list'

    def do_softwarechannel_list(self, args, doreturn=False):
        channels = self.client.channel.listAllChannels(self.session)
        channels = [c.get('label') for c in channels]

        if doreturn:
            return channels
        else:
            if len(channels):
                print '\n'.join(sorted(channels))

####################

    def help_softwarechannel_listsystems(self):
        print 'softwarechannel_listsystems: List all systems subscribed to'
        print '                             a software channel'
        print 'usage: softwarechannel_listsystems CHANNEL'

    def complete_softwarechannel_listsystems(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_softwarechannel_list('', True), text)

    def do_softwarechannel_listsystems(self, args, doreturn=False):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_softwarechannel_listsystems()
            return

        channel = args[0]

        systems = \
            self.client.channel.software.listSubscribedSystems(self.session,
                                                               channel)

        systems = [s.get('name') for s in systems]

        if doreturn:
            return systems
        else:
            if len(systems):
                print '\n'.join(sorted(systems))

####################

    def help_softwarechannel_listpackages(self):
        print 'softwarechannel_listpackages: List the most recent packages'
        print '                              available from a software channel'
        print 'usage: softwarechannel_listpackages CHANNEL'

    def complete_softwarechannel_listpackages(self, text, line, begidx, endidx):
        if len(line.split(' ')) == 2:
            return self.tab_completer(self.do_softwarechannel_list('', True), 
                                      text)
        else:
            return []

    def do_softwarechannel_listpackages(self, args, doreturn=False):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_softwarechannel_listpackages()
            return

        channel = args[0]

        packages = self.client.channel.software.listLatestPackages(self.session,
                                                                   channel)

        packages = self.build_package_names(packages)

        if doreturn:
            return packages
        else:
            if len(packages):
                print '\n'.join(sorted(packages))

####################

    def help_softwarechannel_details(self):
        print 'softwarechannel_details: Show the details of a software channel'
        print 'usage: softwarechannel_details CHANNEL ...'

    def complete_softwarechannel_details(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_softwarechannel_list('', True), text)

    def do_softwarechannel_details(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_softwarechannel_details()
            return

        add_separator = False

        for channel in args:
            details = self.client.channel.software.getDetails(self.session,
                                                              channel)

            systems = \
                self.client.channel.software.listSubscribedSystems(self.session,                                                                   channel)

            trees = self.client.kickstart.tree.list(self.session, channel)

            if add_separator: print self.SEPARATOR
            add_separator = True

            print 'Label:              %s' % details.get('label')
            print 'Name:               %s' % details.get('name')
            print 'Architecture:       %s' % details.get('arch_name')
            print 'Parent:             %s' % details.get('parent_channel_label')
            print 'Systems Subscribed: %s' % str(len(systems))

            if details.get('summary'):
                print
                print 'Summary:'
                print '\n'.join(wrap(details.get('summary')))

            if details.get('description'):
                print
                print 'Description:'
                print '\n'.join(wrap(details.get('description')))

            print
            print 'GPG Key:            %s' % details.get('gpg_key_id')
            print 'GPG Fingerprint:    %s' % details.get('gpg_key_fp')
            print 'GPG URL:            %s' % details.get('gpg_key_url')

            if len(trees):
                print
                print 'Kickstart Trees:'
                for tree in trees:
                    print '  %s' % tree.get('label')

####################

    def help_softwarechannel_listerrata(self):
        print 'softwarechannel_listerrata: List the errata associated with a'
        print '                            software channel'
        print 'usage: softwarechannel_listerrata CHANNEL ...'

    def complete_softwarechannel_listerrata(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_softwarechannel_list('', True), text)

    def do_softwarechannel_listerrata(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.do_help_softwarechannel_listerrata()
            return

        channels = args

        add_separator = False

        for channel in sorted(channels):
            if len(channels) > 1:
                print 'Channel: %s' % channel
                print

            errata = self.client.channel.software.listErrata(self.session,
                                                             channel)

            self.print_errata_list(errata)

            if add_separator: print self.SEPARATOR
            add_separator = True

####################

    def help_softwarechannel_regenerateneededcache(self):
        print 'softwarechannel_regenerateneededcache: '
        print 'Regenerate the needed errata and package cache for all systems'
        print
        print 'usage: softwarechannel_regnerateneededcache'

    def do_softwarechannel_regenerateneededcache(self, args):
        if self.user_confirm('Are you sure [y/N]: '):
            self.client.channel.software.regenerateNeededCache(self.session)

####################

    def help_ssm(self):
        print 'The System Set Manager (SSM) is a group of systems that you '
        print 'can perform tasks on as a group.'
        print
        print 'Adding Systems:'
        print '> ssm_add group:rhel5-x86_64'
        print '> ssm_add channel:rhel-x86_64-server-5'
        print '> ssm_add search:device:vmware'
        print '> ssm_add host.example.com'
        print
        print 'Using the SSM:'
        print '> system_installpackage ssm zsh'
        print '> system_runscript ssm'

####################

    def help_ssm_add(self):
        print 'ssm_add: Add systems to the SSM'
        print 'usage: ssm_add SYSTEM|group:GROUP|channel:CHANNEL|search:QUERY'
        print
        print "see 'help ssm' for more details"

    def complete_ssm_add(self, text, line, begidx, endidx):
        return self.tab_complete_systems(text)

    def do_ssm_add(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_ssm_add()
            return

        systems = self.expand_systems(args)

        if not len(systems):
            logging.warning('No systems found')
            return

        for system in systems:
            if system in self.ssm:
                logging.warning('%s is already in the list' % system)
                continue
            else:
                self.ssm[system] = self.get_system_id(system)
                logging.info('Added %s' % system)

        if len(self.ssm):
            print 'Systems Selected: %s' % str(len(self.ssm))
        
        # save the SSM for use between sessions
        self.save_cache(self.ssm_cache_file, self.ssm)

####################

    def help_ssm_remove(self):
        print 'ssm_remove: Remove systems from the SSM'
        print 'usage: ssm_remove SYSTEM|group:GROUP|channel:CHANNEL|' + \
              'search:QUERY'
        print
        print "see 'help ssm' for more details"

    def complete_ssm_remove(self, text, line, begidx, endidx):
        return self.tab_complete_systems(text)

    def do_ssm_remove(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_ssm_remove()
            return

        systems = self.expand_systems(args)

        if not len(systems):
            logging.warning('No systems found')
            return

        for system in systems:
            # double-check for existance in case of duplicate names
            if system in self.ssm:
                logging.info('Removed %s' % system)
                self.ssm.remove(system)

        print 'Systems Selected: %s' % str(len(self.ssm))

        # save the SSM for use between sessions
        self.save_cache(self.ssm_cache_file, self.ssm)

####################

    def help_ssm_list(self):
        print 'ssm_list: List the systems currently in the SSM'
        print 'usage: ssm_list'
        print
        print "see 'help ssm' for more details"

    def do_ssm_list(self, args):
        systems = sorted(self.ssm)

        if len(systems):
            print '\n'.join(systems)
            print 'Systems Selected: %s' % str(len(systems))

####################

    def help_ssm_clear(self):
        print 'ssm_clear: Remove all systems from the SSM'
        print 'usage: ssm_clear'

    def do_ssm_clear(self, args):
        self.ssm = {}

        # save the SSM for use between sessions
        self.save_cache(self.ssm_cache_file, self.ssm)

####################

    def help_system_list(self):
        print 'system_list: List all system profiles'
        print 'usage: system_list'

    def do_system_list(self, args, doreturn=False):
        if doreturn:
            return self.get_system_names()
        else:
            if len(self.get_system_names()):
                print '\n'.join(sorted(self.get_system_names()))

####################

    def help_system_reboot(self):
        print 'system_reboot: Reboot a system'
        print 'usage: system_reboot <SYSTEMS>'
        print
        print self.HELP_SYSTEM_OPTS
    
    def complete_system_reboot(self, text, line, begidx, endidx):
        return self.tab_complete_systems(text)

    def do_system_reboot(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_reboot()
            return

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)

        if not self.user_confirm('Reboot these systems [y/N]:'): return

        time = self.parse_time_input('now')

        for system in systems:
            id = self.get_system_id(system)
            if not id: continue

            self.client.system.scheduleReboot(self.session, id, time)

####################

    def help_system_search(self):
        print 'system_search: List systems that match the given criteria'
        print 'usage: system_search QUERY'
        print
        print 'Available Fields:'
        print '\n'.join(self.SYSTEM_SEARCH_FIELDS)
        print
        print 'Examples:'
        print '> system_search device:vmware'
        print '> system_search ip:192.168.82'

    def do_system_search(self, args, doreturn=False):
        args = self.parse_arguments(args)

        if len(args) != 1:
            self.help_system_search()
            return
    
        query = args[0]

        if re.search(':', query):
            try:
                (field, value) = query.split(':')
            except ValueError:
                logging.error('Invalid query')
                return []
        else:
            field = 'name'
            value = query

        if not value:
            logging.warning('Invalid query')
            return []

        results = []
        if field == 'name':
            results = self.client.system.search.nameAndDescription(self.session,
                                                                   value)
            key = 'name'
        elif field == 'id':
            # build an array of key/value pairs from our local system cache
            self.generate_system_cache()
            results = [ {'id' : k, 'name' : self.all_systems[k] } \
                        for k in self.all_systems ]
            key = 'id'
        elif field == 'ip':
            results = self.client.system.search.ip(self.session, value)
            key = 'ip'
        elif field == 'hostname':
            results = self.client.system.search.hostname(self.session, value)
            key = 'hostname'
        elif field == 'device':
            results = self.client.system.search.deviceDescription(self.session,
                                                                  value)
            key = 'hw_description'
        elif field == 'vendor':
            results = self.client.system.search.deviceVendorId(self.session,
                                                               value)
            key = 'hw_vendor_id'
        elif field == 'driver':
            results = self.client.system.search.deviceDriver(self.session,
                                                             value)
            key = 'hw_driver'
        else:
            logging.warning('Invalid search field')
            return []

        systems = []
        max_size = 0
        for s in results:
            # only use real matches, not the fuzzy ones we get back
            if re.search(value, str(s.get(key)), re.I):
                if len(s.get('name')) > max_size:
                    max_size = len(s.get('name'))

                systems.append( (s.get('name'), s.get(key)) )

        if doreturn:
            return [s[0] for s in systems]
        else:
            if len(systems):
                for s in sorted(systems):
                    if key == 'name':
                        print s[0]
                    else:
                        print '%s  %s' % (s[0].ljust(max_size), str(s[1]).strip())

####################

    def help_system_runscript(self):
        print 'system_runscript: Schedule a script to run on the list of'
        print '                  systems provided'
        print 'usage: system_runscript <SYSTEMS>'
        print
        print self.HELP_SYSTEM_OPTS
        print
        print 'Start Time Examples:'
        print 'now  -> right now!'
        print '15m  -> 15 minutes from now'
        print '1d   -> 1 day from now'

    def complete_system_runscript(self, text, line, begidx, endidx):
        return self.tab_complete_systems(text)

    def do_system_runscript(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_runscript()
            return

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)

        if not len(systems):
            logging.warning('No systems selected')
            return

        user    = self.prompt_user('User [root]:')
        group   = self.prompt_user('Group [root]:')
        timeout = self.prompt_user('Timeout (in seconds) [600]:')
        time    = self.prompt_user('Start Time [now]:')
        script_file  = self.prompt_user('Script File [create]:')

        # defaults
        if not user:        user        = 'root'
        if not group:       group       = 'root'
        if not timeout:     timeout     = 600

        # convert the time input to xmlrpclib.DateTime
        time = self.parse_time_input(time)

        if script_file:
            keep_script_file = True

            script_file = os.path.abspath(script_file)

            try:
                file = open(script_file, 'r')
                script = file.read()
                file.close()
            except:
                logging.error('Could not read %s' % script_file)
                logging.error(sys.exc_info()[1])
                logging.debug(sys.exc_info())
                return
        else:
            keep_script_file = False

            # have the user put the script into that file
            # put 'hostname' in automatically until the API is fixed
            (script, script_file) = self.editor('#!/bin/bash\n\nhostname\n')

        if not script:
            logging.error('No script provided')
            return

        # display a summary
        print
        print 'User:       %s' % user
        print 'Group:      %s' % group
        print 'Timeout:    %s seconds' % str(timeout)
        print 'Start Time: %s' % self.format_time(time.value)
        print
        print script
        print

        # have the user confirm
        if not self.user_confirm(): return

        scheduled = 0
        for system in systems:
            system_id = self.get_system_id(system)
            if not system_id: return

            # the current API forces us to schedule each system individually
            # XXX: Bugzilla 584867
            try:
                id = self.client.system.scheduleScriptRun(self.session,
                                                          system_id,
                                                          user,
                                                          group,
                                                          timeout,
                                                          script,
                                                          time)
            
                logging.info('Action ID: %s' % str(id))
                scheduled += 1
            except:
                logging.error('Failed to schedule %s' % system)

        print 'Scheduled: %i system(s)' % scheduled

        if not keep_script_file:
            try:
                os.remove(script_file)
            except:
                logging.error('Could not remove %s' % script_file)
                logging.error(sys.exc_info()[1])
                logging.debug(sys.exc_info())

####################

    def help_system_listhardware(self):
        print 'system_listhardware: List the hardware details of a system'
        print 'usage: system_listhardware <SYSTEMS>'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_listhardware(self, text, line, begidx, endidx):
        return self.tab_complete_systems(text)

    def do_system_listhardware(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_details()
            return

        add_separator = False

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)

        for system in sorted(systems):
            system_id = self.get_system_id(system)
            if not system_id: return

            cpu = self.client.system.getCpu(self.session, system_id)
            memory = self.client.system.getMemory(self.session, system_id)
            devices = self.client.system.getDevices(self.session, system_id)
            network = self.client.system.getNetworkDevices(self.session,
                                                           system_id)

            # Solaris systems don't have these value s
            for v in ('cache', 'vendor', 'family', 'stepping'):
                if not cpu.get(v):
                    cpu[v] = ''

            try:
                dmi = self.client.system.getDmi(self.session, system_id)
            except xml.parsers.expat.ExpatError:
                dmi = None

            if add_separator: print self.SEPARATOR
            add_separator = True

            if len(systems) > 1:
                print 'System: %s' % system
                print

            if len(network):
                print 'Network:'

                count = 0
                for device in network:
                    if count: print
                    count += 1

                    print '  Interface:   %s' % device.get('interface')
                    print '  MAC Address: %s' % (
                                 device.get('hardware_address').upper())
                    print '  IP Address:  %s' % device.get('ip')
                    print '  Netmask:     %s' % device.get('netmask')
                    print '  Broadcast:   %s' % device.get('broadcast')
                    print '  Module:      %s' % device.get('module')
                print

            print 'CPU:'
            print '  Count:    %s' % str(cpu.get('count'))
            print '  Arch:     %s' % cpu.get('arch')
            print '  MHz:      %s' % cpu.get('mhz')
            print '  Cache:    %s' % cpu.get('cache')
            print '  Vendor:   %s' % cpu.get('vendor')
            print '  Model:    %s' % re.sub('\s+', ' ', cpu.get('model'))

            print
            print 'Memory:'
            print '  RAM:  %s' % str(memory.get('ram'))
            print '  Swap: %s' % str(memory.get('swap'))

            if dmi:
                print
                print 'DMI:'
                print '  Vendor:       %s' % dmi.get('vendor')
                print '  System:       %s' % dmi.get('system')
                print '  Product:      %s' % dmi.get('product')
                print '  Board:        %s' % dmi.get('board')

                print
                print '  Asset:'
                for asset in dmi.get('asset').split(') ('):
                    print '    %s' % re.sub('\)|\(', '', asset)

                print
                print '  BIOS Release: %s' % dmi.get('bios_release')
                print '  BIOS Vendor:  %s' % dmi.get('bios_vendor')
                print '  BIOS Version: %s' % dmi.get('bios_version')

            if len(devices):
                print
                print 'Devices:'

                count = 0
                for device in devices:
                    if count: print
                    count += 1

                    print '  Description: %s' % (
                             wrap(device.get('description'), 60)[0])
                    print '  Driver:      %s' % device.get('driver')
                    print '  Class:       %s' % device.get('device_class')
                    print '  Bus:         %s' % device.get('bus')

####################

    def help_system_installpackage(self):
        print 'system_installpackage: Install a package on a system'
        print 'usage: system_installpackage <SYSTEMS> <PACKAGE ...>'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_installpackage(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_complete_systems(text)
        elif len(parts) > 2:
            return self.tab_completer(self.get_package_names(), text)

    def do_system_installpackage(self, args):
        args = self.parse_arguments(args)

        if len(args) < 2:
            self.help_system_installpackage()
            return

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()

            # remove 'ssm' from the argument list
            args.pop(0)
        else:
            systems = self.expand_systems(args.pop(0))

        packages_to_install = args

        jobs = []
        for system in sorted(systems):
            system_id = self.get_system_id(system)
            if not system_id: return

            avail_packages = self.client.system.listLatestInstallablePackages(\
                                 self.session, system_id)

            # find the corresponding package IDs
            package_ids = []
            for package_to_install in packages_to_install:
                found_package = False
                installed_packages = []

                for p in avail_packages:
                    if package_to_install == p.get('name'):
                        found_package = True
                        package_ids.append(p.get('id'))
                        break

                if not found_package:
                    if not len(installed_packages):
                        installed_packages = \
                            self.client.system.listPackages(self.session,
                                                            system_id)

                    for p in installed_packages:
                        if package_to_install == p.get('name'):
                            logging.warning('%s already has %s installed' %(
                                            system, package_to_install))
                            break
                    else:
                        logging.warning("%s doesn't have access to %s" %(
                                        system, package_to_install))

            if len(package_ids):
                jobs.append((system, system_id, package_ids))

        if not len(jobs): return

        count = 0
        for job in jobs:
            (system, system_id, package_ids) = job

            if count: print
            count += 1

            print 'System: %s' % system
            print 'Install Packages:'
            for id in package_ids:
                package = self.client.packages.getDetails(self.session, id)
                print self.build_package_names(package)

        if not self.user_confirm(): return

        scheduled = 0
        for job in jobs:
            (system, system_id, package_ids) = job

            time = self.parse_time_input('now')

            try:
                id = self.client.system.schedulePackageInstall(self.session,
                                                               system_id,
                                                               package_ids,
                                                               time)

                logging.info('Action ID: %i' % id)
                scheduled += 1
            except:
                logging.error('Failed to schedule %s' % system)

        print 'Scheduled %i system(s)' % scheduled

####################

    def help_system_removepackage(self):
        print 'system_removepackage: Remove a package from a system'
        print 'usage: system_removepackage <SYSTEMS> <PACKAGE ...>'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_removepackage(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_complete_systems(text)
        elif len(parts) > 2:
            return self.tab_completer(self.get_package_names(), text)

    def do_system_removepackage(self, args):
        args = self.parse_arguments(args)

        if len(args) < 2:
            self.help_system_removepackage()
            return

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()

            # remove 'ssm' from the argument list
            args.pop(0)
        else:
            systems = self.expand_systems(args.pop(0))

        package_list = args


        # make sure this is cached so we can get the package IDs
        self.generate_package_cache()

        # get all matching package names
        matching_packages = \
            self.filter_results(self.all_package_longnames, package_list)

        jobs = {}
        packages_by_id = {}
        for package in matching_packages:
            logging.debug('Finding systems with %s' % package)

            package_id = self.all_package_longnames[package]

            # keep a list of id:name pairs to print later
            if package_id not in packages_by_id:
                packages_by_id[package_id] = package

            installed_systems = \
                self.client.system.listSystemsWithPackage(self.session, 
                                                          package_id)
           
            for s in installed_systems:
                # don't remove from systems we didn't select
                if s.get('name') not in systems: continue

                name = s.get('name')
                if name not in jobs:
                    jobs[name] = []

                jobs[name].append(package_id)

        spacer = False
        for system in jobs:
            if spacer: print

            print '%s:' % system
            for package in jobs[system]:
                print packages_by_id[package]

            spacer = True
   
        if not len(jobs): return 
        if not self.user_confirm('Remove these packages [y/N]:'): return

        time = self.parse_time_input('now')

        scheduled = 0
        for system in jobs:
            system_id = self.get_system_id(system)
            if not system_id: continue

            try:
                id = self.client.system.schedulePackageRemove(self.session,
                                                              system_id,
                                                              jobs[system],
                                                              time)

                logging.info('Action ID: %i' % id)
                scheduled += 1
            except:
                logging.error('Failed to schedule %s' % system)

        print 'Scheduled %i system(s)' % scheduled

####################

    def help_system_upgradepackage(self):
        print 'system_upgradepackage: Upgrade a package on a system'
        print 'usage: system_upgradepackage <SYSTEMS> <PACKAGE ...>|*'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_upgradepackage(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_complete_systems(text)
        elif len(parts) > 2:
            return self.tab_completer(self.get_package_names(), text)

    def do_system_upgradepackage(self, args):
        args = self.parse_arguments(args)

        if len(args) < 2:
            self.help_system_upgradepackage()
            return

        # install and upgrade for individual packages are the same
        if not '.*' in args[1:]:
            return self.do_system_installpackage(' '.join(args))

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()

            # remove 'ssm' from the argument list
            args.pop(0)
        else:
            systems = self.expand_systems(args.pop(0))

        jobs = []
        for system in sorted(systems):
            system_id = self.get_system_id(system)
            if not system_id: return

            packages = \
                self.client.system.listLatestUpgradablePackages(self.session,
                                                                system_id)

            if len(packages):
                package_ids = [p.get('to_package_id') for p in packages]
                jobs.append( (system, system_id, package_ids) )
            else:
                logging.warning('No upgrades available for %s' % system)

        if len(jobs):
            self.do_system_listupgrades(' '.join(systems))
            if not self.user_confirm(): return
        else:
            return

        scheduled = 0
        time = self.parse_time_input('now')
        for job in jobs:
            (system, system_id, package_ids) = job

            try:
                id = self.client.system.schedulePackageInstall(self.session,
                                                               system_id,
                                                               package_ids,
                                                               time)
            
                logging.info('Action ID: %i' % id)
                scheduled += 1
            except:
                logging.error('Failed to schedule %s' % system)

        print 'Scheduled %i system(s)' % scheduled

####################

    def help_system_listupgrades(self):
        print 'system_listupgrades: List the available upgrades for a system'
        print 'usage: system_listupgrades <SYSTEMS>'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_listupgrades(self, text, line, begidx, endidx):
        return self.tab_complete_systems(text)

    def do_system_listupgrades(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_listupgrades()
            return

        add_separator = False

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)

        for system in sorted(systems):
            system_id = self.get_system_id(system)
            if not system_id: return

            packages = \
                self.client.system.listLatestUpgradablePackages(self.session,
                                                                system_id)

            if add_separator: print self.SEPARATOR
            add_separator = True

            if len(systems) > 1:
                print 'System: %s' % system
                print

            count = 0
            for package in sorted(packages, key=itemgetter('name')):
                if count > 0: print
                count += 1

                old = {'name'    : package.get('name'),
                       'version' : package.get('from_version'),
                       'release' : package.get('from_release'),
                       'epoch'   : package.get('from_epoch')}

                new = {'name'    : package.get('name'),
                       'version' : package.get('to_version'),
                       'release' : package.get('to_release'),
                       'epoch'   : package.get('to_epoch')}

                print 'From: %s' % self.build_package_names(old)
                print 'To:   %s' % self.build_package_names(new)

####################

    def help_system_listinstalledpackages(self):
        print 'system_listinstalledpackages: List the installed packages on a'
        print '                              system'
        print 'usage: system_listinstalledpackages <SYSTEMS>'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_listinstalledpackages(self, text, line, begidx, endidx):
        return self.tab_complete_systems(text)

    def do_system_listinstalledpackages(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_listinstalledpackages()
            return

        add_separator = False

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)

        for system in sorted(systems):
            system_id = self.get_system_id(system)
            if not system_id: return

            packages = self.client.system.listPackages(self.session,
                                                       system_id)

            if add_separator: print self.SEPARATOR
            add_separator = True

            if len(systems) > 1:
                print 'System: %s' % system
                print

            print '\n'.join(self.build_package_names(packages))

####################

    def help_system_listconfigchannels(self):
        print 'system_listconfigchannels: List the config channels of a system'
        print 'usage: system_listconfigchannels <SYSTEMS>'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_listconfigchannels(self, text, line, begidx, endidx):
        return self.tab_complete_systems(text)

    def do_system_listconfigchannels(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_listconfigchannels()
            return

        add_separator = False

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)

        for system in sorted(systems):
            system_id = self.get_system_id(system)
            if not system_id: return

            if add_separator: print self.SEPARATOR
            add_separator = True

            if len(systems) > 1:
                print 'System: %s' % system

            try:
                channels = self.client.system.config.listChannels(self.session,
                                                                  system_id)
            except:
                logging.warning('%s does not support configuration channels' % \
                                system)
                continue

            print '\n'.join([ c.get('label') for c in channels ])

####################

    def help_system_addconfigchannels(self):
        print 'system_addconfigchannels: Add config channels to a system'
        print 'usage: system_addconfigchannels <SYSTEMS> <CHANNEL ...>'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_addconfigchannels(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_complete_systems(text)
        elif len(parts) > 2:
            return self.tab_completer(self.do_configchannel_list('', True), 
                                      text)

    def do_system_addconfigchannels(self, args):
        args = self.parse_arguments(args)

        if len(args) < 2:
            self.help_system_addconfigchannels()
            return

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
            args.pop(0)
        else:
            systems = self.expand_systems(args.pop(0))

        channels = args

        answer = self.prompt_user('Add to top or bottom? [T/b]:')
        if re.match('b', answer, re.I):
            location = False
        else:
            location = True

        system_ids = [ self.get_system_id(s) for s in systems ] 

        self.client.system.config.addChannels(self.session, 
                                              system_ids, 
                                              channels, 
                                              location)

####################

    def help_system_removeconfigchannels(self):
        print 'system_removeconfigchannels: Remove config channels from a ' \
              'system'
        print 'usage: system_removeconfigchannels <SYSTEMS> <CHANNEL ...>'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_removeconfigchannels(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_complete_systems(text)
        elif len(parts) > 2:
            return self.tab_completer(self.do_configchannel_list('', True), 
                                      text)

    def do_system_removeconfigchannels(self, args):
        args = self.parse_arguments(args)

        if len(args) < 2:
            self.help_system_removeconfigchannels()
            return

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args.pop(0))
        
        channels = args
        
        system_ids = [ self.get_system_id(s) for s in systems ] 

        self.client.system.config.removeChannels(self.session, 
                                                 system_ids, 
                                                 channels)

####################

    def help_system_setconfigchannelorder(self):
        print 'system_setconfigchannelorder: Set the ranked order of ' \
              'configuration channels'
        print 'usage: system_setconfigchannelorder <SYSTEMS>'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_setconfigchannelorder(self, text, line, begidx, endidx):
        return self.tab_complete_systems(text)

    def do_system_setconfigchannelorder(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_setconfigchannelorder()
            return

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args.pop(0))

        # get the current configuration channels from the first system
        # in the list
        id = self.get_system_id(systems[0])
        new_channels = self.client.system.config.listChannels(self.session, id)
        new_channels = [ c.get('label') for c in new_channels ]

        # call an interface for the user to make selections
        new_channels = self.config_channel_order(new_channels)

        print
        print 'New Configuration Channels:'
        for i in range(len(new_channels)):
            print '[%i] %s' % (i + 1, new_channels[i])

        if not self.user_confirm(): return        

        system_ids = [ self.get_system_id(s) for s in systems ] 
        
        self.client.system.config.setChannels(self.session, 
                                              system_ids, 
                                              new_channels)

####################

    def help_system_deployconfigfiles(self):
        print 'system_deployconfigfiles: Deploy all configuration files for ' \
              'a system'
        print 'usage: system_deployconfigfiles <SYSTEMS>'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_deployconfigfiles(self, text, line, begidx, endidx):
        return self.tab_complete_systems(text)

    def do_system_deployconfigfiles(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_deployconfigfiles()
            return

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)
        
        system_ids = [ self.get_system_id(s) for s in systems ] 
            
        time = self.parse_time_input('now')

        self.client.system.config.deployAll(self.session, 
                                            system_ids, 
                                            time)

####################

    def help_system_delete(self):
        print 'system_delete: Delete a system profile'
        print 'usage: system_delete <SYSTEMS>'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_delete(self, text, line, begidx, endidx):
        return self.tab_complete_systems(text)

    def do_system_delete(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_delete()
            return

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)

        system_ids = []
        for system in sorted(systems):
            system_id = self.get_system_id(system)
            if not system_id: return

            system_ids.append(system_id)

        # provide a summary to the user
        self.do_system_details('', True)

        if not self.user_confirm('Delete these systems [y/N]:'):
            return

        self.client.system.deleteSystems(self.session, system_ids)

        logging.info('Deleted %s system(s)', str(len(system_ids)))

        # regenerate the system name cache
        self.generate_system_cache(True)

        # remove these systems from the SSM
        for s in systems:
            if s in self.ssm:
                self.ssm.remove(s)

####################

    def help_system_lock(self):
        print 'system_lock: Lock a system'
        print 'usage: system_lock <SYSTEMS>'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_lock(self, text, line, begidx, endidx):
        return self.tab_complete_systems(text)

    def do_system_lock(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_lock()
            return

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)

        for system in sorted(systems):
            system_id = self.get_system_id(system)
            if not system_id: continue

            self.client.system.setLockStatus(self.session, system_id, True)

####################

    def help_system_unlock(self):
        print 'system_unlock: Unlock a system'
        print 'usage: system_unlock <SYSTEMS>'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_unlock(self, text, line, begidx, endidx):
        return self.tab_complete_systems(text)

    def do_system_unlock(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_unlock()
            return

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)

        for system in sorted(systems):
            system_id = self.get_system_id(system)
            if not system_id: continue

            self.client.system.setLockStatus(self.session, system_id, False)

####################

    def help_system_rename(self):
        print 'system_rename: Rename a system profile'
        print 'usage: system_rename OLDNAME NEWNAME'

    def complete_system_rename(self, text, line, begidx, endidx):
        if len(line.split(' ')) == 2:
            return self.tab_completer(self.get_system_names(), text)

    def do_system_rename(self, args):
        args = self.parse_arguments(args)

        if len(args) != 2:
            self.help_system_rename()
            return

        (old_name, new_name) = args

        system_id = self.get_system_id(old_name)
        if not system_id: return

        print '%s (%s) -> %s' % (old_name, system_id, new_name)
        if not self.user_confirm(): return

        self.client.system.setProfileName(self.session,
                                          system_id,
                                          new_name)

        # regenerate the cache of systems
        self.generate_system_cache(True)

        # update the SSM
        if old_name in self.ssm:
            self.ssm.remove(old_name)
            self.ssm.append(new_name)

####################

    def help_system_listcustomvalues(self):
        print 'system_listcustomvalues: List the custom values for a system'
        print 'usage: system_listcustomvalues <SYSTEMS>'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_listcustomvalues(self, text, line, begidx, endidx):
        return self.tab_complete_systems(text)

    def do_system_listcustomvalues(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_listcustomvalues()
            return

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)

        add_separator = False

        for system in systems:
            if add_separator: print self.SEPARATOR
            add_separator = True

            if len(systems) > 1:
                print 'System: %s' % system
                print

            system_id = self.get_system_id(system)
            if not system_id: continue

            values = self.client.system.getCustomValues(self.session,
                                                        system_id)

            for v in values:
                print '%s = %s' % (v, values[v])

####################

    def help_system_addcustomvalue(self):
        print 'system_addcustomvalue: Set a custom value for a system'
        print 'usage: system_addcustomvalue <SYSTEMS> KEY VALUE'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_addcustomvalue(self, text, line, begidx, endidx):
        if len(line.split(' ')) == 2:
            return self.tab_complete_systems(text)
        elif len(line.split(' ')) == 3:
            return self.tab_completer(self.do_custominfo_listkeys('', True), 
                                      text)

    def do_system_addcustomvalue(self, args):
        args = self.parse_arguments(args)

        if len(args) < 3:
            self.help_system_addcustomvalue()
            return

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)
   
        key   = args[1]
        value = ' '.join(args[2:])

        for system in systems:
            system_id = self.get_system_id(system)
            if not system_id: continue

            self.client.system.setCustomValues(self.session,
                                               system_id,
                                               {key : value})

####################

    def help_system_updatecustomvalue(self):
        print 'system_updatecustomvalue: Update a custom value for a system'
        print 'usage: system_updatecustomvalue <SYSTEMS> KEY VALUE'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_updatecustomvalue(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_complete_systems(text)
        elif len(parts) == 3:
            return self.tab_completer(self.do_custominfo_listkeys('', True), 
                                      text)

    def do_system_updatecustomvalue(self, args):
        args = self.parse_arguments(args)

        if len(args) < 3:
            self.help_system_updatecustomvalue()
            return

        return self.do_system_addcustomvalue(' '.join(args))

####################

    def help_system_removecustomvalues(self):
        print 'system_removecustomvalues: Remove a custom value for a system'
        print 'usage: system_removecustomvalues <SYSTEMS> <KEY ...>'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_removecustomvalues(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_complete_systems(text)
        elif len(parts) == 3:
            return self.tab_completer(self.do_custominfo_listkeys('', True), 
                                      text)

    def do_system_removecustomvalues(self, args):
        args = self.parse_arguments(args)

        if len(args) < 2:
            self.help_system_removecustomvalues()
            return

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)
   
        keys = args[1:]

        if not self.user_confirm('Delete these values [y/N]:'): return

        for system in systems:
            system_id = self.get_system_id(system)
            if not system_id: continue

            self.client.system.deleteCustomValues(self.session,
                                                  system_id,
                                                  keys)

####################

    def help_system_setbasechannel(self):
        print "system_setbasechannel: Set a system's base software channel"
        print 'usage: system_setbasechannel <SYSTEMS> CHANNEL'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_setbasechannel(self, text, line, begidx, endidx):
        if len(line.split(' ')) == 2:
            return self.tab_complete_systems(text)
        elif len(line.split(' ')) == 3:
            system = line.split(' ')[1]
            return self.tab_completer(self.list_base_channels(), text)

    def do_system_setbasechannel(self, args):
        args = self.parse_arguments(args)

        if len(args) != 2:
            self.help_system_setbasechannel()
            return

        new_channel = args.pop()

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)
    
        add_separator = False

        for system in systems:
            system_id = self.get_system_id(system)
            if not system_id: continue

            old = self.client.system.getSubscribedBaseChannel(self.session,
                                                              system_id)

            if add_separator: print self.SEPARATOR
            add_separator = True

            print 'System:           %s' % system
            print 'Old Base Channel: %s' % old.get('label')
            print 'New Base Channel: %s' % new_channel
             
        if not self.user_confirm(): return

        for system in systems:
            system_id = self.get_system_id(system)
            if not system_id: continue

            self.client.system.setBaseChannel(self.session,
                                              system_id,
                                              new_channel)

####################

    def help_system_listbasechannel(self):
        print 'system_listbasechannel: List the base channel for a system'
        print 'usage: system_listbasechannel <SYSTEMS>'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_listbasechannel(self, text, line, begidx, endidx):
        return self.tab_complete_systems(text)

    def do_system_listbasechannel(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_listbasechannel()
            return

        add_separator = False

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)

        for system in sorted(systems):
            system_id = self.get_system_id(system)
            if not system_id: return

            if add_separator: print self.SEPARATOR
            add_separator = True

            if len(systems) > 1:
                print 'System: %s' % system

            channel = \
                self.client.system.getSubscribedBaseChannel(self.session,
                                                            system_id)

            print channel.get('label')

####################

    def help_system_listchildchannels(self):
        print 'system_listchildchannels: List the child channels for a system'
        print 'usage: system_listchildchannels <SYSTEMS>'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_listchildchannels(self, text, line, begidx, endidx):
        return self.tab_complete_systems(text)

    def do_system_listchildchannels(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_listchildchannels()
            return

        add_separator = False

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)

        for system in sorted(systems):
            system_id = self.get_system_id(system)
            if not system_id: return

            if add_separator: print self.SEPARATOR
            add_separator = True

            if len(systems) > 1:
                print 'System: %s' % system

            channels = \
                self.client.system.listSubscribedChildChannels(self.session,
                                                               system_id)

            print '\n'.join(sorted([ c.get('label') for c in channels ]))

####################

    def help_system_addchildchannel(self):
        print "system_addchildchannel: Add a child channel to a system"
        print 'usage: system_addchildchannel <SYSTEMS> CHANNEL'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_addchildchannel(self, text, line, begidx, endidx):
        if len(line.split(' ')) == 2:
            return self.tab_complete_systems(text)
        elif len(line.split(' ')) == 3:
            system = line.split(' ')[1]
            return self.tab_completer(self.list_child_channels(system), text)

    def do_system_addchildchannel(self, args):
        self.manipulate_child_channels(args)

####################

    def help_system_removechildchannel(self):
        print "system_removechildchannel: Remove a child channel from a system"
        print 'usage: system_removechildchannel <SYSTEMS> CHANNEL'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_removechildchannel(self, text, line, begidx, endidx):
        if len(line.split(' ')) == 2:
            return self.tab_complete_systems(text)
        elif len(line.split(' ')) == 3:
            system = line.split(' ')[1]
            return self.tab_completer(self.list_child_channels(system, True), 
                                      text)

    def do_system_removechildchannel(self, args):
        self.manipulate_child_channels(args, True)

####################

    def help_system_details(self):
        print 'system_details: Show the details of a system profile'
        print 'usage: system_details <SYSTEMS>'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_details(self, text, line, begidx, endidx):
        return self.tab_complete_systems(text)

    def do_system_details(self, args, short=False):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_details()
            return

        add_separator = False

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)

        for system in sorted(systems):
            system_id = self.get_system_id(system)
            if not system_id: return

            last_checkin = \
                self.client.system.getName(self.session,
                                           system_id).get('last_checkin')

            details = self.client.system.getDetails(self.session, system_id)

            registered = self.client.system.getRegistrationDate(self.session,
                                                                system_id)

            if add_separator: print self.SEPARATOR
            add_separator = True

            print 'Name:          %s' % system
            print 'System ID:     %s' % str(system_id)
            print 'Locked:        %s' % str(details.get('lock_status'))
            print 'Registered:    %s' % self.format_time(registered.value)
            print 'Last Checkin:  %s' % self.format_time(last_checkin.value)
            print 'OSA Status:    %s' % details.get('osa_status')

            # only print basic information if requested
            if short: continue

            network = self.client.system.getNetwork(self.session, system_id)

            entitlements = self.client.system.getEntitlements(self.session,
                                                              system_id)

            base_channel = \
                self.client.system.getSubscribedBaseChannel(self.session,
                                                            system_id)

            child_channels = \
                self.client.system.listSubscribedChildChannels(self.session,
                                                               system_id)

            groups = self.client.system.listGroups(self.session,
                                                   system_id)

            kernel = self.client.system.getRunningKernel(self.session,
                                                         system_id)

            keys = self.client.system.listActivationKeys(self.session,
                                                         system_id)

            ranked_config_channels = []
            if 'provisioning_entitled' in entitlements:
                config_channels = \
                    self.client.system.config.listChannels(self.session,
                                                           system_id)

                for channel in config_channels:
                    ranked_config_channels.append(channel.get('label'))

            print
            print 'Hostname:      %s' % network.get('hostname')
            print 'IP Address:    %s' % network.get('ip')
            print 'Kernel:        %s' % kernel

            if len(keys):
                print
                print 'Activation Keys:'
                for key in keys:
                    print '  %s' % key

            print
            print 'Software Channels:'
            print '  %s' % base_channel.get('label')

            for channel in child_channels:
                print '    |-- %s' % channel.get('label')

            if len(ranked_config_channels):
                print
                print 'Configuration Channels:'
                for channel in ranked_config_channels:
                    print '  %s' % channel

            print
            print 'Entitlements:'
            for entitlement in sorted(entitlements):
                print '  %s' % entitlement

            if len(groups):
                print
                print 'System Groups:'
                for group in groups:
                    if group.get('subscribed') == 1:
                        print '  %s' % group.get('system_group_name')

####################

    def help_system_listerrata(self):
        print 'system_listerrata: List available errata for a system'
        print 'usage: system_listerrata <SYSTEMS>'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_listerrata(self, text, line, begidx, endidx):
        return self.tab_complete_systems(text)

    def do_system_listerrata(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_listerrata()
            return

        add_separator = False

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)

        for system in sorted(systems):
            system_id = self.get_system_id(system)
            if not system_id: return

            if add_separator: print self.SEPARATOR
            add_separator = True

            if len(systems) > 1:
                print 'System: %s' % system
                print

            errata = self.client.system.getRelevantErrata(self.session,
                                                          system_id)

            self.print_errata_list(errata)

####################

    def help_system_applyerrata(self):
        print 'system_applyerrata: Apply errata to a system'
        print 'usage: system_applyerrata <SYSTEMS> [ERRATA|search:XXX ...]'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_applyerrata(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_complete_systems(text)
        elif len(parts) > 2:
            self.generate_errata_cache()
            return self.tab_completer(self.all_errata.keys(), text)

    def do_system_applyerrata(self, args):
        args = self.parse_arguments(args)

        if len(args) < 2:
            self.help_system_applyerrata()
            return

        # use the systems applyed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
            args.pop(0)
        else:
            systems = self.expand_systems(args.pop(0))

        errata_list = []
        for a in args:
            if re.match('search:', a):
                a = re.sub('search:', '', a)
                errata_list.extend(self.do_errata_search(a, True))
            else:
                errata_list.append(a)

        self.generate_errata_cache()
        errata_list = self.filter_results(self.all_errata, errata_list)

        errata_ids = []
        errata_found = []
        errata_to_remove = []
        for system in systems:
            if len(errata_found) == len(errata_list): break

            system_id = self.get_system_id(system)
            if not system_id: continue

            avail = self.client.system.getRelevantErrata(self.session,
                                                         system_id)

            # XXX: bugzilla 600691
            # there is not an API call to get the ID of an errata
            # based on the name, so we do it in a round-about way
            for errata in errata_list:
                if errata in errata_found: continue

                logging.debug('Checking %s for %s' % (system, errata))
                errata_id = ''

                for e in avail:
                    if re.match(errata, e.get('advisory_name'), re.I):
                        errata_id = e.get('id')
                        errata_found.append(errata)
                        errata_ids.append(errata_id)
                        break
           
        for errata in errata_list:
            if errata not in errata_found:
                logging.warning('Could not find ID for %s' % errata)
                errata_list.remove(errata)

        if len(errata_list): 
            print 'Systems:'
            for s in sorted(systems):
                print '  %s' % s

            print
            print 'Errata:'
            for e in sorted(errata_list, reverse = True):
                print '  %s' % e
        else:
            logging.warning('No errata to apply')
            return

        if not self.user_confirm('Apply these errata [y/N]:'): return

        for system in sorted(systems):
            system_id = self.get_system_id(system)
            if not system_id: return
            
            time = self.parse_time_input('now')

            for errata in errata_ids:
                try:
                    self.client.system.scheduleApplyErrata(self.session,
                                                           system_id,
                                                           [errata],
                                                           time)
                except:
                    logging.warning('Failed to schedule %s' % system)

####################

    def help_system_createpackageprofile(self):
        print 'system_createpackageprofile: Create a profile of ' + \
              'the packages installed on this system'
        print 'usage: system_createpackageprofile SYSTEM PROFILENAME'

    def complete_system_createpackageprofile(self, text, line, begidx, endidx):
        return self.tab_completer(self.get_system_names(), text)

    def do_system_createpackageprofile(self, args):
        args = self.parse_arguments(args)

        if len(args) < 2:
            self.help_system_createpackageprofile()
            return

        system = args[0]
        label = ' '.join(args[1:])
        
        description = self.prompt_user('Description:')

        system_id = self.get_system_id(system)
        if not system_id: return

        self.client.system.createPackageProfile(self.session, 
                                                system_id, 
                                                label,
                                                description)

####################

    def help_system_listevents(self):
        print 'system_listevents: List the event history for a system'
        print 'usage: system_listevents <SYSTEMS> [LIMIT]'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_listevents(self, text, line, begidx, endidx):
        return self.tab_complete_systems(text)

    def do_system_listevents(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_listevents()
            return

        # allow a limit to be passed as the last argument so that only
        # that number of events is listed
        limit = 0
        if len(args) > 1:
            try:
                limit = int(args[len(args) - 1])
                args.pop()
            except:
                pass

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)
        
        add_separator = False

        for system in sorted(systems):
            system_id = self.get_system_id(system)
            if not system_id: return

            if add_separator: print self.SEPARATOR
            add_separator = True

            if len(systems) > 1:
                print 'System: %s' % system

            events = self.client.system.getEventHistory(self.session,
                                                        system_id)
            count = 0
            for e in events:
                print
                print 'Summary:   %s' % e.get('summary')
                print 'Completed: %s' % self.format_time(e.get('completed').value)

                if e.get('details'):
                    print 'Details:'
                    print e.get('details')

                if limit:
                    count += 1
                    if count >= limit: break

####################

    def help_system_listentitlements(self):
        print 'system_listentitlements: List the entitlements for a system'
        print 'usage: system_listentitlements <SYSTEMS>'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_listentitlements(self, text, line, begidx, endidx):
        return self.tab_complete_systems(text)

    def do_system_listentitlements(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_listentitlements()
            return

        add_separator = False

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)

        for system in sorted(systems):
            system_id = self.get_system_id(system)
            if not system_id: return

            if add_separator: print self.SEPARATOR
            add_separator = True

            if len(systems) > 1:
                print 'System: %s' % system

            entitlements = self.client.system.getEntitlements(self.session,
                                                              system_id)

            print '\n'.join(sorted(entitlements))

####################

    def help_system_addentitlements(self):
        print 'system_addentitlements: Add entitlements to a system'
        print 'usage: system_addentitlements <SYSTEMS> ENTITLEMENT'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_addentitlements(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_complete_systems(text)
        else:
            return self.tab_completer(self.ENTITLEMENTS, text)

    def do_system_addentitlements(self, args):
        args = self.parse_arguments(args)

        if len(args) < 2:
            self.help_system_addentitlements()
            return

        entitlement = args.pop()

        for e in self.ENTITLEMENTS:
            if re.match(entitlement, e, re.I):
                entitlement = e
                break
       
        # use the systems applyed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)

        for system in systems: 
            system_id = self.get_system_id(system)
            if not system_id: continue

            self.client.system.addEntitlements(self.session, 
                                               system_id,
                                               [entitlement])

####################

    def help_system_removeentitlement(self):
        print 'system_removeentitlement: Remove an entitlement from a system'
        print 'usage: system_removeentitlement <SYSTEMS> ENTITLEMENT'
        print
        print self.HELP_SYSTEM_OPTS

    def complete_system_removeentitlement(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_complete_systems(text)
        else:
            return self.tab_completer(self.ENTITLEMENTS, text)

    def do_system_removeentitlement(self, args):
        args = self.parse_arguments(args)

        if len(args) < 2:
            self.help_system_removeentitlement()
            return

        entitlement = args.pop()

        for e in self.ENTITLEMENTS:
            if re.match(entitlement, e, re.I):
                entitlement = e
                break
       
        # use the systems applyed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm.keys()
        else:
            systems = self.expand_systems(args)

        for system in systems: 
            system_id = self.get_system_id(system)
            if not system_id: continue

            self.client.system.removeEntitlements(self.session, 
                                                  system_id,
                                                  [entitlement])

####################

    def help_user_create(self):
        print 'user_create: Create a new user'
        print 'usage: user_create'

    def do_user_create(self, args):
        username = self.prompt_user('Username:', noblank = True)
        first_name = self.prompt_user('First Name:', noblank = True)
        last_name = self.prompt_user('Last Name:', noblank = True)
        email = self.prompt_user('Email Address:', noblank = True)

        password = ''
        while password == '':
            password1 = getpass('Password: ')
            password2 = getpass('Repeat Password: ')

            if password1 != password2:
                logging.warning('Passwords do not match')
            else:
                password = password1

        self.client.user.create(self.session,
                                username,
                                password,
                                first_name,
                                last_name,
                                email)

####################

    def help_user_update(self):
        print "user_update: Update a user's details"
        print 'usage: user_update USER'

    def complete_user_update(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_user_list('', True), text)

    def do_user_update(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_user_update()
            return

        user = args[0]

        details = self.client.user.getDetails(self.session, user)

        new_details = {}

        new_details['first_name'] = \
            self.prompt_user('First Name [%s]:' % details.get('first_name'))

        if new_details['first_name'] == '':
            new_details['first_name'] = details.get('first_name')

        new_details['last_name'] = \
            self.prompt_user('Last Name [%s]:' % details.get('last_name'))
        
        if new_details['last_name'] == '':
            new_details['last_name'] = details.get('last_name')

        new_details['email'] = \
            self.prompt_user('Email Address [%s]:' % details.get('email'))
        
        if new_details['email'] == '':
            new_details['email'] = details.get('email')

        # prefixes are retarded
        new_details['prefix'] = 'Dr.'        

        # the password must be updated
        new_details['password'] = ''
        while new_details['password'] == '':
            password1 = getpass('Password [blank to leave the same]: ')

            # don't force a password change
            if password1 == '':
                del new_details['password']
                break
            
            password2 = getpass('Repeat Password: ')

            if password1 != password2:
                logging.warning('Passwords do not match')
            else:
                new_details['password'] = password1

        self.client.user.setDetails(self.session, user, new_details)

####################

    def help_user_delete(self):
        print 'user_delete: Delete a user'
        print 'usage: user_delete NAME'

    def complete_user_delete(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_user_list('', True), text)

    def do_user_delete(self, args):
        args = self.parse_arguments(args)

        if len(args) != 1:
            self.help_user_delete()
            return

        name = args[0]

        if self.user_confirm('Delete this user [y/N]:'):
            self.client.user.delete(self.session, name)

####################

    def help_user_disable(self):
        print 'user_disable: Disable an user account'
        print 'usage: user_disable NAME'

    def complete_user_disable(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_user_list('', True), text)

    def do_user_disable(self, args):
        args = self.parse_arguments(args)

        if len(args) != 1:
            self.help_user_disable()
            return

        name = args[0]

        self.client.user.disable(self.session, name)

####################

    def help_user_enable(self):
        print 'user_enable: Enable an user account'
        print 'usage: user_enable NAME'

    def complete_user_enable(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_user_list('', True), text)

    def do_user_enable(self, args):
        args = self.parse_arguments(args)

        if len(args) != 1:
            self.help_user_enable()
            return

        name = args[0]

        self.client.user.enable(self.session, name)

####################

    def help_user_list(self):
        print 'user_list: List all users'
        print 'usage: user_list'

    def do_user_list(self, args, doreturn=False):
        users = self.client.user.listUsers(self.session)
        users = [u.get('login') for u in users]

        if doreturn:
            return users
        else:
            if len(users):
                print '\n'.join(sorted(users))

####################

    def help_user_listavailableroles(self):
        print 'user_list: List all available roles for users'
        print 'usage: user_listavailableroles'

    def do_user_listavailableroles(self, args, doreturn=False):
        roles = self.client.user.listAssignableRoles(self.session)

        if doreturn:
            return roles
        else:
            if len(roles):
                print '\n'.join(sorted(roles))

####################

    def help_user_addrole(self):
        print 'user_addrole: Add a role to an user account'
        print 'usage: user_addrole USER ROLE'

    def complete_user_addrole(self, text, line, begidx, endidx):
        parts = line.split(' ')
        
        if len(parts) == 2:
            return self.tab_completer(self.do_user_list('', True), text)
        elif len(parts) == 3:
            return self.tab_completer(self.do_user_listavailableroles('', True), 
                                      text)

    def do_user_addrole(self, args):
        args = self.parse_arguments(args)

        if len(args) != 2:
            self.help_user_addrole()
            return

        user = args[0]
        role = args[1]

        self.client.user.addRole(self.session, user, role)

####################

    def help_user_removerole(self):
        print 'user_removerole: Remove a role from an user account'
        print 'usage: user_removerole USER ROLE'

    def complete_user_removerole(self, text, line, begidx, endidx):
        parts = line.split(' ')
        
        if len(parts) == 2:
            return self.tab_completer(self.do_user_list('', True), text)
        elif len(parts) == 3:
            # only list the roles currently assigned to this user
            roles = self.client.user.listRoles(self.session, parts[1])
            return self.tab_completer(roles, text)

    def do_user_removerole(self, args):
        args = self.parse_arguments(args)

        if len(args) != 2:
            self.help_user_removerole()
            return

        user = args[0]
        role = args[1]

        self.client.user.removeRole(self.session, user, role)

####################

    def help_user_details(self):
        print 'user_details: Show the details of a user'
        print 'usage: user_details USER ...'

    def complete_user_details(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_user_list('', True), text)

    def do_user_details(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_user_details()
            return

        add_separator = False

        for user in args:
            try:
                details = self.client.user.getDetails(self.session, user)

                roles = self.client.user.listRoles(self.session, user)

                groups = self.client.user.listAssignedSystemGroups(self.session, 
                                                                   user)

                default_groups = \
                    self.client.user.listDefaultSystemGroups(self.session,
                                                             user)
            except:
                logging.warning('%s is not a valid user' % user)
                logging.debug(sys.exc_info())
                continue

            org_details = self.client.org.getDetails(self.session, 
                                                     details.get('org_id'))
            organization = org_details.get('name')

            if add_separator: print self.SEPARATOR
            add_separator = True

            print 'Username:      %s' % user
            print 'First Name:    %s' % details.get('first_name')
            print 'Last Name:     %s' % details.get('last_name')
            print 'Email Address: %s' % details.get('email')
            print 'Organization:  %s' % organization
            print 'Last Login:    %s' % details.get('last_login_date')
            print 'Created:       %s' % details.get('created_date')
            print 'Enabled:       %s' % details.get('enabled')

            if len(roles):
                print
                print 'Roles:'
                print '\n'.join(sorted(roles))

            if len(groups):
                print
                print 'Assigned Groups:'
                print '\n'.join(sorted([g.get('name') for g in groups]))
            
            if len(default_groups):
                print
                print 'Default Groups:'
                print '\n'.join(sorted([g.get('name') for g in default_groups]))

####################

    def help_user_addgroup(self):
        print 'user_addgroup: Add a group to an user account'
        print 'usage: user_addgroup USER <GROUP ...>'

    def complete_user_addgroup(self, text, line, begidx, endidx):
        parts = line.split(' ')
        
        if len(parts) == 2:
            return self.tab_completer(self.do_user_list('', True), text)
        elif len(parts) > 2:
            return self.tab_completer(self.do_group_list('', True), text)

    def do_user_addgroup(self, args):
        args = self.parse_arguments(args)

        if len(args) != 2:
            self.help_user_addgroup()
            return

        user = args.pop(0)
        groups = args

        self.client.user.addAssignedSystemGroups(self.session, 
                                                 user, 
                                                 groups, 
                                                 False)

####################

    def help_user_adddefaultgroup(self):
        print 'user_adddefaultgroup: Add a default group to an user account'
        print 'usage: user_adddefaultgroup USER <GROUP ...>'

    def complete_user_adddefaultgroup(self, text, line, begidx, endidx):
        parts = line.split(' ')
        
        if len(parts) == 2:
            return self.tab_completer(self.do_user_list('', True), text)
        elif len(parts) > 2:
            return self.tab_completer(self.do_group_list('', True), text)

    def do_user_adddefaultgroup(self, args):
        args = self.parse_arguments(args)

        if len(args) != 2:
            self.help_user_adddefaultgroup()
            return

        user = args.pop(0)
        groups = args

        self.client.user.addDefaultSystemGroups(self.session, 
                                                user, 
                                                groups)

####################

    def help_user_removegroup(self):
        print 'user_removegroup: Remove a group to an user account'
        print 'usage: user_removegroup USER <GROUP ...>'

    def complete_user_removegroup(self, text, line, begidx, endidx):
        parts = line.split(' ')
        
        if len(parts) == 2:
            return self.tab_completer(self.do_user_list('', True), text)
        elif len(parts) > 2:
            # only list the groups currently assigned to this user
            groups = self.client.user.listAssignedSystemGroups(self.session, parts[1])
            return self.tab_completer([ g.get('name') for g in groups ], text)

    def do_user_removegroup(self, args):
        args = self.parse_arguments(args)

        if len(args) != 2:
            self.help_user_removegroup()
            return

        user = args.pop(0)
        groups = args

        self.client.user.removeAssignedSystemGroups(self.session, 
                                                    user, 
                                                    groups, 
                                                    True)

####################

    def help_user_removedefaultgroup(self):
        print 'user_removedefaultgroup: Remove a default group from an ' + \
              'user account'
        print 'usage: user_removedefaultgroup USER <GROUP ...>'

    def complete_user_removedefaultgroup(self, text, line, begidx, endidx):
        parts = line.split(' ')
        
        if len(parts) == 2:
            return self.tab_completer(self.do_user_list('', True), text)
        elif len(parts) > 2:
            # only list the groups currently assigned to this user
            groups = self.client.user.listDefaultSystemGroups(self.session, parts[1])
            return self.tab_completer([ g.get('name') for g in groups ], text)

    def do_user_removedefaultgroup(self, args):
        args = self.parse_arguments(args)

        if len(args) != 2:
            self.help_user_removedefaultgroup()
            return

        user = args.pop(0)
        groups = args

        self.client.user.removeDefaultSystemGroups(self.session, 
                                                   user, 
                                                   groups)

####################

    def help_whoami(self):
        print 'whoami: Print the name of the currently logged in user'
        print 'usage: whoami'

    def do_whoami(self, args):
        if len(self.username):
            print self.username
        else:
            logging.warning("You're not logged in")

####################

    def help_whoamitalkingto(self):
        print 'whoamitalkingto: Print the name of the server'
        print 'usage: whoamitalkingto'

    def do_whoamitalkingto(self, args):
        if len(self.server):
            print self.server
        else:
            logging.warning('Yourself')

####################

# vim:ts=4:expandtab:
