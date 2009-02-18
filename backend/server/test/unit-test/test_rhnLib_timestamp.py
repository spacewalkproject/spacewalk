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
#
#
#
# $Id$

import sys
import time
import unittest
from common import rhnLib

class Tests(unittest.TestCase):
    def _test_timestamp_1(self):
        # Start with some timestamp, and verify that 
        # timestamp(strftime(t)) is # t
        t = 85345
        increment = 123456
        while t < time.time() + increment:
            is_eq, t1, tstr, t2 = self._test(t)
            #self.assertEqual(t, t2, "%s %s %s %s" % (t, t2, ttuple, tstr))
            if not is_eq:
                print "%s %s %s" % (t1, t2, tstr)
            t = t + increment

    def _str(self, t):
        tformat = "%Y-%m-%d %H:%M:%S"
        ttuple = time.localtime(t)
        return time.strftime(tformat, ttuple)
        
    def _test(self, t):
        t = int(t)
        tstr = self._str(t)
        t2 = int(rhnLib.timestamp(tstr))
        return (t == t2), t, tstr, t2

    def _test_timestamp_2(self):
        y = 1969
        while y < 2015:
            y = y + 1
            # Guess that year's time switch
            tlist = [y, 10, 31, 1, 41, 37, 0, 0, -1]
            t = time.mktime(tlist)
            tlist = list(time.localtime(t))
            # Last Sat of October
            tlist[2] = tlist[2] - (1 + tlist[6]) % 7
            t = int(time.mktime(tlist))
            
            is_eq, t1, tstr, t2 = self._test(t)
            if not is_eq:
                print "%s %s %s" % (t, t2, tstr)
            
    def test_timestamp_3(self): 
        t = 57739297
        is_eq, t1, tstr, t2 = self._test(t)
        self.failUnless(is_eq, "Failed: %s, %s" % (t1, t2))

    def _test_timestamp_4(self): 
        return self.test_timestamp_3()

if __name__ == '__main__':
    sys.exit(unittest.main() or 0)

