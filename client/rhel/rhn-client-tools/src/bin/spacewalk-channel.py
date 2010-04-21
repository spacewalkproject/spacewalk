#!/usr/bin/python
#
# Copyright (c) 2009 Red Hat, Inc.
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
import os
import socket
import sys
import getpass

from optparse import Option, OptionParser

def systemExit(code, msgs=None):
     "Exit with a code and optional message(s). Saved a few lines of code."
     if msgs:
         if type(msgs) not in [type([]), type(())]:
             msgs = (msgs, )
         for msg in msgs:
             sys.stderr.write(str(msg)+'\n')
     sys.exit(code)

# quick check to see if you are a super-user.
if os.getuid() != 0:
    systemExit(8, 'ERROR: must be root to execute\n')

_LIBPATH = "/usr/share/rhn"
# add to the path if need be
if _LIBPATH not in sys.path:
    sys.path.append(_LIBPATH)

from up2date_client.rhnChannel import subscribeChannels, unsubscribeChannels, getChannels
from up2date_client import up2dateAuth, config, up2dateErrors

def processCommandline():
    "process the commandline, setting the OPTIONS object"
    optionsTable = [
        Option('-c', '--channel',         action='append',
            help='name of channel you want to (un)subscribe'),
        Option('-a', '--add',             action='store_true',
            help='subscribe to channel'),
        Option('-r', '--remove',          action='store_true',
            help='unsubscribe from channel'),
        Option('-l', '--list',            action='store_true',
            help='list channels'),
        Option('-v', '--verbose',         action='store_true',
            help='verbose output'),
        Option('-u', '--user',            action='store',
            help='your user name'),
        Option('-p', '--password',        action='store',
            help='your password'),
    ]
    optionParser = OptionParser(option_list=optionsTable)
    global OPTIONS
    OPTIONS, args = optionParser.parse_args()

    # we take no extra commandline arguments that are not linked to an option
    if args:
        systemExit(1, "ERROR: these arguments make no sense in this context (try --help)")
    if not OPTIONS.user and not OPTIONS.list:
        print "Username: ",
        OPTIONS.user = sys.stdin.readline().rstrip('\n')
    if not OPTIONS.password and not OPTIONS.list:
        OPTIONS.password = getpass.getpass()

def main():
    if OPTIONS.add:
        subscribeChannels(OPTIONS.channel, OPTIONS.user, OPTIONS.password)
        if OPTIONS.verbose:
            print "Channel(s): %s successfully added" % ', '.join(OPTIONS.channel)
    elif OPTIONS.remove:
        unsubscribeChannels(OPTIONS.channel, OPTIONS.user, OPTIONS.password)
        if OPTIONS.verbose:
            print "Channel(s): %s successfully removed" % ', '.join(OPTIONS.channel)
    elif OPTIONS.list:
        channels = map(lambda x: x['label'], getChannels().channels())
        channels.sort()
        print '\n'.join(channels)
    else:
        s = rhnserver.RhnServer()
        print s.up2date.listall(up2dateAuth.getSystemId())
        systemExit(3, "ERROR: you may want to specify --add, --remove or --list")

try:
    processCommandline()
    main()
except KeyboardInterrupt:
    systemExit(0, "\nUser interrupted process.")
except up2dateErrors.RhnServerException, e:
    # do not print traceback, it will scare people
    systemExit(1, e)
