#
# Copyright (c) 2010--2011 Red Hat, Inc.
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

import checksum
from rhn_pkg import A_Package, InvalidPackageError

DEB_CHECKSUM_TYPE = 'md5'       # FIXME: this should be a configuration option

class deb_Header:
    "Wrapper class for an deb header - we need to store a flag is_source"
    def __init__(self, stream):
        self.packaging = 'deb'
        self.signatures = []
        self.is_source = 0
        self.deb = None

        try:
            self.deb = debfile.DebFile(stream.name)
        except Exception, e:
            raise InvalidPackageError(e), None, sys.exc_info()[2]

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
                                 ('obsoletes', 'Replaces')]:
                if debcontrol.has_key(deb_k):
                    self.hdr[hdr_k] = debcontrol.get_as_string(deb_k)
            for k in debcontrol.keys():
                if not self.hdr.has_key(k):
                    self.hdr[k] = debcontrol.get_as_string(k)

            version = debcontrol.get_as_string('Version')
            version_tmpArr = version.split('-')
            if len(version_tmpArr) == 1:
                self.hdr['version'] = version
                self.hdr['release'] = "X"
            else:
                self.hdr['version'] = version_tmpArr[0]
                self.hdr['release'] = version_tmpArr[1]
        except Exception, e:
            raise InvalidPackageError(e), None, sys.exc_info()[2]

    @staticmethod
    def checksum_type():
        return DEB_CHECKSUM_TYPE

    @staticmethod
    def is_signed():
        return 0

    def __getitem__(self, name):
        return self.hdr.get(str(name))

class DEB_Package(A_Package):
    def __init__(self, input_stream = None):
        A_Package.__init__(self, input_stream)
        self.header_data = tempfile.NamedTemporaryFile()
        self.checksum_type = DEB_CHECKSUM_TYPE

    def read_header(self):
        self._stream_copy(self.input_stream, self.header_data)
        try:
            self.header_data.seek(0, 0)
            self.header = deb_Header(self.header_data)
        except:
            raise InvalidPackageError, None, sys.exc_info()[2]

    def save_payload(self, output_stream):
        c_hash = checksum.hashlib.new(self.checksum_type)
        if output_stream:
            output_start = output_stream.tell()
        self._stream_copy(self.header_data, output_stream, c_hash)
        self.checksum = c_hash.hexdigest()
        if output_stream:
            self.payload_stream = output_stream
            self.payload_size = output_stream.tell() - output_start
