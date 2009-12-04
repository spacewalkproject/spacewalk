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
import sys
import rpm
import struct

import exceptions
if not hasattr(exceptions, 'StopIteration'):
    # Presumably python 1.5.2
    class StopIteration(Exception):
        pass

# Expose a bunch of useful constants from rpm
error = rpm.error
for sym, val in rpm.__dict__.items():
    if sym[:3] == 'RPM':
        # A constant, probably - import it into our namespace
        globals()[sym] = val
del sym, val

class InvalidPackageError(Exception):
    pass

# wrapper/proxy class for rpm.Transaction so we can
# instrument it, etc easily
class RPMTransaction:
    read_only = 0
    def __init__(self):
        if hasattr(rpm, 'opendb'):
            db = getattr(rpm, 'opendb')(not self.read_only)
            self.ts = rpm.TransactionSet('/', db)
        else:
            self.ts = rpm.TransactionSet()
        self.tsflags = []
        # For rpm 4.0.4
        self._flags = 0
        self._prob_filter = 0

    def __getattr__(self, attr):
        return getattr(self.ts, attr)

    def getMethod(self, method):
        # in theory, we can override this with
        # profile/etc info
        return getattr(self.ts, method)

    # push/pop methods so we don't lose the previous
    # set value, and we can potentially debug a bit
    # easier
    def pushVSFlags(self, flags):
        self.tsflags.append(flags)
        if hasattr(self.ts, 'setVSFlags'):
            f = getattr(self.ts, 'setVSFlags')
            f(self.tsflags[-1])

    def popVSFlags(self):
        del self.tsflags[-1]
        if hasattr(self.ts, 'setVSFlags'):
            f = getattr(self.ts, 'setVSFlags')
            f(self.tsflags[-1])

    def addInstall(self, arg1, arg2, mode):
        """Install a package"""
        hdr = arg1.hdr
        if hasattr(self.ts, 'addInstall'):
            f = getattr(self.ts, 'addInstall')
            return f(hdr, arg2, mode)
        return self.ts.add(hdr, arg2, mode)

    def addErase(self, arg1):
        """Erase a package"""
        hdr = arg1.hdr
        if hasattr(self.ts, 'addErase'):
            f = getattr(self.ts, 'addErase')
            return f(hdr)
        return self.ts.add(hdr, hdr, "e")

    def check(self):
        """Check dependencies"""
        if hasattr(self.ts, 'check'):
            f = getattr(self.ts, 'check')
        else:
            f = getattr(self.ts, 'depcheck')
        return f()

    def setFlags(self, flag):
        """Set transaction flags"""
        if hasattr(rpm, 'headerFromPackage'):
            # Old style rpm
            old_flags = self._flags
            self._flags = flag
            return old_flags
        return self.ts.setFlags(flag)

    def setProbFilter(self, flag):
        """Set problem flags"""
        if hasattr(rpm, 'headerFromPackage'):
            # Old style rpm
            old_flags = self._prob_filter
            self._prob_filter = flag
            return old_flags
        return self.ts.setProbFilter(flag)

    def run(self, callback, user_data):
        if hasattr(rpm, 'headerFromPackage'):
            # Old style rpm
            return self.ts.run(self._flags, self._prob_filter, callback,
                user_data)
        return self.ts.run(callback, user_data)




class SharedStateTransaction:
    _shared_state = {}

    def __init__(self):
        self.__dict__ = self._shared_state

class RPMReadOnlyTransaction(SharedStateTransaction, RPMTransaction):
    read_only = 1
    def __init__(self):
        SharedStateTransaction.__init__(self)
        if not hasattr(self, 'ts'):
            RPMTransaction.__init__(self)
            # FIXME: replace with macro defination
            self.pushVSFlags(8)

