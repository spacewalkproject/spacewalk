#
# Copyright (c) 2008--2012 Red Hat, Inc.
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
# Server-side uploading code

import time
import sys
import xmlrpclib
from spacewalk.common import apache

from spacewalk.common import rhnFlags
from spacewalk.common.rhnLog import log_debug, log_error, log_setreq, initLOG
from spacewalk.common.rhnConfig import CFG, initCFG
from spacewalk.common.rhnTranslate import _
from spacewalk.common.rhnTB import Traceback
from spacewalk.common.rhnException import rhnException, rhnFault
from spacewalk.server import rhnSQL, rhnImport
from spacewalk.satellite_tools.disk_dumper.dumper import ClosedConnectionError
from spacewalk.satellite_tools import constants

from rhn.connections import idn_puny_to_unicode


class BaseApacheServer:

    def __init__(self):
        # Init log to stderr
        initLOG()
        self.start_time = 0
        self._cleanup()

    def headerParserHandler(self, req):
        # pylint: disable=W0201
        log_setreq(req)
        self.start_time = time.time()
        # init configuration options with proper component
        options = req.get_options()
        # if we are initializing out of a <Location> handler don't
        # freak out
        if not options.has_key("RHNComponentType"):
            # clearly nothing to do
            return apache.OK
        initCFG(options["RHNComponentType"])
        initLOG(CFG.LOG_FILE, CFG.DEBUG)
        # short-circuit everything if sending a system-wide message.
        if CFG.SEND_MESSAGE_TO_ALL:
            # Drop the database connection
            # pylint: disable=W0702
            try:
                rhnSQL.closeDB()
            except:
                pass

            # Fetch global message being sent to clients if applicable.
            msg = open(CFG.MESSAGE_TO_ALL).read()
            log_debug(3, "Sending message to all clients: %s" % msg)
            return self._send_xmlrpc(req, rhnFault(-1,
                                                   _("IMPORTANT MESSAGE FOLLOWS:\n%s") % msg, explain=0))

        rhnSQL.initDB()
        self.server = options['SERVER']

        self.server_classes = rhnImport.load("satellite_exporter/handlers")

        if not self.server_classes.has_key(self.server):
            # XXX do something interesting here
            log_error("Missing server", self.server)
            return apache.HTTP_NOT_FOUND

        return self._wrapper(req, self._headerParserHandler)

    def handler(self, req):
        return self._wrapper(req, self._handler)

    def cleanupHandler(self, req):
        self._timer()
        retval = self._wrapper(req, self._cleanupHandler)
        self._cleanup()
        # Reset the logger to stderr
        initLOG()
        return retval

    def _cleanup(self):
        # pylint: disable=W0201
        self.server = None
        self.server_classes = None
        self.server_instance = {}

    # Virtual functions
    # pylint: disable=R0201
    def _headerParserHandler(self, _req):
        return apache.OK

    def _handler(self, _req):
        return apache.OK

    def _cleanupHandler(self, _req):
        return apache.OK

    def _wrapper(self, req, function):
        try:
            ret = function(req)
        except rhnFault, e:
            return self._send_xmlrpc(req, e)
        except ClosedConnectionError:
            # The error code most likely doesn't matter, the client won't see
            # it anyway
            return apache.HTTP_NOT_ACCEPTABLE
        except Exception:  # pylint: disable=E0012, W0703
            Traceback("satexport._wrapper", req=req)
            return apache.HTTP_INTERNAL_SERVER_ERROR
        return ret

    def _send_xmlrpc(self, req, data):
        log_debug(1)
        req.content_type = "text/xml"
        if isinstance(data, rhnFault):
            data = data.getxml()
        else:
            data = (data, )
        ret = xmlrpclib.dumps(data, methodresponse=1)
        req.headers_out['Content-Length'] = str(len(ret))
        req.send_http_header()
        req.write(ret)
        return apache.OK

    def _timer(self):
        if not self.start_time:
            return 0
        log_debug(2, "%.2f sec" % (time.time() - self.start_time))
        return 0


