#
# $Id$

import os
import sys
import config
import socket
import time
import httplib
import urllib2

import clientCaps
import up2dateLog
import up2dateErrors 
import up2dateUtils
import up2dateAuth

from rhn import rpclib

import gettext
_ = gettext.gettext


def stdoutMsgCallback(msg):
    print msg


class RetryServer(rpclib.Server):
    def foobar(self):
        pass

    def addServerList(self, serverList):
        self.serverList = serverList

    def _request1(self, methodname, params):
        self.log = up2dateLog.initLog()
        while 1:
            try:
                ret = self._request(methodname, params)
            except rpclib.InvalidRedirectionError:
                raise
            except rpclib.Fault:
                raise
            except httplib.BadStatusLine:
                self.log.log_me("Error: Server Unavailable. Please try later.") 
                stdoutMsgCallback(
                      _("Error: Server Unavailable. Please try later."))
                sys.exit(-1)
            except:
                server = self.serverList.next()
                if server == None:
                    # since just because we failed, the server list could
                    # change (aka, firstboot, they get an option to reset the
                    # the server configuration) so reset the serverList
                    self.serverList.resetServerIndex()
                    raise

                msg = "An error occured talking to %s:\n" % self._host
                msg = msg + "%s\n%s\n" % (sys.exc_type, sys.exc_value)
                msg = msg + "Trying the next serverURL: %s\n" % self.serverList.server()
                self.log.log_me(msg)
                # try a different url

                # use the next serverURL
                import urllib
                typ, uri = urllib.splittype(self.serverList.server())
                typ = typ.lower()
                if typ not in ("http", "https"):
                    raise InvalidRedirectionError(
                        "Redirected to unsupported protocol %s" % typ)

                self._host, self._handler = urllib.splithost(uri)
                self._orig_handler = self._handler
                self._type = typ
                if not self._handler:
                    self._handler = "/RPC2"
                self._allow_redirect = 1
                continue
            # if we get this far, we succedded
            break
        return ret

    
    def __getattr__(self, name):
        # magic method dispatcher
        return rpclib.xmlrpclib._Method(self._request1, name)
                

# uh, yeah, this could be an iterator, but we need it to work on 1.5 as well
class ServerList:
    def __init__(self, serverlist=[]):
        self.serverList = serverlist
        self.index = 0
        
    def server(self):
        self.serverurl = self.serverList[self.index]
        return self.serverurl


    def next(self):
        self.index = self.index + 1
        if self.index >= len(self.serverList):
            return None
        return self.server()

    def resetServerList(self, serverlist):
        self.serverList = serverlist
        self.index = 0

    def resetServerIndex(self):
        self.index = 0


def getServer(refreshCallback=None):
    log = up2dateLog.initLog()
    cfg = config.initUp2dateConfig()

    # Where do we keep the CA certificate for RHNS?
    # The servers we're talking to need to have their certs
    # signed by one of these CA.
    ca = cfg["sslCACert"]
    if type(ca) == type(""):
        ca = [ca]

    rhns_ca_certs = ca or ["/usr/share/rhn/RHNS-CA-CERT"]
    if cfg["enableProxy"]:
        proxyHost = config.getProxySetting()
    else:
        proxyHost = None

    serverUrls = cfg["serverURL"]

    # the standard is to be a string, so list-a-fy in that case
    if type(serverUrls) == type(""):
        serverUrls = [serverUrls]

    serverList = ServerList(serverUrls)

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
            lang = os.environ[env].split(':')[0]
            lang = lang.split('.')[0]
            break


    s = RetryServer(serverList.server(),
                    refreshCallback=refreshCallback,
                    proxy=proxyHost,
                    username=proxyUser,
                    password=proxyPassword)
    s.addServerList(serverList)

    s.add_header("X-Up2date-Version", up2dateUtils.version())
    
    if lang:
        s.setlang(lang)

    # require RHNS-CA-CERT file to be able to authenticate the SSL connections
    for rhns_ca_cert in rhns_ca_certs:
        if not os.access(rhns_ca_cert, os.R_OK):
            msg = "%s: %s" % (_("ERROR: can not find RHNS CA file"),
				 rhns_ca_cert)
            log.log_me("%s" % msg)
            raise up2dateErrors.SSLCertificateFileNotFound(msg)

        # force the validation of the SSL cert
        s.add_trusted_cert(rhns_ca_cert)

    clientCaps.loadLocalCaps()

    # send up the capabality info
    headerlist = clientCaps.caps.headerFormat()
    for (headerName, value) in headerlist:
        s.add_header(headerName, value)
    return s


def doCall(method, *args, **kwargs):
    log = up2dateLog.initLog()
    log.log_debug("rpcServer: Calling XMLRPC %s" % method.__dict__['_Method__name'])
    cfg = config.initUp2dateConfig()
    ret = None

    attempt_count = 1
    if cfg["networkRetries"] <= 0:
        attempts = 1
    else:
        attempts = cfg["networkRetries"]

    while 1:
        failure = 0
        ret = None        
        try:
            ret = method(*args, **kwargs)
        except KeyboardInterrupt:
            raise up2dateErrors.CommunicationError(_(
                "Connection aborted by the user"))
        # if we get a socket error, keep tryingx2
        except (socket.error, socket.sslerror), e:
            log.log_me("A socket error occurred: %s, attempt #%s" % (
                e, attempt_count))
            if attempt_count >= attempts:
                if len(e.args) > 1:
                    raise up2dateErrors.CommunicationError(e.args[1])
                else:
                    raise up2dateErrors.CommunicationError(e.args[0])
            else:
                failure = 1
        except httplib.IncompleteRead:
            print "httplib.IncompleteRead" 
            raise up2dateErrors.CommunicationError("httplib.IncompleteRead")

        except urllib2.HTTPError, e:
            msg = "\nAn HTTP error occurred:\n"
            msg = msg + "URL: %s\n" % e.filename
            msg = msg + "Status Code: %s\n" % e.code
            msg = msg + "Error Message: %s\n" % e.msg
            log.log_me(msg)
            raise up2dateErrors.CommunicationError(msg)
        
        except rpclib.ProtocolError, e:
            
            log.log_me("A protocol error occurred: %s , attempt #%s," % (
                e.errmsg, attempt_count))
            if e.errcode == 404:
                log.log_me("Could not find URL, %s" % (e.url))
                log.log_me("Check server name and/or URL, then retry\n");

            (errCode, errMsg) = rpclib.reportError(e.headers)
            reset = 0
            if abs(errCode) == 34:
                log.log_me("Auth token timeout occurred\n errmsg: %s" % errMsg)
                # this calls login, which in tern calls doCall (ie,
                # this function) but login should never get a 34, so
                # should be safe from recursion

                up2dateAuth.updateLoginInfo()

            # the servers are being throttle to pay users only, catch the
            # exceptions and display a nice error message
            if abs(errCode) == 51:
                log.log_me(_("Server has refused connection due to high load"))
                raise up2dateErrors.CommunicationError(e.errmsg)
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
                raise up2dateErrors.FileNotFoundError(msg)
                
            if not reset:
                if attempt_count >= attempts:
                    raise up2dateErrors.CommunicationError(e.errmsg)
                else:
                    failure = 1
            
        except rpclib.ResponseError:
            raise up2dateErrors.CommunicationError(
                "Broken response from the server.")

        if ret != None:
            break
        else:
            failure = 1


        if failure:
            # rest for five seconds before trying again
            time.sleep(5)
            attempt_count = attempt_count + 1
        
        if attempt_count > attempts:
            raise up2dateErrors.CommunicationError("The data returned from the server was incomplete")

    return ret
    
