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

from getpass import getpass
from spacecmd.utils import *

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
    print format_time(date.value)

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

def help_login(self):
    print 'login: Connect to a Spacewalk server'
    print 'usage: login [USERNAME] [SERVER]'

def do_login(self, args):
    args = parse_arguments(args)

    # logout before logging in again
    if len(self.session):
        logging.warning('You are already logged in')
        return

    if self.options.nossl:
        proto = 'http'
    else:
        proto = 'https'

    # read the username from the arguments passed
    if len(args):
        username = args[0]
    else:
        username = ''

    # read the server from the arguments passed
    if len(args) == 2:
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

    # check the API to verify connectivity
    try:
        logging.debug('Checking the API version')
        api_version = self.client.api.getVersion()
    except:
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
                sessionfile = open(self.session_file, 'r')
               
                # read the session (format = server:username:session)
                for line in sessionfile:
                    parts = line.split(':')

                    # only use cached credentials for this server
                    if parts[0] == server:
                        # if a username was passed, make sure it matches
                        if len(username):
                            if parts[1] == username:
                                self.session = parts[2]
                        else:
                            username = parts[1]
                            self.session = parts[2]

                sessionfile.close()
            except IOError:
                logging.error('Could not read %s' % self.session_file)

        # check the cached credentials by doing an API call
        if self.session:
            try:
                logging.info('Using cached credentials from %s' %
                             self.session_file)

                self.client.user.listUsers(self.session)
            except:
                logging.debug('Cached credentials are invalid')
                username = ''
                self.session = ''

    # attempt to login if we don't have a valid session yet
    if not len(self.session):
        if len(username):
            print 'Username: %s' % username
        else:
            if self.options.username:
                username = self.options.username

                # remove this from the options so that if 'login' is called
                # again, the user is prompted for the information
                self.options.username = None
            else:
                username = prompt_user('Username:', noblank = True)

        if self.options.password:
            password = self.options.password

            # remove this from the options so that if 'login' is called
            # again, the user is prompted for the information
            self.options.password = None
        else:
            password = getpass('Password: ')

        # login to the server
        try:
            self.session = self.client.auth.login(username, password)
        except:
            logging.error('Invalid credentials')
            return

        # write the session string to a file
        if not self.options.nocache:
            lines = []

            try:
                # read the cached sessions
                if os.path.isfile(self.session_file):
                    try:
                        sessionfile = open(self.session_file, 'r')
                        lines = sessionfile.readlines()
                        sessionfile.close()
                    except IOError:
                        pass

                # find and remove an existing cache for this server
                for line in lines:
                    parts = line.split(':')

                    if re.match('%s:' % server, parts[0], re.I):
                        lines.remove(line)

                # add the new cache to the file
                lines.append('%s:%s:%s\n' % (server, 
                                             username, 
                                             self.session))

                # write the new cache file out
                sessionfile = open(self.session_file, 'w')
                sessionfile.writelines(lines)
                sessionfile.close()
            except IOError:
                logging.error('Could not write cache file')

    # disable caching of subsequent logins
    self.options.nocache = True

    # keep track of who we are and who we're connected to
    self.username = username
    self.server = server

    logging.info('Connected to %s as %s' % (serverurl, username))

####################

def help_logout(self):
    print 'logout: Disconnect from the server'
    print 'usage: logout'

def do_logout(self, args):
    if self.session:
        self.client.auth.logout(self.session)

    self.session = ''
    self.username = ''
    self.server = ''
    self.clear_system_cache()
    self.clear_package_cache()
    self.clear_errata_cache()

####################

def help_whoami(self):
    print 'whoami: Print the name of the currently logged in user'
    print 'usage: whoami'

def do_whoami(self, args):
    if len(self.username):
        print self.username
    else:
        logging.warning("You are not logged in")

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
            logging.warning('%s = %i' % (name, id))

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
                system_id = int(item)
                name = self.client.system.getName(self.session, system_id)
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
