"""
Author: Aron Parsons <aron@redhat.com> -or- <aronparsons@gmail.com>
License: GPLv3+
"""

import atexit, logging, os, re, readline, sys, textwrap, xml, xmlrpclib
from cmd import Cmd
from getpass import getpass
from operator import itemgetter
from pwd import getpwuid

class SpacewalkShell(Cmd):
    MINIMUM_API_VERSION = 10.8

    HISTORY_LENGTH = 1024

    SEPARATOR = "\n--------------------\n"
  
    ENTITLEMENTS = {'provisioning_entitled'        : 'Provisioning',
                    'enterprise_entitled'          : 'Management',
                    'monitoring_entitled'          : 'Monitoring',
                    'virtualization_host'          : 'Virtualization',
                    'virtualization_host_platform' : 'Virtualization Platform'}

    intro = """
Welcome to SpacewalkShell, a command line interface to Spacewalk.

For a full set of commands, type "help" on the prompt.
For help for a specific command try "help <cmd>".
"""
    cmdqueue = []
    completekey = "tab"
    stdout = sys.stdout
    prompt = 'Spacewalk> '

    # do nothing on an empty line
    emptyline = lambda self: None

    def __init__(self, options):
        self.session = ''
        self.username = ''
        self.server = ''
        self.ssm = {}

        # make the options available everywhere
        self.options = options

        userinfo = getpwuid(os.getuid())
        self.cache_file = os.path.join(userinfo[5], ".spacewalk_cache")
        self.history_file = os.path.join(userinfo[5], ".spacewalk_history")

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
                    logging.error("Could not read history file")
                    logging.debug(sys.exc_info())
        except:
            logging.debug(sys.exc_info())


    # load the history file
    def preloop(self):
        if not self.session:
            self.args = []
            self.do_login(self.args)


    # handle commands that exit the shell
    def precmd(self, line, nohistory=False):
        # set the command and arguments once so they can be used elsewhere
        try:
            parts = line.split()
            self.cmd = parts[0]
            self.args = parts[1:]

            # simple globbing
            self.args = [re.sub('\*', '.*', a) for a in self.args]
        except IndexError:
            self.cmd = ''
            self.args = []

        if nohistory:
            return line

        # perform bash-like command substitution 
        if self.cmd.startswith('!'):
            # remove the '!*' line from the history
            last = readline.get_current_history_length() - 1
            readline.remove_history_item(last)

            history_match = False
           
            if self.cmd[1] == '!':
                # repeat the last command
                line = readline.get_history_item(
                           readline.get_current_history_length())

                if line:
                    history_match = True
                else:
                    logging.warning(self.cmd + ': event not found')
                    return ''
            
            if not history_match:
                # is a specific history item being referenced? 
                try:
                    number = int(self.cmd[1:])
                    line = readline.get_history_item(number)
                    if line:
                        history_match = True
                    else:
                        raise Exception
                except:
                    logging.warning(self.cmd + ': event not found')
                    return ''

            # attempt to match the beginning of the string with a history item
            if not history_match:
                history_range = range(1, readline.get_current_history_length())
                history_range.reverse()
 
                for i in history_range:
                    item = readline.get_history_item(i)
                    if item.startswith(self.cmd[1:]):
                        line = item
                        history_match = True
                        break
           
            # append the arguments to the substituted command 
            if history_match:
                line = line + ' ' + ''.join(args)
                print line
                readline.add_history(line)
            else:
                logging.warning(self.cmd + ': event not found')
                return ''

        if self.cmd.lower() in ('quit', 'exit', 'eof'):
            print
            sys.exit(0)
        else:
            return line

###########

    def tab_completer(self, options, text):
        return [o for o in options if o.startswith(text)]

    
    def filter_results(self, list, args):
        patterns = []
        for pattern in args:
            if pattern != '':
                patterns.append(re.compile(pattern, re.IGNORECASE))

        matches = []
        for item in list:
            if len(patterns) > 0:
                for pattern in patterns:
                    if pattern.match(item):
                        matches.append(item)

        return matches


    # build a proper RPM name from the various parts
    def build_package_names(self, packages):
        single = False

        if not isinstance(packages, list):
            packages = [packages]
            single = True

        package_names = []
        for p in packages:
            package = p.get('name') + '-' \
                    + p.get('version') + '-' \
                    + p.get('release')

            if p.get('epoch') != ' ' and p.get('epoch') != '':
                package = package + ':' + p.get('epoch')

            if p.get('arch'):
                # system.listPackages uses AMD64 instead of x86_64
                arch = re.sub('AMD64', 'x86_64', p.get('arch'))

                package = package + '.' + arch
            elif p.get('arch_label'):
                package = package + '.' + p.get('arch_label')

            package_names.append(package)
           
        if single:
            return package_names[0]
        else:
            package_names.sort()
            return package_names


    # check for duplicate system names and return the system ID
    def get_system_id(self, name):
        systems = self.client.system.getId(self.session, name)

        if len(systems) == 0:
            logging.warning("No systems found")
            return
        elif len(systems) == 1:
            return systems[0].get('id')
        else:
            logging.warning("Multiple systems found with the same name")

            for system in sorted(systems):
                logging.warning(name + " = " + str(system.get('id'))) 

            return

    def print_errata_summary(self, errata):
        for e in errata:
            print e.get('advisory_name') + '  ' + \
                  textwrap.wrap(e.get('advisory_synopsis'), 50)[0].ljust(50) + \
                  '  ' + e.get('date').rjust(8) 

