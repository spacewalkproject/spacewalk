#
# Copyright (c) 2012 Red Hat, Inc.
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

import sys
import getpass
import xmlrpclib

def getUsernamePassword(cmdlineUsername, cmdlinePassword):
    """
     Returns a username and password (either by returning the ones passed as
     args, or the user's input
    """
    if cmdlineUsername and cmdlinePassword:
        return cmdlineUsername, cmdlinePassword

    username = cmdlineUsername
    password = cmdlinePassword

    # Read the username, if not already specified
    tty = open("/dev/tty", "r+")
    while not username:
        tty.write("Red Hat Network username: ")
        try:
            username = tty.readline()
        except KeyboardInterrupt:
            tty.write("\n")
            sys.exit(0)
        if username is None:
            # EOF
            tty.write("\n")
            sys.exit(0)
        username = username.strip()
        if username:
            break

    # Now read the password
    while not password:
        try:
            password = getpass.getpass("Red Hat Network password: ")
        except KeyboardInterrupt:
            tty.write("\n")
            sys.exit(0)
        tty.close()
    return username, password

def xmlrpc_login(client, username, password, verbose=0):
    """
     Authenticate Session call
    """
    if verbose:
        print "...logging in to server..."

    try:
        sessionkey = client.auth.login(username, password)
    except xmlrpclib.Fault, e:
        sys.stderr.write("Error: %s\n" % e.faultString)
        sys.exit(-1)

    return sessionkey

def xmlrpc_logout(client, session_key, verbose=0):
    """
     End Authentication call
    """
    if verbose:
        print "...logging out of server..."

    client.auth.logout(session_key)
