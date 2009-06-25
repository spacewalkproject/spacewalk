# Uploading function lib
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
import struct

from rhn import rpclib
Binary = rpclib.xmlrpclib.Binary
Output = rpclib.transports.Output

# RHN imports
from common import rhn_rpm
from rhnpush import uploadLib

# Buffer size we use for copying
BUFFER_SIZE = 65536
HEADERS_PER_CALL = 25


class UploadClass:
    """ Functionality for an uploading tool """





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

        


    def copyonly(self):
        # Set the forcing factor
        self.setForce()
        # Relative directory
        self.setRelativeDir()
        # Set the count
        self.setCount()
        # set the org
        #self.setOrg()
        # set the URL
        #self.setURL()
        # set the channels
        #self.setNoChannels()
        # set the username and password
        #self.setUsernamePassword()
        # set the server
        #self.setServer()
        
        for filename in self.files:
            fileinfo = _processFile(filename,\
                                    relativeDir=self.relativeDir, source=self.options.source,\
                                    nosig=self.options.nosig)
            self.processPackage(fileinfo['nvrea'], filename) 
            
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
    (header_start, header_end) = get_header_byte_range(f);
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
            'packageSize' : size,
            'header_start' : header_start,
            'header_end' : header_end}
    if relativeDir:
        # Append the relative dir too
        hash["relativePath"] = "%s/%s" % (relativeDir,
            os.path.basename(filename))
    hash['nvrea'] = tuple(lh)
    return hash







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
