#
# Copyright (c) 2008--2016 Red Hat, Inc.
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
#

import string
import sys
from spacewalk.common import apache

import rhnSession

from spacewalk.common import rhnFlags
from spacewalk.common.rhnLog import log_debug, log_error, log_setreq, initLOG
from spacewalk.common.rhnConfig import CFG, initCFG
from spacewalk.common.rhnException import rhnFault
from spacewalk.common.rhnTB import Traceback
from spacewalk.server import rhnImport


class UploadHandler:

    def __init__(self):
        self.servers = {}
        self.server = None

    def headerParserHandler(self, req):
        log_setreq(req)
        # init configuration options with proper component
        options = req.get_options()
        # if we are initializing out of a <Location> handler don't
        # freak out
        if "RHNComponentType" not in options:
            # clearly nothing to do
            return apache.OK
        initCFG(options["RHNComponentType"])
        initLOG(CFG.LOG_FILE, CFG.DEBUG)
        if req.method == 'GET':
            # This is the ping method
            return apache.OK
        self.servers = rhnImport.load("upload_server/handlers",
                                      interface_signature='upload_class')
        if 'SERVER' not in options:
            log_error("SERVER not set in the apache config files!")
            return apache.HTTP_INTERNAL_SERVER_ERROR
        server_name = options['SERVER']
        if server_name not in self.servers:
            log_error("Unable to load server %s from available servers %s" %
                      (server_name, self.servers))
            return apache.HTTP_INTERNAL_SERVER_ERROR
        server_class = self.servers[server_name]
        self.server = server_class(req)
        return self._wrapper(req, "headerParserHandler")

    def handler(self, req):
        if req.method == 'GET':
            # This is the ping method
            log_debug(1, "GET method received, returning")
            req.headers_out['Content-Length'] = '0'
            # pkilambi:check for new version of rhnpush to differentiate
            # new sats from old satellites.
            req.headers_out['X-RHN-Check-Package-Exists'] = '1'
            req.send_http_header()
            return apache.OK
        return self._wrapper(req, "handler")

    def cleanupHandler(self, req):
        if req.method == 'GET':
            # This is the ping method
            return apache.OK
        retval = self._wrapper(req, "cleanupHandler")
        # Reset the logger to stderr
        initLOG()
        self.server = None
        return retval

    def logHandler(self, req):
        if req.method == 'GET':
            # This is the ping method
            return apache.OK
        retval = self._wrapper(req, "logHandler")
        return retval

    def _wrapper(self, req, function_name):
        #log_debug(1, "_wrapper", req, function_name)
        if not hasattr(self.server, function_name):
            log_error("%s doesn't have a %s function" %
                      (self.server, function_name))
            return apache.HTTP_NOT_FOUND
        function = getattr(self.server, function_name)
        try:
            log_debug(5, "Calling", function)
            ret = function(req)
        except rhnFault:
            e = sys.exc_info()[1]
            log_debug(4, "rhnFault caught: %s" % (e, ))
            error_string = self._exception_to_text(e)
            error_code = e.code
            self._error_to_headers(req.err_headers_out, error_code, error_string)
            ret = rhnFlags.get("apache-return-code")
            if not ret:
                ret = apache.HTTP_INTERNAL_SERVER_ERROR
            req.status = ret
            log_debug(4, "_wrapper %s exited with apache code %s" %
                      (function_name, ret))
        except rhnSession.ExpiredSessionError:
            e = sys.exc_info()[1]
            # if session expires we catch here and return a forbidden
            # abd make it re-authenticate
            log_debug(4, "Expire Session Error Caught: %s" % (e, ))
            return 403
        except:
            Traceback("server.apacheUploadServer._wrapper", req=req)
            log_error("Unhandled exception")
            return apache.HTTP_INTERNAL_SERVER_ERROR
        return ret

    # Adds an error code and error string to the headers passed in
    def _error_to_headers(self, headers, error_code, error_string):
        error_string = string.strip(error_string)
        import base64
        error_string = string.strip(base64.encodestring(error_string))
        for line in map(string.strip, string.split(error_string, '\n')):
            headers.add(self.server.error_header_prefix + '-String', line)
        headers[self.server.error_header_prefix + '-Code'] = str(error_code)

    def _exception_to_text(self, exception):
        return """\
Error Message:
    %s
Error Class Code: %s
Error Class Info: %s
""" % (string.strip(exception.text), exception.code,
            string.rstrip(exception.arrayText))

# Instantiate external entry points:
apache_server = UploadHandler()

HeaderParserHandler = apache_server.headerParserHandler
Handler = apache_server.handler
CleanupHandler = apache_server.cleanupHandler
LogHandler = apache_server.logHandler
