#
# Copyright (c) 2010 Red Hat, Inc.
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
# $Id$
#
# Author: Lukas Durfina <lukas.durfina@gmail.com>

import os
import gzip
import cStringIO
import tempfile
from rhn.rpclib import xmlrpclib

from debian import debfile
import struct

from types import ListType, TupleType, DictType

DEB_CHECKSUM_TYPE = 'md5'       # FIXME: this should be a configuration option

def get_package_header(filename=None, file=None, fd=None):
    return load(filename=filename, file=file, fd=fd)[0]

# Loads DEB and returns its header and its payload
def load(filename=None, file=None, fd=None):
    if (filename is None):
        raise ValueError, "filename has to be passed"
    if (filename is None and file is None and fd is None):
        raise ValueError, "No parameters passed"

    if filename is not None:
        f = open(filename)
    elif file is not None:
        f = file
    else: # fd is not None
        f = os.fdopen(os.dup(fd), "r")

    f.seek(0, 0)
    return load_deb(f, filename)

def load_deb(stream, filename):

    # Dup the file descriptor, we don't want it to get closed before we read
    # the payload
    newfd = os.dup(stream.fileno())
    stream = os.fdopen(newfd, "r")

    stream.flush()
    stream.seek(0, 0)


    try:
        #header = rhn_deb.get_package_header(file=stream)
        header = deb_Header(filename)
    except:
        raise InvalidPackageError(e)
    stream.seek(0, 0)

    return header, stream

class deb_Header:
    "Wrapper class for an deb header - we need to store a flag is_source"
    def __init__(self, name):
        self.hdr = {}
        self.packaging = 'deb'
        self.signatures = []
        self.name = ''
        self.version = 0
        self.release = 0
        self.arch = 'all'
        self.is_source = 0
        self.deb = None

        try:
            self.deb = debfile.DebFile(name)
        except Exception, e:
            raise InvalidPackageError(e)

        try:
            # Fill info about package
            self.name = self.deb.debcontrol().get_as_string('Package')
            self.arch = self.deb.debcontrol().get_as_string('Architecture') + '-deb'
            version = self.deb.debcontrol().get_as_string('Version')
            version_tmpArr = version.split('-')
            if len(version_tmpArr) == 1:
                self.version = version
                self.release = "X"
            else:
                self.version = version_tmpArr[0]
                self.release = version_tmpArr[1]
        except Exception, e:
            raise InvalidPackageError(e)

    def checksum_type(self):
        return DEB_CHECKSUM_TYPE

    def is_signed(self):
        return 0

    def __getitem__(self, name):
        name = str(name)
        if name == 'name':
            return self.name
        elif name == 'arch':
            return self.arch
        elif name == 'release':
            return self.release
        elif name == 'version':
            return self.version
        elif name == 'epoch':
            return ''
        elif name == 'summary':
            return self.deb.debcontrol().get_as_string('Description').splitlines()[0]
        elif name == 'vendor':
            return self.deb.debcontrol().get_as_string('Maintainer')
        elif name == 'package_group':
            return self.deb.debcontrol().get_as_string('Section')
        if self.deb.debcontrol().has_key(name):
            return self.deb.debcontrol().get_as_string(name)
        else:
            return None
"""
    def __setitem__(self, name, item):
        self.hdr[name] = item

    def __delitem__(self, name):
        del self.hdr[name]

    def __getattr__(self, name):
        return getattr(self.hdr, name)
"""

class InvalidPackageError(Exception):
    pass
