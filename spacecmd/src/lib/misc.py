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
# Copyright 2013 Aron Parsons <aronparsons@gmail.com>
# Copyright (c) 2011--2015 Red Hat, Inc.
#

# NOTE: the 'self' variable is an instance of SpacewalkShell

# wildcard import
# pylint: disable=W0401,W0614

# unused argument
# pylint: disable=W0613

# invalid function name
# pylint: disable=C0103

import logging
import readline
import shlex
from getpass import getpass
from ConfigParser import NoOptionError
from spacecmd.utils import *
from time import sleep
import xmlrpclib

# list of system selection options for the help output
HELP_SYSTEM_OPTS = '''<SYSTEMS> can be any of the following:
name
ssm (see 'help ssm')
search:QUERY (see 'help system_search')
group:GROUP
channel:CHANNEL
'''

HELP_TIME_OPTS = '''Dates can be any of the following:
Explicit Dates:
Dates can be expressed as explicit date strings in the YYYYMMDD[HHMM]
format.  The year, month and day are required, while the hours and
minutes are not; the hours and minutes will default to 0000 if no
values are provided.

Deltas:
Dates can be expressed as delta values.  For example, '2h' would
mean 2 hours in the future.  You can also use negative values to
express times in the past (e.g., -7d would be one week ago).

Units:
s -> seconds
m -> minutes
h -> hours
d -> days
'''

####################

# life of caches in seconds
SYSTEM_CACHE_TTL = 3600
PACKAGE_CACHE_TTL = 86400
ERRATA_CACHE_TTL = 86400

MINIMUM_API_VERSION = 10.8

SEPARATOR = '\n' + '#' * 30 + '\n'

####################

ENTITLEMENTS = ['enterprise_entitled',
                'virtualization_host'
               ]

SYSTEM_SEARCH_FIELDS = ['id', 'name', 'ip', 'hostname',
                        'device', 'vendor', 'driver', 'uuid']

####################


def help_systems(self):
    print HELP_SYSTEM_OPTS


def help_time(self):
    print HELP_TIME_OPTS

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
    print date

####################


def help_list_proxies(self):
    print 'list_proxies: List the proxies wihtin the user\'s organization '
    print 'usage: list_proxies'


def do_list_proxies(self, args):
    proxies = self.client.satellite.listProxies(self.session)
    print proxies

####################


def help_get_session(self):
    print 'get_session: Show the current session string'
    print 'usage: get_session'


def do_get_session(self, args):
    if self.session:
        print self.session
    else:
        logging.error('No session found')

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


def help_toggle_confirmations(self):
    print 'toggle_confirmations: Toggle confirmation messages on/off'
    print 'usage: toggle_confirmations'


def do_toggle_confirmations(self, args):
    if self.options.yes:
        self.options.yes = False
        print 'Confirmation messages are enabled'
    else:
        self.options.yes = True
        logging.warning('Confirmation messages are DISABLED!')

####################


def help_login(self):
    print 'login: Connect to a Spacewalk server'
    print 'usage: login [USERNAME] [SERVER]'


