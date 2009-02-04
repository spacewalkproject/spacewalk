#!/usr/bin/python

import xmlrpclib
import unittest

from config import *
from random import randint

class UserTests(RhnTestCase):

    def setUp(self):
        RhnTestCase.setUp(self)
        self.test_user = "TestUser%s" % randint(1, 1000000)
        client.user.create(self.session_key, self.test_user, "testpassword", 
            "Test", "User", "TestUser@example.com")

        self.test_group_names = []
        self.test_group_ids = []
        self.test_group_names.append("Test Group %s" % randint(1, 100000))
        self.test_group_names.append("Test Group %s" % randint(1, 100000))
        self.test_group_names.append("Test Group %s" % randint(1, 100000))
        
        for group_name in self.test_group_names:
            group = client.systemgroup.create(self.session_key, group_name, 
                "Fake Description")
            self.test_group_ids.append(group['id'])

    def tearDown(self):
        client.user.delete(self.session_key, self.test_user)

        for group_name in self.test_group_names:
            client.systemgroup.delete(self.session_key, group_name)

        RhnTestCase.tearDown(self)

    def test_add_assigned_system_groups(self):
        groups = client.user.listAssignedSystemGroups(self.session_key, 
            self.test_user)
        self.assertEquals(0, len(groups))

        ret = client.user.addAssignedSystemGroups(self.session_key, 
            self.test_user, self.test_group_ids, False)
        self.assertEquals(1, ret)

        groups = client.user.listAssignedSystemGroups(self.session_key, 
            self.test_user)
        self.assertEquals(len(self.test_group_ids), len(groups))

    def test_add_assigned_system_groups_and_set_default(self):
        groups = client.user.listAssignedSystemGroups(self.session_key, 
            self.test_user)
        self.assertEquals(0, len(groups))
        groups = client.user.listDefaultSystemGroups(self.session_key, 
            self.test_user)
        self.assertEquals(0, len(groups))

        ret = client.user.addAssignedSystemGroups(self.session_key, 
            self.test_user, self.test_group_ids, True)
        self.assertEquals(1, ret)

        groups = client.user.listAssignedSystemGroups(self.session_key, 
            self.test_user)
        self.assertEquals(len(self.test_group_ids), len(groups))
        groups = client.user.listDefaultSystemGroups(self.session_key, 
            self.test_user)
        self.assertEquals(len(self.test_group_ids), len(groups))

    def test_add_assigned_system_group(self):
        groups = client.user.listAssignedSystemGroups(self.session_key, 
            self.test_user)
        self.assertEquals(0, len(groups))

        ret = client.user.addAssignedSystemGroup(self.session_key, 
            self.test_user, self.test_group_ids[0], False)
        self.assertEquals(1, ret)

        groups = client.user.listAssignedSystemGroups(self.session_key, 
            self.test_user)
        self.assertEquals(1, len(groups))



if __name__ == "__main__":
    unittest.main()

