#!/usr/bin/python
#
# Copyright (c) 2008--2012 Red Hat, Inc.
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
import unittest
from spacewalk.common import rhnCache

class Tests(unittest.TestCase):
    # pylint: disable=R0904
    key = "unit-test/test"
    content = ""
    for i in range(256):
        content = content + chr(i)

    def test_cache_1(self):
        "Tests storing of simple strings"
        content = self.content * 10
        self._test(self.key, content)

    def test_cache_2(self):
        "Tests storing of more complex data structures"
        content = [ (1, 2, 3), {'a' : 1}, 'ab' ] 
        self._test(self.key, content)
        
    def test_cache_3(self):
        "Tests storing of raw content"
        content = self.content * 10
        self._test(self.key, content, raw=1)

    def test_cache_4(self):
        "Tests storing of raw content"
        content = self.content * 10
        self._test(self.key, content, raw=1, modified='20041110001122')

    def _test(self, key, content, **modifiers):
        # Blow it away
        rhnCache.CACHEDIR = '/tmp/rhn'
        self._cleanup(key)
        rhnCache.set(key, content, **modifiers)
        self.failUnless(rhnCache.has_key(key))
        content2 = rhnCache.get(key, **modifiers)
        self.assertEqual(content, content2)

        self._cleanup(key)
        self.failIf(rhnCache.has_key(key))
        return (key, content)

    def test_cache_5(self):
        content = self.content * 10
        timestamp = '20041110001122'

        self._cleanup(self.key)
        rhnCache.set(self.key, content, modified=timestamp)

        self.failUnless(rhnCache.has_key(self.key))
        self.failUnless(rhnCache.has_key(self.key, modified=timestamp))
        self.failIf(rhnCache.has_key(self.key, modified='20001122112233'))
        self._cleanup(self.key)
        
    def test_missing_1(self):
        "Tests exceptions raised by the code"
        self._cleanup(self.key)
        self.assertEqual(None, rhnCache.get(self.key))

    def test_exception_1(self):
        "Tests raising exceptions"
        self.assertRaises(KeyError, rhnCache.get, self.key, missing_is_null=0)

    def _cleanup(self, key):
        if rhnCache.has_key(key):
            rhnCache.delete(key)

        self.failIf(rhnCache.has_key(key))

if __name__ == '__main__':
    sys.exit(unittest.main() or 0)

