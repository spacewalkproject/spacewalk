#!/usr/bin/python
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

import os
import gzip
import cStringIO
import tempfile
from rhn.rpclib import xmlrpclib

import struct

from types import ListType, TupleType

def labelCompare(l1, l2):
    try:
        import rhn_rpm
    except ImportError:
        # rhn_rpm not avalable; return a dummy comparison function
        return -1
    return rhn_rpm.labelCompare(l1, l2)

def get_package_header(filename=None, file=None, fd=None):
    return load(filename=filename, file=file, fd=fd)[0]

# Loads an MPM and returns its header and its payload
def load(filename=None, file=None, fd=None):
    if (filename is None and file is None and fd is None):
        raise ValueError, "No parameters passed"
    
    if filename is not None:
        f = open(filename)
    elif file is not None:
        f = file
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
            raise e

    return p.header, p.payload_stream

def load_rpm(stream):
    # Hmm, maybe an rpm

    try:
        import rhn_rpm
    except ImportError:
        raise InvalidPackageError

    # Dup the file descriptor, we don't want it to get closed before we read
    # the payload
    newfd = os.dup(stream.fileno())
    stream = os.fdopen(newfd, "r")

    stream.flush()
    stream.seek(0, 0)
        
    try:
        header = rhn_rpm.get_package_header(file=stream)
    except rhn_rpm.InvalidPackageError, e:
        raise apply(InvalidPackageError, e.args)
    except rhn_rpm.error, e:
        raise InvalidPackageError(e)
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

    def __getattr__(self, name):
        return getattr(self.hdr, name)

    def is_signed(self):
        return 0

class InvalidPackageError(Exception):
    pass

MPM_HEADER_COMPRESSED_GZIP = 1
MPM_PAYLOAD_COMPRESSED_GZIP = 1

class MPM_Package:
    _lead_format = '!16sB3s4L92s'
    _magic = 'mpmpackage012345'
    def __init__(self):
        self.header = None
        self.payload_stream = None
        self.header_flags = MPM_HEADER_COMPRESSED_GZIP
        self.payload_flags = 0
        assert(len(self._magic) == 16)
        self._buffer_size = 16384

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
        arr = self._read_lead(input_stream)
        magic = arr[0]
        if magic != self._magic:
            raise InvalidPackageError()
        header_len, payload_len = int(arr[5]), int(arr[6])
        header_flags, payload_flags = arr[3], arr[4]
        file_size = 128 + header_len + payload_len
        input_stream.seek(file_size)
        if file_size != input_stream.tell():
            raise InvalidPackageError()
        # Read the header
        input_stream.seek(128, 0)
        header_data = self._read_bytes(input_stream, header_len)
        payload_stream = tempfile.TemporaryFile()
        self.stream_copy(input_stream, payload_stream)

        self._read_header(header_data, header_flags)
        self._read_payload(payload_stream, payload_flags)

    def _read_bytes(self, stream, amt):
        ret = ""
        while amt:
            buf = stream.read(min(amt, self._buffer_size))
            if not buf:
                return ret
            ret = ret + buf
            amt = amt - len(buf)
        return ret

    def _read_header(self, header_data, header_flags):
        if header_flags & MPM_HEADER_COMPRESSED_GZIP:
            t = cStringIO.StringIO(header_data)
            g = gzip.GzipFile(None, "r", 0, t)
            header_data = g.read()
            g.close()
            t.close()

        try:
            params, foo = xmlrpclib.loads(header_data)
        except:
            # XXX
            raise
    
        self.header = MPM_Header(params[0])

    def _read_payload(self, payload_stream, payload_flags):
        payload_stream.seek(0, 0)
        if payload_flags & MPM_PAYLOAD_COMPRESSED_GZIP:
            g = gzip.GzipFile(None, "r", 0, payload_stream)
            t = tempfile.TemporaryFile()
            self.stream_copy(g, t)
            g.close()
            payload_stream = t

        self.payload_stream = payload_stream

    def write(self, output_stream):
        if self.header is None:
            raise Exception()

        header_stream, header_size = self._encode_header()
        payload_stream, payload_size = self._encode_payload()
        
        lead_arr = (self._magic, 1, "\0" * 3, self.header_flags,
            self.payload_flags, header_size, payload_size, '\0' * 92)
        # lead
        lead = apply(struct.pack, (self._lead_format, ) + lead_arr)
        output_stream.write(lead)
        self.stream_copy(header_stream, output_stream)
        self.stream_copy(payload_stream, output_stream)

    def add_header_flag(self, flag):
        self.header_flags = self.header_flags | flag
        
    def add_payload_flag(self, flag):
        self.payload_flags = self.payload_flags | flag

    def reset_header_flags(self):
        self.header_flags = 0

    def reset_payload_flags(self):
        self.payload_flags = 0

    def _encode_header(self):
        assert(self.header is not None)
        stream = tempfile.TemporaryFile()
        data = xmlrpclib.dumps((_replace_null(self.header), ))
        if self.header_flags & MPM_HEADER_COMPRESSED_GZIP:
            f = gzip.GzipFile(None, "wb", 9, stream)
            f.write(data)
            f.close()
        else:
            stream.write(data)
        stream.flush()
        stream.seek(0, 2)
        size = stream.tell()
        stream.seek(0, 0)
        return stream, size

    def _encode_payload(self):
        assert(self.payload_stream is not None)
        stream = tempfile.TemporaryFile()
        if self.payload_flags & MPM_PAYLOAD_COMPRESSED_GZIP:
            f = gzip.GzipFile(None, "wb", 9, stream)
            self.stream_copy(self.payload_stream, f)
            f.close()
        else:
            stream = self.payload_stream
        stream.flush()
        stream.seek(0, 2)
        size = stream.tell()
        stream.seek(0, 0)
        return stream, size

    def stream_copy(self, source, dest):
        "Copies data from the source stream to the destination stream"
        while 1:
            buf = source.read(self._buffer_size)
            if not buf:
                break
            dest.write(buf)
        

def _replace_null(obj):
    if obj is None:
        return ''
    if isinstance(obj, ListType):
        return map(_replace_null, obj)
    if isinstance(obj, TupleType):
        return tuple(_replace_null(list(obj)))
    if hasattr(obj, 'items'):
        dict = {}
        for k, v in obj.items():
            dict[_replace_null(k)] = _replace_null(v)
        return dict
    return obj
