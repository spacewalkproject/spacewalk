#
# Copyright (c) 2008--2009 Red Hat, Inc.
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

import spacewalk.test.setpath
from common.rhnLib import parseUrl

class RhnLibTests(unittest.TestCase):

    def testParseUrl(self):
        self.assertEquals(('', '', '', '', '', ''),
                parseUrl(''))
        self.assertEquals(('', 'somehostname', '', '', '', ''),
                parseUrl('somehostname'))
        self.assertEquals(('http', 'somehostname', '', '', '', ''),
                parseUrl('http://somehostname'))
        self.assertEquals(('https', 'somehostname', '', '', '', ''),
                parseUrl('https://somehostname'))
        self.assertEquals(('https', 'somehostname:123', '', '', '', ''),
                parseUrl('https://somehostname:123'))
        self.assertEquals(('https', 'somehostname:123', '/ABCDE', '', '', ''),
                parseUrl('https://somehostname:123/ABCDE'))

