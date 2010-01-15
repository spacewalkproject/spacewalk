#!/usr/bin/python
#
# Copyright (c) 2008--2009 Red Hat, Inc.
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
# Common data structures used throughout the import code
#

import os
from types import IntType, StringType, InstanceType
from UserDict import UserDict
from UserList import UserList

from common import log_debug

from server.rhnLib import get_package_path
from spacewalk.common import rhn_mpm
from spacewalk.common.checksum import getFileChecksum
from spacewalk.common.fileutils import maketemp, createPath, setPermsPath

# no-op class, used to define the type of an attribute
class DateType:
    pass


# An Item is just an extension for a dictionary
class Item(UserDict):
    """
    First level object, that stores information in a hash-like structure
    """
    def __init__(self, attributes=None):
        UserDict.__init__(self, attributes)

    def populate(self, hash):
        self.update(hash)
        return self

    def __repr__(self):
        return "[<%s instance; attributes=%s]" % (str(self.__class__), 
            str(self.data))

# BaseInformation is an Item with a couple of other features (an id, an ignored
# flag, diff information)
class BaseInformation(Item):
    """
    Second level object. It may contain composite items as attributes
    """
    def __init__(self, dict=None):
        Item.__init__(self, dict)
        # Initialize attributes 
        for k in dict.keys():
            self[k] = None
        # Each information object has an id (which is set by the database)
        self.id = None
        # If the information is ignored (non-critical)
        self.ignored = None
        # Diff with the object already installed
        self.diff = None
        # Same as above, except that it doesn't get cleared if the upload was
        # forced
        self.diff_result = None

    def toDict(self):
        dict = {
            'ignored'   : not not self.ignored,
            'diff'      : self.diff.toDict(),
        }
        return dict

# This class is handy for reducing code duplication
class Information(BaseInformation):
    attributeTypes = {}
    def __init__(self):
        BaseInformation.__init__(self, self.attributeTypes)

# Function that validates the insertion of items in a Collection
def validateInformation(obj):
    if not isinstance(obj, BaseInformation):
        if isinstance(obj, InstanceType):
            strtype = "instance of %s" % obj.__class__
        else:
            strtype = str(type(obj))
        raise TypeError("Expected an Information object; got %s" % strtype)


# A list with the needed functions to validate what gets put in it
class Collection(UserList):
    def __init__(self, list=None):
        if list:
            for obj in list:
                validateInformation(obj)
        UserList.__init__(self, list)

    def __setitem__(self, i, item):
        validateInformation(item)
        UserList.__setitem__(self, i, item)

    def append(self, item):
        validateInformation(item)
        UserList.append(self, item)

    add = append

    def insert(self, i, item):
        validateInformation(item)
        UserList.insert(self, i, item)

    def extend(self, other):
        for obj in other:
            validateInformation(obj)
        UserList.extend(self, other)

    def __setslice__(self, i, j, other):
        for obj in other:
            validateInformation(obj)
        UserList.__setslice__(self, i, j, other)

    def __add__(self, other):
        for obj in other:
            validateInformation(obj)
        UserList.__add__(self, other)
        
    def __radd__(self, other):
        for obj in other:
            validateInformation(obj)
        UserList.__radd__(self, other)

    def __repr__(self):
        return "[<%s instance; items=%s]" % (str(self.__class__), 
            str(self.data))


# Import classes
# XXX makes sense to put this in a different file
class ChannelFamily(Information):
    attributeTypes = {
        'name'              : StringType,
        'label'             : StringType,
        'product_url'       : StringType,
        'channels'          : [StringType],
    }

class ChannelFamilyPermissions(Information):
    attributeTypes = {
        'channel_family'    : StringType,
        'org_id'            : IntType,
        'max_members'       : IntType,
    }

class DistChannelMap(Information):
    attributeTypes = {
        'os'                : StringType,
        'release'           : StringType,
        'channel_arch'      : StringType,
        'channel'           : StringType,
    }

