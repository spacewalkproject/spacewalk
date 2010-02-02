#!/usr/bin/python

import settestpath

from up2date_client import up2dateErrors
from up2date_client import config

import unittest

#Import the modules you need to test...
from up2date_client import up2dateAuth

test_up2date = "etc-sysconfig-rhn/up2date"

class TestGetSystemID(unittest.TestCase):
    def setUp(self):
	self.__setupData()
        self.cfg = config.initUp2dateConfig(test_up2date)
        self.sysid = self.cfg['systemIdPath']

    def __setupData(self):
        pass

    def tearDown(self):
        self.cfg['systemIdPath'] = self.sysid
    
    def testGetSystemId(self):
        "Verify that the updateAuth.getSystemId can be called"
        id = up2dateAuth.getSystemId()
        assert id != None

    def testGetSystemIdBogusLocation(self):
        "Verify that up2dateAuth.getSystemid fails when given an incorrect path"
        self.cfg['systemIdPath'] = "/a/b/c/d/shouldnt/exist/path"
        id = up2dateAuth.getSystemId()
        self.assertEqual(id, None)

    
class TestMaybeUpdateVersion(unittest.TestCase):
    def setUp(self):
	self.__setupData()
        import testutils
        testutils.setupConfig("8.0-workstation-i386-1")
        self.cfg = config.initUp2dateConfig(test_up2date)
        self.origversion = self.cfg['versionOverride']

    def __setupData(self):
        pass

    def tearDown(self):
        import testutils
        testutils.restoreConfig()
        self.cfg['versionOverride'] = self.origversion
        
        
    def testMaybeUpdateVersion(self):
        "Verify that maybeUpdateVersion works"
        ret = up2dateAuth.maybeUpdateVersion()

    def testMaybeUpdateVersionVersionOverrideNewer(self):
        "Verify that maybeUpdateversion + versionOverride with newer version works"
        self.cfg['versionOverride'] = "1000000"
        try:
            ret = up2dateAuth.maybeUpdateVersion()
        except up2dateErrors.CommunicationError, e:
            pass
        else:
            self.fail("Excepted to get a Communication Error indicating unknown version")

    def testMaybeUpdateVersionVersionOverrideOlder(self):
        "Verify that maybeUpdateversion + versionOverride with older version works"
        self.cfg['versionOverride'] = ".1"
        try:
            ret = up2dateAuth.maybeUpdateVersion()
        except up2dateErrors.CommunicationError, e:
            pass
        else:
            self.fail("Excepted to get a Communication Error indicating unknown version")
    def testMaybeUpdateVersionVersionCorruptSystemid(self):
        "Verify that maybeUpdateVersion handles a munged systemid file"
        import testutils
        testutils.setupConfig("8.0-workstation-i386-1-corrupt-sysid")
        ret = up2dateAuth.maybeUpdateVersion()


class TestLogin(unittest.TestCase):
    def setUp(self):
        self.__setupData()
        import testutils
        testutils.setupConfig("rhel3-i386")

    def __setupData(self):
        pass

    def tearDown(self):
        import testutils
        testutils.restoreConfig()

    def testLogin(self):
        "Test that up2dateAuth.login works with no exceptions"
        ret = up2dateAuth.login()

    def testLoginCredsType(self):
        "Verify that up2dateAuth.login returns login credentials in a dict"
        ret = up2dateAuth.login()
        if type(ret) == type({}):
            if not ret.has_key('X-RHN-Auth'):
                self.fail("Expected a dict containing a X-RHN-AUTH header, didnt get it")
        else:
            self.fail("Expected a dict containing headers, but the return is not a dict")

    
class TestUpdateLoginInfo(unittest.TestCase):
    def setUp(self):
        self.__setupData()
        import testutils
        testutils.setupConfig("rhel3-i386")

    def __setupData(self):
        pass

    def tearDown(self):
        import testutils
        testutils.restoreConfig()

    def testUpdateLoginInfo(self):
        "test that up2dateAuth.up2dateLoginInfo works without exceptions"
        ret = up2dateAuth.updateLoginInfo()

    
    def testUpdateLoginInfoCredsType(self):
        "Verify that up2dateAuth.updateLoginInfo returns login credentials in a dict"
        ret = up2dateAuth.updateLoginInfo()
        if type(ret) == type({}):
            if not ret.has_key('X-RHN-Auth'):
                self.fail("Expected a dict containing a X-RHN-AUTH header, didnt get it")
        else:
            self.fail("Expected a dict containing headers, but the return is not a dict")

    def testUpdateLoginInfoSingleton(self):
        "Verify that up2dateAuth.updateLoginInfo returns the proper auth info"
        # test for bugs #124335, #115385 
        ret1 = up2dateAuth.updateLoginInfo()
        ret2 = up2dateAuth.updateLoginInfo()
        assert ret1 == ret2

    def testUpdateLoginInfoSingletonWorks(self):
        "Verify that up2dateAuth.updateLoginInfo returns the proper auth info every time"
        ret1 = up2dateAuth.updateLoginInfo()
        import repoDirector
        rd = repoDirector.initRepoDirector()
        ret2 = up2dateAuth.updateLoginInfo()
        self.__verifyTokens(rd)

    def __verifyTokens(self, rd):
        import rhnChannel
        import rpcServer
        channels = rhnChannel.getChannels()
        channel = channels.channels()[0]
        # if this doesn't throw an auth traceback, the auth doesnt work
        p, t = rpcServer.doCall(rd.listPackages, channel,
                                msgCallback=None, progressCallback=None)
        

    def testUp2dateLoginInfoWorks(self):
        "Verify that up2dateAuth.updateLoginInfo retuns a working authToken"
        import repoDirector
        rd = repoDirector.initRepoDirector()
        ret2 = up2dateAuth.updateLoginInfo()
        self.__verifyTokens(rd)
        

#TODO: things we don't test yet but need to
# authToken timeout (need some server magic)
# verifying that the authTokens we get actually work

def suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(TestUpdateLoginInfo))
    suite.addTest(unittest.makeSuite(TestLogin))
    suite.addTest(unittest.makeSuite(TestMaybeUpdateVersion))
    suite.addTest(unittest.makeSuite(TestGetSystemID))
    return suite

if __name__ == "__main__":
    unittest.main(defaultTest="suite")
