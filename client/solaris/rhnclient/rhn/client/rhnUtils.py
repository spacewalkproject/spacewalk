#/usr/bin/python
#
# Client code for Update Agent
#
# Copyright (c) 1999--2010 Red Hat, Inc.
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
"""utility functions for rhn clients"""

import re
import os
import sys
import time
import string
import md5
import subprocess
import select
import tempfile
import urlparse

import rhnErrors
import config

from translate import _

# file used to keep track of the next time rhn_check 
# is allowed to update the package list on the server
LAST_UPDATE_FILE = os.path.normpath("%s/var/lib/rhn/dbtimestamp" % config.PREFIX)

def getPackageSearchPath():
    dir_list = []
    cfg = config.initUp2dateConfig()
    dir_list.append(cfg["storageDir"])

    dir_string = cfg["packageDir"]
    if dir_string:
        paths = string.split(dir_string, ':')
        fullpaths = []
        for path in paths:
            fullpath = os.path.normpath(os.path.abspath(os.path.expanduser(path)))
            fullpaths.append(fullpath)
    	dir_list = dir_list + fullpaths
    return dir_list

def pkgToString(pkg):
    return "%s-%s-%s" % (pkg[0], pkg[1], pkg[2])

def pkgToStringArch(pkg):
    return "%s-%s-%s.%s" % (pkg[0], pkg[1], pkg[2], pkg[4])

def pkglistToString(pkgs):
    packages = "("
    for pkg in pkgs:
	packages = packages + pkgToString(pkg) + ","
    packages = packages + ")"
    return packages

def restartUp2date():
    args = sys.argv[:]
    print _("Restarting up2date")
    os.execvp(sys.argv[0], args)
    sys.exit()
#    pid = os.fork()
#    if not pid:
#        args = sys.argv[:]
#        print _("Restarting up2date")
#        os.execvp(sys.argv[0], args)
#    if exit:
#        sys.exit()
#    os.wait()
    
    

def md5sum(fileName):
    hash = md5.new()
    
    try:
        f = open(fileName, "r")
    except:
        return ""

    fData = f.read()
    hash.update(fData)
    del fData
    f.close()
    
    hex = string.hexdigits
    md5res = ""
    for c in hash.digest():
        i = ord(c)
        md5res = md5res + hex[(i >> 4) & 0xF] + hex[i & 0xf]

    return md5res

# return a glob for your particular architecture.
def archGlob():
    if re.search("i.86", os.uname()[4]):
        return "i?86"
    elif getUnameArch() == "sparc":
        return "sparc*"
    elif getUnameArch() == "i86pc":
        return "i?86"
    else:
        return os.uname()[4]

def getProxySetting():
    cfg = config.initUp2dateConfig()
    proxy = None
    proxyHost = cfg["httpProxy"]
    # legacy for backwards compat
    if proxyHost == "":
        try:
            proxyHost = cfg["pkgProxy"]
        except:
            proxyHost = None

    if proxyHost:
        if proxyHost[:7] == "http://":
            proxy = proxyHost[7:]
        else:
            proxy = proxyHost

    return proxy

# PORTME solaris-specific
# should we return "SunOS 5.8" or "Solaris 8" here?
def getOSVersionAndRelease():
    cfg = config.initUp2dateConfig()
    if cfg["versionOverride"]:
        version = cfg["versionOverride"]
    else:
        version = os.uname()[2]

    release = os.uname()[0]
    releaseVersion = (release, version)
    return releaseVersion


def getVersion():
    release, version = getOSVersionAndRelease()

    return version

def getOSRelease():
    release, version = getOSVersionAndRelease()
    return release

def findArch():
    blip = os.uname()
    osname = blip[0]
    platform = blip[4]

    # all the solaris stuff expect uname seems to avoid saying
    # just "sparc" at all cost
    ret, outfd, errfd = my_popen(["uname", "-a"])
    out = outfd.read()
    unameparts = string.split(out)
    arch = unameparts[5]
    
    # ugh, I really dont want to implement config.guess...
    if osname == "SunOS":
        osname = "solaris"

    return "%s-%s-%s" % (arch, platform, osname)
    