class ReleaseChannelMap(Information):
    attributeTypes = {
        'product'           : StringType,
        'version'           : StringType,
        'release'           : StringType,
        'channel_arch_id'   : IntType,
        'channel_id'        : IntType
    }


class ChannelErratum(Information):
    attributeTypes = {
        'id'                : StringType,
        'advisory_name'     : StringType,
        'last_modified'     : DateType,
    }

class IncompleteSourcePackage(Information):
    attributeTypes = {
        'id'                : StringType,
        'source_rpm'        : StringType,
        'last_modified'     : DateType,
    }

class Channel(Information):
    attributeTypes = {
        'label'             : StringType,
        'org_id'            : IntType,
        'channel_arch'      : StringType,
        'parent_channel'    : StringType,
        'name'              : StringType,
        'summary'           : StringType,
        'description'       : StringType,
        'last_modified'     : DateType,
        'gpg_key_url'       : StringType,
        'product_name_id'   : IntType,
        'channel_product_id': IntType,
        'receiving_updates' : StringType,
        'checksum_type'     : StringType,       # xml dumps >= 3.5
        # XXX Not really useful stuff
        'basedir'           : StringType,
        'product_name'      : StringType,
        'product_version'   : StringType,
        'product_beta'      : StringType,
        # Families this channel is subscribed to
        'families'          : [ChannelFamily],
        'packages'          : [StringType],
        'source_packages'   : [IncompleteSourcePackage],
        'all-packages'      : [StringType],
        'dists'             : [DistChannelMap],
        'release'           : [ReleaseChannelMap],
        'errata'            : [StringType],
        'errata_timestamps' : [ChannelErratum],
        'kickstartable_trees'   : [StringType],
    }


class File(Item):
    attributeTypes = {
        'name'              : StringType,
        'device'            : IntType,
        'inode'             : IntType,
        'file_mode'         : IntType,
        'username'          : StringType,
        'groupname'         : StringType,
        'rdev'              : IntType,
        'file_size'         : IntType,
        'mtime'             : DateType,
        'linkto'            : StringType,
        'flags'             : IntType,
        'verifyflags'       : IntType,
        'lang'              : StringType,
        # those attributes are mutualy exclusive
        'md5sum'            : StringType,       # xml dumps < 3.5
        'checksum'          : StringType,       # xml dumps >= 3.5
        'checksum_type'     : StringType,       # xml dumps >= 3.5
    }
    def __init__(self):
        Item.__init__(self, self.attributeTypes)


class Dependency(Item):
    attributeTypes = {
        'name'              : StringType,
        'version'           : StringType,
        'flags'             : IntType,
    }
    def __init__(self):
        Item.__init__(self, self.attributeTypes)


class ChangeLog(Item):
    attributeTypes = {
        'name'              : StringType,
        'text'              : StringType,
        'time'              : DateType,
    }
    def __init__(self):
        Item.__init__(self, self.attributeTypes)


class IncompletePackage(BaseInformation):
    attributeTypes = {
        'package_id'        : StringType, # RH db id
        'name'              : StringType,
        'epoch'             : StringType,
        'version'           : StringType,
        'release'           : StringType,
        'arch'              : StringType,
        'org_id'            : IntType,
        'package_size'      : IntType,
        'last_modified'     : DateType,
        # those attributes are mutualy exclusive
        'md5sum'            : StringType,       # xml dumps < 3.5
        'checksum'          : StringType,       # xml dumps >= 3.5
        'checksum_type'     : StringType,       # xml dumps >= 3.5
        # These attributes are lists of objects
        'channels'          : [StringType],
    }
    def __init__(self):
        BaseInformation.__init__(self, IncompletePackage.attributeTypes)
        self.name = None
        self.evr = None
        self.arch = None
        self.org_id = None

    def toDict(self):
        dict = BaseInformation.toDict(self)
        evr = list(self.evr)
        if evr[0] is None:
            evr[0] = ''

        dict['name'] = self.name
        dict['evr'] = evr
        dict['arch'] = self.arch

        org_id = self.org_id
        if org_id is None:
            org_id = ''
        dict['org_id'] = org_id
        return dict

    def short_str(self):
        return "%s-%s-%s.%s.rpm" % (self.name, self.evr[1], self.evr[2],
            self.arch)

    def get_nevrao(self):
        return (self.name, self['name'], self['epoch'], self['version'],
            self['release'], self['arch'], self['org_id'])