def do_login(self, args):
    (args, _options) = parse_arguments(args)

    # logout before logging in again
    if len(self.session):
        logging.warning('You are already logged in')
        return True

    # an argument passed to the function get precedence
    if len(args) == 2:
        server = args[1]
    else:
        # use the server we were already using
        server = self.config['server']

    # bail out if not server was given
    if not server:
        logging.warning('No server specified')
        return False

    # load the server-specific configuration
    self.load_config_section(server)

    # an argument passed to the function get precedence
    if len(args):
        username = args[0]
    elif self.config.has_key('username'):
        # use the username from before
        username = self.config['username']
    elif self.options.username:
        # use the username from before
        username = self.options.username
    else:
        username = ''

    # set the protocol
    if self.config.has_key('nossl') and self.config['nossl']:
        proto = 'http'
    else:
        proto = 'https'

    server_url = '%s://%s/rpc/api' % (proto, server)

    # this will enable spewing out all client/server traffic
    verbose_xmlrpc = False
    if self.options.debug > 1:
        verbose_xmlrpc = True

    # connect to the server
    logging.debug('Connecting to %s', server_url)
    self.client = xmlrpclib.Server(server_url, verbose=verbose_xmlrpc)

    # check the API to verify connectivity
    try:
        self.api_version = self.client.api.getVersion()
        logging.debug('Server API Version = %s', self.api_version)
    except xmlrpclib.Fault, e:
        if self.options.debug > 0:
            logging.exception(e)

        logging.error('Failed to connect to %s', server_url)
        self.client = None
        return False

    # ensure the server is recent enough
    if self.api_version < self.MINIMUM_API_VERSION:
        logging.error('API (%s) is too old (>= %s required)',
                      self.api_version, self.MINIMUM_API_VERSION)

        self.client = None
        return False

    # store the session file in the server's own directory
    session_file = os.path.join(self.conf_dir, server, 'session')

    # retrieve a cached session
    if os.path.isfile(session_file) and not self.options.password:
        try:
            sessionfile = open(session_file, 'r')

            # read the session (format = username:session)
            for line in sessionfile:
                parts = line.split(':')

                # if a username was passed, make sure it matches
                if len(username):
                    if parts[0] == username:
                        self.session = parts[1]
                else:
                    # get the username from the cache if one
                    # wasn't passed by the user
                    username = parts[0]
                    self.session = parts[1]

            sessionfile.close()
        except IOError:
            logging.error('Could not read %s', session_file)

    # check the cached credentials by doing an API call
    if self.session:
        try:
            logging.debug('Using cached credentials from %s', session_file)

            self.client.user.listAssignableRoles(self.session)
        except xmlrpclib.Fault:
            logging.warning('Cached credentials are invalid')
            self.current_user = ''
            self.session = ''

    # attempt to login if we don't have a valid session yet
    if not len(self.session):
        if len(username):
            logging.info('Spacewalk Username: %s', username)
        else:
            username = prompt_user('Spacewalk Username:', noblank=True)

        if self.options.password:
            password = self.options.password

            # remove this from the options so that if 'login' is called
            # again, the user is prompted for the information
            self.options.password = None
        elif self.config.has_key('password'):
            password = self.config['password']
        else:
            password = getpass('Spacewalk Password: ')

        # login to the server
        try:
            self.session = self.client.auth.login(username, password)

            # don't keep the password around
            password = None
        except xmlrpclib.Fault:
            logging.error('Invalid credentials')
            return False

        try:
            # make sure ~/.spacecmd/<server> exists
            conf_dir = os.path.join(self.conf_dir, server)

            if not os.path.isdir(conf_dir):
                os.mkdir(conf_dir, 0700)

            # add the new cache to the file
            line = '%s:%s\n' % (username, self.session)

            # write the new cache file out
            sessionfile = open(session_file, 'w')
            sessionfile.write(line)
            sessionfile.close()
        except IOError:
            logging.error('Could not write session file')

    # load the system/package/errata caches
    self.load_caches(server)

    # keep track of who we are and who we're connected to
    self.current_user = username
    self.server = server

    logging.info('Connected to %s as %s', server_url, username)

    return True

####################


def help_logout(self):
    print 'logout: Disconnect from the server'
    print 'usage: logout'


def do_logout(self, args):
    if self.session:
        self.client.auth.logout(self.session)

    self.session = ''
    self.current_user = ''
    self.server = ''
    self.do_clear_caches('')

####################


def help_whoami(self):
    print 'whoami: Print the name of the currently logged in user'
    print 'usage: whoami'


def do_whoami(self, args):
    if len(self.current_user):
        print self.current_user
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
        channels = ['channel:%s' % s
                    for s in self.do_softwarechannel_list('', True)]

        return tab_completer(channels, text)
    elif re.match('search:', text):
        # prepend 'search' to each item for tab completion
        fields = ['search:%s:' % f for f in self.SYSTEM_SEARCH_FIELDS]
        return tab_completer(fields, text)
    else:
        options = self.get_system_names()

        # add our special search options
        options.extend(['group:', 'channel:', 'search:'])

        return tab_completer(options, text)


def remove_last_history_item(self):
    last = readline.get_current_history_length() - 1

    if last >= 0:
        readline.remove_history_item(last)


def clear_errata_cache(self):
    self.all_errata = {}
    self.errata_cache_expire = datetime.now()
    self.save_errata_cache()


