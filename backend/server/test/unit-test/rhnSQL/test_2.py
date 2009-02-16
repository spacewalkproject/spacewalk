#!/usr/bin/python
#Copyright (c) 2005, Red Hat Inc.
#
#
#
# $Id$

import unittest
from server import rhnSQL

class ExceptionsTest(unittest.TestCase):
    def test_failed_connection(self):
        self.assertRaises(rhnSQL.SQLConnectError, rhnSQL.initDB, 'x/y@z')

if __name__ == '__main__':
    unittest.main()
