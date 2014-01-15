#!/usr/bin/python
# Copyright (c) 2005--2010 Red Hat, Inc.
#
#
#

import unittest
from spacewalk.server import rhnSQL

class ExceptionsTest(unittest.TestCase):
    def test_failed_connection(self):
        # Connect to localhost and look for db on a totally bogus port, this
        # makes the test faster.
        host     = "localhost"
        username = "x"
        password = "y"
        database = "z"
        port     = 9000

        self.assertRaises(
            rhnSQL.SQLConnectError,
            rhnSQL.initDB,
            "oracle",
            host,
            port,
            database,
            username,
            password
        )

if __name__ == '__main__':
    unittest.main()
