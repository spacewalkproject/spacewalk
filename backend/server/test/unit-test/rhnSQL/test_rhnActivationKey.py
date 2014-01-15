#!/usr/bin/python
#
# Copyright (c) 2008--2010 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#
#
#
#

import os
import sys
import time
import unittest
from spacewalk.server import rhnSQL

sys.path.insert(
    0,
    os.path.abspath(os.path.dirname(os.path.abspath(__file__) + "/../../../attic/"))
)
import rhnActivationKey

import misc_functions

DB_SETTINGS = misc_functions.db_settings("oracle")


class Tests(unittest.TestCase):

    def setUp(self):
        rhnSQL.initDB(
            backend  = "oracle",
            username = DB_SETTINGS["user"],
            password = DB_SETTINGS["password"],
            database = DB_SETTINGS["database"]
        )
        rhnSQL.clear_log_id()

    def tearDown(self):
        # Roll back any unsaved data
        rhnSQL.rollback()

    def test_new_activation_key_1(self):
        org_id = misc_functions.create_new_org()
        u = misc_functions.create_new_user(org_id=org_id)

        groups = []
        for i in range(3):
            params = misc_functions.build_server_group_params(org_id=org_id)
            sg = misc_functions.create_server_group(params)
            groups.append(sg.get_id())
        groups.sort()

        channels = ['rhn-tools-rhel-2.1-as-i386',
                'rhn-tools-rhel-2.1-es-i386', 'rhn-tools-rhel-2.1-ws-i386']
        channels.sort()

        token_user_id = u.getid()
        token_org_id = org_id
        token_entitlement_level = {
            'provisioning_entitled' : None,
            'enterprise_entitled'   : None,
        }
        token_note = "Test activation key %d" % int(time.time())

        a = misc_functions.create_activation_key(org_id=token_org_id,
            user_id=token_user_id, entitlement_level=token_entitlement_level,
            note=token_note, groups=groups, channels=channels)

        token = a.get_token()

        a = rhnActivationKey.ActivationKey()
        a.load(token)

        self.assertEqual(a.get_user_id(), token_user_id)
        self.assertEqual(a.get_org_id(), token_org_id)
        self.assertEqual(a.get_entitlement_level(), token_entitlement_level)
        self.assertEqual(a.get_note(), token_note)
        g = a.get_server_groups()
        g.sort()
        self.assertEqual(g, groups)

        g = a.get_channels()
        g.sort()
        self.assertEqual(g, channels)

    def test_exception_token_load_1(self):
        a = rhnActivationKey.ActivationKey()
        self.assertRaises(rhnActivationKey.InvalidTokenError, a.load, "a")

    def test_exception_token_channels_1(self):
        a = rhnActivationKey.ActivationKey()
        self.assertRaises(rhnActivationKey.InvalidChannelError, a.set_channels,
            ["a"])

    def test_exception_token_entitlement_level_1(self):
        a = rhnActivationKey.ActivationKey()
        self.assertRaises(rhnActivationKey.InvalidEntitlementError,
            a.set_entitlement_level, {'a' : None})

if __name__ == '__main__':
    sys.exit(unittest.main() or 0)
