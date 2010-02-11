#!/usr/bin/python



import sys

import settestpath

from up2date_client import config
from up2date_client import rpcServer

import unittest
from rhn import rpclib

test_up2date = "etc-sysconfig-rhn/up2date"

def write(blip):
    sys.stdout.write("\n%s\n" % blip)


class TestGetServer(unittest.TestCase):
    def setUp(self):
        self.cfg = config.initUp2dateConfig(test_up2date)
        self.origssl = self.cfg['sslCACert']

    def tearDown(self):
        # reset this
        self.cfg['enableProxy'] = 0
        self.cfg['enableAuthProxy'] = 0
        self.cfg['serverURL'] = "https://xmlrpc.rhn.redhat.com/XMLRPC"
        self.cfg['sslCACert'] = self.origssl


    def testGetServerDefault(self):
        "Verify that rpcServer.getServer works with default config and arguments"
        try:
            s = rpcServer.getServer()
        except:
            self.fail("Got an expection calling rpcServer.getServer")

    def __callback(self):
        write("callback called")
        
    def testGetServerDefaultWithRefreshCallback(self):
        "Verify that getServer works with default config and a refreshCallback"
        try:
            s = rpcServer.getServer(refreshCallback=self.__callback)
        except:
            self.fail("Got an expection calling rpcServer.getServer")
        
    def testGetServerRedirectServer(self):
        "Verify that getServer works when talking to a server that redirects"
        self.cfg['serverURL'] = "https://rhn.redhat.com/XMLRPC-REDIRECT"
        try:
            s = rpcServer.getServer()
        except:
            self.fail("Got an expection calling rpcServer.getServer")

    def testGetServerProxy(self):
        "Verify that getServer Works when specifying a proxy"
        sys.path.append("/etc/sysconfig/rhn/")
        proxyUrl = testConfig.anonProxyUrl
        self.cfg['httpProxy'] = proxyUrl
        try:
            s = rpcServer.getServer()
        except:
            self.fail("Got an expection calling rpcServer.getServer")

    def testGetServerAuthProxy(self):
        "Verify that getSerer works when specifying an an auth proxy"
        sys.path.append("/etc/sysconfig/rhn/")
        proxyUrl = testConfig.authProxyUrl
        self.cfg['httpProxy'] = testConfig.authProxyUrl
        self.cfg['proxyUser'] = testConfig.authProxyUser
        self.cfg['proxyPassword'] = testConfig.authProxyPassword
        self.cfg['enableAuthProxy'] = 1
        try:
            s = rpcServer.getServer()
        except:
            self.fail("Got an expection calling rpcServer.getServer")
    
    
    def testGetServerAuthProxyNoPassword(self):
        "Verify that getSerer works when specifying an an auth proxy and no user password"
        sys.path.append("/etc/sysconfig/rhn/")
        proxyUrl = testConfig.authProxyUrl
        self.cfg['httpProxy'] = testConfig.authProxyUrl
        self.cfg['proxyUser'] = testConfig.authProxyUser
        self.cfg['enableAuthProxy'] = 1
        try:
            s = rpcServer.getServer()
        except:
            self.fail("Got an expection calling rpcServer.getServer")

    def testGetServerAuthProxyNoUsername(self):
        "Verify that getSerer works when specifying an an auth proxy and no username"
        sys.path.append("/etc/sysconfig/rhn/")
        proxyUrl = testConfig.authProxyUrl
        self.cfg['httpProxy'] = testConfig.authProxyUrl
        self.cfg['enableAuthProxy'] = 1
        try:
            s = rpcServer.getServer()
        except:
            self.fail("Got an expection calling rpcServer.getServer")

    def testGetServerAuthProxyNoEnableAuthProxy(self):
        "getServer with httpProxy set, but no enableAuthProxy"
        sys.path.append("/etc/sysconfig/rhn/")
        proxyUrl = testConfig.authProxyUrl
        self.cfg['httpProxy'] = testConfig.authProxyUrl
        try:
            s = rpcServer.getServer()
        except:
            self.fail("Got an expection calling rpcServer.getServer")

    def testGetServerNoCaCert(self):
        "getServer with a missing CA cert"
        self.cfg['sslCACert'] =  ["/var/not/likely/to/exist/I/hope/SSL-CA-Cert"]
