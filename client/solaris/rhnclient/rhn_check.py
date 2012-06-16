#!/usr/bin/python
#
# Python client for checking periodically for posted actions
# on the Red Hat Network servers.
#
# Copyright (c) 2000--2010 Red Hat, Inc. Distributed under GPL.
# Authors: Cristian Gafton <gafton@redhat.com>,
#          Preston Brown <pbrown@redhat.com>
#          Adrian Likins <alikins@redhat.com>
#
# In addition, as a special exception, the copyright holders give
# permission to link the code of portions of this program with the
# OpenSSL library under certain conditions as described in each
# individual source file, and distribute linked combinations
# including the two.
# You must obey the GNU General Public License in all respects
# for all of the code used other than OpenSSL.  If you modify
# file(s) with this exception, you may extend this exception to your
# version of the file(s), but you are not obligated to do so.  If you
# do not wish to do so, delete this exception statement from your
# version.  If you delete this exception statement from all source
# files in the program, then also delete it here.
#
# $Id: rhn_check.py,v 1.11 2004/12/07 17:09:10 misa Exp $

import os
import sys
import socket
import string
import getopt
import fnmatch
import traceback
import time

from OpenSSL import SSL
PREFIX="/"
MODULEPATH="%s/usr/share/rhn" % PREFIX
sys.path.append(MODULEPATH)

import rhn.actions
from rhn.client.translate import _
from rhn.client import rhnErrors
from rhn.client import rhnAuth
from rhn.client import rhnLog
from rhn.client import rpcServer
from rhn.client import config
from rhn.client import clientCaps
from rhn.client import capabilities

import xmlrpclib

cfg = config.initUp2dateConfig()
log = rhnLog.initLog()

# action version we understand
ACTION_VERSION = 2 

# lock file to check if we're disabled at the server's request
DISABLE_FILE = os.path.join(config.RHN_SYSCONFIG_DIR, "disable")

# path location of the CA cert file
rhns_ca_cert = cfg['sslCACert'] 

# Exceptions
class UnknownXML:
    def __init__(self, value):
        self.__value = value
        
    def __repr__(self):
        return "Invalid request received (%s)." % self.__value


def showHelp():                        
    print _("Usage: rhn_check [options]")
    print ""
    print _("Available command line options:")
    print _("-h, --help         - this help ")
    print _("-v, --verbose      - increasing verbosity ")
    print ""


LOCAL_ACTIONS = [("solarispkgs.checkNeedUpdate", ("rhnsd=1",))]
def run_local_actions():
    # If we want to run any actions everytime rhnsd runs rhn_check,
    # we can add them to the list LOCAL_ACTIONS

    for method_params in LOCAL_ACTIONS:
        method = method_params[0]
        params =  method_params[1]
        (status, message, data) = run_action(method, params)
        log.log_debug("local action status: ", (status, message, data))
    
# submit a response for an action_id
def submit_response(action_id, status, message, data):
    global server
    # try to submit
    try:
        ret = rpcServer.doCall(server.queue.submit,rhnAuth.getSystemId(),
                                  action_id, status, message, data)
    except xmlrpclib.Fault, f:
        print "Could not submit results to server %s" % server
        print "Error code: %d%s" % (f.faultCode, f.faultString)
        sys.exit(-1)
    # XXX: what if no SSL in socket?
    except socket.sslerror:
        print "ERROR: SSL handshake to %s failed" % server
        print """
        This could signal that you are *NOT* talking to a server
        whose certificate was signed by a Certificate Authority
        listed in the %s file or that the
        RHNS-CA-CERT file is invalid.""" % rhns_ca_cert
        sys.exit(-1)
    except socket.error:
        print "Could not submit to %s.\n"\
              "Possible networking problem?" % str(server)
        sys.exit(-1)                
    return ret

###
# Functions
###
def check_action(action):
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
    except:
        ver = -1
    if ver > ACTION_VERSION or ver < 0:
        print "Got unknown action version %d" % ver
        print action
        # the -99 here is kind of magic
        submit_response(action["id"],
                        xmlrpclib.Fault(-99, "Can not handle this version"))
        return -1
    return 0

def run_action(method, params):
    try:
        log.log_debug("do_call", method, params)
        (status, message, data) = rhn.actions.do_call(method, params)   
    except (TypeError, ValueError, KeyError, IndexError):
        if cfg["debug"]:
            traceback.print_exc()            
        # wrong number of arguments, wrong type of arguments, etc
        status = 6,
        message = "Fatal error in Python code occured"
        data = {}
    except UnknownXML:
        log.log_debug("Got unknown XML-RPC call", method, params)
        # invalid function called
        status = 6
        message = "Invalid function call attempted"
        data = {}
    except AttributeError:
        log.log_debug("Attempt to call an unsupported action", method, params)
        status = 6
        message = "Invalid function call attempted"
        data = {}


    return (status, message, data)

