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
#

import re

# common module
from common import log_debug, rhnException

# Parses the HTTP header value and stores in the flags  a list of (start, end)
# tuples that are more pythonic than the RFC semantics
def parse_byteranges(byterange_header, file_size = None):
    log_debug(4, "Parsing byte range", byterange_header)
    regexp = re.compile(r"^bytes\s*=\s*(.*)$")
    mo = regexp.match(byterange_header)
    if not mo:
        raise InvalidByteRangeException

    arr = mo.groups()[0].split(",")
    regexp = re.compile(r"^([^-]*)-([^-]*)$")

    if len(arr) > 1:
        # We don't support very fancy byte ranges yet
        raise UnsatisfyableByteRangeException

    mo = regexp.match(arr[0])
    if not mo:
        # Invalid byterange
        raise InvalidByteRangeException
    try:
        start, end = map(_str2int, mo.groups())
    except ValueError:
        # Invalid
        raise InvalidByteRangeException
    if start is not None:
        if start < 0:
            # Invalid
            raise InvalidByteRangeException
        if file_size is not None:
            if start >= file_size:
                raise UnsatisfyableByteRangeException
        if end is not None:
            if start > end:
                # Invalid
                raise InvalidByteRangeException
            end = end + 1
        else:
            if file_size:
                end = file_size
    else:
        # No start specified
        if end is None:
            # Invalid
            raise InvalidByteRangeException
        if end <= 0:
            # Invalid
            raise InvalidByteRangeException
        if file_size:
            if end > file_size:
                raise UnsatisfyableByteRangeException
            start = file_size - end
            end = file_size
        else:
            start = -end
            end = None

    byteranges = (start, end)

    log_debug(4, "Request byterange", byteranges)
    return byteranges

def _str2int(val):
    val = val.strip()
    if val is "":
        return None

    return int(val)

def get_content_range(start, end, total_length=None):
    if total_length is None:
        total_length = "*"
    end = end - 1
    content_range = "bytes %d-%d/%s" % (start, end, total_length)
    return content_range

class InvalidByteRangeException(rhnException):
    pass

class UnsatisfyableByteRangeException(rhnException):
    pass
