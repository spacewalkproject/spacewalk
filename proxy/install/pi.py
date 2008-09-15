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
#RHN Proxy installer shared (GUI/TUI/CLI) code.
#------------------------------------------------------------------------------
# $Id: pi.py,v 1.87 2004/09/16 18:37:07 taw Exp $

## language imports
import os
import sys
import pwd
import rpm
import time
import string
import shutil
import socket
import signal
import cgiwrap
import xmlrpclib
rpclib = xmlrpclib

## local imports
import pi_lib
import pi_errors
import ssl_cert_gen

from pi_log import log_me, log_clean
from translate import _

DEFAULT_WEBRPC_HANDLER_v1_1 = '/WEBRPC/proxy.pxt'
DEFAULT_WEBRPC_HANDLER_v3_x = '/rpc/api'


def switchOnAllServices():
    """ chkconfig ON all services """
    #switchOnService('rhn_auth_cache')
    switchOnService('squid')
    switchOnService('httpd')


def restartEverything():
    """ Bounce all the services... """
    #restartService('rhn_auth_cache')
    restartService('squid')
    restartService('httpd')


def setupSquid():
    """ copies the squid.conf.sample file into the /etc/squid/ directory
        and bounces the service.
    """

    import glob
    # back up the old file.
    oldSquidConf = '/etc/squid/squid.conf'
    oldSquidConfBackup = oldSquidConf + '--proxy-install-backup'
    if os.path.exists(oldSquidConf) \
    and not os.path.exists(oldSquidConfBackup):
        shutil.copy(oldSquidConf, oldSquidConfBackup)
        msg = "backing up old squid.conf: %s --> %s" % (oldSquidConf, oldSquidConfBackup)
        log_me(msg)
        print msg

    # copy over the new one.
    sampleSquidGlobPath = '/usr/share/doc/rhns-proxy-*'
    sampleSquidConf = glob.glob(sampleSquidGlobPath)[0] + '/squid.conf.sample'
    shutil.copy(sampleSquidConf, oldSquidConf)
    msg = "copying over new squid.conf: %s --> %s" % (sampleSquidConf, oldSquidConf)
    log_me(msg)
    print msg


def setupHttpds(baseDir):
    # back up the old httpd.conf file.
    oldHttpdConf = '/etc/httpd/conf/httpd.conf'
    oldHttpdConfBackup = oldHttpdConf + '--proxy-install-backup'
    if os.path.exists(oldHttpdConf) \
    and not os.path.exists(oldHttpdConfBackup):
        shutil.copy(oldHttpdConf, oldHttpdConfBackup)
        msg = "backing up old httpd.conf: %s --> %s" % (oldHttpdConf, oldHttpdConfBackup)
        log_me(msg)
        print msg

    # copy over the new one.
    sampleHttpdConf = '%s/install/httpd.conf.sample' % baseDir
    shutil.copy(sampleHttpdConf, oldHttpdConf)
    msg = "copying over new httpd.conf: %s --> %s" % (sampleHttpdConf, oldHttpdConf)
    log_me(msg)
    print msg


def switchOnService(service):
    """ chkconfig ON a service """
    
    # Turn on the service (according to chkconfig)
    cmdline = ["/sbin/chkconfig", "--level", "2345", service, "on"]
    ret, stdout, stderr = pi_lib.myPopen(cmdline)
    out = stdout.read()
    err = stderr.read()
    if ret:
        errormsg = "Commandline, '%s' failed: \n: '%s'" % (string.join(cmdline), err)
        log_me(errormsg)
        raise pi_errors.ChkconfigError(errormsg)
    print "Service chkconfiged ON:", service


