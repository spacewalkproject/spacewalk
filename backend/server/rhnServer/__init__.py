#
# Copyright (c) 2008--2016 Red Hat, Inc.
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
# Module for handling the rhnServer objects.
#


# these are pretty much the only entry points
from spacewalk.common.usix import StringType, UnicodeType
from spacewalk.common.rhnException import rhnFault
from spacewalk.common.rhnLog import log_debug, log_error
from spacewalk.server import rhnUser

# Local imports
from server_class import Server
from server_certificate import Certificate
from server_token import fetch_token, fetch_org_token


def get(system_id, load_user=1):
    """ retrieve the server with matching certificate from the database """
    log_debug(3, "load_user = %s" % load_user)
    # This has to be a string
    if not isinstance(system_id, (StringType, UnicodeType)):
        return None
    # Try to initialize the certificate object
    cert = Certificate()
    if not cert.reload(system_id) == 0:
        return None
    # if invalid, stop here
    if not cert.valid():
        return None

    # this looks like a real server
    server = Server(None)
    # and load it up
    if not server.loadcert(cert, load_user) == 0:
        return None
    # okay, it is a valid certificate
    return server


def search(server_id, username=None):
    """ search for a server in the database and return the Server object """
    log_debug(3, server_id, username)
    s = Server(None)
    if not s.reload(server_id) == 0:
        log_error("Reloading server id %d failed" % server_id)
        # we can't say that the server is not really found
        raise rhnFault(20)
    # now that it is reloaded, fix up the s.user field
    if username:
        s.user = rhnUser.search(username)
    return s


def search_token(token):
    log_debug(3, token)
    return fetch_token(token)


def search_org_token(org_id):
    log_debug(3, org_id)
    return fetch_org_token(org_id)
