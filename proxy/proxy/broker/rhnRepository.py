# rhnRepository.py                         - Perform local repository functions.
#-------------------------------------------------------------------------------
# This module contains the functionality for providing local packages.
#
# Copyright (c) 2008--2015 Red Hat, Inc.
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

## language imports
import os
import time
import glob
import cPickle
import sys
import types
from operator import truth
import xmlrpclib

## common imports
from spacewalk.common.rhnLib import parseRPMName
from spacewalk.common.rhnLog import log_debug
from spacewalk.common.rhnException import rhnFault
from spacewalk.common.rhnConfig import CFG
from spacewalk.common import rhnRepository
from spacewalk.common.rhnTranslate import _

## local imports
from rhn import rpclib


PKG_LIST_DIR = os.path.join(CFG.PKG_DIR, 'list')
PREFIX = "rhn"


class NotLocalError(Exception):
    pass


class Repository(rhnRepository.Repository):
    # pylint: disable=R0902

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

    def getPackagePath(self, pkgFilename, redirect=0):
        """ OVERLOADS getPackagePath in common/rhnRepository.
            Returns complete path to an RPM file.
        """

        log_debug(3, pkgFilename)
        mappingName = "package_mapping:%s:" % self.channelName
        mapping = self._cacheObj(mappingName, self.channelVersion,
                                 self.__channelPackageMapping, ())

        # If the file name has parameters, it's a different kind of package.
        # Determine the architecture requested so we can construct an
        # appropriate filename.
        if isinstance(pkgFilename, types.ListType):
            arch = pkgFilename[3]
            # Not certain if anything is needed here for Debian, but since what I've tested
            # works.   Leave it alone.
            if isSolarisArch(arch):
                pkgFilename = "%s-%s-%s.%s.pkg" % \
                    (pkgFilename[0],
                     pkgFilename[1],
                     pkgFilename[2],
                     pkgFilename[3])

        if not mapping.has_key(pkgFilename):
            log_debug(3, "Package not in mapping: %s" % pkgFilename)
            raise NotLocalError
        # A list of possible file paths. Always a list, channel mappings are
        # cleared on package upgrade so we don't have to worry about the old
        # behavior of returning a string
        filePaths = mapping[pkgFilename]
        # Can we see a file at any of the possible filepaths?
        for filePath in filePaths:
            filePath = "%s/%s" % (CFG.PKG_DIR, filePath)
            log_debug(4, "File path", filePath)
            if os.access(filePath, os.R_OK):
                return filePath
        log_debug(4, "Package not found locally: %s" % pkgFilename)
        raise NotLocalError(filePaths[0], pkgFilename)

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
        except xmlrpclib.Fault, e:
            raise rhnFault(1000,
                           _("Error retrieving source package: %s") % str(e)), None, sys.exc_info()[2]
        if not retval:
            raise rhnFault(17, _("Invalid SRPM package requested: %s")
                           % pkgFilename)

        if pkgFilename[-8:] != '.src.rpm':
            # We already know the filename ends in .src.rpm
            nvrea = list(parseRPMName(pkgFilename[:-8]))
            nvrea.append("src")
        else:
            # We already know the filename ends in .nosrc.rpm
            # otherwise we did not pass first if in this func
            nvrea = list(parseRPMName(pkgFilename[:-10]))
            nvrea.append("nosrc")

        filePaths = computePackagePaths(nvrea, source=1, prepend=PREFIX)
        for filePath in filePaths:
            filePath = "%s/%s" % (CFG.PKG_DIR, filePath)
            log_debug(4, "File path", filePath)
            if os.access(filePath, os.R_OK):
                return filePath
        log_debug(4, "Source package not found locally: %s" % pkgFilename)
        raise NotLocalError(filePaths[0], pkgFilename)

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
            try:
                # Slurp the file
                f = open(filePath, "r")
                data = f.read()
                f.close()
                stringObject = cPickle.loads(data)
                return stringObject
            except (IOError, cPickle.UnpicklingError): # corrupted cache file
                pass # do nothing, we'll fetch / write it again

        # The file's not there; query the DB or whatever dataproducer used.
        if params is None:
            params = ()
        stringObject = dataProducer(*params)
        # Cache the thing
        cache(cPickle.dumps(stringObject, 1), fileDir, fileName, version)
        # Return the string
        return stringObject

    @staticmethod
    def _getPkgListDir():
        """ Creates and returns the directory for cached lists of packages.
            Used by _cacheObj.

            XXX: Problem exists here. If PKG_LIST_DIR can't be created
            due to ownership... this is bad... need to fix.
        """

        log_debug(3, PKG_LIST_DIR)
        if not os.access(PKG_LIST_DIR, os.R_OK | os.X_OK):
            os.makedirs(PKG_LIST_DIR)
        return PKG_LIST_DIR

    def _listPackages(self):
        """ Generates a list of objects by calling the function """
        server = rpclib.GETServer(self.rhnParentXMLRPC, proxy=self.httpProxy,
                                  username=self.httpProxyUsername, password=self.httpProxyPassword,
                                  headers=self.clientInfo)
        if self.caChain:
            server.add_trusted_cert(self.caChain)
        return server.listAllPackagesChecksum(self.channelName,
                                              self.channelVersion)

    def __channelPackageMapping(self):
        """ fetch package list on behalf of the client """

        log_debug(6, self.rhnParentXMLRPC, self.httpProxy, self.httpProxyUsername, self.httpProxyPassword)
        log_debug(6, self.clientInfo)

        try:
            packageList = self._listPackages()
        except xmlrpclib.ProtocolError, e:
            errcode, errmsg = rpclib.reportError(e.headers)
            raise rhnFault(1000, "SpacewalkProxy error (xmlrpclib.ProtocolError): "
                           "errode=%s; errmsg=%s" % (errcode, errmsg)), None, sys.exc_info()[2]

        # Hash the list
        _hash = {}
        for package in packageList:
            arch = package[4]

            extension = "rpm"
            if isSolarisArch(arch):
                extension = "pkg"
            if isDebianArch(arch):
                extension = "deb"

            filename = "%s-%s-%s.%s.%s" % (package[0], package[1],
                                           package[2], package[4], extension)
            # if the package contains checksum info
            if len(package) > 6:
                filePaths = computePackagePaths(package, source=0,
                                                prepend=PREFIX, checksum=package[7])
            else:
                filePaths = computePackagePaths(package, source=0,
                                                prepend=PREFIX)
            _hash[filename] = filePaths

        if CFG.DEBUG > 4:
            log_debug(5, "Mapping: %s[...snip snip...]%s" % (str(_hash)[:40], str(_hash)[-40:]))
        return _hash


