#!/usr/bin/python

import settestpath

from up2date_client import up2dateUtils

import unittest

TestCase = unittest.TestCase
test_up2date = "etc-sysconfig-rhn/up2date"


class TestGetVersion(TestCase):
    def setUp(self):
        from up2date_client import config
        self.cfg = config.initUp2dateConfig(test_up2date)

    def testVersionOverride(self):
        "Verify that specify a version overide works"
        self.cfg['versionOverride'] = "100"
        res = up2dateUtils.getVersion()
        assert res == "100"


def suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(TestGetVersion))
    return suite

if __name__ == "__main__":
    unittest.main(defaultTest="suite")
