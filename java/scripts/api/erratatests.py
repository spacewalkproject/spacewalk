#!/usr/bin/python

import xmlrpclib
import unittest

from config import *

# User TODO: Provide a CVE that does exist
VALID_CVE="CVE-2008-1294"

# User TODO: Provide a CVE that does not exist
INVALID_CVE="CVE-0000-9999"

class Errata(RhnTestCase):

    def setUp(self):
        RhnTestCase.setUp(self)

    def tearDown(self):
        RhnTestCase.tearDown(self)

    def test_find_by_cve(self):

        # with the current UI and apis, we don't have a way to associate
        # CVEs with an errata... we can create errata... but not CVEs

        # as a result, we'll use a property that the must be configured
        # to represent a valid CVE...

        erratas = client.errata.findByCve(self.session_key, VALID_CVE)
#        print erratas
        self.assertTrue(len(erratas) > 0)

        erratas = client.errata.findByCve(self.session_key, INVALID_CVE)
#        print erratas
        self.assertTrue(len(erratas) == 0)

if __name__ == "__main__":
    unittest.main()