###########

    def help_ssm_add(self):
        print "Usage: ssm_add group:GROUP|SYSTEM ..."

    def complete_ssm_add(self, text, line, begidx, endidx):
        if text.startswith('group:'):
            # prepend 'group' to each item for tab completion
            groups = ['group:' + g for g in self.do_group_list('', True)]

            return self.tab_completer(groups, text)
        else:
            return self.tab_completer(self.do_system_list('', True), text) 

    def do_ssm_add(self, args):
        all_systems = {}
        for s in self.client.system.listSystems(self.session):
            all_systems[s.get('name')] = s.get('id')

        systems = []
        for item in self.args:
            if item.startswith('group:'):
                item = re.sub('group:', '', item)
                members = self.do_group_listsystems(item, True)

                if len(members) > 0:
                    systems.extend(members)
                else:
                    logging.warning('No systems in group ' + item)
            else:
                systems.append(item)

        matches = self.filter_results(all_systems.keys(), systems)

        if len(matches) == 0:
            logging.warning("No matches found")
            return

        for match in matches:
            if match in self.ssm.keys():
                logging.warning(match + " is already in the SSM")
                continue
            else:
                logging.info("Added " + match)
                self.ssm[match] = all_systems.get(match)

        if len(self.ssm) > 0:
            print
            print 'Systems Selected: ' + str(len(self.ssm))

###########

    def help_ssm_rm(self):
        print "Usage: ssm_rm SYSTEM ..."
    
    def complete_ssm_rm(self, text, line, begidx, endidx):
        if text.startswith('group:'):
            # prepend 'group' to each item for tab completion
            groups = ['group:' + g for g in self.do_group_list('', True)]

            return self.tab_completer(groups, text)
        else:
            return self.tab_completer(self.do_ssm_list('', True), text)

    def do_ssm_rm(self, args):
        systems = []
        for item in self.args:
            if item.startswith('group:'):
                item = re.sub('group:', '', item)
                members = self.do_group_listsystems(item, True)

                if len(members) > 0:
                    systems.extend(members)
                else:
                    logging.warning('No systems in group ' + item)
            else:
                systems.append(item)

        matches = self.filter_results(self.ssm.keys(), systems)
        
        if len(matches) == 0:
            logging.warning("No matches found")
            return

        for match in matches:
            logging.info("Removed " + match)
            del self.ssm[match]
            
        print
        print 'Systems Selected: ' + str(len(self.ssm))

###########
 
    def help_ssm_list(self):
        print "Usage: ssm_list"
    
    def do_ssm_list(self, args, doreturn=False):
        systems = sorted(self.ssm.keys())

        if doreturn:
            return systems
        else:
            for s in systems:
                print s

            if len(systems) > 0:
                print
                print 'Systems Selected: ' + str(len(systems))

###########

    def help_ssm_clear(self):
        print "Usage: ssm_clear"
    
    def do_ssm_clear(self, args):
        self.ssm.clear()

###########

    def help_help(self):
        print "Usage: help COMMAND"

###########

    def help_clear(self):
        print "Usage: clear"
    
    def do_clear(self, args):
        os.system('clear')

###########

    def help_history(self):
        print "Usage: history"

    def do_history(self, args):
        for i in range(1, readline.get_current_history_length()):
            print str(i).rjust(4) + '  ' + readline.get_history_item(i)

###########

    def help_login(self):
        print "Usage: login [USERNAME] [SERVER]"

    def do_login(self, args):
        self.session = ''
        
        if self.options.nossl:
            proto = "http"
        else:
            proto = "https"

        if len(self.args) == 2 and self.args[1]:
            server = self.args[1]
        elif self.options.server:
            server = self.options.server
        else:
            logging.warning("No server specified")
            return

        server = proto + "://" + server + "/rpc/api"

        # connect to the server
        logging.debug("Connecting to " + server)
        self.client = xmlrpclib.Server(server)

        try:
            api_version = self.client.api.getVersion()
        except:
            logging.error('API version check failed')
            logging.error(sys.exc_info()[1])
            logging.debug(sys.exc_info())
            self.client = None
            return

        # ensure the server is recent enough
        if api_version < self.MINIMUM_API_VERSION:
            logging.error("API (" + api_version + ") is too old (>= " \
                         + self.MINIMUM_API_VERSION + " required)")

            self.client = None
            return

        # retrieve a cached session
        if not self.options.nocache:
            if os.path.isfile(self.cache_file):
                try:
                    # read the session (format = username:session)
                    sessionfile = open(self.cache_file, "r")
                    parts = sessionfile.read().split(':')
                    sessionfile.close()
   
                    username = parts[0]
                    self.session = parts[1]
                except:
                    logging.error("Could not read " + self.cache_file)
                    logging.debug(sys.exc_info())

                try:
                    logging.info("Using cached credentials from " + \
                                 self.cache_file)

                    self.client.user.listUsers(self.session)
                except:
                    logging.warning("Cached credentials are invalid")
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
            elif len(self.args) > 0 and self.args[0]:
                username = self.args[0]
            else:
                username = raw_input("Username: ")

                # don't store the username in the command history
                last = readline.get_current_history_length() - 1
                readline.remove_history_item(last)

            if self.options.password:
                password = self.options.password
                self.options.password = None
            else:
                password = getpass("Password: ")

            try:
                self.session = self.client.auth.login(username, 
                                                      password)
            except:
                logging.warning("Invalid credentials")
                logging.debug(sys.exc_info())
                return

            # write the session to a cache
            if not self.options.nocache:
                try:
                    logging.debug("Writing session cache to " + self.cache_file) 
                    sessionfile = open(self.cache_file, "w")
                    sessionfile.write(username + ':' + self.session)
                    sessionfile.close()
                except:
                    logging.error("Could not write cache file")
                    logging.debug(sys.exc_info())
 
        # disable caching of subsequent logins
        self.options.nocache = True

        # keep track of who we are and who we're connected to
        self.username = username
        self.server = server

        logging.info("Connected to " + server + " as " + username)