def get_errata_names(self):
    return sorted([e.get('advisory_name') for e in self.all_errata])


def get_erratum_id(self, name):
    if name in self.all_errata:
        return self.all_errata[name]['id']


def get_erratum_name(self, erratum_id):
    for erratum in self.all_errata:
        if self.all_errata[erratum]['id'] == erratum_id:
            return erratum


def generate_errata_cache(self, force=False):
    if not force and datetime.now() < self.errata_cache_expire:
        return

    if not self.options.quiet:
        # tell the user what's going on
        self.replace_line_buffer('** Generating errata cache **')

    channels = self.client.channel.listSoftwareChannels(self.session)
    channels = [c.get('label') for c in channels]

    for c in channels:
        try:
            errata = \
                self.client.channel.software.listErrata(self.session, c)
        except xmlrpclib.Fault:
            logging.debug('No access to %s', c)
            continue

        for erratum in errata:
            if erratum.get('advisory_name') not in self.all_errata:
                self.all_errata[erratum.get('advisory_name')] = \
                    {'id': erratum.get('id'),
                     'advisory_name': erratum.get('advisory_name'),
                     'advisory_type': erratum.get('advisory_type'),
                     'date': erratum.get('date'),
                     'advisory_synopsis': erratum.get('advisory_synopsis')}

    self.errata_cache_expire = \
        datetime.now() + timedelta(self.ERRATA_CACHE_TTL)

    self.save_errata_cache()

    if not self.options.quiet:
        # restore the original line buffer
        self.replace_line_buffer()


def save_errata_cache(self):
    save_cache(self.errata_cache_file,
               self.all_errata,
               self.errata_cache_expire)


def clear_package_cache(self):
    self.all_packages_short = {}
    self.all_packages = {}
    self.all_packages_by_id = {}
    self.package_cache_expire = datetime.now()
    self.save_package_caches()


def generate_package_cache(self, force=False):
    if not force and datetime.now() < self.package_cache_expire:
        return

    if not self.options.quiet:
        # tell the user what's going on
        self.replace_line_buffer('** Generating package cache **')

    channels = self.client.channel.listSoftwareChannels(self.session)
    channels = [c.get('label') for c in channels]

    for c in channels:
        try:
            packages = \
                self.client.channel.software.listAllPackages(self.session, c)
        except xmlrpclib.Fault:
            logging.debug('No access to %s', c)
            continue

        for p in packages:
            if not p.get('name') in self.all_packages_short:
                self.all_packages_short[p.get('name')] = ''

            longname = build_package_names(p)

            if not longname in self.all_packages:
                self.all_packages[longname] = [p.get('id')]
            else:
                self.all_packages[longname].append(p.get('id'))

    # keep a reverse dictionary so we can lookup package names by ID
    self.all_packages_by_id = {}
    for (k, v) in self.all_packages.iteritems():
        for i in v:
            self.all_packages_by_id[i] = k

    self.package_cache_expire = \
        datetime.now() + timedelta(seconds=self.PACKAGE_CACHE_TTL)

    self.save_package_caches()

    if not self.options.quiet:
        # restore the original line buffer
        self.replace_line_buffer()


def save_package_caches(self):
    # store the cache to disk to speed things up
    save_cache(self.packages_short_cache_file,
               self.all_packages_short,
               self.package_cache_expire)

    save_cache(self.packages_long_cache_file,
               self.all_packages,
               self.package_cache_expire)

    save_cache(self.packages_by_id_cache_file,
               self.all_packages_by_id,
               self.package_cache_expire)


# create a global list of all available package names
def get_package_names(self, longnames=False):
    self.generate_package_cache()

    if longnames:
        return self.all_packages.keys()
    else:
        return self.all_packages_short


def get_package_id(self, name):
    self.generate_package_cache()

    try:
        return set(self.all_packages[name])
    except KeyError:
        return


def get_package_name(self, package_id):
    self.generate_package_cache()

    try:
        return self.all_packages_by_id[package_id]
    except KeyError:
        return


def clear_system_cache(self):
    self.all_systems = {}
    self.system_cache_expire = datetime.now()
    self.save_system_cache()


