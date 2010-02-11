#!/usr/bin/python

import settestpath

from up2date_client import up2dateUtils

import unittest
#import profileUnittest

TestCase = unittest.TestCase
test_up2date = "etc-sysconfig-rhn/up2date"

class TestGetProxySetting(TestCase):
    def setUp(self):
        from up2date_client import config
        self.cfg = config.initUp2dateConfig(test_up2date)
        self.proxy1 = "http://proxy.company.com:8080"
        self.proxy2 = "proxy.company.com:8080"

    def testHttpSpecified(self):
        "Verify that http:// gets stripped from proxy settings"
        self.cfg['httpProxy'] = self.proxy1
        res = up2dateUtils.getProxySetting()
        assert res == "proxy.company.com:8080"

    def testHttpUnSpecified(self):
        "Verify that proxies with no http:// work correctly"
        self.cfg['httpProxy'] = self.proxy2
        res = up2dateUtils.getProxySetting()
        assert res == "proxy.company.com:8080"
        

class TestGetVersion(TestCase):
    def setUp(self):
        from up2date_client import config
        self.cfg = config.initUp2dateConfig(test_up2date)

    def testVersionOverride(self):
        "Verify that specify a version overide works"
        self.cfg['versionOverride'] = "100"
        res = up2dateUtils.getVersion()
        assert res == "100"


class TestPprint_pkglist(TestCase):
    def setUp(self):
        self.pkgList1 = [["foo", "1.0", "1", "", "i386", "234234234", "some-channel"],
                         ["bar", "2.0", "2", "9", "i686", "34234234234234", "some-channel"]]

        self.pkgList2 = []
        self.pkgList3 = map(lambda a: a+["othercruft", "morecruft"], self.pkgList1)

        # send it a tuple
        self.pkgList4 = ("foo", "1.0", "1", "", "i386", "234234234", "some-channel")
        self.pkgList5 = list(self.pkgList4)

    def testPprint_pkglist(self):
        """Verify that pprint_pkglist properly formats a package list"""
        res = up2dateUtils.pprint_pkglist(self.pkgList1)
        assert res == ['foo-1.0-1', 'bar-2.0-2']

    def testEmptyList(self):
        """Verify that pprint_pkglist properly handles a empty list"""
        res = up2dateUtils.pprint_pkglist(self.pkgList2)
        assert res == []

    def testTuple(self):
        """Verify that pprint_pkglist properly handles a single tuple"""
        res = up2dateUtils.pprint_pkglist(self.pkgList4)
        assert res == "foo-1.0-1"

    def testSingleList(self):
        """Verify that pprint_pkglist proper handles a single list (IndexError)"""
        try:
            res = up2dateUtils.pprint_pkglist(self.pkgList5)
            print res
        except IndexError:
            pass
        else:
            self.fail("expected a IndexError")


