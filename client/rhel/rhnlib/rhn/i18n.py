#
# This module contains all the RPC-related functions the RHN code uses
#
# Copyright (c) 2016 Red Hat, Inc.
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

from sys import version_info

try:
    PY3 = version_info.major >= 3
except AttributeError:
    PY3 = False


def ustr(obj):
    # converts object to unicode like object
    if PY3: # python3
        if isinstance(obj, str):
            return obj
        else:
            return str(obj, 'utf8', 'ignore')
    else: # python2
        if isinstance(obj, unicode):
            return obj
        return unicode(obj, 'utf8', 'ignore')

def bstr(obj):
    # converts object to bytes like object
    if PY3: # python3
        if isinstance(obj, bytes):
            return obj
        else:
            return bytes(obj, 'utf8', 'ignore')
    else: # python2
        if isinstance(obj, str):
            return obj
        return str(obj.encode('utf8', 'ignore'))

def sstr(obj):
    # converts object to string
    if PY3: # python3
        if isinstance(obj, str):
            return obj
        else:
            return str(obj, 'utf8', 'ignore')
    else: # python2
        if isinstance(obj, str):
            return obj
        return str(obj.encode('utf8', 'ignore'))