###########

    def help_logout(self):
        print "Usage: logout"
        
    def do_logout(self, args):
        if self.session:
            self.client.auth.logout(self.session)
            self.session = ''
            self.username = ''
            self.server = ''
           
            if os.path.isfile(self.cache_file): 
                try:
                    os.remove(self.cache_file)
                except:
                    logging.debug(sys.exc_info())
        else:
            logging.warning("You're not logged in")

###########

    def help_whoami(self):
        print "Usage: whoami"

    def do_whoami(self, args):
        if len(self.username) > 0:
            print self.username
        else:
            logging.warning("You're not logged in")

###########

    def help_whoamitalkingto(self):
        print "Usage: whoamitalkingto"

    def do_whoamitalkingto(self, args):
        if len(self.server) > 0:
            print self.server
        else:
            logging.warning('Yourself')

###########

    def help_get_apiversion(self):
        print "Usage: get_apiversion"


    def do_get_apiversion(self, args):
        print self.client.api.getVersion()

###########

    def help_get_serverversion(self):
        print "Usage: get_serverversion"

    def do_get_serverversion(self, args):
        print self.client.api.systemVersion()

###########

    def help_get_certificateexpiration(self):
        print "Usage: get_certificateexpiration"

    def do_get_certificateexpiration(self, args):
        print self.client.satellite.getCertificateExpirationDate(self.session).value

###########

    def help_get_entitlements(self):
        print "Usage: get_entitlements"

    def do_get_entitlements(self, args):
        entitlements = self.client.satellite.listEntitlements(self.session)

        print "System:"
        for e in entitlements.get('system'):
            print e.get('label') + ": " + \
                  str(e.get('used_slots')) + "/" + str(e.get('total_slots'))

        print       
        print "Channel:"
        for e in entitlements.get('channel'):
            print e.get('label') + ": " + \
                  str(e.get('used_slots')) + "/" + str(e.get('total_slots'))

###########

    def help_package_details(self):
        print "Usage: package_details PACKAGE ..."        

    def do_package_details(self, args):
        if len(self.args) == 0:
            self.help_package_details()
            return

        add_separator = False

        for package in self.args:
            if add_separator:
                print self.SEPARATOR

            add_separator = True

            try:
                id = int(package)
            except:
                id = self.client.packages.search.name(self.session,
                                                      package)[0].get('id')

            details = self.client.packages.getDetails(self.session, id)
            channels = self.client.packages.listProvidingChannels(self.session,
                                                                  id)

            print "Name:    " + details.get('name')
            print "Version: " + details.get('version')
            print "Release: " + details.get('release') 
            print "Epoch:   " + details.get('epoch')
            print "Arch:    " + details.get('arch_label')

            print
            print "Description: "
            print "\n".join(textwrap.wrap(details.get('description')))

            print
            print "File:    " + details.get('file')
            print "Size:    " + details.get('size')
            print "MD5:     " + details.get('md5sum')

            print
            print "Available From:"
            for channel in sorted([c.get('label') for c in channels]):
                print channel

###########

    def help_package_search(self):
        print "Usage: package_search PACKAGE|QUERY"
        print "Example: package_search kernel-2.6.18-92"
        print
        print "Advanced Search:"
        print "Available Fields: name, epoch, version, release, arch, " + \
              "description, summary"
        print "Example: name:kernel AND version:2.6.18 AND -description:devel" 

    def do_package_search(self, args):
        if len(self.args) == 0:
            self.help_package_search()
            return

        fields = ('name', 'epoch', 'version', 'release', 
                  'arch', 'description', 'summary')

        advanced = False
        for f in fields:
            if re.match(f + ':', args):
                advanced = True
                break

        if advanced:
            packages = self.client.packages.search.advanced(self.session, args)
        else:
            packages = self.client.packages.search.name(self.session, args)
       
        if len(packages) > 0: 
            print "\n".join(self.build_package_names(packages))
        else:
            logging.warning('No packages found')

###########

    def help_kickstart_list(self):
        print "Usage: kickstart_list [PATTERN] ..."
    
    def do_kickstart_list(self, args, doreturn=False):
        kickstarts = self.client.kickstart.listKickstarts(self.session)
        kickstarts = [k.get('name') for k in kickstarts]

        if doreturn:
            return kickstarts
        else:
            if len(self.args) > 0:
                kickstarts = self.filter_results(kickstarts, self.args)

            print "\n".join(sorted(kickstarts))

