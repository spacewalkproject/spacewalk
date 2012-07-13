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
import socket
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
from up2date_client import up2dateAuth, config, up2dateErrors, rhncli


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

# quick check to see if you are a super-user.
if os.getuid() != 0:
    systemExit(8, _('ERROR: must be root to execute\n'))

def processCommandline():
    "process the commandline, setting the OPTIONS object"
    optionsTable = [
        Option('-c', '--channel',         action='append',
            help=_('name of channel you want to (un)subscribe')),
        Option('-a', '--add',             action='store_true',
            help=_('subscribe to channel')),
        Option('-r', '--remove',          action='store_true',
            help=_('unsubscribe from channel')),
        Option('-l', '--list',            action='store_true',
            help=_('list channels')),
        Option('-L', '--available-channels', action='store_true',
            help=_('list all available child channels')),
        Option('-v', '--verbose',         action='store_true',
            help=_('verbose output')),
        Option('-u', '--user',            action='store',
            help=_('your user name')),
        Option('-p', '--password',        action='store',
            help=_('your password')),
    ]
    optionParser = OptionParser(option_list=optionsTable)
    global OPTIONS
    OPTIONS, args = optionParser.parse_args()

    # we take no extra commandline arguments that are not linked to an option
    if args:
        systemExit(1, _("ERROR: these arguments make no sense in this context (try --help)"))
    if not OPTIONS.user and not OPTIONS.list:
        print _("Username: "),
        OPTIONS.user = sys.stdin.readline().rstrip('\n')
    if not OPTIONS.password and not OPTIONS.list:
        OPTIONS.password = getpass.getpass()

def get_available_channels(user, password):
    """ return list of available child channels """
    cfg = config.initUp2dateConfig()
    satellite_url = config.getServerlURL()[0]
    scheme, netloc, path, query, fragment = urlparse.urlsplit(satellite_url)
    satellite_url = urlparse.urlunsplit((scheme, netloc, '/rpc/api', query, fragment))
    client = xmlrpclib.Server(satellite_url, verbose=0)
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
    if OPTIONS.add:
        need_channel(OPTIONS.channel)
        result = subscribeChannels(OPTIONS.channel, OPTIONS.user, OPTIONS.password)
        if OPTIONS.verbose:
            if result == 0:
                print _("Channel(s): %s successfully added") % ', '.join(OPTIONS.channel)
            else:
                sys.stderr.write(rhncli.utf8_encode(_("Error during adding channel(s) %s") % ', '.join(OPTIONS.channel)))
        if result != 0:
            sys.exit(result)
    elif OPTIONS.remove:
        need_channel(OPTIONS.channel)
        result = unsubscribeChannels(OPTIONS.channel, OPTIONS.user, OPTIONS.password)
        if OPTIONS.verbose:
            if result == 0:
                print _("Channel(s): %s successfully removed") % ', '.join(OPTIONS.channel)
            else:
                sys.stderr.write(rhncli.utf8_encode(_("Error during removal of channel(s) %s") % ', '.join(OPTIONS.channel)))
        if result != 0:
            sys.exit(result)
    elif OPTIONS.list:
        try:
            channels = map(lambda x: x['label'], getChannels().channels())
        except up2dateErrors.NoChannelsError:
            systemExit(1, _('This system is not associated with any channel.'))
        except up2dateErrors.NoSystemIdError:
            systemExit(1, _('Unable to locate SystemId file. Is this system registered?'))
        channels.sort()
        print '\n'.join(channels)
    elif OPTIONS.available_channels:
        channels = get_available_channels(OPTIONS.user, OPTIONS.password)
        channels.sort()
        print '\n'.join(channels)
    else:
        systemExit(3, _("ERROR: you may want to specify --add, --remove or --list"))

try:
    sys.excepthook = rhncli.exceptionHandler
    processCommandline()
    main()
except KeyboardInterrupt:
    systemExit(0, "\n" + _("User interrupted process."))
except up2dateErrors.RhnServerException, e:
    # do not print traceback, it will scare people
    systemExit(1, e)
