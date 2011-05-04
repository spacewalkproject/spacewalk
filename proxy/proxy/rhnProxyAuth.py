# RHN Proxy Server authentication manager.
#
# Copyright (c) 2008--2011 Red Hat, Inc.
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
# -----------------------------------------------------------------------------
# $Id: rhnProxyAuth.py,v 1.64 2006/04/05 15:35:43 taw Exp $

## system imports
import os
import time
import string
import socket
import xmlrpclib

## local imports
import rhnAuthCacheClient
from rhn import rpclib
from rhn import SSL

## common imports
from spacewalk.common.rhnLib import parseUrl
from spacewalk.common.rhnTB import Traceback
from spacewalk.common.rhnLog import log_debug, log_error
from spacewalk.common.rhnConfig import CFG
from spacewalk.common.rhnException import rhnFault
from spacewalk.common import rhnCache
from spacewalk.common.rhnTranslate import _


# To avoid doing unnecessary work, keep ProxyAuth object global
__PROXY_AUTH = None
def get_proxy_auth(hostname=None):
    global __PROXY_AUTH
    if not __PROXY_AUTH:
        __PROXY_AUTH = ProxyAuth(hostname)
    if __PROXY_AUTH.hostname != hostname:
        __PROXY_AUTH = ProxyAuth(hostname)
    return __PROXY_AUTH


