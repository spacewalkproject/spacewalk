#
# This module contains all the RPC-related functions the RHN code uses
#
# Copyright (c) 2005--2010 Red Hat, Inc.
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

__version__ = "$Revision$"

import transports
import urllib

from types import ListType, TupleType

from UserDictCase import UserDictCase

import xmlrpclib
from xmlrpclib import Fault, ResponseError, ProtocolError, getparser

from transports import File

# Redirection handling

MAX_REDIRECTIONS = 5

#
# Function used to split host information in an URL per RFC 2396
# handle full hostname like user:passwd@host:port
#
# TODO: check IPv6 numerical IPs it may break
#
def split_host(hoststring):
    l = hoststring.split('@', 1)
    host = None
    port = None
    user = None
    passwd = None

    if len(l) == 2:
        hostport = l[1]
        # userinfo present
        userinfo = l[0].split(':', 1)
        user = userinfo[0]
        if len(userinfo) == 2:
            passwd = userinfo[1]
    else:
        hostport = l[0]

    # Now parse hostport
    arr = hostport.split(':', 1)
    host = arr[0]
    if len(arr) == 2:
        port = arr[1]
        
    return (host, port, user, passwd)

def get_proxy_info(proxy):
    if proxy == None:
        raise ValueError, "Host string cannot be null"

    arr = proxy.split('://', 1)
    if len(arr) == 2:
        # scheme found, strip it
        proxy = arr[1]
    
    return split_host(proxy)
        

class MalformedURIError(IOError):
    pass


