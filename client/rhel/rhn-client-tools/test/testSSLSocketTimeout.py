#!/usr/bin/python

import os
import sys

import unittest

#Import the modules you need to test...
try: # python2
    import httplib
except ImportError: # python3
    import http.client as httplib

def write(blip):
    sys.stdout.write("\n|%s|\n" % blip)


class TestSomething(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.http_proxy = os.getenv("HTTP_PROXY") or os.getenv("http_proxy")
        cls.https_proxy = os.getenv("HTTPS_PROXY") or os.getenv("https_proxy")

    def setUp(self):
        self.__setupData()

    def __setupData(self):
        pass

    def testHttpConnection(self):
        if self.http_proxy:
            con = httplib.HTTPConnection(self.http_proxy)
            con.set_tunnel("www.adrianlikins.com")
        else:
            con = httplib.HTTPConnection("www.adrianlikins.com")
        con.request("GET", "/")
        r1 = con.getresponse()
        data = r1.read()
        con.close()

    def testHttpsConnection(self):
        if self.https_proxy:
            con = httplib.HTTPSConnection(self.https_proxy)
            con.set_tunnel("rhn.redhat.com")
        else: 
            con = httplib.HTTPSConnection("rhn.redhat.com")
        con.request("GET", "/")
        r1 = con.getresponse()
        data = r1.read()
        con.close()

    def testHTTPSConnectionTimeout(self):
        import socket
        socket.setdefaulttimeout(3)
        if self.https_proxy:
            con = httplib.HTTPSConnection(self.https_proxy)
            con.set_tunnel("rhn.redhat.com")
        else:
            con = httplib.HTTPSConnection("rhn.redhat.com")
        con.request("GET", "/")
        r1 = con.getresponse()
        data = r1.read()
        con.close()


def suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(TestSomething))
    return suite

if __name__ == "__main__":
    unittest.main(argv=sys.argv)
