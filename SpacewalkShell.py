'''
Author: Aron Parsons <aron@redhat.com>
License: GPLv3+
'''

import atexit, logging, os, re, readline
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

    SEPARATOR = '\n--------------------\n'

    ENTITLEMENTS = {'provisioning_entitled'        : 'Provisioning',
                    'enterprise_entitled'          : 'Management',
                    'monitoring_entitled'          : 'Monitoring',
                    'virtualization_host'          : 'Virtualization',
                    'virtualization_host_platform' : 'Virtualization Platform'}

    EDITORS = ['vim', 'vi', 'nano', 'emacs']

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
        self.ssm = []

        # cache large lists instead of looking up every time
        self.all_package_shortnames = []
        self.all_package_fullnames = []
        self.all_systems = []

        # expiration times for internal caches
        self.system_cache_expire = datetime.now()
        self.package_cache_expire = datetime.now()

        # make the options available everywhere
        self.options = options

        userinfo = getpwuid(os.getuid())
        self.cache_file = os.path.join(userinfo[5], '.spacecmd_cache')
        self.history_file = os.path.join(userinfo[5], '.spacecmd_history')

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


    # load the history file
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

        if not self.session:
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

    def tab_completer(self, options, text):
        return [o for o in options if re.match(text, o)]


    def filter_results(self, list, patterns):
        compiled_regex = []
        for pattern in patterns:
            if pattern != '':
                compiled_regex.append(re.compile(pattern, re.I))

        matches = []
        for item in list:
            for pattern in compiled_regex:
                if pattern.match(item):
                    matches.append(item)

        return matches


    def editor(self, template):
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
        if os.environ['EDITOR']:
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

                return (contents, file_name)
            except:
                logging.error('Could not read %s' % file_name)
                logging.debug(sys.exc_info())
                return ''


    def remove_last_history_item(self):
        last = readline.get_current_history_length() - 1

        if last >= 0:
            readline.remove_history_item(last)


    def prompt_user(self, prompt):
        try:
            input = raw_input('%s ' % prompt)
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


    def clear_package_cache(self):
        self.all_package_shortnames = []
        self.all_package_fullnames = []
        self.package_cache_expire = datetime.now()


    def generate_package_cache(self, force=False):
        if not force and datetime.now() < self.package_cache_expire:
            return

        logging.debug('Regenerating internal package cache')

        channels = self.client.channel.listSoftwareChannels(self.session)
        channels = [c.get('label') for c in channels]

        for c in channels:
            packages = \
                self.client.channel.software.listLatestPackages(self.session, c)

            for p in packages:
                if not p.get('name') in self.all_package_shortnames:
                    self.all_package_shortnames.append(p.get('name'))

                fullname = self.build_package_names(p)

                if not fullname in self.all_package_fullnames:
                    self.all_package_fullnames.append(fullname)

        self.package_cache_expire = \
            datetime.now() + timedelta(seconds=self.PACKAGE_CACHE_TTL)


    # create a global list of all available package names
    def get_package_names(self, fullnames=False):
        self.generate_package_cache()

        if fullnames:
            return self.all_package_fullnames
        else:
            return self.all_package_shortnames


    def clear_system_cache(self):
        self.all_systems = []
        self.system_cache_expire = datetime.now()


    def generate_system_cache(self, force=False):
        if not force and datetime.now() < self.system_cache_expire:
            return

        logging.debug('Regenerating internal system cache')

        systems = self.client.system.listSystems(self.session)

        self.all_systems = []
        for s in systems:
            self.all_systems.append( {'id' : s.get('id'),
                                      'name' : s.get('name')})

        self.system_cache_expire = \
            datetime.now() + timedelta(seconds=self.SYSTEM_CACHE_TTL)


    def get_system_names(self):
        self.generate_system_cache()
        return [s.get('name') for s in self.all_systems]


    # check for duplicate system names and return the system ID
    def get_system_id(self, name):
        self.generate_system_cache()

        try:
            # check if we were passed a system instead of a name
            id = int(name)
            for s in self.all_systems:
                if id == s.get('id'): return id
        except:
            pass

        # get a set of matching systems to check for duplicate names
        systems = []
        for s in self.all_systems:
            if name == s.get('name'):
                systems.append(s.get('id'))

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

        return systems


    def list_base_channels(self, system):
        if re.match('ssm', system, re.I):
            if len(self.ssm):
                system = self.ssm[0]

        system_id = self.get_system_id(system)
        if not system_id: return

        channels = self.client.system.listSubscribableBaseChannels(self.session,
                                                                   system_id)

        return [c.get('label') for c in channels]   


    def list_child_channels(self, system, subscribed=False):
        if re.match('ssm', system, re.I):
            if len(self.ssm):
                system = self.ssm[0]

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
            systems = self.ssm
        else:
            systems = args
    
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
        print 'ID:         %s' % str(action.get('id'))
        print 'Type:       %s' % action.get('type')
        print 'Scheduler:  %s' % action.get('scheduler')
        print 'Start Time: %s' % re.sub('T' , ' ', action.get('earliest').value)

        if len(systems):
            print
            print 'Systems:'
            for s in systems:
                print '  %s' % s.get('server_name')

