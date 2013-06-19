#
# Connection objects
#
# Copyright (c) 2002--2011 Red Hat, Inc.
#
# Author: Mihai Ibanescu <misa@redhat.com>

# $Id$


import base64
import SSL
import nonblocking
import httplib
import xmlrpclib
import encodings.idna
import socket
from platform import python_version

# Import into the local namespace some httplib-related names
from httplib import _CS_REQ_SENT, _CS_IDLE, ResponseNotReady

class HTTPResponse(httplib.HTTPResponse):
    def set_callback(self, rs, ws, ex, user_data, callback):
        if not isinstance(self.fp, nonblocking.NonBlockingFile):
            self.fp = nonblocking.NonBlockingFile(self.fp)
        self.fp.set_callback(rs, ws, ex, user_data, callback)

class HTTPConnection(httplib.HTTPConnection):
    response_class = HTTPResponse
    
    def __init__(self, host, port=None, timeout=SSL.DEFAULT_TIMEOUT):
        if python_version() >= '2.6.1':
            httplib.HTTPConnection.__init__(self, host, port, timeout=timeout)
        else:
            httplib.HTTPConnection.__init__(self, host, port)
        self._cb_rs = []
        self._cb_ws = []
        self._cb_ex = []
        self._cb_user_data = None
        self._cb_callback = None
        self._user_agent = "rhn.connections $Revision$ (python)"
        self.timeout = timeout

    def set_callback(self, rs, ws, ex, user_data, callback):
        # XXX check the params
        self._cb_rs = rs
        self._cb_ws = ws
        self._cb_ex = ex
        self._cb_user_data = user_data
        self._cb_callback = callback

    def set_user_agent(self, user_agent):
        self._user_agent = user_agent

    # XXX Had to copy the function from httplib.py, because the nonblocking
    # framework had to be initialized
    def getresponse(self):
        "Get the response from the server."

        # check if a prior response has been completed
        if self.__response and self.__response.isclosed():
            self.__response = None

        #
        # if a prior response exists, then it must be completed (otherwise, we
        # cannot read this response's header to determine the connection-close
        # behavior)
        #
        # note: if a prior response existed, but was connection-close, then the
        # socket and response were made independent of this HTTPConnection
        # object since a new request requires that we open a whole new
        # connection
        #
        # this means the prior response had one of two states:
        #   1) will_close: this connection was reset and the prior socket and
        #                  response operate independently
        #   2) persistent: the response was retained and we await its
        #                  isclosed() status to become true.
        #
        if self.__state != _CS_REQ_SENT or self.__response:
            raise ResponseNotReady()

        if self.debuglevel > 0:
            response = self.response_class(self.sock, self.debuglevel)
        else:
            response = self.response_class(self.sock)
        
        # The only modification compared to the stock HTTPConnection
        if self._cb_callback:
            response.set_callback(self._cb_rs, self._cb_ws, self._cb_ex,
                self._cb_user_data, self._cb_callback)

        response.begin()
        assert response.will_close != httplib._UNKNOWN
        self.__state = _CS_IDLE

        if response.will_close:
            # this effectively passes the connection to the response
            self.close()
        else:
            # remember this, so we can tell when it is complete
            self.__response = response

        return response

    def connect(self):
        httplib.HTTPConnection.connect(self)
        self.sock.settimeout(self.timeout)


class HTTPProxyConnection(HTTPConnection):
    def __init__(self, proxy, host, port=None, username=None, password=None,
            timeout=SSL.DEFAULT_TIMEOUT):
        # The connection goes through the proxy
        HTTPConnection.__init__(self, proxy, timeout=timeout)
        # save the proxy values
        self.__proxy, self.__proxy_port = self.host, self.port
        # self.host and self.port will point to the real host
        self._set_hostport(host, port)
        # save the host and port
        self._host, self._port = self.host, self.port
        # Authenticated proxies support
        self.__username = username
        self.__password = password

    def connect(self):
        # We are actually connecting to the proxy
        self._set_hostport(self.__proxy, self.__proxy_port)
        HTTPConnection.connect(self)
        # Restore the real host and port
        self._set_hostport(self._host, self._port)

    def putrequest(self, method, url, skip_host=0):
        # The URL has to include the real host
        hostname = self._host
        if self._port != self.default_port:
            hostname = hostname + ':' + str(self._port)
        newurl = "http://%s%s" % (hostname, url)
        # Piggyback on the parent class
        HTTPConnection.putrequest(self, method, newurl, skip_host=skip_host)
        # Add proxy-specific headers
        self._add_proxy_headers()
        
    def _add_proxy_headers(self):
        if not self.__username:
            return
        # Authenticated proxy
        userpass = "%s:%s" % (self.__username, self.__password)
        enc_userpass = base64.encodestring(userpass).replace("\n", "")
        self.putheader("Proxy-Authorization", "Basic %s" % enc_userpass)
        
