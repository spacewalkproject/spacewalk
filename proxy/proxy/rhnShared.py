# Shared (RHN Proxy/Redirect) handler code called by rhnApache.
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
# $Id: rhnShared.py,v 1.65.2.1 2007/07/30 12:27:56 msuchy Exp $

## language imports
import urllib
import string
import socket
from types import ListType, TupleType

## global imports
from rhn import connections
from common import apache
from rhn.SSL import TimeoutException

## common imports
from common import UserDictCase, rhnFlags, log_debug, log_error, Traceback, \
    CFG, rhnException, rhnFault, rhnLib
from common.rhnTranslate import _

## local imports
import rhnConstants
from responseContext import ResponseContext

class SharedHandler:
    """ Shared handler class (between rhnBroker and rhnRedirect.
        *** only inherited ***
    """

    def __init__(self, req):
        """ init with http request object """
        
        # FIXME: should rename some things:
        #        self.bodyFd --> self.body or self.data or ?
        #        self.caChain --> self.caCert
        
        self.req = req
        self.responseContext = ResponseContext()
        self.uri = None   # ''

        # Common settings for both the proxy and the redirect
        # broker and redirect immediately alter these for their own purposes
        self.caChain = CFG.CA_CHAIN
        self.httpProxy = CFG.HTTP_PROXY
        self.httpProxyUsername = CFG.HTTP_PROXY_USERNAME
        self.httpProxyPassword = CFG.HTTP_PROXY_PASSWORD
        if not self.httpProxyUsername:
            self.httpProxyPassword = ''
        self.rhnParent = CFG.RHN_PARENT or ''
        self.rhnParent = string.split(rhnLib.parseUrl(self.rhnParent)[1], ':')[0]
        CFG.set('RHN_PARENT', self.rhnParent)

        # can we resolve self.rhnParent?
        # BUG 148961: not necessary, and dumb if the proxy is behind a firewall