class Package(IncompletePackage):
    """
    A package is a hash of attributes
    """
    attributeTypes = {
        'description'       : StringType,
        'summary'           : StringType,
        'license'           : StringType,
        'package_group'     : StringType,
        'rpm_version'       : StringType,
        'payload_size'      : IntType,
        'payload_format'    : StringType,
        'build_host'        : StringType,
        'build_time'        : DateType,
        'cookie'            : StringType,
        'vendor'            : StringType,
        'source_rpm'        : StringType,
        'package_size'      : IntType,
        'last_modified'     : DateType,
        'sigpgp'            : StringType,
        'siggpg'            : StringType,
        'sigsize'           : IntType,
        'header_start'      : IntType,
        'header_end'        : IntType,
        'path'              : StringType,
        # these attributes are mutualy exclusive
        'md5sum'            : StringType,       # xml dumps < 3.5
        'checksum'          : StringType,       # xml dumps >= 3.5
        'checksum_type'     : StringType,       # xml dumps >= 3.5
        'sigmd5'            : StringType,       # xml dumps < 3.5 and rpms
        'sigchecksum_type'  : StringType,       # xml dumps >= 3.5
        'sigchecksum'       : StringType,       # xml dumps >= 3.5
        # These attributes are lists of objects
        'files'             : [File],
        'requires'          : [Dependency],
        'provides'          : [Dependency],
        'conflicts'         : [Dependency],
        'obsoletes'         : [Dependency],
        'changelog'         : [ChangeLog],
        'channels'          : [StringType],
    }
    def __init__(self):
        # Inherit from IncompletePackage
        IncompletePackage.__init__(self)
        # And initialize the specific ones
        for k in self.attributeTypes.keys():
            self[k] = None


class SourcePackage(IncompletePackage):
    attributeTypes = {
        'package_group'     : StringType,
        'rpm_version'       : StringType,
        'source_rpm'        : StringType,
        'payload_size'      : IntType,
        'payload_format'    : StringType,
        'build_host'        : StringType,
        'build_time'        : DateType,
        'sigchecksum_type'  : StringType,
        'sigchecksum'       : StringType,
        'vendor'            : StringType,
        'cookie'            : StringType,
        'package_size'      : IntType,
        'path'              : StringType,
        'last_modified'     : DateType,
        # these attributes are mutualy exclusive
        'md5sum'            : StringType,       # xml dumps < 3.5
        'checksum'          : StringType,       # xml dumps >= 3.5
        'checksum_type'     : StringType,       # xml dumps >= 3.5
    }
    def __init__(self):
        # Inherit from IncompletePackage
        IncompletePackage.__init__(self)
        # And initialize the specific ones
        self.source_rpm = None
        for k in self.attributeTypes.keys():
            self[k] = None

    def short_str(self):
        return self.source_rpm


class SourcePackageFile(Information):
    attributeTypes = {
        'file_size'         : IntType,
        'path'              : StringType,
        'org_id'            : IntType,
        # these attributes are mutualy exclusive
        'md5sum'            : StringType,       # xml dumps < 3.5
        'checksum'          : StringType,       # xml dumps >= 3.5
        'checksum_type'     : StringType,       # xml dumps >= 3.5
    }


class Bug(Information):
    attributeTypes = {
        'bug_id'            : StringType,
        'bug_summary'       : StringType,
    }