class HTTPSConnection(HTTPConnection):
    response_class = HTTPResponse
    default_port = httplib.HTTPSConnection.default_port

    def __init__(self, host, port=None, trusted_certs=None,
            timeout=SSL.DEFAULT_TIMEOUT):
        HTTPConnection.__init__(self, host, port, timeout=timeout)
        trusted_certs = trusted_certs or []
        self.trusted_certs = trusted_certs

    def connect(self):
        "Connect to a host on a given (SSL) port"
        results = socket.getaddrinfo(self.host, self.port,
            socket.AF_UNSPEC, socket.SOCK_STREAM)

        for r in results:
            af, socktype, proto, canonname, sa = r
            try:
                sock = socket.socket(af, socktype, proto)
            except socket.error, msg:
                sock = None
                continue

            try:
                sock.connect((self.host, self.port))
                sock.settimeout(self.timeout)
            except socket.error, e:
                sock.close()
                sock = None
                continue
            break

        if sock is None:
            raise socket.error("Unable to connect to the host and port specified")

        self.sock = SSL.SSLSocket(sock, self.trusted_certs)
        self.sock.init_ssl()

class HTTPSProxyResponse(HTTPResponse):
    def begin(self):
        HTTPResponse.begin(self)
        self.will_close = 0

class HTTPSProxyConnection(HTTPProxyConnection):
    default_port = HTTPSConnection.default_port

    def __init__(self, proxy, host, port=None, username=None, password=None, 
            trusted_certs=None, timeout=SSL.DEFAULT_TIMEOUT):
        HTTPProxyConnection.__init__(self, proxy, host, port, username,
                password, timeout=timeout)
        trusted_certs = trusted_certs or []
        self.trusted_certs = trusted_certs

    def connect(self):
        # Set the connection with the proxy
        HTTPProxyConnection.connect(self)
        # Use the stock HTTPConnection putrequest 
        host = "%s:%s" % (self._host, self._port)
        HTTPConnection.putrequest(self, "CONNECT", host)
        # Add proxy-specific stuff
        self._add_proxy_headers()
        # And send the request
        HTTPConnection.endheaders(self)
        # Save the response class
        response_class = self.response_class
        # And replace the response class with our own one, which does not
        # close the connection after 
        self.response_class = HTTPSProxyResponse
        response = HTTPConnection.getresponse(self)
        # Restore the response class
        self.response_class = response_class
        # Close the response object manually
        response.close()
        if response.status != 200:
            # Close the connection manually
            self.close()
            raise xmlrpclib.ProtocolError(host,
                response.status, response.reason, response.msg)
        self.sock = SSL.SSLSocket(self.sock, self.trusted_certs)
        self.sock.init_ssl()

    def putrequest(self, method, url, skip_host=0):
        return HTTPConnection.putrequest(self, method, url, skip_host=skip_host)

    def _add_proxy_headers(self):
        HTTPProxyConnection._add_proxy_headers(self)
        # Add a User-Agent header
        self.putheader("User-Agent", self._user_agent)

def idn_pune_to_unicode(hostname):
    """ Convert Internationalized domain name from Pune encoding to Unicode """
    if hostname is None:
        return None
    else:
        return hostname.decode('idna')

def idn_ascii_to_pune(hostname):
    """ Convert domain name to Pune encoding. Hostname can be instance of string or Unicode """
    if hostname is None:
        return None
    else:
        if not isinstance(hostname, unicode):
            hostname = unicode(hostname, 'utf-8')
        return hostname.encode('idna')