#        rpcServer.rhns_ca_certs = ["/var/not/likely/to/exist/I/hope/SSL-CA-Cert"]
        try:
            s = rpcServer.getServer()
            write(s)
        except SystemExit:
            pass
        else:
            self.fail("Expected to get a sys.exit(1)")

    def testGetServerMultipleCaCert(self):
        "getServer with a multiple CA certs"
        rpcServer.rhns_ca_certs = ["/usr/share/rhn/RHNS-CA-CERT", "/usr/share/rhn/RHNS-CA-CERT"]
        
        try:
            s = rpcServer.getServer()
        except:
            self.fail("Got an %s expection" % sys.exc_type)



class TestRpcServer500Error(unittest.TestCase):
    def setUp(self):
        
        self.defaultServer = testConfig.brokenServer500error
        import testutils
        testutils.setupConfig("fc1-at-pepsi")

        # cant import config until we put the right stuff in place
        self.cfg = config.initUp2dateConfig(test_up2date)
        self.cfg['serverURL'] = self.defaultServer
        
    def tearDown(self):
        import testutils
        testutils.restoreConfig()

    def testDefaultWelcomeMessage(self):
        "Test welcome_message call with no redirects or proxies"
        s = rpcServer.getServer()
        
        ret = s.registration.welcome_message()

##    def testListPackages(self):
##        "Test that listPackages returns something correctly"
##        import up2dateAuth
##        from repoBackends import up2dateRepo
##        ss = up2dateRepo.ServerSettings()

## #       write("%s" % (ss.settings(),))
##        li = up2dateAuth.getLoginInfo()
##        s = up2dateRepo.getGETServer(li, ss)
##        try:
##            ret = rpcServer.doCall(s.getObsoletes, "rhel-i386-as-3", "123123123")
##        except up2dateErrors.CommunicationError, e:
##            pass
##        else:
##            self.fail("Excpectd to get a CommunicationsError here but did not")
###        write(ret)

class TestRpcServerWelcomeMessage(unittest.TestCase):
    def __init__(self, methodname):
        self.neServerSSL = "https://www.hokeypokeyland.coma/FOO"
        self.neServer = "http://www.hokeypokeyland.coma/FOO"
        self.FourOhFourServerSSL = "https://xmlrpc.rhn.redhat.com/XMLSSDFSD"
        self.FourOhFourServer = "http://xmlrpc.rhn.redhat.com/XMLSSDFSD"
        unittest.TestCase.__init__(self, methodname)
        
    def setUp(self):
        self.cfg = config.initUp2dateConfig(test_up2date)
        self.defaultServer = self.cfg['serverURL']