class ErrataFile(Information):
    attributeTypes = {
        'filename'          : StringType,
        'file_type'         : StringType,
        'channel_list'      : [StringType],
        'package_id'        : IntType,
        # these attributes are mutualy exclusive
        'md5sum'            : StringType,       # xml dumps < 3.5
        'checksum'          : StringType,       # xml dumps >= 3.5
        'checksum_type'     : StringType,       # xml dumps >= 3.5
    }


class Keyword(Information):
    attributeTypes = {
        'keyword'           : StringType,
    }


class CVE(Information):
    attributeTypes = {
        'name'              : StringType,
    }


class Erratum(Information):
    attributeTypes = {
        'advisory'          : StringType,
        'advisory_name'     : StringType,
        'advisory_rel'      : IntType,
        'advisory_type'     : StringType,
        'product'           : StringType,
        'description'       : StringType,
        'synopsis'          : StringType,
        'topic'             : StringType,
        'solution'          : StringType,
        'issue_date'        : DateType,
        'update_date'       : DateType,
        'last_modified'     : DateType,
        'notes'             : StringType,
        'org_id'            : IntType,
        'refers_to'         : StringType,
        # These attributes are lists of objects
        'channels'          : [Channel],
        'packages'          : [IncompletePackage],
        'files'             : [ErrataFile],
        'keywords'          : [Keyword],
        'bugs'              : [Bug],
        'cve'               : [StringType],
    }


class BaseArch(Information):
    attributeTypes = {
        'label'     : StringType,
        'name'      : StringType,
    }

class CPUArch(BaseArch):
    pass


class BaseTypedArch(BaseArch):
    attributeTypes = BaseArch.attributeTypes.copy()
    attributeTypes.update({
        'arch-type-label'   : StringType,
        'arch-type-name'    : StringType,
    })

class ServerArch(BaseTypedArch):
    pass

class PackageArch(BaseTypedArch):
    pass

class ChannelArch(BaseTypedArch):
    pass

class ServerPackageArchCompat(Information):
    attributeTypes = {
        'server-arch'   : StringType,
        'package-arch'  : StringType,
        'preference'    : IntType,
    }

class ServerChannelArchCompat(Information):
    attributeTypes = {
        'server-arch'   : StringType,
        'channel-arch'  : StringType,
    }

class ChannelPackageArchCompat(Information):
    attributeTypes = {
        'channel-arch'  : StringType,
        'package-arch'  : StringType,
    }

class ServerGroupServerArchCompat(Information):
    attributeTypes = {
        'server-arch'       : StringType,
        'server-group-type' : StringType,
    }

class BlacklistObsoletes(Information):
    attributeTypes = {
        'name'          : StringType,
        'epoch'         : StringType,
        'version'       : StringType,
        'release'       : StringType,
        'package-arch'  : StringType,
        'ignored-name'  : StringType,
    }

class KickstartFile(Information):
    attributeTypes = {
        'relative_path' : StringType,
        'last_modified' : DateType,
        'file_size'     : IntType,
        # these attributes are mutualy exclusive
        'md5sum'            : StringType,       # xml dumps < 3.5
        'checksum'          : StringType,       # xml dumps >= 3.5
        'checksum_type'     : StringType,       # xml dumps >= 3.5
    }

class KickstartableTree(Information):
    attributeTypes = {
        'label'             : StringType,
        'base_path'         : StringType,
        'channel'           : StringType,
        'boot_image'        : StringType,
        'kstree_type_label' : StringType,
        'install_type_name' : StringType,
        'kstree_type_label' : StringType,
        'install_type_name' : StringType,
        'org_id'            : IntType,
        'last_modified'     : DateType,
        'files'             : [ KickstartFile ],
    }

class ProductName(Information):
    attributeTypes = {
        'label'             : StringType,
	'name'              : StringType,
    }

