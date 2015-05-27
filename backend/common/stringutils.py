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

from types import StringType, UnicodeType


def to_unicode(obj):
    if isinstance(obj, StringType):
        return unicode(obj, 'utf8')
    else:
        return obj


def to_string(obj):
    if isinstance(obj, UnicodeType):
        return obj.encode('utf8')
    else:
        return obj
