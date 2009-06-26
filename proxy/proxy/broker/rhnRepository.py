# rhnRepository.py                         - Perform local repository functions.
#-------------------------------------------------------------------------------
# This module contains the functionality for providing local packages.
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
#-------------------------------------------------------------------------------
# $Id: rhnRepository.py,v 1.92 2007/01/25 21:44:29 pvetere Exp $

## language imports
import re
import os
import time
import glob
import string
import cPickle
import types
from operator import truth

## common imports
from common import rhnRepository, log_debug, log_error, CFG, rhnFault
from common.rhnTranslate import _

## local imports
from rhn import rpclib


PKG_LIST_DIR = os.path.join(CFG.PKG_DIR, 'list')
PREFIX = "rhn"


class NotLocalError(Exception):
    pass


class Repository(rhnRepository.Repository):
    """ Proxy local package repository lookup and manipulation code. """

    def __init__(self,
      channelName, channelVersion, clientInfo,
      rhnParent=None, rhnParentXMLRPC=None, httpProxy=None, httpProxyUsername=None,
      httpProxyPassword=None, caChain=None):

        log_debug(3, channelName)
        rhnRepository.Repository.__init__(self, channelName)
        self.functions = CFG.PROXY_LOCAL_FLIST
        self.channelName = channelName
        self.channelVersion = channelVersion
        self.clientInfo = clientInfo
        self.rhnParent = rhnParent
        self.rhnParentXMLRPC = rhnParentXMLRPC
        self.httpProxy = httpProxy
        self.httpProxyUsername = httpProxyUsername
        self.httpProxyPassword = httpProxyPassword
        self.caChain = caChain

    def getPackagePath(self, pkgFilename):
        """ OVERLOADS getPackagePath in common/rhnRepository.
            Returns complete path to an RPM file.
        """

        log_debug(3, pkgFilename)
        mappingName = "package_mapping:%s:" % self.channelName
        pickledMapping = self._cacheObj(mappingName, self.channelVersion,
                                        self.__channelPackageMapping, ())

        mapping = cPickle.loads(pickledMapping)

        # If the file name has parameters, it's a different kind of package.
        # Determine the architecture requested so we can construct an 
        # appropriate filename.
        if type(pkgFilename) == types.ListType:
            arch = pkgFilename[3]
            if isSolarisArch(arch):
                pkgFilename = "%s-%s-%s.%s.pkg" % \
                    (pkgFilename[0], 
                     pkgFilename[1], 
                     pkgFilename[2], 
                     pkgFilename[3])

        if not mapping.has_key(pkgFilename):
            log_error("Package not in mapping: %s" % pkgFilename)
            raise rhnFault(17, _("Invalid RPM package requested: %s")
                                 % pkgFilename)
        filePath = "%s/%s" % (CFG.PKG_DIR, mapping[pkgFilename])
        log_debug(4, "File path", filePath)
        if not os.access(filePath, os.R_OK):
            log_debug(4, "Package not found locally: %s" % pkgFilename)
            raise NotLocalError(filePath, pkgFilename)
        return filePath


    def getSourcePackagePath(self, pkgFilename):
        """ OVERLOADS getSourcePackagePath in common/rhnRepository.
            snag src.rpm and nosrc.rpm from local repo, after ensuring 
            we are authorized to fetch it.
        """

        log_debug(3, pkgFilename)
        if pkgFilename[-8:] != '.src.rpm' and pkgFilename[-10:] != '.nosrc.rpm':
            raise rhnFault(17, _("Invalid SRPM package requested: %s")
                                 % pkgFilename)

        # Connect to the server to get an authorization for downloading this
        # package
        server = rpclib.Server(self.rhnParentXMLRPC, proxy=self.httpProxy,
                               username=self.httpProxyUsername,
                               password=self.httpProxyPassword)
        if self.caChain:
            server.add_trusted_cert(self.caChain)

        try:
            retval = server.proxy.package_source_in_channel(
                        pkgFilename, self.channelName, self.clientInfo)
        except rpclib.Fault, e:
            raise rhnFault(1000,
                    _("Error retrieving source package: %s") % str(e))
        if not retval:
            raise rhnFault(17, _("Invalid SRPM package requested: %s")
                                 % pkgFilename)

        if pkgFilename[-8:] != '.src.rpm':
            # We already know the filename ends in .src.rpm
            nvrea = parseRPMName(pkgFilename[:-8])
            nvrea.append("src")
        else:
            # We already know the filename ends in .nosrc.rpm
            # otherwise we did not pass first if in this func
            nvrea = parseRPMName(pkgFilename[:-10])
            nvrea.append("nosrc")

        filePath = computePackagePath(nvrea, source=1, prepend=PREFIX)
        filePath = "%s/%s" % (CFG.PKG_DIR, filePath)
        log_debug(4, "File path", filePath)
        if not os.access(filePath, os.R_OK):
            log_debug(4, "Source package not found locally: %s" % pkgFilename)
            raise NotLocalError(filePath, pkgFilename)
        return filePath

    def _cacheObj(self, fileName, version, dataProducer, params=None):
        """ The real workhorse for all flavors of listall
            It tries to pull data out of a file; if it doesn't work,
            it calls the data producer with the specified params to generate
            the data, which is also cached.

            Returns a string from a cache file or, if the cache file is not
            there, calls dataProducer to generate the object and caches the
            results
        """

        log_debug(4, fileName, version, params)
        fileDir = self._getPkgListDir()
        filePath = "%s/%s-%s" % (fileDir, fileName, version)
        if os.access(filePath, os.R_OK):
            # Slurp the file
            f = open(filePath, "r")
            data = f.read()
            f.close()
            return data

        # The file's not there; query the DB or whatever dataproducer used.
        if not params:
            stringObject = dataProducer()
        else:
            stringObject = apply(dataProducer, params)
        # Cache the thing
        cache(stringObject, fileDir, fileName, version)
        # Return the string
        return stringObject

    def _getPkgListDir(self):
        """ Creates and returns the directory for cached lists of packages.
            Used by _cacheObj.

            XXX: Problem exists here. If PKG_LIST_DIR can't be created
            due to ownership... this is bad... need to fix.
        """

        log_debug(3, PKG_LIST_DIR)
        if not os.access(PKG_LIST_DIR, os.R_OK | os.X_OK):
            os.makedirs(PKG_LIST_DIR)
        return PKG_LIST_DIR

    def __channelPackageMapping(self):
        """ fetch package list on behalf of the client """

        log_debug(6, self.rhnParentXMLRPC, self.httpProxy, self.httpProxyUsername, self.httpProxyPassword)
        log_debug(6, self.clientInfo)
        server = rpclib.GETServer(self.rhnParentXMLRPC, proxy=self.httpProxy,
            username=self.httpProxyUsername, password=self.httpProxyPassword,
            headers=self.clientInfo)
        if self.caChain:
            server.add_trusted_cert(self.caChain)

        packageList = listPackages(server.listAllPackages, self.channelName,
                                   self.channelVersion)

        # Hash the list
        _hash = {}
        for package in packageList:
            arch = package[4]

            extension = "rpm"
            if isSolarisArch(arch):
                extension = "pkg"

            filename = "%s-%s-%s.%s.%s" % (package[0], package[1],
                package[2], package[4], extension)
            filePath = computePackagePath(package, source=0, prepend=PREFIX)
            _hash[filename] = filePath

        if CFG.DEBUG>4:
            log_debug(5, "Mapping: %s[...snip snip...]%s" % (str(_hash)[:40], str(_hash)[-40:]))
        return cPickle.dumps(_hash, 1)

