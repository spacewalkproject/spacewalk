# Red Hat Network Proxy Server Broker handler code.
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
# $Id: rhnBroker.py,v 1.208 2007/07/31 11:04:01 msuchy Exp $

# system module imports
import time
import string
import socket
import re

# global module imports
from common import apache

# common module imports
from common.rhnLib import parseUrl
from common import UserDictCase, rhnFlags, log_debug, log_error, CFG, \
    rhnFault, rhnException
from common.rhnTranslate import _

# local module imports
from proxy.rhnShared import SharedHandler
import rhnRepository
import proxy.rhnProxyAuth


# the version should not be never decreased, never mind that spacewalk has different versioning
_PROXY_VERSION = '5.3.1' # HISTORY: '0.9.7', '3.2.0', '3.5.0', '3.6.0', '4.1.0', '4.2.0', '5.0.0', '5.1.0', '5.2.0', '0.1', '5.3.0' '5.3.1'


class BrokerHandler(SharedHandler):
    """ RHN Proxy broker specific handler code called by rhnApache. 

        Workflow is:
        Client -> Apache:Broker -> Squid -> Apache:Redirect -> Satellite

        Broker handler get request from clients from outside. Some request
        (POST and HEAD) bypass cache so, it is passed directly to parent.
        For everything else we transform destination to localhost:80 (which
        is handled by Redirect handler) and set proxy as local squid. 
        This way we got all request cached localy by squid.
    """

    def __init__(self, req):
        SharedHandler.__init__(self, req)

        # Initialize variables
        self.componentType = 'proxy.broker'
        self.cachedClientInfo = None # headers - session token
        self.authChannels = None
        self.clientServerId = None
        hostname = ''
        if req.headers_in.has_key('Host'):
            hostname = req.headers_in['Host'] or ''
        if not hostname:
            # this shouldn't happen
            # socket.gethostname is a punt. Shouldn't need to do it.
            hostname = socket.gethostname()
            log_debug(-1, 'WARNING: no hostname in the incoming headers; '
                          'punting: %s' % hostname)
        hostname = string.split(parseUrl(hostname)[1], ':')[0]
        self.proxyAuth =  proxy.rhnProxyAuth.get_proxy_auth(hostname)

        self._initConnectionVariables(req)

    def _initConnectionVariables(self, req):
        """ set connection variables 
            NOTE: self.{caChain,rhnParent,httpProxy*} are initialized
                  in SharedHandler
        
            rules:
                - GET requests:
                      . are non-SSLed (potentially SSLed by the redirect)
                      . use the local cache
                      . CFG.HTTP_PROXY or CFG.USE_SSL:
                          . use the SSL Redirect
                            (i.e., parent is now 127.0.0.1)
                          . NOTE: the reason we use the SSL Redirect if we
                                  are going through an outside HTTP_PROXY:
                                  o CFG.HTTP_PROXY is ONLY used by an SSL
                                    redirect - maybe should rethink that.
                      . not CFG.USE_SSL and not CFG.HTTP_PROXY:
                          . bypass the SSL Redirect (performance)
                - POST and HEAD requests (not GET) bypass both the local cache
                       and SSL redirect (we SSL it directly)
        """

        scheme = 'http'
        # self.{caChain,httpProxy*,rhnParent} initialized in rhnShared.py

        if req.method == 'GET':
            scheme = 'http'
            self.httpProxy = CFG.SQUID
            self.caChain = self.httpProxyUsername = self.httpProxyPassword = ''
            if CFG.HTTP_PROXY or CFG.USE_SSL or re.search('^/ty-cksm/', self._getEffectiveURI()):
                # o if we need to go through an outside HTTP proxy, use the
                #   redirect
                # o if an SSL request, use the redirect
                # o otherwise (non-ssl and not going through an outside HTTP
                #   proxy) bypass that redirect for performance
                self.rhnParent = '127.0.0.1'
        else:
            # !GET: bypass cache, bypass redirect
            if CFG.USE_SSL:
                scheme = 'https'
            else:
                scheme = 'http'
                self.caChain = ''

        self.rhnParentXMLRPC = scheme + '://' + self.rhnParent + '/XMLRPC'
        self.rhnParent = scheme + \
                         '://' + \
                         self.rhnParent + \
                         self._getEffectiveURI()

        log_debug(2, 'set self.rhnParent:       %s' % self.rhnParent)
        log_debug(2, 'set self.rhnParentXMLRPC: %s' % self.rhnParentXMLRPC)
        if self.httpProxy:
            if self.httpProxyUsername and self.httpProxyPassword:
                log_debug(2, 'using self.httpProxy:     %s (authenticating)' % self.httpProxy)
            else:
                log_debug(2, 'using self.httpProxy:     %s (non-authenticating)' % self.httpProxy)
        else:
            log_debug(2, '*not* using an http proxy')

    def handler(self):
        """ Main handler to handle all requests pumped through this server. """

        log_debug(1)
        self._prepHandler()

        _oto = rhnFlags.get('outputTransportOptions')

        # tell parent that we can follow redirects, even if client is not able to
        _oto['X-RHN-Transport-Capability'] = "follow-redirects=3"

        # No reason to put Host: in the header, the connection object will
        # do that for us

        # Add/modify the X-RHN-IP-Path header.
        ip_path = _oto['X-RHN-IP-Path']
        log_debug(4, "X-RHN-IP-Path is: %s" % repr(ip_path))
        client_ip = self.req.connection.remote_ip
        if ip_path is None:
            ip_path = client_ip
        else:
            ip_path += ',' + client_ip
        _oto['X-RHN-IP-Path'] = ip_path
            
        # NOTE: X-RHN-Proxy-Auth described in broker/rhnProxyAuth.py
        log_debug(5, 'X-RHN-Proxy-Auth currently set to: %s' % repr(_oto['X-RHN-Proxy-Auth']))

        if self.req.headers_in.has_key('X-RHN-Proxy-Auth'):
            tokens = string.split(_oto['X-RHN-Proxy-Auth'], ',')
            log_debug(5, 'Tokens: %s' % tokens)

        # GETs: authenticate user, and service local GETs.
        getResult = self.__local_GET_handler(self.req)
        if getResult is not None:
            # it's a GET request
            return getResult

        # 1. check cached version of the proxy login,
        #    snag token if there...
        #    if not... login...
        #    if good token, cache it.
        # 2. push into headers.
        authToken = self.proxyAuth.check_cached_token()
        log_debug(5, 'XXX auth token for this machine only! %s' % authToken)
        tokens = []

        _oto = rhnFlags.get('outputTransportOptions')
        if _oto.has_key('X-RHN-Proxy-Auth'):
            log_debug(5, 'XXX (auth token prior): %s'
                         % repr(_oto['X-RHN-Proxy-Auth']))
            tokens = string.split(_oto['X-RHN-Proxy-Auth'], ',')

        # list of tokens to be pushed into the headers.
        tokens.append(authToken)
        tokens = filter(lambda token: token, tokens)

        _oto['X-RHN-Proxy-Auth'] = string.join(tokens, ',')
        log_debug(5, 'XXX (auth token after): %s'
                      % repr(_oto['X-RHN-Proxy-Auth']))

        log_debug(3, 'Trying to connect to parent')
        data = self.req.read()
            
        # Loops twice? Here's why:
        #   o If no errors, the loop is broken and we move on.
        #   o If an error, either we get a new token and try again,
        #     or we get a critical error and we fault.
        for i in range(2):
            self._connectToParent()  # part 1

            log_debug(4, 'after _connectToParent')
            # Add the proxy version
            rhnFlags.get('outputTransportOptions')['X-RHN-Proxy-Version'] = str(_PROXY_VERSION)

            status = self._serverCommo(data)       # part 2

            # check for proxy authentication blowup.
            respHeaders = self.responseContext.getHeaders()
            if not respHeaders or \
               not respHeaders.has_key('X-RHN-Proxy-Auth-Error'):
                # No proxy auth errors
                # XXX: need to verify that with respHeaders ==
                #      None that is is correct logic. It should be -taw
                break

            # Expired/invalid auth token; go through the loop once again
            error = string.split(respHeaders['X-RHN-Proxy-Auth-Error'], ':')[0]
            if error == '1003': # invalid token
                msg = "RHN Proxy Session Token INVALID -- bad!"
                log_error(msg)
                log_debug(0, msg)
            elif error == '1004':
                log_debug(1,
                    "RHN Proxy Session Token expired, acquiring new one.")
            else: # this should never happen.
                msg = "RHN Proxy login failed, error code is %s" % error
                log_error(msg)
                log_debug(0, msg)
                raise rhnFault(1000,
                  _("RHN Proxy error (issues with proxy login). "
                    "Please contact your system administrator."))

            # Forced refresh of the proxy token
            rhnFlags.get('outputTransportOptions')['X-RHN-Proxy-Auth'] = self.proxyAuth.check_cached_token(1)
        else: #for
            # The token could not be aquired
            log_debug(0, "Unable to acquire proxy authentication token")
            raise rhnFault(1000,
              _("RHN Proxy error (unable to acquire proxy auth token). "
                "Please contact your system administrator."))

        # Support for yum byte-range
        if (status != apache.OK) and (status != apache.HTTP_PARTIAL_CONTENT):
            log_debug(1, "Leaving handler with status code %s" % status)
            return status

        self.__handleAction(self.responseContext.getHeaders())

        return self._clientCommo()

    def _prepHandler(self):
        """ prep handler and check PROXY_AUTH's expiration. """
        SharedHandler._prepHandler(self)

    # --- PRIVATE METHODS ---

    def __handleAction(self, headers):
        log_debug(1)
        # Check if proxy is interested in this action, and execute any
        # action required:
        if not headers.has_key('X-RHN-Action'):
            # Don't know what to do
            return

        log_debug(2, "Action is %s" % headers['X-RHN-Action'])
        # Now, is it a login? If so, cache the session token.
        if headers['X-RHN-Action'] != 'login':
            # Don't care
            return

        # A login. Cache the session token
        self.__cacheClientSessionToken(headers)

    def __local_GET_handler(self, req):
        """ GETs: authenticate user, and service local GETs.
            if not a local fetch, return None
        """

        # Early test to check if this is a request the proxy can handle
        log_debug(2, 'request method: %s' % req.method)
        if req.method != "GET":
            # Don't know how to handle this
            return None

        # Split the URI to find out if we should take care of this.
        # URI should look something like:
        # /$RHN/redhat-linux-i386-7.1/getPackage/abiword-0.7.13.2.i386.rpm
        # NOTE: it splits to ['', '$RHN', label, channel, ...]
        args = string.split(req.path_info, '/')
        if not args or len(args) < 2 or (args[1] != '$RHN' and args[1] != 'GET-REQ'):
            # not a traditional RHN GET (i.e., it is an arbitrary get)
            # XXX: there has to be a more elegant way to do this
            return None
        reqchannel = args[2]
        reqaction = args[3]
        reqparams = args[4:]

        # --- AUTH. CHECK:
        # Check client authentication. If not authenticated, throw
        # an exception.
        token = self.__getSessionToken()
        self.__checkAuthSessionTokenCache(token, reqchannel)

        # --- LOCAL GET:
        localFlist = CFG.PROXY_LOCAL_FLIST or []

        # Can we serve this request?
        if not CFG.PKG_DIR:
            return None

        if reqaction not in localFlist:
            # Not an action we know how to handle
            return None

        # Is this channel local?
        for ch in self.authChannels:
            channel, version, isBaseChannel, isLocalChannel = ch[:4]
            if channel == reqchannel and str(isLocalChannel) == '1':
                # Local channel
                break
        else:
            # Not a local channel
            return None

        # We have a match; we'll try to serve packages from the local
        # repository
        log_debug(3, "Retrieve from local repository.")
        log_debug(3, reqchannel, reqaction, reqparams)
        result = self.__callLocalRepository(reqchannel, reqaction, reqparams)
        if result is None:
            log_debug(3, "Not available locally; will try higher up the chain.")
        else:
            # Signal that we have to XMLRPC encode the response in apacheHandler
            #log_debug(0, 'XXXXXXXXX result is not None XXXXXXXXXX')
            rhnFlags.set("NeedEncoding", 1)

        return result

    def __getSessionToken(self):
        """ Get/test-for session token in headers (rhnFlags) """
        log_debug(1)
        if not rhnFlags.test("AUTH_SESSION_TOKEN"):
            raise rhnFault(33, "Missing session token")
        return rhnFlags.get("AUTH_SESSION_TOKEN")

    def __cacheClientSessionToken(self, headers):
        """pull session token from headers and push to caching daemon. """

        log_debug(1)
        # Get the server ID
        if not headers.has_key('X-RHN-Server-ID'):
            log_debug(3, "Client server ID not found in headers")
            # XXX: no client server ID in headers, should we care?
            #raise rhnFault(1000, _("Client Server ID not found in headers!"))
            return
        serverId = 'X-RHN-Server-ID'

        self.clientServerId = headers[serverId]
        token = UserDictCase()

        # The session token contains everything that begins with
        # "x-rhn-auth"
        prefix = "x-rhn-auth"
        l = len(prefix)
        tokenKeys = filter(
            lambda x, p = prefix, l = l: string.lower(x[:l]) == p,
            headers.keys())
        for k in tokenKeys:
            if string.lower(k) == 'x-rhn-auth-channels':
                # Multivalued header
                #values = headers.getHeaderValues(k)
                values = self._get_header(k)
                token[k] = map(lambda x: string.split(x, ':'), values)
            else:
                # Single-valued header
                token[k] = headers[k]

        # Dump the proxy's clock skew in the dict
        serverTime = float(token['X-RHN-Auth-Server-Time'])
        token["X-RHN-Auth-Proxy-Clock-Skew"] = time.time() - serverTime

        # Save the token
        _writeToCache(self.clientServerId, token)
        return token

    # To service items from local repository.
    def __callLocalRepository(self, channelName, funct, params):
        """ Contacts the local repository and retrieves files
        
            URI looks like:
              /$RHN/<channel>/<function>/<params>
        """

        log_debug(2, channelName, funct, params)

        # Find the channel version
        version = None
        for c in self.authChannels:
            ch, ver = c[:2]
            if ch == channelName:
                version = ver
                break

        # NOTE: X-RHN-Proxy-Auth described in broker/rhnProxyAuth.py
        if rhnFlags.get('outputTransportOptions').has_key('X-RHN-Proxy-Auth'):
            self.cachedClientInfo['X-RHN-Proxy-Auth'] = rhnFlags.get('outputTransportOptions')['X-RHN-Proxy-Auth']
        if rhnFlags.get('outputTransportOptions').has_key('Host'):
            self.cachedClientInfo['Host'] = rhnFlags.get('outputTransportOptions')['Host']

        # We already know he's subscribed to this channel
        # channel, so the version is non-null
        rep = rhnRepository.Repository(channelName, version,
                                       self.cachedClientInfo,
                                       rhnParent=self.rhnParent,
                                       rhnParentXMLRPC=self.rhnParentXMLRPC,
                                       httpProxy=self.httpProxy,
                                       httpProxyUsername=self.httpProxyUsername,
                                       httpProxyPassword=self.httpProxyPassword,
                                       caChain=self.caChain)

        f = rep.get_function(funct)
        if not f:
            raise rhnFault(1000,
                _("RHN Proxy configuration error: invalid function %s") % funct)

        log_debug(3, "Calling %s(%s)" % (funct, params))
        try:
            if params:
                ret = apply(f, params)
            else:
                ret = f()
        except rhnRepository.NotLocalError:
            # The package is not local
            return None
        return ret

    def __checkAuthSessionTokenCache(self, token, channel):
        """ Authentication / authorize the channel """

        log_debug(2, token, channel)
        self.clientServerId = token['X-RHN-Server-ID']

        shelf = proxy.rhnProxyAuth.get_auth_shelf()
        if not shelf.has_key(self.clientServerId):
            # should this ever happen?
            msg = _("Invalid session key - server ID not found in cache: %s") \
                  % self.clientServerId
            log_error(msg)
            raise rhnFault(33, msg)

        self.cachedClientInfo = UserDictCase(shelf[self.clientServerId])

        clockSkew = self.cachedClientInfo["X-RHN-Auth-Proxy-Clock-Skew"]
        del self.cachedClientInfo["X-RHN-Auth-Proxy-Clock-Skew"]

        # Add the server id
        self.authChannels = self.cachedClientInfo['X-RHN-Auth-Channels']
        del self.cachedClientInfo['X-RHN-Auth-Channels']
        self.cachedClientInfo['X-RHN-Server-ID'] = self.clientServerId
        log_debug(4, 'Retrieved token from cache: %s' % self.cachedClientInfo)

        # Compare the two things
        if not _dictEquals(token, self.cachedClientInfo,
                            ['X-RHN-Auth-Channels']):
            log_debug(3, "Session tokens different")
            raise rhnFault(33) # Invalid session key

        # Check the expiration
        serverTime = float(token['X-RHN-Auth-Server-Time'])
        offset = float(token['X-RHN-Auth-Expire-Offset'])
        if time.time() > serverTime + offset + clockSkew:
            log_debug(3, "Session token has expired")
            raise rhnFault(34) # Session key has expired

        # Only autherized channels are the ones stored in the cache.
        authChannels = map(lambda x: x[0], self.authChannels)
        log_debug(4, "Auth channels: '%s'" % authChannels)
        # Check the authorization
        if channel not in authChannels:
            log_debug(4, "Not subscribed to channel %s; unauthorized" %
                channel)
            raise rhnFault(35, _('Unauthorized channel access requested.'))


def _dictEquals(d1, d2, exceptions=[]):
    """ Function that compare two dictionaries, ignoring certain keys """
    exceptions = map(string.lower, exceptions)
    for k, v in d1.items():
        if string.lower(k) in exceptions:
            continue
        if not d2.has_key(k) or d2[k] != v:
            return 0
    for k, v in d2.items():
        if string.lower(k) in exceptions:
            continue
        if not d1.has_key(k) or d1[k] != v:
            return 0
    return 1


def _writeToCache(key, value):
    """ Open a connection to the shelf """
    shelf = proxy.rhnProxyAuth.get_auth_shelf()
    # Cache the thing
    shelf[key] = value
    log_debug(2, "successfully returning")

#===============================================================================

