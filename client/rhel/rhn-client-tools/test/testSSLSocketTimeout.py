#!/usr/bin/python

import sys

import unittest

#Import the modules you need to test...
import httplib

def write(blip):
    sys.stdout.write("\n|%s|\n" % blip)


class TestSomething(unittest.TestCase):
    def setUp(self):
	self.__setupData()

    def __setupData(self):
        pass
        
    def testHttpConnection(self):
        con = httplib.HTTPConnection("www.adrianlikins.com")
        con.request("GET", "/")
        r1 = con.getresponse()
        data = r1.read()
        con.close()

    def testHttpsConnection(self):
        con = httplib.HTTPSConnection("rhn.redhat.com")
        con.request("GET", "/")
        r1 = con.getresponse()
        data = r1.read()
        con.close()

    def testHTTPSConnectionTimeout(self):
        import socket
        socket.setdefaulttimeout(3)
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
