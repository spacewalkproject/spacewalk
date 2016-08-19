#
# Copyright (c) 2013--2016 Red Hat, Inc.
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

import sys
import types

PY2 = sys.version_info[0] == 2
PY3 = sys.version_info[0] == 3


# Common data types
# Common data types
if PY3:
    BufferType = memoryview
    UnicodeType = str
    StringType = bytes
    DictType = dict
    IntType = int
    LongType = int
    ListType = list
    ClassType = type
    FloatType = float
    TupleType = tuple
    TypeType = type
    InstanceType = object
else:
    BufferType = types.BufferType
    UnicodeType = unicode
    StringType = types.StringType
    DictType = types.DictType
    IntType = types.IntType
    LongType = types.LongType
    ListType = types.ListType
    ClassType = types.BufferType
    FloatType = types.FloatType
    TupleType = types.TupleType
    TypeType = types.TypeType
    InstanceType = types.InstanceType

# Common limits

if PY3:
    MaxInt = sys.maxsize
else:
    MaxInt = sys.maxint


# Common methods

# raise exception with traceback
# pylint: disable=W0122
if PY3:
    def raise_with_tb(value, tb=None):
        try:
            if value.__traceback__ is not tb:
                raise value.with_traceback(tb)
            raise value
        finally:
            value = None
            tb = None
else:
    exec("""
def raise_with_tb(value, tb=None):
    try:
        raise value, None, tb
    finally:
        tb = None
""")


# code from original 'six' module
# added for compatibility with Python 2.4
try:
    advance_iterator = next
except NameError:
    def advance_iterator(it):
        return it.next()
next = advance_iterator  # pylint: disable=W0622