#        try:
#            socket.gethostbyname(self.rhnParent)
#        except socket.error, e:
#            msg = "SOCKET ERROR: hostname: %s - %s" % (self.rhnParent, str(e))
#            log_error(msg)
#            log_debug(0, msg)
#            raise

    # --- HANDLER SPECIFIC CODE ---

    def _prepHandler(self):
        """ Handler part 0 """

        # Just to be on the safe side
        if self.req.main:
            # A subrequest
            return apache.DECLINE
        log_debug(4, rhnFlags.all())

        if not self.rhnParent:
            raise rhnException("Oops, no proxy parent! Exiting")

        # Copy the headers.
        rhnFlags.get('outputTransportOptions').clear()
        rhnFlags.get('outputTransportOptions').update(self._getHeaders(self.req))

        return apache.OK

    def _connectToParent(self):
        """ Handler part 1
            Should not return an error code -- simply connects.
        """

        scheme, host, port, self.uri = self._parse_url(self.rhnParent)
        self.responseContext.setConnection(self._create_connection())

        if not self.uri:
            self.uri = '/'

        log_debug(3, 'Scheme:', scheme)
        log_debug(3, 'Host:', host)
        log_debug(3, 'Port:', port)
        log_debug(3, 'URI:', self.uri)
        log_debug(3, 'HTTP proxy:', self.httpProxy)
        log_debug(3, 'HTTP proxy username:', self.httpProxyUsername)
        log_debug(3, 'HTTP proxy password:', "<password>")
        log_debug(3, 'CA cert:', self.caChain)

        try:
            self.responseContext.getConnection().connect()
        except socket.error, e:
            log_error("Error opening connection", self.rhnParent, e)
            Traceback(mail=0)
            raise rhnFault(1000,
              _("RHN Proxy could not successfully connect its RHN parent. "
                "Please contact your system administrator."))

        # At this point the server should be okay
        log_debug(3, "Connected to parent: %s " % self.rhnParent)
        if self.httpProxy:
            if self.httpProxyUsername:
                log_debug(3, "HTTP proxy info: %s %s/<password>" % (
                  self.httpProxy, self.httpProxyUsername))
            else:
                log_debug(3, "HTTP proxy info: %s" % self.httpProxy)
        else:
            log_debug(3, "HTTP proxy info: not using an HTTP proxy")
        log_debug(4, "Other connection info: %s:%s%s" % 
            (self.responseContext.getConnection().sock.getpeername() + \
            (self.uri, )))

    def _create_connection(self):
        """ Returns a Connection object """
        scheme, host, port, uri = self._parse_url(self.rhnParent)
        # Build the list of params
        params = {
            'host'  :   host,
            'port'  :   port,
        }
        if self.httpProxy:
            params['proxy'] = self.httpProxy
            params['username'] = self.httpProxyUsername
            params['password'] = self.httpProxyPassword
        if scheme == 'https' and self.caChain:
            params['trusted_certs'] = [self.caChain,]

        # Now select the right class
        if self.httpProxy:
            if scheme == 'https':
                conn_class = connections.HTTPSProxyConnection
            else:
                conn_class = connections.HTTPProxyConnection
        else:
            if scheme == 'https':
                conn_class = connections.HTTPSConnection
            else:
                conn_class = connections.HTTPConnection

        log_debug(5, "Using connection class", conn_class, 'Params:', params)
        return apply(conn_class, (), params)

    def _parse_url(self, url):
        """ Returns scheme, host, port, path. """
        scheme, netloc, path, params, query, frag = rhnLib.parseUrl(url)
        host, port = urllib.splitnport(netloc)
        if (port <= 0):
            port = None
        return scheme, host, port, path

    def _serverCommo(self, data):
        """ Handler part 2
        
            Server (or next proxy) communication.
            data is the self.req.read()
        """

        log_debug(1)

        # Copy the method from the original request, and use the
        # handler for this server
        # We add path_info to the put (GET, CONNECT, HEAD, PUT, POST) request.
        log_debug(2, self.req.method, self.uri)
        self.responseContext.getConnection().putrequest(self.req.method, 
                                                             self.uri)

        # Send the headers, the body and expect a response
        try:
            status, headers, bodyFd = self._proxy2server(data)
            self.responseContext.setHeaders(headers)
            self.responseContext.setBodyFd(bodyFd)
        except IOError:
            # Raised by HTTP*Connection.getresponse
            # Server closed connection on us, no need to mail out
            # XXX: why are we not mailing this out???
            Traceback("SharedHandler._serverCommo", self.req, mail=0)
            raise rhnFault(1000, _(
                "RHN Proxy error: connection with the RHN server failed"))
        except socket.error:
            # maybe self.req.read() failed?
            Traceback("SharedHandler._serverCommo", self.req)
            raise rhnFault(1000, _(
                "RHN Proxy error: connection with the RHN server failed"))

        log_debug(2, "HTTP status code (200 means all is well): %s" % status)

        # Now we need to decide how to deal with the server's response.  We'll
        # defer to subclass-specific implementation here.  The handler will
        # return apache.OK if the request was a success.

        return self._handleServerResponse(status)

    def _handleServerResponse(self, status):
        """ This method can be overridden by subclasses who want to handle server
            responses in their own way.  By default, we will wrap all the headers up
            and send them back to the client with an error status.  This method
            should return apache.OK if everything went according to plan.
        """
        if (status != apache.HTTP_OK) and (status != apache.HTTP_PARTIAL_CONTENT):
            # Non 200 response; have to treat it differently
            log_debug(2, "Forwarding status %s" % status)
            # Copy the incoming headers to err_headers_out
            headers = self.responseContext.getHeaders()
            if headers is not None:
                for k in headers.keys():
                    rhnLib.setHeaderValue(self.req.err_headers_out, k,
                        self._get_header(k))
            else:
                log_error('WARNING? - no incoming headers found!')
            # And that's that
            return status

        if (status == apache.HTTP_PARTIAL_CONTENT):
            return apache.HTTP_PARTIAL_CONTENT
        else:
            # apache.HTTP_OK becomes apache.OK.
            return apache.OK

    def _get_header(self, k, headerObj = None):
        if headerObj is None:
            headerObj = self.responseContext.getHeaders()

        if hasattr(headerObj, 'getheaders'):
            return headerObj.getheaders(k)
        # The pain of python 1.5.2
        headers = headerObj.getallmatchingheaders(k)
        hname = string.lower(str(k)) + ':'
        hlen = len(hname)
        ret = []
        for header in headers:
            hn = string.lower(header[:hlen])
            if hn != hname:
                log_debug(1, "Invalid header", header)
                continue
            ret.append(string.strip(header[hlen:]))
        return ret
            

    def _clientCommo(self, status=apache.OK):
        """ Handler part 3
            Forward server's response to the client.
        """
        log_debug(1)

        try:
            self._forwardServer2Client()
        except IOError:
            # Raised by HTTP*connection.getresponse
            # Client closed connection on us, no need to mail out a traceback
            Traceback("SharedHandler._clientCommo", self.req, mail=0)
            return apache.HTTP_SERVICE_UNAVAILABLE

        # Close all open response contexts.
        self.responseContext.clear()

        return status

    # --- PROTECTED METHODS ---

    def _getHeaders(self, req):
        """ Copy the incoming headers. """

        hdrs = UserDictCase()
        for k in req.headers_in.keys():
            # XXX misa: is this enough? Shouldn't we care about multivalued
            # headers?
            hdrs[k] = req.headers_in[k]
        return hdrs

    # Forward the server response to the client.
    def _forwardServer2Client(self):
        """ Forward headers, and bodyfd from server to the calling client.
            For most XMLRPC code, this function is called.
        """

        log_debug(1)

        # Okay, nothing interesting from the server;
        # we'll just forward what we got

        bodyFd = self.responseContext.getBodyFd()

        self._forwardHTTPHeaders(bodyFd, self.req)

        # Set the content type

        headers = self.responseContext.getHeaders()
        self.req.content_type = headers.gettype()
        self.req.send_http_header()

        # Forward the response body back to the client.

        self._forwardHTTPBody(bodyFd, self.req)

    def _proxy2server(self, body):
        hdrs = rhnFlags.get('outputTransportOptions')
        log_debug(3, hdrs, "Content length", len(body))

        # Put the headers into the output connection object
        http_connection = self.responseContext.getConnection()
        for (k, vals) in hdrs.items():
            if string.lower(k) == 'host':
                # Filtering this header, the connection object takes care of
                # it
                continue
            if type(vals) not in (ListType, TupleType):
                vals = [vals]
            for v in vals:
                log_debug(5, "Outgoing header", k, v)
                http_connection.putheader(k, v)
        http_connection.endheaders()

        # Send the body too if there is a body
        if body:
            http_connection.send(body)

        # At this point everything is sent to the server
        # We now wait for the response
        try:
	    response = http_connection.getresponse() 
        except TimeoutException, e:
            log_error("Connection timed out")
            return apache.HTTP_GATEWAY_TIME_OUT, None, None     
        headers = response.msg
        status = response.status
        # Get the body of the request too - well, just a fd actually
        # in this case, the response object itself.
        bodyFd = response
        return status, headers, bodyFd

    def _getEffectiveURI(self):
        if self.req.headers_in.has_key(rhnConstants.HEADER_EFFECTIVE_URI):
            return self.req.headers_in[rhnConstants.HEADER_EFFECTIVE_URI]
        else:
            return self.req.uri

    def _determineHTTPBodySize(self, headers):
        """ This routine attempts to determine the size of an HTTP body by searching
            the headers for a "Content-Length" field.  The size is returned, if
            found, otherwise 0 is returned.
        """

        # Get the size of the body
        size = 0
        if headers.has_key(rhnConstants.HEADER_CONTENT_LENGTH):
            try:
                size = int(headers[rhnConstants.HEADER_CONTENT_LENGTH])
            except ValueError:
                size = 0
        else:
            size = 0

        return size

    def _forwardHTTPHeaders(self, fromResponse, toRequest):
        """ This routine will transfer the header contents of an HTTP response to
            the output headers of an HTTP request for reply to the original
            requesting client.  This function does NOT call the request's
            send_http_header routine; that is the responsibility of the caller.
        """

        if fromResponse is None or toRequest is None:
            return

        # Iterate over each header in the response and place it in the request
        # output area.

        for k in fromResponse.msg.keys():

            # Get the value

            v = self._get_header(k, fromResponse.msg)

            # Set the field in the response

            rhnLib.setHeaderValue(toRequest.headers_out, k, v)
    
    def _forwardHTTPBody(self, fromResponse, toRequest):
        """ This routine will transfer the body of an HTTP response to the output
            area of an HTTP request for response to the original requesting client.
            The request's send_http_header function must be called before this
            function is called.
        """
        if fromResponse is None or toRequest is None:
            return

        # Get the size of the body

        size = self._determineHTTPBodySize(fromResponse.msg)
        log_debug(4, "Response body size: ", size)

        # Now fill in the bytes if need be.

        if size > 0:
            buf = fromResponse.read(CFG.BUFFER_SIZE)
            while buf:
                try:
                    toRequest.write(buf)
                    buf = fromResponse.read(CFG.BUFFER_SIZE)
                except IOError:
                    buf = 0

