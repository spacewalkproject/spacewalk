#
# Abstraction for an XML importer with a disk base
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

import os
import gzip
import string
from spacewalk.common.fileutils import createPath


class MissingXmlDiskSourceFileError(Exception):
    pass
class MissingXmlDiskSourceDirError(Exception):
    pass


class DiskSource:
    subdir = None
    # Allow for compressed files by default
    allow_compressed_files = 1
    def __init__(self, mountPoint):
        self.mountPoint = mountPoint

    # Returns a data stream
    def load(self):
        # Returns a stream
        filename = self._getFile()
        return self._loadFile(filename)

    def _getFile(self, create=0):
        # Virtual
        return None

    def _loadFile(self, filename):
        # Look for a gzip file first
        if self.allow_compressed_files:
            if filename[-3:] == '.gz' and os.path.exists(filename):
                return gzip.open(filename, "rb")

            if os.path.exists(filename + '.gz'):
                return gzip.open(filename + ".gz", "rb")

        if os.path.exists(filename):
            return open(filename, "r")

        raise MissingXmlDiskSourceFileError("unable to process file %s" % filename)

    def _getDir(self, create=0):
        dirname = "%s/%s" % (self.mountPoint, self.subdir)
        if not create:
            return dirname
        if not os.path.exists(dirname):
            createPath(dirname, logging=0)
        if not os.path.isdir(dirname):
            raise MissingXmlDiskSourceDirError("%s is not a directory" % dirname)
        return dirname


class ArchesDiskSource(DiskSource):
    subdir = 'arches'
    filename = 'arches.xml'

    def _getFile(self, create=0):
        dirname = self._getDir(create)
        if create and not os.path.isdir(dirname):
            createPath(dirname, logging=0)
        return os.path.join(dirname, self.filename)

class ArchesExtraDiskSource(ArchesDiskSource):
    filename = "arches-extra.xml"

class ProductnamesDiskSource(DiskSource):
    subdir = 'product_names'

    def _getFile(self, create=0):
        dirname = self._getDir(create)
        if create and not os.path.isdir(dirname):
            createPath(dirname, logging=0)
        return "%s/product_names.xml" % dirname



class ChannelFamilyDiskSource(DiskSource):
    subdir = 'channel_families'

    def _getFile(self, create=0):
        dirname = self._getDir(create)
        if create and not os.path.isdir(dirname):
            createPath(dirname, logging=0)
        return "%s/channel_families.xml" % dirname


class ChannelDiskSource(DiskSource):
    subdir = 'channels'

    def __init__(self, mountPoint):
        DiskSource.__init__(self, mountPoint)
        self.channel = None

    def setChannel(self, channel):
        self.channel = channel

    def list(self):
        # Lists the available channels
        dirname = self._getDir(create=0)
        if not os.path.isdir(dirname):
            # No channels available
            return []
        return os.listdir(dirname)

    def _getFile(self, create=0):
        dirname = "%s/%s" % (self._getDir(create), self.channel)
        if create and not os.path.isdir(dirname):
            createPath(dirname, logging=0)
        return os.path.join(dirname, self._file_name())

    def _file_name(self):
        return "channel.xml"


class ChannelCompsDiskSource(ChannelDiskSource):

    def _file_name(self):
        return "comps.xml"


def hashPackageId(obj_id, mod=100, padding=2):
    """Hash the package ID

    Ord each character, add 'em up, mod the result... and make
    sure there is enough padding.
    """

    # Make sure obj_id is a string
    obj_id = str(obj_id)
    # Get the last numeric part out of this package
    obj_id = obj_id[string.rfind(obj_id, '-') + 1:]
    try:
        obj_id = long(obj_id)
    except ValueError:
        # No numbers at the end, add all the values for the string
        obj_id = reduce(lambda x,y: x+y, map(long, map(ord, obj_id)))
    obj_id = obj_id % mod
    format = "%%0%sd" % padding
    # Map the id to the hash/format
    return format % obj_id
    

class ShortPackageDiskSource(DiskSource):
    subdir = "packages_short"

    def __init__(self, mountPoint):
        DiskSource.__init__(self, mountPoint)
        # Package ID
        self.id = None
        self._file_suffix = ".xml"

    def setID(self, id):
        self.id = id

    # limited dict behaviour
    def has_key(self, id):
        # Save the old id
        old_id = self.id
        self.id = id
        f = self._getFile()
        # Restore the old id
        self.id = old_id
        if os.path.exists(f + '.gz') or os.path.exists(f):
            return 1
        return 0
        
    def _getFile(self, create=0):
        dirname = "%s/%s" % (self._getDir(create), self._hashID())
        # Create the directoru if we have to
        if create and not os.path.exists(dirname):
            createPath(dirname, logging=0)
        return "%s/%s%s" % (dirname, self.id, self._file_suffix)

    def _hashID(self):
        # Hashes the package name
        return hashPackageId(self.id, mod=100, padding=2)

class PackageDiskSource(ShortPackageDiskSource):
    subdir = "packages"

class SourcePackageDiskSource(ShortPackageDiskSource):
    subdir = "source_packages"

class ErrataDiskSource(ShortPackageDiskSource):
    subdir = "errata"

    def _hashID(self):
        # Hashes the erratum name
        return hashPackageId(self.id, mod=10, padding=1)

class BlacklistsDiskSource(DiskSource):
    subdir = "blacklists"

    def _getFile(self, create=0):
        dirname = self._getDir(create)
        if create and not os.path.isdir(dirname):
            createPath(dirname, logging=0)
        return "%s/blacklists.xml" % dirname

class BinaryRPMDiskSource(ShortPackageDiskSource):
    subdir = "rpms"

    def __init__(self, mountPoint):
        ShortPackageDiskSource.__init__(self, mountPoint)
        self._file_suffix = '.rpm'

class SourceRPMDiskSource(BinaryRPMDiskSource):
    subdir = "srpms"

class KickstartDataDiskSource(DiskSource):
    subdir = "kickstart_trees"

    def __init__(self, mountPoint):
        DiskSource.__init__(self, mountPoint)
        self.id = None

    def setID(self, ks_label):  
        self.id = ks_label

    def _getFile(self, create=0):
        dirname = self._getDir(create)
        if create and not os.path.isdir(dirname):
            createPath(dirname, logging=0)
        return os.path.join(dirname, self.id) + '.xml'

class KickstartFileDiskSource(KickstartDataDiskSource):
    subdir = "kickstart_files"
    allow_compressed_files = 0

    def __init__(self, mountPoint):
        KickstartDataDiskSource.__init__(self, mountPoint)
        # the file's relative path
        self.relative_path = None

    def set_relative_path(self, relative_path):
        self.relative_path = relative_path

    def _getFile(self, create=0):
        path = os.path.join(self._getDir(create), self.id,
            self.relative_path)
        dirname = os.path.dirname(path)
        if create and not os.path.isdir(dirname):
            createPath(dirname, logging=0)
        return path

if __name__ == '__main__':
    # TEST CODE
    s = ChannelDiskSource("/tmp")
    print s.list()
    s.setChannel("redhat-linux-i386-7.2")
    print s.load()