###########

    def help_kickstart_details(self):
        print "Usage: kickstart_details PROFILE"

    def complete_kickstart_details(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_kickstart_list('', True), text)
 
    def do_kickstart_details(self, args):
        if len(self.args) != 1:
            self.help_kickstart_details()
            return

        label = self.args[0]
        kickstart = None

        profiles = self.client.kickstart.listKickstarts(self.session)
        for p in profiles:
            if p.get('label') == label:
                kickstart = p
                break

        if not kickstart:
            logging.warning('No Kickstart profile found')
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

        print 'Name:        ' + kickstart.get('name')
        print 'Label:       ' + kickstart.get('label')
        print 'Tree:        ' + kickstart.get('tree_label')
        print 'Active:      ' + str(kickstart.get('active'))
        print 'Advanced:    ' + str(kickstart.get('advanced_mode'))
        print 'Org Default: ' + str(kickstart.get('org_default'))

        print 
        print 'Config Management: ' + str(config_manage)
        print 'Remote Commands:   ' + str(remote_commands)

        print
        print "Software Channels:"
        print '  ' + base_channel.get('label')

        for channel in sorted(child_channels):
            print '    |-- ' + channel

        if len(advanced_options) > 0:
            print
            print 'Advanced Options:'
            for o in sorted(advanced_options, key=itemgetter('name')):
                if o.get('arguments'):
                    print '  ' + o.get('name') + ' ' + o.get('arguments')

        if len(custom_options) > 0:
            print
            print 'Custom Options:'
            for o in sorted(custom_options, key=itemgetter('arguments')):
                print '  ' + re.sub("\n", '', o.get('arguments'))

        if len(partitions) > 0:
            print
            print 'Partitioning:'
            for line in partitions:
                print '  ' + line

        print 
        print 'Software:'
        for s in software:
            print '  ' + s

        if len(act_keys) > 0:
            print
            print 'Activation Keys:'
            for k in sorted(act_keys, key=itemgetter('key')):
                print '  ' + k.get('key')

        if len(crypto_keys) > 0:
            print
            print 'Crypto Keys:'
            for k in sorted(crypto_keys, key=itemgetter('description')):
                print '  ' + k.get('description')

        if len(file_preservations) > 0:
            print
            print 'File Preservations:'
            for fp in sorted(file_preservations, key=itemgetter('name')):
                print '  ' + fp.get('name')
                for file in sorted(fp.get('file_names')):
                    print '    |-- ' + file

        if len(variables) > 0:
            print
            print 'Variables:'
            for k in sorted(variables.keys()):
                print '  ' + k + '=' + str(variables[k])

        if len(scripts) > 0:
            print
            print 'Scripts:'

            add_separator = False

            for s in scripts:
                if add_separator:
                    print self.SEPARATOR

                add_separator = True

                print '  Type:        ' + s.get('script_type')
                print '  Chroot:      ' + str(s.get('chroot'))
            
                if s.get('interpreter'):
                    print '  Interpreter: ' + s.get('interpreter')

                print
                print s.get('contents')
 
###########

    def help_kickstart_raw(self):
        print "Usage: kickstart_raw [PATTERN] ..."
    
    def complete_kickstart_raw(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_kickstart_list('', True), text)

    def do_kickstart_raw(self, args, doreturn=False):
        kickstart = \
            self.client.kickstart.profile.downloadKickstart(self.session,
                                                            self.args[0],
                                                            self.server)

        print kickstart

###########

    def help_kickstart_listsnippets(self):
        print "Usage: kickstart_listsnippets [PATTERN] ..."
    
    def do_kickstart_listsnippets(self, args, doreturn=False):
        snippets = self.client.kickstart.snippet.listCustom(self.session)
        snippets = [s.get('name') for s in snippets]

        if doreturn:
            return snippets
        else:
            if len(self.args) > 0:
                snippets = self.filter_results(snippets, self.args)

            print "\n".join(sorted(snippets))

###########
 
    def help_kickstart_snippetdetails(self):
        print "Usage: kickstart_snippetdetails SNIPPET ..."

    def complete_kickstart_snippetdetails(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_kickstart_listsnippets('', True),
                                  text)
             
    def do_kickstart_snippetdetails(self, args):
        if len(self.args) == 0:
            self.help_kickstart_snippetdetails()
            return

        add_separator = False

        snippets = self.client.kickstart.snippet.listCustom(self.session)
        
        for name in self.args:
            for s in snippets:
                if s.get('name') == name:
                    snippet = s
                    break

            if not snippet:
                logging.warning(name + ' is not a valid snippet')
                continue                

            if add_separator:
                print self.SEPARATOR
            
            add_separator = True

            print 'Name:   ' + snippet.get('name')
            print 'Macro:  ' + snippet.get('fragment')
            print 'File:   ' + snippet.get('file')

            print
            print snippet.get('contents')

###########

    def help_system_list(self):
        print "Usage: system_list [PATTERN] ..."
    
    def do_system_list(self, args, doreturn=False):
        systems = self.client.system.listSystems(self.session)
        systems = [s.get('name') for s in systems]

        if doreturn:
            return systems
        else:
            if len(self.args) > 0:
                systems = self.filter_results(systems, self.args)

            print "\n".join(sorted(systems))

