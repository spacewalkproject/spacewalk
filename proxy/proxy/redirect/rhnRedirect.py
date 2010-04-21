# Red Hat Network Proxy Server SSL Redirect handler code.
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
# $Id: rhnRedirect.py,v 1.59.2.2 2007/08/01 15:07:26 msuchy Exp $

# language imports
import string
import socket
import re
from common import apache

# common module imports
from common.rhnLib import parseUrl
from common import log_debug, log_error, CFG, rhnFlags, rhnFault, rhnLib, \
    Traceback
from common.rhnTranslate import _

# local module imports
from proxy.rhnShared import SharedHandler
from proxy import rhnConstants

# rhnlib imports
from rhn import connections

# Main apache entry point for the proxy.
class RedirectHandler(SharedHandler):
    """ RHN Proxy SSL Redirect specific handler code called by rhnApache. 

        Workflow is:
        Client -> Apache:Broker -> Squid -> Apache:Redirect -> Satellite

        Redirect handler get all request for localhost:80 and they come 
        from Broker handler through Squid, which hadle caching.
        Redirect module transform destination url to parent or http proxy.
        Depend on what we have in CFG.
    """

    def __init__(self, req):
        SharedHandler.__init__(self, req)
        self.componentType = 'proxy.redirect'
        self._initConnectionVariables(req)
        
    def _initConnectionVariables(self, req):
        """ set connection variables 
            NOTE: self.{caChain,rhnParent,httpProxy*} are initialized
                  in SharedHandler
        """

        effectiveURI = self._getEffectiveURI()
        if CFG.USE_SSL:
            self.rhnParentXMLRPC = 'https://' + self.rhnParent + '/XMLRPC'
            self.rhnParent = 'https://' + self.rhnParent + effectiveURI
        else:
            self.rhnParentXMLRPC = 'http://' + self.rhnParent + '/XMLRPC'
            self.rhnParent = 'http://' + self.rhnParent + effectiveURI
            self.caChain = ''

        log_debug(3, 'remapped self.rhnParent:       %s' % self.rhnParent)
        log_debug(3, 'remapped self.rhnParentXMLRPC: %s' % self.rhnParentXMLRPC)

    def handler(self):
        """ Main handler for all requests pumped through this server. """

        log_debug(4, 'In redirect handler')
        self._prepHandler()
        #self.__checkLegalRedirect()

        # Rebuild the X-Forwarded-For header so that it reflects the actual
        # path of the request.  We must do this because squid is unable to
        # determine the "real" client, and will make each entry in the chain
        # 127.0.0.1.
        _oto = rhnFlags.get('outputTransportOptions')
        _oto['X-Forwarded-For'] = _oto['X-RHN-IP-Path']

        self.rhnParent = self.rhnParent or '' # paranoid

        log_debug(4, 'Connecting to parent...')
        self._connectToParent()  # part 1

        log_debug(4, 'Initiating communication with server...')
        status = self._serverCommo(self.req.read())       # part 2
        if (status != apache.OK) and (status != apache.HTTP_PARTIAL_CONTENT):
            log_debug(3, "Leaving handler with status code %s" % status)
            return status

        log_debug(4, 'Initiating communication with client...')
        # If we got this far, it has to be a good response
        return self._clientCommo(status)

    def _handleServerResponse(self, status):
        """ Here, we'll override the default behavior for handling server responses
            so that we can adequately handle 302's.

            We will follow redirects unless it is redirect to (re)login page. In which
            case we change protocol to https and return redirect to user.
        """

        # In case of a 302, redirect the original request to the location
        # specified in the response.

        if status == apache.HTTP_MOVED_TEMPORARILY or \
           status == apache.HTTP_MOVED_PERMANENTLY:

            log_debug(1, "Received redirect response: ", status)

            # if we redirected to ssl version of login page, send redirect directly to user
            headers = self.responseContext.getHeaders()
            if headers is not None:
                for headerKey in headers.keys():
                    if headerKey == 'location':
                        location = self._get_header(headerKey)
                        relogin = re.compile('https?://.*(/rhn/(Re)?Login.do\?.*)')
                        m = relogin.match(location[0])
                        if m:
                            # pull server name out of "t:o:k:e:n:hostname1,t:o:k:e:n:hostname2,..."
                            proxy_auth = self.req.headers_in['X-RHN-Proxy-Auth']
                            last_auth = string.split(proxy_auth, ',')[-1]
                            server_name = string.split(last_auth, ':')[-1]
                            log_debug(1, "Redirecting to SSL version of login page")
                            rhnLib.setHeaderValue(self.req.headers_out, 'Location',
                                "https://%s%s" % (server_name, m.group(1)))
                            return apache.HTTP_MOVED_PERMANENTLY


            redirectStatus = self.__redirectToNextLocation()

            # At this point, we've either:
            #
            #     (a) successfully redirected to the 3rd party
            #     (b) been told to redirect somewhere else from the 3rd party
            #     (c) run out of retry attempts
            #
            # We'll keep redirecting until we've received HTTP_OK or an error.

            while redirectStatus == apache.HTTP_MOVED_PERMANENTLY or \
                  redirectStatus == apache.HTTP_MOVED_TEMPORARILY:

                # We've been told to redirect again.  We'll pass a special
                # argument to ensure that if we end up back at the server, we
                # won't be redirected again.

                log_debug(1, "Redirected again!  Code=", redirectStatus)
                redirectStatus = self.__redirectToNextLocation(True)

            if (redirectStatus != apache.HTTP_OK) and (redirectStatus != apache.HTTP_PARTIAL_CONTENT):

                # We must have run out of retry attempts.  Fail over to Hosted 
                # to perform the request.

                log_debug(1, "Redirection failed; retries exhausted.  " \
                             "Failing over.  Code=",                    \
                             redirectStatus)
                redirectStatus = self.__redirectFailover()

            return SharedHandler._handleServerResponse(self, redirectStatus)

        else:
            # Otherwise, revert to default behavior.
            return SharedHandler._handleServerResponse(self, status)

    def __checkLegalRedirect(self):
        """ Check request to see if this coming from a RHN Proxy.
        
            THIS SHOULD NEVER FAIL!!!
            Probably not necessary, but stymies the casual abuser.
        """
        if not rhnFlags.get('outputTransportOptions').has_key('X-RHN-Proxy-Version'):
            log_debug(-1, 'THIS SHOULD NEVER HAPPEN!!!')
            raise rhnFault(1000,
                _("RHN Proxy Error: No SSL Redirect Request found!"))

    def __redirectToNextLocation(self, loopProtection = False):
        """ This function will perform a redirection to the next location, as 
            specified in the last response's "Location" header. This function will 
            return an actual HTTP response status code.  If successful, it will 
            return apache.HTTP_OK, not apache.OK.  If unsuccessful, this function       
            will retry a configurable number of times, as defined in 
            CFG.NETWORK_RETRIES.  The following codes define "success".
     
              HTTP_OK
              HTTP_PARTIAL_CONTENT
              HTTP_MOVED_TEMPORARILY
              HTTP_MOVED_PERMANENTLY
     
            Upon successful completion of this function, the responseContext
            should be populated with the response.
    
            Arguments:
        
            loopProtection - If True, this function will insert a special
                           header into the new request that tells the RHN
                           server not to issue another redirect to us, in case
                           that's where we end up being redirected.
      
            Return:
     
            This function may return any valid HTTP_* response code.  See 
            __redirectToNextLocationNoRetry for more info.
        """ 
        retriesLeft = CFG.NETWORK_RETRIES

        # We'll now try to redirect to the 3rd party.  We will keep
        # retrying until we exhaust the number of allowed attempts.
        # Valid response codes are:
        #     HTTP_OK
        #     HTTP_PARTIAL_CONTENT
        #     HTTP_MOVED_PERMANENTLY
        #     HTTP_MOVED_TEMPORARILY

        redirectStatus = self.__redirectToNextLocationNoRetry(loopProtection)
        while redirectStatus != apache.HTTP_OK                and \
              redirectStatus != apache.HTTP_PARTIAL_CONTENT   and \
              redirectStatus != apache.HTTP_MOVED_PERMANENTLY and \
              redirectStatus != apache.HTTP_MOVED_TEMPORARILY and \
              retriesLeft > 0:

            retriesLeft = retriesLeft - 1
            log_debug(1, "Redirection failed; trying again.  " \
                         "Retries left=",                      \
                         retriesLeft,                          \
                         "Code=",                              \
                         redirectStatus)

            # Pop the current response context and restore the state to 
            # the last successful response.  The acts of remove the current
            # context will cause all of its open connections to be closed.
            self.responseContext.remove()

            # XXX: Possibly sleep here for a second?
            redirectStatus = \
                self.__redirectToNextLocationNoRetry(loopProtection)

        return redirectStatus

    def __redirectToNextLocationNoRetry(self, loopProtection = False):
        """ This function will perform a redirection to the next location, as 
            specified in the last response's "Location" header. This function will 
            return an actual HTTP response status code.  If successful, it will 
            return apache.HTTP_OK, not apache.OK.  If unsuccessful, this function 
            will simply return; no retries will be performed.  The following error 
            codes can be returned:
     
            HTTP_OK,HTTP_PARTIAL_CONTENT - Redirect successful.
            HTTP_MOVED_TEMPORARILY     - Redirect was redirected again by 3rd party.
            HTTP_MOVED_PERMANENTLY     - Redirect was redirected again by 3rd party.
            HTTP_INTERNAL_SERVER_ERROR - Error extracting redirect information
            HTTP_SERVICE_UNAVAILABLE   - Could not connect to 3rd party server, 
                                         connection was reset, or a read error
                                         occurred during communication.
            HTTP_*                     - Any other HTTP status code may also be
                                         returned.
     
            Upon successful completion of this function, a new responseContext
            will be created and pushed onto the stack.
        """

        # Obtain the redirect location first before we replace the current
        # response context.  It's contained in the Location header of the
        # previous response.

        redirectLocation = self._get_header(rhnConstants.HEADER_LOCATION)

        # We are about to redirect to a new location so now we'll push a new
        # response context before we return any errors.
        self.responseContext.add()

        # There should always be a redirect URL passed back to us.  If not,
        # there's an error.

        if not redirectLocation or len(redirectLocation) == 0:
            log_error("  No redirect location specified!")
            Traceback(mail = 0)
            return apache.HTTP_INTERNAL_SERVER_ERROR

        # The _get_header function returns the value as a list.  There should
        # always be exactly one location specified.

        redirectLocation = redirectLocation[0]
        log_debug(1, "  Redirecting to: ", redirectLocation)

        # Tear apart the redirect URL.  We need the scheme, the host, the 
        # port (if not the default), and the URI.

        scheme, host, port, uri = self._parse_url(redirectLocation)

        # Add any params onto the URI since _parse_url doesn't include them.
        uri += redirectLocation[redirectLocation.index('?'):]

        # Now create a new connection.  We'll use SSL if configured to do
        # so.

        if CFG.USE_SSL:
            log_debug(1, "  Redirecting with SSL.  Cert= ", self.caChain)
            connection = \
                connections.HTTPSConnection(host, port, [self.caChain])
        else:
            log_debug(1, "  Redirecting withOUT SSL.")
            connection = connections.HTTPConnection(host, port)

        # Put the connection into the current response context.
        self.responseContext.setConnection(connection)

        # Now open the connection to the 3rd party server.

        log_debug(4, "Attempting to connect to 3rd party server...")
        try:
            connection.connect()
        except socket.error, e:
            log_error("Error opening redirect connection", redirectLocation, e)
            Traceback(mail = 0)
            return apache.HTTP_SERVICE_UNAVAILABLE
        log_debug(4, "Connected to 3rd party server:",
                     connection.sock.getpeername())

        # Put the request out on the wire.

        response = None
        try:
            # We'll redirect to the URI made in the original request, but with
            # the new server instead.

            log_debug(4, "Making request: ", self.req.method, uri)
            connection.putrequest(self.req.method, uri)

            # Add some custom headers.

            if loopProtection:
                connection.putheader(rhnConstants.HEADER_RHN_REDIRECT, '0')

            log_debug(4, "  Adding original URL header: ", self.rhnParent)
            connection.putheader(rhnConstants.HEADER_RHN_ORIG_LOC, 
                                 self.rhnParent)

            # Add all the other headers in the original request in case we
            # need to re-authenticate with Hosted.

            for hdr in self.req.headers_in.keys():
                if hdr.lower().startswith("x-rhn"):
            	    connection.putheader(hdr, self.req.headers_in[hdr])
                    log_debug(4, "Passing request header: ",
                                 hdr,
                                 self.req.headers_in[hdr])

            connection.endheaders()

            response = connection.getresponse()
        except IOError, ioe:
            # Raised by getresponse() if server closes connection on us.
            log_error("Redirect connection reset by peer.",
                      redirectLocation,
                      ioe)
            Traceback(mail = 0)

            # The connection is saved in the current response context, and
            # will be closed when the caller pops the context.
            return apache.HTTP_SERVICE_UNAVAILABLE

        except socket.error, se:
            # Some socket error occurred.  Possibly a read error.
            log_error("Redirect request failed.", redirectLocation, se)
            Traceback(mail = 0)

            # The connection is saved in the current response context, and
            # will be closed when the caller pops the context.
            return apache.HTTP_SERVICE_UNAVAILABLE

        # Save the response headers and body FD in the current communication
        # context.

        self.responseContext.setBodyFd(response)
        self.responseContext.setHeaders(response.msg)

        log_debug(4, "Response headers: ", 
                     self.responseContext.getHeaders().items())
        log_debug(4, "Got redirect response.  Status=", response.status)

        # Return the HTTP status to the caller.

        return response.status

    def __redirectFailover(self):
        """ This routine resends the original request back to the satellite/hosted
            system if a redirect to a 3rd party failed.  To prevent redirection loops
            from occurring, an "X-RHN-Redirect: 0" header is passed along with the
            request.  This function will return apache.HTTP_OK if everything 
            succeeded, otherwise it will return an appropriate HTTP error code.
        """
        
        # Add a special header which will tell the server not to send us any
        # more redirects.

        headers = rhnFlags.get('outputTransportOptions')
        headers[rhnConstants.HEADER_RHN_REDIRECT] = '0'

        log_debug(4, "Added X-RHN-Redirect header to outputTransportOptions:", \
                     headers)

        # Reset the existing connection and reconnect to the RHN parent server.

        self.responseContext.clear()
        self._connectToParent()

        # We'll just call serverCommo once more.  The X-RHN-Redirect constant
        # will prevent us from falling into an infinite loop.  Only GETs are 
        # redirected, so we can safely pass an empty string in as the request
        # body.

        status = self._serverCommo('')

        # This little hack isn't pretty, but lets us normalize our result code.

        if status == apache.OK:
            status = apache.HTTP_OK

        return status

#===============================================================================

