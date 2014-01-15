#!/usr/bin/python
# Copyright (c) 2005--2010 Red Hat, Inc.
#
#
#

import unittest
from spacewalk.common.rhnConfig import CFG, initCFG
from spacewalk.server import rhnSQL

import misc_functions

DB_SETTINGS = misc_functions.db_settings("oracle")


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

        try:
            rhnSQL.initDB(
                backend  = "oracle",
                username = DB_SETTINGS["user"],
                password = DB_SETTINGS["password"],
                database = DB_SETTINGS["database"]
            )
        except:
            self.fail("Exception raised while trying to connect to the db using proper settings. That's not expected to happen.")


if __name__ == '__main__':
    unittest.main()
