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
# This module implements requests handlers for GET and POST methods.
#

# system modules
import sys
import base64
import string
from rhn import rpclib
from rhn.rpclib import transports
from server import apache

# common modules
from common import CFG, rhnFault, rhnFlags, redirectException #to catch redirect exception
from common import log_debug, log_error, Traceback
from common.rhnTranslate import _
from common.rhnLib import setHeaderValue

# local modules
import rhnRepository
import rhnImport
import rhnSQL
import rhnCapability
import apacheAuth
import byterange

# Exceptions
class UnknownXML(Exception):
    def __init__(self, value):
        Exception.__init__(self)
        self.__value = value

    def __repr__(self):
        return _("Invalid request received (%s).") % self.__value
    __str__ = __repr__

class HandlerNotFoundError(Exception):
    pass

# base class for requests
class apacheRequest:
    def __init__(self, client_version, req):
        self.client = client_version
        self.req = req
        # grab an Input object
        self.input = transports.Input(req.headers_in)
        # make sure we have a parser and a decoder available
        self.parser, self.decoder = rpclib.xmlrpclib.getparser()
        # Make sure the decoder doesn't assume UTF-8 data, that would break if
        # non-UTF-8 chars are sent (bug 139370)
        self.decoder._encoding = None

        # extract the server we're talking to and the root directory
        # from the request configuration options
        req_config = req.get_options()
        # XXX: attempt to catch these KeyErrors sometime when there is
        # time to play nicely
        self.server = req_config["SERVER"]
        # Load the server classes
        # XXX: some day we're going to trust the timestamp stuff...
        self.root_dir = req_config["RootDir"]
        self.servers = None
        self._setup_servers()
        
    def _setup_servers(self):
        self.servers = rhnImport.load("server/handlers", root_dir=self.root_dir,
            interface_signature='rpcClasses')

    # return a reference to a method name. The method in the base
    def method_ref(self, method):
        raise UnknownXML("Could not find reference definition"
                         "for method '%s'" % method)

    # call a function with parameters
    def call_function(self, method, params):
        # short-circuit everything if sending a system-wide message.
        if CFG.SEND_MESSAGE_TO_ALL:
            # Make sure the applet doesn't see the message
            if method == 'applet.poll_status':
                return self.response({ 
                    'checkin_interval' : 3600, 
                    'server_status' : 'normal'
                })
            if method == 'applet.poll_packages':
                return self.response({ 'use_cached_copy' : 1 })
                
            # Fetch global message being sent to clients if applicable.
            msg = open(CFG.MESSAGE_TO_ALL).read()
            log_debug(3, "Sending message to all clients: %s" % msg)
            # Send the message as a fault.
            response = rpclib.Fault(
                -1, _("IMPORTANT MESSAGE FOLLOWS:\n%s") % msg)
            # and now send everything back
            ret = self.response(response)
            log_debug(4, "Leave with return value", ret)
            return ret

        # req: where the response is sent to
        log_debug(2, method)

        # Now we have the reference, call away
        force_rollback = 1
        try:
            # now get the function reference and call it
            func = self.method_ref(method)
            if len(params):
                response = apply(func, params)
            else:
                response = func()
        except (TypeError, ValueError, KeyError, IndexError, UnknownXML):
            # report exception back to server
            fault = 1
            if sys.exc_type == UnknownXML:
                fault = -1
            e_type, e_value = sys.exc_info()[:2]
            response = rpclib.Fault(fault, _(
                "While running '%s': caught\n%s : %s\n") % (
                method, e_type, e_value))
            Traceback(method, self.req,
                extra="Response sent back to the caller:\n%s\n" % (
                    response.faultString,),
                severity="notification")
            
        #pkilambi:catch exception if redirect
        except redirectException, re:
            log_debug(3,"redirect exception caught",re.path)
            response = re.path

        except rhnFault, f:
            response = f.getxml()
        except rhnSQL.SQLSchemaError, e:
            f = None
            if e.errno == 20200:
                log_debug(2, "User Group Membership EXCEEDED")
                f = rhnFault(43, e.errmsg)
            elif e.errno == 20220:
                log_debug(2, "Server Group Membership EXCEEDED")
                f = rhnFault(44, e.errmsg)
            if not f:
                log_debug(4, "rhnSQL.SQLSchemaError caught", e)
                rhnSQL.rollback()
                # generate the traceback report
                Traceback(method, self.req,
                          extra = "SQL Error generated: %s" % e,
                          severity="schema")
                return apache.HTTP_INTERNAL_SERVER_ERROR
            response = f.getxml()
        except rhnSQL.SQLError, e:
            log_debug(4, "rhnSQL.SQLError caught", e)
            rhnSQL.rollback()
            Traceback(method, self.req,
                      extra="SQL Error generated: %s" % e,
                      severity="schema")
            return apache.HTTP_INTERNAL_SERVER_ERROR
        except:
            rhnSQL.rollback()
            # otherwise we do a full stop
            Traceback(method, self.req, severity="unhandled")
            return apache.HTTP_INTERNAL_SERVER_ERROR
        else:
            # if no exception, we don't need to rollback
            force_rollback = 0
        if force_rollback:
            rhnSQL.rollback()
        # and now send everything back
        ret = self.response(response)
        log_debug(4, "Leave with return value", ret)
        return ret

    # process the request
    def process(self):
        # this is just a stub we'd better override
        return apache.HTTP_NOT_IMPLEMENTED

    # convert a response to the right type for passing back to
    # rpclib.xmlrpclib.dumps
    def normalize(self, response):
        if isinstance(response, rpclib.Fault):
            return response
        return (response,)

    # send a file out
    def response_file(self, response):
        log_debug(3, response.name)
        # We may set the content type remotely
        if rhnFlags.test("Content-Type"):
            self.req.content_type = rhnFlags.get("Content-Type")
        else:
            # Safe default
            self.req.content_type = "application/octet-stream"

        # find out the size of the file
        if response.length == 0:
            response.file_obj.seek(0,2)
            file_size = response.file_obj.tell()
            response.file_obj.seek(0,0)
        else:
            file_size = response.length

        success_response = apache.OK
        response_size = file_size

        # Serve up the requested byte range
        if self.req.headers_in.has_key("Range"):
            try:
                range_start, range_end = \
                    byterange.parse_byteranges(self.req.headers_in["Range"],
                        file_size)
                response_size = range_end - range_start
                self.req.headers_out["Content-Range"] = \
                    byterange.get_content_range(range_start, range_end, file_size)
                self.req.headers_out["Accept-Ranges"] = "bytes"

                response.file_obj.seek(range_start)

                # We'll want to send back a partial content rather than ok
                # if this works
                self.req.status = apache.HTTP_PARTIAL_CONTENT
                success_response = apache.HTTP_PARTIAL_CONTENT

            # For now we will just return the file file on the following exceptions 
            except byterange.InvalidByteRangeException:
                pass
            except byterange.UnsatisfyableByteRangeException:
                pass



        self.req.headers_out["Content-Length"] = str(response_size)

        # if we loaded this from a real fd, set it as the X-Replace-Content
        # check for "name" since sometimes we get xmlrpclib.File's that have
        # a stringIO as the file_obj, and they dont have a .name (ie,
        # fileLists...)
        if response.name:
            self.req.headers_out["X-Package-FileName"] = response.name

        xrepcon = self.req.headers_in.has_key("X-Replace-Content-Active") \
                  and rhnFlags.test("Download-Accelerator-Path")
        if xrepcon:
            fpath = rhnFlags.get("Download-Accelerator-Path")
            log_debug(1, "Serving file %s" % fpath)
            self.req.headers_out["X-Replace-Content"] = fpath
            # Only set a byte rate if xrepcon is active
            byte_rate = rhnFlags.get("QOS-Max-Bandwidth")
            if byte_rate:
                self.req.headers_out["X-Replace-Content-Throttle"] = str(byte_rate)

        # send the headers
        self.req.send_http_header()
        # and the file
        read = 0
        while read < response_size:
            # We check the size here in case we're not asked for the entire file.
            if (read + CFG.BUFFER_SIZE > response_size):
                to_read = read + CFG.BUFFER_SIZE - response_size
            else:
                to_read = CFG.BUFFER_SIZE
            buf = response.read(CFG.BUFFER_SIZE)
            if not buf:
                break
            try:
                self.req.write(buf)
                read = read + CFG.BUFFER_SIZE
            except IOError:
                if xrepcon:
                    # We're talking to a proxy, so don't bother to report
                    # a SIGPIPE
                    break
                return apache.HTTP_BAD_REQUEST
        response.close()
        return success_response

    # send the response (common code)
    def response(self, response):
        # Send the xml-rpc response back
        log_debug(3, type(response))
        needs_xmlrpc_encoding = not rhnFlags.test("XMLRPC-Encoded-Response")
        compress_response = rhnFlags.test("compress_response")
        # Init an output object; we'll use it for sending data in various
        # formats
        if isinstance(response, rpclib.File):
            if not hasattr(response.file_obj, 'fileno') and compress_response:
                # This is a StringIO that has to be compressed, so read it in
                # memory; mark that we don't have to do any xmlrpc encoding
                response = response.file_obj.read()
                needs_xmlrpc_encoding = 0
            else:
                # Just treat is as a file
                return self.response_file(response)
        
        output = transports.Output()

        # First, use the same encoding/transfer that the client used
        output.set_transport_flags(
            transfer=transports.lookupTransfer(self.input.transfer), 
            encoding=transports.lookupEncoding(self.input.encoding))

        if isinstance(response, rpclib.Fault):
            log_debug(4, "Return FAULT",
                      response.faultCode, response.faultString)
            # No compression for faults because we'd like them to pop
            # up in clear text on the other side just in case
            output.set_transport_flags(output.TRANSFER_NONE, output.ENCODE_NONE)
        elif compress_response:
            # check if we have to compress this result
            log_debug(4, "Compression on for client version", self.client)
            if self.client > 0:
                output.set_transport_flags(output.TRANSFER_BINARY,
                                     output.ENCODE_ZLIB)
            else: # original clients had the binary transport support broken
                output.set_transport_flags(output.TRANSFER_BASE64,
                                     output.ENCODE_ZLIB)

        # We simply add the transport options to the output headers
        output.headers.update(rhnFlags.get('outputTransportOptions').dict())

        if needs_xmlrpc_encoding:
            # Normalize the response
            response = self.normalize(response)
            try:
                response = rpclib.xmlrpclib.dumps(response, methodresponse = 1)
            except TypeError, e:
                log_debug(4, "Error \"%s\" encoding response = %s" % (e, response))
                Traceback("apacheHandler.response", self.req,
                    extra="Error \"%s\" encoding response = %s" % (e, response),
                    severity="notification")
                return apache.HTTP_INTERNAL_SERVER_ERROR
            except:
                # Uncaught exception; signal the error
                Traceback("apacheHandler.response", self.req,
                    severity="unhandled")
                return apache.HTTP_INTERNAL_SERVER_ERROR

        # we're about done here, patch up the headers
        output.process(response)
        # Copy the rest of the fields
        for k, v in output.headers.items():
            if string.lower(k) == 'content-type':
                # Content-type
                self.req.content_type = v
            else:
                setHeaderValue(self.req.headers_out, k, v)

	if 5 <= CFG.DEBUG < 10:
            log_debug(5, "The response: %s[...SNIP (for sanity) SNIP...]%s" % (response[:100], response[-100:]))
        elif CFG.DEBUG >= 10:
            # if you absolutely must have that whole response in the log file
            log_debug(10, "The response: %s" % response)

        # send the headers
        self.req.send_http_header()
        try:
            # XXX: in case data is really large maybe we should split
            # it in smaller chunks instead of blasting everything at
            # once. Not yet a problem...
            self.req.write(output.data)
        except IOError:
            # send_http_header is already sent, so it doesn't make a lot of
            # sense to return a non-200 error; but there is no better solution
            return apache.HTTP_BAD_REQUEST
        del output
        return apache.OK

    def auth_client(self):
        return apacheAuth.auth_client()

    def auth_proxy(self):
        return apacheAuth.auth_proxy()

