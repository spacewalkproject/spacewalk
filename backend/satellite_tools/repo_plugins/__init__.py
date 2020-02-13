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

import re
import rpm
from spacewalk.common import rhn_pkg
from spacewalk.common.rhnException import rhnFault
from spacewalk.server import rhnPackageUpload

CACHE_DIR = '/var/cache/rhn/reposync/'


class ContentPackage:

    def __init__(self):
        # map of checksums
        self.checksum_type = None
        self.checksum = None

        # unique ID that can be used by plugin
        self.unique_id = None

        self.name = None
        self.version = None
        self.release = None
        self.epoch = None
        self.arch = None

        self.path = None

        self.a_pkg = None

    def __cmp__(self, other):
        ret = cmp(self.name, other.name)
        if ret == 0:
            rel_self = str(self.release).split('.')[0]
            rel_other = str(other.release).split('.')[0]
            # pylint: disable=E1101
            ret = rpm.labelCompare((str(self.epoch), str(self.version), rel_self),
                                   (str(other.epoch), str(other.version), rel_other))
        if ret == 0:
            ret = cmp(self.arch, other.arch)
        return ret

    def getNRA(self):
        rel = re.match(".*?\\.(.*)",self.release)
        rel = rel.group(1)
        nra = str(self.name) + str(rel) + str(self.arch)
        return nra

    def setNVREA(self, name, version, release, epoch, arch):
        self.name = name
        self.version = version
        self.release = release
        self.arch = arch
        self.epoch = epoch

    def getNVREA(self):
        if self.epoch:
            return self.name + '-' + self.version + '-' + self.release + '-' + self.epoch + '.' + self.arch
        else:
            return self.name + '-' + self.version + '-' + self.release + '.' + self.arch

    def getNEVRA(self):
        if self.epoch is None:
            self.epoch = '0'
        return self.name + '-' + self.epoch + ':' + self.version + '-' + self.release + '.' + self.arch

    def load_checksum_from_header(self):
        if self.path is None:
            raise rhnFault(50, "Unable to load package", explain=0)
        self.a_pkg = rhn_pkg.package_from_filename(self.path)
        self.a_pkg.read_header()
        self.a_pkg.payload_checksum()
        self.a_pkg.input_stream.close()

    def upload_package(self, org_id, metadata_only=False):
        if not metadata_only:
            rel_package_path = rhnPackageUpload.relative_path_from_header(
                self.a_pkg.header, org_id, self.a_pkg.checksum_type, self.a_pkg.checksum)
        else:
            rel_package_path = None
        _unused = rhnPackageUpload.push_package(self.a_pkg,
                                                force=False,
                                                relative_path=rel_package_path,
                                                org_id=org_id)
        return rel_package_path
