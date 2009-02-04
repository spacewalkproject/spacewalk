#!/usr/bin/python

import xmlrpclib
import unittest

from config import *

class SystemSearchTests(RhnTestCase):

    def test_searchByNameAndDescription(self):
        systems = client.system.search.ip(self.session_key, SYS_SEARCH_NAME_DESCRP)
        self.assertTrue(systems != None)
        for s in systems:
            self.assertTrue(s.has_key("name"))
            self.assertTrue(s.has_key("ip"))
            self.assertTrue(s.has_key("id"))
    
    def test_searchByIp(self):
        systems = client.system.search.ip(self.session_key, SYS_SEARCH_IP)
        self.assertTrue(systems != None)
        for s in systems:
            self.assertTrue(s.has_key("name"))
            self.assertTrue(s.has_key("ip"))
            self.assertTrue(s.has_key("id"))

    def test_searchByHostname(self):
        term = "redhat.com"
        systems = client.system.search.hostname(self.session_key, SYS_SEARCH_HOSTNAME)
        self.assertTrue(systems != None)
        for s in systems:
            self.assertTrue(s.has_key("name"))
            self.assertTrue(s.has_key("hostname"))
            self.assertTrue(s.has_key("id"))

    def test_searchByDeviceDescription(self):
        systems = client.system.search.deviceDescription(self.session_key, SYS_SEARCH_HW_DESCRP)
        self.assertTrue(systems != None)
        for s in systems:
            self.assertTrue(s.has_key("name"))
            self.assertTrue(s.has_key("id"))
            self.assertTrue(s.has_key("hw_description"))
            self.assertTrue(s.has_key("hw_driver"))


    def test_searchByDeviceDriver(self):
        systems = client.system.search.deviceDriver(self.session_key, SYS_SEARCH_HW_DEVICE_DRIVER)
        self.assertTrue(systems != None)
        for s in systems:
            self.assertTrue(s.has_key("name"))
            self.assertTrue(s.has_key("id"))
            self.assertTrue(s.has_key("hw_description"))
            self.assertTrue(s.has_key("hw_driver"))

    def test_searchByDeviceId(self):
        systems = client.system.search.deviceId(self.session_key, SYS_SEARCH_HW_DEVICE_ID)
        self.assertTrue(systems != None)
        for s in systems:
            self.assertTrue(s.has_key("name"))
            self.assertTrue(s.has_key("id"))
            self.assertTrue(s.has_key("hw_description"))
            self.assertTrue(s.has_key("hw_device_id"))
            self.assertTrue(s.has_key("hw_driver"))

    def test_searchByDeviceVendorId(self):
        systems = client.system.search.deviceVendorId(self.session_key, SYS_SEARCH_HW_VENDOR_ID)
        self.assertTrue(systems != None)
        for s in systems:
            self.assertTrue(s.has_key("name"))
            self.assertTrue(s.has_key("id"))
            self.assertTrue(s.has_key("hw_description"))
            self.assertTrue(s.has_key("hw_driver"))
            self.assertTrue(s.has_key("hw_vendor_id"))

if __name__ == "__main__":
    unittest.main()