class ApacheServer(BaseApacheServer):

    def __init__(self):
        BaseApacheServer.__init__(self)

    def _headerParserHandler(self, req):
        log_debug(3, "Method", req.method)
        self._validate_version(req)
        return apache.OK

    def _handler(self, req):
        log_debug(3, "Method", req.method)

        # Read all the request
        data = req.read()
        log_debug(7, "Received", data)

        # Decode the data
        try:
            params, methodname = xmlrpclib.loads(data)
        except:
            raise

        log_debug(5, params, methodname)

        try:
            f = self.get_function(methodname, req)
        except FunctionRetrievalError, e:
            Traceback(methodname, req)
            return self._send_xmlrpc(req, rhnFault(3008, str(e), explain=0))

        if len(params) < 2:
            params = []
        else:
            params = params[1:]

        result = f(*params)

        if result:
            # Error of some sort
            return self._send_xmlrpc(req, rhnFault(3009))

        # Presumably the function did all the sending
        log_debug(4, "Exiting OK")
        return apache.OK

    # pylint: disable=R0201
    def get_function(self, method_name, req):
        iss_slave_condition = self.auth_system(req)
        # Get the module name
        idx = method_name.rfind('.')
        module_name, function_name = method_name[:idx], method_name[idx + 1:]
        log_debug(5, module_name, function_name)

        handler_classes = self.server_classes[self.server]
        if not handler_classes.has_key(module_name):
            raise FunctionRetrievalError("Module %s not found" % module_name)

        mod = handler_classes[module_name](req)
        mod.set_exportable_orgs(iss_slave_condition)
        f = mod.get_function(function_name)
        if f is None:
            raise FunctionRetrievalError(
                "Module %s: function %s not found" %
                (module_name, function_name))
        return f

    def auth_system(self, req):
        if CFG.DISABLE_ISS:
            raise rhnFault(2005, _('ISS is disabled on this satellite.'))

        remote_hostname = req.get_remote_host(apache.REMOTE_DOUBLE_REV)
        row = rhnSQL.fetchone_dict("""
        select id, allow_all_orgs
          from rhnISSSlave
         where slave = :hostname
           and enabled = 'Y'
        """, hostname = idn_puny_to_unicode(remote_hostname))
        if not row:
            raise rhnFault(2004,
                           _('Server "%s" is not enabled for ISS.')
                           % remote_hostname)
        iss_slave_condition = "select id from web_customer"
        if not(row['allow_all_orgs'] == 'Y'):
            iss_slave_condition = "select rhnISSSlaveOrgs.org_id from rhnISSSlaveOrgs where slave_id = %d" % row['id']
        return iss_slave_condition

    @staticmethod
    def _validate_version(req):
        server_version = constants.PROTOCOL_VERSION
        vstr = 'X-RHN-Satellite-XML-Dump-Version'
        if not req.headers_in.has_key(vstr):
            raise rhnFault(3010, "Missing version string")
        client_version = req.headers_in[vstr]

        # set the client version  through rhnFlags to access later
        rhnFlags.set('X-RHN-Satellite-XML-Dump-Version', client_version)

        log_debug(1, "Server version", server_version, "Client version",
                  client_version)

        client_ver_arr = str(client_version).split(".")
        server_ver_arr = str(server_version).split(".")
        client_major = client_ver_arr[0]
        server_major = server_ver_arr[0]
        if len(client_ver_arr) >= 2:
            client_minor = client_ver_arr[1]
        else:
            client_minor = 0

        server_minor = server_ver_arr[1]

        try:
            client_major = int(client_major)
            client_minor = int(client_minor)
        except ValueError:
            raise rhnFault(3011, "Invalid version string %s" % client_version), None, sys.exc_info()[2]

        try:
            server_major = int(server_major)
            server_minor = int(server_minor)
        except ValueError:
            raise rhnException("Invalid server version string %s"
                               % server_version), None, sys.exc_info()[2]

        if client_major != server_major:
            raise rhnFault(3012, "Client version %s does not match"
                           " server version %s" % (client_version, server_version),
                           explain=0)


class FunctionRetrievalError(Exception):
    pass


apache_server = ApacheServer()
HeaderParserHandler = apache_server.headerParserHandler
Handler = apache_server.handler
CleanupHandler = apache_server.cleanupHandler
