#
# Copyright (c) 2008--2017 Red Hat, Inc.
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

# system imports
import os
import sys
import fnmatch
import getpass

# imports
# pylint: disable=F0401,E0611

# exceptions
# pylint: disable=W0702,W0703

import inspect
from spacewalk.common import rhn_mpm
from spacewalk.common.rhn_pkg import package_from_filename, get_package_header
from spacewalk.common.usix import raise_with_tb
from up2date_client import rhnserver
from rhn.i18n import sstr
from rhnpush import rhnpush_cache

if sys.version_info[0] == 3:
    import xmlrpc.client as xmlrpclib
else:
    import xmlrpclib

try:
    from rhn import rpclib # pylint: disable=C0412
    Binary = rpclib.xmlrpclib.Binary
    Output = rpclib.transports.Output
except ImportError:
    # old-style xmlrpclib library
    rpclib = xmlrpclib
    Binary = rpclib.Binary
    # pylint: disable=F0401
    import cgiwrap
    Output = cgiwrap.Output

# Buffer size we use for copying
BUFFER_SIZE = 65536
HEADERS_PER_CALL = 25

# Exception class


class UploadError(Exception):
    pass


class ServerFault(Exception):

    def __init__(self, faultCode=None, faultString="", faultExplanation=""):
        Exception.__init__(self)
        self.faultCode = faultCode
        self.faultString = faultString
        self.faultExplanation = faultExplanation