###########

    def help_system_hardware(self):
        print "Usage: system_details SSM|SYSTEM"

    def complete_system_hardware(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_system_list('', True), text)
 
    def do_system_hardware(self, args):
        if len(self.args) == 0:
            self.help_system_details()
            return

        add_separator = False

        # use the systems listed in the SSM
        if self.args[0].lower() == 'ssm':
            systems = self.ssm
        else:
            systems = self.args

        for system in sorted(systems):
            try:
                # check if we were passed a system ID
                system_id = int(system)
            except ValueError:
                system_id = self.get_system_id(system)

            if not system_id:
                logging.warning(system + ' is not a valid system')
                continue

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
                print 'System: ' + system
                print

            if len(network) > 0:
                count = 0
                print 'Network:'
                for device in network:
                    if count > 0:
                        print
                    count += 1

                    print '  Interface:   ' + device.get('interface')
                    print '  MAC Address: ' + \
                                 device.get('hardware_address').upper()
                    print '  IP Address:  ' + device.get('ip')
                    print '  Netmask:     ' + device.get('netmask')
                    print '  Broadcast:   ' + device.get('broadcast')
                    print '  Module:      ' + device.get('module')
                print

            print 'CPU:'
            print '  Count:    ' + str(cpu.get('count'))
            print '  Arch:     ' + cpu.get('arch')
            print '  MHz:      ' + cpu.get('mhz')
            print '  Cache:    ' + cpu.get('cache')
            print '  Vendor:   ' + cpu.get('vendor')
            print '  Model:    ' + re.sub("\s+", ' ', cpu.get('model'))
            print '  Family:   ' + cpu.get('family')
            print '  Stepping: ' + cpu.get('stepping')

            print
            print 'Memory:'
            print '  RAM:  ' + str(memory.get('ram'))
            print '  Swap: ' + str(memory.get('swap'))

            if dmi:
                print
                print 'DMI:'
                print '  Vendor:       ' + dmi.get('vendor')
                print '  System:       ' + dmi.get('system')
                print '  Product:      ' + dmi.get('product')
                print '  Board:        ' + dmi.get('board')

                print
                print '  Asset:'
                for asset in dmi.get('asset').split(') ('):
                    print '    ' + re.sub('\)|\(', '', asset)

                print
                print '  BIOS Release: ' + dmi.get('bios_release')
                print '  BIOS Vendor:  ' + dmi.get('bios_vendor')
                print '  BIOS Version: ' + dmi.get('bios_version')

            if len(devices) > 0:
                count = 0
                print
                print 'Devices:'
                for device in devices:
                    if count > 0:
                        print
                    count += 1
    
                    print '  Description: ' + \
                             textwrap.wrap(device.get('description'), 60)[0]
                    print '  Driver:      ' + device.get('driver')
                    print '  Class:       ' + device.get('device_class')
                    print '  Bus:         ' + device.get('bus')

###########

    def help_system_availableupgrades(self):
        print "Usage: system_availableupgrades SSM|SYSTEM"

    def complete_system_availableupgrades(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_system_list('', True), text)
 
    def do_system_availableupgrades(self, args):
        if len(self.args) == 0:
            self.help_system_availableupgrades()
            return

        add_separator = False

        # use the systems listed in the SSM
        if self.args[0].lower() == 'ssm':
            systems = self.ssm
        else:
            systems = self.args

        for system in sorted(systems):
            try:
                # check if we were passed a system ID
                system_id = int(system)
            except ValueError:
                system_id = self.get_system_id(system)

            if not system_id:
                logging.warning(system + ' is not a valid system')
                continue

            packages = \
                self.client.system.listLatestUpgradablePackages(self.session,
                                                                system_id)

            if add_separator:
                print self.SEPARATOR

            add_separator = True

            if len(systems) > 1:
                print 'System: ' + system
                print

            for package in sorted(packages, key=itemgetter('name')):
                old = {'name'    : package.get('name'),
                       'version' : package.get('from_version'),
                       'release' : package.get('from_release'),
                       'epoch'   : package.get('from_epoch')}

                new = {'name'    : package.get('name'),
                       'version' : package.get('to_version'),
                       'release' : package.get('to_release'),
                       'epoch'   : package.get('to_epoch')}

                print 'Old: ' + self.build_package_names(old)
                print 'New: ' + self.build_package_names(new)
                print

###########

    def help_system_packages(self):
        print "Usage: system_packages SSM|SYSTEM"

    def complete_system_packages(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_system_list('', True), text)
 
    def do_system_packages(self, args):
        if len(self.args) == 0:
            self.help_system_packages()
            return

        add_separator = False

        # use the systems listed in the SSM
        if self.args[0].lower() == 'ssm':
            systems = self.ssm
        else:
            systems = self.args

        for system in sorted(systems):
            try:
                # check if we were passed a system ID
                system_id = int(system)
            except ValueError:
                system_id = self.get_system_id(system)

            if not system_id:
                logging.warning(system + ' is not a valid system')
                continue

            packages = self.client.system.listPackages(self.session,
                                                       system_id)

            if add_separator:
                print self.SEPARATOR

            add_separator = True

            if len(systems) > 1:
                print 'System: ' + system
                print

            print "\n".join(self.build_package_names(packages))

