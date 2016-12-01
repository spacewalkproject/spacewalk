# Main entry point for apacheServer.py for the Spacewalk Proxy
# and/or SSL Redirect Server.
#
# Copyright (c) 2008--2015 Red Hat, Inc.
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

# language imports
import os
import base64
import xmlrpclib
import re

# common imports
from spacewalk.common.rhnConfig import CFG
from spacewalk.common.rhnLog import log_debug, log_error
from spacewalk.common.rhnApache import rhnApache
from spacewalk.common.rhnTB import Traceback
from spacewalk.common.rhnException import rhnFault, rhnException
from spacewalk.common import rhnFlags, apache
from spacewalk.common.rhnLib import setHeaderValue
from spacewalk.common import byterange

from rhn import rpclib, connections
from rhn.UserDictCase import UserDictCase
from rhnConstants import HEADER_ACTUAL_URI, HEADER_EFFECTIVE_URI, \
    HEADER_CHECKSUM, SCHEME_HTTP, SCHEME_HTTPS, URI_PREFIX_KS, \
    URI_PREFIX_KS_CHECKSUM, COMPONENT_BROKER, COMPONENT_REDIRECT

# local imports
from proxy.rhnProxyAuth import get_proxy_auth


def getComponentType(req):
    """
        Are we a 'proxy.broker' or a 'proxy.redirect'.

        Checks to see if the last visited Spacewalk Proxy was itself. If so, we
        are a 'proxy.redirect'. If not, then we must be a 'proxy.broker'.
    """

    # NOTE: X-RHN-Proxy-Auth described in broker/rhnProxyAuth.py
    if not req.headers_in.has_key('X-RHN-Proxy-Auth'):
        # Request comes from a client, Must be the broker
        return COMPONENT_BROKER

    # pull server id out of "t:o:k:e:n:hostname1,t:o:k:e:n:hostname2,..."
    proxy_auth = req.headers_in['X-RHN-Proxy-Auth']
    last_auth = proxy_auth.split(',')[-1]
    last_visited = last_auth.split(':')[0]
    proxy_server_id = get_proxy_auth().getProxyServerId()
    # is it the same box?
    try:
        log_debug(4, "last_visited", last_visited, "; proxy server id",
                  proxy_server_id)
    # pylint: disable=W0702
    except:
        # pylint: disable=W0702
        # incase called prior to the log files being initialized
        pass
    if last_visited == proxy_server_id:
        # XXX this assumes redirect runs on the same box as the broker
        return COMPONENT_REDIRECT

    return COMPONENT_BROKER


