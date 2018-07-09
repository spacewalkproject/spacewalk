#!/usr/bin/python

import sys

import settestpath

import unittest

#Import the modules you need to test...
from up2date_client import pkgUtils

def write(blip):
    sys.stdout.write("\n|%s|\n" % blip)


class TestVerifyPackages(unittest.TestCase):
    def setUp(self):
        self.__setupData()

    def __setupData(self):
        pass

    def testEmptyLabelList(self):
        "Verify that the verifyPackages call with empty list works"
        data, missing_packages = pkgUtils.verifyPackages([])
        assert data == []

    def testNameOnlyList(self):
        "Verify that the verifyPackages call with just name works"
        packageList1 = [("pam", "", "", "", "")]
        data, missing_packages = pkgUtils.verifyPackages(packageList1)

    def testNameVersionOnlyList(self):
        "Verify that the verifyPackages call with just name-version works"
        packageList2 = [("pam", "0.77", "", "", ""),
                        ("autoconf", "2.57", "", "", "")]
        data, missing_packages = pkgUtils.verifyPackages(packageList2)

    def testNameVersionReleaseOnlyList(self):
        "Verify that verifyPackages call with just name-version-release works"
        packageList3 = [("pam", "0.77", "3", "", ""),
                        ("autoconf", "2.57", "3", "", "")]
        data, missing_packages = pkgUtils.verifyPackages(packageList3)

    def testNameVersionReleaseArchList(self):
        "Verify that verifyPackages call with name-version-release.arch works"
        packageList4 = [("pam", "0.77", "3", "", "i386"),
                        ("autoconf", "2.57", "3", "", "noarch")]
        data, missing_packages = pkgUtils.verifyPackages(packageList4)

    def testNameArchOnlyList(self):
        "Verify that verifyPackages call with name.arch works"
        packageList5 = [("pam", "", "", "", "i386"),
                        ("autoconf", "", "", "", "noarch")]
        data, missing_packages = pkgUtils.verifyPackages(packageList5)

    def testNameVersionArchOnlyList(self):
        "Verify that verifyPackage call with name-version.arch works"
        packageList6 =  [("pam", "0.77", "", "", "i386"),
                        ("autoconf", "2.57", "", "", "noarch")]
        data, missing_packages = pkgUtils.verifyPackages(packageList6)

    def testNameOfUknownPackage(self):
        "Verify that verifyPackage call with a package name that doesnt exist works"
        packageList7 = [("asdfasdfjwe4tisdfgjsdlfgsdfg", "","","", ""),
                        ("apackagenamedsue", "", "", "", "")]
        data, missing_packages = pkgUtils.verifyPackages(packageList7)

    def testNameOfRightNameWrongVersion(self):
        "Verify that verifyPackage call handles a package-version that doesnt exist"
        packageList8 = [("pam", "0.0001", "", "", "i386"),
                        ("autoconf", "342.57", "", "", "noarch")]
        data, missing_packages = pkgUtils.verifyPackages(packageList8)

    def testNameOfKernelPackages(self):
        "Verify that verifyPackage works for kernel packages"
        packageList9 = [("kernel", "", "", "", "")]
        data, missing_packages = pkgUtils.verifyPackages(packageList9)

    def testMissingPackagesReturned(self):
        "Verify that verifyPackages returns list of missing packages"
        packageList10= [("shouldntexisteveresdfasdfas", "", "", "", ""),
                         ("alsoshoudnteverexistever", "", "", "", "")]
        data, missing_packages = pkgUtils.verifyPackages(packageList10)
        assert missing_packages == packageList10

def suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(TestVerifyPackages))
    return suite

if __name__ == "__main__":
    unittest.main(defaultTest="suite")
