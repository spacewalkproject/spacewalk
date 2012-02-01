#
# Copyright (c) 2008--2011 Red Hat, Inc.
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
import tempfile

import checksum
from rhn_pkg import A_Package, InvalidPackageError

# Expose a bunch of useful constants from rpm
error = rpm.error
for sym, val in rpm.__dict__.items():
    if sym[:3] == 'RPM':
        # A constant, probably - import it into our namespace
        globals()[sym] = val
del sym, val

# need this for rpm-pyhon < 4.6 (e.g. on RHEL5)
rpm.RPMTAG_FILEDIGESTALGO = 5011

# these values are taken from /usr/include/rpm/rpmpgp.h
# PGPHASHALGO_MD5             =  1,   /*!< MD5 */
# PGPHASHALGO_SHA1            =  2,   /*!< SHA1 */
# PGPHASHALGO_RIPEMD160       =  3,   /*!< RIPEMD160 */
# PGPHASHALGO_MD2             =  5,   /*!< MD2 */
# PGPHASHALGO_TIGER192        =  6,   /*!< TIGER192 */
# PGPHASHALGO_HAVAL_5_160     =  7,   /*!< HAVAL-5-160 */
# PGPHASHALGO_SHA256          =  8,   /*!< SHA256 */
# PGPHASHALGO_SHA384          =  9,   /*!< SHA384 */
# PGPHASHALGO_SHA512          = 10,   /*!< SHA512 */
PGPHASHALGO = {
  1: 'md5',
  2: 'sha1',
  3: 'ripemd160',
  5: 'md2',
  6: 'tiger192',
  7: 'haval-5-160',
  8: 'sha256',
  9: 'sha384',
 10: 'sha512',
}


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

    def __nonzero__(self):
        if self.hdr:
            return True
        else:
            return False

    def checksum_type(self):
        if self.hdr[rpm.RPMTAG_FILEDIGESTALGO] \
           and PGPHASHALGO.has_key(self.hdr[rpm.RPMTAG_FILEDIGESTALGO]):
           checksum_type = PGPHASHALGO[self.hdr[rpm.RPMTAG_FILEDIGESTALGO]]
        else:
           checksum_type = 'md5'
        return checksum_type

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
            if not ret:
                continue
            ret_len = len(ret)
            if ret_len < 17:
                continue
            # Get the key id - hopefully we get it right
            elif ret_len <= 65: # V3 DSA signature
                key_id = ret[9:17]
            elif ret_len <= 72: # V4 DSA signature
                key_id = ret[18:26]
            elif ret_len <= 536: # V3 RSA/SHA256 signature
                key_id = ret[10:18]
            else: # ret_len <= 543 # V4 RSA/SHA signature
                key_id = ret[19:27]

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

