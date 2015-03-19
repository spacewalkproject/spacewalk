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
from TestServer import TestServer
from spacewalk.server import xp, rhnSQL

#   Tests the functionality of the listMissingSourcePackages function of the packages.py file


class ListMissingTestCase(unittest.TestCase):

    def setUp(self):
        self.directory = '/home/devel/wregglej/downloads/srcrpms'
        self.myserver = TestServer()
        self.myserver.upload_packages(self.directory, source=1)
        self.packageobj = xp.packages.Packages()

    def tearDown(self):
        rhnSQL.rollback()

    def testPresence(self):
        if self.packageobj.listMissingSourcePackages:
            assert 1
        else:
            assert 0

    def testlistMissingSourcePackages(self):
        channel = self.myserver.getChannel()
        package_list = self.packageobj.listMissingSourcePackages([channel.get_label()],
                                                                 self.myserver.getUsername(),
                                                                 self.myserver.getPassword())
        if type(package_list) == type([]):
            assert 1
        else:
            assert 0

if __name__ == "__main__":
    unittest.main()
