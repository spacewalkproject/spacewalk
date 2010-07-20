#!/usr/bin/python
#
# Python client for checking periodically for posted actions
# on the Red Hat Network servers.
#
# Copyright (c) 2000--2010 Red Hat, Inc.
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
import sys
import socket

from OpenSSL import SSL
sys.path.append("/usr/share/rhn/")

from up2date_client import getMethod
from up2date_client import up2dateErrors
from up2date_client import up2dateAuth
from up2date_client import up2dateLog
from up2date_client import rpcServer
from up2date_client import config
from up2date_client import clientCaps
from up2date_client import capabilities
from up2date_client import rhncli, rhnserver

from rhn import rhnLockfile
from rhn import rpclib

cfg = config.initUp2dateConfig()
log = up2dateLog.initLog()

# action version we understand
ACTION_VERSION = 2 

# lock file to check if we're disabled at the server's request
DISABLE_FILE = "/etc/sysconfig/rhn/disable"

# Actions that will run each time we execute.
LOCAL_ACTIONS = [("packages.checkNeedUpdate", ("rhnsd=1",))]


class CheckCli(rhncli.RhnCli):

    def __init__(self):
        super(CheckCli, self).__init__()

        self.rhns_ca_cert = cfg['sslCACert'] 
        self.server = None

    def main(self):
        """ Process all the actions we have in the queue. """
        CheckCli.__check_instance_lock()
        CheckCli.__check_rhn_disabled()
        CheckCli.__check_has_system_id()

        self.server = CheckCli.__get_server()

        CheckCli.__update_system_id()

        self.__run_remote_actions()
        CheckCli.__run_local_actions()

        s = rhnserver.RhnServer()
        if s.capabilities.hasCapability('staging_content', 1) and cfg['stagingContent'] != 0:
             self.__check_future_actions()

        sys.exit(0)

    def __get_action(self, status_report):
        try:
            action = self.server.queue.get(up2dateAuth.getSystemId(),
                ACTION_VERSION, status_report)

            return action
        except rpclib.Fault, f:
            if f.faultCode == -31:
                raise up2dateErrors.InsuffMgmntEntsError(f.faultString)
            else:
                print "Could not retrieve action item from server %s" % self.server
                print "Error code: %d%s" % (f.faultCode, f.faultString)
            sys.exit(-1)
        # XXX: what if no SSL in socket?
        except socket.sslerror:
            print "ERROR: SSL handshake to %s failed" % self.server
            print """
            This could signal that you are *NOT* talking to a server
            whose certificate was signed by a Certificate Authority
            listed in the %s file or that the
            RHNS-CA-CERT file is invalid.""" % self.rhns_ca_cert
            sys.exit(-1)
        except socket.error:
            print "Could not retrieve action from %s.\n"\
                  "Possible networking problem?" % str(self.server)
            sys.exit(-1)
        except up2dateErrors.ServerCapabilityError, e:
            print e
            sys.exit(1)
        except SSL.Error, e:
            print "ERROR: SSL errors detected"
            print "%s" % e
            sys.exit(-1)

    def __query_future_actions(self, time_window):
        try:
            actions = self.server.queue.get_future_actions(up2dateAuth.getSystemId(),
                time_window)
            return actions
        except rpclib.Fault, f:
            if f.faultCode == -31:
                raise up2dateErrors.InsuffMgmntEntsError(f.faultString)
            else:
                print "Could not retrieve action item from server %s" % self.server
                print "Error code: %d%s" % (f.faultCode, f.faultString)
            sys.exit(-1)
        # XXX: what if no SSL in socket?
        except socket.sslerror:
            print "ERROR: SSL handshake to %s failed" % self.server
            print """
            This could signal that you are *NOT* talking to a server
            whose certificate was signed by a Certificate Authority
            listed in the %s file or that the
            RHNS-CA-CERT file is invalid.""" % self.rhns_ca_cert
            sys.exit(-1)
        except socket.error:
            print "Could not retrieve action from %s.\n"\
                  "Possible networking problem?" % str(self.server)
            sys.exit(-1)
        except up2dateErrors.ServerCapabilityError, e:
            print e
            sys.exit(1)
        except SSL.Error, e:
            print "ERROR: SSL errors detected"
            print "%s" % e
            sys.exit(-1)

    def __fetch_future_action(self, action):
        """ Fetch one specific action from rhnParent """
        # TODO
        pass

    def __check_future_actions(self):
        """ Retrieve scheduled actions and cache them if possible """
        time_window = cfg['stagingContentWindow'] or 24;
        actions = self.__query_future_actions(time_window)
        for action in actions:
            self.__fetch_future_action(action)

    def __run_remote_actions(self):
        # the list of caps the client needs
        caps = capabilities.Capabilities()
        
        status_report = CheckCli.__build_status_report()

        action = self.__get_action(status_report)
        while action != "" and action != {}:
            self.__verify_server_capabilities(caps)
               
            if self.is_valid_action(action):
                try:
                    up2dateAuth.updateLoginInfo()
                except up2dateErrors.ServerCapabilityError, e:
                    print e
                    sys.exit(1)
                self.handle_action(action)

            action = self.__get_action(status_report)

    def __verify_server_capabilities(self, caps):
        response_headers = self.server.get_response_headers()
        caps.populate(response_headers)
        # do we actually want to validte here?
        try:        
            caps.validate()
        except up2dateErrors.ServerCapabilityError, e:
            print e
            sys.exit(1)
 
    def __parse_action_data(self, action):
        """ Parse action data and returns (method, params) """
        data = action['action']
        parser, decoder = rpclib.getparser()
        parser.feed(data)
        parser.close()
        params = decoder.close()
        method = decoder.getmethodname()
        return (method, params)

    def submit_response(self, action_id, status, message, data):
        """ Submit a response for an action_id. """

        # get a new server object with fresh headers
        self.server = CheckCli.__get_server()
        
        try:
            ret = self.server.queue.submit(up2dateAuth.getSystemId(),
                                      action_id, status, message, data)
        except rpclib.Fault, f:
            print "Could not submit results to server %s" % self.server
            print "Error code: %d%s" % (f.faultCode, f.faultString)
            sys.exit(-1)
        # XXX: what if no SSL in socket?
        except socket.sslerror:
            print "ERROR: SSL handshake to %s failed" % self.server
            print """
            This could signal that you are *NOT* talking to a server
            whose certificate was signed by a Certificate Authority
            listed in the %s file or that the
            RHNS-CA-CERT file is invalid.""" % self.rhns_ca_cert
            sys.exit(-1)
        except socket.error:
            print "Could not submit to %s.\n"\
                  "Possible networking problem?" % str(self.server)
            sys.exit(-1)                
        return ret
 
    def handle_action(self, action):
        """ Wrapper handler for the action we're asked to do. """
        log.log_debug("handle_action", action)
        log.log_debug("handle_action actionid = %s, version = %s" % (
            action['id'], action['version']))
            
        (method, params) = self.__parse_action_data(action)
        (status, message, data) = CheckCli.__run_action(method, params)

        log.log_debug("Sending back response", (status, message, data))
        return self.submit_response(action['id'], status, message, data)


    def is_valid_action(self, action):
        log.log_debug("check_action", action)
            
        # be very paranoid of what we get back
        if type(action) != type({}):
            print "Got unparseable action response from server"
            sys.exit(-1)

        for key in ['id', 'version', 'action']:
            if not action.has_key(key):
                print "Got invalid response - missing '%s'" % key
                sys.exit(-1)
        try:
            ver = int(action['version'])
        except ValueError:
            ver = -1
        if ver > ACTION_VERSION or ver < 0:
            print "Got unknown action version %d" % ver
            print action
            # the -99 here is kind of magic
            self.submit_response(action["id"],
                            rpclib.Fault(-99, "Can not handle this version"))
            return False
        return True
 
    @staticmethod
    def __get_server():
        """ Initialize a server connection and set up capability info. """
        server = rpcServer.getServer()

        # load the new client caps if they exist
        clientCaps.loadLocalCaps()

        headerlist = clientCaps.caps.headerFormat()
        for (headerName, value) in headerlist:
            server.add_header(headerName, value)

        return server

    @staticmethod
    def __update_system_id():
        try:
            up2dateAuth.maybeUpdateVersion()
        except up2dateErrors.CommunicationError, e:
            print e
            sys.exit(1)

    @staticmethod
    def __build_status_report():
        status_report = {}
        status_report["uname"] = os.uname()

        if os.access("/proc/uptime", os.R_OK):
            uptime = open("/proc/uptime", "r").read().split()
            try:
                status_report["uptime"] = map(int, map(float, uptime))
            except (TypeError, ValueError):
                status_report["uptime"] = map(lambda a: a[:-3], uptime)
            except:
                pass

        return status_report

    @staticmethod
    def __run_local_actions():
        """
        Hit any actions that we want to always run.

        If we want to run any actions everytime rhnsd runs rhn_check,
        we can add them to the list LOCAL_ACTIONS
        """

        for method_params in LOCAL_ACTIONS:
            method = method_params[0]
            params =  method_params[1]
            (status, message, data) = CheckCli.__run_action(method, params)
            log.log_debug("local action status: ", (status, message, data))

    @staticmethod
    def __do_call(method, params):
        log.log_debug("do_call", method, params)

        method = getMethod.getMethod(method, "/usr/share/rhn/", "actions")
        retval = method(*params)
    
        return retval

    @staticmethod
    def __run_action(method, params):
        try:
            (status, message, data) = CheckCli.__do_call(method, params)   
        except getMethod.GetMethodException:
            log.log_debug("Attempt to call an unsupported action", method,
                params)
            status = 6
            message = "Invalid function call attempted"
            data = {}
        except:
            log.log_exception(*sys.exc_info())
            # The action code failed in some way. let's let the server know.
            status = 6,
            message = "Fatal error in Python code occured"
            data = {}
        return (status, message, data)

    @staticmethod
    def __check_rhn_disabled():
        """ If we're disabled, go down (almost) quietly. """
        if os.path.exists(DISABLE_FILE):
            print "RHN service is disabled. Check %s" % DISABLE_FILE
            sys.exit(0)

    @staticmethod
    def __check_has_system_id():
        """ Retrieve the system_id. This is required. """
        if not up2dateAuth.getSystemId():
            print "ERROR: unable to read system id."
            sys.exit(-1)

    @staticmethod
    def __check_instance_lock():
        lock = None
        try:
            lock = rhnLockfile.Lockfile('/var/run/rhn_check.pid')        
        except rhnLockfile.LockfileLockedException, e:
            sys.stderr.write("Attempting to run more than one instance of rhn_check. Exiting.\n")
            sys.exit(0)

if __name__ == "__main__":
    cli = CheckCli()
    cli.run()