###########

    def help_system_details(self):
        print "Usage: system_details SSM|SYSTEM"

    def complete_system_details(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_system_list('', True), text)
 
    def do_system_details(self, args):
        if len(self.args) == 0:
            self.help_system_details()
            return

        add_separator = False

        # use the systems listed in the SSM
        if self.args[0].lower() == 'ssm':
            systems = self.ssm
        else:
            systems = self.args

        for system in sorted(systems):
            try:
                # check if we were passed a system ID
                system_id = int(system)
            except ValueError:
                system_id = self.get_system_id(system)

            if not system_id:
                logging.warning(system + ' is not a valid system')
                continue

            last_checkin = \
                self.client.system.getName(self.session,
                                           system_id).get('last_checkin')

            details = self.client.system.getDetails(self.session, system_id)

            registered = self.client.system.getRegistrationDate(self.session,
                                                                system_id)
            
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
           
            network = self.client.system.getNetwork(self.session, system_id)

            keys = self.client.system.listActivationKeys(self.session,
                                                         system_id)

            ranked_config_channels = []
            if 'provisioning_entitled' in entitlements:
                config_channels = \
                    self.client.system.config.listChannels(self.session,
                                                           system_id)

                for channel in config_channels:
                    ranked_config_channels.append(channel.get('label'))
       
            if add_separator:
                print self.SEPARATOR

            add_separator = True

            print "Name:          " + system
            print "System ID:     " + str(system_id)
            print "Locked:        " + str(details.get('lock_status'))
            print "Registered:    " + re.sub('T', ' ', registered.value)
            print "Last Checkin:  " + re.sub('T', ' ', last_checkin.value)
            print "OSA Status:    " + details.get('osa_status')

            print
            print "Hostname:      " + network.get('hostname')
            print "IP Address:    " + network.get('ip')
            print "Kernel:        " + kernel

            if len(keys) > 0:
                print
                print "Activation Keys:"
                for key in keys:
                    print '  ' + key

            print
            print "Software Channels:"
            print '  ' + base_channel.get('label')

            for channel in child_channels:
                print '    |-- ' + channel.get('label')

            if len(ranked_config_channels) > 0:
                print
                print 'Configuration Channels:'
                for channel in ranked_config_channels:
                    print '  ' + channel

            print
            print "Entitlements:"
            for entitlement in sorted(entitlements):
                print '  ' + self.ENTITLEMENTS[entitlement]

            if len(groups) > 0:
                print
                print "System Groups:"
                for group in groups:
                    if group.get('subscribed') == 1:
                        print '  ' + group.get('system_group_name')

###########

    def help_system_errata(self):
        print "Usage: system_errata SYSTEM ..."
    
    def complete_system_errata(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_system_list('', True), text)
 
    def do_system_errata(self, args):
        if len(self.args) == 0:
            self.do_help_system_errata()
            return

        add_separator = False

        # use the systems listed in the SSM
        if self.args[0].lower() == 'ssm':
            systems = self.ssm
        else:
            systems = self.args

        for system in sorted(systems):
            try:
                # check if we were passed a system ID
                system_id = int(system)
            except ValueError:
                system_id = self.get_system_id(system)

            if not system_id:
                logging.warning(system + ' is not a valid system')
                continue

            errata = self.client.system.getRelevantErrata(self.session,
                                                          system_id)
            
            rhsa = []
            rhea = []
            rhba = []
            other = []
            for e in errata:
                type = e.get('advisory_type').lower()

                if type.startswith('security'):
                    rhsa.append(e)
                elif type.startswith('bug fix'):
                    rhba.append(e)
                elif type.startswith('enhancement'):
                    rhea.append(e)
                else:
                    other.append(e)
               
            if add_separator:
                print self.SEPARATOR

            add_separator = True

            if len(systems) > 1:
                print 'System: ' + system
                print

            if len(errata) == 0:
                print 'No relevant errata'
                continue

            if len(rhsa) > 0:
                print 'Security Errata:'
                self.print_errata_summary(rhsa)
            
            if len(rhba) > 0:
                if len(rhsa) > 0:
                    print

                print 'Bug Fix Errata:'
                self.print_errata_summary(rhba)
 
            if len(rhea) > 0:
                if len(rhsa) > 0 or len(rhba) > 0:
                    print

                print 'Enhancement Errata:'
                self.print_errata_summary(rhea)

            if len(other) > 0:
                if len(rhsa) > 0 or len(rhba) > 0 or len(rhea) > 0:
                    print

                print 'Other Errata:'
                self.print_errata_summary(other)

###########

    def help_group_list(self):
        print "Usage: group_list [GROUP] ..."

    def do_group_list(self, args, doreturn=False, filtered=True):
        groups = self.client.systemgroup.listAllGroups(self.session)
        groups = [g.get('name') for g in groups]

        if doreturn:
            return groups
        else:
            if len(self.args) > 0:
                groups = self.filter_results(groups, self.args)

            print "\n".join(sorted(groups))

###########

    def help_group_listsystems(self):
        print "Usage: group_listsystems GROUP"

    def complete_group_listsystems(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_group_list('', True), text)
 
    def do_group_listsystems(self, args, doreturn=False):
        if len(self.args) == 0:
            self.help_group_listsystems()
            return

        group = args

        try:
            systems = self.client.systemgroup.listSystems(self.session,
                                                          group)
            
            systems = [s.get('profile_name') for s in systems]
        except:
            logging.warning(group + ' is not a valid group')
            logging.debug(sys.exc_info())
            return []
 
        if doreturn:
            return systems
        else:
            if len(self.args) > 1:
                systems = self.filter_results(systems, self.args[1:])

            print "\n".join(sorted(systems))
     
###########
 
    def help_group_details(self):
        print "Usage: group_details GROUP ..."

    def complete_group_details(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_group_list('', True), text)
 
    def do_group_details(self, args):
        if len(self.args) == 0:
            self.help_group_details()
            return

        add_separator = False

        for group in self.args:
            try:
                details = self.client.systemgroup.getDetails(self.session, 
                                                             group)
            
                systems = self.client.systemgroup.listSystems(self.session,
                                                              group)
            
                systems = [s.get('profile_name') for s in systems]
            except:
                logging.warning(key + ' is not a valid group')
                logging.debug(sys.exc_info())
                return
     
            if add_separator:
                print self.SEPARATOR
            
            add_separator = True

            print "Name               " + details.get('name')
            print "Description:       " + details.get('description')
            print "Number of Systems: " + str(details.get('system_count'))

            print
            print "Members:"
            for system in sorted(systems):
                print '  ' + system

