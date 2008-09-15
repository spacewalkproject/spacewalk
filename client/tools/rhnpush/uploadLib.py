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

# system imports
import os
import sys
import md5
import string
import fnmatch
import getpass

from rhn import rpclib
Binary = rpclib.xmlrpclib.Binary
Output = rpclib.transports.Output

# RHN imports
from common import rhn_rpm


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

    """ Functionality for an uploading tool """

    def __init__(self, options, files=None):
        #CmdlineClass.__init__(self, table, argsDescription, aliasing)
        self.options = options
        self.username = None
        self.password = None
        self.proxy = None
        self.proxyUsername = None
        self.proxyPassword = None
        self.ca_chain = None
        self.force = None
        self.files = files or []

    def warn(self, verbose, *args):
        if self.options.verbose >= verbose:
            apply(ReportError, args)

    def die(self, errcode, *args):
        apply(ReportError, args)
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
        self.ca_chain = None

    def setProxy(self):
        self.proxy = None

    def setForce(self):
        self.force = None

    def setServer(self):
        self.warn(1, "Connecting to %s" % self.url)
        # set the proxy
        self.setProxy()
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
        self.warn(1, "Channels: %s" % string.join(self.channels))

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
        # Set the args (pretend we read them from the command line)
        self.warn(2, "Uploading files from directory", self.options.dir)
        self.files = listdir(self.options.dir)

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
        self.files = readStdin()

    def list(self):
        # set the URL
        self.setURL()
        # set the channels
        self.setChannels()
        # set the username and password
        self.setUsernamePassword()
        # set the server
        self.setServer()

        if self.options.source:
            self.die(1, "Listing source rpms not supported")
        else:
            # List the channel's contents
            list = listChannel(self.server, self.username, self.password,
                self.channels)
        for p in list:
            print p[:6]

    def newest(self):
        # set the URL
        self.setURL()
        # set the channels
        self.setChannels()
        # set the username and password
        self.setUsernamePassword()
        # set the server
        self.setServer()
        
        sources = self.options.source

        if sources:
            return self.get_missing_source_packages()

        return self.get_newest_binary_packages()

        
    def get_newest_binary_packages(self):
        # Loop through the args and only keep the newest ones
        localPackagesHash = {}
        for filename in self.files:
            nvrea = _processFile(filename, nosig=1)['nvrea']
            name = nvrea[0]
            if not localPackagesHash.has_key(name):
                localPackagesHash[name] = {nvrea : filename}
                continue

            same_names_hash = localPackagesHash[name]
            # Already saw this name
            if same_names_hash.has_key(nvrea):
                # Already seen this nvrea
                continue
            skip_rpm = 0
            for local_nvrea in same_names_hash.keys():
                ret = packageCompare(local_nvrea, nvrea)
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
        pkglist = listChannel(self.server, self.username, self.password,
            self.channels)

        for p in pkglist:
            name = p[0]
            if not localPackagesHash.has_key(name):
                # Not in the local list
                continue
            same_names_hash = localPackagesHash[name]
            remote_nvrea = tuple(p[:5])
            if same_names_hash.has_key(remote_nvrea):
                # The same package is already uploaded
                del same_names_hash[remote_nvrea]
                continue

            for local_nvrea in same_names_hash.keys():
                ret = packageCompare(local_nvrea, remote_nvrea)
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
        for hash in localPackagesHash.values():
            for filename in hash.values():
                l.append(filename)
        l.sort()
        self.files = l

    def get_missing_source_packages(self):
        localPackagesHash = {}
        for filename in self.files:
            localPackagesHash[os.path.basename(filename)] = filename
        
        # Now get the list from the server
        pkglist = listMissingSourcePackages(self.server, self.username, 
            self.password, self.channels)

        to_push = []
        for pkg in pkglist:
            pkg_name, pkg_channel = pkg[:2]
            if not localPackagesHash.has_key(pkg_name):
                # We don't have it
                continue
            to_push.append(localPackagesHash[pkg_name])

        to_push.sort()
        self.files = to_push
        return self.files

    def test(self):
        # Test only
        for p in self.files:
            print p

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
        # set the username and password
        self.setUsernamePassword()
        # set the server
        self.setServer()

        source = self.options.source

        while self.files:
            chunk = self.files[:self.count]
            del self.files[:self.count]
            uploadedPackages, headersList = _processBatch(chunk,
                relativeDir=self.relativeDir, source=self.options.source, 
                verbose=self.options.verbose, nosig=self.options.nosig)

            if not headersList:
                # Nothing to do here...
                continue

            # Send the big hash
            hash = {'packages' : headersList}
            if self.orgId > 0 or self.orgId == '':
                hash['orgId'] = self.orgId

            if self.force:
                hash['force'] = self.force

            if self.channels:
                hash['channels'] = self.channels

            # Some feedback
            if self.options.verbose:
                ReportError("Uploading batch:")
                for p in uploadedPackages.values():
                    ReportError("\t\t%s" % p)

            if source:
                method = self.server.packages.uploadSourcePackageInfo
            else:
                method = self.server.packages.uploadPackageInfo

            ret = call(method, self.username, self.password, hash)
            if ret is None:
               self.die(-1, "Upload attempt failed")

            # Append the package information
            alreadyUploaded, newPackages = ret
            pkglists = (alreadyUploaded, newPackages)

            for idx in range(len(pkglists)):
                for p in pkglists[idx]:
                    key = tuple(p[:5])
                    if not uploadedPackages.has_key(key):
                        # XXX Hmm
                        self.warn("XXX XXX %s" % str(p))
                    filename = uploadedPackages[key]
                    # Some debugging
                    if self.options.verbose:
                        if idx == 0:
                            pattern = "Already uploaded: %s"
                        else:
                            pattern = "Uploaded: %s"
                        print pattern % filename
                    # Per-package post actions
                    self.processPackage(p, filename)

    def processPackage(self, package, filename):
        pass