#        self.defaultServer = "http://SECRET_URL/XMLRPC"
#        write("defaultServer: %s" % self.cfg['serverURL'])


    def tearDown(self):
        self.cfg['serverURL'] = self.defaultServer
        self.cfg['enableProxy'] = 0
        self.cfg['enableAuthProxy'] = 0
        
    def testDefaultWelcomeMessage(self):
        "Test welcome_message call with no redirects or proxies"
        s = rpcServer.getServer()
        s.registration.welcome_message()

    
    def testDefaultWelcomeMessageFailoverNonExistentServer(self):
        "Test welcome_message call faling over from a non existent server"
        self.cfg['serverURL'] = [ self.neServer,
                                 'https://SECRET_URL/XMLRPC']
        s = rpcServer.getServer()
        s.registration.welcome_message()

    def testDefaultWelcomeMessageFailover404Server(self):
        "Test welcome_message call faling over from a server that 404's"
        self.cfg['serverURL'] = [ self.FourOhFourServer,
                                  'https://SECRET_URL/XMLRPC']
        s = rpcServer.getServer()
        s.registration.welcome_message()
        
    def testDefaultWelcomeMessageFailoverNonExistentServerRedirect(self):
        "Test welcome_message call faling over from a non existent server to a redirect"
        self.cfg['serverURL'] = [ self.neServer,
                                 'https://SECRET_URL/XMLRPC-REDIRECT']
        s = rpcServer.getServer()
        s.registration.welcome_message()

    def testDefaultWelcomeMessageFailover404ServerRedirect(self):
        "Test welcome_message call faling over from a non existent server to a redirect"
        self.cfg['serverURL'] = [ self.FourOhFourServer,
                                 'https://SECRET_URL/XMLRPC-REDIRECT']
        s = rpcServer.getServer()
        s.registration.welcome_message()
    
    def testDefaultWelcomeMessageHttpsToHttps(self):
        "Test redirecting https to https"
        self.cfg['serverURL'] = "https://SECRET_URL/XMLRPC-REDIRECT"
        s = rpcServer.getServer()
        s.registration.welcome_message()

    def testDefaultWelcomeMessageHttpToHttps(self):
        "Test redirecting http to https"
        self.cfg['serverURL'] = "http://SECRET_URL/XMLRPC-REDIRECT"
        s = rpcServer.getServer()
        s.registration.welcome_message()

    def testDefaultWelcomeMessageHttpsToHttp(self):
        "Test redirecting https to http"
        self.cfg['serverURL'] = "https://SECRET_URL/XMLRPC-REDIRECT-NOSSL"
        s = rpcServer.getServer()
        try:
            s.registration.welcome_message()
        except rpclib.InvalidRedirectionError:
            pass
        else:
            self.fail("IOError expected here but didnt get it")

    
    def testDefaultWelcomeMessageHttpsToHttpFailovers(self):
        "Test redirecting https to http after failing over from bad servers"
        self.cfg['serverURL'] = [self.neServer,
                                 self.FourOhFourServer,
                                 "https://SECRET_URL/XMLRPC-REDIRECT-NOSSL"]
        s = rpcServer.getServer()

        try:
            s.registration.welcome_message()
        except rpclib.InvalidRedirectionError:
        
            pass
        else:
            self.fail("InvalidRedirectionError expected here but didnt get it")

    def testDefaultWelcomeMessageHttpsToHttpFailoversSSLandNonSSL(self):
        "Test redirecting https to http after failing over from bad servers"
        self.cfg['serverURL'] = [self.neServerSSL,
                                 self.FourOhFourServer,
                                 "https://SECRET_URL/XMLRPC-REDIRECT-NOSSL"]
        s = rpcServer.getServer()

        try:
            s.registration.welcome_message()
        except rpclib.InvalidRedirectionError:
        
            pass
        else:
            self.fail("InvalidRedirectionError expected here but didnt get it")

    def testDefaultWelcomeMessageHttpsToHttpFailoversNonSSLandSSL(self):
        "Test redirecting https to http after failing over from bad servers"
        self.cfg['serverURL'] = [self.neServer,
                                 self.FourOhFourServerSSL,
                                 "https://SECRET_URL/XMLRPC-REDIRECT-NOSSL"]
        s = rpcServer.getServer()

        try:
            s.registration.welcome_message()
        except rpclib.InvalidRedirectionError:
        
            pass
        else:
            self.fail("InvalidRedirectionError expected here but didnt get it")

            
    def testDefaultWelcomeMessageHttpsToHttpFailoversSSL(self):
        "Test redirecting https to http after failing over from bad ssl servers"
        self.cfg['serverURL'] = [self.neServerSSL,
                                 self.FourOhFourServerSSL,
                                 "https://SECRET_URL/XMLRPC-REDIRECT-NOSSL"]
        s = rpcServer.getServer()

        try:
            s.registration.welcome_message()
        except rpclib.InvalidRedirectionError:
        
            pass
        else:
            self.fail("InvalidRedirectionError expected here but didnt get it")
        
    def testDefaultWelcomeMessageHttpToHttp(self):
        "Test redirecting http to http"
        self.cfg['serverURL'] = "http://SECRET_URL/XMLRPC-REDIRECT-NOSSL"
        s = rpcServer.getServer()
        s.registration.welcome_message()



    def testDefaultWelcomeMessageHttpsToHttpsCheckReturnCode(self):
        "Test redirecting https to https and verify its return code"
        self.cfg['serverURL'] = "https://SECRET_URL/XMLRPC-REDIRECT"
        s = rpcServer.getServer()
        s.registration.welcome_message()
        status  = s.get_response_status()
        self.assertEqual(status, 200)

    def testDefaultWelcomeMessageHttpToHttpsCheckReturnCode(self):
        "Test redirecting http to https and verify its return code"
        self.cfg['serverURL'] = "http://SECRET_URL/XMLRPC-REDIRECT"
        s = rpcServer.getServer()
        s.registration.welcome_message()
        status = s.get_response_status()
        self.assertEqual(status, 200)

    def testDefaultWelcomeMessageHttpToHttpCheckReturnCode(self):
        "Test redirecting http to http and verify its return code"
        self.cfg['serverURL'] = "http://SECRET_URL/XMLRPC-REDIRECT-NOSSL"
        s = rpcServer.getServer()
        s.registration.welcome_message()
        status = s.get_response_status()
        self.assertEqual(status, 200)

    def testDefaultWelcomeMessageHttpsToHttpsRedirectsOff(self):
        "Test redirecting https to https and verify it fails with allow_redirect off"
        self.cfg['serverURL'] = "https://SECRET_URL/XMLRPC-REDIRECT"
        s = rpcServer.getServer()
        s.allow_redirect(0)
        try:
            s.registration.welcome_message()
        except  rpclib.InvalidRedirectionError:
            pass
        else:
            self.fail("InvalidRedirectionError expected here but didnt get it")

    def testDefaultWelcomeMessageHttpToHttpsRedirectsOff(self):
        "Test redirecting http to https and verify it fails with allow_redirect off"
        self.cfg['serverURL'] = "http://SECRET_URL/XMLRPC-REDIRECT"
        s = rpcServer.getServer()
        s.allow_redirect(0)
        try:
            s.registration.welcome_message()
        except  rpclib.InvalidRedirectionError:
            pass
        else:
            self.fail("InvalidRedirectionError expected here but didnt get it")
        
    def testDefaultWelcomeMessageHttpToHttpRedirectsOff(self):
        "Test redirecting http to http and verify if tails with allow_redirect off"
        self.cfg['serverURL'] = "http://SECRET_URL/XMLRPC-REDIRECT-NOSSL"
        s = rpcServer.getServer()
        s.allow_redirect(0)
        try:
            s.registration.welcome_message()
        except rpclib.InvalidRedirectionError:
            pass
        else:
            self.fail("InvalidRedirectionError expected here but didnt get it")

    def testDefaultWelcomeMessageHttpsToHttpRedirectsOff(self):
        "Test redirecting https to http and verify it fails with allow_redirect off"
        self.cfg['serverURL'] = "https://SECRET_URL/XMLRPC-REDIRECT-NOSSL"
        s = rpcServer.getServer()
        s.allow_redirect(0)

        try:
            s.registration.welcome_message()
        except rpclib.InvalidRedirectionError:
            pass
        else:
            self.fail("InvalidRedirectionError expected here but didnt get it")

    def testDefaultWelcomeMessageHttpsToHttps(self):
        "Test redirecting https to https"
        self.cfg['serverURL'] = "https://SECRET_URL/XMLRPC-REDIRECT"
        s = rpcServer.getServer()
        s.registration.welcome_message()

    def testDefaultWelcomeMessageHttpToHttpsCheckRedirect(self):
        "Test redirecting http to https and verify redirect()"
        self.cfg['serverURL'] = "http://SECRET_URL/XMLRPC-REDIRECT"
        s = rpcServer.getServer()
        s.registration.welcome_message()
        ret = s.redirected()
        self.assertEqual(ret, "https://SECRET_URL/XMLRPC")
        

    def testDefaultWelcomeMessageHttpsToHttpCheckRedirect(self):
        "Test redirecting https to http and verify redirect()"
        self.cfg['serverURL'] = "https://SECRET_URL/XMLRPC-REDIRECT-NOSSL"
        s = rpcServer.getServer()
        try:
            s.registration.welcome_message()
        except rpclib.InvalidRedirectionError:
            pass
        else:
            self.fail("InvalidRedirectError expected here but didnt get it")
        ret = s.redirected()
        self.assertEqual(ret, "http://SECRET_URL/XMLRPC")

    def testDefaultWelcomeMessageHttpToHttpCheckRedirect(self):
        "Test redirecting http to http and verify redirect()"
        self.cfg['serverURL'] = "http://SECRET_URL/XMLRPC-REDIRECT-NOSSL"
        s = rpcServer.getServer()
        s.registration.welcome_message()
        ret = s.redirected()
        self.assertEqual(ret, "http://SECRET_URL/XMLRPC")

    def testDefaulWelcomeMessageNoRedirectCheckRedirect(self):
        "Test a non redirecting connection and see if redirected() is set"
        self.cfg['serverURL'] = "http://SECRET_URL/XMLRPC"
        s = rpcServer.getServer()
        s.registration.welcome_message()
        ret = s.redirected()
        self.assertEqual(ret, None)

def suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(TestRpcServerWelcomeMessage))
    suite.addTest(unittest.makeSuite(TestRpcServer500Error))
    suite.addTest(unittest.makeSuite(TestGetServer))
    return suite

if __name__ == "__main__":
    unittest.main(defaultTest="suite")
