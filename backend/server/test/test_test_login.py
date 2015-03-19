#
# Copyright (c) 2008--2015 Red Hat, Inc.
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
import TestServer
import server.app.packages


class TestLoginTestCase(unittest.TestCase):

    def setUp(self):
        self.myserver = TestServer.TestServer()
        self.packages = server.app.packages.Packages()

    def tearDown(self):
        pass

    def testReturnType(self):
        assert type(self.packages.test_login(self.myserver.getUsername(), self.myserver.getPassword())) == type(1)

    def testReturnValue(self):
        assert self.packages.test_login(self.myserver.getUsername(), self.myserver.getPassword()) == 1

    def testReturnValue2(self):
        assert self.packages.test_login("afdafdsfasdf", "afdfadfa") == 0

if __name__ == "__main__":
    unittest.main()
