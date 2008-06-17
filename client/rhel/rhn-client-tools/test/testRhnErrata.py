#!/usr/bin/python

import sys

import settestpath

from up2date_client import rhnErrata
# lots of useful util methods for building/tearing down
# test enviroments...
import testutils

import unittest

def write(blip):
    sys.stdout.write("\n|%s|\n" % blip)

class TestRhnErrata(unittest.TestCase):
    def setUp(self):
        self.__setupData()
        testutils.setupConfig("channelTest1")

    def __setupData(self):
        pass
    
    def tearDown(self):
        testutils.restoreConfig()

    def testGetAdvisoryInfo(self):
        res = rhnErrata.getAdvisoryInfo(["sendmail", "8.12.8", "5.90", ""])
        write(res)


def suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(TestRhnErrata))
    return suite

if __name__ == "__main__":
    unittest.main(argv=sys.argv)