###########

    def help_cryptokey_list(self):
        print "Usage: cryptokey_list [KEY] ..."

    def do_cryptokey_list(self, args, doreturn=False):
        keys = self.client.kickstart.keys.listAllKeys(self.session)
        keys = [k.get('description') for k in keys]

        if doreturn:
            return keys
        else:
            if len(self.args) > 0:
                keys = self.filter_results(keys, self.args)

            print "\n".join(sorted(keys))

###########
 
    def help_cryptokey_details(self):
        print "Usage: cryptokey_details KEY ..."

    def complete_cryptokey_details(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_cryptokey_list('', True), text)
 
    def do_cryptokey_details(self, args):
        if len(self.args) == 0:
            self.help_cryptokey_details()
            return

        add_separator = False

        for key in self.args:
            try:
                details = self.client.kickstart.keys.getDetails(self.session, 
                                                                key)
            except:
                logging.warning(key + ' is not a valid crypto key')
                logging.debug(sys.exc_info())
                return
        
            if add_separator:
                print self.SEPARATOR
            
            add_separator = True

            print "Description: " + details.get('description')
            print "Type:        " + details.get('type')

            print
            print details.get('content')

###########

    def help_activationkey_list(self):
        print "Usage: activationkey_list [KEY] ..."

    def do_activationkey_list(self, args, doreturn=False):
        keys = self.client.activationkey.listActivationKeys(self.session)
        keys = [k.get('key') for k in keys]

        if doreturn:
            return keys
        else:
            if len(self.args) > 0:
                keys = self.filter_results(keys, self.args)

            print "\n".join(sorted(keys))

###########

    def help_activationkey_listsystems(self):
        print "Usage: activationkey_listsystems KEY"

    def complete_activationkey_listsystems(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_activationkey_list('', True), text)

    def do_activationkey_listsystems(self, args):
        if len(self.args) == 0:
            self.help_activationkey_listsystems()
            return

        try:
            systems = \
                self.client.activationkey.listActivatedSystems(self.session,
                                                           self.args[0])
        except:
            logging.warning(self.args[0] + ' is not a valid activation key')
            logging.debug(sys.exc_info())
            return
        
        systems = sorted([s.get('hostname') for s in systems])

        print "\n".join(systems)

###########
 
    def help_activationkey_details(self):
        print "Usage: activationkey_details KEY ..."

    def complete_activationkey_details(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_activationkey_list('', True), text)
 
    def do_activationkey_details(self, args):
        if len(self.args) == 0:
            self.help_activationkey_details()
            return

        add_separator = False

        for key in self.args:
            try:
                details = self.client.activationkey.getDetails(self.session, 
                                                               key)

                config_channels = \
                    self.client.activationkey.listConfigChannels(self.session, 
                                                                 key) 
            except:
                logging.warning(key + ' is not a valid activation key')
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

            print "Key:               " + details.get('key')
            print "Description:       " + details.get('description')
            print "Universal Default: " + str(details.get('universal_default'))

            print
            print "Software Channels:"
            print '  ' + details.get('base_channel_label')

            for channel in details.get('child_channel_labels'):
                print "   |-- " + channel

            print
            print 'Configuration Channels:'
            for channel in config_channels:
                print '  ' + channel.get('label')

            print
            print "Entitlements:"
            for entitlement in sorted(details.get('entitlements')):
                print '  ' + self.ENTITLEMENTS[entitlement]

            print
            print "System Groups:"
            for group in groups:
                print '  ' + group

            print
            print "Packages:"
            for package in details.get('packages'):
                name = package.get('name')

                if package.get('arch'):
                    name = name + '.' + package.get('arch')

                print '  ' + name

###########

    def help_configchannel_list(self):
        print "Usage: configchannel_list [CHANNEL] ..."

    def do_configchannel_list(self, args, doreturn=False):
        channels = self.client.configchannel.listGlobals(self.session)
        channels = [c.get('label') for c in channels]

        if doreturn:
            return channels
        else:
            if len(self.args) > 0:
                channels = self.filter_results(channels, self.args)

            print "\n".join(sorted(channels))

###########

    def help_configchannel_listsystems(self):
        print "Usage: configchannel_listsystems CHANNEL"

    def complete_configchannel_listsystems(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_configchannel_list('', True), text)

    def do_configchannel_listsystems(self, args):
        print "configchannel.listSubscribedSystems is not implemented"
        return

        if len(self.args) == 0:
            self.help_configchannel_listsystems()
            return

        systems = \
            self.client.configchannel.listSubscribedSystems(self.session,
                                                            self.args[0])
        
        systems = sorted([s.get('name') for s in systems])

        print "\n".join(systems)

###########

    def help_configchannel_listfiles(self):
        print "Usage: configchannel_listfiles CHANNEL ..."

    def complete_configchannel_listfiles(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_configchannel_list('', True), text)
 
    def do_configchannel_listfiles(self, args, doreturn=False):
        if len(args) == 0:
            self.help_configchannel_listfiles()
            return []

        for channel in args.split():
            files = self.client.configchannel.listFiles(self.session,
                                                        channel)
            files = [f.get('path') for f in files]

            if doreturn:
                return files
            else:
                print "\n".join(sorted(files))

