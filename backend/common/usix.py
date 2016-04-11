#
# Copyright (c) 2013--2015 Red Hat, Inc.
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

# we cannot use ternary operator 'a if test else b'
# because this code is Python 2.4 compatible, will use
# (falseValue, trueValue)[test]

UnicodeType = (types.UnicodeType, str)[PY3 == True]
StringType = (types.StringType, bytes)[PY3 == True]
DictType = (types.DictType, dict)[PY3 == True]
IntType = (types.IntType, int)[PY3 == True]
LongType = (types.LongType, int)[PY3 == True]
ListType = (types.ListType, list)[PY3 == True]
NoneType = (types.NoneType, type(None))[PY3 == True]
BooleanType = (types.BooleanType, bool)[PY3 == True]
ClassType = (types.BufferType, type)[PY3 == True]
ComplexType = (types.ComplexType, complex)[PY3 == True]
EllipsisType = (types.EllipsisType, type(Ellipsis))[PY3 == True]
FloatType = (types.FloatType, float)[PY3 == True]
ObjectType = (types.ObjectType, object)[PY3 == True]
NotImplementedType = (types.NotImplementedType, type(NotImplemented))[PY3 == True]
SliceType = (types.SliceType, slice)[PY3 == True]
TupleType = (types.TupleType, tuple)[PY3 == True]
TypeType = (types.TypeType, type)[PY3 == True]
XRangeType = (types.XRangeType, range)[PY3 == True]

if PY3:
        BufferType = memoryview
else:
        BufferType = types.BufferType

# Common limits

if PY3:
    MaxInt = sys.maxsize
else:
    MaxInt = sys.maxint


# Common methods

# raise exception with traceback
def raise_with_tb(exc, tb):
    if PY3:
        raise exc.with_traceback(tb)
    else:
        raise exc, None, tb