def getArch():
    platformpath = os.path.normpath("%s/etc/rhn/platform" % config.PREFIX)
    if not os.access(platformpath, os.R_OK):
        return findArch()

    fd = open(platformpath, "r")
    platform = string.strip(fd.read())

    return platform

# FIXME: and again, ripped out of r-c-packages
# FIXME: ripped right out of anaconda, belongs in rhpl
def getUnameArch():
    arch = os.uname()[4]
    if (len (arch) == 4 and arch[0] == 'i' and
        arch[2:4] == "86"):
        arch = "i386"

    if arch == "i86pc":
        arch = "i386"

    if arch == "sun4m" or arch == "sun4u" or arch == "sun4v" or arch == "sparc64":
        arch = "sparc"

    if arch == "s390x":
        arch = "s390"

    return arch



def version():
    # substituted to the real version by the Makefile at installation time.
    return "@VERSION@"

def pprint_pkglist(pkglist):
    if type(pkglist) == type([]):
        foo = map(lambda a : "%s-%s-%s" % (a[0],a[1],a[2]), pkglist)
    else:
        foo = "%s-%s-%s" % (pkglist[0], pkglist[1], pkglist[2])
    return foo


def my_popen(cmd):
    c = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                 stderr=subprocess.PIPE, close_fds=True, bufsize=0)

    # We don't write to the child process 
    c.stdin.close()

    child_out = tempfile.TemporaryFile()
    child_err = tempfile.TemporaryFile()

    # Map the input file descriptor with the temporary (output) one
    fd_mappings = [(c.stdout, child_out), (c.stderr, child_err)]

    buffer_size = 16384

    exitcode = None
    while 1:
        status = c.poll()
        if status is not None:
            if status >= 0:
                # Save the exit code, we still have to read from the pipes
                exitcode = status
            else:
                # Some signal sent to this process
                exitcode = status
                break

        fd_set = map(lambda x: x[0], fd_mappings)
        try:
            readfds = select.select(fd_set, [], [])[0]
        except select.error:
            # XXX
            raise

        for childfd, tempfd in fd_mappings:
            if childfd in readfds:
                data = os.read(childfd.fileno(), buffer_size)
                
                if data:
                    tempfd.write(data)

        if exitcode is not None:
            # Child process is done
            break

    for childfd, tempfd in fd_mappings:
        childfd.close()
        tempfd.flush()
        tempfd.seek(0, 0)

    return exitcode, child_out, child_err


def freeDiskSpace():
    cfg = config.initUp2dateConfig()
    import statvfs

    dfInfo = os.statvfs(cfg["storageDir"])
    return long(dfInfo[statvfs.F_BAVAIL]) * (dfInfo[statvfs.F_BSIZE])

# the package DB expected to change on each RPM list change
#dbpath = "/var/lib/rpm"
#if cfg['dbpath']:
#    dbpath = cfg['dbpath']
#RPM_PACKAGE_FILE="%s/Packages" % dbpath 

def touchTimeStamp():
    try:
        file = open(LAST_UPDATE_FILE, "w+")
        file.close()
    except:
        return (0, "unable to open the timestamp file", {})
    # Never update the package list more than once every hour.
    t = time.time()
    try:
        os.utime(LAST_UPDATE_FILE, (t, t))

    except:
        return (0, "unable to set the time stamp on the time stamp file %s" % LAST_UPDATE_FILE, {})

# Parses the URL and fill in missing pieces with sensible defaults
def fix_url(url, scheme='http', path='/XMLRPC'):
    if url == None:
	return url
    uscheme, netloc, upath, params, query, fragment = urlparse.urlparse(url)
    if not netloc:
        # No schema - trying to patch it up ourselves?
        url = scheme + url
        uscheme, netloc, upath, params, query, fragment = urlparse.urlparse(url)

    if not netloc:
        raise rhnErrors.InvalidUrlError("Invalid URL %s" % url)
    if upath == '':
        upath = path
    if string.lower(scheme) not in ('http', 'https'):
        raise Exception("Unknown URL scheme %s" % scheme)
    return urlparse.urlunparse((uscheme, netloc, upath, params, query,
        fragment))