# This is a cut-and-paste of xmlrpclib.ServerProxy, with the data members made
# protected instead of private
# It also adds support for changing the way the request is made (XMLRPC or
# GET)
class Server:
    """uri [,options] -> a logical connection to an XML-RPC server

    uri is the connection point on the server, given as
    scheme://host/target.

    The standard implementation always supports the "http" scheme.  If
    SSL socket support is available (Python 2.0), it also supports
    "https".

    If the target part and the slash preceding it are both omitted,
    "/RPC2" is assumed.

    The following options can be given as keyword arguments:

        transport: a transport factory
        encoding: the request encoding (default is UTF-8)
        verbose: verbosity level
        proxy: use an HTTP proxy
        username: username for authenticated HTTP proxy
        password: password for authenticated HTTP proxy

    All 8-bit strings passed to the server proxy are assumed to use
    the given encoding.
    """

    # Default factories
    _transport_class = transports.Transport
    _transport_class_https = transports.SafeTransport
    _transport_class_proxy = transports.ProxyTransport
    _transport_class_https_proxy = transports.SafeProxyTransport
    def __init__(self, uri, transport=None, encoding=None, verbose=0, 
        proxy=None, username=None, password=None, refreshCallback=None,
        progressCallback=None):
        # establish a "logical" server connection

        #
        # First parse the proxy information if available
        #
        if proxy != None:
            (ph, pp, pu, pw) = get_proxy_info(proxy)

            if pp is not None:
                proxy = "%s:%s" % (ph, pp)
            else:
                proxy = ph

            # username and password will override whatever was passed in the
            # URL
            if pu is not None and username is None:
                username = pu

                if pw is not None and password is None:
                    password = pw
                    
        self._uri = uri
        self._refreshCallback = None
        self._progressCallback = None
        self._bufferSize = None
        self._proxy = proxy
        self._username = username
        self._password = password

        self._reset_host_handler_and_type()

        if transport is None:
            self._allow_redirect = 1
            transport = self.default_transport(type, proxy, username, password)
        else:
            #
            # dont allow redirect on unknow transports, that should be
            # set up independantly
            #
            self._allow_redirect = 0
            
        self._redirected = None
        self.use_handler_path = 1
        self._transport = transport

        self._trusted_cert_files = []
        self._lang = None

        self._encoding = encoding
        self._verbose = verbose

        self.set_refresh_callback(refreshCallback)
        self.set_progress_callback(progressCallback)

        self._headers = UserDictCase()

    def default_transport(self, type, proxy=None, username=None, password=None):
        if proxy:
            if type == 'https':
                transport = self._transport_class_https_proxy(proxy, 
                    proxyUsername=username, proxyPassword=password)
            else:
                transport = self._transport_class_proxy(proxy, 
                    proxyUsername=username, proxyPassword=password)
        else:
            if type == 'https':
                transport = self._transport_class_https()
            else:
                transport = self._transport_class()
        return transport

    def allow_redirect(self, allow):
        self._allow_redirect = allow

    def redirected(self):
        if not self._allow_redirect:
            return None
        return self._redirected

    def set_refresh_callback(self, refreshCallback):
        self._refreshCallback = refreshCallback
        self._transport.set_refresh_callback(refreshCallback)

    def set_buffer_size(self, bufferSize):
        self._bufferSize = bufferSize
        self._transport.set_buffer_size(bufferSize)

    def set_progress_callback(self, progressCallback, bufferSize=16384):
        self._progressCallback = progressCallback
        self._transport.set_progress_callback(progressCallback, bufferSize)

    def _req_body(self, params, methodname):
        return xmlrpclib.dumps(params, methodname, encoding=self._encoding)

    def get_response_headers(self):
        if self._transport:
            return self._transport.headers_in
        return None

    def get_response_status(self):
        if self._transport:
            return self._transport.response_status
        return None

    def get_response_reason(self):
        if self._transport:
            return self._transport.response_reason
        return None

    def get_content_range(self):
        """Returns a dictionary with three values:
            length: the total length of the entity-body (can be None)
            first_byte_pos: the position of the first byte (zero based)
            last_byte_pos: the position of the last byte (zero based)
           The range is inclusive; that is, a response 8-9/102 means two bytes
        """
        headers = self.get_response_headers()
        if not headers:
            return None
        content_range = headers.get('Content-Range')
        if not content_range:
            return None
        arr = filter(None, content_range.split())
        assert arr[0] == "bytes"
        assert len(arr) == 2
        arr = arr[1].split('/')
        assert len(arr) == 2

        brange, total_len = arr
        if total_len == '*':
            # Per RFC, the server is allowed to use * if the length of the
            # entity-body is unknown or difficult to determine
            total_len = None
        else:
            total_len = int(total_len)

        start, end = brange.split('-')
        result = {
            'length'            : total_len,
            'first_byte_pos'    : int(start),
            'last_byte_pos'     : int(end),
        }
        return result

    def accept_ranges(self):
        headers = self.get_response_headers()
        if not headers:
            return None
        if headers.has_key('Accept-Ranges'):
            return headers['Accept-Ranges']
        return None

    def _reset_host_handler_and_type(self):
        """ Reset the attributes:
            self._host, self._handler, self._type
            according the value of self._uri.
        """
        # get the url
        type, uri = urllib.splittype(self._uri)
        if type is None:
            raise MalformedURIError, "missing protocol in uri"
        # with a real uri passed in, uri will now contain "//hostname..." so we
        # need at least 3 chars for it to maybe be ok...
        if len(uri) < 3 or uri[0:2] != "//":
            raise MalformedURIError
        if type != None:
            self._type = type.lower()
        else:
            self._type = type
        if self._type not in ("http", "https"):
            raise IOError, "unsupported XML-RPC protocol"
        self._host, self._handler = urllib.splithost(uri)
        if not self._handler:
            self._handler = "/RPC2"

    def _request(self, methodname, params):
        # call a method on the remote server
        # the loop is used to handle redirections
        redirect_response = 0
        retry = 0

        rpc_version = __version__
        if len(__version__.split()) > 1:
            rpc_version = __version__.split()[1]

        self._reset_host_handler_and_type()

        while 1:
            if retry >= MAX_REDIRECTIONS:
                raise InvalidRedirectionError(
                      "Unable to fetch requested Package")

            # Clear the transport headers first
            self._transport.clear_headers()
            for k, v in self._headers.items():
                self._transport.set_header(k, v)

            self._transport.add_header("X-Info",
                'RPC Processor (C) Red Hat, Inc (version %s)' % 
                rpc_version)
            # identify the capability set of this client to the server
            self._transport.set_header("X-Client-Version", 1)
            
            if self._allow_redirect:
                # Advertise that we follow redirects
                #changing the version from 1 to 2 to support backward compatibility
                self._transport.add_header("X-RHN-Transport-Capability",
                    "follow-redirects=3")

            if redirect_response:
                self._transport.add_header('X-RHN-Redirect', '0')
                if self.send_handler:
                    self._transport.add_header('X-RHN-Path', self.send_handler)

            request = self._req_body(params, methodname)

            try:
                response = self._transport.request(self._host, \
                                self._handler, request, verbose=self._verbose)
                save_response = self._transport.response_status
            except xmlrpclib.ProtocolError, pe:
                if self.use_handler_path:
                    raise pe
                else:
                     save_response = pe.errcode

            self._redirected = None
            retry += 1
            if save_response == 200:
                # exit redirects loop and return response
                break
            elif save_response not in (301, 302):
                # Retry pkg fetch
                 self.use_handler_path = 1
                 continue
            # rest of loop is run only if we are redirected (301, 302)
            self._redirected = self._transport.redirected()
            self.use_handler_path = 0
            redirect_response = 1

            if not self._allow_redirect:
                raise InvalidRedirectionError("Redirects not allowed")
                                
            if self._verbose:
                print "%s redirected to %s" % (self._uri, self._redirected)

            typ, uri = urllib.splittype(self._redirected)
            
            if typ != None:
                typ = typ.lower()
            if typ not in ("http", "https"):
                raise InvalidRedirectionError(
                    "Redirected to unsupported protocol %s" % typ)

            #
            # We forbid HTTPS -> HTTP for security reasons
            # Note that HTTP -> HTTPS -> HTTP is allowed (because we compare
            # the protocol for the redirect with the original one)
            #
            if self._type == "https" and typ == "http":
                raise InvalidRedirectionError(
                    "HTTPS redirected to HTTP is not supported")

            self._host, self._handler = urllib.splithost(uri)
            if not self._handler:
                self._handler = "/RPC2"

            # Create a new transport for the redirected service and
            # set up the parameters on the new transport
            del self._transport
            self._transport = self.default_transport(typ, self._proxy,
                                     self._username, self._password)
            self.set_progress_callback(self._progressCallback)
            self.set_refresh_callback(self._refreshCallback)
            self.set_buffer_size(self._bufferSize)
            self.setlang(self._lang)

            if self._trusted_cert_files != [] and \
                hasattr(self._transport, "add_trusted_cert"):
                for certfile in self._trusted_cert_files:
                    self._transport.add_trusted_cert(certfile)
            # Then restart the loop to try the new entry point.

        if isinstance(response, transports.File):
            # Just return the file
            return response
            
        # an XML-RPC encoded data structure
        if isinstance(response, TupleType) and len(response) == 1:
            response = response[0]

        return response

    def __repr__(self):
        return (
            "<%s for %s%s>" %
            (self.__class__.__name__, self._host, self._handler)
            )

    __str__ = __repr__

    def __getattr__(self, name):
        # magic method dispatcher
        return _Method(self._request, name)

    # note: to call a remote object with an non-standard name, use
    # result getattr(server, "strange-python-name")(args)

    def set_transport_flags(self, transfer=0, encoding=0, **kwargs):
        if not self._transport:
            # Nothing to do
            return
        kwargs.update({
            'transfer'  : transfer,
            'encoding'  : encoding,
        })
        apply(self._transport.set_transport_flags, (), kwargs)

    def get_transport_flags(self):
        if not self._transport:
            # Nothing to do
            return {}
        return self._transport.get_transport_flags()

    def reset_transport_flags(self):
        # Does nothing
        pass

    # Allow user-defined additional headers.
    def set_header(self, name, arg):
        if type(arg) in [ type([]), type(()) ]:
            # Multivalued header
            self._headers[name] = map(str, arg)
        else:
            self._headers[name] = str(arg)

    def add_header(self, name, arg):
        if self._headers.has_key(name):
            vlist = self._headers[name]
            if not isinstance(vlist, ListType):
                vlist = [ vlist ]
        else:
            vlist = self._headers[name] = []
        vlist.append(str(arg))

    # Sets the i18n options
    def setlang(self, lang):
        self._lang = lang
        if self._transport and hasattr(self._transport, "setlang"):
            self._transport.setlang(lang)
        
    # Sets the CA chain to be used
    def use_CA_chain(self, ca_chain = None):
        raise NotImplementedError, "This method is deprecated"

    def add_trusted_cert(self, certfile):
        self._trusted_cert_files.append(certfile)
        if self._transport and hasattr(self._transport, "add_trusted_cert"):
            self._transport.add_trusted_cert(certfile)
        
    def close(self):
        if self._transport:
            self._transport.close()
            self._transport = None

