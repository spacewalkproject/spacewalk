#
# Copyright (c) 2008--2012 Red Hat, Inc.
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
import cStringIO
import tempfile
import xmlrpclib
import struct
import sys
import fileutils

from types import ListType, TupleType

import checksum
from rhn_pkg import A_Package, InvalidPackageError

MPM_CHECKSUM_TYPE = 'md5'       # FIXME: this should be a configuration option

def labelCompare(l1, l2):
    try:
        import rhn_rpm
    except ImportError:
        # rhn_rpm not avalable; return a dummy comparison function
        return -1
    return rhn_rpm.labelCompare(l1, l2)

def get_package_header(filename=None, file_obj=None, fd=None):
    return load(filename=filename, file_obj=file_obj, fd=fd)[0]

def load(filename=None, file_obj=None, fd=None):
    """ Loads an MPM and returns its header and its payload """
    if (filename is None and file_obj is None and fd is None):
        raise ValueError, "No parameters passed"

    if filename is not None:
        f = open(filename)
    elif file_obj is not None:
        f = file_obj
    else: # fd is not None
        f = os.fdopen(os.dup(fd), "r")

    f.seek(0, 0)

    p = MPM_Package()
    try:
        p.load(f)
    except InvalidPackageError, e:
        try:
            return load_rpm(f)
        except InvalidPackageError:
            raise e, None, sys.exc_info()[2]
        except:
            raise e, None, sys.exc_info()[2]

    return p.header, p.payload_stream

def load_rpm(stream):
    # Hmm, maybe an rpm

    try:
        import rhn_rpm
    except ImportError:
        raise InvalidPackageError, None, sys.exc_info()[2]

    # Dup the file descriptor, we don't want it to get closed before we read
    # the payload
    newfd = os.dup(stream.fileno())
    stream = os.fdopen(newfd, "r")

    stream.flush()
    stream.seek(0, 0)

    try:
        header = rhn_rpm.get_package_header(file_obj=stream)
    except InvalidPackageError, e:
        raise InvalidPackageError(*e.args), None, sys.exc_info()[2]
    except rhn_rpm.error, e:
        raise InvalidPackageError(e), None, sys.exc_info()[2]
    except:
        raise InvalidPackageError, None, sys.exc_info()[2]
    stream.seek(0, 0)

    return header, stream

class MPM_Header:
    "Wrapper class for an mpm header - we need to store a flag is_source"
    def __init__(self, hdr):
        self.hdr = hdr
        self.is_source = hdr.get('is_source')
        self.packaging = 'mpm'
        self.signatures = []

    def __getitem__(self, name):
        return self.hdr.get(name)

    def __setitem__(self, name, item):
        self.hdr[name] = item

    def __delitem__(self, name):
        del self.hdr[name]

    def __getattr__(self, name):
        return getattr(self.hdr, name)

    @staticmethod
    def is_signed():
        return 0

    @staticmethod
    def checksum_type():
        return MPM_CHECKSUM_TYPE

    @staticmethod
    def unload():
        return None

MPM_HEADER_COMPRESSED_GZIP = 1
MPM_PAYLOAD_COMPRESSED_GZIP = 1

