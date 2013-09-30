"""
Unit Tests for syncing the self.package profile with rhn.
"""

import unittest
from yum import transactioninfo
from yum.packages import YumAvailablePackage

import settestpath

import rhnplugin


class DummyRepo:

    def __init__(self, channel):
        self.id = channel


class SimplePkgDict:

    """
    A Simple package dictionary object.
    This is essentially another way to get up2date info into yum.
    """

    def __init__(self, nevra):
        self.nevra = nevra


class DummyPackageObject(YumAvailablePackage):

    """ A yum package object for objects stored in RHN. """

    def __init__(self, pkg, storageDir, repo):

        name    = pkg[0]
        epoch   = pkg[3]
        version = pkg[1]
        release = pkg[2]
        arch    = pkg[4]
        channel = pkg[6]
        size    = pkg[5]

        # YUM prefers the epoch to be '0', not ''.
        if epoch == '':
            epoch = '0'

        nevra = (name, epoch, version, release, arch)
        pkgdict = SimplePkgDict(nevra)

        YumAvailablePackage.__init__(self, repo, pkgdict)

        self.pkg = pkg
        self.simple['repoid']      = channel
        self.simple['id']          = name
        self.simple['packagesize'] = size

        # Not including epoch here because up2date doesn't.
        hdrname = "%s-%s-%s.%s.hdr" % (name, version, release, arch)
        rpmname = "%s-%s-%s.%s.rpm" % (name, version, release, arch)

        self.simple['relativepath'] = rpmname

        self.hdrpath = "%s/%s" % (storageDir, hdrname)
        self.localpath = "%s/%s" % (storageDir, rpmname)

        self.hdr = None

    def returnSimple(self, name):
        """
        Return one of the package's simple attributes. If we don't know about it,
        return None instead.
        """
        try:
            return YumAvailablePackage.returnSimple(self, name)
        except KeyError:
            return None


class ProfileSyncTests(unittest.TestCase):

    """
    Tests for the RHN self.package Object.
    """

    def setUp(self):
        repo = DummyRepo("rhel-4")

        self.pkg_tup = ("zsh", "0.1", "EL3", "0", "noarch", "23456533",
            "rhel-4")
        self.package = DummyPackageObject(self.pkg_tup,
            "/Fake/Location", repo)

        self.old_pkg_tup = ("figgle", "0.1", "EL3", "0", "noarch", "23456533",
            "rhel-4")
        self.old_package = DummyPackageObject(self.old_pkg_tup,
            "/Fake/Location", repo)

        self.ts_info = transactioninfo.TransactionData()


    def testEmptyTsData(self):
        delta = rhnplugin.make_package_delta(self.ts_info)

        # We need the two lists
        self.assertTrue(delta.has_key("added"))
        self.assertTrue(delta.has_key("removed"))

        self.assertEquals(0, len(delta["added"]))
        self.assertEquals(0, len(delta["removed"]))

    def testAddedProfileSync(self):
        self.ts_info.addInstall(self.package)

        delta = rhnplugin.make_package_delta(self.ts_info)

        self.assertEquals(0, len(delta["removed"]))
        self.assertEquals(1, len(delta["added"]))

        self.assertEquals(self.pkg_tup[:5], delta["added"][0])

    def testRemovedProfileSync(self):
        self.ts_info.addErase(self.package)

        delta = rhnplugin.make_package_delta(self.ts_info)

        self.assertEquals(1, len(delta["removed"]))
        self.assertEquals(0, len(delta["added"]))

        self.assertEquals(self.pkg_tup[:5], delta["removed"][0])


    def testUpdatedProfileSync(self):
        self.ts_info.addUpdate(self.package, self.old_package)

        delta = rhnplugin.make_package_delta(self.ts_info)

        self.assertEquals(0, len(delta["removed"]))
        self.assertEquals(1, len(delta["added"]))

        self.assertEquals(self.pkg_tup[:5], delta["added"][0])

    def testObsoletingProfileSync(self):
        self.ts_info.addObsoleting(self.package, self.old_package)

        delta = rhnplugin.make_package_delta(self.ts_info)

        self.assertEquals(0, len(delta["removed"]))
        self.assertEquals(1, len(delta["added"]))

        self.assertEquals(self.pkg_tup[:5], delta["added"][0])

    def testObsoletedProfileSync(self):
        self.ts_info.addObsoleted(self.old_package, self.package)

        delta = rhnplugin.make_package_delta(self.ts_info)

        self.assertEquals(0, len(delta["removed"]))
        self.assertEquals(0, len(delta["added"]))


def suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(ProfileSyncTests))
    return suite

if __name__ == "__main__":
    unittest.main(defaultTest="suite")