class UploadClass:

    """Functionality for an uploading tool
    """

    def __init__(self, options, files=None):
        self.options = options
        self.username = None
        self.password = None
        self.proxy = None
        self.proxyUsername = None
        self.proxyPassword = None
        self.ca_chain = None
        self.force = None
        self.files = files or []
        self.new_sat = None
        self.url = None
        self.channels = None
        self.count = None
        self.server = None
        self.session = None
        self.orgId = None
        self.relativeDir = None
        self.use_session = True
        self.use_checksum_paths = False

    def warn(self, verbose, *args):
        if self.options.verbose >= verbose:
            ReportError(*args)

    @staticmethod
    def die(errcode, *args):
        ReportError(*args)
        # pkilambi:bug#176358:this should exit with error code
        sys.exit(errcode)

    def setURL(self):
        # Redefine this in derived classes
        self.url = None

    def setUsernamePassword(self):
        # Use the stored values, if available
        username = self.username or self.options.username
        password = self.password or self.options.password
        self.username, self.password = getUsernamePassword(username, password)

    def setProxyUsernamePassword(self):
        self.proxyUsername = None
        self.proxyPassword = None

    def setCAchain(self):
        self.ca_chain = self.options.ca_chain

    def setProxy(self):
        if self.options.proxy is None or self.options.proxy == '':
            self.proxy = None
        else:
            self.proxy = "http://%s" % self.options.proxy

    def setForce(self):
        self.force = None

    def setServer(self):
        # set the proxy
        self.setProxy()

        if self.proxy is None:
            self.warn(1, "Connecting to %s" % self.url)
        else:
            self.warn(1, "Connecting to %s (via proxy '%s')" % (self.url, self.proxy))

        # set the CA chain
        self.setCAchain()
        # set the proxy username and password
        self.setProxyUsernamePassword()
        self.server = getServer(self.url, self.proxy, self.proxyUsername,
                                self.proxyPassword, self.ca_chain)
        # Compress the output, just to be fast
        self.server.set_transport_flags(
            transfer=Output.TRANSFER_BINARY,
            encoding=Output.ENCODE_GZIP)

    def setChannels(self):
        if not self.options.channel:
            self.die(-1, "No channel was specified")
        self.channels = self.options.channel
        self.warn(1, "Channels: %s" % ' '.join(self.channels))

    setNoChannels = setChannels

    def setOrg(self):
        self.orgId = -1

    def setCount(self):
        if not self.options.count:
            self.count = HEADERS_PER_CALL
        else:
            self.count = self.options.count

    def setRelativeDir(self):
        self.relativeDir = None

    def directory(self):
        self.warn(2, "Uploading files from directory", self.options.dir)

        for filename in listdir(self.options.dir):
            # only add packages
            if filename[-3:] in ("rpm", "mpm"):
                self.files.append(filename)

    def filter_excludes(self):
        if not self.options.exclude:
            return self
        for f in self.files[:]:
            bf = os.path.basename(f)
            for pattern in self.options.exclude:
                if fnmatch.fnmatch(bf, pattern):
                    self.warn(1, "Ignoring %s" % f)
                    self.files.remove(f)
        return self

    def readStdin(self):
        self.warn(1, "Reading package names from stdin")
        self.files = self.files + readStdin()

    def _listChannelSource(self):
        if self.use_session:
            return listChannelSourceBySession(self.server,
                                              self.session.getSessionString(),
                                              self.channels)

        return listChannelSource(self.server,
                                 self.username, self.password,
                                 self.channels)

    def _listChannel(self):
        if self.use_session:
            if self.use_checksum_paths:
                return listChannelChecksumBySession(self.server,
                                                    self.session.getSessionString(), self.channels)

            return listChannelBySession(self.server,
                                        self.session.getSessionString(),
                                        self.channels)

        if self.use_checksum_paths:
            return listChannelChecksum(self.server,
                                       self.username, self.password,
                                       self.channels)

        return listChannel(self.server,
                           self.username, self.password,
                           self.channels)

    def list(self):
        # set the URL
        self.setURL()
        # set the channels
        self.setChannels()
        # set the server
        self.setServer()

        self.authenticate()

        if self.options.source:
            channel_list = self._listChannelSource()
        else:
            # List the channel's contents
            channel_list = self._listChannel()

        for p in channel_list:
            print(p[:6])

    def newest(self):
        # set the URL
        self.setURL()
        # set the channels
        self.setChannels()
        # set the server
        self.setServer()

        self.authenticate()

        sources = self.options.source

        if sources:
            return self.get_missing_source_packages()

        return self.get_newest_binary_packages()

    def get_newest_binary_packages(self):
        # Loop through the args and only keep the newest ones
        localPackagesHash = {}
        for filename in self.files:
            nvrea = self._processFile(filename, nosig=1)['nvrea']
            name = nvrea[0]
            if name not in localPackagesHash:
                localPackagesHash[name] = {nvrea: filename}
                continue

            same_names_hash = localPackagesHash[name]
            # Already saw this name
            if nvrea in same_names_hash:
                # Already seen this nvrea
                continue
            skip_rpm = 0
            for local_nvrea in same_names_hash.keys():
                # XXX is_mpm should be set accordingly
                ret = packageCompare(local_nvrea, nvrea,
                                     is_mpm=0)
                if ret == 0 and local_nvrea[4] == nvrea[4]:
                    # Weird case, we've already compared the two
                    skip_rpm = 1
                    break

                if ret > 0:
                    # nvrea is older than local_nvrea
                    skip_rpm = 1
                    break

                if ret < 0:
                    # nvrea is newer than local_nvrea
                    del same_names_hash[local_nvrea]

                # Different arches - go on

            if skip_rpm:
                # Older
                continue

            same_names_hash[nvrea] = filename

        # Now get the list from the server
        pkglist = self._listChannel()

        for p in pkglist:
            name = p[0]
            if name not in localPackagesHash:
                # Not in the local list
                continue
            same_names_hash = localPackagesHash[name]
            remote_nvrea = tuple(p[:5])
            if remote_nvrea in same_names_hash:
                # The same package is already uploaded
                del same_names_hash[remote_nvrea]
                continue

            for local_nvrea in list(same_names_hash.keys()):
                # XXX is_mpm sould be set accordingly
                ret = packageCompare(local_nvrea, remote_nvrea,
                                     is_mpm=0)
                if ret < 0:
                    # The remote package is newer than the local one
                    del same_names_hash[local_nvrea]
                    continue
                if ret == 0 and local_nvrea[4] == remote_nvrea[4]:
                    # Same arch
                    del same_names_hash[local_nvrea]
                    continue
                # This means local is newer

        # Return the list of files to push
        l = []
        for fhash in localPackagesHash.values():
            for filename in fhash.values():
                l.append(filename)
        l.sort()
        self.files = l

    def _listMissingSourcePackages(self):
        if self.use_session:
            return listMissingSourcePackagesBySession(self.server,
                                                      self.session.getSessionString(), self.channels)

        return listMissingSourcePackages(self.server,
                                         self.username, self.password, self.channels)

    def get_missing_source_packages(self):
        localPackagesHash = {}
        for filename in self.files:
            localPackagesHash[os.path.basename(filename)] = filename

        # Now get the list from the server
        pkglist = self._listMissingSourcePackages()

        to_push = []
        for pkg in pkglist:
            pkg_name, _pkg_channel = pkg[:2]
            if pkg_name not in localPackagesHash:
                # We don't have it
                continue
            to_push.append(localPackagesHash[pkg_name])

        to_push.sort()
        self.files = to_push
        return self.files

    def test(self):
        # Test only
        for p in self.files:
            print(p)

    def _get_files(self):
        return self.files[:]

    def _uploadSourcePackageInfo(self, info):
        if self.use_session:
            return call(self.server.packages.uploadSourcePackageInfoBySession,
                        self.session.getSessionString(), info)

        return call(self.server.packages.uploadSourcePackageInfo,
                    self.username, self.password, info)

    def _uploadPackageInfo(self, info):
        if self.use_session:
            return call(self.server.packages.uploadPackageInfoBySession,
                        self.session.getSessionString(), info)

        return call(self.server.packages.uploadPackageInfo,
                    self.username, self.password, info)

    def uploadHeaders(self):
        # Set the forcing factor
        self.setForce()
        # Relative directory
        self.setRelativeDir()
        # Set the count
        self.setCount()
        # set the org
        self.setOrg()
        # set the URL
        self.setURL()
        # set the channels
        self.setNoChannels()

        # set the server
        self.setServer()

        self.authenticate()

        source = self.options.source
        file_list = self._get_files()

        while file_list:
            chunk = file_list[:self.count]
            del file_list[:self.count]
            uploadedPackages, headersList = self._processBatch(chunk,
                                                               relativeDir=self.relativeDir, source=self.options.source,
                                                               verbose=self.options.verbose, nosig=self.options.nosig)

            if not headersList:
                # Nothing to do here...
                continue

            # Send the big hash
            info = {'packages': headersList}
            if self.orgId > 0 or self.orgId == '':
                info['orgId'] = self.orgId

            if self.force:
                info['force'] = self.force

            if self.channels:
                info['channels'] = self.channels

            # Some feedback
            if self.options.verbose:
                ReportError("Uploading batch:")
                for p in list(uploadedPackages.values())[0]:
                    ReportError("\t\t%s" % p)

            if source:
                ret = self._uploadSourcePackageInfo(info)
            else:
                ret = self._uploadPackageInfo(info)

            if ret is None:
                self.die(-1, "Upload attempt failed")

            # Append the package information
            alreadyUploaded, newPackages = ret
            pkglists = (alreadyUploaded, newPackages)

            for idx, item in enumerate(pkglists):
                for p in item:
                    key = tuple(p[:5])
                    if key not in uploadedPackages:
                        # XXX Hmm
                        self.warn(1, "XXX XXX %s" % str(p))
                    filename, checksum = uploadedPackages[key]
                    # Some debugging
                    if self.options.verbose:
                        if idx == 0:
                            pattern = "Already uploaded: %s"
                        else:
                            pattern = "Uploaded: %s"
                        print(pattern % filename)
                    # Per-package post actions
                    # For backwards-compatibility with old spacewalk-proxy
                    try:
                        self.processPackage(p, filename, checksum)
                    except TypeError:
                        self.processPackage(p, filename)

    def processPackage(self, package, filename, checksum=None):
        pass

    def checkSession(self, session):
        return call(self.server.packages.check_session, session)

    def readSession(self):
        # pylint: disable=W0703
        try:
            self.session = rhnpush_cache.RHNPushSession()
            self.session.readSession()
        except Exception:
            self.session = None

    def writeSession(self, session):
        if self.session:
            self.session.setSessionString(session)
        else:
            self.session = rhnpush_cache.RHNPushSession()
            self.session.setSessionString(session)

        if not self.options.no_session_caching:
            self.session.writeSession()

    def authenticate(self):
        # Only use the session token stuff if we're talking to a sat that supports session-token authentication.
        self.readSession()
        if self.session and not self.options.new_cache and self.options.username == self.username:
            chksession = self.checkSession(self.session.getSessionString())
            if chksession:
                return
        self.setUsernamePassword()
        sessstr = call(self.server.packages.login, self.username, self.password)
        self.writeSession(sessstr)

        # set whether we should use checksum paths or not (if upstream supports
        # it we should).
        self.use_checksum_paths = hasChannelChecksumCapability(self.server)

    @staticmethod
    def _processFile(filename, relativeDir=None, source=None, nosig=None):
        """ Processes a file
            Returns a hash containing:
              header
              packageSize
              checksum
              relativePath
              nvrea
         """

        # Is this a file?
        if not os.access(filename, os.R_OK):
            raise UploadError("Could not stat the file %s" % filename)
        if not os.path.isfile(filename):
            raise UploadError("%s is not a file" % filename)

        # Size
        size = os.path.getsize(filename)

        try:
            a_pkg = package_from_filename(filename)
            a_pkg.read_header()
            a_pkg.payload_checksum()
            assert a_pkg.header
        except:
            raise_with_tb(UploadError("%s is not a valid package" % filename), sys.exc_info()[2])

        if nosig is None and not a_pkg.header.is_signed():
            raise UploadError("ERROR: %s: unsigned rpm (use --nosig to force)"
                              % filename)

        # Get the name, version, release, epoch, arch
        lh = []
        for k in ['name', 'version', 'release', 'epoch']:
            if k == 'epoch' and not a_pkg.header[k]:
            # Fix the epoch
                lh.append(sstr(""))
            else:
                lh.append(sstr(a_pkg.header[k]))

        if source:
            lh.append('src')
        else:
            lh.append(sstr(a_pkg.header['arch']))

        # Build the header hash to be sent
        info = {'header': Binary(a_pkg.header.unload()),
                'checksum_type': a_pkg.checksum_type,
                'checksum': a_pkg.checksum,
                'packageSize': size,
                'header_start': a_pkg.header_start,
                'header_end': a_pkg.header_end}
        if relativeDir:
            # Append the relative dir too
            info["relativePath"] = "%s/%s" % (relativeDir,
                                              os.path.basename(filename))
        info['nvrea'] = tuple(lh)
        return info

    def _processBatch(self, batch, relativeDir, source, verbose, nosig=None):
        sentPackages = {}
        headersList = []
        for filename in batch:
            if verbose:
                print("Uploading %s" % filename)
            info = self._processFile(filename, relativeDir=relativeDir, source=source,
                                     nosig=nosig)
            # Get nvrea
            nvrea = info['nvrea']
            del info['nvrea']

            sentPackages[nvrea] = (filename, info['checksum'])

            # Append the header to the list of headers to be sent out
            headersList.append(info)
        return sentPackages, headersList