class KickstartRepository(Repository):

    """ Kickstarts always end up pointing to a channel that they're getting
    rpms from. Lookup what channel that is and then just use the regular
    repository """

    def __init__(self, kickstart, clientInfo, rhnParent=None,
                 rhnParentXMLRPC=None, httpProxy=None, httpProxyUsername=None,
                 httpProxyPassword=None, caChain=None, orgId=None, child=None,
                 session=None, systemId=None):
        log_debug(3, kickstart)

        self.systemId = systemId
        self.kickstart = kickstart
        self.ks_orgId = orgId
        self.ks_child = child
        self.ks_session = session

        # have to look up channel name and version for this kickstart
        # we have no equievanet to the channel version for kickstarts,
        # expire the cache after an hour
        fileName = "kickstart_mapping:%s-%s-%s-%s:" % (str(kickstart),
                                                       str(orgId), str(child), str(session))

        mapping = self._lookupKickstart(fileName, rhnParentXMLRPC, httpProxy,
                                        httpProxyUsername, httpProxyPassword, caChain)
        Repository.__init__(self, mapping['channel'], mapping['version'],
                            clientInfo, rhnParent, rhnParentXMLRPC, httpProxy,
                            httpProxyUsername, httpProxyPassword, caChain)

    def _lookupKickstart(self, fileName, rhnParentXMLRPC, httpProxy,
                         httpProxyUsername, httpProxyPassword, caChain):
        fileDir = self._getPkgListDir()
        filePath = "%s/%s-1" % (fileDir, fileName)
        mapping = None
        if os.access(filePath, os.R_OK):
            try:
                # Slurp the file
                f = open(filePath, "r")
                mapping = cPickle.loads(f.read())
                f.close()
            except (IOError, cPickle.UnpicklingError): # corrupt cached file
                mapping = None # ignore it, we'll get and write it again

        now = int(time.time())
        if not mapping or mapping['expires'] < now:
            # Can't use the normal GETServer handler because there is no client
            # to auth. Instead this is something the Proxy has to be able to
            # do, so read the serverid and send that up.
            server = rpclib.Server(rhnParentXMLRPC, proxy=httpProxy,
                                   username=httpProxyUsername, password=httpProxyPassword)
            if caChain:
                server.add_trusted_cert(caChain)
            try:
                response = self._getMapping(server)
                mapping = {'channel': str(response['label']),
                           'version': str(response['last_modified']),
                           'expires': int(time.time()) + 3600}  # 1 hour from now
            except Exception:
                # something went wrong. Punt, we just won't serve this request
                # locally
                raise NotLocalError

            # Cache the thing
            cache(cPickle.dumps(mapping, 1), fileDir, fileName, "1")

        return mapping

    def _listPackages(self):
        """ Generates a list of objects by calling the function"""
        # Can't use the normal GETServer handler because there is no client
        # to auth. Instead this is something the Proxy has to be able to do,
        # so read the serverid and send that up.
        server = rpclib.Server(self.rhnParentXMLRPC, proxy=self.httpProxy,
                               username=self.httpProxyUsername, password=self.httpProxyPassword)
        if self.caChain:
            server.add_trusted_cert(self.caChain)
        # Versionless package listing from Server. This saves us from erroring
        # unnecessarily if the channel has changed since the kickstart mapping.
        # No problem, newer channel listings will work fine with kickstarts
        # unless they have removed the kernel or something, in which case it's
        # not supposed to work.
        # Worst case scenario is that we cache listing using an older version
        # than it actually is, and the next time we serve a file from the
        # regular Repository it'll get replace with the same info but newer
        # version in filename.
        return server.proxy.listAllPackagesKickstart(self.channelName,
                                                     self.systemId)

    def _getMapping(self, server):
        """ Generate a hash that tells us what channel this
        kickstart is looking at. We have no equivalent to channel version,
        so expire the cached file after an hour."""
        if self.ks_orgId:
            return server.proxy.getKickstartOrgChannel(self.kickstart,
                                                       self.ks_orgId, self.systemId)
        elif self.ks_session:
            return server.proxy.getKickstartSessionChannel(self.kickstart,
                                                           self.ks_session, self.systemId)
        elif self.ks_child:
            return server.proxy.getKickstartChildChannel(self.kickstart,
                                                         self.ks_child, self.systemId)
        else:
            return server.proxy.getKickstartChannel(self.kickstart,
                                                    self.systemId)