class SolarisPatchInfo(Information):
    # Object attribute name -> Object attribute type mapping
    attributeTypes = {
        'package_id'    : IntType,
        'solaris_release': StringType,
        'sunos_release' : StringType,
        'patch_type'    : IntType,
        'readme'        : StringType,
        'patchinfo'     : StringType,
    }


class SolarisPatchPackagesInfo(Information):
    attributeTypes = {
        'patch_id'      : IntType,
        'package_nevra_id': IntType,
    }


class SolarisPatchSetMember(Information):
    attributeTypes = {
        'patch_id'      : IntType,
        'patch_set_id'  : IntType,
    }


class SolarisPatchSetInfo(Information):
    attributeTypes = {
        'package_id'    : IntType,
        'readme'        : StringType,
        'set_date'      : DateType,
        'members'       : [ SolarisPatchSetMember ],
    }


class SolarisPackageInfo(Information):
    attributeTypes = {
        'package_id'    : IntType,
        'category'      : StringType,
        'pkginfo'       : StringType,
        'pkgmap'        : StringType,
        'intonly'       : StringType,
    }


# Generic error object
class Error(Information):
    attributeTypes = {
        'error'             : StringType,
    }


# Base import class
class Import:
    def __init__(self, batch, backend):
        self.batch = batch
        self.backend = backend
        # Upload force
        self.uploadForce = 1
        # Force object verification
        self.forceVerify = 0
        # Ignore already-uploaded objects
        self.ignoreUploaded = 0
        # Transactional behaviour
        self.transactional = 0

    def setUploadForce(self, value):
        self.uploadForce = value

    def setForceVerify(self, value):
        self.forceVerify = value

    def setIgnoreUploaded(self, value):
        self.ignoreUploaded = value

    def setTransactional(self, value):
        self.transactional = value

    # This is the generic API exposed by an importer
    def preprocess(self):
        pass

    def fix(self):
        pass

    def submit(self):
        pass

    def run(self):
        self.preprocess()
        self.fix()
        self.submit()

    def cleanup(self):
        # Clean up the objects in the batch
        for object in self.batch:
            self._cleanup_object(object)

    def _cleanup_object(self, object):
        object.clear()

    def status(self):
        # Report the status back
        self.cleanup()
        return self.batch

    def _processPackage(self, package):
        # Build the helper data structures
        evr = []
        for f in ('epoch', 'version', 'release'):
            evr.append(package[f])
        package.evr = tuple(evr)
        package.name = package['name']
        package.arch = package['arch']
        package.org_id = package['org_id']


# Any package processing import class
class GenericPackageImport(Import):
    def __init__(self, batch, backend):
        Import.__init__(self, batch, backend)
        # Packages have to be pre-processed
        self.names = {}
        self.evrs = {}
        self.checksums = {}
        self.package_arches = {}
        self.channels = {}
        self.channel_package_arch_compat = {}

    def _processPackage(self, package):
        Import._processPackage(self, package)

        # Save the fields in the local hashes
        if not self.evrs.has_key(package.evr):
            self.evrs[package.evr] = None

        if not self.names.has_key(package.name):
            self.names[package.name] = None

        if not self.package_arches.has_key(package.arch):
            self.package_arches[package.arch] = None

        checksumTuple = (package['checksum_type'], package['checksum'])
        if not self.checksums.has_key(checksumTuple):
            self.checksums[checksumTuple] = None

    def _postprocessPackageNEVRA(self, package):
        arch = self.package_arches[package.arch]
        if not arch:
            # Unsupported arch
            package.ignored = 1
            raise InvalidArchError(package.arch, 
                "Unknown arch %s" % package.arch)

