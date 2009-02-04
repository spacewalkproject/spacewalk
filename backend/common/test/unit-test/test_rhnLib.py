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
# $Id$

import sys
import locale
import unittest
from common import rhnLib

class Tests(unittest.TestCase):

    ###########################################################################
    # Tests for rhnLib.fix_url()
    ###########################################################################

    def test_normal_1(self):
        "Simple call"
        test_url = 'http://example.com'
        result = rhnLib.fix_url(test_url)
        self.assertEqual(result, 'http://example.com/', test_url)

    def test_normal_2(self):
        "host has port number too"
        test_url = 'http://example.com:8080'
        result = rhnLib.fix_url(test_url)
        self.assertEqual(result, 'http://example.com:8080/', test_url)

    def test_normal_path_1(self):
        "Specifying path"
        test_url = 'http://example.com'
        result = rhnLib.fix_url(test_url, path='/abc')
        self.assertEqual(result, 'http://example.com/abc', test_url)

    def test_normal_scheme_1(self):
        "No scheme, default"
        test_url = 'example.com'
        result = rhnLib.fix_url(test_url)
        self.assertEqual(result, 'http://example.com/', test_url)
    
    def test_normal_scheme_2(self):
        "No scheme, scheme specified"
        test_url = 'example.com'
        result = rhnLib.fix_url(test_url, scheme='https')
        self.assertEqual(result, 'https://example.com/', test_url)

    def test_failure_bad_scheme_1(self):
        "Invalid default scheme"
        test_url = 'example.com'
        self.assertRaises(ValueError, rhnLib.fix_url, test_url, scheme='httpq')

    def test_failure_bad_scheme_2(self):
        "Invalid default scheme"
        test_url = 'ftp://example.com'
        self.assertRaises(rhnLib.InvalidUrlError, rhnLib.fix_url, test_url)

    ###########################################################################
    # Tests for rhnLib.rfc822time()
    ###########################################################################

    def test_rfc822time_normal_tuple_arg(self):
        "rfc822time: Simple call using a valid tuple argument."
        test_arg = (2006, 1, 27, 9, 12, 5, 4, 27, -1)
        target = "Fri, 27 Jan 2006 14:12:05 GMT"
        result = rhnLib.rfc822time(test_arg)
        self.assertEqual(result, target, result + " != " + target)
        
    def test_rfc822time_normal_list_arg(self):
        "rfc822time: Simple call using a valid list argument."
        test_arg = [2006, 1, 27, 9, 12, 5, 4, 27, -1]
        target = "Fri, 27 Jan 2006 14:12:05 GMT"
        result = rhnLib.rfc822time(test_arg)
        self.assertEqual(result, target, result + " != " + target)
        
    def test_rfc822time_normal_float_arg(self):
        "rfc822time: Simple call using a valid float argument."
        test_arg = 1138371125
        target = "Fri, 27 Jan 2006 14:12:05 GMT"
        result = rhnLib.rfc822time(test_arg)
        self.assertEqual(result, target, result + " != " + target)

    def test_rfc822time_japan_locale(self):
        "rfc822time: Test result in ja_JP locale."
        test_arg = 1138371125
        target = "Fri, 27 Jan 2006 14:12:05 GMT"
        old_locale = locale.getlocale(locale.LC_TIME)
        locale.setlocale(locale.LC_TIME, 'ja_JP')
        result = rhnLib.rfc822time(test_arg)
        locale.setlocale(locale.LC_TIME, old_locale)
        self.assertEqual(result, target, result + " != " + target)

if __name__ == '__main__':
    sys.exit(unittest.main() or 0)


