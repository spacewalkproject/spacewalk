#!/usr/bin/python

import xmlrpclib
import unittest

from random import randint

from config import *

# Should have at least 100 free slots to run these tests, which *should*
# return all of those back to the default satellite org once finished.
CHANNEL_FAMILY_LABEL = "rhel-server"
SYSTEM_ENTITLEMENT_LABEL = "provisioning_entitled"

SATELLITE_ORG_ID = 1

class OrgTests(RhnTestCase):

    def setUp(self):
        RhnTestCase.setUp(self)

        # Create a test org that will be deleted in teardown:
        self.random_int = randint(1, 1000000)
        self.org_name = "Test Org %s" % self.random_int
        self.org = client.org.create(self.session_key, self.org_name, 
                "admin%s" % self.random_int, "password", 
                "Mr.", "Fake", "Admin", "fake@example.com", False)
        self.org_id = self.org['id']

    def tearDown(self):
        result = client.org.delete(self.session_key, self.org_id)
        RhnTestCase.tearDown(self)

    def test_create_org(self):
        self.assertTrue(self.org.has_key('id'))
        self.assertTrue(self.org.has_key('name'))
        self.assertTrue(self.org.has_key('systems'))
        self.assertTrue(self.org.has_key('active_users'))
        self.assertTrue(self.org.has_key('system_groups'))
        self.assertTrue(self.org.has_key('activation_keys'))
        self.assertTrue(self.org.has_key('kickstart_profiles'))

    def test_delete_no_such_org(self):
        self.assertRaises(Exception, client.org.delete, self.session_key, -1)

    def test_list_channel_family_entitlements(self):
        result = client.org.listSoftwareEntitlements(self.session_key, 
                CHANNEL_FAMILY_LABEL)
        self.assertTrue(len(result) >= 1) # default org at least
        for counts in result:
            self.assertTrue(counts.has_key('org_id'))
            self.assertTrue(counts.has_key('allocated'))
            self.assertTrue(counts.has_key('used'))
            self.assertTrue(counts.has_key('free'))
            self.assertEquals(counts['allocated'], counts['used'] + counts['free'])

    def test_list_channel_family_entitlements_for_org(self):
        # NOTE: Using the default org here:
        result = client.org.listSoftwareEntitlementsForOrg(self.session_key, 
                SATELLITE_ORG_ID)
        for counts in result:
            self.assertTrue(counts.has_key('label'))
            self.assertTrue(counts.has_key('allocated'))
            self.assertTrue(counts.has_key('used'))
            self.assertTrue(counts.has_key('free'))
            self.assertTrue(counts.has_key('unallocated'))
            self.assertEquals(counts['allocated'], counts['used'] + counts['free'])
            #print "Channel family: %s" % counts['channel_family_label']
            #print "  allocated: %s" % counts['allocated']
            #print "  used: %s" % counts['used']
            #print "  free: %s" % counts['free']

    #def test_sat_list(self):
    #    result = client.satellite.listEntitlements(self.session_key)
    #    chan = result['channel']
    #    for c in chan:
    #        print "Channel: %s" % c['name']
    #        print "%s - %s - %s" % (c['total_slots'], c['free_slots'], c['used_slots'])

    def __find_count_for_org(self, results, org_id):
        for count in results:
            if count['org_id'] == org_id:
                return count
        self.fail("Unable to find org id: %s" % org_id)

    def __find_count_for_entitlement(self, results, channel_family_label):
        for count in results:
            if count['label'] == channel_family_label:
                return count
        self.fail("Unable to find channel family: %s" % channel_family_label)

    def test_set_channel_family_entitlements(self):
        # Lookup satellite org count for verification:
        result = client.org.listSoftwareEntitlementsForOrg(self.session_key, 
                SATELLITE_ORG_ID)
        count = self.__find_count_for_entitlement(result, CHANNEL_FAMILY_LABEL)
        sat_org_total = count['allocated']
        self.assertTrue(count['free'] >= 100)

        result = client.org.setSoftwareEntitlements(self.session_key,
                self.org_id, CHANNEL_FAMILY_LABEL, 100)
        self.assertEquals(1, result)

        result = client.org.listSoftwareEntitlementsForOrg(self.session_key, 
                self.org_id)
        count = self.__find_count_for_entitlement(result, CHANNEL_FAMILY_LABEL)
        self.assertEquals(100, count['allocated'])

        # Check that the satellite org lost it's entitlements:
        result = client.org.listSoftwareEntitlementsForOrg(self.session_key, 
                SATELLITE_ORG_ID)
        count = self.__find_count_for_entitlement(result, CHANNEL_FAMILY_LABEL)
        self.assertEquals(sat_org_total - 100, count['allocated'])

    def test_set_too_many_channel_family_entitlements(self):
        result = client.org.listSoftwareEntitlementsForOrg(self.session_key, 
                SATELLITE_ORG_ID)
        count = self.__find_count_for_entitlement(result, CHANNEL_FAMILY_LABEL)
        sat_org_free = count['free']

        # Allocate one too many entitlements:
        result = self.assertRaises(Exception, 
                client.org.setSoftwareEntitlements, self.session_key,
                self.org_id, CHANNEL_FAMILY_LABEL, sat_org_free + 1)

    def test_set_channel_family_entitlements_on_default_org(self):
        self.assertRaises(Exception, client.org.setSoftwareEntitlements,
                self.session_key, SATELLITE_ORG_ID, CHANNEL_FAMILY_LABEL, 100)

    def test_list_system_entitlements_global(self):
        result = client.org.listSystemEntitlements(self.session_key)
        for r in result:
            self.assertTrue(r.has_key('allocated'))
            self.assertTrue(r.has_key('used'))
            self.assertTrue(r.has_key('free'))
            self.assertTrue(r.has_key('unallocated'))

    def test_set_system_entitlements(self):
        # Lookup satellite org count for verification:
        result = client.org.listSystemEntitlementsForOrg(self.session_key, 
                SATELLITE_ORG_ID)
        count = self.__find_count_for_entitlement(result, 
                SYSTEM_ENTITLEMENT_LABEL)
        sat_org_total = count['allocated']
        self.assertTrue(count['free'] >= 100)

        result = client.org.setSystemEntitlements(self.session_key,
                self.org_id, SYSTEM_ENTITLEMENT_LABEL, 100)
        self.assertEquals(1, result)

        result = client.org.listSystemEntitlementsForOrg(self.session_key, 
                self.org_id)
        count = self.__find_count_for_entitlement(result, 
                SYSTEM_ENTITLEMENT_LABEL)
        self.assertEquals(100, count['allocated'])

        # Check that the satellite org lost it's entitlements:
        result = client.org.listSystemEntitlementsForOrg(self.session_key, 
                SATELLITE_ORG_ID)
        count = self.__find_count_for_entitlement(result, 
                SYSTEM_ENTITLEMENT_LABEL)
        self.assertEquals(sat_org_total - 100, count['allocated'])

    def test_set_too_many_system_entitlements(self):
        result = client.org.listSystemEntitlementsForOrg(self.session_key, 
                SATELLITE_ORG_ID)
        count = self.__find_count_for_entitlement(result, 
                SYSTEM_ENTITLEMENT_LABEL)
        sat_org_free = count['free']

        # Allocate one too many entitlements:
        result = self.assertRaises(Exception, 
                client.org.setSoftwareEntitlements, self.session_key,
                self.org_id, SYSTEM_ENTITLEMENT_LABEL, sat_org_free + 1)

    def test_set_system_entitlements_on_default_org(self):
        self.assertRaises(Exception, client.org.setSystemEntitlements,
                self.session_key, SATELLITE_ORG_ID, SYSTEM_ENTITLEMENT_LABEL, 
                100)



if __name__ == "__main__":
    unittest.main()


