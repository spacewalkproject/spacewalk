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
""" SSL certificates/RPMs generation
"""
#------------------------------------------------------------------------------
# $Id: ssl_cert_gen.py,v 1.24 2004/06/27 00:51:12 taw Exp $

## language imports
import os
from os.path import basename
import re
import sys
import rpm
import glob
import shutil
import string
import socket

## local imports
from pi_log import log_me, log_me_stdout
from pi_errors import RpmError, genPublicCaCertError, DependencyError
from translate import _
from pi_lib import openrpmdb, DEFAULT_RHN_ETC_DIR, myPopen, \
                   DEFAULT_APACHE_PUB_DIRECTORY

_SSL_DIR = os.path.join(DEFAULT_RHN_ETC_DIR, 'ssl')
if not os.path.exists(_SSL_DIR):
    os.makedirs(_SSL_DIR, 0770)

_ANCIENT_HTTPD_SSL_KEY_PAIR_RPM_NAME = 'rhns-ssl-cert'
_LEGACY_HTTPD_SSL_KEY_PAIR_RPM_NAME = 'rhn-httpd-ssl-key-pair'


class RpmCallback:
    def __init__(self):
        self.fd = 0

    def callback(self,what, amount, total, hdr, path):
        if what == rpm.RPMCALLBACK_INST_OPEN_FILE:
            fileName = "%s/%s-%s-%s.%s.rpm" % (path,
                                               hdr['name'],
                                               hdr['version'],
                                               hdr['release'],
                                               hdr['arch'])
            self.fd = os.open(fileName, os.O_RDONLY)
            return self.fd
        elif what == rpm.RPMCALLBACK_INST_CLOSE_FILE:
            os.close(self.fd)
            self.fd = 0
        elif what == rpm.RPMCALLBACK_INST_START:
            pass
        elif (what == rpm.RPMCALLBACK_TRANS_PROGRESS or
              what == rpm.RPMCALLBACK_INST_PROGRESS):
            pass
        elif what == rpm.RPMCALLBACK_TRANS_START:
            pass
        elif what == rpm.RPMCALLBACK_TRANS_STOP:
            pass
        return None


def getInstalledSSLCertHeader(rpmName):
    """ quieries the RPM DB for the version of the rpmName 
        installed
    """

    from common.rhn_rpm import MatchIterator, hdrLabelCompare
    mi = MatchIterator("name")
    mi.pattern("name", rpm.RPMMIRE_GLOB, rpmName)
    hdr = hdrnext = mi.next()
    while hdrnext is not None:
        if hdrLabelCompare(hdrnext, hdr) == 1:
            hdr = hdrnext
        hdrnext = mi.next()
    return hdr


# reg exp for splitting package names.
re_rpmName = re.compile("^(.*)-([^-]*)-([^-]*)$")

def parseRPMName(pkgName):
    """ IN:  Package string in, n-n-n-v.v.v-r.r_r, format.
        OUT: Four strings (in a tuple): name, release, version, epoch.
    """
    reg = re_rpmName.match(pkgName)
    if reg == None:
        return None, None, None, None
    n, v, r = reg.group(1,2,3)
    e = ""
    ind = string.find(r, ':')
    if ind < 0: # no epoch
        return str(n), str(v), str(r), str(e)
    e = r[ind+1:]
    r = r[0:ind]
    return str(n), str(v), str(r), str(e)


def parseRPMFilename(pkgFilename):
    """ 'n_n-n-v.v.v-r_r.r:e.ARCH.rpm' ---> [n,v,r,e,a]
        IN: Package Name: xxx-yyy-ver.ver.ver-rel.rel_rel:e.ARCH.rpm (string)
            Understood rules:
               o Name can have nearly any char, but end in a - (well seperated
                 by). Any character; may include - as well.
               o Version cannot have a -, but ends in one.
               o Release should be an actual number, and can't have any -'s.
               o Release can include the Epoch, e.g.: 2:4 (4 is the epoch)
               o Epoch: Can include anything except a - and the : seperator???
                 XXX: Is epoch info above correct?
        OUT: [n,v,r,e, arch].
    """
    if type(pkgFilename) != type(''):
	raise ValueError(str(pkgFilename)) # Invalid arg.

    pkgFilename = os.path.basename(pkgFilename)

    # Check that this is a package NAME (with arch.rpm) and strip
    # that crap off.
    pkg = string.split(pkgFilename, '.')

    # 'rpm' at end?
    if string.lower(pkg[-1]) != 'rpm':
	raise ValueError('not an rpm package name: %s' % pkgFilename)

    _arch = pkg[-2]

    # Nuke that arch.rpm.
    pkg = string.join(pkg[:-2], '.')
    ret = list(parseRPMName(pkg))
    if ret:
        ret.append(_arch)
    return  ret