###########
 
    def help_configchannel_filedetails(self):
        print "Usage: configchannel_filedetails CHANNEL FILE ..."

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
        if len(self.args) < 2:
            self.help_configchannel_filedetails()
            return

        add_separator = False

        channel = self.args[0]
        filenames = self.args[1:]

        # the server return a null exception if an invalid file is passed
        valid_files = self.do_configchannel_listfiles(channel, True)
        for f in filenames:
            if not f in valid_files:
                filenames.remove(f)
                logging.warning(f + ' is not in this configuration channel')
                continue

        files = self.client.configchannel.lookupFileInfo(self.session, 
                                                         channel,
                                                         filenames)

        for file in files:
            if add_separator:
                print self.SEPARATOR
            
            add_separator = True

            print 'File:     ' + file.get('path')
            print 'Type:     ' + file.get('type')
            print 'Revision: ' + str(file.get('revision'))
            print 'Created:  ' + re.sub('T', ' ', file.get('creation').value)
            print 'Modified: ' + re.sub('T', ' ', file.get('modified').value)

            print
            print 'Owner:    ' + file.get('owner')
            print 'Group:    ' + file.get('group')
            print 'Mode:     ' + file.get('permissions_mode')

            if file.get('type') == 'file':
                print 'MD5:      ' + file.get('md5')
                print 'Binary:   ' + str(file.get('binary'))

                if not file.get('binary'):
                    print
                    print file.get('contents')

###########
 
    def help_configchannel_details(self):
        print "Usage: configchannel_details CHANNEL ..."

    def complete_configchannel_details(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_configchannel_list('', True), text)
 
    def do_configchannel_details(self, args):
        if len(self.args) == 0:
            self.help_configchannel_details()
            return

        add_separator = False

        for channel in self.args:
            details = self.client.configchannel.getDetails(self.session, 
                                                           channel)
      
            files = self.client.configchannel.listFiles(self.session,
                                                        channel)
 
            if add_separator:
                print self.SEPARATOR
            
            add_separator = True

            print "Label:       " + details.get('label')
            print "Name:        " + details.get('name')
            print "Description: " + details.get('description')

            print
            print "Files:"
            for file in files:
                print '  ' + file.get('path')

###########

    def help_softwarechannel_list(self):
        print "Usage: softwarechannel_list [CHANNEL] ..."

    def do_softwarechannel_list(self, args, doreturn=False):
        channels = self.client.channel.listAllChannels(self.session)
        channels = [c.get('label') for c in channels]

        if doreturn:
            return channels
        else:
            if len(self.args) > 0:
                channels = self.filter_results(channels, self.args)

            print "\n".join(sorted(channels))
      
###########

    def help_softwarechannel_listsystems(self):
        print "Usage: softwarechannel_listsystems CHANNEL"

    def complete_softwarechannel_listsystems(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_softwarechannel_list('', True), text)

    def do_softwarechannel_listsystems(self, args):
        if len(self.args) == 0:
            self.help_softwarechannel_listsystems()
            return

        systems = \
            self.client.channel.software.listSubscribedSystems(self.session,
                                                               self.args[0])
        
        systems = sorted([s.get('name') for s in systems])

        print "\n".join(systems)

###########

    def help_softwarechannel_packages(self):
        print "Usage: softwarechannel_packages CHANNEL [PACKAGE] ..."

    def complete_softwarechannel_packages(self, text, line, begidx, endidx):
        # only tab complete the channel name
        if len(line.split(' ')) == 2:
            return self.tab_completer(self.do_softwarechannel_list('', True), text)
        else:
            return []

    def do_softwarechannel_packages(self, args, doreturn=False):
        if len(self.args) == 0:
            self.help_softwarechannel_packages()
            return

        packages = self.client.channel.software.listLatestPackages(self.session,
                                                                   self.args[0])

        packages = self.build_package_names(packages)

        if doreturn:
            return packages
        else:
            if len(self.args) > 1:
                packages = self.filter_results(packages, self.args[1:])

            print "\n".join(sorted(packages)) 
            
###########
 
    def help_softwarechannel_details(self):
        print "Usage: softwarechannel_details CHANNEL ..."

    def complete_softwarechannel_details(self, text, line, begidx, endidx):
        return self.tab_completer(self.do_softwarechannel_list('', True), text)
 
    def do_softwarechannel_details(self, args):
        if len(self.args) == 0:
            self.help_softwarechannel_details()
            return

        add_separator = False

        for channel in self.args:
            details = self.client.channel.software.getDetails(self.session, 
                                                              channel)
      
            systems = \
                self.client.channel.software.listSubscribedSystems(self.session,                                                                   channel)
 
            if add_separator:
                print self.SEPARATOR

            add_separator = True

            print "Label:              " + details.get('label')
            print "Name:               " + details.get('name')
            print "Architecture:       " + details.get('arch_name')
            print "Parent:             " + details.get('parent_channel_label')
            print "Summary:            " + details.get('summary')
            print "Systems Subscribed: " + str(len(systems))

            print
            print "Description:"
            print "\n".join(textwrap.wrap(details.get('description')))
           
            print 
            print "GPG Key:            " + details.get('gpg_key_id')
            print "GPG Fingerprint:    " + details.get('gpg_key_fp')
            print "GPG URL:            " + details.get('gpg_key_url')

# vim:ts=4:expandtab:
