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
# consistent (predictable) time functions
#
# Author: taw@redhat.com
#
# NOTE: translating seconds to years is an approximation. I.e., xxx secs *
#       365 not really right. Some years do not come out to 365 days.
#    
# $Id$

#
# The Unix Epoch is/was: 1970-01-01 00:00:00
#
# NOTE: the POSIX time range is defined (for 32 bit machines) as:
#       seconds: -2147483648L - 2147483647L
#       readable: 1901-12-13 20:45:52 - 2038-01-19 03:14:07
#       tuples: (1901, 12, 13, 20, 45, 52, 4, 347, 0)
#            to (2038,  1, 19,  3, 14,  7, 1,  19, 0)
#


from time import strftime, strptime, mktime, gmtime, timezone
_struct_time = type(())
try:
    # struct_time not in python 1.5.2
    from time import struct_time
    _struct_time = struct_time
except ImportError:
    pass
from time import time

MIN = 60.0
HOUR = 60 * MIN
DAY = 24 * HOUR
WEEK = 7 * DAY
YEAR = 365 * DAY

MAXINT, MININT = int(2L**31 - 1), int(-2L**31)

class LeapYearException(Exception):
    "exception for leap year related things"

def isLeapYearYN(year):
    yn4 = year/4.0
    if round(yn4) == yn4:
        # so far, yes
        yn100 = year/100.0
        if round(yn100) == yn100:
            yn400 = year/400.0
            return round(yn400) == yn400
        return 1
    return 0

def checkLeapDay(tup):
    "raises an exception if a leap day but not valid"
    if not isLeapYearYN(tup[0]) and tup[1] == 2 and tup[2] == 29:
        raise LeapYearException(repr(tup))


def now():
    return round(time())

def secs2str(format, secs):
    assert type(secs) in (type(1), type(1.0))
    return strftime(format, gmtime(round(secs)))
str2tup = strptime
    # str2tup(s, format)
def tup2secs(tup):
    assert isinstance(tup, _struct_time)
    return mktime(tup) - timezone
def secs2tup(secs):
    assert type(secs) in (type(1), type(1L), type(1.0))
    return gmtime(round(secs))
def tup2str(format, tup):
    return secs2str(format, tup2secs(tup))
def str2secs(s, format):
    return tup2secs(str2tup(s, format))

def str2str(s, formatIn, formatOut):
    return tup2str(formatOut, str2tup(s, formatIn))


def checkTuple(tup, ignoreLeapYear=0):
    """ checks validity of a time tuple. Raises ValueError or LeapYearException
        Time tuple is: (YYYY, MM, DD, hh, mm, ss, wkday, day, dst)
                       (   0,  1,  2,  3,  4,  5,     6,   7    8)
        YYYY = 1901 - 1938 (for 32-bit boxes)
        MM = 01 - 12
        DD = 01 - 31
        hh, mm, ss = the obvious
        wkday = 0 - 6
        day = 1 - 366
        dst = -1, 0, 1 (-1=no-info, 0=not-dst, 1=dst)
    """

    if 0 in tup[0:3]:
        raise ValueError("Year, month, and day must be a non-negative, positive number: %s" % tup)

    # month
    if tup[1] not in range(1, 13):
        raise ValueError("Month value is calculated to within a range of 1-12: %s" % tup)

    # day
    if tup[2] not in range(1, 32):
        raise ValueError("Day value is calculated to within a range of 1-31: %s" % tup)

    # days
    if tup[7] not in range(1, 367):
        raise ValueError("Days value is calculated to within a range of 1-367: %s" % tup)

    # leapyear check
    if not ignoreLeapYear:
        # can raise LeapYearException
        checkLeapDay(tup)

    # 31-day month check
    if tup[2] == 31:
        if tup[1] not in (1, 3, 5, 7, 8, 10, 12):
            raise ValueError("Day value can't exceed 31 for months (2, 4, 6, 9, 11): %s" % tup)

    # epoch rollunder check
    t = secs2tup(MININT)
    underYN = 0
    if tup[0] < t[0]:
        underYN = 1
    elif tup[0] == t[0]:
        if tup[1] < t[1]:
            underYN = 1
        elif tup[1] == t[1]:
            if tup[2] < t[2]:
                underYN = 1
            elif tup[2] == t[2]:
                if tup[3] < t[3]:
                    underYN = 1
                elif tup[3] == t[3]:
                    if tup[4] < t[4]:
                        underYN = 1
                    elif tup[4] == t[4]:
                        if tup[5] < t[5]:
                            underYN = 1
    if underYN:
        raise ValueError('Tuple "under"flows the POSIX Epoch: %s' % tup)

    # epoch rollover check
    t = secs2tup(MAXINT)
    overYN = 0
    if tup[0] > t[0]:
        overYN = 1
    elif tup[0] == t[0]:
        if tup[1] > t[1]:
            overYN = 1
        elif tup[1] == t[1]:
            if tup[2] > t[2]:
                overYN = 1
            elif tup[2] == t[2]:
                if tup[3] > t[3]:
                    overYN = 1
                elif tup[3] == t[3]:
                    if tup[4] > t[4]:
                        overYN = 1
                    elif tup[4] == t[4]:
                        if tup[5] > t[5]:
                            overYN = 1
    if overYN:
        raise ValueError("Tuple overlows the POSIX Epoch: %s" % tup)


def tup_addYMD(tup, years=0, months=0, days=0, ignoreLeapYear=0):
    """ add years, months, days to a time tuple, checking for leap year
        sensibilities. Can throw a LeapYearException or ValueError.
    """
    tup = list(tup)
    tup[0], tup[1], tup[2], tup[7] = tup[0]+years, tup[1]+months, tup[2]+days, tup[7]+days
    tup = _struct_time(tup)
    checkTuple(tup)
    return tup


def years2secs(years):
    "an approximation"
    return years*YEAR
def weeks2secs(weeks):
    return weeks*WEEK
def days2secs(days):
    return days*DAY
def hours2secs(hours):
    return hours*HOUR
def mins2secs(mins):
    return mins*MIN


def secs2mins(secs):
    return round(secs/MIN)
def secs2hours(secs):
    return round(secs/HOUR)
def secs2days(secs):
    return round(secs/DAY)
def secs2weeks(secs):
    return round(secs/WEEK)
def secs2years(secs):
    "an approximation"
    return round(secs/YEAR)

#-----------------------------------------------------------------------------

def _test():
    nowS = now()
    F = '%b %d %H:%M:%S %Y'
    print 'Right now, in seconds (epoch): ', nowS
    print 'Right now, stringified:        ', secs2str(F, nowS)

    print 'One year from now, in seconds:                                                  ', nowS+YEAR
    print 'One year from now, secs2tup:                                                    ', secs2tup(nowS+YEAR)
    print '(1)...secs2str(F, ...):                                                         ',\
                                                   secs2str(F, nowS+YEAR)
    print '(2)...str2tup(secs2str(F, ...), F):                                             ',\
                                            str2tup(secs2str(F, nowS+YEAR), F)
    print '(3)...tup2secs(str2tup(secs2str(F, ...), F)):                                   ',\
                                   tup2secs(str2tup(secs2str(F, nowS+YEAR), F))
    print '(4)...secs2tup(tup2secs(str2tup(secs2str(F, ...), F))):                         ',\
                          secs2tup(tup2secs(str2tup(secs2str(F, nowS+YEAR), F)))
    print '(5)...tup2str(F, secs2tup(tup2secs(str2tup(secs2str(F, ...), F)))):             ',\
               tup2str(F, secs2tup(tup2secs(str2tup(secs2str(F, nowS+YEAR), F))))
    print '(6)...str2secs(tup2str(F, secs2tup(tup2secs(str2tup(secs2str(F, ...), F)))), F):',\
      str2secs(tup2str(F, secs2tup(tup2secs(str2tup(secs2str(F, nowS+YEAR), F)))), F)
    print "%s --> %s" % (secs2str(F, nowS+YEAR),
                         str2str(secs2str(F, nowS+YEAR), F,
                                 "%Y-%m-%d %H:%M:%S"))


    print 'YEAR, WEEK, DAY, HOUR, MIN: ', YEAR, WEEK, DAY, HOUR, MIN
    print 'years2secs(1):   ', years2secs(1)
    print 'weeks2secs(1):   ', weeks2secs(1)
    print 'days2secs(1):    ', days2secs(1)
    print 'hours2secs(1):   ', hours2secs(1)
    print 'mins2secs(1):    ', mins2secs(1)
    print 'secs2mins(MIN):  ', secs2mins(MIN)
    print 'secs2hours(HOUR):', secs2hours(HOUR)
    print 'secs2days(DAY):  ', secs2days(DAY)
    print 'secs2weeks(WEEK):', secs2weeks(WEEK)
    print 'secs2years(YEAR):', secs2years(YEAR)

    print
    print 'Now (reminder) now:  %s, %s' % (nowS, secs2tup(nowS))
    print ('TRULY one year, one month, one day from now:\n'
           '- in seconds:  %s'
           % str(tup2secs(tup_addYMD(secs2tup(nowS),
                                     1,1,1, ignoreLeapYear=1))))
    print ('- as a tuple:  %s'
           % str(tup_addYMD(secs2tup(nowS), 1,1,1, ignoreLeapYear=1)))

    try:
        tup = _struct_time((2004, 02, 28, 6, 35, 14, 0, 285, 1))
        print 'This is a good leap day: %s' % str(tup_addYMD(tup, 0,0,1))
    except LeapYearException, e:
        print 'Verified correctly bad! - %s' % e
    else:
        print 'Verified good!'

    try:
        tup = _struct_time((2005, 02, 28, 6, 35, 14, 0, 285, 1))
        # for printing
        print 'This is a bad leap day: %s' % str(tup_addYMD(tup, 0,0,1, ignoreLeapYear=1))
        # for breaking
        tup_addYMD(tup, 0,0,1)
    except LeapYearException, e:
        print 'Verified correctly bad! - %s' % e
    else:
        print 'Verified good!'

    print "Tuple sanity checks"
    t = secs2tup(MAXINT) 
    t = list(t)
    t[5] = t[5] + 1
    t = _struct_time(t)
    print "One second over the POSIX Epoch max: %s" % t
    try:
        print "checkTuple(t)..."; checkTuple(t)
    except Exception, e:
        print e
    t = secs2tup(MININT)
    t = list(t)
    t[5] = t[5] - 1
    t = _struct_time(t)
    print "One second under the POSIX Epoch min: %s" % t
    try:
        print "checkTuple(t)..."; checkTuple(t)
    except Exception, e:
        print e

    print "Not testing all checkTuple checks."

    print "April does not have 31 days..."
    t = secs2tup(0)
    t = list(t)
    t[1] = 4 # april
    t[2] = 31
    t = _struct_time(t)
    try:
        print "checkTuple(t)..."; checkTuple(t)
    except Exception, e:
        print e

    print "March does have 31 days..."
    t = secs2tup(0)
    t = list(t)
    t[1] = 3 # march
    t[2] = 31
    t = _struct_time(t)
    try:
        print "checkTuple(t)..."; checkTuple(t)
    except Exception, e:
        print e



if __name__ == '__main__':
    _test()