def restartService(service):
    """ bounce the passed in service. """
    
    cwd = os.getcwd()
    os.chdir('/')
    # stop the service
    ret, stdout, stderr = pi_lib.myPopen(["/etc/init.d/%s" % service, "stop"])
    print "Stopping service:", service
    out = stdout.read();    stdout.close()
    err = stderr.read();    stderr.close()
    if ret:
        # don't care, we may someday.
        pass

    # sleep
    time.sleep(2)

    # start the service
    print "Starting service:", service
    ret, stdout, stderr = pi_lib.myPopen(["/etc/init.d/%s" % service, "start"])
    out = stdout.read();    stdout.close()
    err = stderr.read();    stderr.close()
    os.chdir(cwd)
    if ret:
        log_me("%s process failed to start: \n: %s" % (service, err))
        raise pi_errors.ServiceRestartError("The %s process failed to start. The message was: %s\n" % (service, err))


def getSystemId():
    path = "/etc/sysconfig/rhn/systemid"
    if not os.access(path, os.R_OK):
        return None
    return open(path, "r").read()


# key is which key we would like to add to the keyring
def addGPGKey(key="/usr/share/rhn/RPM-GPG-KEY"):
    # might as well log this security stuff well
    gpg_command = "/usr/bin/gpg --list-keys"
    log_me("running %s to make sure gpg is initialized completely" % gpg_command)
    os.system(gpg_command)

    gpg_command = "/usr/bin/gpg  --import %s > /dev/null 2>&1" % (key)
    log_me("running %s" % gpg_command)
    return os.system(gpg_command)


def getAPIVersion(serverHostname, httpProxyHost,
                  httpProxyUser, httpProxyPassword):
    """ get's the API version, if fails, default back to 1.1 """
    version = '1.1.1'
    serverUrl = 'https://' + serverHostname + DEFAULT_WEBRPC_HANDLER_v3_x
    if not httpProxyHost:
        httpProxyHost = None
    if not httpProxyUser:
        httpProxyUser = None
    if not httpProxyPassword:
        httpProxyPassword = None

    s = rpclib.Server(serverUrl, httpProxyHost,
                      refreshCallback=None,
                      username=httpProxyUser,
                      password=httpProxyPassword)
    try:
        version = s.api.system_version()    # 3.1 API
    except xmlrpclib.Fault, e:
        log_me("WARNING: recieved xmlrpclib.Fault upon 'system_version', assuming '3.0.0' at least. Error was '%s'." % e.faultString)
        version = '3.0.0'
    except (cgiwrap.ProtocolError, socket.error), e:
        log_me("ERROR: bad things happening: %s" % repr(e)) 
        raise
    except (SystemExit, KeyboardInterrupt, NameError, TypeError):
        raise
    except Exception, e:
        # more than likely old API
        version = '1.1.1'
    log_me('API version: %s' % version)
    return string.split(version, '.')


