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
import rhnpush_cache
import time

class UserInfoTestCase(unittest.TestCase):
        def setUp(self):
                self.userinfo = rhnpush_cache.UserInfo(5, username='wregglej', password='password')

        def tearDown(self):
                self.userinfo = None

        def testCheckCacheTrue(self):
                assert self.userinfo.checkCache() == True

        def testCheckCacheFalse(self):
                time.sleep(7)
                assert self.userinfo.checkCache() == False

        def testSetUsernamePassword(self):
                self.userinfo = rhnpush_cache.UserInfo( 5, username='wregglej', password='password')
                self.userinfo.setUsernamePassword('aaaa', 'bbbb')
                assert self.userinfo.username != 'wregglej' and self.userinfo.password != 'password'

        def testSetUsernamePassword3(self):
                self.userinfo = rhnpush_cache.UserInfo( 5, username='wregglej', password='password')
                self.userinfo.setUsernamePassword('aaaa', 'bbbb')
                assert self.userinfo.username == 'aaaa' and self.userinfo.password == 'bbbb'

        def testGetUsernamePassword(self):
                self.userinfo = rhnpush_cache.UserInfo( 5, username='wregglej', password='password')
                assert self.userinfo.username == 'wregglej' and self.userinfo.password == 'password'

        def testIsFresh(self):
                self.userinfo = rhnpush_cache.UserInfo( 5, username='wregglej', password='password')
                assert self.userinfo.isFresh() == True

        def testIsntFresh(self):
                time.sleep(6)
                assert self.userinfo.isFresh() == False

        def testSetCacheLifetime(self):
                self.userinfo = rhnpush_cache.UserInfo( 5, username='wregglej', password='password')
                self.userinfo.setCacheLifetime(6667)
                assert self.userinfo.cache_lifetime != 5 and self.userinfo.cache_lifetime == 6667

        def testGetTimeLeft(self):
                self.userinfo = rhnpush_cache.UserInfo( 10, username='wregglej', password='password')
                time.sleep(2.0)
                assert self.userinfo.getTimeLeft() >= 7.98 and self.userinfo.getTimeLeft() <= 8.002

class CacheManagerTestCase(unittest.TestCase):
        def setUp(self):
                self.cache = rhnpush_cache.CacheManager(5)

        def tearDown(self):
                self.cache = None

        def testIsFresh(self):
                self.cache = rhnpush_cache.CacheManager(5)
                self.cache.setUsernamePassword('a','b')
                assert self.cache.isFresh() == True

        def testIsntFresh(self):
                self.cache = rhnpush_cache.CacheManager(5)
                time.sleep(7)
                assert self.cache.isFresh() == False

        def testSetUsernamePassword(self):
                self.cache = rhnpush_cache.CacheManager(5)
                self.cache.setUsernamePassword('wregglej', 'password')
                #print self.cache.cache.username
                assert self.cache.cache.username == 'wregglej' and self.cache.cache.password == 'password'

        def testSetUsernamePassword2(self):
                self.cache = rhnpush_cache.CacheManager(5)
                self.cache.setUsernamePassword('wregglej', 'password')
                self.cache.setUsernamePassword('aaaa', 'bbbb')
                assert self.cache.cache.username == 'aaaa' and self.cache.cache.password == 'bbbb'

        def testGetUsernamePassword(self):
                self.cache = rhnpush_cache.CacheManager(5)
                self.cache.setUsernamePassword('wregglej', 'password')
                u,p = self.cache.getUsernamePassword()
                assert u == 'wregglej' and p == 'password'

        def testSetCacheLifetime(self):
                self.cache = rhnpush_cache.CacheManager(5)
                self.cache.setCacheLifetime(10)
                assert self.cache.cache.cache_lifetime == 10 and self.cache.cache.cache_lifetime != 5

        def testWriteCache(self):
                pass
        def testGetTimeLeft(self):
                pass

if __name__ == "__main__":
        unittest.main()
