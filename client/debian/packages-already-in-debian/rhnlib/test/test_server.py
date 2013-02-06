#!/usr/bin/python
#
#
# $Id$

import unittest
from rhn.rpclib import Server
from rhn.rpclib import MalformedURIError

class ServerTest(unittest.TestCase):

#    def setUp(self):

#    def tearDown(self):

    def testGoodURIWithHTTP(self):
        try:
            Server("http://localhost")
        except:
            assert False

    def testGoodURIWithHTTPS(self):
        try:
            Server("https://localhost")
        except:
            assert False

    def testURIMissingProtocol(self):
        self.assertRaises(MalformedURIError, Server, "localhost")

    def testURIMissingHost(self):
        self.assertRaises(MalformedURIError, Server, "http://")

    def testURIMissingHostAndSlashes(self):
        self.assertRaises(MalformedURIError, Server, "http:")

    def testURIWithGarbageInsteadOfSlashesAndHost(self):
        self.assertRaises(MalformedURIError, Server, "http:alsofh")

    def testURIMissingColon(self):
        self.assertRaises(MalformedURIError, Server, "http//localhost")


if __name__ == "__main__":
    unittest.main()
