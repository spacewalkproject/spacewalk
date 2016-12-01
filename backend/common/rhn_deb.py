#
# Copyright (c) 2010--2016 Red Hat, Inc.
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
# Meta-package manager
#
# Author: Lukas Durfina <lukas.durfina@gmail.com>

import sys
import tempfile

from debian import debfile

from spacewalk.common.usix import raise_with_tb
from spacewalk.common import checksum
from spacewalk.common.rhn_pkg import A_Package, InvalidPackageError

# bare-except and broad-except
# pylint: disable=W0702,W0703

DEB_CHECKSUM_TYPE = 'sha256'       # FIXME: this should be a configuration option


class deb_Header:

    "Wrapper class for an deb header - we need to store a flag is_source"

    def __init__(self, stream):
        self.packaging = 'deb'
        self.signatures = []
        self.is_source = 0
        self.deb = None

        try:
            self.deb = debfile.DebFile(stream.name)
        except Exception:
            e = sys.exc_info()[1]
            raise_with_tb(InvalidPackageError(e), sys.exc_info()[2])

        try:
            # Fill info about package
            debcontrol = self.deb.debcontrol()
            self.hdr = {
                'name': debcontrol.get_as_string('Package'),
                'arch': debcontrol.get_as_string('Architecture') + '-deb',
                'summary': debcontrol.get_as_string('Description').splitlines()[0],
                'vendor': debcontrol.get_as_string('Maintainer'),
                'package_group': debcontrol.get_as_string('Section'),
                'epoch':   '',
                'version': 0,
                'release': 0,
                'description': debcontrol.get_as_string('Description'),
            }
            for hdr_k, deb_k in [('requires', 'Depends'),
                                 ('provides', 'Provides'),
                                 ('conflicts', 'Conflicts'),
                                 ('obsoletes', 'Replaces'),
                                 ('recommends', 'Recommends'),
                                 ('suggests', 'Suggests'),
                                 ('breaks', 'Breaks'),
                                 ('predepends', 'Pre-Depends'),
                                 ('payload_size', 'Installed-Size')]:
                if deb_k in debcontrol:
                    self.hdr[hdr_k] = debcontrol.get_as_string(deb_k)
            for k in debcontrol.keys():
                if k not in self.hdr:
                    self.hdr[k] = debcontrol.get_as_string(k)

            version = debcontrol.get_as_string('Version')
            version_tmpArr = version.split('-', 1)
            if len(version_tmpArr) == 1:
                self.hdr['version'] = version
                self.hdr['release'] = "X"
            else:
                self.hdr['version'] = version_tmpArr[0]
                self.hdr['release'] = version_tmpArr[1]
        except Exception:
            e = sys.exc_info()[1]
            raise_with_tb(InvalidPackageError(e), sys.exc_info()[2])

    @staticmethod
    def checksum_type():
        return DEB_CHECKSUM_TYPE

    @staticmethod
    def is_signed():
        return 0

    def __getitem__(self, name):
        return self.hdr.get(str(name))

    def __setitem__(self, name, item):
        self.hdr[name] = item

    def __delitem__(self, name):
        del self.hdr[name]

    def __getattr__(self, name):
        return getattr(self.hdr, name)

    def __len__(self):
        return len(self.hdr)


class DEB_Package(A_Package):

    def __init__(self, input_stream=None):
        A_Package.__init__(self, input_stream)
        self.header_data = tempfile.NamedTemporaryFile()
        self.checksum_type = DEB_CHECKSUM_TYPE

    def read_header(self):
        self._stream_copy(self.input_stream, self.header_data)
        self.header_end = self.header_data.tell()
        try:
            self.header_data.seek(0, 0)
            self.header = deb_Header(self.header_data)
        except:
            raise_with_tb(InvalidPackageError, sys.exc_info()[2])

    def save_payload(self, output_stream):
        c_hash = checksum.getHashlibInstance(self.checksum_type, False)
        if output_stream:
            output_start = output_stream.tell()
        self._stream_copy(self.header_data, output_stream, c_hash)
        self.checksum = c_hash.hexdigest()
        if output_stream:
            self.payload_stream = output_stream
            self.payload_size = output_stream.tell() - output_start
