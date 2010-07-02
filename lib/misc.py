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

# vim:ts=4:expandtab:
