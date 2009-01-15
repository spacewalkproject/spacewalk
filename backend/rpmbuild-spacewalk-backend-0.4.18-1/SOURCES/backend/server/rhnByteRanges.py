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
import string

# common module
from common import log_debug, rhnFlags

# Parses the HTTP header value and stores in the flags  a list of (start, end) 
# tuples that are more pythonic than the RFC semantics
def set_byteranges(byterange_header):
    log_debug(4, "Parsing byte range", byterange_header)
    regexp = re.compile(r"^bytes\s*=\s*(.*)$")
    mo = regexp.match(byterange_header)
    if not mo:
        # Invalid
        return
    arr = string.split(mo.groups()[0], ",")
    regexp = re.compile(r"^([^-]*)-([^-]*)$")
    byteranges = []
    for i in arr:
        mo = regexp.match(i)
        if not mo:
            # Invalid byterange
            continue
        try:
            start, end = map(_str2int, mo.groups())
        except ValueError:
            # Invalid
            continue
        if start is not None:
            if start < 0:
                # Invalid
                continue
            if end is not None:
                if start > end:
                    # Invalid
                    continue
                end = end + 1
        else:
            # No start specified
            if end is None:
                # Invalid
                continue
            if end <= 0:
                # Invalid
                continue
            start = -end
            end = None
        
        byteranges.append((start, end))

    rhnFlags.set("request-byterange", byteranges)
    log_debug(4, "Request byterange", byteranges)

def get_byteranges():
    return rhnFlags.get("request-byterange")

def _str2int(val):
    val = string.strip(val)
    if val is "":
        return None

    return int(val)
        
def set_content_range(start, end, total_length=None):
    if total_length is None:
        total_length = "*"
    end = end - 1
    content_range = "bytes %d-%d/%s" % (start, end, total_length)
    rhnFlags.get("outputTransportOptions")['Content-Range'] = content_range
    rhnFlags.set("return-code", 206)

def get_status_code():
    status = rhnFlags.get("return-code")
    if not status:
        return 200
    return status
