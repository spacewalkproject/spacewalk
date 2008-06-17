""" satLib.py - helper functions that can be used by more than one module

    Copyright (c) 2002-2005, Red Hat, Inc.
    All rights reserved.
"""

#-------------------------------------------------------------------------------
# $Id: satLib.py,v 1.96 2005-07-05 17:50:13 wregglej Exp $

import os
import sys
import glob
import time
import gzip
import types
import popen2
import select
import string
from translate import _

## set up paths:
DEFAULT_SATPATH = '/usr/share/rhn'
if DEFAULT_SATPATH not in sys.path:
    sys.path.append(DEFAULT_SATPATH)
from common.rhnLib import make_temp_file, parseUrl, cleanupAbsPath, getFileMD5,\
                          maketemp
from common.rhn_rpm import get_package_header, labelCompare

from satLog import log_me, log_me_clean

# systemExit is imported from satLib by a number of
# other modules so, this is easier:
from installPackages import systemExit
from satErrors import PRODUCT_NAME

from certs.sslToolLib import yearsTil18Jan2038


## Globals and defaults:
########################
DEFAULT_RHN_ETC_DIR = '/etc/sysconfig/rhn'
SAT_SCHEMA = "%s/universe.satellite.sql" % DEFAULT_RHN_ETC_DIR
SAT_SCHEMA_DEPLOY = "%s/universe.deploy.sql" % DEFAULT_RHN_ETC_DIR

# XXX: pull some of these from CFG sometime in the future
#      also move them out of here!
DEFAULT_SYSTEMID_LOCATION = '%s/systemid' % DEFAULT_RHN_ETC_DIR
DEFAULT_RHN_REGISTER_CONFIG_LOCATION = '%s/rhn_register' % DEFAULT_RHN_ETC_DIR
DEFAULT_UP2DATE_CONFIG_LOCATION = '%s/up2date' % DEFAULT_RHN_ETC_DIR
DEFAULT_RHN_CERT_LOCATION = '%s/rhn-entitlement-cert.xml' % DEFAULT_RHN_ETC_DIR
DEFAULT_RHN_PARENT = "xmlrpc.rhn.redhat.com"
DEFAULT_RHN_HANDLER = '/XMLRPC'
#DEFAULT_WEB_HANDLER = '/WEBRPC/satellite.pxt'   # pre-cactus API
DEFAULT_WEB_HANDLER = '/rpc/api'               # cactus API
DEFAULT_RHN_TRUSTED_SSL_CERT = "/usr/share/rhn/RHNS-CA-CERT"
DEFAULT_ORG_TRUSTED_SSL_CERT = "/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT"
DEFAULT_MOUNT_POINT = "/var/satellite"
DEFAULT_GPG_KEY = "/usr/share/rhn/RPM-GPG-KEY"
DEFAULT_WEBAPP_GPG_KEY_RING = "/etc/webapp-keyring.gpg"
DEFAULT_ORIGINATING_WEBAPP_GPG_KEY_RING = "/etc/sysconfig/rhn-satellite-prep/etc/webapp-keyring.gpg"
DEFAULT_CONFIG_FILE = "/etc/rhn/rhn.conf"
DEFAULT_TNSNAMES = '/etc/tnsnames.ora'
DEFAULT_CA_CERT_EXP = int(round(yearsTil18Jan2038()))
DEFAULT_HTTPD_SSL_CERT_EXP = int(round(yearsTil18Jan2038()))

# for embedded database, if need be:
DEFAULT_DB_USER = 'rhnsat'
DEFAULT_DB_SID = 'rhnsat'
DEFAULT_DB_PASSWORD = 'rhnsat'
DEFAULT_DB_HOSTNAME = '127.0.0.1'
DEFAULT_DB_PORT = "1521"
DEFAULT_DB_DATA_PATH = '/%s' % DEFAULT_DB_SID

# for the bootstrap script generator
DEFAULT_APACHE_PUB_DIRECTORY = '/var/www/html/pub/'
DEFAULT_BOOTSTRAP_DIRECTORY = DEFAULT_APACHE_PUB_DIRECTORY + 'bootstrap/'
DEFAULT_CLIENT_CONFIG_OVERRIDES = '%sclient-config-overrides.txt' % DEFAULT_BOOTSTRAP_DIRECTORY

# examples
EXAMPLE_HTTP_PROXY = 'my.corporate.gateway.example.com:3128'
EXAMPLE_EMAILS = 'admin@example.com, adminsSidekick@example.com'


def XXXshowOptions(options):
    """ this is useful for debuging state """
    print "XXX: OPTIONS:"
    for key in dir(options):
        keyStr = 'key: ' + key
        print keyStr, ' '*(30-len(keyStr)), 'value:', repr(getattr(options, key))


def diffFilesYN(filepath1, filepath2):
    """ 0 or 1, not different or are different.
        If there are any errors, we just let them happen (OS/IOErrors, etc).
    """

    filepath1 = cleanupAbsPath(filepath1)
    filepath2 = cleanupAbsPath(filepath2)

