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
#
#

import sys
import unittest
from spacewalk.common.rhnConfig import initCFG
from spacewalk.server import rhnSQL

import misc_functions

DB_SETTINGS = misc_functions.db_settings("oracle")


class Tests(unittest.TestCase):

    def setUp(self):
        initCFG("server")
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

    def test_new_org_1(self):
        org_id = misc_functions.create_new_org()
        h = rhnSQL.prepare("select id from web_customer where id = :id")
        h.execute(id=org_id)
        row = h.fetchone_dict()
        self.assertNotEqual(row, None)
        self.assertEqual(row['id'], org_id)

    def _verify_new_user(self, u):
        uid = u.getid()
        login = u.contact["login"]
        org_id = u.contact["org_id"]

        h = rhnSQL.prepare("select login, org_id from web_contact where id = :id")
        h.execute(id=uid)
        row = h.fetchone_dict()
        self.assertNotEqual(row, None)
        self.assertEqual(row['login'], login)
        self.assertEqual(row['org_id'], org_id)

    def test_new_user_1(self):
        "Create a new user"
        u = misc_functions.create_new_user()
        self._verify_new_user(u)

    def test_new_user_2(self):
        "Create a new user in an existing org"
        org_id = misc_functions.create_new_org()
        u = misc_functions.create_new_user(org_id=org_id)
        self._verify_new_user(u)
        self.assertEqual(org_id, u.contact['org_id'])

    def test_new_users_1(self):
        "Create a bunch of new users in an org"
        org_id = misc_functions.create_new_org()
        for i in range(10):
            u = misc_functions.create_new_user(org_id=org_id)
            self._verify_new_user(u)
            self.assertEqual(org_id, u.contact['org_id'])


if __name__ == '__main__':
    sys.exit(unittest.main() or 0)
