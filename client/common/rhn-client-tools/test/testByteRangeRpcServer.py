#!/usr/bin/python

import sys

import settestpath

import unittest

#Import the modules you need to test...
from up2date_client import clientCaps


class TestClientCaps(unittest.TestCase):
    def testEmptyInit(self):
        "Verify that the class can be created with no arguments"
        cc = clientCaps.ClientCapabilities()

    def testPopulate(self):
        "Verify the object gets created with an approriate populated data"
        cc = clientCaps.ClientCapabilities()
        len = cc.keys()
        self.assertTrue(len >= 1)

    def testHeaderFormat(self):
        "Verify that headerFormat runs without errors"
        cc = clientCaps.ClientCapabilities()
        res = cc.headerFormat()
        self.assertEquals(type([]),  type(res))


def suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(TestClientCaps))
    return suite

if __name__ == "__main__":
    unittest.main(argv=sys.argv)