# RHN GET server
class GETServer(Server):
    def __init__(self, uri, transport=None, proxy=None, username=None,
            password=None, client_version=2, headers={}, refreshCallback=None,
            progressCallback=None):
        Server.__init__(self, uri, 
            proxy=proxy,
            username=username,
            password=password,
            transport=transport,
            refreshCallback=refreshCallback,
            progressCallback=progressCallback)
        self._client_version = client_version
        self._headers = headers
        # Back up the original handler, since we mangle it
        self._orig_handler = self._handler
        # Download resumption
        self.set_range(offset=None, amount=None)
        # referer, which redirect us to new handler
        self.send_handler=None

    def _req_body(self, params, methodname):
        if not params or len(params) < 1:
            raise Exception("Required parameter channel not found")
        # Strip the multiple / from the handler
        h_comps = filter(lambda x: x != '', self._orig_handler.split('/'))
        # Set the handler we are going to request
        hndl = h_comps + ["$RHN", params[0], methodname] + list(params[1:])
        self._handler = '/' + '/'.join(hndl)

        #save the constructed handler in case of redirect
        self.send_handler = self._handler
        
        # Add headers
        #override the handler to replace /XMLRPC with pkg path
        if self._redirected and not self.use_handler_path:
           self._handler = self._new_req_body()
            
        for h, v in self._headers.items():
            self._transport.set_header(h, v)

        if self._offset is not None:
            if self._offset >= 0:
                brange = str(self._offset) + '-'
                if self._amount is not None:
                    brange = brange + str(self._offset + self._amount - 1)
            else:
                # The last bytes
                # amount is ignored in this case
                brange = '-' + str(-self._offset)

            self._transport.set_header('Range', "bytes=" + brange)
            # Flag that we allow for partial content
            self._transport.set_transport_flags(allow_partial_content=1)
        # GET requests have empty body
        return ""

    def _new_req_body(self):
        type, tmpuri = urllib.splittype(self._redirected)
        site, handler = urllib.splithost(tmpuri)
        return handler
    
    def set_range(self, offset=None, amount=None):
        if offset is not None:
            try:
                offset = int(offset)
            except ValueError:
                # Error
                raise RangeError("Invalid value `%s' for offset" % offset)

        if amount is not None:
            try:
                amount = int(amount)
            except ValueError:
                # Error
                raise RangeError("Invalid value `%s' for amount" % amount)

            if amount <= 0:
                raise RangeError("Invalid value `%s' for amount" % amount)
                
        self._amount = amount
        self._offset = offset

    def reset_transport_flags(self):
        self._transport.set_transport_flags(allow_partial_content=0)

    def __getattr__(self, name):
        # magic method dispatcher
        return SlicingMethod(self._request, name)

    def default_transport(self, type, proxy=None, username=None, password=None):
	ret = Server.default_transport(self, type, proxy=proxy, username=username, password=password)
	ret.set_method("GET")
	return ret