class TinyUrlRepository(KickstartRepository):
    # pylint: disable=W0233,W0231

    """ TinyURL kickstarts have actually already made a HEAD request up to the
    Satellite to to get the checksum for the rpm, however we can't just use
    that data because the epoch information is not in the filename so we'd
    never find files with a non-None epoch. Instead do the same thing we do
    for non-tiny-urlified kickstarts and look up what channel it maps to."""

    def __init__(self, tinyurl, clientInfo, rhnParent=None,
                 rhnParentXMLRPC=None, httpProxy=None, httpProxyUsername=None,
                 httpProxyPassword=None, caChain=None, systemId=None):
        log_debug(3, tinyurl)

        self.systemId = systemId
        self.tinyurl = tinyurl

        # have to look up channel name and version for this kickstart
        # we have no equievanet to the channel version for kickstarts,
        # expire the cache after an hour
        fileName = "tinyurl_mapping:%s:" % (str(tinyurl))

        mapping = self._lookupKickstart(fileName, rhnParentXMLRPC, httpProxy,
                                        httpProxyUsername, httpProxyPassword, caChain)
        Repository.__init__(self, mapping['channel'], mapping['version'],
                            clientInfo, rhnParent, rhnParentXMLRPC, httpProxy,
                            httpProxyUsername, httpProxyPassword, caChain)

    def _getMapping(self, server):
        return server.proxy.getTinyUrlChannel(self.tinyurl, self.systemId)


def isSolarisArch(arch):
    """
    Returns true if the given arch string represents a solaris architecture.
    """
    return arch.find("solaris") != -1


def isDebianArch(arch):
    """
    Returns true if the given arch string represents a Debian architecture..
    """
    return arch[-4:] == "-deb"


def computePackagePaths(nvrea, source=0, prepend="", checksum=None):
    """ Finds the appropriate paths, prepending something if necessary """
    paths = []
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
    if isDebianArch(pkgarch):
        extension = "deb"

    version = nvrea[1]
    epoch = nvrea[3]
    if epoch not in [None, '']:
        version = str(epoch) + ':' + version
    # The new prefered path template avoides collisions if packages with the
    # same nevra but different checksums are uploaded. It also should be the
    # same as the /var/satellite/redhat/NULL/* paths upstream.
    # We can't reliably look up the checksum for source packages, so don't
    # use it in the source path.
    if checksum and not source:
        checksum_template = prepend + "/%s/%s/%s-%s/%s/%s/%s-%s-%s.%s.%s"
        checksum_template = '/'.join(filter(truth, checksum_template.split('/')))
        paths.append(checksum_template % (checksum[:3], name, version, release,
                                          dirarch, checksum, name, nvrea[1], release, pkgarch, extension))
    template = prepend + "/%s/%s-%s/%s/%s-%s-%s.%s.%s"
    # Sanitize the path: remove duplicated /
    template = '/'.join(filter(truth, template.split('/')))
    paths.append(template % (name, version, release, dirarch, name, nvrea[1],
                             release, pkgarch, extension))
    return paths


def cache(stringObject, directory, filename, version):
    """ Caches stringObject into a file and removes older files """

    # The directory should be readable, writable, seekable
    if not os.access(directory, os.R_OK | os.W_OK | os.X_OK):
        os.makedirs(directory)
    filePath = "%s/%s-%s" % (directory, filename, version)
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
            raise
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
    _list = glob.glob("%s/%s-*" % (directory, filename))
    for _file in _list:
        if _file < filePath:
            # Older than this
            os.unlink(_file)