class ProxyAuth:

    __serverid = None
    __systemid = None
    __systemid_mtime= None
    __systemid_filename = '/etc/sysconfig/rhn/systemid'

    __nRetries = 3 # number of login retries

    hostname = None

    def __init__(self, hostname):
        log_debug(3)
        ProxyAuth.hostname = hostname
        self.__processSystemid()

    def __processSystemid(self):
        """ update the systemid/serverid but only if they stat differently.
            returns 0=no updates made; or 1=updates were made
        """
        if not os.access(ProxyAuth.__systemid_filename, os.R_OK):
            log_error("unable to access %s" % ProxyAuth.__systemid_filename)
            raise rhnFault(1000,
                      _("RHN Proxy error (RHN Proxy systemid has wrong permissions?). "
                        "Please contact your system administrator."))

        mtime = None
        try:
            mtime = os.stat(ProxyAuth.__systemid_filename)[-2]
        except IOError, e:
            log_error("unable to stat %s: %s" % (ProxyAuth.__systemid_filename, repr(e)))
            raise rhnFault(1000,
                      _("RHN Proxy error (RHN Proxy systemid has wrong permissions?). "
                        "Please contact your system administrator."))

        if not self.__systemid_mtime:
            ProxyAuth.__systemid_mtime = mtime

        if self.__systemid_mtime == mtime \
        and self.__systemid and self.__serverid:
            # nothing to do
            return 0

        # get systemid
        try:
            ProxyAuth.__systemid = open(ProxyAuth.__systemid_filename, 'r').read()
        except IOError, e:
            log_error("unable to read %s" % ProxyAuth.__systemid_filename)
            raise rhnFault(1000,
                      _("RHN Proxy error (RHN Proxy systemid has wrong permissions?). "
                        "Please contact your system administrator."))

        # get serverid
        sysid, cruft = xmlrpclib.loads(ProxyAuth.__systemid)
        ProxyAuth.__serverid = sysid[0]['system_id'][3:]

        log_debug(7, 'SystemId: "%s[...snip  snip...]%s"' \
          % (ProxyAuth.__systemid[:20], ProxyAuth.__systemid[-20:]))
        log_debug(7, 'ServerId: %s' % ProxyAuth.__serverid)

        # ids were updated
        return 1

    def check_cached_token(self, forceRefresh=0):
        """ check cache, login if need be, and cache.
        """
        log_debug(3)
        oldToken = self.get_cached_token()
        token = oldToken
        if not token or forceRefresh or self.__processSystemid():
            token = self.login()
        if token and token != oldToken:
            self.set_cached_token(token)
        return token

    def get_cached_token(self):
        """ Fetches this proxy's token (or None) from the cache
        """
        log_debug(3)
        # Try to connect to the token-cache.
        shelf = get_auth_shelf()
        # Fetch the token
        key = self.__cache_proxy_key()
        if shelf.has_key(key):
            return shelf[key]
        return None

    def set_cached_token(self, token):
        """ Caches current token in the auth cache.
        """
        log_debug(3)
        # Try to connect to the token-cache.
        shelf = get_auth_shelf()
        # Cache the token.
        try:
            shelf[self.__cache_proxy_key()] = token
        except:
            text = _("""\
Caching of authentication token for proxy id %s failed!
Either the authentication caching daemon is experiencing
problems, isn't running, or the token is somehow corrupt.
""") % self.__serverid
            Traceback("ProxyAuth.set_cached_token", extra=text)
            raise rhnFault(1000,
                      _("RHN Proxy error (auth caching issue). "
                        "Please contact your system administrator."))
        log_debug(4, "successfully returning")
        return token

    def del_cached_token(self):
        """Removes the token from the cache
        """
        log_debug(3)
        # Connect to the token cache
        shelf = get_auth_shelf()
        key = self.__cache_proxy_key()
        try:
            del shelf[key]
        except KeyError:
            # no problem
            pass

    def login(self):
        """ Login and fetch new token (proxy token).
        
            How it works in a nutshell.
            Only the broker component uses this. We perform a xmlrpc request
            to rhn_parent. This occurs outside of the http process we are
            currently working on. So, we do this all on our own; do all of
            our own SSL decisionmaking etc. We use CFG.RHN_PARENT as we always
            bypass the SSL redirect.
        
            DESIGN NOTES:  what is the proxy auth token?
            -------------------------------------------
            An RHN Proxy auth token is a token fetched upon login from
            RHN Satellite or hosted.
        
            It has this format:
               'S:U:ST:EO:SIG'
            Where:
               S   = server ID
               U   = username
               ST  = server time
               EO  = expiration offset
               SIG = signature
               H   = hostname (important later)
        
            Within this function within the RHN Proxy Broker we also tag on
            the hostname to the end of the token. The token as described above
            is enough for authentication purposes, but we need a to identify
            the exact hostname (as the RHN Proxy sees it). So now the token
            becomes (token:hostname):
               'S:U:ST:EO:SIG:H'
        
            DESIGN NOTES:  what is X-RHN-Proxy-Auth?
            -------------------------------------------
            This is where we use the auth token beyond RHN Proxy login
            purposes. This a header used to track request routes through
            a hierarchy of RHN Proxies.
        
            X-RHN-Proxy-Auth is a header that passes proxy authentication
            information around in the form of an ordered list of tokens. This
            list is used to gain information as to how a client request is
            routed throughout an RHN topology.
           
            Format: 'S1:U1:ST1:EO1:SIG1:H1,S2:U2:ST2:EO2:SIG2:H2,...'
                     |_________1_________| |_________2_________| |__...
                             token                 token
                     where token is really: token:hostname
           
            leftmost token was the first token hit by a client request.
            rightmost token was the last token hit by a client request.
           
        """

        log_debug(3)
        server = self.__getXmlrpcServer()
        error = None
        token = None
        # update the systemid/serverid if need be.
        self.__processSystemid()
        # Makes three attempts to login
        for i in range(self.__nRetries):
            try:
                token = server.proxy.login(self.__systemid)
            except (socket.error, socket.sslerror), e:
                if CFG.HTTP_PROXY:
                    # socket error, check to see if your HTTP proxy is running...
                    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                    httpProxy, httpProxyPort = string.split(CFG.HTTP_PROXY, ':')
                    try:
                        s.connect((httpProxy, int(httpProxyPort)))
                    except socket.error, e:
                        error = ['socket.error', 'HTTP Proxy not running? '
                                           '(%s) %s' % (CFG.HTTP_PROXY, e)]
                        # rather big problem: http proxy not running.
                        log_error("*** ERROR ***: %s" % error[1])
                        Traceback(mail=0)
                    except socket.sslerror, e:
                        error = ['socket.sslerror',
                                 '(%s) %s' % (CFG.HTTP_PROXY, e)]
                        # rather big problem: http proxy not running.
                        log_error("*** ERROR ***: %s" % error[1])
                        Traceback(mail=0)
                    else:
                        error = ['socket', str(e)]
                        log_error(error)
                        Traceback(mail=0)
                else:
                    log_error("Socket error", e)
                    Traceback(mail=0)
                Traceback(mail=1)
                token = None
                time.sleep(.25)
                continue
            except SSL.SSL.Error, e:
                token = None
                error = ['rhn.SSL.SSL.Error', repr(e), str(e)]
                log_error(error)
                Traceback(mail=0)
                time.sleep(.25)
                continue
            except xmlrpclib.ProtocolError, e:
                token = None
                log_error('xmlrpclib.ProtocolError', e)
                time.sleep(.25)
                continue
            except xmlrpclib.Fault, e:
                # Report it through the mail
                # Traceback will try to walk over all the values
                # in each stack frame, and eventually will try to stringify
                # the method object itself
                # This should trick it, since the originator of the exception
                # is this function, instead of a deep call into xmlrpclib
                log_error("%s" % e)
                if e.faultCode == 10000:
                    # reraise it for the users (outage or "important message"
                    # coming through")
                    raise rhnFault(e.faultCode, e.faultString)
                # ok... it's some other fault
                Traceback("ProxyAuth.login (Fault) - RHN Proxy not "
                          "able to log in.")
                # And raise a Proxy Error - the server made its point loud and
                # clear
                raise rhnFault(1000,
                          _("RHN Proxy error (during proxy login). "
                            "Please contact your system administrator."))
            except Exception, e:
                token = None
                log_error("Unhandled exception", e)
                Traceback(mail=0)
                time.sleep(.25)
                continue
            else:
                break

        if not token:
            if error:
                if error[0] in ('xmlrpclib.ProtocolError', 'socket.error', 'socket'):
                    raise rhnFault(1000,
                                _("RHN Proxy error (error: %s). "
                                  "Please contact your system administrator.") % error[0])
                if error[0] in ('rhn.SSL.SSL.Error', 'socket.sslerror'):
                    raise rhnFault(1000,
                                _("RHN Proxy error (SSL issues? Error: %s). "
                                  "Please contact your system administrator.") % error[0])
                else:
                    raise rhnFault(1002, err_text='%s' % e)
            else:
                raise rhnFault(1001)
        if self.hostname:
            token = token + ':' + self.hostname
        log_debug(6, "New proxy token: %s" % token)
        return token

    # __private methods__

    def __getXmlrpcServer(self):
        """ get an xmlrpc server object
        
            WARNING: if CFG.USE_SSL is off, we are sending info
                     in the clear. 
        """
        log_debug(3)

        # build the URL
        url = CFG.RHN_PARENT or ''
        url = string.split(parseUrl(url)[1], ':')[0]
        if CFG.USE_SSL:
            url = 'https://' + url  + '/XMLRPC'
        else:
            url = 'http://' + url  + '/XMLRPC'
        log_debug(3, 'server url: %s' % url)

        if CFG.HTTP_PROXY:
            serverObj = rpclib.Server(url,
                                      proxy=CFG.HTTP_PROXY,
                                      username=CFG.HTTP_PROXY_USERNAME,
                                      password=CFG.HTTP_PROXY_PASSWORD)
        else:
            serverObj = rpclib.Server(url)
        if CFG.USE_SSL and CFG.CA_CHAIN:
            if not os.access(CFG.CA_CHAIN, os.R_OK):
                log_error('ERROR: missing or cannot access (for ca_chain): %s' % CFG.CA_CHAIN)
                raise rhnFault(1000,
                          _("RHN Proxy error (file access issues). "
                            "Please contact your system administrator. "
                            "Please refer to RHN Proxy logs."))
            serverObj.add_trusted_cert(CFG.CA_CHAIN)
        serverObj.add_header('X-RHN-Client-Version', 2)
        return serverObj

    def __cache_proxy_key(self):
        return 'p' + str(self.__serverid)

    def getProxyServerId(self):
        return self.__serverid

def get_auth_shelf():
    if CFG.USE_LOCAL_AUTH:
        return AuthLocalBackend()
    server, port = string.split(CFG.AUTH_CACHE_SERVER, ':')
    port = int(port)
    return rhnAuthCacheClient.Shelf((server, port))

class AuthLocalBackend:
    _cache_prefix = "proxy-auth"

    def has_key(self, key):
        rkey = self._compute_key(key)
        return rhnCache.has_key(rkey)

    def __getitem__(self, key):
        rkey = self._compute_key(key)
        # We want a dictionary-like behaviour, so if the key is not present,
        # raise an exception (that's what missing_is_null=0 does)
        val = rhnCache.get(rkey, missing_is_null=0)
        return val

    def __setitem__(self, key, val):
        rkey = self._compute_key(key)
        return rhnCache.set(rkey, val)

    def __delitem__(self, key):
        rkey = self._compute_key(key)
        return rhnCache.delete(rkey)
    
    def _compute_key(self, key):
        return os.path.join(self._cache_prefix, str(key))


# ==============================================================================

