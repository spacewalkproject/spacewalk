#
# Copyright (c) 2008--2010 Red Hat, Inc.
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

import rhnpush_config
import unittest


class RhnConfigTestCase(unittest.TestCase):
    def setUp(self):
        self.userconfig = rhnpush_config.rhnpushConfigParser('.rhnpushrc')
        self.defaultconfig = rhnpush_config.rhnpushConfigParser('/etc/sysconfig/rhn/rhnpushrc')

    def tearDown(self):
        self.userconfig = None
        self.defaultconfig = None

    def testReadConfigFiles(self):
        self.userconfig._read_config_files()
        self.defaultconfig._read_config_files()
        assert self.userconfig.settings != None and self.defaultconfig.settings != None

    def testGetOption(self):
        a = self.userconfig.get_option('usage')
        b = self.defaultconfig.get_option('usage')
        assert a != None and b != None and a == '0' and b == '0'

    def testKeys(self):
        a = self.userconfig.keys()
        b = self.defaultconfig.keys()
        assert a != None and b != None

    def test_keys(self):
        a = self.userconfig._keys()
        b = self.defaultconfig._keys()
        assert a != None and b != None

    def testGetItem(self):
        pass

    def testAddConfigAsAttr(self):
        self.userconfig._add_config_as_attr()
        self.userconfig._add_config_as_attr()
        assert self.userconfig.usage != None and self.defaultconfig.usage != None

if __name__ == "__main__":
    unittest.main()
