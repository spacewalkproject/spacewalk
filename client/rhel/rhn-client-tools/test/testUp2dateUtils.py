#!/usr/bin/python

import settestpath

from up2date_client import up2dateUtils

import unittest

TestCase = unittest.TestCase
test_up2date = "etc-sysconfig-rhn/up2date"

class ReturnsString(TestCase):
    def testReturnsString(self):
        "Verify that function returns string"
        assert type(self.function()) == type("")

    def testNonZoreLength(self):
        "Verify that function returns a non zero length string"
        assert len(self.function()) > 0

class TestGetVersion(ReturnsString):
    def setUp(self):
        from up2date_client import config
        self.cfg = config.initUp2dateConfig(test_up2date)
        self.function = up2dateUtils.getVersion

    def testVersionOverride(self):
        "Verify that specify a version overide works"
        self.cfg['versionOverride'] = "100"
        res = up2dateUtils.getVersion()
        assert res == "100"

class TestGetOSRelease(ReturnsString):
    def setUp(self):
        self.function = up2dateUtils.getOSRelease

class TestGetRelease(ReturnsString):
    def setUp(self):
        self.function = up2dateUtils.getRelease

class TestGetArch(ReturnsString):
    def setUp(self):
        self.function = up2dateUtils.getArch

    def testIa32eOverride(self):
        "Verify that function does not return ia32e #216225"
        arch = self.function()
        assert arch.find('ia32e') == -1

class TestVersion(ReturnsString):
    def setUp(self):
        self.function = up2dateUtils.version

def suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(TestGetVersion))
    suite.addTest(unittest.makeSuite(TestGetOSRelease))
    suite.addTest(unittest.makeSuite(TestGetRelease))
    suite.addTest(unittest.makeSuite(TestGetArch))
    suite.addTest(unittest.makeSuite(TestVersion))
    return suite

if __name__ == "__main__":
    unittest.main(defaultTest="suite")
