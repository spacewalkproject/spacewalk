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

import os
import time
import string

# global module imports
from common import apache

# common module imports
from common import rhnApache, rhnTB
from common import rhnFault, rhnException, rhnFlags
from common import log_debug, log_error
from common import CFG

# local module imports
import rhnSQL

from apacheRequest import apacheGET, apachePOST, HandlerNotFoundError
import rhnCapability

# a lame timer function for pretty logs
def timer(last):
    if not last:
        return 0
    log_debug(2, "%.2f sec" % (time.time() - last,))
    return 0


class apacheSession(rhnApache):
    """ a class that extends rhnApache with several support functions used
     by the main handler class. This class deals with the processing of
     the request and setup for the real action handled in the
     apacheHandler class below. """
    _lang_catalog = "server"

class apacheHandler(apacheSession):
    """ main Apache XMLRPC point of entry for the server """
    def __init__(self):
        # First call the inherited constructor:
        apacheSession.__init__(self)
        self._req_processor = None

    ###
    # HANDLERS, in the order which they are called:
    # headerParserHandler, handler, and cleanupHandler.
    ###

    def headerParserHandler(self, req):
        """ parse the request, init database and figure out what can we call """
        log_debug(2, req.the_request)
        # call method from inherited class
        ret = apacheSession.headerParserHandler(self, req)
        if ret != apache.OK:
            return ret
        # make sure we have DB connection
        if not CFG.SEND_MESSAGE_TO_ALL:
            try:
                rhnSQL.initDB()
            except rhnSQL.SQLConnectError:
                rhnTB.Traceback(mail=1, req=req, severity="schema")
                return apache.HTTP_INTERNAL_SERVER_ERROR
        else:
            # If in outage mode, close the DB connections
            rhnSQL.closeDB()
        
        # Store client capabilities
        client_cap_header = 'X-RHN-Client-Capability'
        if req.headers_in.has_key(client_cap_header):
            client_caps =  req.headers_in[client_cap_header]
            client_caps = filter(None, 
                map(string.strip, string.split(client_caps, ","))
            )
	    rhnCapability.set_client_capabilities(client_caps)
            
        #Enabling the input header flags associated with the redirects/newer clients
	redirect_support_flags = ['X-RHN-Redirect', 'X-RHN-Transport-Capability']
	for flag in redirect_support_flags:
            if req.headers_in.has_key( flag ):
                rhnFlags.set(flag, str(req.headers_in[flag]) )    

        return apache.OK

    def _init_request_processor(self, req):
        log_debug(3)
        # Override the parent class's behaviour
        # figure out what kind of request handler we need to instantiate
        if req.method == "POST":
            self._req_processor = apachePOST(self.clientVersion, req)
            return apache.OK
        if req.method == "GET":
            try:
                self._req_processor = apacheGET(self.clientVersion, req)
            except HandlerNotFoundError, e:
                log_error("Unable to handle GET request for server %s" %
                    (e.args[0], ))
                return apache.HTTP_METHOD_NOT_ALLOWED
            # We want to give the request processor the ability to override
            # the default behaviour of calling _setSessionToken
            # XXX This is a but kludgy - misa 20040827
            if hasattr(self._req_processor, 'init_request'):
                if not self._req_processor.init_request():
                    return apache.HTTP_METHOD_NOT_ALLOWED
                # Request initialized
                return apache.OK
            token = self._setSessionToken(req.headers_in)
            if token is None:
                return apache.HTTP_METHOD_NOT_ALLOWED
            return apache.OK

        log_error("Method not allowed", req.method)
        return apache.HTTP_METHOD_NOT_ALLOWED
    
    def _cleanup_request_processor(self):
        """ Clean up the request processor """
        if hasattr(self._req_processor, 'cleanup_request'):
            self._req_processor.cleanup_request()
        self._req_processor = None
        return apache.OK

    def handler(self, req):
        """ main Apache handler """
        log_debug(2)
        ret = apacheSession.handler(self, req)
        if ret != apache.OK:
            return ret

        if not CFG.SEND_MESSAGE_TO_ALL:
            # Need to get any string template overrides here, before any app
            # code gets executed, as the rhnFault error messages use the 
            # templates
            # If send_message_to_all, we don't have DB connectivity though
            h = rhnSQL.prepare("select label, value from rhnTemplateString")
            h.execute()
            
            templateStrings = {}
            while 1:
                row = h.fetchone_dict()
                if not row:
                    break

                templateStrings[row['label']] = row['value']
                
            if templateStrings:
                rhnFlags.set('templateOverrides', templateStrings)

            log_debug(4, "template strings:  %s" % templateStrings)

        if not CFG.SECRET_KEY:
            # Secret key not defined, complain loudly
            try:
                raise rhnException("Secret key not found!")
            except:
                rhnTB.Traceback(mail=1, req=req, severity="schema")
                req.status = 500
                req.send_http_header()
                return apache.OK

        
        # Try to authenticate the proxy if it this request passed
        # through a proxy.
        if self.proxyVersion:
            try:
                ret = self._req_processor.auth_proxy()
            except rhnFault, f:
                return self._req_processor.response(f.getxml())

        # Decide what to do with the request: try to authenticate the client.
        # NOTE: only upon GET requests is there Signature information to
        #       authenticate. XMLRPC requests DO NOT use signature
        #       authentication.
        if req.method == "GET":
            try:
                ret = self._req_processor.auth_client()
            except rhnFault, f:
                return self._req_processor.response(f.getxml())
            # be safe rather than sorry
            if not ret:
                log_error("Got a GET call, but auth_client declined",
                          req.path_info)
                return apache.HTTP_METHOD_NOT_ALLOWED
 
        # Avoid leaving Oracle deadlocks
        try:
            ret = self._req_processor.process()
        except:
            if not CFG.SEND_MESSAGE_TO_ALL:
                rhnSQL.rollback()
            raise        
        log_debug(4, "Leave with return value", ret)
        return ret


    def cleanupHandler(self, req):
        """ Clean up stuff before we close down the session when we are called
        from apacheServer.Cleanup() """
        log_debug(2)
        # kill all of our child processes (if any)
        while 1:
            pid = status = -1
            try:
                (pid, status) = os.waitpid(-1, 0)
            except OSError:
                break
            else:
                log_error("Reaped child process %d with status %d" % (
                          pid, status))
        ret = apacheSession.cleanupHandler(self, req)
        return ret

