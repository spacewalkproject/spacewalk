#!/usr/bin/python -u
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
""" Activate an RHN Proxy
    USAGE: python rhn_proxy_activate.py

    Author: Todd Warner <taw@redhat.com>
"""
# $Id: rhn_proxy_activate.py,v 1.1 2004/08/30 23:46:13 taw Exp $

## core lang imports
import os
import sys
import pwd
import string
import socket

## lib imports
from rhn import rpclib

## proxy code
# set up paths:
_LIBPATH = '/usr/share/rhn'
if _LIBPATH not in sys.path:
    sys.path.append(_LIBPATH)
from common.rhnConfig import RHNOptions, CFG, initCFG
from common.rhnLib import parseUrl

USE_SSL = 1

DEFAULT_WEBRPC_HANDLER_v1_1 = '/WEBRPC/proxy.pxt'
DEFAULT_WEBRPC_HANDLER_v3_x = '/rpc/api'


def _getCfg(component, dir=None, file=None):
    err = sys.stderr
    sys.stderr = open('/dev/null', 'rb+')
    cfg = RHNOptions(component, dir, file)
    cfg.parse()
    sys.stderr = err
    # returns a dictionary because cfg is a singleton
    d = {}
    for k in cfg.keys():
        d[k] = cfg[k]
    return d


def alreadyConvertedYN():
    proxyCfg = _getCfg('proxy')
    brokerCfg = _getCfg('proxy.broker')
    redirectCfg = _getCfg('proxy.redirect')
    p_rhn_parent = parseUrl(proxyCfg.get('rhn_parent', ''))[1]
    pb_rhn_parent = parseUrl(brokerCfg.get('rhn_parent', ''))[1]
    pr_rhn_parent = parseUrl(redirectCfg.get('rhn_parent', ''))[1]
    return p_rhn_parent == pb_rhn_parent == pr_rhn_parent


def getSystemId():
    path = "/etc/sysconfig/rhn/systemid"
    if not os.access(path, os.R_OK):
        return None
    return open(path, "r").read()


def getServer(hostname, handler, proxy, proxyUsername, proxyPassword, caCert):
    """ get an rpclib.Server object. NOTE: proxy is an HTTP proxy """

    serverUrl = 'https://' + hostname + handler
    if not USE_SSL:
        serverUrl = 'http://' + hostname + handler
        caCert = None

    proxy = proxy or None
    proxyUsername = proxyUsername or None
    if not proxyUsername:
        proxyPassword = None
    proxyPassword = proxyPassword or None

    caCert = caCert or None

#    print """\
#Attempting to activate: server:     %s
#                        proxy host: %s
#                        proxy user: %s
#                        proxy pass: %s""" \
#        % (serverUrl, proxy, proxyUsername, proxyPassword)

    s = None
    if proxy:
        s = rpclib.Server(serverUrl,
                          proxy=proxy,
                          username=proxyUsername,
                          password=proxyPassword)
    else:
        s = rpclib.Server(serverUrl)

    if USE_SSL and caCert:
        s.add_trusted_cert(caCert)

    return s



def chmod_chown_systemid():
    path = "/etc/sysconfig/rhn/systemid"

    if getSystemId() is None:
        sys.stderr.write("ERROR: RHN Proxy does not appear to be registered\n")
        sys.exit(-1)

    # systemid needs to be accessible by apache
    apacheGID = pwd.getpwnam('apache')[3]

    # chmod 0640 ...; chown root.apache ...
    os.chmod(path, 0640)
    os.chown(path, 0, apacheGID)


def getAPIVersion(serverHostname, httpProxyHost,
                  httpProxyUser, httpProxyPassword):
    """ get's the API version, if fails, default back to 1.1 """

    version = '1.1.1'

    s = getServer(serverHostname, DEFAULT_WEBRPC_HANDLER_v3_x,
                  httpProxyHost, httpProxyUser, httpProxyPassword, CFG.CA_CHAIN)

    try:
        version = s.api.system_version()    # 3.1+ API
    except rpclib.Fault, e:
        #sys.stderr.write("warning: Recieved rpclib.Fault upon 'system_version' call.\n")
        #sys.stderr.write("         Assuming '3.0.0' at least.\n")
        #sys.stderr.write("         Error was '%s'.\n" % e.faultString)
        version = '3.0.0'
    except (rpclib.ProtocolError, socket.error), e:
        sys.stderr.write("ERROR: bad things happening: %s\n" % repr(e)) 
        raise
    except (SystemExit, KeyboardInterrupt, NameError, TypeError):
        raise
    except Exception, e:
        # more than likely old API
        version = '1.1.1'
    print "API version: %s" % version
    return string.split(version, '.')


