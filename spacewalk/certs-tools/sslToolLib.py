#
# Copyright (c) 2008--2010 Red Hat, Inc.
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
# rhn-ssl-tool general library
#
# $Id$

## language imports
import os
import re
import sys
import string
import shutil
import tempfile
from timeLib import DAY, now, secs2days, secs2years, secs2str, \
                    str2secs
from spacewalk.common.fileutils import cleanupAbsPath, rhn_popen

class RhnSslToolException(Exception):
    """ general exception class for the tool """

errnoGeneralError = 1
errnoSuccess = 0


def fixSerial(serial):
    """ fixes a serial number this may be wrongly formatted """

    if not serial:
        serial = '00'

    if string.find(serial, '0x') == -1:
        serial = '0x'+serial

    # strip the '0x' if present
    serial = string.split(serial, 'x')[-1]

    # the string might have a trailing L
    serial = string.replace(serial, 'L', '')

    # make sure the padding is correct
    # if odd number of digits, pad with a 0
    # e.g., '100' --> '0100'
    if len(serial)/2.0 != len(serial)/2:
        serial = '0'+serial

    return serial


def incSerial(serial):
    """ increment a serial hex number """

    if not serial:
        serial = '00'

    if string.find(serial, '0x') == -1:
        serial = '0x'+serial

    serial = eval(serial) + 1
    serial = hex(serial)

    serial = string.split(serial, 'x')[-1]
    return fixSerial(serial)


def getMachineName(hostname):
    """ xxx.yyy.zzz.com --> xxx.yyy
        yyy.zzz.com     --> yyy
        zzz.com         --> zzz.com
        xxx             --> xxx
        *.yyy.zzz.com   --> _star_.yyy
    """
    hn = string.split(hostname.replace('*', '_star_'), '.')
    if len(hn) < 3:
        return hostname
    return string.join(hn[:-2], '.')

#
# NOTE: the Unix epoch overflows at: 2038-01-19 03:14:07 (2^31 seconds)
#

def secsTil18Jan2038():
    """ (int) secs til 1 day before the great 32-bit overflow
        We are making it 1 day just to be safe.
    """
    return int(2L**31 - 1) - now() - DAY

def daysTil18Jan2038():
    "(float) days til 1 day before the great 32-bit overflow"
    return secs2days(secsTil18Jan2038())

def yearsTil18Jan2038():
    "(float) approximate years til 1 day before the great 32-bit overflow"
    return secs2years(secsTil18Jan2038())


def gendir(directory):
    "makedirs, but only if it doesn't exist first"
    if not os.path.exists(directory):
        try:
            os.makedirs(directory, 0700)
        except OSError, e:
            print "Error: %s" % (e, )
            sys.exit(1)

def chdir(newdir):
    "chdir with the previous cwd as the return value"
    cwd = os.getcwd()
    os.chdir(newdir)
    return cwd


class TempDir:

    """ temp directory class with a cleanup destructor and method """
    
    _shutil = shutil # trying to hang onto shutil during garbage collection

    def __init__(self, suffix='-rhn-ssl-tool'):
        "create a temporary directory in /tmp"

        if string.find(suffix, '/') != -1:
            raise ValueError("suffix cannot be a path, only a name")

        # add some quick and dirty randomness to the tempfilename
        s = ''
        while len(s) < 10:
            s = s + str(ord(os.urandom(1)))
        self.path = tempfile.mkdtemp(suffix='-'+s+suffix)

    def getdir(self):
        return self.path
    getpath = getdir

    def __del__(self):
        """ delete temporary directory when done with it """
        self._shutil.rmtree(self.path)

    close = __del__
        

# next two functions orgininally stolen/adapted from backend/server/rhnLib.py

# reg exp for splitting package names.
re_rpmName = re.compile("^(.*)-([^-]*)-([^-]*)$")
def parseRPMName(pkgName):
    """ 'n-n-n-v.v.v-r.r_r' --> (name, release, version, epoch) """

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
    """ 'n_n-n-v.v.v-r_r.r:e.ARCH.rpm' --> [n,v,r,e,a]
        IN: Package Name: xxx-yyy-ver.ver.ver-rel.rel_rel:e.ARCH.rpm (string)
        Understood rules:
           o Name can have nearly any char, but end in a - (well seperated by).
             Any character; may include - as well.
           o Version cannot have a -, but ends in one.
           o Release should be an actual number, and can't have any -'s.
           o Release can include the Epoch, e.g.: 2:4 (4 is the epoch)
           o Epoch: Can include anything except a - and the : seperator???
             XXX: Is epoch info above correct?
        OUT: [n,v,r,e, arch].
    """

    pkgFilename = os.path.basename(pkgFilename)
    pkg = string.split(pkgFilename, '.')
    if string.lower(pkg[-1]) != 'rpm':
	raise ValueError('not an rpm package name: %s' % pkgFilename)
    _arch = pkg[-2]
    pkg = string.join(pkg[:-2], '.')
    ret = list(parseRPMName(pkg))
    if ret:
        ret.append(_arch)
    return  ret


#===============================================================================

