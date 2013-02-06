#!/usr/bin/python

import settestpath

from up2date_client import up2dateErrors
##from up2date_client import config

import unittest

#Import the modules you need to test...
from up2date_client import rhnregGui
from up2date_client.rhnregGui import callAndFilterExceptions

class MyError(Exception):
    pass

class TestcallAndFilterExceptions(unittest.TestCase):
    def storeMessage(self, message, dummy):
        self.message = message
    
    def returnsNumber(self):
        return 6
    
    def raiseError(self):
        raise MyError("I am a banana!")
    
    def testCallableDoesntRaiseException(self):
        value = callAndFilterExceptions(self.returnsNumber, [], "Error", 
                                            self.storeMessage)
        self.assertEqual(value, 6)
    
    def testCallableRaisesValidException(self):
        self.assertRaises(MyError,
                        callAndFilterExceptions, self.raiseError, 
                        [MyError], "Error", 
                        self.storeMessage)

    def testCallableRaisesInvalidException(self):
        value = callAndFilterExceptions(self.raiseError, [], "Error3", 
                                            self.storeMessage)
        self.assertEqual(value, None)
        self.assertEqual(self.message, "Error3")
    
#TODO: things we don't test yet but need to
# authToken timeout (need some server magic)
# verifying that the authTokens we get actually work

def suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(TestcallAndFilterExceptions))
    return suite

if __name__ == "__main__":
    unittest.main(defaultTest="suite")
