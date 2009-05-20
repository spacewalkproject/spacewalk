#!/usr/bin/python

import xmlrpclib
import unittest

from config import *

class PackageSearchTests(RhnTestCase):

    def test_searchByNameAndSummary(self):
        """
        Search for a package by name or summary
        """
        query = "apache"
        pkgs = client.packages.search.nameAndSummary(self.session_key, query)
        self.assertTrue(pkgs != None)
        self.assertTrue(len(pkgs) > 0)
        for p in pkgs:
            #print "Package name = %s, version = %s, release = %s" % (p["name"], p["version"], p["release"])
            self.assertTrue(p.has_key("id"))
            self.assertTrue(p.has_key("name"))
            self.assertTrue(p.has_key("epoch"))
            self.assertTrue(p.has_key("version"))
            self.assertTrue(p.has_key("release"))
            self.assertTrue(p.has_key("arch"))
            self.assertTrue(p.has_key("description"))
            self.assertTrue(p.has_key("summary"))
        #print "%s packages were returned" % (len(pkgs))

    def test_searchByNameAndDescription(self):
        """
        Search for a package by name or description
        """
        query = "virt"
        pkgs = client.packages.search.nameAndDescription(self.session_key, query)
        self.assertTrue(pkgs != None)
        self.assertTrue(len(pkgs) > 0)
        for p in pkgs:
            #print "Package name = %s, version = %s, release = %s" % (p["name"], p["version"], p["release"])
            self.assertTrue(p.has_key("id"))
            self.assertTrue(p.has_key("name"))
            self.assertTrue(p.has_key("epoch"))
            self.assertTrue(p.has_key("version"))
            self.assertTrue(p.has_key("release"))
            self.assertTrue(p.has_key("arch"))
            self.assertTrue(p.has_key("description"))
            self.assertTrue(p.has_key("summary"))
        #print "%s packages were returned" % (len(pkgs))

    def test_searchByName(self):
        """
        Search for a package by name
        """
        query = "vim"
        pkgs = client.packages.search.name(self.session_key, query)
        self.assertTrue(pkgs != None)
        self.assertTrue(len(pkgs) > 0)
        for p in pkgs:
            #print "Package name = %s, version = %s, release = %s" % (p["name"], p["version"], p["release"])
            self.assertTrue(p.has_key("id"))
            self.assertTrue(p.has_key("name"))
            self.assertTrue(p.has_key("epoch"))
            self.assertTrue(p.has_key("version"))
            self.assertTrue(p.has_key("release"))
            self.assertTrue(p.has_key("arch"))
            self.assertTrue(p.has_key("description"))
            self.assertTrue(p.has_key("summary"))
        #print "%s packages were returned" % (len(pkgs))

    def test_searchFreeFormSpecificVersion(self):
        """
        Search for a subset of available kernel packages
        """
        luceneQuery = "(name:kernel AND -name:devel) AND version:2.6.18 AND (release:53.el5 OR release:92.el5)"
        pkgs = client.packages.search.advanced(self.session_key, luceneQuery)
        self.assertTrue(pkgs != None)
        self.assertTrue(len(pkgs) > 0)
        for p in pkgs:
            #print "Package name = %s, version = %s, release = %s" % (p["name"], p["version"], p["release"])
            self.assertTrue(p.has_key("id"))
            self.assertTrue(p.has_key("name"))
            self.assertTrue(p.has_key("epoch"))
            self.assertTrue(p.has_key("version"))
            self.assertTrue(p.has_key("release"))
            self.assertTrue(p.has_key("arch"))
            self.assertTrue(p.has_key("description"))
            self.assertTrue(p.has_key("summary"))
        #print "%s packages were returned" % (len(pkgs))

    def test_searchFreeFormWithChannel(self):
        """
        Search for virt packages in a particular channel
        """
        luceneQuery = "name:virt"
        channelLabel = "rhel-i386-server-vt-5"
        pkgs = client.packages.search.advancedWithChannel(self.session_key, luceneQuery, channelLabel)
        #pkgs = client.packages.search.advanced(self.session_key, luceneQuery)
        self.assertTrue(pkgs != None)
        self.assertTrue(len(pkgs) > 0)
        for p in pkgs:
            print "Package name = %s, version = %s, release = %s" % (p["name"], p["version"], p["release"])
            self.assertTrue(p.has_key("id"))
            self.assertTrue(p.has_key("name"))
            self.assertTrue(p.has_key("epoch"))
            self.assertTrue(p.has_key("version"))
            self.assertTrue(p.has_key("release"))
            self.assertTrue(p.has_key("arch"))
            self.assertTrue(p.has_key("description"))
            self.assertTrue(p.has_key("summary"))
        print "%s packages were returned" % (len(pkgs))

if __name__ == "__main__":
    unittest.main()