class RangeError(Exception):
    pass

class InvalidRedirectionError(Exception):
    pass

def getHeaderValues(headers, name):
    import mimetools
    if not isinstance(headers, mimetools.Message):
        if headers.has_key(name):
            return [headers[name]]
        return []

    return map(lambda x: x.split(':', 1)[1].strip(), 
            headers.getallmatchingheaders(name))

class _Method:
    # some magic to bind an XML-RPC method to an RPC server.
    # supports "nested" methods (e.g. examples.getStateName)
    def __init__(self, send, name):
        self._send = send
        self._name = name
    def __getattr__(self, name):
        return _Method(self._send, "%s.%s" % (self._name, name))
    def __call__(self, *args):
        return self._send(self._name, args)
    def __repr__(self):
        return (
            "<%s %s (%s)>" %
            (self.__class__.__name__, self._name, self._send)
            )
    __str__ = __repr__


class SlicingMethod(_Method):
    """
    A "slicing method" allows for byte range requests
    """
    def __init__(self, send, name):
        _Method.__init__(self, send, name)
        self._offset = None
    def __getattr__(self, name):
        return SlicingMethod(self._send, "%s.%s" % (self._name, name))
    def __call__(self, *args, **kwargs):
        self._offset = kwargs.get('offset')
        self._amount = kwargs.get('amount')

        # im_self is a pointer to self, so we can modify the class underneath 
        try:
            self._send.im_self.set_range(offset=self._offset,
                amount=self._amount)
        except AttributeError:
            pass

        result = self._send(self._name, args)

        # Reset "sticky" transport flags
        try:
            self._send.im_self.reset_transport_flags()
        except AttributeError:
            pass

        return result
        

def reportError(headers):
    # Reports the error from the headers
    errcode = 0
    errmsg = ""
    s = "X-RHN-Fault-Code"
    if headers.has_key(s):
        errcode = int(headers[s])
    s = "X-RHN-Fault-String"
    if headers.has_key(s):
        _sList = getHeaderValues(headers, s)
        if _sList:
            _s = ''.join(_sList)
            import base64
            errmsg = "%s" % base64.decodestring(_s)

    return errcode, errmsg