class TestIsObsoleted(TestCase):
    def setUp(self):
        self.obs1 = ['gcc', '3.4.3', '9.EL4', '', 'x86_64', 'libgnat', '3.4.3-9.EL4', '10']

        # obsSense = 0 (all versions)
        self.obs2 = ['any', '1.0', '1', '', 'x86_64', "older", "1.0-1", "0"]
        self.obs3 = ['newer-than', '1.0', '1', '', 'x86_64', "older", "1.0-1", "4"]
        self.obs4 = ['newer-than-or-equal', '1.0', '1', '', 'x86_64', "older", "1.0-1", "10"]
        self.obs5 = ["older-than", "1.0", "1", '', "x86_64", "older", "1.0-1", "2"]
        self.obs6 = ["newer-than-or-equal", "1.0", "1", '', "x86_64", "older", "1.0-1", "12"]
        self.pkg1 = ['libgnat', '3.4.3', '9.EL4', '', 'i386']
        self.pkg2 = ["older", "1.0", "1", "", "x86_64"]
        self.pkg3 = ["older-noarch", "1.0", "1", "", "noarch"]
        self.pkg4 = ["older", "0.9", "1", "", "x86_64"]
        self.pkg5 = ["older", "1.3", "1", "", "x86_64"]

        self.obsAspell = ['aspell', '0.50.5', '3.fc3', '12', 'i386', 'aspell-da', '0.50', '2']
        self.pkgAspell =  ['aspell-da', '0.50', '10', "50", 'x86_64']

	self.obsGcc = ['compat-libgcc-296', '2.96', '132.7.2', '', 'i386', 'gcc', '2.96', '10']
	self.pkgGcc =  ['gcc', '3.4.3', '22', '', 'i386', '4545445', 'rhel-i386-as-4']

    def testAnyObs(self):
        """Verify that a package with no version sense obsolets all versions of
        the package it is obsoleting"""
        self.assertEqual(up2dateUtils.isObsoleted(self.obs2, self.pkg2), 1)

    def testNewerThanObs(self):
        """Verify that a package with > 1.0-1 does not obsolete package 1.0-1"""
        self.assertEqual(up2dateUtils.isObsoleted(self.obs3, self.pkg2), 0)

    def testNewerThanObsWorks(self):
        """Verify that a package with >= 1.0-1 does  obsolete package 0.9-1"""
        self.assertEqual(up2dateUtils.isObsoleted(self.obs6, self.pkg4), 0)

    def testNewerThanObsFails(self):
        """Verify that a package with >= 1.0-1 does  obsolete package 1.3-1"""
        self.assertEqual(up2dateUtils.isObsoleted(self.obs6, self.pkg5), 1)

    def testOlderThan(self):
        """Verify that a obs: < 1.0-1  does not obsolete 1.0-1""" 
        self.assertEqual(up2dateUtils.isObsoleted(self.obs5, self.pkg2), 0)



    def testOlderThanFail(self):
        """Verify that < 1.0-1   does not obsolete package 1.3-1"""
        self.assertEqual(up2dateUtils.isObsoleted(self.obs5, self.pkg5), 0)
    
    def testOlderThanPass(self):
        """Verify that a pacakage with < 1.0-1 does obsolete package 0.9-1"""
        self.assertEqual(up2dateUtils.isObsoleted(self.obs5, self.pkg4), 1)




    def testOlderThanOrEqualObs(self):
        """Verify that a package with <= 1.0-1 does obsolete package 1.0-1"""
        self.assertEqual(up2dateUtils.isObsoleted(self.obs4, self.pkg2), 1)

    def testAspell(self):
        self.assertEqual(up2dateUtils.isObsoleted(self.obsAspell, self.pkgAspell), 0)

    def testGcc(self):
        self.assertEqual(up2dateUtils.isObsoleted(self.obs1, self.pkg1), 1)
        
    def testGccCompat(self):
	self.assertEqual(up2dateUtils.isObsoleted(self.obsGcc, self.pkgGcc), 0)
        


class TestTouchTimeStamp(TestCase):
    def setUp(self):
        import os
        info = os.stat(up2dateUtils.LAST_UPDATE_FILE) 
        self.origATime = info[7]
        self.origMTime = info[8]
        
    def testTouchTimeStamp(self):
        "Verify that the time stamp file gets touched"
        import time
        import os
        ct = time.time()
        # heh, lame but only have one sec resolution on file stamps
        time.sleep(1)
        up2dateUtils.touchTimeStamp()
        timestamp = os.stat(up2dateUtils.LAST_UPDATE_FILE)[8]
        if ct >= timestamp:
            self.fail("Timestamp not updated")


    def testNoTimeStampFile(self):
        "Verify that touchTimeStamp handles no timestamp file existing"
        import os
        os.unlink(up2dateUtils.LAST_UPDATE_FILE)
        res = up2dateUtils.touchTimeStamp()

        if not os.access(up2dateUtils.LAST_UPDATE_FILE, os.R_OK):
            self.fail("No timestamp file created")

    def tearDown(self):
        import os
        # recreate the file with the original time stamp
        file = open(up2dateUtils.LAST_UPDATE_FILE, "w+")
        file.close()
        os.utime(up2dateUtils.LAST_UPDATE_FILE, (self.origATime, self.origMTime))

# were root, so it's kind of hard to make the file unreadable, need to chattr
# it, and cleanup properly
##    def testUnableToOpenTimestamp(self):
##        "Verify we get the correct return code if we cant open the timestamp"
##        import os
##        os.chmod(up2dateUtils.LAST_UPDATE_FILE, 0000)
##        res = up2dateUtils.touchTimeStamp()
##        write(res)
##        assert res == (0, "unable to open the timestamp file", {})

        
#runner = unittest.TextTestRunner(verbosity=2)
#runner.run(testSuite)

def suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(TestTouchTimeStamp))
    suite.addTest(unittest.makeSuite(TestIsObsoleted))
    suite.addTest(unittest.makeSuite(TestPprint_pkglist))  
    suite.addTest(unittest.makeSuite(TestGetVersion))
    suite.addTest(unittest.makeSuite(TestGetProxySetting))
    return suite

if __name__ == "__main__":
    unittest.main(defaultTest="suite")