def readStdin():
    # Reads the standard input lines and returns a list
    l = []
    while 1:
        line = sys.stdin.readline()
        if not line:
            break
        l.append(line.strip())
    return l


def getUsernamePassword(cmdlineUsername, cmdlinePassword):
    # Returns a username and password (either by returning the ones passed as
    # args, or the user's input
    if cmdlineUsername and cmdlinePassword:
        return cmdlineUsername, cmdlinePassword

    username = cmdlineUsername
    password = cmdlinePassword

    # Read the username, if not already specified
    tty = open("/dev/tty", "w")
    tty.write("Username: ")
    tty.close()
    tty = open("/dev/tty", "r")

    while not username:
        try:
            username = tty.readline()
        except KeyboardInterrupt:
            tty.write("\n")
            sys.exit(0)
        if username is None:
            # EOF
            tty.write("\n")
            sys.exit(0)
        username = username.strip()
        if username:
            break

    # Now read the password
    while not password:
        try:
            password = getpass.getpass("Password: ")
        except KeyboardInterrupt:
            tty.write("\n")
            sys.exit(0)
        tty.close()
    return username, password


def listdir(directory):
    directory = os.path.abspath(os.path.normpath(directory))
    if not os.access(directory, os.R_OK | os.X_OK):
        raise UploadError("Cannot read from directory %s" % directory)
    if not os.path.isdir(directory):
        raise UploadError("%s not a directory" % directory)
    # Build the package list
    packagesList = []
    for f in os.listdir(directory):
        packagesList.append("%s/%s" % (directory, f))
    return packagesList


