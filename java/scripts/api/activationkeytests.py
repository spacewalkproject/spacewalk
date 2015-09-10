#!/usr/bin/python

import xmlrpclib
import unittest

from random import randint

from config import *

class ActivationKeyTests(RhnTestCase):
    def setUp(self):
        RhnTestCase.setUp(self)
        self.create_key()


    def tearDown(self):
        client.activationkey.delete(self.session_key, self.key)
        RhnTestCase.tearDown(self)


    def create_key(self):
        random_int = randint(1, 1000000)
        self.key = "xmlrpckey_python"  + str(random_int)
        self.key = client.activationkey.create(self.session_key, self.key,
            "xmlrpc test key " + str(random_int), BASE_CHANNEL_LABEL, 0,
            [], False)
        print "created key: %s" % self.key
        return self.key

    # Manually verify results assuming no errors are thrown:
    def test_create_new_key(self):
        random_int = randint(1, 1000000)
        key = "xmlrpckey" + str(random_int)
        newkey = client.activationkey.create(self.session_key, key,
            "xmlrpc test key " + str(random_int), BASE_CHANNEL_LABEL, 0,
            [], False)

        new_details = {}
        new_details['description'] = "look i changed! %s" % str(random_int)
        new_details['usage_limit'] = 5000

        # Test changing the keys details:
        client.activationkey.setDetails(self.session_key, newkey, new_details)

        new_details = client.activationkey.getDetails(self.session_key, newkey)

        # Make sure the base channel wasn't nullified even though we excluded
        # it from the new details:
        self.assertEquals(BASE_CHANNEL_LABEL, new_details['base_channel_label'])

        # Add some new entitlements:
        client.activationkey.addEntitlements(self.session_key, newkey,
            ['virtualization_host'])

        client.activationkey.addChildChannels(self.session_key, newkey,
            [CHILD_CHANNEL_LABEL])

        client.activationkey.addServerGroups(self.session_key, newkey,
            [SERVER_GROUP_ID])

        client.activationkey.addPackageNames(self.session_key, newkey, ["gaim"])

        details = client.activationkey.getDetails(self.session_key, newkey)
        self.validateActivationKeyHash(details)

        allKeys = client.activationkey.listActivationKeys(self.session_key)
        self.assertTrue(len(allKeys) > 0)
        for keyDetails in allKeys:
            self.validateActivationKeyHash(keyDetails)

        ### Teardown Related Calls ###
        client.activationkey.removePackageNames(self.session_key, newkey, ["gaim"])

    def validateActivationKeyHash(self, keyDetails):
        self.assertTrue(keyDetails.has_key('key'))
        self.assertTrue(keyDetails.has_key('description'))
        self.assertTrue(keyDetails.has_key('usage_limit'))
        self.assertTrue(keyDetails.has_key('base_channel_label'))
        self.assertTrue(keyDetails.has_key('child_channel_labels'))
        self.assertTrue(keyDetails.has_key('entitlements'))
        self.assertTrue(keyDetails.has_key('server_group_ids'))
        self.assertTrue(keyDetails.has_key('package_names'))

if __name__ == "__main__":
    unittest.main()