def _getActivationErrorString(e):
    """ common error strings dependent upon faultString """

    errorString = ''
    errorCode = -1
    if e.faultString == 'proxy_invalid_systemid':
        errorString = ("this server does not seem to be registered or "
                       "/etc/sysconfig/rhn/systemid is corrupt.")
        errorCode = -2
    elif e.faultString == 'proxy_no_provisioning_entitlements':
        # possible future error message?
        errorString = ("no Provisioning entitlements available. There must "
                       "be at least one free Management/Provisioning slot "
                       "available in your RHN account.")
        errorCode = -3
    elif e.faultString == 'proxy_no_management_entitlements':
        errorString = ("no Management entitlements available. There must be "
                       "at least one free Management/Provisioning slot "
                       "available in your RHN account.")
        errorCode = -3
    elif e.faultString == 'proxy_no_enterprise_entitlements':
        # legacy error message
        errorString = ("no Management entitlements available. There must be "
                       "at least one free Management/Provisioning slot "
                       "available in your RHN account.")
        errorCode = -3
    elif e.faultString == 'proxy_no_channel_entitlements':
        errorString = ("no RHN Proxy entitlements available. There must be "
                       "at least one free RHN Proxy entitlement "
                       "available in your RHN account.")
        errorCode = -4
    elif e.faultString == 'proxy_no_proxy_child_channel':
        errorString = ("no RHN Proxy entitlements available for this "
                       "server's version of Red Hat Enterprise Linux.")
        errorCode = -5
    else:
        errorString = "unknown error - %s" % str(e)
        errorCode = -1
    return errorCode, errorString


def activateProxy_v1_1(serverHostname, httpProxyHost,
                       httpProxyUser, httpProxyPassword,
                       apiVersion):

    systemid = getSystemId()

    errorCode, errorString = 0, ''
    handler = DEFAULT_WEBRPC_HANDLER_v1_1

    for i in range(2):
        s = getServer(serverHostname, handler,
                      httpProxyHost, httpProxyUser, httpProxyPassword, CFG.CA_CHAIN)

        errorString = ''
        try:
            errorCode = s.proxy.activate_proxy(systemid) # RHN Proxy v1.1 API
        except rpclib.Fault, e:
            errorCode, errorString = _getActivationErrorString(e)
            errorString = "ERROR: upon entitlement/activation attempt: %s" % errorString
            sys.stderr.write(errorString+'\n')
        except (rpclib.ProtocolError, socket.error), e:
            # try the old way
            errorString = '%s' % str(e)
            sys.stderr.write("warning: Attempting to activate via old methodology (%s)\n" % str(e))
            handler = '/rpc/proxy.pxt'
            errorCode = -10
        except Exception, e:
            sys.stderr.write("ERROR: upon entitlement/activation attempt (something unexpected): (%s) %s\n" % (repr(e), str(e)))
            errorCode = -1
        else:
            errorCode = 1
        if errorCode not in (-10,):
            break
    print "activateProxy_v1_1: %s" % repr((errorCode, errorString))
    return (errorCode, errorString)


