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

"""
Pure unit tests for components of rhnSQL.

NOTE: Not hitting the database here!
"""

import unittest

from spacewalk.server.rhnSQL.driver_postgresql import convert_named_query_params


class RhnSQLTests(unittest.TestCase):

    """ Pure unit tests for components of rhnSQL. """

    def test_convert_named_query_params(self):
        query = "INSERT INTO people(id, name, phone) VALUES(:id, :name, :phone)"
        expected_query = \
            "INSERT INTO people(id, name, phone) VALUES(%(id)s, %(name)s, %(phone)s)"

        new_query = convert_named_query_params(query)
        self.assertEquals(expected_query, new_query)

    def test_convert_named_params_none_required(self):
        query = "SELECT * FROM people"

        new_query = convert_named_query_params(query)
        self.assertEquals(query, new_query)

    def test_convert_named_params_multiple_uses(self):
        query = "INSERT INTO people(a, b, c, d) VALUES(:a, :b, :a, :b)"
        expected_query = \
            "INSERT INTO people(a, b, c, d) VALUES(%(a)s, %(b)s, %(a)s, %(b)s)"

        new_query = convert_named_query_params(query)
        self.assertEquals(expected_query, new_query)

    def test_date_format_conversion_issue(self):
        query = "SELECT TO_CHAR(issued, 'YYYY-MM-DD HH24:MI:SS') issued FROM rhnSatelliteCert WHERE id=:id, name=:name"
        expected_query = "SELECT TO_CHAR(issued, 'YYYY-MM-DD HH24:MI:SS') issued FROM rhnSatelliteCert WHERE id=%(id)s, name=%(name)s"
        new_query = convert_named_query_params(query)
        self.assertEquals(expected_query, new_query)