class RPM_Header:
    "Wrapper class for an rpm header - we need to store a flag is_source"
    def __init__(self, hdr, is_source=None):
        self.hdr = hdr
        self.is_source = is_source
        self.packaging = 'rpm'
        self.signatures = []
        self._extract_signatures()

    def __getitem__(self, name):
        return self.hdr[name]

    def __getattr__(self, name):
        return getattr(self.hdr, name)

    def is_signed(self):
        if hasattr(rpm, "RPMTAG_DSAHEADER"):
            dsaheader = self.hdr["dsaheader"]
        else:
            dsaheader = 0
        if self.hdr["siggpg"] or self.hdr["sigpgp"] or dsaheader:
            return 1
        return 0

    def _extract_signatures(self):
        header_tags = [
            [rpm.RPMTAG_DSAHEADER, "dsa"],
            [rpm.RPMTAG_RSAHEADER, "rsa"],
            [rpm.RPMTAG_SIGGPG, "gpg"],
            [rpm.RPMTAG_SIGPGP, 'pgp'],
        ]
        for ht, sig_type in header_tags:
            ret = self.hdr[ht]
            if not ret or len(ret) < 17:
                continue
            # Get the key id - hopefully we get it right
            key_id = ret[9:17]
            key_id_len = len(key_id)
            format = "%dB" % key_id_len
            t = struct.unpack(format, key_id)
            format = "%02x" * key_id_len
            key_id = format % t
            self.signatures.append({
                'signature_type'    : sig_type,
                'key_id'            : key_id,
                'signature'         : ret,
            })

def get_header_byte_range(package_file):
    """
    Return the start and end bytes of the rpm header object.

    For details of the rpm file format, see:
    http://www.rpm.org/max-rpm/s1-rpm-file-format-rpm-file-format.html
    """

    lead_size = 96

    # Move past the rpm lead
    package_file.seek(lead_size)

    sig_size = get_header_struct_size(package_file)

    # Now we can find the start of the actual header.
    header_start = lead_size + sig_size

    package_file.seek(header_start)

    header_size = get_header_struct_size(package_file)

    header_end = header_start + header_size

    return (header_start, header_end)

def get_header_struct_size(package_file):
    """
    Compute the size in bytes of the rpm header struct starting at the current
    position in package_file.
    """
    # Move past the header preamble
    package_file.seek(8, 1)

    # Read the number of index entries
    header_index = package_file.read(4)
    (header_index_value, ) = struct.unpack('>I', header_index)

    # Read the the size of the header data store
    header_store = package_file.read(4)
    (header_store_value, ) = struct.unpack('>I', header_store)

    # The total size of the header. Each index entry is 16 bytes long.
    header_size = 8 + 4 + 4 + header_index_value * 16 + header_store_value

    # Headers end on an 8-byte boundary. Round out the extra data.
    round_out = header_size % 8
    if round_out != 0:
        header_size = header_size + (8 - round_out)

    return header_size

# Loads the package header from a file / stream / file descriptor
# Raises rpm.error if an error is found, or InvalidPacageError if package is
# busted
# XXX Deal with exceptions better
def get_package_header(filename=None, file=None, fd=None):
    if (filename is None and file is None and fd is None):
        raise ValueError, "No parameters passed"

    if filename is not None:
        f = open(filename)
    elif file is not None:
        f = file
        f.seek(0, 0)
    else: # fd is not None
        f = None

    if f is None:
        os.lseek(fd, 0, 0)
        file_desc = fd
    else:
        file_desc = f.fileno()

    if hasattr(rpm, 'headerFromPackage'):
        hdr, is_source = rpm.headerFromPackage(file_desc)
        if hdr is None:
            raise InvalidPackageError
    else:
        if hasattr(rpm, 'readHeaderFromFD'):
            header_start, header_end = \
                    get_header_byte_range(os.fdopen(os.dup(file_desc)))
            os.lseek(file_desc, header_start, 0)
            hdr, offset = rpm.readHeaderFromFD(file_desc)
        else:
            # RHEL-4 and older, do the old way
            ts = RPMReadOnlyTransaction()
            nomd5 = getattr(rpm, 'RPMVSF_NOMD5')
            needpayload = getattr(rpm, 'RPMVSF_NEEDPAYLOAD')
            ts.pushVSFlags(~(nomd5 | needpayload))
            hdr = RPMReadOnlyTransaction().hdrFromFdno(file_desc)
            ts.popVSFlags()
        if hdr is None:
            raise InvalidPackageError
        is_source = hdr[getattr(rpm, 'RPMTAG_SOURCEPACKAGE')]

    return RPM_Header(hdr, is_source)