def _getActivationErrorString(e):
    """ common error strings dependent upon faultString """

    errorString = ''
    errorCode = -1
    if e.faultString == 'proxy_invalid_systemid':
        errorstring = ("this server does not seem to be registered or "
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
    # apiVersion is not actually used (in this version), just shutting up
    # pychecker.
    apiVersion = apiVersion
    serverUrl = 'https://' + serverHostname + DEFAULT_WEBRPC_HANDLER_v1_1
    if not httpProxyHost:
        httpProxyHost = None
    if not httpProxyUser:
        httpProxyUser = None
    if not httpProxyPassword:
        httpProxyPassword = None
#    print """\
#        Attempting to activate: server:     %s
#                        proxy host: %s
#                        proxy user: %s
#                        proxy pass: %s""" \
#        % (serverUrl, httpProxyHost, httpProxyUser, httpProxyPassword)
    s = rpclib.Server(serverUrl, httpProxyHost,
                      refreshCallback=None,
                      username=httpProxyUser,
                      password=httpProxyPassword)

    systemid = getSystemId()

    errorCode, errorString = 0, ''
    for i in range(2):
        errorString = ''
        try:
            errorCode = s.proxy.activate_proxy(systemid) # RHN Proxy v1.1 API
        except xmlrpclib.Fault, e:
            errorCode, errorString = _getActivationErrorString(e)
            errorString = "ERROR: upon entitlement/activation attempt: %s" % errorString
            log_me(errorString)
            sys.stderr.write(errorString)
        except (cgiwrap.ProtocolError, socket.error), e:
            # try the old way
            errorString = '%s' % str(e)
            log_me("WARNING!!!! Attempting to activate via old methodology (%s)" % str(e))
            serverUrl = 'https://' + serverHostname + '/rpc/proxy.pxt'
            errorCode = -10
        except Exception, e:
            log_me("ERROR: upon entitlement/activation attempt (something unexpected): (%s) %s" % (repr(e), str(e)))
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
    serverUrl = 'https://' + serverHostname + DEFAULT_WEBRPC_HANDLER_v3_x
    if not httpProxyHost:
        httpProxyHost = None
    if not httpProxyUser:
        httpProxyUser = None
    if not httpProxyPassword:
        httpProxyPassword = None
#    print """\
#        Attempting to activate: server:     %s
#                        proxy host: %s
#                        proxy user: %s
#                        proxy pass: %s""" \
#        % (serverUrl, httpProxyHost, httpProxyUser, httpProxyPassword)
    s = rpclib.Server(serverUrl, httpProxyHost,
                      refreshCallback=None,
                      username=httpProxyUser,
                      password=httpProxyPassword)

    systemid = getSystemId()

    # DEactivate!
    try:
        errorCode = s.proxy.deactivate_proxy(systemid)       # proxy 3.0+ API
    except xmlrpclib.Fault, e:
        if string.find(e.faultString, 'proxy_not_activated') != -1:
            # fine. We weren't activated yet. noop
            pass
        else:
            errorCode, errorString = _getActivationErrorString(e)
            errorString = "WARNING: upon deactivation attempt: %s" % errorString
            log_me(errorString)
            sys.stderr.write(errorString)
    except Exception, e:
        log_me("ERROR: upon deactivation attempt (something unexpected): (%s) %s" % (repr(e), str(e)))
        return (-1, '')
    else:
        log_me("NOTE: successfully deactivated (i.e., was activated previously).")

    # activate!
    errorCode, errorString = 0, ''
    try:
        if apiVersion[1] == '0':
            errorCode = s.proxy.activate_proxy(systemid)         # 1.1/3.0 API
        else:
            errorCode = s.proxy.activate_proxy(systemid, "3.2")  # 3.1+ API
    except xmlrpclib.Fault, e:
        errorCode, errorString = _getActivationErrorString(e)
        errorString = "ERROR: upon entitlement/activation attempt: %s" % errorString
        log_me(errorString)
        sys.stderr.write(errorString)
    except Exception, e:
        log_me("ERROR: upon entitlement/activation attempt (something unexpected): (%s) %s" % (repr(e), str(e)))
        errorCode = -1
    else:
        errorString = 'activated!'
        errorCode = 1
    print "activateProxy: %s" % repr((errorCode, errorString))
    return (errorCode, errorString)


def validateRhnLogin(serverHostname, httpProxyHost, httpProxyUser, httpProxyPassword,
                     username, password):
    """ Creates an account (username/password) if doesn't exist already. """

    serverUrl = 'https://' + serverHostname + pi_lib.DEFAULT_RHN_HANDLER

    if not httpProxyHost:
        httpProxyHost = None
    if not httpProxyUser:
        httpProxyUser = None
    if not httpProxyPassword:
        httpProxyPassword = None

    print """\
Attempting to register: server:     %s
                        proxy host: %s
                        proxy user: %s
                        proxy pass: %s
                        username:   %s
                        password:   %s""" \
        % (serverUrl, httpProxyHost, httpProxyUser, httpProxyPassword, username, '*'*len(password))
    s = rpclib.Server(serverUrl, httpProxyHost,
                      refreshCallback=None,
                      username=httpProxyUser,
                      password=httpProxyPassword)

    ret = None
    try:
        ret = s.registration.new_user(username, password)
    except rpclib.Fault, f:
        if f.faultCode == -2 or f.faultCode == -11:
            raise pi_errors.InvalidUsernamePassword("The given username and password are incorrect")
    except socket.error, e:
        raise e

    return ret


def registerSystem(rhnUsername, rhnPassword):
    """ Register a box given and rhn username/password.
        NOTE: rhnreg_ks will use settings specified by rhn_register/up2date.
    """

    cmdline = ["/usr/sbin/rhnreg_ks", "--username", rhnUsername, "--force", "--password"]
    cmdline_printable = string.join(cmdline + ['<password>'])
    cmdline = cmdline + [rhnPassword]
    print "cmdline: %s" % cmdline_printable
    ret, stdout, stderr = pi_lib.myPopen(cmdline)
    out = stdout.read()
    err = stderr.read()

    # systemid needs to be accessible by apache
    apacheGID = pwd.getpwnam('apache')[3]
    # chmod 0640 ...; chown root.apache ...
    os.chmod('/etc/sysconfig/rhn/systemid', 0640)
    os.chown('/etc/sysconfig/rhn/systemid', 0, apacheGID)

    if ret:
        log_me("Registration of the system via RHN failed: \n: %s" % err)
        raise pi_errors.RhnEntitlementError("%s" % err)
    return 0


def getInstalledPackageList(msgCallback=None, progressCallback=None,
                            getArch=None):
    list = []

    if msgCallback != None:
        msgCallback(_("Getting list of packages installed on the system"))

    db = pi_lib.openrpmdb(option=0)

    _firstKeyYN = 0
    _nextKeyYN = 0
    if "firstkey" in dir(db):
        _firstKeyYN = 1
    if "nextkey" in dir(db):
        _nextKeyYN = 1

    # this block simply gets a count
    if progressCallback != None:
        count = 1
        total = 0

        if _firstKeyYN:
            key = db.firstkey()
            h = db[key]
        else:
            iterator = db.match(0)
            h = iterator.next()

        while (h):
            count = count + 1
            if _nextKeyYN:
                key = db.nextkey(key)
                if key:
                    h = db[key]
                else:
                    h = None
            else:
                h = iterator.next()

        total = count
        count = 1

    # now we do actual work
    if _firstKeyYN:
        key = db.firstkey()
        h = db[key]
    else:
        iterator = db.match(0)
        h = iterator.next()

    while (h):
        name = h['name']
        epoch = h['epoch']
        if epoch is None:
            epoch = ""
        version = h['version']
        release = h['release']
        if getArch:
            arch = h['arch']
            list.append([name, version, release, epoch, arch])
        else:
            list.append([name, version, release, epoch])

        if progressCallback != None:
            progressCallback(count, total)
            count = count + 1

        if _nextKeyYN:
            key = db.nextkey(key)
            if key:
                h = db[key]
            else:
                h = None
        else:
            h = iterator.next()

    list.sort()
    del db
    return list


def getListOfPackagesToInstall(rpmPath):
    # or if we decide to use a manifest, do it here
    import glob
    from up2date_client import up2dateUtils
    globPattern = "%s/*.rpm" % (rpmPath)

    packagesToInstall = {}
    installedPackages = getInstalledPackageList()
    installedPackagesDict = {}
    for package in installedPackages:
        installedPackagesDict[package[0]] = package

    availablePackages = {}
    filenames = glob.glob(globPattern)
    for filename in filenames:
         fd = os.open(filename, 0)
         (hdr,isSource) = rpm.headerFromPackage(fd)
         # blargh, cant have None as the epoch
         nvr = [hdr['name'],
                hdr['version'],
                hdr['release']]
         ep = hdr['epoch']
         if ep == None:
             e = [""]
         else:
             e = [ep]
         nvre = nvr + e
         availablePackages[tuple(nvre)] = filename

    pkgList = availablePackages.keys()
    for pkg in pkgList:
        # package isnt currently installed
        if not installedPackagesDict.has_key(pkg[0]):
                # add it to the list of installed packages with 0-0:0 version
                installedPackagesDict[pkg[0]] = (pkg[0], "0", "0", "")

    pkgCount = len(pkgList)
    for index in range(pkgCount):
        if installedPackagesDict.has_key(pkgList[index][0]):
            installedPackage = installedPackagesDict[pkgList[index][0]]
            ret = up2dateUtils.comparePackages(installedPackage, pkgList[index])
            # already installed
            if ret == 0:
                pass
            # newer version installed
            elif ret > 0:
                pass
            # the one available is newer
            else:
                packagesToInstall[pkgList[index]] =  availablePackages[pkgList[index]]

    return packagesToInstall.values()


def installPackages(rpmPath, rpmCallback):
    db = pi_lib.openrpmdb(option=1)
    ts = rpm.TransactionSet("/", db)

    filenames = getListOfPackagesToInstall(rpmPath)

    if len(filenames) == 0:
        return 0

    for filename in filenames:
        fd = os.open(filename, 0)
        (hdr, isSource) = rpm.headerFromPackage(fd)
        if hdr is None:
            raise pi_errors.RpmError(_("Error reading header from package %s") % filename)
        ts.add(hdr, hdr, "u")
        os.close(fd)

    ts.order()
    deps = ts.depcheck()

    # make this smarter, duh
    if deps:
        msg = _("Dependency resolution error: ")
        print msg + repr(deps)
        log_me(msg + repr(deps))
        raise pi_errors.DependencyError(msg, deps=deps)

    rc = ts.run(0, 0, rpmCallback, rpmPath)

    if rc:
        errors = "\n"
        for e in rc:
            try:
                errors = errors + e[1] + "\n"
            except:
                errors = errors + str(e) + "\n"
        raise pi_errors.RpmError(_("Package installation error: %s") % errors)

    del db
    return 0


def genSslCerts(passwd, C, ST, L, O, OU, CN, emailAddress, hostname,
                caCertExpiration, serverCertExpiration):
    sys.path.append("/usr/share/rhn/")
    from certs.sslToolLib import getMachineName
    from certs.sslToolConfig import DEFS
    from certs import rhn_ssl_tool

    if not C or len(C) != 2:
        raise ValueError, "(country code) must be exactly two characters (e.g. US)"
    if not CN:
        CN = hostname
    
    DEFS['--dir'] = '/etc/sysconfig/rhn/ssl' # for now
    DEFS['--set-country'] = C
    DEFS['--set-state'] = ST
    DEFS['--set-city'] = L
    DEFS['--set-org'] = O
    DEFS['--set-org-unit'] = OU
    DEFS['--server-rpm'] = 'rhn-org-httpd-ssl-key-pair-' \
                           + getMachineName(hostname)
        
    # generate the Client CA Key & Cert
    DEFS['--set-email'] = ""
    DEFS['--cert-expiration'] = int(caCertExpiration)*356
    DEFS['--set-common-name'] = CN
    rhn_ssl_tool.genPrivateCaKey(passwd, DEFS, verbosity=2, forceYN=1)
    rhn_ssl_tool.genPublicCaCert(passwd, DEFS, verbosity=2, forceYN=1)


    # generate the Server Key, Cert Req,  & Cert
    DEFS['--set-email'] = emailAddress
    DEFS['--cert-expiration'] = int(serverCertExpiration)*356
    DEFS['--set-hostname'] = hostname
    rhn_ssl_tool.genServerKey(DEFS, verbosity=2)
    rhn_ssl_tool.genServerCertReq(DEFS, verbosity=2)
    rhn_ssl_tool.genServerCert(passwd, DEFS, verbosity=2)

    # build the RPMs
    caCertRpmPath = os.path.join(DEFS['--dir'], rhn_ssl_tool.genCaRpm(DEFS, verbosity=2))
    serverRpmPath = os.path.join(DEFS['--dir'], rhn_ssl_tool.genServerRpm(DEFS, verbosity=2))

    # install the server RPM
    sslCertRPMPath = ssl_cert_gen.installCertRpm(serverRpmPath)

    # deploy RPM and ca cert to /var/www/html/pub/
    caCertRPMPath = ssl_cert_gen.deployClientCertRPMs(caCertRpmPath)
    ca_cert_path = os.path.join(DEFS['--dir'], DEFS['--ca-cert'])
    ssl_cert_gen.deployClientCert(ca_cert_path)

    return (sslCertRPMPath, caCertRPMPath)

