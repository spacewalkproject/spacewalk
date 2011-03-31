#!/usr/bin/python

import settestpath

import packages

import unittest

class TestTouchTimeStamp(unittest.TestCase):
    def setUp(self):
        import os
        info = os.stat(packages.LAST_UPDATE_FILE)
        self.origATime = info[7]
        self.origMTime = info[8]

    def testTouchTimeStamp(self):
        "Verify that the time stamp file gets touched"
        import time
        import os
        ct = time.time()
        # heh, lame but only have one sec resolution on file stamps
        time.sleep(1)
        packages.touch_time_stamp()
        timestamp = os.stat(packages.LAST_UPDATE_FILE)[8]
        if ct >= timestamp:
            self.fail("Timestamp not updated")

    def testNoTimeStampFile(self):
        "Verify that touch_time_stamp handles no timestamp file existing"
        import os
        os.unlink(packages.LAST_UPDATE_FILE)
        res = packages.touch_time_stamp()

        if not os.access(packages.LAST_UPDATE_FILE, os.R_OK):
            self.fail("No timestamp file created")

    def tearDown(self):
        import os
        # recreate the file with the original time stamp
        file = open(packages.LAST_UPDATE_FILE, "w+")
        file.close()
        os.utime(packages.LAST_UPDATE_FILE, (self.origATime, self.origMTime))

def suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(TestTouchTimeStamp))
    return suite

if __name__ == "__main__":
    unittest.main(defaultTest="suite")