####################

    def help_activationkey_list(self):
        print 'activationkey_list: List all activation keys'
        print 'usage: activationkey_list'

    def do_activationkey_list(self, args, doreturn=False):
        keys = self.client.activationkey.listActivationKeys(self.session)
        keys = [k.get('key') for k in keys]

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

                config_channels = \
                    self.client.activationkey.listConfigChannels(self.session,
                                                                 key)
            except:
                logging.warning('%s is not a valid activation key' % key)
                logging.debug(sys.exc_info())
                return

            groups = []
            for group in details.get('server_group_ids'):
                group_details = self.client.systemgroup.getDetails(self.session,
                                                                   group)
                groups.append(group_details.get('name'))

            if add_separator:
                print self.SEPARATOR

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
            print 'Configuration Channels:'
            for channel in config_channels:
                print '  %s' % channel.get('label')

            print
            print 'Entitlements:'
            for entitlement in sorted(details.get('entitlements')):
                print '  %s' % self.ENTITLEMENTS[entitlement]

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
            if add_separator:
                print self.SEPARATOR

            add_separator = True

            print 'File:     %s' % file.get('path')
            print 'Type:     %s' % file.get('type')
            print 'Revision: %s' % str(file.get('revision'))
            print 'Created:  %s' % re.sub('T', ' ', file.get('creation').value)
            print 'Modified: %s' % re.sub('T', ' ', file.get('modified').value)

            print
            print 'Owner:    %s' % file.get('owner')
            print 'Group:    %s' % file.get('group')
            print 'Mode:     %s' % file.get('permissions_mode')

            if file.get('type') == 'file':
                print 'MD5:      %s' % file.get('md5')
                print 'Binary:   %s' % str(file.get('binary'))

                if not file.get('binary'):
                    print
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

            if add_separator:
                print self.SEPARATOR

            add_separator = True

            print 'Label:       %s' % details.get('label')
            print 'Name:        %s' % details.get('name')
            print 'Description: %s' % details.get('description')

            print
            print 'Files:'
            for file in files:
                print '  %s' % file.get('path')

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

            if add_separator:
                print self.SEPARATOR

            add_separator = True

            print 'Description: %s' % details.get('description')
            print 'Type:        %s' % details.get('type')

            print
            print details.get('content')

