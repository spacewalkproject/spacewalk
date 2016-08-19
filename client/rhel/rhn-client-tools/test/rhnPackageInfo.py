#!/usr/bin/python

import settestpath
import unittest

from up2date_client import rhnPackageInfo



class TestPprint_pkglist(unittest.TestCase):
    def setUp(self):
        self.pkgList1 = [["foo", "1.0", "1", "", "i386", "234234234", "some-channel"],
                         ["bar", "2.0", "2", "9", "i686", "34234234234234", "some-channel"]]

        self.pkgList2 = []
        self.pkgList3 = [a+["othercruft", "morecruft"] for a in self.pkgList1]

        # send it a tuple
        self.pkgList4 = ("foo", "1.0", "1", "", "i386", "234234234", "some-channel")
        self.pkgList5 = list(self.pkgList4)

    def testPprint_pkglist(self):
        """Verify that pprint_pkglist properly formats a package list"""
        res = rhnPackageInfo.pprint_pkglist(self.pkgList1)
        assert res == ['foo-1.0-1', 'bar-2.0-2']

    def testEmptyList(self):
        """Verify that pprint_pkglist properly handles a empty list"""
        res = rhnPackageInfo.pprint_pkglist(self.pkgList2)
        assert res == []

    def testTuple(self):
        """Verify that pprint_pkglist properly handles a single tuple"""
        res = rhnPackageInfo.pprint_pkglist(self.pkgList4)
        assert res == "foo-1.0-1"

    def testSingleList(self):
        """Verify that pprint_pkglist proper handles a single list (IndexError)"""
        try:
            res = rhnPackageInfo.pprint_pkglist(self.pkgList5)
            print res
        except IndexError:
            pass
        else:
            self.fail("expected a IndexError")

def suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(TestPprint_pkglist))
    return suite

if __name__ == "__main__":
    unittest.main(defaultTest="suite")