#    if not os.path.isfile(filepath1) or not os.path.isfile(filepath2):
#        return 1
    
    # compare sizes
    if os.stat(filepath1)[-4] != os.stat(filepath2)[-4]:
        return 1

    # compare md5sums
    if getFileMD5(filepath1) != getFileMD5(filepath2):
        return 1

    return 0


def hdrLabelCompare(hdr1, hdr2):
    """ take two RPMs and compare them for order """

    if hdr1['name'] != hdr2['name']:
        return None
    hdr1 = [hdr1['epoch'] or None, hdr1['version'], hdr1['release']]
    hdr2 = [hdr2['epoch'] or None, hdr2['version'], hdr2['release']]
    if hdr1[0]:
        hdr1[0] = str(hdr1[0])
    if hdr2[0]:
        hdr2[0] = str(hdr2[0])
    return labelCompare(hdr1, hdr2)


def rpmLabelCompare(rpmFilename1, rpmFilename2):
    """ take two RPMs and compare them for order """
    return hdrLabelCompare(get_package_header(rpmFilename1),
                           get_package_header(rpmFilename2))


def sortRPMs(rpms):
    """ inefficiently sorts a list of RPMs. They *must* exist. """

    # initially sort the best we can in reverse order should speed things up.
    rpms.sort()
    rpms.reverse()
    newrpms = []
    
    for rpm in rpms:
        if not newrpms:
            newrpms.append(rpm)
            continue
        for i in range(len(newrpms)):
            comp = rpmLabelCompare(rpm, newrpms[i])
            if comp is None:
                break
            if comp == 0 or comp == -1:
                newrpms.insert(i, rpm)
                break
            if i == len(newrpms)-1:
                newrpms.append(rpm)
    return newrpms


def sortHeaders(hdrs):
    """ inefficiently sorts a list of hdrs. NOT USED ATM """

    newhdrs = []
    for hdr in hdrs:
        if not newhdrs:
            newhdrs.append(hdr)
            continue
        for i in range(len(newhdrs)):
            comp = hdrLabelCompare(hdr, newhdrs[i])
            if comp is None:
                break
            if comp in [0, -1]:
                newhdrs.insert(i, hdr)
                break
            if i == len(newhdrs)-1:
                newhdrs.append(hdr)
    return newhdrs


def myPopen(cmd, progressCallback=None, bufferSize=16384, writeFo=None):
    """ popen-like function, that accepts execvp-style arguments too (i.e. an
        array of params, thus making shell escaping unnecessary)

        cmd can be either a string (like "ls -l /dev"), or an array of arguments
        ["ls", "-l", "/dev"]

        Returns the command's error code, a stream with stdout's contents and a 
        stream with stderr's contents

        progressCallback --> progress bar twiddler
        writeFo --> show progress to writeFo as well (e.g., sys.stdout)
    """

    popen2._cleanup()

    # If you want unbuffered, set bufsize to 0
    if type(cmd) in (types.ListType, types.TupleType):
        cmd = map(str, cmd)
    c = popen2.Popen3(cmd, capturestderr=1, bufsize=0)

    # We don't write to the child process
    c.tochild.close()

    # Create two temporary streams to hold the info from stdout and stderr
    child_out = make_temp_file("/tmp/my-popen-")
    child_err = make_temp_file("/tmp/my-popen-")

    # Map the input file descriptor with the temporary (output) one
    fd_mappings = [(c.fromchild, child_out), (c.childerr, child_err)]
    exitcode = None
    count = 1

    while 1:
        # Is the child process done?
        status = c.poll()
        if status != -1:
            if os.WIFEXITED(status):
                # Save the exit code, we still have to read from the pipes
                exitcode = os.WEXITSTATUS(status)
            elif os.WIFSIGNALED(status):
                # Some signal terminated this process
                sig = os.WTERMSIG(status)
                log_me("myPopen: terminated: Signal %s received" % sig)
                exitcode = -sig
                break
            elif os.WIFSTOPPED(status):
                # Some signal stopped this process
                sig = os.WSTOPSIG(status)
                log_me("myPopen: stopped: Signal %s received" % sig)
                exitcode = -sig
                break

        fd_set = map(lambda x: x[0], fd_mappings)
        readfds = select.select(fd_set, [], [])[0]

        for in_fd, out_fd in fd_mappings:
            if in_fd in readfds:
                # There was activity on this file descriptor
                output = os.read(in_fd.fileno(), bufferSize)
                if output:
                    # show progress
                    if progressCallback:
                        count = count + len(output)
                        progressCallback(count)

                    # log everything.
                    log_me_clean(output)

                    # show a tickmark per read:
                    if writeFo is not None:
                        writeFo.write('.')
                        writeFo.flush()

                    # write to the output buffer(s)
                    out_fd.write(output)
                    out_fd.flush()

        if exitcode is not None:
            # Child process is done
            break

    if writeFo is not None:
        writeFo.write('\n')
        writeFo.flush()

    for f_in, f_out in fd_mappings:
        f_in.close()
        f_out.seek(0, 0)

    return exitcode, child_out, child_err


