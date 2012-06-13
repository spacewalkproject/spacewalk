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

import unittest
import utils

class TestObj1:
    def __init__(self):
        self.a = 1
        self.b = 2
        self.c = 3
        self._d = '1'
        self._e = '2'

    def _private_function(self):
        print "This is privatei to TestObj1 instances"

    def public_function(self):
        print "This is public and belongs to TestObj1"

class TestObj2:
    def __init__(self):
        self.a = 4
        self.b = 5
        self.c = 6
        self._d = '4'
        self._e = '5'
        self.f = 'aaa'

    def _private_function(self):
        print "This is private to TestObj2 instances"

    def public_function(self):
        print "This is public and belongs to TestObj2"



class UtilsTestCase(unittest.TestCase):
    def setUp(self):
        self.obj1 = TestObj1()
        self.obj2 = TestObj2()

    def tearDown(self):
        self.obj1 = None
        self.obj2 = None

    def testMakeCommonAttrEqual(self):
        self.obj1, self.obj2 = utils.make_common_attr_equal(self.obj1, self.obj2)
        assert self.obj1._d == '1' and self.obj2._d == '4' and self.obj1.a == 4 and self.obj1.b == 5 and self.obj1.c == 6 and self.obj2.f == 'aaa'

    def testAttrNotFunction(self):
        assert utils.attr_not_function(self.obj1.__dict__['a']) == True

if __name__ == "__main__":
    unittest.main()
