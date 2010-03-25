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

# system imports
import os
import sys
import string
import fnmatch
import getpass
import rhnpush_cache
import struct
from spacewalk.common import rhn_mpm
from spacewalk.common.checksum import getFileChecksum

try:
    from rhn import rpclib
    Binary = rpclib.xmlrpclib.Binary
    Output = rpclib.transports.Output
except ImportError:
    # old-style xmlrpclib library
    import xmlrpclib
    rpclib = xmlrpclib
    Binary = rpclib.Binary
    import cgiwrap
    Output = cgiwrap.Output

# Buffer size we use for copying
BUFFER_SIZE = 65536
HEADERS_PER_CALL = 25

# Exception class
class UploadError(Exception):
    pass

InvalidPackageError = rhn_mpm.InvalidPackageError

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
        self.new_sat = None

    def warn(self, verbose, *args):
        if self.options.verbose >= verbose:
            apply(ReportError, args)

    def die(self, errcode, *args):
        apply(ReportError, args)
        #pkilambi:bug#176358:this should exit with error code
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
        if self.options.proxy is None or self.options.proxy is '':
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
        self.warn(2, "Uploading files from directory", self.options.dir)

        for file in listdir(self.options.dir):
            # only add packages
            if file[-3:] in ("rpm", "mpm"):
                self.files.append(file)

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

    def list(self):
        # set the URL
        self.setURL()
        # set the channels
        self.setChannels()
        # set the username and password
        #self.setUsernamePassword()
        # set the server
        self.setServer()

        #XXX
        self.authenticate()

        if self.options.source:
            if self.new_sat_test():
                list = listChannelSourceBySession(self.server, self.session.getSessionString(), self.channels)
            else:
                list = listChannelSource(self.server, self.username, self.password, self.channels)
            #self.die(1, "Listing source rpms not supported")
        else:
            # List the channel's contents
            if self.new_sat_test():
                list = listChannelBySession(self.server, self.session.getSessionString(), self.channels)
            else:
                list = listChannel(self.server, self.username, self.password, self.channels)

        for p in list:
            print p[:6]

    def newest(self):
        # set the URL
        self.setURL()
        # set the channels
        self.setChannels()
        # set the username and password
        #self.setUsernamePassword()
        # set the server
        self.setServer()

        #XXX
        self.authenticate()
        
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
        if self.new_sat_test():
            pkglist = listChannelBySession(self.server, self.session.getSessionString(), self.channels)
        else:
            pkglist = listChannel(self.server, self.username, self.password, self.channels)

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
        if self.new_sat_test():
            pkglist = listMissingSourcePackagesBySession(self.server, self.session.getSessionString(), self.channels)
        else:
            pkglist = listMissingSourcePackages(self.server, self.username, self.password, self.channels)

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

        # set the server
        self.setServer()
        
        #XXX
        self.authenticate()
        
        source = self.options.source
        file_list = self.files[:]        

        while file_list:
            chunk = file_list[:self.count]
            del file_list[:self.count]
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
                if self.new_sat_test():
                    method = self.server.packages.uploadSourcePackageInfoBySession
                else:
                    method = self.server.packages.uploadSourcePackageInfo
            else:
                if self.new_sat_test():
                    method = self.server.packages.uploadPackageInfoBySession
                else:
                    method = self.server.packages.uploadPackageInfo

            if self.new_sat_test():
                ret = call(method, self.session.getSessionString(), hash)
            else:
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

    #12/22/05 wregglej 173287 This calls the XMLRPC function that checks whether or not the
    #current session is still valid.
    def checkSession(self, session):
        return call(self.server.packages.check_session, session)

    #12/22/05 wregglej 173287 Reads the cached session string from ~/.rhnpushcache and 
    #configures a session object with it.
    def readSession(self):
        try:
            self.session = rhnpush_cache.RHNPushSession()
            self.session.readSession()
        except Exception, e:
            self.session = None

    #12/22/05 wregglej 173287 Writes the session to ~/.rhnpushcache and configures makes sure the
    #session object is configured with it.
    def writeSession(self, session):
        if self.session:
            self.session.setSessionString(session)
        else:
            self.session = rhnpush_cache.RHNPushSession()
            self.session.setSessionString(session)
      
        if not self.options.no_cache:
            self.session.writeSession()

    #12/22 wregglej 173287 The actual authenication process. It reads in the session, checks the sessions validity,
    #and will prompt the user for their username and password if there's something wrong with their session string.
    #After they've entered their username/password, they are passed to the new XMLRPC call 'login', which will 
    #verify the user/pass and return a new session string if they are correct.
    #Need to fix this up so there's less repeated code.
    # 2008-09-26 mmraka - 461701: if --username is set use always username/password
    # and generate new session
    def authenticate(self):
        #Only use the session token stuff if we're talking to a sat that supports session-token authentication.
        if self.new_sat_test():
            self.readSession()
            if self.session and not self.options.new_cache and self.options.username == self.username:
                chksession = self.checkSession(self.session.getSessionString())
                if not chksession:
                    self.setUsernamePassword()
                    sessstr = call(self.server.packages.login, self.username, self.password)
                    self.writeSession(sessstr)
            else:
                self.setUsernamePassword()
                sessstr = call(self.server.packages.login, self.username, self.password)
                self.writeSession(sessstr)
        else:
            self.setUsernamePassword()

    #1/3/06 wregglej 173287 rhnpush needs to work against older satellites, so we need a way to see if they can handle
    #session token authentication
    def new_sat_test(self):
        if self.new_sat is None:
            if self.options.no_session_caching:
                self.new_sat = 0 
            else:
                self.new_sat = 1
                try:
                    self.server.packages.no_op()
                except:
                    self.new_sat = 0
        return self.new_sat     
 
        

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
    # Open the file
    f = open(filename, "r")
    # Read the header
    h = get_header(None, f.fileno(), source)
    (header_start, header_end) = get_header_byte_range(f);
    # Rewind the file
    f.seek(0, 0)
    # Compute digest
    checksum_type = h.checksum_type()
    checksum = getFileChecksum(checksum_type, file=f)
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
            'checksum_type' : checksum_type,
            'checksum' : checksum,
            'packageSize' : size,
            'header_start' : header_start,
            'header_end' : header_end}
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
    while not password:
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