def parseHttpProxyString(httpProxy):
    httpProxy = parseUrl(httpProxy)[1]
    tup = string.split(httpProxy, ':')
    if len(tup) != 2:
        raise ValueError("ERROR: invalid host:port (%s)" % httpProxy)
    try:
        int(tup[1])
    except ValueError:
        raise ValueError("ERROR: invalid host:port (%s)" % httpProxy)
    return httpProxy


_IS_EMBEDDED_DB_YN = None
def embeddedDbYN():
    """ is this the embedded version of the RHN Satellite?
        Just look for the rpm
    """

    global _IS_EMBEDDED_DB_YN
    if _IS_EMBEDDED_DB_YN is None:
        _IS_EMBEDDED_DB_YN = not not glob.glob(cleanupAbsPath('../RPMS/oracle-server*.rpm'))
    return _IS_EMBEDDED_DB_YN


def sleep(seconds, progressCallback=None, writeFo=None):
    """ generic sleep function that pokes progress bars

        progressCallback --> progress bar twiddler
        writeFo --> will write a brief message and dots if needed (e.g., sys.stdout)
    """

    seconds = float(seconds)
    smallest = 0.1
    if seconds < smallest:
        seconds = smallest

    if writeFo is not None:
        writeFo.write("* sleeping for %s seconds" % seconds)

    def bumpProgress(xxx, writeFo=writeFo):
        if writeFo is not None:
            sys.stdout.write('.')

    if progressCallback is None:
        progressCallback = bumpProgress

    # adjust the barlength to be best fit
    # probably more work than we really need
    barLength = 10
    l = barLength
    while seconds/l >= smallest:
        l = l * 5
    barLength = max(barLength, l)
    l = barLength
    while seconds/l <= smallest:
        l = l / 5
    barLength = min(barLength, l)

    sec = seconds/barLength

    total = 0
    for i in range(barLength):
        time.sleep(sec)
        total = total + sec
        progressCallback(total)
        # print ...'s anyway even if we use a GUI progress-bar:
        if progressCallback != bumpProgress:
            bumpProgress(total)
    if writeFo is not None:
        writeFo.write('\n')
        writeFo.flush()


def wrap_line(line, maxLineSize=72):
    """ wrap an entire piece of text to maxLineSize (or WS) chunks """

    def forceFit(line, maxLineSize=72):
        ret = []
        while line:
            ret.append(line[:maxLineSize])
            line = line[maxLineSize:]
        return ret

    if len(line) < maxLineSize:
        return line
    ret = []
    l = ""
    for w in string.split(line):
        if not len(l):
            l = w
            continue
        tmp = "%s %s" % (l, w)
        if len(tmp) > maxLineSize:
            ret.extend(forceFit(l))
            l = w
        else:
            l = tmp
    if len(l):
        ret.extend(forceFit(l))
    return string.join(ret, '\n')


def wrap_text(txt):
    """ wrap an entire piece of text to the \n's or to maxLineSize
        and add the appropriate \n's
    """
    
    if type(txt) != type(''):
        txt = repr(txt)

    return string.join(map(wrap_line, string.split(txt, '\n')), '\n')

    ## doing on multiple lines in order to aid in debugging
    ## the split
    #split = string.split(txt, '\n')
    ## the map
    #for i in range(len(split)):
    #    split[i] = wrap_line(split[i])
    ## the re-joining
    #return string.join(split, '\n')


def openGzippedFile(filename):
    """ Open a file for reading. File may or may not be a gzipped file.
        Returns a fileobject.
    """

    if filename[-2:] == 'gz':
        fo = gzip.open(filename, 'rb')
        try:
            fo.read(1)
        except IOError:
            # probably not a gzipped file
            pass
        else:
            # is a gzipped file return; a file object
            fo.close()
            fo = gzip.open(filename, 'rb')
            return fo
    # not a gzipped file; return a file object
    fo = open(filename, 'rb')
    return fo


class MuzzleFd:

    """ this class controls the voice of a writable file-descriptor
        mfd = MuzzleFd(fd)
        mfd.mute()
        mfd.unmute()
    """

    def __init__(self, fd):
        self._fd = fd
        self._savedfd = None

    def mute(self):
        if self._savedfd is not None:
            # already muted
            return
        filename, mapfd = maketemp('/tmp/.mapfd.')
        os.unlink(filename)
        self._savedfd = os.dup(self._fd)
        os.dup2(mapfd, self._fd)
        os.close(mapfd)

    def unmute(self):
        os.dup2(self._savedfd, self._fd)
        os.close(self._savedfd)
        self._savedfd = None

#===============================================================================
