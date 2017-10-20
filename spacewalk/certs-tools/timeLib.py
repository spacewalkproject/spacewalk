#
# Copyright (c) 2008--2013 Red Hat, Inc.
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
# consistent (predictable) time functions
#
# Author: taw@redhat.com
#
# NOTE: translating seconds to years is an approximation. I.e., xxx secs *
#       365 not really right. Some years do not come out to 365 days.
#

#
# The Unix Epoch is/was: 1970-01-01 00:00:00
#
# NOTE: the POSIX time range is defined (for 32 bit machines) as:
#       seconds: -2147483648L - 2147483647L
#       readable: 1901-12-13 20:45:52 - 2038-01-19 03:14:07
#       tuples: (1901, 12, 13, 20, 45, 52, 4, 347, 0)
#            to (2038,  1, 19,  3, 14,  7, 1,  19, 0)
#


from __future__ import print_function
from time import strftime, strptime, mktime, gmtime, timezone
from time import time

MIN = 60.0
HOUR = 60 * MIN
DAY = 24 * HOUR
WEEK = 7 * DAY
YEAR = 365 * DAY

def now():
    return round(time())

def secs2str(format, secs):
    assert type(secs) in (type(1), type(1.0))
    return strftime(format, gmtime(round(secs)))
def str2secs(s, format):
    return mktime(strptime(s, format)) - timezone

def secs2days(secs):
    return round(secs/DAY)
def secs2years(secs):
    "an approximation"
    return round(secs/YEAR)

#-----------------------------------------------------------------------------

def _test():
    nowS = now()
    F = '%b %d %H:%M:%S %Y'
    print('Right now, in seconds (epoch): ', nowS)
    print('Right now, stringified:        ', secs2str(F, nowS))

    print('YEAR, WEEK, DAY, HOUR, MIN: ', YEAR, WEEK, DAY, HOUR, MIN)
    print('secs2days(DAY):  ', secs2days(DAY))
    print('secs2years(YEAR):', secs2years(YEAR))

if __name__ == '__main__':
    _test()