def activateProxy_v3_2(serverHostname, httpProxyHost,
                       httpProxyUser, httpProxyPassword,
                       apiVersion):

    s = getServer(serverHostname, DEFAULT_WEBRPC_HANDLER_v3_x,
                  httpProxyHost, httpProxyUser, httpProxyPassword, CFG.CA_CHAIN)

    systemid = getSystemId()

    # DEactivate!
    try:
        errorCode = s.proxy.deactivate_proxy(systemid)       # proxy 3.0+ API
    except rpclib.Fault, e:
        if string.find(e.faultString, 'proxy_not_activated') != -1:
            # fine. We weren't activated yet. noop
            pass
        else:
            errorCode, errorString = _getActivationErrorString(e)
            errorString = "WARNING: upon deactivation attempt: %s" % errorString
            sys.stderr.write(errorString+'\n')
    except Exception, e:
        sys.stderr.write("ERROR: upon deactivation attempt (something unexpected): (%s) %s\n" % (repr(e), str(e)))
        return (-1, '')
    else:
        sys.stdout.write("successfully deactivated (i.e., was activated previously).\n")

    # activate!
    errorCode, errorString = 0, ''
    try:
        if apiVersion[1] == '0':
            errorCode = s.proxy.activate_proxy(systemid)         # 1.1/3.0 API
        else:
            errorCode = s.proxy.activate_proxy(systemid, "3.2")  # 3.1+ API
    except rpclib.Fault, e:
        errorCode, errorString = _getActivationErrorString(e)
        errorString = "ERROR: upon entitlement/activation attempt: %s" % errorString
        sys.stderr.write(errorString+'\n')
    except Exception, e:
        sys.stderr.write("ERROR: upon entitlement/activation attempt (something unexpected): (%s) %s\n" % (repr(e), str(e)))
        errorCode = -1
    else:
        errorString = 'activated!'
        errorCode = 1
    print "activateProxy: %s" % repr((errorCode, errorString))
    return (errorCode, errorString)


def activateProxy():
    initCFG('proxy')
    
    httpProxy = CFG.HTTP_PROXY
    httpProxyUsername = CFG.HTTP_PROXY_USERNAME
    httpProxyPassword = CFG.HTTP_PROXY_PASSWORD
    if not httpProxy:
        httpProxy, httpProxyUsername, httpProxyPassword = None, None, None

    print 'RHN Parent of this RHN Proxy:', parseUrl(CFG.RHN_PARENT)[1]
    apiVersion = getAPIVersion(parseUrl(CFG.RHN_PARENT)[1],
                               httpProxy,
                               httpProxyUsername,
                               httpProxyPassword)
    funct = activateProxy_v1_1
    if apiVersion[0] == '1' or (apiVersion[0] == '3' and apiVersion[1] == '0'):
        # 1.1 or 3.0
        sys.stderr.write("ERROR: upstream server incompatible with "
                         "this RHN Proxy version. Upstream API "
                         "version is %s\n" % string.join(apiVersion, '.'))
        sys.exit(-1)
        funct = activateProxy_v1_1
    elif apiVersion[0] == 3:
        funct = activateProxy_v3_2
    elif int(apiVersion[0]) >= 3:
        # for now
        funct = activateProxy_v3_2

    # errorCode == 1 means activated!
    errorCode, errorString = funct(parseUrl(CFG.RHN_PARENT)[1],
                                   httpProxy,
                                   httpProxyUsername,
                                   httpProxyPassword, apiVersion)
        
    if errorCode == -1 and not errorString:
        # ancient satellite will produce a -1 error-code... nothing else should.
        errorString = ("\nAn unknown error occured, there could be several reasons for this.\n\n"
                       "(a) you are pointing at a Satellite without automated activate.\n"
                       "    Here are the steps:\n"
                       "        o login to the satellite\n"
                       "        o go to the system list and click on the recently registered system\n"
                       "        o set Entitled to 'Enterprise', and click the 'Modify System Profile' button\n"
                       "        o click on the 'RHN Proxy' tab and click on the 'Activate License' button\n"
                       "        o click this dialog's OK button (in the installer) and then click 'Next'\n\n"
                       "(b) there really is an unknown problem... Consult with your Red Hat representative.\n"
                       "        o click this dialog's OK button (in the installer) and then click 'Cancel'\n")
        sys.stderr.write("\nThere was a problem activating the RHN Proxy entitlement:\n\n%s\n" % errorString)
        sys.exit(errorCode)

    if errorCode != 1:
        if not errorString:
            errorString = ("An unknown error occured. Consult with your Red Hat representative.\n")
        sys.stderr.write("\nThere was a problem activating the RHN Proxy entitlement:\n\n%s" % errorString)
        sys.exit(errorCode)
        

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
def main():
    if '-h' in sys.argv or '--help' in sys.argv:
        print "USAGE: %s" % os.path.basename(sys.argv[0])
        sys.exit(0)

    chmod_chown_systemid()

    if not alreadyConvertedYN():
        print """
Configuration file (/etc/rhn/rhn.conf) does not appear to be of version 3.x!!!
"""
        sys.exit(-1)

    activateProxy()

if __name__ == '__main__':
    try:
        sys.exit(main() or 0)
    except SystemExit:
        raise
    except:
        raise 