# handles the POST requests
class apachePOST(apacheRequest):
    # Decode the request. Returns a tuple of (params, methodName).
    def decode(self, data):
        try:
            self.parser.feed(data)
        except IndexError:
            # malformed XML data
            raise rpclib.ResponseError

        self.parser.close()
        # extract the method and arguments; we pass the exceptions through
        params = self.decoder.close()
        method = self.decoder.getmethodname()
        return params, method

    # get the function reference for the POST request
    def method_ref(self, method):
        # Execute the right function (from xml-rpc request) in the right class.
        # NOTE: All functions should do their own logging
        log_debug(3, self.server, method)
        if method[-8:] == '.__str__':
            # Ignore these, they are just some code trying to stringify an
            # XML-RPC function
            log_error("Ignoring call for method", method)
            raise rhnFault(-1, "Ignoring call for a __str__ method", explain=0)
        if self.server is None:
            raise UnknownXML("Method `%s' is not bound to a server "
                             "(server = %s)" % (method, self.server))
        classes = self.servers[self.server]
        if classes is None:
            raise UnknownXML("Server %s is not a valid XML-RPC receiver" %
                             (self.server,))

        try:
            classname, funcname = string.split(method, '.', 1)
        except:
            raise UnknownXML("method '%s' doesn't have a class and function" %
                             (method,))
        if not classname or not funcname:
            raise UnknownXML(method)

        log_debug(4, "Class name: %s; function name: %s" % (classname,
            funcname))
        c = classes.get(classname)
        if c is None:
            raise UnknownXML("class %s.%s is not defined (function = %s)" % (
                self.server, classname, funcname))

        # Initialize the handlers object
        serverHandlers = c()
        # we need this for sat handler
        serverHandlers.remote_hostname = self.req.get_remote_host(apache.REMOTE_DOUBLE_REV)
        f = serverHandlers.get_function(funcname)
        if f is None:
            raise UnknownXML("function: %s invalid" % (method,))
        # Send the client this server's capabilities
        rhnCapability.set_server_capabilities()
        return f

    # handle the POST requests
    def process(self):
        log_debug(3)
        # nice thing that req has a read() method, so it makes it look just
        # like an fd
        try:
            fd = self.input.decode(self.req)
        except IOError: # client timed out
            return apache.HTTP_BAD_REQUEST

        # Read the data from the request
        _body = fd.read()
        fd.close()

        # In this case, we talk to a client (maybe through a proxy)
        # make sure we have something to decode
        if _body is None or len(_body) == 0:
            return apache.HTTP_BAD_REQUEST

        # Decode the request; avoid logging crappy responses
        try:
            params, method = self.decode(_body)
        except rpclib.ResponseError:
            log_error("Got bad XML-RPC blob of len = %d" % len(_body))
            return apache.HTTP_BAD_REQUEST
        else:
            if params is None:
                params = ()
        # make the actual function call and return the result
        return self.call_function(method, params)