def call(function, *params, **kwargs):
    # Wrapper function
    try:
        ret = function(*params)
    except xmlrpclib.Fault:
        e = sys.exc_info()[1]
        x = parseXMLRPCfault(e)
        if x.faultString:
            print(x.faultString)
        if x.faultExplanation:
            print(x.faultExplanation)
        sys.exit(-1)
    except xmlrpclib.ProtocolError:
        e = sys.exc_info()[1]
        if kwargs.get('raise_protocol_error'):
            raise
        print(e.errmsg)
        sys.exit(-1)

    return ret


def parseXMLRPCfault(fault):
    if not isinstance(fault, xmlrpclib.Fault):
        return None
    faultCode = fault.faultCode
    if faultCode and isinstance(faultCode, type(1)):
        faultCode = -faultCode
    return ServerFault(faultCode, "", fault.faultString)

# pylint: disable=C0103


def listChannel(server, username, password, channels):
    return call(server.packages.listChannel, channels, username, password)


def listChannelChecksum(server, username, password, channels):
    return call(server.packages.listChannelChecksum, channels, username,
                password)


def listChannelBySession(server, session_string, channels):
    return call(server.packages.listChannelBySession, channels, session_string)


def listChannelChecksumBySession(server, session_string, channels):
    return call(server.packages.listChannelChecksumBySession, channels,
                session_string)


