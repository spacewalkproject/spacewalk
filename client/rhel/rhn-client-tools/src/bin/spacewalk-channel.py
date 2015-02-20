#!/usr/bin/python
#
# Copyright (c) 2009--2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#
import getpass
import os
import re
import sys
import urlparse
import xmlrpclib
from rhn import rpclib

from optparse import Option, OptionParser

import gettext
t = gettext.translation('rhn-client-tools', fallback=True)
_ = t.ugettext

_LIBPATH = "/usr/share/rhn"
# add to the path if need be
if _LIBPATH not in sys.path:
    sys.path.append(_LIBPATH)

from up2date_client.rhnChannel import subscribeChannels, unsubscribeChannels, getChannels
from up2date_client import up2dateAuth, config, up2dateErrors, rhncli, rhnserver


class Credentials(object):
    def __init__(self, username=None, password=None):
        if username is not None:
            self.user = username
        if password is not None:
            self.password = password

    def __getattr__(self, attr):
        if attr == 'user':
            tty = open("/dev/tty", "r+")
            tty.write('Username: ')
            tty.close()
            setattr(self, 'user', sys.stdin.readline().rstrip('\n'))
            return self.user
        elif attr == 'password':
            # force user population
            _user = self.user

            setattr(self, 'password', getpass.getpass())
            return self.password
        else:
            raise AttributeError(attr)

    def user_callback(self, _option, _opt_str, value, _parser):
        self.user = value

    def password_callback(self, _option, _opt_str, value, _parser):
        self.password = value


def systemExit(code, msgs=None):
    "Exit with a code and optional message(s). Saved a few lines of code."
    if msgs is not None:
        if type(msgs) not in [type([]), type(())]:
            msgs = (msgs, )
        for msg in msgs:
            if hasattr(msg, 'value'):
                msg = msg.value
            sys.stderr.write(rhncli.utf8_encode(msg) + "\n")
    sys.exit(code)


def processCommandline():
    "process the command-line"
    credentials = Credentials()

    optionsTable = [
        Option('-c', '--channel',         action='append',
            help=_('name of channel you want to (un)subscribe')),
        Option('-a', '--add',             action='store_true',
            help=_('subscribe to channel')),
        Option('-r', '--remove',          action='store_true',
            help=_('unsubscribe from channel')),
        Option('-l', '--list',            action='store_true',
            help=_('list channels')),
        Option('-b', '--base',            action='store_true',
            help=_('show base channel of a system')),
        Option('-L', '--available-channels', action='store_true',
            help=_('list all available child channels')),
        Option('-v', '--verbose',         action='store_true',
            help=_('verbose output')),
        Option('-u', '--user', action='callback', callback=credentials.user_callback,
               nargs=1, type='string', help=_('your user name')),
        Option('-p', '--password', action='callback', callback=credentials.password_callback,
               nargs=1, type='string', help=_('your password')),
    ]
    optionParser = OptionParser(option_list=optionsTable)
    opts, args = optionParser.parse_args()

    # we take no extra commandline arguments that are not linked to an option
    if args:
        systemExit(1, _("ERROR: these arguments make no sense in this context (try --help)"))

    # remove confusing stuff
    delattr(opts, 'user')
    delattr(opts, 'password')

    return opts, credentials


def get_available_channels(user, password):
    """ return list of available child channels """
    modified_servers = []
    servers = config.getServerlURL()
    for server in servers:
        scheme, netloc, path, query, fragment = urlparse.urlsplit(server)
        modified_servers.append(urlparse.urlunsplit((scheme, netloc, '/rpc/api', query, fragment)))
    client = rhnserver.RhnServer(serverOverride=modified_servers)
    try:
        key = client.auth.login(user, password)
    except xmlrpclib.Fault, exc:
        systemExit(1, "Error during client authentication: %s" % exc.faultString)

    system_id = re.sub('^ID-', '', rpclib.xmlrpclib.loads(up2dateAuth.getSystemId())[0][0]['system_id'])
    result = []
    try:
        channels = client.system.listChildChannels(key, int(system_id))
    except xmlrpclib.Fault, exc:
        systemExit(1, "Error when listing child channels: %s" % exc.faultString)

    for channel in channels:
        if 'LABEL' in channel:
            result.extend([channel['LABEL']])
        else:
            result.extend([channel['label']])
    return result

def need_channel(channel):
    """ die gracefuly if channel is empty """
    if not channel:
        systemExit(4, _("ERROR: you have to specify at least one channel"))

def main():
    options, credentials = processCommandline()

    if options.add:
        need_channel(options.channel)
        result = subscribeChannels(options.channel, credentials.user, credentials.password)
        if options.verbose:
            if result == 0:
                print _("Channel(s): %s successfully added") % ', '.join(options.channel)
            else:
                sys.stderr.write(rhncli.utf8_encode(_("Error during adding channel(s) %s") % ', '.join(options.channel)))
        if result != 0:
            sys.exit(result)
    elif options.remove:
        need_channel(options.channel)
        result = unsubscribeChannels(options.channel, credentials.user, credentials.password)
        if options.verbose:
            if result == 0:
                print _("Channel(s): %s successfully removed") % ', '.join(options.channel)
            else:
                sys.stderr.write(rhncli.utf8_encode(_("Error during removal of channel(s) %s") % ', '.join(options.channel)))
        if result != 0:
            sys.exit(result)
    elif options.list:
        try:
            channels = map(lambda x: x['label'], getChannels().channels())
        except up2dateErrors.NoChannelsError:
            systemExit(1, _('This system is not associated with any channel.'))
        except up2dateErrors.NoSystemIdError:
            systemExit(1, _('Unable to locate SystemId file. Is this system registered?'))
        channels.sort()
        print '\n'.join(channels)
    elif options.base:
        try:
            for channel in getChannels().channels():
                # Base channel has no parent
                if not channel['parent_channel']:
                    print channel['label']
        except up2dateErrors.NoChannelsError:
            systemExit(1, 'This system is not associated with any channel.')
        except up2dateErrors.NoSystemIdError:
            systemExit(1, 'Unable to locate SystemId file. Is this system registered?')

    elif options.available_channels:
        channels = get_available_channels(credentials.user, credentials.password)
        channels.sort()
        print '\n'.join(channels)
    else:
        systemExit(3, _("ERROR: you may want to specify --add, --remove or --list"))

if __name__ == '__main__':
    # quick check to see if you are a super-user.
    if os.getuid() != 0:
        systemExit(8, _('ERROR: must be root to execute\n'))
    try:
        sys.excepthook = rhncli.exceptionHandler
        main()
    except KeyboardInterrupt:
        systemExit(0, "\n" + _("User interrupted process."))
    except up2dateErrors.RhnServerException, e:
        # do not print traceback, it will scare people
        systemExit(1, e)
else:
    # If you need some code from here, separate it to some proper place...
    raise ImportError('This was never supposed to be called as library')