def generate_system_cache(self, force=False, delay=0):
    if not force and datetime.now() < self.system_cache_expire:
        return

    if not self.options.quiet:
        # tell the user what's going on
        self.replace_line_buffer('** Generating system cache **')

    # we might need to wait for some systems to delete
    if delay:
        sleep(delay)

    systems = self.client.system.listSystems(self.session)

    self.all_systems = {}
    for s in systems:
        self.all_systems[s.get('id')] = s.get('name')

    self.system_cache_expire = \
        datetime.now() + timedelta(seconds=self.SYSTEM_CACHE_TTL)

    self.save_system_cache()

    if not self.options.quiet:
        # restore the original line buffer
        self.replace_line_buffer()


def save_system_cache(self):
    save_cache(self.system_cache_file,
               self.all_systems,
               self.system_cache_expire)


def load_caches(self, server):
    conf_dir = os.path.join(self.conf_dir, server)

    try:
        if not os.path.isdir(conf_dir):
            os.mkdir(conf_dir, 0700)
    except OSError:
        logging.error('Could not create directory %s', conf_dir)
        return

    self.ssm_cache_file = os.path.join(conf_dir, 'ssm')
    self.system_cache_file = os.path.join(conf_dir, 'systems')
    self.errata_cache_file = os.path.join(conf_dir, 'errata')
    self.packages_long_cache_file = os.path.join(conf_dir, 'packages_long')
    self.packages_by_id_cache_file = \
        os.path.join(conf_dir, 'packages_by_id')
    self.packages_short_cache_file = \
        os.path.join(conf_dir, 'packages_short')

    # load self.ssm from disk
    (self.ssm, _ignore) = load_cache(self.ssm_cache_file)

    # update the prompt now that we loaded the SSM
    self.postcmd(False, '')

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


def get_system_names(self):
    self.generate_system_cache()
    return self.all_systems.values()


# check for duplicate system names and return the system ID
def get_system_id(self, name):
    self.generate_system_cache()

    try:
        # check if we were passed a system instead of a name
        system_id = int(name)
        if system_id in self.all_systems:
            return system_id
    except ValueError:
        pass

    # get a set of matching systems to check for duplicate names
    systems = []
    for system_id in self.all_systems:
        if name == self.all_systems[system_id]:
            systems.append(system_id)

    if len(systems) == 1:
        return systems[0]
    elif not len(systems):
        logging.warning("Can't find system ID for %s", name)
        return 0
    else:
        logging.warning('Duplicate system profile names found!')
        logging.warning("Please reference systems by ID or resolve the")
        logging.warning("underlying issue with 'system_delete' or 'system_rename'")

        id_list = '%s = ' % name

        for system_id in systems:
            id_list = id_list + '%i, ' % system_id

        logging.warning('')
        logging.warning(id_list[:-2])

        return 0


def get_system_name(self, system_id):
    self.generate_system_cache()

    try:
        return self.all_systems[system_id]
    except KeyError:
        return


def get_org_id(self, name):
    details = self.client.org.getDetails(self.session, name)
    return details.get('id')


def expand_errata(self, args):
    if not isinstance(args, list):
        args = args.split()

    self.generate_errata_cache()

    if len(args) == 0:
        return self.all_errata

    errata = []
    for item in args:
        if re.match('search:', item):
            item = re.sub('search:', '', item)
            errata.extend(self.do_errata_search(item, True))
        else:
            errata.append(item)

    matches = filter_results(self.all_errata, errata)

    return matches


def expand_systems(self, args):
    if not isinstance(args, list):
        args = shlex.split(args)

    systems = []
    system_ids = []

    for item in args:
        if re.match('ssm', item, re.I):
            systems.extend(self.ssm)
        elif re.match('group:', item):
            item = re.sub('group:', '', item)
            members = self.do_group_listsystems("'%s'" % item, True)

            if len(members):
                systems.extend([re.escape(m) for m in members])
            else:
                logging.warning('No systems in group %s', item)
        elif re.match('search:', item):
            query = item.split(':', 1)[1]
            results = self.do_system_search(query, True)

            if len(results):
                systems.extend([re.escape(r) for r in results])
        elif re.match('channel:', item):
            item = re.sub('channel:', '', item)
            members = self.do_softwarechannel_listsystems(item, True)

            if len(members):
                systems.extend([re.escape(m) for m in members])
            else:
                logging.warning('No systems subscribed to %s', item)
        else:
            # translate system IDs that the user passes
            try:
                sys_id = int(item)
                system_ids.append(sys_id)
            except ValueError:
                # just a system name
                systems.append(item)

    matches = filter_results(self.get_system_names(), systems)

    return list(set(matches + system_ids))