def listChannelSource(server, username, password, channels):
    return call(server.packages.listChannelSource, channels, username, password)


def listChannelSourceBySession(server, session_string, channels):
    return call(server.packages.listChannelSourceBySession, channels, session_string)


def listMissingSourcePackages(server, username, password, channels):
    return call(server.packages.listMissingSourcePackages, channels, username, password)


def listMissingSourcePackagesBySession(server, session_string, channels):
    return call(server.packages.listMissingSourcePackagesBySession, channels, session_string)


def getPackageChecksumBySession(server, session_string, info):
    return call(server.packages.getPackageChecksumBySession, session_string, info)


def getSourcePackageChecksumBySession(server, session_string, info):
    return call(server.packages.getSourcePackageChecksumBySession, session_string, info)


def getSourcePackageChecksum(server, username, password, info):
    return call(server.packages.getSourcePackageChecksum, username, password, info)

# for backward compatibility with satellite <5.4.0


def getPackageMD5sumBySession(server, session_string, info):
    return call(server.packages.getPackageMD5sumBySession, session_string, info)


def getSourcePackageMD5sumBySession(server, session_string, info):
    return call(server.packages.getSourcePackageMD5sumBySession, session_string, info)


def getServer(uri, proxy=None, username=None, password=None, ca_chain=None):
    s = rpclib.Server(uri, proxy=proxy, username=username, password=password)
    if ca_chain:
        s.add_trusted_cert(ca_chain)
    return s

# pylint: disable=E1123
def hasChannelChecksumCapability(rpc_server):
    """ check whether server supports getPackageChecksumBySession function"""
    # pylint: disable=W1505
    if 'rpcServerOverride' in inspect.getargspec(rhnserver.RhnServer.__init__)[0]:
        server = rhnserver.RhnServer(rpcServerOverride=rpc_server)
    else:
        server = rhnserver.RhnServer()
        # pylint: disable=W0212
        server._server = rpc_server
    return server.capabilities.hasCapability('xmlrpc.packages.checksums')


def exists_getPackageChecksumBySession(rpc_server):
    """ check whether server supports getPackageChecksumBySession function"""
    # unfortunatelly we do not have capability for getPackageChecksumBySession function,
    # but extended_profile in version 2 has been created just 2 months before
    # getPackageChecksumBySession lets use it instead
    # pylint: disable=W1505
    if 'rpcServerOverride' in inspect.getargspec(rhnserver.RhnServer.__init__)[0]:
        server = rhnserver.RhnServer(rpcServerOverride=rpc_server)
    else:
        server = rhnserver.RhnServer()
        # pylint: disable=W0212
        server._server = rpc_server
    return server.capabilities.hasCapability('xmlrpc.packages.extended_profile', 2)

# compare two package [n,v,r,e] tuples


def packageCompare(pkg1, pkg2, is_mpm=None):
    if pkg1[0] != pkg2[0]:
        raise ValueError("You should only compare packages with the same name")
    packages = []
    for pkg in (pkg1, pkg2):
        e = pkg[3]
        if e == "":
            e = None
        elif e is not None:
            e = str(e)
        evr = (e, str(pkg[1]), str(pkg[2]))
        packages.append(evr)
    if is_mpm:
        func = rhn_mpm.labelCompare
    else:
        from spacewalk.common import rhn_rpm
        func = rhn_rpm.labelCompare
    return func(packages[0], packages[1])


# returns a header from a package file on disk.
def get_header(filename, fildes=None, source=None):
    try:
        h = get_package_header(filename=filename, fd=fildes)
    except:
        raise_with_tb(UploadError("Package is invalid"), sys.exc_info()[2])

    # Verify that this is indeed a binary/source. xor magic
    # xor doesn't work with None values, so compare the negated values - the
    # results are identical
    if (not source) ^ (not h.is_source):
        raise UploadError("Unexpected RPM package type")
    return h


def ReportError(*args):
    sys.stderr.write(' '.join(map(str, args)) + "\n")