# Wrapper handler for the action we're asked to do
def handle_action(action):
    global server
    
    log.log_debug("handle_action", action)
        
    version = action['version']
    action_id = action['id']
    data = action['action']

    log.log_debug("handle_action actionid = %s, version = %s" % (
        action_id, version))
        
    # Decipher the data
    parser, decoder = xmlrpclib.getparser()
    parser.feed(data)
    parser.close()
    params = decoder.close()
    method = decoder.getmethodname()
    data = {}

    (status, message, data) = run_action(method, params)

    log.log_debug("Sending back response", (status, message, data))
    return submit_response(action_id, status, message, data)
    
###
# Init
###
# quick check for other instances of up2date/rhn_check
##lock = None
##try:
##    lock = rhnLockfile.Lockfile('/var/run/up2date.pid')
##except rhnLockfile.LockfileLockedException, e:
##    sys.stderr.write("Attempting to run more than one instance of up2date/rhn_check. Exiting.\n")
##    sys.exit(0)

try:
    opts, args = getopt.getopt(sys.argv[1:], "hv", ["help", "verbose"])
except getopt.error, e:
    print _("Error parsing command list arguments: %s") % e
    showHelp()
    sys.exit(1)

for (opt, val) in opts:
    if opt in ["--verbose", "-v"]:
        cfg["debug"] = cfg["debug"] + 1
    elif opt in ["--help", "-h"]:
        showHelp()
        sys.exit(0)
        
# if we're disabled, go down (almost) quietly
if os.path.exists(DISABLE_FILE):
    print "RHN service is disabled. Check %s" % DISABLE_FILE
    sys.exit(0)
    
# retrieve the system_id. This is required.
if not rhnAuth.getSystemId():
    print "ERROR: unable to read system id."
    sys.exit(-1)

# Initialize the server connection...
server = rpcServer.getServer()

# send up the capabality info
headerlist = clientCaps.caps.headerFormat()
for (headerName, value) in headerlist:
    server.add_header(headerName, value)

# the list of caps the client needs
caps = capabilities.Capabilities()



# PORT ME, actually, once the getVersionRelease
# stuff is ported, this should just work
#try:
#    rhnAuth.maybeUpdateVersion()
#except rhnErrors.CommunicationError, e:
#    print e
#    sys.exit(1)


###
# Main PROGRAM
###

# Build a status report
Status = {}
Status["uname"] = os.uname()

# PORTME
if os.access("/proc/uptime", os.R_OK):
    uptime = string.split(open("/proc/uptime", "r").read())
    try:
        Status["uptime"] = map(int, map(float, uptime))
    except TypeError, ValueError:
        Status["uptime"] = map(lambda a: a[:-3], uptime)
    except:
        pass

# Process all the actions we have in the queue

has_logged_in = None
while 1:
    try:
        action = rpcServer.doCall(server.queue.get,rhnAuth.getSystemId(),
                                  ACTION_VERSION, Status)
    except xmlrpclib.Fault, f:
        print "Could not retrieve action item from server %s" % server
        print "Error code: %d%s" % (f.faultCode, f.faultString)
        sys.exit(-1)
    # XXX: what if no SSL in socket?
    except socket.sslerror:
        print "ERROR: SSL handshake to %s failed" % server
        print """
        This could signal that you are *NOT* talking to a server
        whose certificate was signed by a Certificate Authority
        listed in the %s file or that the
        RHNS-CA-CERT file is invalid.""" % rhns_ca_cert
        sys.exit(-1)
    except socket.error:
	print "Could not retrieve action from %s.\n"\
              "Possible networking problem?" % str(server)
	sys.exit(-1)
    except rhnErrors.ServerCapabilityError, e:
        print e
        sys.exit(1)
    except SSL.Error, e:
       print "ERROR: SSL errors detected"
       print "%s" % e
       sys.exit(-1)

    # verify serv caps
    response_headers = server.get_response_headers()
    caps.populate(response_headers)
    # do we actually want to validte here?
    try:        
        caps.validate()
    except rhnErrors.ServerCapabilityError, e:
        print e
        sys.exit(1)
        
    
    if action == "" or action == {}:
        break

    if check_action(action) == 0:
        if not has_logged_in:
            try:
                rhnAuth.updateLoginInfo()
            except rhnErrors.ServerCapabilityError, e:
                print e
                sys.exit(1)
        handle_action(action)

# hit any actions that we want to always run
run_local_actions()

#if lock:
#    lock.release()

sys.exit(0)