class apacheHandler(rhnApache):

    """ Main apache entry point for the proxy. """
    _lang_catalog = "proxy"

    def __init__(self):
        rhnApache.__init__(self)
        self.input = None
        self._component = None

    def set_component(self, component):
        self._component = component

    @staticmethod
    def _setSessionToken(headers):
        # extended to always return a token, even if an empty one
        ret = rhnApache._setSessionToken(headers)
        if ret:
            log_debug(4, "Returning", ret)
            return ret

        # Session token did not verify, we have an empty auth token
        token = UserDictCase()
        rhnFlags.set("AUTH_SESSION_TOKEN", token)
        return token

    def headerParserHandler(self, req):
        """ Name-munging if request came from anaconda in response to a
            kickstart. """
        ret = rhnApache.headerParserHandler(self, req)
        if ret != apache.OK:
            return ret

        self.input = rpclib.transports.Input(req.headers_in)

        # Before we allow the main handler code to commence, we'll first check
        # to see if this request came from anaconda in response to a kickstart.
        # If so, we'll need to do some special name-munging before we continue.

        ret = self._transformKickstartRequest(req)
        return ret

    def _transformKickstartRequest(self, req):
        """ If necessary, this routine will transform a "tinified" anaconda-
            generated kickstart request into a normalized form capable of being
            cached effectively by squid.

            This is done by first making a HEAD request
            to the satellite for the purpose of updating the kickstart progress and
            retrieving an MD5 sum for the requested file.  We then replace the
            tinyURL part of the URI with the retrieved MD5 sum.  This effectively
            removes session-specific information while allowing us to still cache
            based on the uniqueness of the file.
        """
        # Kickstart requests only come in the form of a GET, so short-circuit
        # if that is not the case.

        if (req.method != "GET"):
            return apache.OK

        log_debug(6, "URI", req.uri)
        log_debug(6, "COMPONENT", self._component)

        # If we're a broker, we know that this is a kickstart request from
        # anaconda by checking if the URI begins with /ty/*, otherwise just
        # return.  If we're an SSL redirect, we check that the URI begins with
        # /ty-cksm/*, otherwise return.

        if self._component == COMPONENT_BROKER:
            if req.uri.startswith(URI_PREFIX_KS):
                log_debug(3, "Found a kickstart URI: %s" % req.uri)
                return self._transformKsRequestForBroker(req)
        elif self._component == COMPONENT_REDIRECT:
            if req.uri.startswith(URI_PREFIX_KS_CHECKSUM):
                log_debug(3, "Found a kickstart checksum URI: %s" % req.uri)
                return self._transformKsRequestForRedirect(req)

        return apache.OK

    def _transformKsRequestForBroker(self, req):

        # Get the checksum for the requested resource from the satellite.

        (status, checksum) = self._querySatelliteForChecksum(req)
        if status != apache.OK or not checksum:
            return status

        # If we got this far, we have the checksum.  Create a new URI based on
        # the checksum.

        newURI = self._generateCacheableKickstartURI(req.uri, checksum)
        if not newURI:
            # Couldn't create a cacheable URI, log an error and revert to
            # BZ 158236 behavior.

            log_error('Could not create cacheable ks URI from "%s"' % req.uri)
            return apache.OK

        # Now we must embed the old URI into a header in the original request
        # so that the SSL Redirect has it available if the resource has not
        # been cached yet.  We will also embed a header that holds the new URI,
        # so that the content handler can use it later.

        log_debug(3, "Generated new kickstart URI: %s" % newURI)
        req.headers_in[HEADER_ACTUAL_URI] = req.uri
        req.headers_in[HEADER_EFFECTIVE_URI] = newURI

        return apache.OK

    @staticmethod
    def _transformKsRequestForRedirect(req):

        # If we don't get the actual URI in the headers, we'll decline the
        # request.

        if not req.headers_in or not req.headers_in.has_key(HEADER_ACTUAL_URI):
            log_error("Kickstart request header did not include '%s'"
                      % HEADER_ACTUAL_URI)
            return apache.DECLINED

        # The original URI is embedded in the headers under X-RHN-ActualURI.
        # Remove it, and place it in the X-RHN-EffectiveURI header.

        req.headers_in[HEADER_EFFECTIVE_URI] = req.headers_in[HEADER_ACTUAL_URI]
        log_debug(3, "Reverting to old URI: %s" % req.headers_in[HEADER_ACTUAL_URI])

        return apache.OK

    def _querySatelliteForChecksum(self, req):
        """ Sends a HEAD request to the satellite for the purpose of obtaining
            the checksum for the requested resource.  A (status, checksum)
            tuple is returned.  If status is not apache.OK, checksum will be
            None.  If status is OK, and a checksum is not returned, the old
            BZ 158236 behavior will be used.
        """
        scheme = SCHEME_HTTP
        if req.server.port == 443:
            scheme = SCHEME_HTTPS
        log_debug(6, "Using scheme: %s" % scheme)

        # Initiate a HEAD request to the satellite to retrieve the MD5 sum.
        # Actually, we make the request through our own proxy first, so
        # that we don't accidentally bypass necessary authentication
        # routines.  Since it's a HEAD request, the proxy will forward it
        # directly to the satellite like it would a POST request.

        host = "127.0.0.1"
        port = req.connection.local_addr[1]

        connection = self._createConnection(host, port, scheme)
        if not connection:
            # Couldn't form the connection.  Log an error and revert to the
            # old BZ 158236 behavior.  In order to be as robust as possible,
            # we won't fail here.

            log_error('HEAD req - Could not create connection to %s://%s:%s'
                      % (scheme, host, str(port)))
            return (apache.OK, None)

        # We obtained the connection successfully.  Construct the URL that
        # we'll connect to.

        pingURL = "%s://%s:%s%s" % (scheme, host, str(port), req.uri)
        log_debug(6, "Ping URI: %s" % pingURL)

        hdrs = UserDictCase()
        for k in req.headers_in.keys():
            if k.lower() != 'range':  # we want checksum of whole file
                hdrs[k] = re.sub(r'\n(?![ \t])|\r(?![ \t\n])', '', str(req.headers_in[k]))

        log_debug(9, "Using existing headers_in", hdrs)
        connection.request("HEAD", pingURL, None, hdrs)
        log_debug(6, "Connection made, awaiting response.")

        # Get the response.

        response = connection.getresponse()
        log_debug(6, "Received response status: %s" % response.status)
        connection.close()

        if (response.status != apache.HTTP_OK) and (response.status != apache.HTTP_PARTIAL_CONTENT):
            # Something bad happened.  Return back back to the client.

            log_debug(1, "HEAD req - Received error code in reponse: %s"
                      % (str(response.status)))
            return (response.status, None)

        # The request was successful.  Dig the MD5 checksum out of the headers.

        responseHdrs = response.msg
        if not responseHdrs:
            # No headers?!  This shouldn't happen at all.  But if it does,
            # revert to the old # BZ 158236 behavior.

            log_error("HEAD response - No HTTP headers!")
            return (apache.OK, None)

        if not responseHdrs.has_key(HEADER_CHECKSUM):
            # No checksum was provided.  This could happen if a newer
            # proxy is talking to an older satellite.  To keep things
            # running smoothly, we'll just revert to the BZ 158236
            # behavior.

            log_debug(1, "HEAD response - No X-RHN-Checksum field provided!")
            return (apache.OK, None)

        checksum = responseHdrs[HEADER_CHECKSUM]

        return (apache.OK, checksum)

    @staticmethod
    def _generateCacheableKickstartURI(oldURI, checksum):
        """
        This routine computes a new cacheable URI based on the old URI and the
        checksum. For example, if the checksum is 1234ABCD and the oldURI was:

            /ty/AljAmCEt/RedHat/base/comps.xml

        Then, the new URI will be:

            /ty-cksm/1234ABCD/RedHat/base/comps.xml

        If for some reason the new URI could not be generated, return None.
        """

        newURI = URI_PREFIX_KS_CHECKSUM + checksum

        # Strip the first two path pieces off of the oldURI.

        uriParts = oldURI.split('/')
        numParts = 0
        for part in uriParts:
            if len(part) is not 0:  # Account for double slashes ("//")
                numParts += 1
                if numParts > 2:
                    newURI += "/" + part

        # If the URI didn't have enough parts, return None.

        if numParts <= 2:
            newURI = None

        return newURI

    @staticmethod
    def _createConnection(host, port, scheme):
        params = {'host': host,
                  'port': port}

        if CFG.has_key('timeout'):
            params['timeout'] = CFG.TIMEOUT

        if scheme == SCHEME_HTTPS:
            conn_class = connections.HTTPSConnection
        else:
            conn_class = connections.HTTPConnection

        return conn_class(**params)

    def handler(self, req):
        """ Main handler to handle all requests pumped through this server. """

        ret = rhnApache.handler(self, req)
        if ret != apache.OK:
            return ret

        log_debug(4, "METHOD", req.method)
        log_debug(4, "PATH_INFO", req.path_info)
        log_debug(4, "URI (full path info)", req.uri)
        log_debug(4, "Component", self._component)

        if self._component == COMPONENT_BROKER:
            from broker import rhnBroker
            handlerObj = rhnBroker.BrokerHandler(req)
        else:
            # Redirect
            from redirect import rhnRedirect
            handlerObj = rhnRedirect.RedirectHandler(req)

        try:
            ret = handlerObj.handler()
        except rhnFault, e:
            return self.response(req, e)

        if rhnFlags.test("NeedEncoding"):
            return self.response(req, ret)

        # All good; we expect ret to be an HTTP return code
        if not isinstance(ret, type(1)):
            raise rhnException("Invalid status code type %s" % type(ret))
        log_debug(1, "Leaving with status code %s" % ret)
        return ret

    @staticmethod
    def normalize(response):
        """ convert a response to the right type for passing back to
            rpclib.xmlrpclib.dumps
        """
        if isinstance(response, xmlrpclib.Fault):
            return response
        return (response,)

    @staticmethod
    def response_file(req, response):
        """ send a file out """
        log_debug(3, response.name)
        # We may set the content type remotely
        if rhnFlags.test("Content-Type"):
            req.content_type = rhnFlags.get("Content-Type")
        else:
            # Safe default
            req.content_type = "application/octet-stream"

        # find out the size of the file
        if response.length == 0:
            response.file_obj.seek(0, 2)
            file_size = response.file_obj.tell()
            response.file_obj.seek(0, 0)
        else:
            file_size = response.length

        success_response = apache.OK
        response_size = file_size

        # Serve up the requested byte range
        if req.headers_in.has_key("Range"):
            try:
                range_start, range_end = \
                    byterange.parse_byteranges(req.headers_in["Range"],
                                               file_size)
                response_size = range_end - range_start
                req.headers_out["Content-Range"] = \
                    byterange.get_content_range(range_start, range_end, file_size)
                req.headers_out["Accept-Ranges"] = "bytes"

                response.file_obj.seek(range_start)

                # We'll want to send back a partial content rather than ok
                # if this works
                req.status = apache.HTTP_PARTIAL_CONTENT
                success_response = apache.HTTP_PARTIAL_CONTENT

            # For now we will just return the file file on the following exceptions
            except byterange.InvalidByteRangeException:
                pass
            except byterange.UnsatisfyableByteRangeException:
                pass

        req.headers_out["Content-Length"] = str(response_size)

        # if we loaded this from a real fd, set it as the X-Replace-Content
        # check for "name" since sometimes we get xmlrpclib.transports.File's that have
        # a stringIO as the file_obj, and they dont have a .name (ie,
        # fileLists...)
        if response.name:
            req.headers_out["X-Package-FileName"] = response.name

        xrepcon = req.headers_in.has_key("X-Replace-Content-Active") \
            and rhnFlags.test("Download-Accelerator-Path")
        if xrepcon:
            fpath = rhnFlags.get("Download-Accelerator-Path")
            log_debug(1, "Serving file %s" % fpath)
            req.headers_out["X-Replace-Content"] = fpath
            # Only set a byte rate if xrepcon is active
            byte_rate = rhnFlags.get("QOS-Max-Bandwidth")
            if byte_rate:
                req.headers_out["X-Replace-Content-Throttle"] = str(byte_rate)

        # send the headers
        req.send_http_header()

        if req.headers_in.has_key("Range"):
            # and the file
            read = 0
            while read < response_size:
                # We check the size here in case we're not asked for the entire file.
                buf = response.read(CFG.BUFFER_SIZE)
                if not buf:
                    break
                try:
                    req.write(buf)
                    read = read + CFG.BUFFER_SIZE
                except IOError:
                    if xrepcon:
                        # We're talking to a proxy, so don't bother to report
                        # a SIGPIPE
                        break
                    return apache.HTTP_BAD_REQUEST
            response.close()
        else:
            if 'wsgi.file_wrapper' in req.headers_in:
                req.output = req.headers_in['wsgi.file_wrapper'](response, CFG.BUFFER_SIZE)
            else:
                req.output = iter(lambda: response.read(CFG.BUFFER_SIZE), '')
        return success_response

    def response(self, req, response):
        """ send the response (common code) """

        # Send the xml-rpc response back
        log_debug(5, "Response type", type(response))

        needs_xmlrpc_encoding = rhnFlags.test("NeedEncoding")
        compress_response = rhnFlags.test("compress_response")
        # Init an output object; we'll use it for sending data in various
        # formats
        if isinstance(response, rpclib.transports.File):
            if not hasattr(response.file_obj, 'fileno') and compress_response:
                # This is a StringIO that has to be compressed, so read it in
                # memory; mark that we don't have to do any xmlrpc encoding
                response = response.file_obj.read()
                needs_xmlrpc_encoding = 0
            else:
                # Just treat is as a file
                return self.response_file(req, response)

        is_fault = 0
        if isinstance(response, rhnFault):
            if req.method == 'GET':
                return self._response_fault_get(req, response.getxml())
            # Need to encode the response as xmlrpc
            response = response.getxml()
            is_fault = 1
            # No compression
            compress_response = 0
            # This is an xmlrpc Fault, so we have to encode it
            needs_xmlrpc_encoding = 1

        output = rpclib.transports.Output()

        if not is_fault:
            # First, use the same encoding/transfer that the client used
            output.set_transport_flags(
                transfer=rpclib.transports.lookupTransfer(self.input.transfer),
                encoding=rpclib.transports.lookupEncoding(self.input.encoding))

        if compress_response:
            # check if we have to compress this result
            log_debug(4, "Compression on for client version", self.clientVersion)
            if self.clientVersion > 0:
                output.set_transport_flags(output.TRANSFER_BINARY,
                                           output.ENCODE_ZLIB)
            else:  # original clients had the binary transport support broken
                output.set_transport_flags(output.TRANSFER_BASE64,
                                           output.ENCODE_ZLIB)

        # We simply add the transport options to the output headers
        output.headers.update(rhnFlags.get('outputTransportOptions').dict())

        if needs_xmlrpc_encoding:
            # Normalize the response
            response = self.normalize(response)
            try:
                response = rpclib.xmlrpclib.dumps(response, methodresponse=1)
            except TypeError, e:
                log_debug(-1, "Error \"%s\" encoding response = %s" % (e, response))
                Traceback("apacheHandler.response", req,
                          extra="Error \"%s\" encoding response = %s" % (e, response),
                          severity="notification")
                return apache.HTTP_INTERNAL_SERVER_ERROR
            except Exception:  # pylint: disable=E0012, W0703
                # Uncaught exception; signal the error
                Traceback("apacheHandler.response", req,
                          severity="unhandled")
                return apache.HTTP_INTERNAL_SERVER_ERROR

        # we're about done here, patch up the headers
        output.process(response)
        # Copy the rest of the fields
        for k, v in output.headers.items():
            if k.lower() == 'content-type':
                # Content-type
                req.content_type = v
            else:
                setHeaderValue(req.headers_out, k, v)

        if CFG.DEBUG == 4:
            # I wrap this in an "if" so we don't parse a large file for no reason.
            log_debug(4, "The response: %s[...SNIP (for sanity) SNIP...]%s" %
                      (response[:100], response[-100:]))
        elif CFG.DEBUG >= 5:
            # if you absolutely must have that whole response in the log file
            log_debug(5, "The response: %s" % response)

        # send the headers
        req.send_http_header()
        try:
            # XXX: in case data is really large maybe we should split
            # it in smaller chunks instead of blasting everything at
            # once. Not yet a problem...
            req.write(output.data)
        except IOError:
            # send_http_header is already sent, so it doesn't make a lot of
            # sense to return a non-200 error; but there is no better solution
            return apache.HTTP_BAD_REQUEST
        del output
        return apache.OK

    @staticmethod
    def _response_fault_get(req, response):
        req.headers_out["X-RHN-Fault-Code"] = str(response.faultCode)
        faultString = base64.encodestring(response.faultString).strip()
        # Split the faultString into multiple lines
        for line in faultString.split('\n'):
            req.headers_out.add("X-RHN-Fault-String", line.strip())
        # And then send all the other things
        for k, v in rhnFlags.get('outputTransportOptions').items():
            setHeaderValue(req.headers_out, k, v)
        return apache.HTTP_NOT_FOUND

    def cleanupHandler(self, req):
        """ Clean up stuff before we close down the session when we are
            called from apacheServer.Cleanup()
        """

        log_debug(1)
        self.input = None
        # kill all of our child processes (if any)
        while 1:
            pid = status = -1
            try:
                (pid, status) = os.waitpid(-1, 0)
            except OSError:
                break
            else:
                log_error("Reaped child process %d with status %d" % (pid, status))
        ret = rhnApache.cleanupHandler(self, req)
        return ret

# =============================================================================
