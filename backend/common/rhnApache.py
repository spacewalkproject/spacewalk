#
# Copyright (c) 2008--2010 Red Hat, Inc.
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
# Code for the shared apache handler class inherited by the
# RHN proxy and server.
#

# system module imports
import time
import string
import os.path


# global module imports
from common import apache


# Now local module imports
import rhnFlags
from UserDictCase import UserDictCase
from rhnLog import log_debug
from rhnLog import log_error
from rhnTranslate import cat

class rhnApache:
    """ Shared rhnApache class: rhnApache classes in proxy and server inherit 
        this class. 
    
        Shared apache handler code: headerParserHandler,
                                handler (defined in class that inherits this),
                                cleanupHandler.
    """
    _lang_catalog = "common"

    def __init__(self):
        self.lang = "C"
        self.clientVersion = 0
        self.proxyVersion = None
        self.start_time = 0

    ###
    # HANDLERS, in the order which they are called
    ###

    def headerParserHandler(self, req):
        """
        after a request has been received, first thing we do is to create the
        input object
        """

        log_debug(3)
        self.start_time = time.time()
        # Decline if this is a subrequest:
        if req.main:
            return apache.DECLINE
        log_debug(4, req.method, req.path_info, req.headers_in)

        # Clear the global flags.
        rhnFlags.reset()
        # Init the transport options.
        rhnFlags.set('outputTransportOptions', UserDictCase())
        # Init the session token dictionary.
        rhnFlags.set("AUTH_SESSION_TOKEN", UserDictCase())

        ret = self._init_request_processor(req)
        if ret != apache.OK:
            return ret

        ret = self._set_client_info(req)
        if ret != apache.OK:
            return ret

        # Check the protocol version
        if req.proto_num < 1001:
            # HTTP protocols prior to 1.1 close the connection
            rhnFlags.get('outputTransportOptions')["Connection"] = "close"

        ret = self._set_proxy_info(req)
        if ret != apache.OK:
            return ret

        # Need to run _set_other first, since _set_lang needs RoodDir set
        ret = self._set_other(req)
        if ret != apache.OK:
            return ret

        ret = self._set_lang(req)
        if ret != apache.OK:
            return ret

        return apache.OK

    def _set_client_info(self, req):
        # Figure out the client version
        clientVersionHeader = 'X-RHN-Client-Version'
        if req.headers_in.has_key(clientVersionHeader):
            # Useful to have it as a separate variable, to see it in a
            # traceback report
            clientVersion = req.headers_in[clientVersionHeader]
            self.clientVersion = int(clientVersion)
        # NOTE: x-client-version is really the cgiwrap xmlrpc API version
        #       NOT the RHN client version... but it works if nothing else
        #       does.
        elif req.headers_in.has_key('X-Client-Version'):
            clientVersion = req.headers_in['X-Client-Version']
            self.clientVersion = int(clientVersion)
        else:
            self.clientVersion = 0

        # Make sure the client version gets set in the headers.
        rhnFlags.get('outputTransportOptions')[clientVersionHeader] = str(
                     self.clientVersion)
        return apache.OK

    def _set_proxy_info(self, req):
        """ RHN Proxy stuff. """
        proxyVersion = 'X-RHN-Proxy-Version'
        if req.headers_in.has_key(proxyVersion):
            self.proxyVersion = req.headers_in[proxyVersion]
        # Make sure the proxy version gets set in the headers.
        rhnFlags.get('outputTransportOptions')[proxyVersion] = str(
                     self.proxyVersion)
        # Make sure the proxy auth-token gets set in global flags.
        if req.headers_in.has_key('X-RHN-Proxy-Auth'):
            rhnFlags.set('X-RHN-Proxy-Auth',
                         req.headers_in['X-RHN-Proxy-Auth'])
        return apache.OK

    def _set_lang(self, req):
        """ determine what language the client prefers """
        if req.headers_in.has_key("Accept-Language"):
            # RFC 2616 #3.10: case insensitive
            lang = string.lower(req.headers_in["Accept-Language"])
        else:
            lang = "C"
        self.setlang(lang, self._lang_catalog)

        return apache.OK

    def _set_other(self, req):
        req_config = req.get_options()
        # XXX: attempt to catch these KeyErrors sometime when there is
        # time to play nicely
        # Save the RootDir in the global flags
        root_dir = req_config["RootDir"]
        rhnFlags.set("RootDir", root_dir)
        return apache.OK

    def _init_request_processor(self, req):
        # first, make sure we only allow certain methods
        if req.method == "GET":
            # This is a request from a cache/client, so verify the signature,
            # system_id, and expiration exist and push into rhnFlags.
            token = self._setSessionToken(req.headers_in)
            if token is None:
                return apache.HTTP_METHOD_NOT_ALLOWED
            return apache.OK

        elif req.method == "POST":
            return apache.OK

        elif req.method == "HEAD":
            # We should only receive this type of request from ourself.
            return apache.OK

        log_error("Unknown HTTP method", req.method)
        return apache.HTTP_METHOD_NOT_ALLOWED

    def _cleanup_request_processor(self):
        return apache.OK

    def handler(self, req):
        """
        a handler - not doing much for the common case, but called from
        classes that inherit this one.
        """
        log_debug(3)
        # Set the lang in the output headers
        if self.lang != "C":
            req.headers_out["Content-Language"] = self.getlang()

        log_debug(4, "URI", req.unparsed_uri)
        log_debug(4, "CONFIG", req.get_config())
        log_debug(4, "OPTIONS", req.get_options())
        log_debug(4, "HEADERS", req.headers_in)
        return apache.OK

    def cleanupHandler(self, req):
        """
        clean up this session
        """
        log_debug(3)
        self.lang = "C"
        self.clientVersion = self.proxyVersion = 0
        # clear the global flags
        rhnFlags.reset()
        timer(self.start_time)
        return self._cleanup_request_processor()

    def logHandler(self, req):
        """
        A dummy log function
        """
        log_debug(3)
        return apache.OK

    def setlang(self, lang, domain):
        """
        An entry point for setting the language for the current sesstion
        """
        self.lang = lang
        self.domain = domain
        rootdir = rhnFlags.get("RootDir") or "."
        localedir = os.path.abspath("%s/locale" % rootdir)
        cat.set(domain=domain, localedir=localedir)
        # If the language presented by the client does not exist, the
        # translation object falls back to printing the original string, which
        # is pretty much the same as translating to en
        cat.setlangs(self.lang)
        log_debug(3, rootdir, self.lang, self.domain)

    def getlang(self):
        """
        And another lang function to produce the list of languages we're
        handling
        """
        return string.join(cat.getlangs(), "; ")

    def _setSessionToken(self, headers):
        """ Pushes token into rhnFlags. If doesn't exist, returns None.
            Pull session token out of the headers and into rhnFlags.
        """
        log_debug(3)
        token = UserDictCase()
        if headers.has_key('X-RHN-Server-Id'):
            token['X-RHN-Server-Id'] = headers['X-RHN-Server-Id']
        else:
            # This has to be here, or else we blow-up.
            return None
        prefix = "x-rhn-auth"
        tokenKeys = filter(
            lambda x, prefix=prefix: string.lower(x[:len(prefix)]) == prefix,
                headers.keys())
        for k in tokenKeys:
            token[k] = headers[k]

        rhnFlags.set("AUTH_SESSION_TOKEN", token)
        return token


def timer(last):
    """
    a lame timer function for pretty logs
    """
    if not last:
        return 0
    log_debug(2, "Request served in %.2f sec" % (time.time() - last, ))
    return 0
