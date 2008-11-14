#
# Copyright (c) 2008 Red Hat, Inc.
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
Database specific tests for rhnSQL drivers.

These tests require a database connection, usually configured in a 
rhntests-*.py script.
"""

import unittest

from random import randint

from server import rhnSQL
from server.rhnSQL import sql_base

TEST_ID = 1
TEST_NAME = "Bill"
TEST_NUM = 900.12

class RhnSQLDatabaseTests(unittest.TestCase):
    """ 
    Database connection tests that can be run against any supported database.
    """

    def setUp(self):
        # Expect self.temp_table to have been created by subclass by now:

        #insert_query = "INSERT INTO %s(id, name) VALUES($1, $2)" % \
        #        self.temp_table
        #cursor = rhnSQL.prepare(insert_query)
        #ids = [1, 2, 3, 4, 5]
        #names = ["Bill", "Ted", "Mary", "Tom", "Susan"]
        #cursor.executemany([ids, names])

        insert_query = "INSERT INTO %s(id, name, num) VALUES(:id, :name, :num)" % \
                self.temp_table
        cursor = rhnSQL.prepare(insert_query)
        cursor.execute(id=TEST_ID, name=TEST_NAME, num=TEST_NUM)

    def tearDown(self):
        drop_table_query = "DROP TABLE %s" % self.temp_table
        cursor = rhnSQL.prepare(drop_table_query)
        cursor.execute()
        rhnSQL.commit()

    def test_execute_not_all_variables_bound(self):
        query = "INSERT INTO %s(id, name) VALUES(:id, :name)" % \
                self.temp_table
        cursor = rhnSQL.prepare(query)
        self.assertRaises(sql_base.SQLError, cursor.execute, name="Blah")

    def test_fetchone(self):
        query = "SELECT * FROM %s WHERE id = 1" % self.temp_table
        cursor = rhnSQL.prepare(query)
        cursor.execute()
        results = cursor.fetchone()
        self.assertEquals(TEST_ID, results[0])
        self.assertEquals(TEST_NAME, results[1])

    def test_statement_prepare_error(self):
        query = "aaa bbb ccc"
        cursor = rhnSQL.prepare(query)
        self.assertRaises(rhnSQL.SQLStatementPrepareError,
            cursor.execute)
        rhnSQL.rollback()

    def test_execute_bindbyname_extra_params_passed(self):
        query = "SELECT * FROM %s WHERE id = :id" % self.temp_table
        cursor = rhnSQL.prepare(query)
        cursor.execute(id=TEST_ID, name="Sam") # name should be ignored
        results = cursor.fetchone()
        self.assertEquals(TEST_ID, results[0])
        self.assertEquals(TEST_NAME, results[1])

    def test_numeric_columns(self):
        h = rhnSQL.prepare("SELECT num FROM %s WHERE id = %s" %
                (self.temp_table, TEST_ID))
        h.execute()
        row = h.fetchone()
        self.assertNotEqual(row, None)
        self.assertEqual(TEST_NUM, row[0])



class PostgreSQLDatabaseTests(RhnSQLDatabaseTests):
    QUERY_CREATE_TABLE = """
        CREATE TABLE %s(id INT, name TEXT, num NUMERIC(5,2))
    """

    def setUp(self):
        self.temp_table = "testtable%s" % randint(1, 10000000)
        create_table_query = self.QUERY_CREATE_TABLE % self.temp_table
        cursor = rhnSQL.prepare(create_table_query)
        cursor.execute()

        RhnSQLDatabaseTests.setUp(self)



class OracleDatabaseTests(RhnSQLDatabaseTests):
    QUERY_CREATE_TABLE = """
        CREATE TABLE %s(id NUMBER, name VARCHAR2(256), num NUMBER(5,2))
    """

    def setUp(self):
        self.temp_table = "testtable%s" % randint(1, 10000000)
        create_table_query = self.QUERY_CREATE_TABLE % self.temp_table
        cursor = rhnSQL.prepare(create_table_query)
        cursor.execute()

        RhnSQLDatabaseTests.setUp(self)



def postgresql_suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(PostgreSQLDatabaseTests))
    return suite

def oracle_suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(OracleDatabaseTests))
    return suite