def isSolarisArch(arch):
    """
    Returns true if the given arch string represents a solaris architecture.
    """
    return arch.find("solaris") != -1

def listPackages(function, channel, version):
    """ Generates a list of objects by calling the function """

    try:
        return function(channel, version)
    except rpclib.ProtocolError, e:
        errcode, errmsg = rpclib.reportError(e.headers)
        raise rhnFault(1000, "RHN Proxy error (rpclib.ProtocolError): "
                             "errode=%s; errmsg=%s" % (errcode, errmsg))


def computePackagePath(nvrea, source=0, prepend=""):
    """ Finds the appropriate path, prepending something if necessary """
    name = nvrea[0]
    release = nvrea[2]

    if source:
        dirarch = 'SRPMS'
        pkgarch = 'src'
    else:
        dirarch = pkgarch = nvrea[4]

    extension = "rpm"
    if isSolarisArch(pkgarch):
        extension = "pkg"

    version = nvrea[1]
    epoch = nvrea[3]
    if epoch not in [None, '']:
        version = str(epoch) + ':' + version
    template = prepend + "/%s/%s-%s/%s/%s-%s-%s.%s.%s"
    # Sanitize the path: remove duplicated /
    template = string.join(filter(truth, string.split(template, '/')), '/')
    return template % (name, version, release, dirarch, name, nvrea[1],
        release, pkgarch, extension)



# reg exp for splitting package names.
re_rpmName = re.compile("^(.*)-([^-]*)-([^-]*)$")
def parseRPMName(pkgName):
    """ IN:  Package string in, n-n-n-v.v.v-r.r_r, format.
        OUT: Four strings (in a list): name, release, version, epoch.
    """

    reg = re_rpmName.match(pkgName)
    if reg == None:
        return [None, None, None, None]
    n, v, r = reg.group(1,2,3)
    e = ""
    ind = string.find(r, ':')
    if ind < 0: # no epoch
        return [str(n), str(v), str(r), str(e)]
    e = r[ind+1:]
    r = r[0:ind]
    return [str(n), str(v), str(r), str(e)]


def cache(stringObject, dir, filename, version):
    """ Caches stringObject into a file and removes older files """

    # The directory should be readable, writable, seekable
    if not os.access(dir, os.R_OK | os.W_OK | os.X_OK):
        os.makedirs(dir)
    filePath = "%s/%s-%s" % (dir, filename, version)
    # Create a temp file based on the filename, version and stuff
    tempfile = "%s-%.20f" % (filePath, time.time())
    # Try to create the temp file
    tries = 10
    while tries > 0:
        # Try to create this new file
        try:
            fd = os.open(tempfile, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 
                0644)
        except OSError, e:
            if e.errno == 17:
                # File exists; give it another try
                tries = tries - 1
                tempfile = tempfile + "%.20f" % time.time()
                continue
            # Another error
            raise e
        else:
            # We've got the file; everything's nice and dandy
            break
    else:
        # Could not create the file
        raise Exception("Could not create the file")
    # Write the object into the cache
    os.write(fd, stringObject)
    os.close(fd)
    # Now rename the temp file
    os.rename(tempfile, filePath)
    # Expire the cached copies
    _list = glob.glob("%s/%s-*" % (dir, filename))
    for _file in _list:
        if _file < filePath:
            # Older than this
            os.unlink(_file)