#        package['package_arch_id'] = arch
#        package['name_id'] = self.names[package.name]
#        package['evr_id'] = self.evrs[package.evr]

        nevra = (self.names[package.name], self.evrs[package.evr], arch)
        nevra_dict = {nevra: None}

        self.backend.lookupPackageNEVRAs(nevra_dict)

        package['name_id'], package['evr_id'], package['package_arch_id'] = nevra
        package['nevra_id'] = nevra_dict[nevra]
        package['checksum_id'] = self.checksums[(package['checksum_type'], package['checksum'])]

# Exceptions
class ImportException(Exception):
    def __init__(self, arglist):
        apply(Exception.__init__, (self, ) + arglist)

class AlreadyUploadedError(ImportException):
    def __init__(self, object, *rest):
        ImportException.__init__(self, rest)
        self.object = object

class FileConflictError(AlreadyUploadedError):
    pass

class InvalidPackageError(ImportException):
    def __init__(self, package, *rest):
        ImportException.__init__(self, rest)
        self.package = package


class InvalidArchError(ImportException):
    def __init__(self, arch, *rest):
        ImportException.__init__(self, rest)
        self.arch = arch


class InvalidChannelError(ImportException):
    def __init__(self, channel, *rest):
        ImportException.__init__(self, rest)
        self.channel = channel


class MissingParentChannelError(ImportException):
    def __init__(self, channel, *rest):
        ImportException.__init__(self, rest)
        self.channel = channel


class InvalidChannelFamilyError(ImportException):
    def __init__(self, channel_family, *rest):
        ImportException.__init__(self, rest)
        self.channel_family = channel_family


class IncompatibleArchError(ImportException):
    def __init__(self, arch1, arch2, *rest):
        ImportException.__init__(self, rest)
        self.arch1 = arch1
        self.arch2 = arch2

class InvalidSeverityError(ImportException):
    def __init__(self, *rest):
	ImportException.__init__(self, rest)

class TransactionError(ImportException):
    def __init__(self, *rest):
        ImportException.__init__(self, rest)

# Class that stores diff information
class Diff(UserList):
    def __init__(self):
        UserList.__init__(self)
        self.level = 0

    def setLevel(self, level):
        if self.level < level:
            self.level = level

    def toDict(self):
        # Converts the object to a dictionary
        l = []
        for item in self:
            l.append(removeNone(item))
        return {
            'level' : self.level,
            'diff'  : l,
        }


# Replaces all occurences of None with the empty string
def removeNone(list):
    return map(lambda x: (x is not None and x) or '', list)


# Assorted functions for various things

def copy_package(fd, basedir, relpath, checksum_type, checksum, force=None):
    """
    Copies the information from the file descriptor to a file
    Checks the file's checksum, raising FileConflictErrror if it's different
    The force flag prevents the exception from being raised, and copies the
    file even if the checksum has changed
    """
    packagePath = basedir + "/" + relpath
    # Is the file there already?
    if os.path.isfile(packagePath) and not force:
        # Get its checksum
        localsum = getFileChecksum(checksum_type, packagePath)
        if checksum == localsum:
            # Same file, so get outa here
            return 
        raise FileConflictError(os.path.basename(packagePath))

    dir = os.path.dirname(packagePath)
    # Create the directory where the file will reside
    if not os.path.exists(dir):
        createPath(dir)
    pkgfd = os.open(packagePath, os.O_WRONLY | os.O_CREAT | os.O_TRUNC)
    os.lseek(fd, 0, 0)
    while 1:
        buffer = os.read(fd, 65536)
        if not buffer:
            break
        n = os.write(pkgfd, buffer)
        if n != len(buffer):
            # Error writing to the file
            raise IOError, "Wrote %s out of %s bytes in file %s" % (
                n, len(buffer), packagePath)
    os.close(pkgfd)
    # set the path perms readable by all users
    setPermsPath(packagePath, chmod=0644)


# Returns a list of containing nevra for the given RPM header
def get_nevra(header):
    # Get nevra
    nevra = []
    for tag in ['name', 'epoch', 'version', 'release', 'arch']:
        nevra.append(header[tag])
    return nevra
