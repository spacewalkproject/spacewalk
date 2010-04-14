#
# Copyright (c) 2008 Red Hat, Inc.
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

# system module import
import time

# common module imports
from common import CFG, rhnFault, rhnFlags, log_debug, log_error, UserDictCase
from common.rhnTranslate import _

# local module imports
from server.rhnLib import computeSignature

from server import rhnServer, rhnHandler, rhnSQL, apacheAuth, rhnPackage

# a class that provides additional authentication support for the
# proxy functions
class rhnProxyHandler(rhnHandler):
    def __init__(self):
        rhnHandler.__init__(self)

    def auth_system(self, system_id):
        """ System authentication. We override the standard function because
            we need to check additionally if this system_id is entitled for
            proxy functionality.
        """
        log_debug(3)        
        server = rhnHandler.auth_system(self, system_id)
        # if it did not blow up, we have a valid server. Check proxy
        # entitlement.
        # XXX: this needs to be moved out of the rhnServer module,
        # possibly in here
        h = rhnSQL.prepare("""
        select 1
        from rhnProxyInfo pi
        where pi.server_id = :server_id
        """)
        h.execute(server_id = self.server_id)
        row = h.fetchone_dict()
        if not row:
            # we require entitlement for this functionality
            log_error("Server not entitled for Proxy", self.server_id)
            raise rhnFault(1002, _(
                'RHN Proxy service not enabled for server profile: "%s"')
                           % server.server["name"])
        # we're fine...
        return server

    def auth_client(self, token):
        """ Authenticate a system based on the same authentication tokens
            the client is sending for GET requests
        """
        log_debug(3)
        # Build a UserDictCase out of the token
        dict = UserDictCase(token)
        # Set rhnFlags so that we can piggyback on apacheAuth's auth_client
        rhnFlags.set('AUTH_SESSION_TOKEN', dict)

        # XXX To clean up apacheAuth.auth_client's logging, this is not about
        # GET requests
        result = apacheAuth.auth_client()

        if not result:
            raise rhnFault(33, _("Invalid session key"))

        log_debug(4, "Client auth OK")
        # We checked it already, so we're sure it's there
        client_id = dict['X-RHN-Server-Id']
        
        server = rhnServer.search(client_id)
        if not server:
            raise rhnFault(8, _("This server ID no longer exists"))
        # XXX: should we check if the username still has access to it? 
        # probably not, because there is no known good way we can
        # update the server system_id on the client side when
        # permissions change... Damn it. --gafton
        self.server = server
        self.server_id = client_id
        self.user = dict['X-RHN-Auth-User-Id']
        return server

    
class Proxy(rhnProxyHandler):
    """ this is the XML-RPC receiver for proxy calls """
    def __init__(self):
        log_debug(3)
        rhnProxyHandler.__init__(self)
        self.functions.append('package_source_in_channel')
        self.functions.append('login')

    def package_source_in_channel(self, package, channel, auth_token):
        """ Validates the client request for a source package download """
        log_debug(3, package, channel)
        server = self.auth_client(auth_token)
        return rhnPackage.package_source_in_channel(self.server_id, 
            package, channel)

    def login(self, system_id):
        """ Login routine for the proxy

            Return a formatted string of session token information as regards
            an RHN Proxy.  Also sets this information in the headers.

            NOTE: design description for the auth token format and how it is
               is used is well documented in the proxy/broker/rhnProxyAuth.py
               code.
        """
        log_debug(5, system_id)
        # Authenticate. We need the user record to be able to generate
        # auth tokens
        self.load_user = 1        
        self.auth_system(system_id)
        # log the entry
        log_debug(1, self.server_id)
        rhnServerTime = str(time.time())
        expireOffset = str(CFG.PROXY_AUTH_TIMEOUT)
        signature = computeSignature(CFG.SECRET_KEY, self.server_id, self.user,
                                     rhnServerTime, expireOffset)
        
        token = '%s:%s:%s:%s:%s' % (self.server_id, self.user, rhnServerTime,
                                    expireOffset, signature)

        # NOTE: for RHN Proxies of version 3.1+ tokens are passed up in a
        #       multi-valued header with HOSTNAME tagged onto the end of the
        #       token, so, it looks something like this:
        #           x-rhn-proxy-auth: 'TOKEN1:HOSTNAME1,TOKEN2:HOSTNAME2'
        #       This note is only that -- a "heads up" -- in case anyone gets
        #       confused.

        # Push this value into the headers so that the proxy can
        # intercept and cache it without parsing the xmlrpc.
        transport = rhnFlags.get('outputTransportOptions')
        transport['X-RHN-Action'] = 'login'
        transport['X-RHN-Proxy-Auth'] = token
        return token


#-----------------------------------------------------------------------------

