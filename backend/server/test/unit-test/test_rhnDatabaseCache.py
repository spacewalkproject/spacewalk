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

import os
import sys
import unittest
from server import rhnSQL, rhnDatabaseCache

DB = 'rhnuser/rhnuser@webdev'
    

class Tests(unittest.TestCase):

    def setUp(self):
        rhnSQL.initDB(DB)

    def tearDown(self):
        # Roll back any unsaved data
        rhnSQL.rollback()

    def get_content(self):
        filename = os.path.join(os.path.dirname(sys.argv[0]),
            "rhn-package-78527.xml")
        return open(filename).read() * 100

    def test_insert_1(self):
        key = 'xml-packages/27/rhn-package-78527.xml-alt'
        ts = 1056359720.0

        content = "0123456789" * 100

        rhnDatabaseCache.set(key, content, modified=ts, raw=1, compressed=1)

        val = rhnDatabaseCache.get(key, modified=ts, raw=1, compressed=1)
        self.assertEqual(val, content)


if __name__ == '__main__':
    sys.exit(unittest.main() or 0)