def installCertRpm(rpmPath):

    # find <path>/<rpm_name>:
    rpmNamePath = parseRPMFilename(rpmPath)
    rpmNamePath = os.path.join(os.path.dirname(rpmPath), rpmNamePath[0])

    filenames = glob.glob("%s-*.noarch.rpm" % rpmNamePath)
    from common.rhn_rpm import sortRPMs
    filenames = sortRPMs(filenames)

    if filenames:
        log_me_stdout("\n** Found these rpms:")
    for filename in filenames:
        log_me_stdout("   %s" % filename)
    
    if not filenames:
        msg ="ERROR: no %s.noarch.rpm RPMs found. Please troubleshoot" \
             % basename(rpmNamePath)
        sys.stderr.write(msg+'\n')
        raise genPublicCaCertError, msg

    filename = filenames[-1]
    ancient = getInstalledSSLCertHeader(_ANCIENT_HTTPD_SSL_KEY_PAIR_RPM_NAME)
    legacy = getInstalledSSLCertHeader(_LEGACY_HTTPD_SSL_KEY_PAIR_RPM_NAME)
    if ancient:
        log_me_stdout("**Removing legacy rpm: %s" % ancient)
        # XXX: quick and dirty... let's use rpm libraries soon:
        cmdLine = "/bin/rpm -e %s" % _ANCIENT_HTTPD_SSL_KEY_PAIR_RPM_NAME
        stdout = os.popen(cmdLine, "r")
        out = stdout.read()
        ret = stdout.close()
        if ret:
            log_me("ERROR: upon executing this commandline (%s) - %s"
                   % (cmdLine, out))
            raise RpmError("ERROR: upon executing this commandline (%s) - %s"
                           % (cmdLine, out))
    elif legacy:
        log_me_stdout("**Removing legacy rpm: %s" % legacy)
        # XXX: quick and dirty... let's use rpm libraries soon:
        cmdLine = "/bin/rpm -e %s" % _LEGACY_HTTPD_SSL_KEY_PAIR_RPM_NAME
        stdout = os.popen(cmdLine, "r")
        out = stdout.read()
        ret = stdout.close()
        if ret:
            log_me("ERROR: upon executing this commandline (%s) - %s"
                   % (cmdLine, out))
            raise RpmError("ERROR: upon executing this commandline (%s) - %s"
                           % (cmdLine, out))
    elif basename(filename) == getInstalledSSLCertHeader(basename(rpmPath)):
        # nothing to do
        return filename

    log_me_stdout("** Installing: %s" % basename(filename))

    rcb = RpmCallback()
    rpmCallback = rcb.callback
    db = openrpmdb(option=1)
    ts = rpm.TransactionSet("/", db)

    # add that file to the transaction
    fd = os.open(filename, 0)
    hdr, isSource = rpm.headerFromPackage(fd)
    if hdr is None:
        raise RpmError(_("Error reading header from package %s") %
                       filename)
    ts.add(hdr, hdr, "u")
    os.close(fd)

    # dependency check (?)
    ts.order()
    deps = ts.depcheck()
    if deps:
        raise DependencyError(_("Dependencies should have already been "
                                "resolved, but they are not."), deps)
    # execute!
    rc = ts.run(0, 0, rpmCallback, _SSL_DIR)

    if rc:
        errors = "\n"
        for e in rc:
            try:
                errors = errors + e[1] + "\n"
            except:
                errors = errors + str(e) + "\n"
        raise RpmError(_("Failed installing packages: %s") % errors)

    del db
    if filename:
        log_me_stdout("** RPM install success: %s\n"
                      "   Please verify with 'rpm -q ...'."
                      % basename(filename))
    return filename