class RPM_Package(A_Package):
    def __init__(self, input_stream = None):
        A_Package.__init__(self, input_stream)
        self.header_data = tempfile.SpooledTemporaryFile()

    def read_header(self):
        self._get_header_byte_range()
        try:
            self.header = get_package_header(file=self.header_data)
        except InvalidPackageError, e:
            raise InvalidPackageError(*e.args), None, sys.exc_info()[2]
        except error, e:
            raise InvalidPackageError(e), None, sys.exc_info()[2]
        except:
            raise InvalidPackageError, None, sys.exc_info()[2]
        self.checksum_type = self.header.checksum_type()

    def _get_header_byte_range(self):
        """
        Return the start and end bytes of the rpm header object.
        Raw header data are then stored in self.header_data.

        For details of the rpm file format, see:
        http://www.rpm.org/max-rpm/s1-rpm-file-format-rpm-file-format.html
        """

        lead_size = 96
        struct_lead_size = 16
        # Move past the rpm lead
        buf = self._read_bytes(self.input_stream, lead_size)
        self.header_data.write(buf)

        buf = self._read_bytes(self.input_stream, struct_lead_size)
        self.header_data.write(buf)

        sig_size = self._get_header_struct_size(buf)

        # Now we can find the start of the actual header.
        self.header_start = lead_size + sig_size

        buf = self._read_bytes(self.input_stream, sig_size - struct_lead_size)
        self.header_data.write(buf)

        buf = self._read_bytes(self.input_stream, struct_lead_size)
        self.header_data.write(buf)

        header_size = self._get_header_struct_size(buf)
        self.header_end = self.header_start + header_size

        buf = self._read_bytes(self.input_stream, header_size - struct_lead_size)
        self.header_data.write(buf)

    def _get_header_struct_size(self, struct_lead):
        """
        Compute the size in bytes of the rpm header struct starting at the current
        position in package_file.
        """
        # Read the number of index entries
        header_index = struct_lead[8:12]
        (header_index_value, ) = struct.unpack('>I', header_index)

        # Read the the size of the header data store
        header_store = struct_lead[12:16]
        (header_store_value, ) = struct.unpack('>I', header_store)

        # The total size of the header. Each index entry is 16 bytes long.
        header_size = 8 + 4 + 4 + header_index_value * 16 + header_store_value

        # Headers end on an 8-byte boundary. Round out the extra data.
        round_out = header_size % 8
        if round_out != 0:
            header_size = header_size + (8 - round_out)

        return header_size

    def save_payload(self, output_stream):
        hash = checksum.hashlib.new(self.checksum_type)
        if output_stream:
            output_start = output_stream.tell()
        self.header_data.seek(0,0)
        self._stream_copy(self.header_data, output_stream, hash)
        self._stream_copy(self.input_stream, output_stream, hash)
        self.checksum = hash.hexdigest()
        self.header_data.close()
        if output_stream:
            self.payload_stream = output_stream
            self.payload_size = output_stream.tell() - output_start

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

SHARED_TS=None
def get_package_header(filename=None, file=None, fd=None):
    """ Loads the package header from a file / stream / file descriptor
        Raises rpm.error if an error is found, or InvalidPacageError if package is
        busted
    """
    global SHARED_TS
    # XXX Deal with exceptions better
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

    # don't try to use rpm.readHeaderFromFD() here, it brokes signatures
    # see commit message
    if not SHARED_TS:
        SHARED_TS = rpm.ts()
    SHARED_TS.setVSFlags(-1)

    rpm.addMacro('_dbpath', '/var/cache/rhn/rhnpush-rpmdb')
    try:
        hdr = SHARED_TS.hdrFromFdno(file_desc)
        rpm.delMacro('_dbpath')
    except:
        rpm.delMacro('_dbpath')
        raise

    if hdr is None:
        raise InvalidPackageError
    is_source = hdr[rpm.RPMTAG_SOURCEPACKAGE]

    return RPM_Header(hdr, is_source)

class MatchIterator:
    def __init__(self, tag_name=None, value=None):
        # Query by name, by default
        if not tag_name:
            tag_name = "name"

        # rpm 4.1 or later
        self.ts = rpm.TransactionSet()
        self.ts.setVSFlags(8)

        m_args = (tag_name,)
        if value:
            m_args += (value,)
        self.mi = self.ts.dbMatch(*m_args)

    def pattern(self, tag_name, mode, pattern):
        self.mi.pattern(tag_name, mode, pattern)

    def next(self):
        try:
            hdr = self.mi.next()
        except StopIteration:
            hdr = None

        if hdr is None:
            return None
        is_source =  hdr[rpm.RPMTAG_SOURCEPACKAGE]
        return RPM_Header(hdr, is_source)


def headerLoad(data):
    hdr = rpm.headerLoad(data)
    is_source =  hdr[rpm.RPMTAG_SOURCEPACKAGE]
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


def sortRPMs(rpms):
    """ Sorts a list of RPM files. They *must* exist.  """

    assert isinstance(rpms, type([]))

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