class MatchIterator:
    def __init__(self, tag_name=None, value=None):
        # Query by name, by default
        if not tag_name:
            tag_name = "name"

        if hasattr(rpm, "headerFromPackage"):
            # rpm 4.0.4 or earlier
            self.db = rpm.opendb()
            method = self.db.match
        else:
            # rpm 4.1 or later
            self.ts = rpm.TransactionSet()
            self.ts.setVSFlags(8)
            method = self.ts.dbMatch

        if value:
            self.mi = method(tag_name, value)
        else:
            self.mi = method(tag_name)

    def pattern(self, tag_name, mode, pattern):
        self.mi.pattern(tag_name, mode, pattern)

    def next(self):
        try:
            hdr = self.mi.next()
        except StopIteration:
            hdr = None

        if hdr is None:
            return None
        if hasattr(rpm, "headerFromPackage"):
            is_source = not hdr[rpm.RPMTAG_SOURCERPM]
        else:
            is_source =  hdr[getattr(rpm, 'RPMTAG_SOURCEPACKAGE')]
        return RPM_Header(hdr, is_source)


def headerLoad(data):
    hdr = rpm.headerLoad(data)
    if hasattr(rpm, "headerFromPackage"):
        is_source = not hdr[rpm.RPMTAG_SOURCERPM]
    else:
        is_source =  hdr[getattr(rpm, 'RPMTAG_SOURCEPACKAGE')]
    return RPM_Header(hdr, is_source)

def labelCompare(t1, t2):
    return rpm.labelCompare(t1, t2)

def nvre_compare(t1, t2):
    def build_evr(p):
        evr = [p[3], p[1], p[2]]
        evr = map(str, evr)
        if evr[0] == "":
            evr[0] = None
        return evr
    if t1[0] != t2[0]:
        raise ValueError("You should only compare packages with the same name")
    evr1, evr2 = (build_evr(t1), build_evr(t2))
    return rpm.labelCompare(evr1, evr2)


def hdrLabelCompare(hdr1, hdr2):
    """ take two RPMs or headers and compare them for order """

    if hdr1['name'] == hdr2['name']:
        hdr1 = [hdr1['epoch'] or None, hdr1['version'], hdr1['release']]
        hdr2 = [hdr2['epoch'] or None, hdr2['version'], hdr2['release']]
        if hdr1[0]:
            hdr1[0] = str(hdr1[0])
        if hdr2[0]:
            hdr2[0] = str(hdr2[0])
        return rpm.labelCompare(hdr1, hdr2)
    elif hdr1['name'] < hdr2['name']:
        return -1
    return 1


def rpmLabelCompare(rpmFilename1, rpmFilename2):
    """ take two RPMs and compare them for order """
    return hdrLabelCompare(get_package_header(rpmFilename1),
                           get_package_header(rpmFilename2))


def sortHeaders(hdrs):
    """ Sorts a list of RPM headers (or RPMs).
        Assertion: they *must* exist.
    """

    assert isinstance(hdrs, type([]))

    sorted = hdrs[:]
    sorted.sort(hdrLabelCompare)
    return sorted


def sortRPMs(rpms):
    """ Sorts a list of RPM files. They *must* exist.  """

    assert isinstance(rpms, type([]))

    # We don't want to use rpmLabelCompare as a sorting mechanism, it would
    # extract the rpm header for each comparison.
    # Build a list of (header, rpm)
    helper = map(lambda x: (get_package_header(x), x), rpms)

    # Sort the list using the headers as a comparison
    helper.sort(lambda x, y: hdrLabelCompare(x[0], y[0]))

    # Extract the rpm names now
    return map(lambda x: x[1], helper)


def getInstalledHeader(rpmName):
    """ quieries the RPM DB for a header matching rpmName. """

    mi = MatchIterator("name")
    mi.pattern("name", rpm.RPMMIRE_STRCMP, rpmName)
    return mi.next()


if __name__ == '__main__':
    mi = MatchIterator("name")
    mi.pattern("name", rpm.RPMMIRE_GLOB, "*ker*")
    while 1:
        h = mi.next()
        if not h:
            break
        print h['name']
    sys.exit(1)
    hdr = get_package_header(filename="/tmp/python-1.5.2-42.72.i386.rpm")
    print dir(hdr)
    # Sources
    hdr = get_package_header(filename="/tmp/python-1.5.2-42.72.src.rpm")
    hdr2 = headerLoad(hdr.unload())
    print hdr2
    print len(hdr2.keys())