####################

    def help_errata_details(self):
        print 'errata_details: Show the details of an errata'
        print 'usage: errata_details NAME ...'

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

            if add_separator:
                print self.SEPARATOR

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
        print 'usage: errata_search CVE|RHSA|RHBA|RHEA ...'
        print
        print 'Example:'
        print '> errata_search CVE-2009:1674'
        print '> errata_search RHSA-2009:1674'

    def do_errata_search(self, args, doreturn=False):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_errata_search()
            return

        add_separator = False

        for query in args:
            value = query.upper()

            #XXX: Bugzilla 584855
            if re.match('CVE', query, re.I):
                # CVE- prefix is required
                if not re.match('CVE', value, re.I):
                    value = 'CVE-%s' % value

                errata = self.client.errata.findByCve(self.session, value)
            else:
                errata = self.client.errata.getDetails(self.session, value)
                logging.debug(errata.get('type'))
                errata = [ {'advisory_name'     : value,
                            'advisory_type'     : errata.get('type'),
                            'advisory_synopsis' : errata.get('synopsis'),
                            'date'              : errata.get('issue_date') } ]

            if add_separator: print self.SEPARATOR
            add_separator = True

            if len(errata):
                map(self.print_errata_summary, errata)

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
        print 'usage: group_addsystems GROUP SSM|<SYSTEM ...>'

    def complete_group_addsystems(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_group_list('', True), text)
        elif len(parts) > 2:
            return self.tab_completer(self.get_system_names(), text)

    def do_group_addsystems(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_group_addsystems()
            return

        group_name = args.pop(0)

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm
        else:
            systems = args

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
        print 'usage: group_removesystems GROUP SSM|<SYSTEM ...>'

    def complete_group_removesystems(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.do_group_list('', True), text)
        elif len(parts) > 2:
            return self.tab_completer(self.do_group_listsystems(parts[1], True),
                                                                text)

    def do_group_removesystems(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_group_removesystems()
            return

        group_name = args.pop(0)

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm
        else:
            systems = args

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
        print 'usage: group_create NAME'

    def do_group_create(self, args):
        args = self.parse_arguments(args)

        if len(args) != 1:
            self.help_group_create()
            return

        name = args[0]
        description = self.prompt_user('Description:')

        group = self.client.systemgroup.create(self.session, name, description)

        if not group:
            logging.error('Failed to create group')
            return

####################

    def help_group_delete(self):
        print 'group_delete: Delete a system group'
        print 'usage: group_create NAME ...'

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

            if add_separator:
                print self.SEPARATOR

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
                if add_separator:
                    print self.SEPARATOR

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

    def help_kickstart_listsnippets(self):
        print 'kickstart_listsnippets: List the available Kickstart snippets'
        print 'usage: kickstart_listsnippets'

    def do_kickstart_listsnippets(self, args, doreturn=False):
        snippets = self.client.kickstart.snippet.listCustom(self.session)
        snippets = [s.get('name') for s in snippets]

        if doreturn:
            return snippets
        else:
            if len(snippets):
                print '\n'.join(sorted(snippets))

####################

    def help_kickstart_snippetdetails(self):
        print 'kickstart_snippetdetails: Show the contents of a snippet'
        print 'usage: kickstart_snippetdetails SNIPPET ...'

    def complete_kickstart_snippetdetails(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_kickstart_listsnippets('', True),
                                  text)

    def do_kickstart_snippetdetails(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_kickstart_snippetdetails()
            return

        add_separator = False

        snippets = self.client.kickstart.snippet.listCustom(self.session)

        for name in args:
            for s in snippets:
                if s.get('name') == name:
                    snippet = s
                    break

            if not snippet:
                logging.warning('%s is not a valid snippet' % name)
                continue

            if add_separator:
                print self.SEPARATOR

            add_separator = True

            print 'Name:   %s' % snippet.get('name')
            print 'Macro:  %s' % snippet.get('fragment')
            print 'File:   %s' % snippet.get('file')

            print
            print snippet.get('contents')

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
        logging.debug('Connecting to %s' % (server))
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
            if os.path.isfile(self.cache_file):
                try:
                    # read the session (format = username:session)
                    sessionfile = open(self.cache_file, 'r')
                    parts = sessionfile.read().split(':')
                    sessionfile.close()

                    username = parts[0]
                    self.session = parts[1]
                except:
                    logging.error('Could not read %s' % self.cache_file)
                    logging.debug(sys.exc_info())

                try:
                    logging.info('Using cached credentials from %s' %
                                 self.cache_file)

                    self.client.user.listUsers(self.session)
                except:
                    logging.info('Cached credentials are invalid')
                    self.session = ''

                    try:
                        os.remove(self.cache_file)
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
                                  self.cache_file)
                    sessionfile = open(self.cache_file, 'w')
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

            if os.path.isfile(self.cache_file):
                try:
                    os.remove(self.cache_file)
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

        for package in args:
            if add_separator:
                print self.SEPARATOR

            add_separator = True

            try:
                id = int(package)
            except:
                id = self.client.packages.search.name(self.session,
                                                      package)[0].get('id')

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

    def do_package_search(self, args):
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
        else:
            packages = self.client.packages.search.name(self.session, args)

        if len(packages):
            print '\n'.join(self.build_package_names(packages))

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

    def help_schedule_summary(self):
        print 'schedule_summary: Show the details of a scheduled action'
        print 'usage: schedule_summary ID'

    def do_schedule_summary(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_schedule_summary()
            return

        try:
            id = int(args[0])
        except:
            logging.warning('%s is not a valid ID' % str(a))
            return

        completed = self.client.schedule.listCompletedSystems(self.session, id)
        failed = self.client.schedule.listFailedSystems(self.session, id)
        pending = self.client.schedule.listInProgressSystems(self.session, id)

        # schedule.getAction() API call would make this easier
        all_actions = self.client.schedule.listAllActions(self.session)
        action = None
        for a in all_actions:
            if a.get('id') == id:
                action = a
                del all_actions
                break

        self.print_action_summary(action)

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

        print
        print 'Completed: %s' % str(len(completed))
        print 'Failed:    %s' % str(len(failed))
        print 'Pending:   %s' % str(len(pending))

####################

    def help_schedule_getoutput(self):
        print 'schedule_getoutput: Show the output from a completed action'
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
            id = int(args[0])
        except:
            logging.error('%s is not a valid action ID' % str(a))
            return

        #XXX: Bugzilla 584869
        results = self.client.system.getScriptResults(self.session, id)

        add_separator = False
        for r in results:
            if add_separator:
                print self.SEPARATOR

            add_separator = True

            print 'System:      %s' % 'UNKNOWN'
            print 'Start Time:  %s' % re.sub('T', ' ', r.get('startDate').value)
            print 'Stop Time:   %s' % re.sub('T', ' ', r.get('stopDate').value)
            print 'Return Code: %s' % str(r.get('returnCode'))

            print
            print r.get('output')

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
                if add_separator:
                    print self.SEPARATOR

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
                if add_separator:
                    print self.SEPARATOR

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
                if add_separator:
                    print self.SEPARATOR

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
                if add_separator:
                    print self.SEPARATOR

                add_separator = True

                self.print_action_summary(actions[i])

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
        print '                          available from a software channel'
        print 'usage: softwarechannel_listpackages CHANNEL [PACKAGE ...]'

    def complete_softwarechannel_listpackages(self, text, line, begidx, endidx):
        # only tab complete the channel name
        if len(line.split(' ')) == 2:
            return self.tab_completer(self.do_softwarechannel_list('', True), text)
        else:
            return []

    def do_softwarechannel_listpackages(self, args, doreturn=False):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_softwarechannel_listpackages()
            return

        packages = self.client.channel.software.listLatestPackages(self.session,
                                                                   args[0])

        packages = self.build_package_names(packages)

        if doreturn:
            return packages
        else:
            if len(args) > 1:
                packages = self.filter_results(packages, args[1:])

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

            if add_separator:
                print self.SEPARATOR

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

            if add_separator:
                print self.SEPARATOR

            add_separator = True

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
        print 'ssm_add: Add systems to the SSM, which can then be operated'
        print '         on as a single group'
        print 'usage: ssm_add SYSTEM|group:GROUP|channel:CHANNEL|search:QUERY'

    def complete_ssm_add(self, text, line, begidx, endidx):
        if re.match('group:', text):
            # prepend 'group' to each item for tab completion
            groups = ['group:%s' % g for g in self.do_group_list('', True)]

            return self.tab_completer(groups, text)
        elif re.match('channel:', text):
            channels = ['channel:%s' % s \
                for s in self.do_softwarechannel_list('', True)]

            return self.tab_completer(channels, text)
        else:
            return self.tab_completer(self.get_system_names(), text)

    def do_ssm_add(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_ssm_add()
            return

        systems = self.expand_systems(args)
        matches = self.filter_results(self.get_system_names(), systems)

        if not len(matches):
            logging.warning('No systems found')
            return

        for match in matches:
            if match in self.ssm:
                logging.warning('%s is already in the list' % match)
                continue
            else:
                self.ssm.append(match)
                logging.info('Added %s' % match)

        if len(self.ssm):
            print 'Systems Selected: %s' % str(len(self.ssm))

####################

    def help_ssm_rm(self):
        print 'ssm_rm: Remove systems from the SSM'
        print 'usage: ssm_rm SYSTEM|group:GROUP|channel:CHANNEL|search:QUERY'

    def complete_ssm_rm(self, text, line, begidx, endidx):
        if re.match('group:', text):
            # prepend 'group' to each item for tab completion
            groups = ['group:%s' % g for g in self.do_group_list('', True)]

            return self.tab_completer(groups, text)
        elif re.match('channel:', text):
            channels = ['channel:%s' % s \
                for s in self.do_softwarechannel_list('', True)]

            return self.tab_completer(channels, text)
        else:
            return self.tab_completer(sorted(self.ssm), text)

    def do_ssm_rm(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_ssm_rm()
            return

        systems = self.expand_systems(args)
        matches = self.filter_results(self.ssm, systems)

        if not len(matches):
            logging.warning('No systems found')
            return

        for match in matches:
            # double-check for existance in case of duplicate names
            if match in self.ssm:
                logging.info('Removed %s' % match)
                self.ssm.remove(match)

        print 'Systems Selected: %s' % str(len(self.ssm))

####################

    def help_ssm_list(self):
        print 'ssm_list: List the systems currently in the SSM'
        print 'usage: ssm_list'

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
        self.ssm = []

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

    def help_system_search(self):
        print 'system_search: List systems that match the given criteria'
        print 'usage: system_search QUERY'
        print
        print 'Available Fields: id, name, ip, hostname, ' + \
              'device, vendor, driver'
        print
        print 'Examples:'
        print '> system_search vendor:vmware'
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
            self.generate_system_cache()
            results = self.all_systems
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
        print 'usage: system_runscript SSM|<SYSTEM ...>'
        print
        print 'Start Time Examples:'
        print 'now  -> right now!'
        print '15m  -> 15 minutes from now'
        print '1d   -> 1 day from now'

    def complete_system_runscript(self, text, line, begidx, endidx):
        return self.tab_completer(self.get_system_names(), text)

    def do_system_runscript(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_runscript()
            return

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm
        else:
            systems = args

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
        print 'Start Time: %s' % re.sub('T', ' ', time.value)
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
            id = self.client.system.scheduleScriptRun(self.session,
                                                      system_id,
                                                      user,
                                                      group,
                                                      timeout,
                                                      script,
                                                      time)

            logging.info('Action ID: %s' % str(id))
            scheduled += 1

        print 'Scheduled: %s system(s)' % str(scheduled)

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
        print 'usage: system_listhardware SSM|<SYSTEM ...>'

    def complete_system_listhardware(self, text, line, begidx, endidx):
        return self.tab_completer(self.get_system_names(), text)

    def do_system_listhardware(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_details()
            return

        add_separator = False

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm
        else:
            systems = args

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

            if add_separator:
                print self.SEPARATOR

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
        print 'usage: system_installpackage SSM|SYSTEM <PACKAGE ...>'

    def complete_system_installpackage(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.get_system_names(), text)
        elif len(parts) > 2:
            return self.tab_completer(self.get_package_names(), text)

    def do_system_installpackage(self, args):
        args = self.parse_arguments(args)

        if len(args) < 2:
            self.help_system_installpackage()
            return

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm

            # remove 'ssm' from the argument list
            args.pop(0)
        else:
            # only operate on one system
            systems = [args.pop(0)]

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

            status = self.client.system.schedulePackageInstall(self.session,
                                                               system_id,
                                                               package_ids,
                                                               time)

            if status:
                scheduled += 1
            else:
                logging.error('Failed to schedule %s' % system)
                continue

        print 'Scheduled %s system(s)' % str(scheduled)

####################

    def help_system_removepackage(self):
        print 'system_removepackage: Remove a package from a system'
        print 'usage: system_removepackage SSM|SYSTEM <PACKAGE ...>'

    def complete_system_removepackage(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.get_system_names(), text)
        elif len(parts) > 2:
            return self.tab_completer(self.get_package_names(), text)

    def do_system_removepackage(self, args):
        args = self.parse_arguments(args)

        if len(args) < 2:
            self.help_system_removepackage()
            return

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm

            # remove 'ssm' from the argument list
            args.pop(0)
        else:
            # only operate on one system
            systems = [args.pop(0)]

        packages_to_remove = args

        jobs = []
        for system in sorted(systems):
            system_id = self.get_system_id(system)
            if not system_id: return

            channels = \
                self.client.channel.software.listSystemChannels(self.session,
                                                                system_id)

            #XXX: system.listPackages doesn't include package ID
            #XXX: Bugzilla 584873
            installed_packages = []
            for channel in channels:
                installed_packages.extend(
                    self.client.system.listPackagesFromChannel(
                        self.session, system_id, channel.get('label')))

            # find the corresponding package IDs
            package_ids = []
            for package_to_remove in packages_to_remove:
                found_package = False

                for p in installed_packages:
                    if package_to_remove == p.get('name'):
                        found_package = True
                        package_ids.append(p.get('id'))
                        break

                if not found_package:
                    logging.warning("%s does not have %s installed" %(
                                    system, package_to_remove))

            if len(package_ids):
                jobs.append((system, system_id, package_ids))

        if not len(jobs): return

        count = 0
        for job in jobs:
            (system, system_id, package_ids) = job

            if count: print
            count += 1

            print 'System: %s' % system
            print 'Remove Packages:'
            for id in package_ids:
                package = self.client.packages.getDetails(self.session, id)
                print self.build_package_names(package)

        if not self.user_confirm(): return

        scheduled = 0
        for job in jobs:
            (system, system_id, package_ids) = job

            time = self.parse_time_input('now')

            id = self.client.system.schedulePackageRemove(self.session,
                                                          system_id,
                                                          package_ids,
                                                          time)

            if id:
                logging.debug('Action ID: %s' % str(id))
                scheduled += 1
            else:
                logging.error('Failed to schedule %s' % system)
                continue

        print 'Scheduled %s system(s)' % str(scheduled)

####################

    def help_system_upgradepackage(self):
        print 'system_upgradepackage: Upgrade a package on a system'
        print 'usage: system_upgradepackage SSM|SYSTEM <PACKAGE ...>|*'

    def complete_system_upgradepackage(self, text, line, begidx, endidx):
        parts = line.split(' ')

        if len(parts) == 2:
            return self.tab_completer(self.get_system_names(), text)
        elif len(parts) > 2:
            return self.tab_completer(self.get_package_names(), text)

    def do_system_upgradepackage(self, args):
        args = self.parse_arguments(args)

        if len(args) < 2:
            self.help_system_upgradepackage()
            return

        # install and upgrade for individual packages are the same
        if not '.*' in args[1:]:
            return self.do_system_installpackage(args)

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm

            # remove 'ssm' from the argument list
            args.pop(0)
        else:
            # only operate on one system
            systems = [args.pop(0)]

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
                args.remove(system)

        if len(jobs):
            self.do_system_listupgrades(' '.join(systems))
            if not self.user_confirm(): return
        else:
            return

        scheduled = 0
        time = self.parse_time_input('now')
        for job in jobs:
            (system, system_id, package_ids) = job

            status = self.client.system.schedulePackageInstall(self.session,
                                                               system_id,
                                                               package_ids,
                                                               time)

            if status:
                scheduled += 1
            else:
                logging.error('Failed to schedule %s' % system)
                continue

        print 'Scheduled %s system(s)' % str(scheduled)

####################

    def help_system_listupgrades(self):
        print 'system_listupgrades: List the available upgrades for a system'
        print 'usage: system_listupgrades SSM|<SYSTEM ...>'

    def complete_system_listupgrades(self, text, line, begidx, endidx):
        return self.tab_completer(self.get_system_names(), text)

    def do_system_listupgrades(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_listupgrades()
            return

        add_separator = False

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm
        else:
            systems = args

        for system in sorted(systems):
            system_id = self.get_system_id(system)
            if not system_id: return

            packages = \
                self.client.system.listLatestUpgradablePackages(self.session,
                                                                system_id)

            if add_separator:
                print self.SEPARATOR

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
        print 'usage: system_listinstalledpackages SSM|<SYSTEM ...>'

    def complete_system_listinstalledpackages(self, text, line, begidx, endidx):
        return self.tab_completer(self.get_system_names(), text)

    def do_system_listinstalledpackages(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_listinstalledpackages()
            return

        add_separator = False

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm
        else:
            systems = args

        for system in sorted(systems):
            system_id = self.get_system_id(system)
            if not system_id: return

            packages = self.client.system.listPackages(self.session,
                                                       system_id)

            if add_separator:
                print self.SEPARATOR

            add_separator = True

            if len(systems) > 1:
                print 'System: %s' % system
                print

            print '\n'.join(self.build_package_names(packages))

####################

    def help_system_delete(self):
        print 'system_delete: Delete a system profile'
        print 'usage: system_delete SSM|<SYSTEM ...>'

    def complete_system_delete(self, text, line, begidx, endidx):
        return self.tab_completer(self.get_system_names(), text)

    def do_system_delete(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_delete()
            return

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm
        else:
            systems = args

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

    def help_system_setbasechannel(self):
        print "system_setbasechannel: Set a system's base software channel"
        print 'usage: system_setbasechannel SSM|<SYSTEM ...> CHANNEL'

    def complete_system_setbasechannel(self, text, line, begidx, endidx):
        if len(line.split(' ')) == 2:
            return self.tab_completer(self.get_system_names(), text)
        elif len(line.split(' ')) == 3:
            system = line.split(' ')[1]
            return self.tab_completer(self.list_base_channels(system), text)

    def do_system_setbasechannel(self, args):
        args = self.parse_arguments(args)

        if len(args) != 2:
            self.help_system_setbasechannel()
            return

        new_channel = args.pop()

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm
        else:
            systems = args
    
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

    def help_system_addchildchannel(self):
        print "system_addchildchannel: Add a child channel to a system"
        print 'usage: system_addchildchannel SSM|<SYSTEM ...> CHANNEL'

    def complete_system_addchildchannel(self, text, line, begidx, endidx):
        if len(line.split(' ')) == 2:
            return self.tab_completer(self.get_system_names(), text)
        elif len(line.split(' ')) == 3:
            system = line.split(' ')[1]
            return self.tab_completer(self.list_child_channels(system), text)

    def do_system_addchildchannel(self, args):
        self.manipulate_child_channels(args)

####################

    def help_system_removechildchannel(self):
        print "system_removechildchannel: Remove a child channel from a system"
        print 'usage: system_removechildchannel SSM|<SYSTEM ...> CHANNEL'

    def complete_system_removechildchannel(self, text, line, begidx, endidx):
        if len(line.split(' ')) == 2:
            return self.tab_completer(self.get_system_names(), text)
        elif len(line.split(' ')) == 3:
            system = line.split(' ')[1]
            return self.tab_completer(self.list_child_channels(system, True), 
                                      text)

    def do_system_removechildchannel(self, args):
        self.manipulate_child_channels(args, True)

####################

    def help_system_details(self):
        print 'system_details: Show the details of a system profile'
        print 'usage: system_details SSM|<SYSTEM ...>'

    def complete_system_details(self, text, line, begidx, endidx):
        return self.tab_completer(self.get_system_names(), text)

    def do_system_details(self, args, short=False):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_details()
            return

        add_separator = False

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm
        else:
            systems = args

        for system in sorted(systems):
            system_id = self.get_system_id(system)
            if not system_id: return

            last_checkin = \
                self.client.system.getName(self.session,
                                           system_id).get('last_checkin')

            details = self.client.system.getDetails(self.session, system_id)

            registered = self.client.system.getRegistrationDate(self.session,
                                                                system_id)

            if add_separator:
                print self.SEPARATOR

            add_separator = True

            print 'Name:          %s' % system
            print 'System ID:     %s' % str(system_id)
            print 'Locked:        %s' % str(details.get('lock_status'))
            print 'Registered:    %s' % re.sub('T', ' ', registered.value)
            print 'Last Checkin:  %s' % re.sub('T', ' ', last_checkin.value)
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
                print '  %s' % self.ENTITLEMENTS[entitlement]

            if len(groups):
                print
                print 'System Groups:'
                for group in groups:
                    if group.get('subscribed') == 1:
                        print '  %s' % group.get('system_group_name')

####################

    def help_system_listerrata(self):
        print 'system_listerrata: List available errata for a system'
        print 'usage: system_listerrata SSM|<SYSTEM ...>'

    def complete_system_listerrata(self, text, line, begidx, endidx):
        return self.tab_completer(self.get_system_names(), text)

    def do_system_listerrata(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_listerrata()
            return

        add_separator = False

        # use the systems listed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm
        else:
            systems = args

        for system in sorted(systems):
            system_id = self.get_system_id(system)
            if not system_id: return

            if len(systems) > 1:
                print 'System: %s' % system
                print

            errata = self.client.system.getRelevantErrata(self.session,
                                                          system_id)

            self.print_errata_list(errata)

            if add_separator:
                print self.SEPARATOR

            add_separator = True

####################

    def help_system_applyerrata(self):
        print 'system_applyerrata: Apply all outstanding errata for a system'
        print 'usage: system_applyerrata SSM|<SYSTEM ...>'

    def complete_system_applyerrata(self, text, line, begidx, endidx):
        return self.tab_completer(self.get_system_names(), text)

    def do_system_applyerrata(self, args):
        args = self.parse_arguments(args)

        if not len(args):
            self.help_system_applyerrata()
            return

        # use the systems applyed in the SSM
        if re.match('ssm', args[0], re.I):
            systems = self.ssm
        else:
            systems = args

        jobs = []
        for system in sorted(systems):
            system_id = self.get_system_id(system)
            if not system_id: return

            errata = self.client.system.getRelevantErrata(self.session,
                                                          system_id)

            if not len(errata):
                logging.warning("%s doesn't have any relevant errata" %system)
                continue

            jobs.append( (system, system_id, errata) )

        if not len(jobs): return

        count = 0
        for job in jobs:
            (system, system_id, errata) = job

            if count: print
            count += 1

            print 'System: %s' % system
            print 'Errata:'
            map(self.print_errata_summary, errata)

        if not self.user_confirm(): return

        scheduled = 0
        for job in jobs:
            (system, system_id, errata) = job

            errata_ids = [e.get('id') for e in errata]

            time = self.parse_time_input('now')

            status = self.client.system.scheduleApplyErrata(self.session,
                                                            system_id,
                                                            errata_ids,
                                                            time)

            if status:
                scheduled += 1
            else:
                logging.error('Failed to schedule %s' % system)
                continue

        print 'Scheduled %s system(s)' % str(scheduled)

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