def list_base_channels(self):
    all_channels = self.client.channel.listSoftwareChannels(self.session)

    base_channels = []
    for c in all_channels:
        if not c.get('parent_label'):
            base_channels.append(c.get('label'))

    return base_channels


def list_child_channels(self, system=None, parent=None, subscribed=False):
    channels = []

    if system:
        system_id = self.get_system_id(system)
        if not system_id:
            return

        if subscribed:
            channels = \
                self.client.system.listSubscribedChildChannels(self.session,
                                                               system_id)
        else:
            channels = self.client.system.listSubscribableChildChannels(
                self.session, system_id)
    elif parent:
        all_channels = \
            self.client.channel.listSoftwareChannels(self.session)

        for c in all_channels:
            if parent == c.get('parent_label'):
                channels.append(c)
    else:
        # get all channels that have a parent
        all_channels = \
            self.client.channel.listSoftwareChannels(self.session)

        for c in all_channels:
            if c.get('parent_label'):
                channels.append(c)

    return [c.get('label') for c in channels]


def user_confirm(self, prompt='Is this ok [y/N]:', nospacer=False,
                 integer=False, ignore_yes=False):

    if self.options.yes and not ignore_yes:
        return True

    if nospacer:
        answer = prompt_user('%s' % prompt)
    else:
        answer = prompt_user('\n%s' % prompt)

    if re.match('y', answer, re.I):
        if integer:
            return 1
        else:
            return True
    else:
        if integer:
            return 0
        else:
            return False


# check if the available API is recent enough
def check_api_version(self, want):
    want_parts = [int(i) for i in want.split('.')]
    have_parts = [int(i) for i in self.api_version.split('.')]

    if len(have_parts) == 2 and len(want_parts) == 2:
        if have_parts[0] == want_parts[0]:
            # compare minor versions if majors are the same
            return have_parts[1] >= want_parts[1]
        else:
            # only compare major versions if they differ
            return have_parts[0] >= want_parts[0]
    else:
        # compare the whole value
        return float(self.api_version) >= float(want)


# replace the current line buffer
def replace_line_buffer(self, msg=None):
    # restore the old buffer if we weren't given a new line
    if not msg:
        msg = readline.get_line_buffer()

    # don't print a prompt if there wasn't one to begin with
    if len(readline.get_line_buffer()):
        new_line = '%s%s' % (self.prompt, msg)
    else:
        new_line = '%s' % msg

    # clear the current line
    self.stdout.write('\r'.ljust(len(self.current_line) + 1))
    self.stdout.flush()

    # write the new line
    self.stdout.write('\r%s' % new_line)
    self.stdout.flush()

    # keep track of what is displayed so we can clear it later
    self.current_line = new_line


def load_config_section(self, section):
    config_opts = ['server', 'username', 'password', 'nossl']

    if not self.config_parser.has_section(section):
        logging.debug('Configuration section [%s] does not exist', section)
        return

    logging.debug('Loading configuration section [%s]', section)

    for key in config_opts:
        # don't override command-line options
        if self.options.__dict__[key]:
            # set the config value to the command-line argument
            self.config[key] = self.options.__dict__[key]
        else:
            try:
                self.config[key] = self.config_parser.get(section, key)
            except NoOptionError:
                pass

    # handle the nossl boolean
    if self.config.has_key('nossl') and isinstance(self.config['nossl'], str):
        if re.match('^1|y|true$', self.config['nossl'], re.I):
            self.config['nossl'] = True
        else:
            self.config['nossl'] = False

    # Obfuscate the password with asterisks
    config_debug = self.config.copy()
    if config_debug.has_key('password'):
        config_debug['password'] = "*" * len(config_debug['password'])

    logging.debug('Current Configuration: %s', config_debug)