def listChannelBySession(server, session_string, channels): 
    return call(server.packages.listChannelBySession, channels, session_string)

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

def getPackageChecksum(server, username, password, info):
    return call(server.packages.getPackageChecksum, username, password, info)

def getSourcePackageChecksum(server, username, password, info):
    return call(server.packages.getSourcePackageChecksum, username, password, info)


def getServer(uri, proxy=None, username=None, password=None, ca_chain=None):
    s = rpclib.Server(uri, proxy=proxy, username=username, password=password)
    if ca_chain:
        s.add_trusted_cert(ca_chain)
    return s


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
def get_header(file, fildes=None, source=None):
    # rhn_mpm.get_package_header will choose the right thing to do - open the
    # file or use the provided open file descriptor)
    h = rhn_mpm.get_package_header(filename=file, fd=fildes)
        
    # Verify that this is indeed a binary/source. xor magic
    # xor doesn't work with None values, so compare the negated values - the
    # results are identical
    if (not source) ^ (not h.is_source):
        raise UploadError("Unexpected RPM package type")
    return h

def ReportError(*args):
    sys.stderr.write(string.join(map(str, args)) + "\n")

def get_header_byte_range(package_file):
    """
    Return the start and end bytes of the rpm header object.

    For details of the rpm file format, see:
    http://www.rpm.org/max-rpm/s1-rpm-file-format-rpm-file-format.html
    """

    lead_size = 96

    # Move past the rpm lead
    package_file.seek(lead_size)

    sig_size = get_header_struct_size(package_file)

    # Now we can find the start of the actual header.
    header_start = lead_size + sig_size

    package_file.seek(header_start)

    header_size = get_header_struct_size(package_file)

    header_end = header_start + header_size

    return (header_start, header_end)

def get_header_struct_size(package_file):
    """
    Compute the size in bytes of the rpm header struct starting at the current
    position in package_file.
    """
    # Move past the header preamble
    package_file.seek(8, 1)

    # Read the number of index entries
    header_index = package_file.read(4)
    (header_index_value, ) = struct.unpack('>I', header_index)

    # Read the the size of the header data store
    header_store = package_file.read(4)
    (header_store_value, ) = struct.unpack('>I', header_store)

    # The total size of the header. Each index entry is 16 bytes long.
    header_size = 8 + 4 + 4 + header_index_value * 16 + header_store_value

    # Headers end on an 8-byte boundary. Round out the extra data.
    round_out = header_size % 8
    if round_out != 0:
        header_size = header_size + (8 - round_out)

    return header_size