def deployClientCertRPMs(rpmPath):
    "copy the client cert RPM(s) to the proper path"

    # find <path>/<rpm_name>:
    rpmNamePath = parseRPMFilename(rpmPath)
    rpmNamePath = os.path.join(os.path.dirname(rpmPath), rpmNamePath[0])

    filenames = glob.glob("%s-*.noarch.rpm" % rpmNamePath)
    from common.rhn_rpm import sortRPMs
    filenames = sortRPMs(filenames)

    # cp to /var/www/html/pub
    certpath=DEFAULT_APACHE_PUB_DIRECTORY
    if not os.path.isdir(certpath):
        os.mkdir(certpath)
    if len(filenames):
        filename = filenames[-1]
        shutil.copy(filename, certpath)
        
        filename = certpath + basename(filename)
        os.chmod(filename, 0644)

        return filename
    else:
        raise genPublicCaCertError, \
          "no SSL CA Cert RPMs available for deployment in %s" \
          % os.path.dirname(rpmPath)


def deployClientCert(certPath):
    "copy the client ssl cert (not the RPM) to the proper path"

    # cp to /var/www/html/pub
    certDir="/var/www/html/pub"
    if not os.path.isdir(certDir):
        os.mkdir(certDir)
    if os.path.exists(certPath):
        shutil.copy(certPath, certDir)
        filename = os.path.join(certDir, basename(certPath))
        os.chmod(filename, 0644)
        return filename
    else:
        raise genPublicCaCertError, \
          "no SSL CA Cert RPMs available for deployment in %s" \
          % os.path.dirname(certPath)


def fetchSslData(caCertConfig=None, serverCertConfig=None):
    """ yank all the pertinent ssl data from a previously
        generated *-openssl.cnf
    """

    sys.path.append("/usr/share/rhn/")
    from certs.sslToolLib import getMachineName

    caCertConfig = caCertConfig or os.path.join(_SSL_DIR, 'rhn-ca-openssl.cnf')
    serverCertConfig = serverCertConfig \
                         or '%s/%s/rhn-server-openssl.cnf' \
                            % (_SSL_DIR, getMachineName(socket.gethostname()))

    if not os.path.exists(caCertConfig):
        caCertConfig = os.path.join(_SSL_DIR, 'openssl.cnf')
    if not os.path.exists(serverCertConfig):
        serverCertConfig = os.path.join(_SSL_DIR, 'openssl.cnf')

    cad = {}
    sd = {}

    for fPath, d in ((caCertConfig, cad), (serverCertConfig, sd)):
        try:
            fo = open(fPath, 'r')
        except:
            continue

        keys = ['C', 'ST', 'L', 'O', 'OU', 'CN', 'emailAddress', 'caExp', 'serverExp']

        for s in fo.readlines():
            s = string.strip(s)
            split = string.split(s)
            if not split or len(split) < 3:
                continue
            if split[0] not in keys:
                continue
            split = string.split(s, '=')
            if len(split) != 2:
                continue
            for i in range(len(split)):
                split[i] = string.strip(split[i])
            d[split[0]] = split[1]

    return cad, sd


#------------------------------------------------------------------------------

def _test():
    """ For test purposes only. """

    print "Testing."
    # init the logger
    import pi_log
    try:
        pi_log.initLog()
    except IOError, e:
        print "Unable to open log file. The error was: %s" % e
        sys.exit(1)
    passwd = "foobar"
    certInfo = {
        'ssl_country_code'  : "US",
        'ssl_province_name' : "North Carolina",
        "ssl_locality_name" : "Raleigh",
        "ssl_org_name"      : "Crazy Billy Bobs Great Big Linux And Open Source Emporium",
        "ssl_org_unit"      : "Doublewide and SSL Server sales",
        "ssl_common_name"   : "flippy.bar.com",
        "ssl_email"         : "root@nowhere_real.com",
        }
    if not certInfo['ssl_country_code'] or len(certInfo['ssl_country_code']) != 2:
        raise ValueError, "(country code) must be 2 characters (e.g., US); no more, no less"

#    populateTemplate(certInfo)
#    genCAKey(passwd)
#    genCACert(passwd)
#    genServerKey()
#    genServerCert(passwd)
#    genCertRpms(passwd)
#    installCertRpm()

if __name__ == "__main__":
    _test()
