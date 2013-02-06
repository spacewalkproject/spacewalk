#!/usr/bin/python

import os

import settestpath

import unittest

from up2date_client import clientCaps
from up2date_client import up2dateAuth

test_clientCaps_d = "etc-sysconfig-rhn/clientCaps.d"

class TestClientCaps(unittest.TestCase):
    def setUp(self):
	self.__setupData()

    def __setupData(self):
        self.caps1 = {"packages.runTransaction":{'version':1, 'value':1},
                      "blippyfoo":{'version':5, 'value':0},
                      "caneatCheese":{'version':1, 'value': 1}
                      }

        self.headerFormat1 = [('X-RHN-Client-Capability', 'caneatCheese(1)=1'),
                              ('X-RHN-Client-Capability', 'packages.runTransaction(1)=1'),
                              ('X-RHN-Client-Capability', 'blippyfoo(5)=0')]

        self.dataKeysSorted1 = ['blippyfoo',
                                'caneatCheese',
                                'packages.runTransaction']
        self.dataValuesSorted1 = [{'version': 5, 'value': 0},
                                  {'version': 1, 'value': 1},
                                  {'version': 1, 'value': 1}]
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
        self.assertEquals(type([]), type(res))

    def testHeaderFormatVerify(self):
        "Verify that headerFormat returns proper results"
        cc = clientCaps.ClientCapabilities()
        cc.populate(self.caps1)
        res = cc.headerFormat()
        self.assertEquals(type([]), type(res))
        self.assertTrue(len(res) >= 1)

        for header in res:
            headerName, value = header
            self.assertEqual("X-RHN-Client-Capability", headerName)

        self.assertEqual(res, self.headerFormat1)

    def testDataFormatVerify(self):
        "Verify that populate() creates the internal dict's properly"
        cc = clientCaps.ClientCapabilities()
        cc.populate(self.caps1)

        keys = cc.keys()
        keys.sort()
        self.assertEqual(self.dataKeysSorted1, keys)

        values = cc.values()
        values.sort()
        self.assertEqual(self.dataValuesSorted1, values)


    def testLoadClientCaps(self):
        "Verify that loadClientCaps works"
        blip = clientCaps.loadLocalCaps(test_clientCaps_d)

    def testLoadClientCapsSkipDirs(self):
        "Verify that client caps loads with dirs in /etc/sysconfig/rhn/clientCaps.d,"
        # bugzilla #114322
        dirname= test_clientCaps_d + "/TESTDIR"
        if not os.access(dirname, os.R_OK):
            os.makedirs(dirname)
        try:
            clientCaps.loadLocalCaps(test_clientCaps_d)
            os.rmdir(dirname) 
        except:
            os.rmdir(dirname) 
            self.fail()


class TestLoginWithCaps(unittest.TestCase):
    def testLogin(self):
        "Attempt a login that utilizies capabilties"
        # this doesnt neccesarily seem to relate to caps
        # but it's here as a convient way to test login's
        # at the moment...

        # in the future we could also try override different
        # capbilities, etc...
        res = up2dateAuth.login()


def suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(TestClientCaps))
    suite.addTest(unittest.makeSuite(TestLoginWithCaps))
    return suite
       
if __name__ == "__main__":
    unittest.main(defaultTest="suite")
