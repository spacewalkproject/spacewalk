#
# Copyright (c) 2009--2014 Red Hat, Inc.
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

hashlib_has_usedforsecurity = False

try:
    import hashlib
    import inspect
    if 'usedforsecurity' in inspect.getargspec(hashlib.new)[0]:
        hashlib_has_usedforsecurity = True
except ImportError:
    import md5
    import sha
    from Crypto.Hash import SHA256 as sha256

    class hashlib(object):

        @staticmethod
        def new(checksum):
            if checksum == 'md5':
                return md5.new()
            elif checksum == 'sha1':
                return sha.new()
            elif checksum == 'sha256':
                return sha256.new()
            else:
                raise ValueError, "Incompatible checksum type"


def getHashlibInstance(hash_type, used_for_security):
    """Get an instance of a hashlib object.
    """
    if hashlib_has_usedforsecurity:
        return hashlib.new(hash_type, usedforsecurity=used_for_security)
    else:
        return hashlib.new(hash_type)


def getFileChecksum(hashtype, filename=None, fd=None, file_obj=None, buffer_size=None, used_for_security=False):
    """ Compute a file's checksum
        Used by rotateFile()
    """

    # python's md5 lib sucks
    # there's no way to directly import a file.
    if buffer_size is None:
        buffer_size = 65536

    if filename is None and fd is None and file_obj is None:
        raise ValueError("no file specified")
    if file_obj:
        f = file_obj
    elif fd is not None:
        f = os.fdopen(os.dup(fd), "r")
    else:
        f = open(filename, "r")
    # Rewind it
    f.seek(0, 0)
    m = getHashlibInstance(hashtype, used_for_security)
    while 1:
        buf = f.read(buffer_size)
        if not buf:
            break
        m.update(buf)

    # cleanup time
    if file_obj is not None:
        file_obj.seek(0, 0)
    else:
        f.close()
    return m.hexdigest()


def getStringChecksum(hashtype, s):
    """ compute checksum of an arbitrary string """
    h = getHashlibInstance(hashtype, False)
    h.update(s)
    return h.hexdigest()