def _processFile(filename, relativeDir=None, source=None, nosig=None):
    """ Processes a file
        Returns a hash containing:
          header
          packageSize
          md5sum
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
    # Open the file
    f = open(filename, "r")
    digest = computeMD5sum(None, f)
    # Rewind the file
    f.seek(0, 0)
    # Read the header
    h = get_header(None, f.fileno(), source)
    f.close()
    if h is None:
        raise UploadError("%s is not a valid RPM file" % filename)

    if nosig is None and not h.is_signed():
        raise UploadError("ERROR: %s: unsigned rpm (use --nosig to force)"
            % filename)

    # Get the name, version, release, epoch, arch
    lh = []
    for k in ['name', 'version', 'release', 'epoch']:
        lh.append(h[k])
    # Fix the epoch
    if lh[3] is None:
        lh[3] = ""
    else:
        lh[3] = str(lh[3])

    if source:
        lh.append('src')
    else:
        lh.append(h['arch'])

    # Build the header hash to be sent
    hash = { 'header' : Binary(h.unload()),
            'md5sum' : digest,
            'packageSize' : size}
    if relativeDir:
        # Append the relative dir too
        hash["relativePath"] = "%s/%s" % (relativeDir,
            os.path.basename(filename))
    hash['nvrea'] = tuple(lh)
    return hash

def _processBatch(batch, relativeDir, source, verbose, nosig=None):
    sentPackages = {}
    headersList = []
    for filename in batch:
        if verbose:
            print "Uploading %s" % filename
        hash = _processFile(filename, relativeDir=relativeDir, source=source, 
            nosig=nosig)
        # Get nvrea
        nvrea = hash['nvrea']
        del hash['nvrea']

        sentPackages[nvrea] = filename

        # Append the header to the list of headers to be sent out
        headersList.append(hash)
    return sentPackages, headersList

def computeMD5sum(filename=None, f=None):
    if f is None:
        fd = open(filename, "r")
    else:
        fd = f
        fd.seek(0, 0)
    md5sum = md5.new()
    while 1:
        buf = fd.read(BUFFER_SIZE)
        if not buf:
            break
        md5sum.update(buf)
    if not f:
        fd.close()
    return string.join(map(lambda x: "%02x" % ord(x), md5sum.digest()), '')


def readStdin():
    # Reads the standard input lines and returns a list
    l = []
    while 1:
        line = sys.stdin.readline()
        if not line:
            break
        l.append(string.strip(line))
    return l


def getUsernamePassword(cmdlineUsername, cmdlinePassword):
    # Returns a username and password (either by returning the ones passed as
    # args, or the user's input
    if cmdlineUsername and cmdlinePassword:
        return cmdlineUsername, cmdlinePassword

    username = cmdlineUsername
    password = cmdlinePassword

    # Read the username, if not already specified
    tty = open("/dev/tty", "r+")
    while not username:
        tty.write("Red Hat Network username: ")
        try:
            username = tty.readline()
        except KeyboardInterrupt:
                tty.write("\n")
                sys.exit(0)
        if username is None:
            # EOF
            tty.write("\n")
            sys.exit(0)
        username = string.strip(username)
        if username:
            break

    # Now read the password
    try:
        password = getpass.getpass("Red Hat Network password: ")
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


def call(function, *params):
    # Wrapper function
    try:
        ret = apply(function, params)
    except rpclib.Fault, e:
        x = parseXMLRPCfault(e)
        if x.faultString:
            print x.faultString
        if x.faultExplanation:
            print x.faultExplanation
        sys.exit(-1)
    except rpclib.ProtocolError, e:
        print e.errmsg
        sys.exit(-1)

    return ret


def parseXMLRPCfault(fault):
    if not isinstance(fault, rpclib.Fault):
        return None
    faultCode = fault.faultCode
    if faultCode and isinstance(faultCode, type(1)):
        faultCode = -faultCode
    return ServerFault(faultCode, "", fault.faultString)


def listChannel(server, username, password, channels):
    return call(server.packages.listChannel, channels, username, password)

def listMissingSourcePackages(server, username, password, channels):
    return call(server.packages.listMissingSourcePackages, channels,
        username, password)

def getServer(uri, proxy=None, username=None, password=None, ca_chain=None):
    s = rpclib.Server(uri, proxy=proxy, username=username, password=password)
    if ca_chain:
        s.add_trusted_cert(ca_chain)
    return s


# compare two package [n,v,r,e] tuples
def packageCompare(pkg1, pkg2):
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
    return rhn_rpm.labelCompare(packages[0], packages[1])


# returns a header from a package file on disk.
def get_header(file, fildes=None, source=None):
    # rhn_rpm.get_package_header will choose the right thing to do - open the
    # file or use the provided open file descriptor)
    try:
        h = rhn_rpm.get_package_header(filename=file, fd=fildes)
    except rhn_rpm.InvalidPackageError:
        raise UploadError("Package is invalid")
    # Verify that this is indeed a binary/source. xor magic
    # xor doesn't work with None values, so compare the negated values - the
    # results are identical
    if (not source) ^ (not h.is_source):
        raise UploadError("Unexpected RPM package type")
    return h


def ReportError(*args):
    sys.stderr.write(string.join(map(str, args)) + "\n")

