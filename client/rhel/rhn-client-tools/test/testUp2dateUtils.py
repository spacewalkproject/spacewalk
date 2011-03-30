#!/usr/bin/python

import settestpath

from up2date_client import up2dateUtils

import unittest
#import profileUnittest

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
    suite.addTest(unittest.makeSuite(TestGetVersion))
    return suite

if __name__ == "__main__":
    unittest.main(defaultTest="suite")