class MPM_Package(A_Package):
    # pylint: disable=R0902
    _lead_format = '!16sB3s4L92s'
    _magic = 'mpmpackage012345'
    def __init__(self, input_stream = None):
        A_Package.__init__(self, input_stream)
        self.header_flags = MPM_HEADER_COMPRESSED_GZIP
        self.header_size = 0
        self.payload_flags = 0
        assert(len(self._magic) == 16)
        self._buffer_size = 16384
        self.file_size = 0

    def read_header(self):
        arr = self._read_lead(self.input_stream)
        magic = arr[0]
        if magic != self._magic:
            raise InvalidPackageError()
        header_len, payload_len = int(arr[5]), int(arr[6])
        self.header_flags, self.payload_flags = arr[3], arr[4]
        self.file_size = 128 + header_len + payload_len
        header_data = self._read_bytes(self.input_stream, header_len)
        self._read_header(header_data, self.header_flags)
        self.checksum_type = self.header.checksum_type()

    def _read_lead(self, stream):
        # Lead has the following format:
        # 16 bytes  magic
        #  1 bytes  version
        #  3 bytes  unused
        #  4 bytes  header flags
        #  4 bytes  payload flags
        #  4 bytes  header length
        #  4 bytes  payload length
        # 92 bytes  padding to 128 bytes
        lead = self._read_bytes(stream, 128)
        if len(lead) != 128:
            raise InvalidPackageError()

        arr = struct.unpack(self._lead_format, lead)
        return arr

    def load(self, input_stream):
        # Clean up
        self.__init__()
        self.input_stream = input_stream
        # Read the header
        self.read_header()

        payload_stream = fileutils.payload(input_stream.name, input_stream.tell())
        input_stream.seek(self.file_size)
        if self.file_size != input_stream.tell():
            raise InvalidPackageError()

        self._read_payload(payload_stream, self.payload_flags)

    def _read_header(self, header_data, header_flags):
        if header_flags & MPM_HEADER_COMPRESSED_GZIP:
            t = cStringIO.StringIO(header_data)
            g = gzip.GzipFile(None, "r", 0, t)
            header_data = g.read()
            g.close()
            t.close()

        try:
            params, _x = xmlrpclib.loads(header_data)
        except:
            # XXX
            raise

        self.header = MPM_Header(params[0])

    def _read_payload(self, payload_stream, payload_flags):
        payload_stream.seek(0, 0)
        if payload_flags & MPM_PAYLOAD_COMPRESSED_GZIP:
            g = gzip.GzipFile(None, "r", 0, payload_stream)
            t = tempfile.TemporaryFile()
            self._stream_copy(g, t)
            g.close()
            payload_stream = t

        self.payload_stream = payload_stream

    def write(self, output_stream):
        if self.header is None:
            raise Exception()

        output_stream.seek(128, 0)
        self._encode_header(output_stream)
        self._encode_payload(output_stream)

        # now we know header and payload size so rewind back and write lead
        lead_arr = (self._magic, 1, "\0" * 3, self.header_flags,
            self.payload_flags, self.header_size, self.payload_size, '\0' * 92)
        # lead
        lead = struct.pack(self._lead_format, *lead_arr)
        output_stream.seek(0, 0)
        output_stream.write(lead)
        output_stream.seek(0, 2)

    def _encode_header(self, stream):
        assert(self.header is not None)
        data = xmlrpclib.dumps((_replace_null(self.header), ))
        start = stream.tell()
        if self.header_flags & MPM_HEADER_COMPRESSED_GZIP:
            f = gzip.GzipFile(None, "wb", 9, stream)
            f.write(data)
            f.close()
        else:
            stream.write(data)
        stream.flush()
        self.header_size = stream.tell() - start

    def _encode_payload(self, stream, c_hash=None):
        assert(self.payload_stream is not None)
        if stream:
            start = stream.tell()
        if stream and self.payload_flags & MPM_PAYLOAD_COMPRESSED_GZIP:
            f = gzip.GzipFile(None, "wb", 9, stream)
            self._stream_copy(self.payload_stream, f, c_hash)
            f.close()
        else:
            self._stream_copy(self.payload_stream, stream, c_hash)
        if stream:
            self.payload_size = stream.tell() - start

    def save_payload(self, output_stream):
        self.payload_stream = self.input_stream
        c_hash = checksum.hashlib.new(self.header.checksum_type())
        self._encode_payload(output_stream, c_hash)
        self.checksum = c_hash.hexdigest()
        if output_stream:
            self.payload_stream = output_stream


def _replace_null(obj):
    if obj is None:
        return ''
    if isinstance(obj, ListType):
        return map(_replace_null, obj)
    if isinstance(obj, TupleType):
        return tuple(_replace_null(list(obj)))
    if hasattr(obj, 'items'):
        obj_dict = {}
        for k, v in obj.items():
            obj_dict[_replace_null(k)] = _replace_null(v)
        return obj_dict
    return obj
