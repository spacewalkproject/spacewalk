#
# Copyright (c) 2008--2016 Red Hat, Inc.
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
from rhn.i18n import bstr
from spacewalk.common import checksum

def get_package_header(filename=None, file_obj=None, fd=None):
    # pylint: disable=E1103
    if filename is not None:
        stream = open(filename, mode='rb')
        need_close = True
    elif file_obj is not None:
        stream = file_obj
    else:
        stream = os.fdopen(os.dup(fd), "r")
        need_close = True

    if stream.name.endswith('.deb'):
        packaging = 'deb'
    elif stream.name.endswith('.rpm'):
        packaging = 'rpm'
    else:
        packaging = 'mpm'

    a_pkg = package_from_stream(stream, packaging)
    a_pkg.read_header()
    if need_close:
        stream.close()
    return a_pkg.header


def package_from_stream(stream, packaging):
    if packaging == 'deb':
        from spacewalk.common import rhn_deb
        a_pkg = rhn_deb.DEB_Package(stream)
    elif packaging == 'rpm':
        from spacewalk.common import rhn_rpm
        a_pkg = rhn_rpm.RPM_Package(stream)
    elif packaging == 'mpm':
        from spacewalk.common import rhn_mpm
        a_pkg = rhn_mpm.MPM_Package(stream)
    else:
        a_pkg = None
    return a_pkg


def package_from_filename(filename):
    if filename.endswith('.deb'):
        packaging = 'deb'
    elif filename.endswith('.rpm') or filename.endswith('.hdr'):
        packaging = 'rpm'
    else:
        packaging = 'mpm'
    stream = open(filename, mode='rb')
    return package_from_stream(stream, packaging)

BUFFER_SIZE = 16384
DEFAULT_CHECKSUM_TYPE = 'md5'


class A_Package:

    """virtual class that implements shared methods for RPM/MPM/DEB package object"""
    # pylint: disable=R0902

    def __init__(self, input_stream=None):
        self.header = None
        self.header_start = 0
        self.header_end = 0
        self.input_stream = input_stream
        self.checksum_type = DEFAULT_CHECKSUM_TYPE
        self.checksum = None
        self.payload_stream = None
        self.payload_size = None

    def read_header(self):
        """reads header from self.input_file"""
        pass

    def save_payload(self, output_stream):
        """saves payload to output_stream"""
        c_hash = checksum.getHashlibInstance(self.checksum_type, False)
        if output_stream:
            output_start = output_stream.tell()
        self._stream_copy(self.input_stream, output_stream, c_hash)
        self.checksum = c_hash.hexdigest()
        if output_stream:
            self.payload_stream = output_stream
            self.payload_size = output_stream.tell() - output_start

    def payload_checksum(self):
        # just read and compute checksum
        start = self.input_stream.tell()
        self.save_payload(None)
        self.payload_size = self.input_stream.tell() - start + self.header_end
        self.payload_stream = self.input_stream

    @staticmethod
    def _stream_copy(source, dest, c_hash=None):
        """copies data from the source stream to the destination stream"""
        while True:
            buf = source.read(BUFFER_SIZE)
            if not buf:
                break
            if dest:
                dest.write(buf)
            if c_hash:
                c_hash.update(buf)

    @staticmethod
    def _read_bytes(stream, amt):
        ret = bstr('')
        while amt:
            buf = stream.read(min(amt, BUFFER_SIZE))
            if not buf:
                return ret
            ret = ret + buf
            amt = amt - len(buf)
        return ret


class InvalidPackageError(Exception):
    pass
