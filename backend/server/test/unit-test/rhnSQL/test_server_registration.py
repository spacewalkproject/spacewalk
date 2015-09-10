#!/usr/bin/python
#
# Copyright (c) 2008--2015 Red Hat, Inc.
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
# Tests verious codepaths for server registration
#

import sys
import time
import unittest
from spacewalk.common import rhnFlags
from spacewalk.common.rhnConfig import initCFG, CFG
from spacewalk.server import rhnSQL, rhnServer, rhnChannel, rhnUser
from spacewalk.server.handlers.xmlrpc import registration

import misc_functions
DB_SETTINGS = misc_functions.db_settings("oracle")


class Tests(unittest.TestCase):
    _channel = 'redhat-advanced-server-i386'
    _channel_family = 'rhel-as'
    _entitlements = {
        'enterprise_entitled': None
    }

    def setUp(self):
        initCFG("server.xmlrpc")
        rhnSQL.initDB(
            backend="oracle",
            username=DB_SETTINGS["user"],
            password=DB_SETTINGS["password"],
            database=DB_SETTINGS["database"]
        )
        rhnSQL.clear_log_id()

    def tearDown(self):
        # Roll back any unsaved data
        rhnSQL.rollback()

    def test_new_server_1(self):
        "Test normal server registration, with username/password"
        u, password = self._create_new_user()
        username = u.contact['login']
        org_id = u.contact['org_id']
        entitlements = self._entitlements
        os_release = "2.1as"

        t = misc_functions.create_activation_key(
            org_id=u.contact['org_id'],
            entitlement_level=entitlements,
            user_id=u.getid(),
            release=os_release
        )

        params = build_new_system_params_with_username(username=username,
                                                       password=password, os_release=os_release)

        system_id = register_new_system(params)
        rhnSQL.commit()

        s = rhnServer.get(system_id)
        self.assertNotEqual(s, None)

        server_id = s.getid()
        channels = rhnChannel.channels_for_server(server_id)
        self.assertEqual(len(channels), 1)
        self.assertEqual(channels[0]['label'], self._channel)

    def test_new_server_token_1(self):
        "test registration with token"
        u, _ = self._create_new_user()
        org_id = u.contact['org_id']
        entitlements = self._entitlements
        os_release = "2.1as"

        t = misc_functions.create_activation_key(
            org_id=u.contact['org_id'],
            entitlement_level=entitlements,
            user_id=u.getid(),
            release=os_release
        )

        token = t.get_token()

        params = build_new_system_params_with_token(
            token=token,
            os_release=os_release
        )

        system_id = register_new_system(params)
        rhnSQL.commit()

        s = rhnServer.get(system_id)
        self.assertNotEqual(s, None)

    def test_new_server_token_2(self):
        "Test registration with token that specifies a base channel"

        # FIXME: the test fails because there's no channel associated with the
        # freshly created Server: rhnServerChannel is not populated by the
        # registration code.

        u, _ = self._create_new_user()
        org_id = u.contact['org_id']
        base_channel = 'rhel-i386-as-3'
        entitlements = self._entitlements
        os_release = "2.1as"

        t = misc_functions.create_activation_key(org_id=u.contact['org_id'],
                                                 entitlement_level=entitlements, user_id=u.getid(),
                                                 channels=[base_channel], release=os_release)

        token = t.get_token()

        params = build_new_system_params_with_token(
            token=token,
            os_release=os_release
        )

        system_id = register_new_system(params)
        rhnSQL.commit()

        s = rhnServer.get(system_id)
        self.assertNotEqual(s, None)

        server_id = s.getid()
        channels = rhnChannel.channels_for_server(server_id)
        self.assertEqual(len(channels), 1)
        self.assertEqual(channels[0]['label'], base_channel)

    def test_new_server_reactivation_token_1(self):
        "Test server re-registration"
        u, password = self._create_new_user()
        username = u.contact['login']
        os_release = "2.1AS"

        params = build_new_system_params_with_username(username=username,
                                                       password=password, os_release="2.1AS")

        system_id = register_new_system(params)
        rhnSQL.commit()

        s1 = rhnServer.get(system_id)
        self.assertNotEqual(s1, None)

        server_id_1 = s1.getid()
        groups1 = misc_functions.fetch_server_groups(server_id_1)

        # Build a re-registration token
        base_channel = 'rhel-i386-as-3'
        entitlements = self._entitlements
        t = misc_functions.create_activation_key(org_id=u.contact['org_id'],
                                                 entitlement_level=entitlements, user_id=u.getid(),
                                                 channels=[base_channel], server_id=server_id_1, release=os_release)

        token = t.get_token()

        params = build_new_system_params_with_token(
            token=token,
            os_release=os_release
        )
        system_id = register_new_system(params)
        rhnSQL.commit()

        s2 = rhnServer.get(system_id)
        server_id_2 = s2.getid()

        groups2 = misc_functions.fetch_server_groups(server_id_2)

        self.assertNotEqual(s2, None)
        self.assertEqual(server_id_1, server_id_2)
        # Should be subscribed to the same groups
        self.assertEqual(groups1, groups2)

    def test_new_server_multiple_tokens_1(self):
        """Test registration with multiple activation tokens
        Resulting server group is the union of all server groups from all
        tokens
        """
        u, _ = self._create_new_user()
        org_id = u.contact['org_id']
        entitlements = self._entitlements
        os_release = "2.1AS"

        t = misc_functions.create_activation_key(org_id=u.contact['org_id'],
                                                 entitlement_level=entitlements, user_id=u.getid(), release=os_release)

        token1 = t.get_token()
        sg1 = t.get_server_groups()

        t = misc_functions.create_activation_key(org_id=u.contact['org_id'],
                                                 entitlement_level=entitlements, user_id=u.getid(), release=os_release)

        token2 = t.get_token()
        sg2 = t.get_server_groups()

        token = token1 + ',' + token2

        params = build_new_system_params_with_token(token=token,
                                                    os_release=os_release)

        system_id = register_new_system(params)
        rhnSQL.commit()

        s = rhnServer.get(system_id)
        self.assertNotEqual(s, None)

        server_id = s.getid()
        sgs = misc_functions.fetch_server_groups(server_id)
        sgstgt = sg1 + sg2
        sgstgt.sort()

        self.assertEqual(sgs, sgstgt)

    def _create_new_user(self):
        # Create new org
        org_id = misc_functions.create_new_org()
        users_unencrypted_password = "unittest-password-%.3f" % time.time()

        # Grant entitlements to the org
        misc_functions.grant_channel_family_entitlements(
            org_id,
            "%s-%.3f" % (self._channel_family, time.time()),
            1
        )

        # Create new user
        u = misc_functions.create_new_user(
            org_id=org_id,
            roles=['org_admin'],
            password=users_unencrypted_password,
            encrypt_password=CFG.encrypted_passwords
        )

        return u, users_unencrypted_password


class Counter:
    _counter = 0

    def value(self):
        val = self._counter
        self._counter = val + 1
        return val


def build_new_system_params_with_username(**kwargs):
    val = Counter().value()
    rnd_string = "%d-%d" % (int(time.time()), val)

    params = {
        'os_release': '9',
        'architecture': 'i686-redhat-linux',
        'profile_name': "unittest server " + rnd_string,
        'username': 'no such user',
        'password': 'no such password',
    }
    params.update(kwargs)
    if params.has_key('token'):
        del params['token']
    return params


def build_new_system_params_with_token(**kwargs):
    params = {
        'token': kwargs.get('token', "no such token"),
    }
    params.update(build_new_system_params_with_username(**kwargs))
    del params['username']
    del params['password']
    return params


def register_new_system(params):
    rhnFlags.reset()
    return registration.Registration().new_system(params)


if __name__ == '__main__':
    sys.exit(unittest.main() or 0)
