#!/usr/bin/python
#
# $Id: rpcServer.py,v 1.5 2004/02/27 22:11:06 alikins Exp $

import os
import sys
import config
import clientCaps
import rhnLog
import rhnErrors 
import rhnAuth 
import rhnUtils

#import wrapperUtils

import socket
import string
import time
import httplib
import urllib2
import xmlrpclib

# so we can use the same code with python 1.5.2 and 2.2
try:
    from rhn import rpclib
except ImportError:
    rpclib = __import__("xmlrpclib")
    
from translate import _
            

def stdoutMsgCallback(msg):
    print msg


def hasSSL():
    return hasattr(socket, "ssl")

def getServer(refreshCallback=None):
    log = rhnLog.initLog()
    cfg = config.initUp2dateConfig()
# Where do we keep the CA certificate for RHNS?
# The servers we're talking to need to have their certs
# signed by one of these CA.
    ca = cfg["sslCACert"]
    if type(ca) == type(""):
    	ca = [ca]

    rhns_ca_certs = ca or ["%s/usr/share/rhn/RHNS-CA-CERT" % config.PREFIX]
    if cfg["enableProxy"]:
        proxyHost = rhnUtils.getProxySetting()
    else:
        proxyHost = None

    if hasSSL():
        serverUrl = cfg["serverURL"]
    else:
        serverUrl = cfg["noSSLServerURL"]

    proxyUser = None
    proxyPassword = None
    if cfg["enableProxyAuth"]:
        proxyUser = cfg["proxyUser"] or None
        proxyPassword = cfg["proxyPassword"] or None

    lang = None
    for env in 'LANGUAGE', 'LC_ALL', 'LC_MESSAGES', 'LANG':
        if os.environ.has_key(env):
            if not os.environ[env]:
                # sometimes unset
                continue
            lang = string.split(os.environ[env], ':')[0]
            lang = string.split(lang, '.')[0]
            break

        
    s = rpclib.Server(serverUrl, refreshCallback=refreshCallback,
                      proxy=proxyHost,
                      username=proxyUser,
                      password=proxyPassword)
    s.add_header("X-Up2date-Version", rhnUtils.version())
    
    if lang:
        s.setlang(lang)

    # require RHNS-CA-CERT file to be able to authenticate the SSL connections
    for rhns_ca_cert in rhns_ca_certs:
        if not os.access(rhns_ca_cert, os.R_OK):
            log.log_me("ERROR: can not find RHNS CA file: %s" % rhns_ca_cert)
            sys.exit(-1)

        # force the validation of the SSL cert
        s.add_trusted_cert(rhns_ca_cert)

    clientCaps.loadLocalCaps()

    # send up the capabality info
    headerlist = clientCaps.caps.headerFormat()
    for (headerName, value) in headerlist:
        s.add_header(headerName, value)
    return s


# FIXME: doCall should probabaly be a method
# of a higher level server object
def doCall(method, *args, **kwargs):
    log = rhnLog.initLog()
    cfg = config.initUp2dateConfig()
    ret = None

    attempt_count = 1
    attempts = cfg["networkRetries"] or 5

    while 1:
        failure = 0
        ret = None        
        try:
            ret = apply(method, args, kwargs)
        except KeyboardInterrupt:
            raise rhnErrors.CommunicationError(_(
                "Connection aborted by the user"))
        # if we get a socket error, keep tryingx2
        except (socket.error, socket.sslerror), e:
            log.log_me("A socket error occurred: %s, attempt #%s" % (
                e, attempt_count))
            if attempt_count >= attempts:
                if len(e.args) > 1:
                    raise rhnErrors.CommunicationError(e.args[1])
                else:
                    raise rhnErrors.CommunicationError(e.args[0])
            else:
                failure = 1
        except httplib.IncompleteRead:
            print "httplib.IncompleteRead" 
            raise rhnErrors.CommunicationError("httplib.IncompleteRead")

        except urllib2.HTTPError, e:
            msg = "\nAn HTTP error occurred:\n"
            msg = msg + "URL: %s\n" % e.filename
            msg = msg + "Status Code: %s\n" % e.code
            msg = msg + "Error Message: %s\n" % e.msg
            log.log_me(msg)
            raise rhnErrors.CommunicationError(msg)
        
        except xmlrpclib.ProtocolError, e:
            
            log.log_me("A protocol error occurred: %s , attempt #%s," % (
                e.errmsg, attempt_count))
            (errCode, errMsg) = rpclib.reportError(e.headers)
            reset = 0
            if abs(errCode) == 34:
                log.log_me("Auth token timeout occurred\n errmsg: %s" % errMsg)
                # this calls login, which in tern calls doCall (ie,
                # this function) but login should never get a 34, so
                # should be safe from recursion

                # PORTME : needs to do login without repoDirector preferbly
#                rd = repoDirector.initRepoDirector()
#                rd.updateAuthInfo()
#                reset = 1

            # the servers are being throttle to pay users only, catch the
            # exceptions and display a nice error message
            if abs(errCode) == 51:
                log.log_me(_("Server was refused connection due to high load"))
                raise rhnErrors.CommunicationError(e.errmsg)
            # if we get a 404 from our server, thats pretty
            # fatal... no point in retrying over and over. Note that
            # errCode == 17 is specific to our servers, if the
            # serverURL is just pointing somewhere random they will
            # get a 0 for errcode and will raise a CommunicationError
            if abs(errCode) == 17:
		#in this case, the args are the package string, so lets try to
		# build a useful error message
                if type(args[0]) == type([]):
                    pkg = args[0]
                else:
                    pkg=args[1]
                    
                if type(pkg) == type([]):
                    pkgName = "%s-%s-%s.%s" % (pkg[0], pkg[1], pkg[2], pkg[4])
                else:
                    pkgName = pkg
		msg = "File Not Found: %s\n%s" % (pkgName, errMsg)
		log.log_me(msg)
                raise rhnErrors.FileNotFoundError(msg)
                
            if not reset:
                if attempt_count >= attempts:
                    raise rhnErrors.CommunicationError(e.errmsg)
                else:
                    failure = 1
            
        except xmlrpclib.ResponseError:
            raise rhnErrors.CommunicationError(
                "Broken response from the server.")

        if failure:
            # rest for five seconds before trying again
            time.sleep(5)
            attempt_count = attempt_count + 1
        if ret != None:
            break
        
    return ret
    