class apacheGET:
    def __init__(self, client_version, req):
        # extract the server we're talking to and the root directory
        # from the request configuration options
        req_config = req.get_options()
        self.server = req_config["SERVER"]
        self.root_dir = req_config["RootDir"]
        # XXX: some day we're going to trust the timestamp stuff...
        self.handler_classes = rhnImport.load("server/handlers", 
            root_dir=self.root_dir, interface_signature='getHandler')
        log_debug(3, "Handler classes", self.handler_classes)

        self.handler = None
        if not self.handler_classes.has_key(self.server):
            raise HandlerNotFoundError(self.server)

        handler_class = self.handler_classes[self.server]
        if handler_class is None:
            # Was set just so that we make the logs quiet
            raise HandlerNotFoundError(self.server)
        log_debug(3, "Handler class", handler_class, type(handler_class))
        self.handler = handler_class(client_version, req)

    def __getattr__(self, name):
        return getattr(self.handler, name)

class GetHandler(apacheRequest):
    # we require our own init since we depend on a channel
    def __init__(self, client_version, req):
        apacheRequest.__init__(self, client_version, req)
        self.channel = None

    def _setup_servers(self):
        # Nothing to do here
        pass

    # get a function reference for the GET request
    def method_ref(self, method):
        log_debug(3, self.server, method)

        # Init the repository
        server_id = rhnFlags.get("AUTH_SESSION_TOKEN")['X-RHN-Server-Id']
        username = rhnFlags.get("AUTH_SESSION_TOKEN")['X-RHN-Auth-User-Id']
        repository = rhnRepository.Repository(self.channel, server_id,
                                              username)
        repository.set_qos()

        f = repository.get_function(method)
        if f is None:
            raise UnknownXML("function '%s' invalid; path_info is %s" % (
                method, self.req.path_info))
        return f

    # handle the GET requests
    def process(self):
        log_debug(3)
        # Query repository; only after a clients signature has been
        # authenticated.

        try:
            method, params = self._get_method_params()
        except rhnFault, f:
            log_debug(2, "Fault caught")
            response = f.getxml()
            self.response(response)
            return apache.HTTP_NOT_FOUND
        except Exception, e:
            rhnSQL.rollback()
            # otherwise we do a full stop
            Traceback(method, self.req, severity="unhandled")
            return apache.HTTP_INTERNAL_SERVER_ERROR
        # make the actual function call and return the result
        return self.call_function(method, params)

    def _get_method_params(self):
        # Returns the method name and params for this call

        # Split the request into parts
        array = string.split(self.req.path_info, '/')
        if len(array) < 4:
            log_error("Invalid URI for GET request", self.req.path_info)
            raise rhnFault(21, _("Invalid URI %s" % self.req.path_info))

        self.channel, method = (array[2], array[3])
        params = tuple(array[4:])
        return method, params

    # send the response out for the GET requests
    def response(self, response):
        log_debug(3)
        #pkilambi:if redirectException caught returns path(<str>)
        if isinstance(response, str):
            method, params = self._get_method_params()
            if method == "getPackage":
                return self.redirect(self.req, response)

        # GET requests resulting in a Fault receive special treatment
        # since we have to stick the error message in the HTTP header,
        # and to return an Apache error code
                
        if isinstance(response, rpclib.Fault):
            log_debug(4, "Return FAULT",
                      response.faultCode, response.faultString)
            retcode = apache.HTTP_NOT_FOUND
            if abs(response.faultCode) in (33, 34, 35, 37, 39, 41):
                retcode = apache.HTTP_UNAUTHORIZED

            self.req.err_headers_out["X-RHN-Fault-Code"] = \
                str(response.faultCode)
            faultString = string.strip(base64.encodestring(
                    response.faultString))
            # Split the faultString into multiple lines
            for line in string.split(faultString, '\n'):
                self.req.err_headers_out.add("X-RHN-Fault-String",
                    string.strip(line))
            # And then send all the other things
            for k, v in rhnFlags.get('outputTransportOptions').items():
                setHeaderValue(self.req.err_headers_out, k, v)
            return retcode
        # Otherwise we're pretty much fine with the standard response
        # handler

        # Copy the fields from the transport options, if necessary
        for k, v in rhnFlags.get('outputTransportOptions').items():
            setHeaderValue(self.req.headers_out, k, v)
        # and jump into the base handler
        return apacheRequest.response(self, response)

    #pkilambi: redirect request back to client with edge network url
    def redirect( self, req, url, temporary=1 ):
        log_debug(3,"url input to redirect is ",url)
        if req.sent_bodyct:
            raise IOError, "Cannot redirect after headers have already been sent."
        
        #akamize the url with the new tokengen before sending the redirect response
        import tokengen.Generator
        arl = tokengen.Generator.generate_auth_url(url)
        req.headers_out["Location"] = arl
        log_debug(3,"Akamized url to redirect is ",arl)
        if temporary:
            req.status = apache.HTTP_MOVED_TEMPORARILY
        else:
            req.status = apache.HTTP_MOVED_PERMANENTLY
        return req.status
