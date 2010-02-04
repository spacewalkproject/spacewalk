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
Database specific tests for rhnSQL drivers.

These tests require a database connection, usually configured in a
rhntests-*.py script.
"""

import unittest

from random import randint

from server import rhnSQL
from server.rhnSQL import sql_base

TEST_IDS = [1, 2, 3]
TEST_NAMES = ["Bill", "Susan", "Joe"]
TEST_NUMS = [900.12, 600.49, 34.98]

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
        cursor.execute(id=TEST_IDS[0], name=TEST_NAMES[0], num=TEST_NUMS[0])
        cursor.execute(id=TEST_IDS[1], name=TEST_NAMES[1], num=TEST_NUMS[1])
        cursor.execute(id=TEST_IDS[2], name=TEST_NAMES[2], num=TEST_NUMS[2])

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

    def test_statement_prepare_error(self):
        query = "aaa bbb ccc"
        cursor = rhnSQL.prepare(query)
        self.assertRaises(rhnSQL.SQLStatementPrepareError,
            cursor.execute)
        rhnSQL.rollback()

    def test_execute_bindbyname_extra_params_passed(self):
        query = "SELECT * FROM %s WHERE id = :id" % self.temp_table
        cursor = rhnSQL.prepare(query)
        cursor.execute(id=TEST_IDS[0], name="Sam") # name should be ignored
        results = cursor.fetchone()
        self.assertEquals(TEST_IDS[0], results[0])
        self.assertEquals(TEST_NAMES[0], results[1])

    def test_executemany(self):
        query = "INSERT INTO %s(id, name) VALUES(:id, :name)" \
                % self.temp_table
        ids = [1000, 1001]
        names = ["Somebody", "Else"]

        cursor = rhnSQL.prepare(query)
        cursor.executemany(id=ids, name=names)

        query = rhnSQL.prepare("SELECT * FROM %s WHERE id >= 1000 ORDER BY ID"
                % self.temp_table)
        query.execute()
        rows = query.fetchall()
        self.assertEquals(2, len(rows))

        self.assertEquals(1000, rows[0][0])
        self.assertEquals(1001, rows[1][0])
        self.assertEquals("Somebody", rows[0][1])
        self.assertEquals("Else", rows[1][1])

    def test_executemany2(self):
        query = "SELECT * FROM %s" \
                % self.temp_table
        cursor = rhnSQL.prepare(query)

        # Just want to see that this doesn't throw an exception:
        cursor.executemany()

    def test_execute_bulk(self):
        query = "INSERT INTO %s(id, name) VALUES(:id, :name)" \
                % self.temp_table
        ids = [1000, 1001]
        names = ["Somebody", "Else"]

        cursor = rhnSQL.prepare(query)
        d = {
                'id': ids,
                'name': names,
        }
        cursor.execute_bulk(d)

        query = rhnSQL.prepare("SELECT * FROM %s WHERE id >= 1000 ORDER BY ID"
                % self.temp_table)
        query.execute()
        rows = query.fetchall()
        self.assertEquals(2, len(rows))

        self.assertEquals(1000, rows[0][0])
        self.assertEquals(1001, rows[1][0])
        self.assertEquals("Somebody", rows[0][1])
        self.assertEquals("Else", rows[1][1])


    def test_numeric_columns(self):
        h = rhnSQL.prepare("SELECT num FROM %s WHERE id = %s" %
                (self.temp_table, TEST_IDS[0]))
        h.execute()
        row = h.fetchone()
        self.assertEqual(TEST_NUMS[0], row[0])

    def test_fetchone(self):
        query = "SELECT * FROM %s WHERE id = 1 ORDER BY id" % self.temp_table
        cursor = rhnSQL.prepare(query)
        cursor.execute()
        results = cursor.fetchone()
        self.assertEquals(TEST_IDS[0], results[0])
        self.assertEquals(TEST_NAMES[0], results[1])

    def test_fetchone_dict(self):
        query = "SELECT * FROM %s WHERE id = 1 ORDER BY id" % self.temp_table
        cursor = rhnSQL.prepare(query)
        cursor.execute()
        results = cursor.fetchone_dict()
        self.assertEquals(TEST_IDS[0], results['id'])
        self.assertEquals(TEST_NAMES[0], results['name'])
        self.assertEquals(TEST_NUMS[0], results['num'])

    def test_fetchall(self):
        query = rhnSQL.prepare("SELECT * FROM %s ORDER BY id" %
                self.temp_table)
        query.execute()
        rows = query.fetchall()
        self.assertEquals(len(TEST_IDS), len(rows))

        i = 0
        while i < len(TEST_IDS):
            self.assertEquals(TEST_IDS[i], rows[i][0])
            self.assertEquals(TEST_NAMES[i], rows[i][1])
            i = i + 1

    def test_fetchall_dict(self):
        query = rhnSQL.prepare("SELECT * FROM %s ORDER BY id" %
                self.temp_table)
        query.execute()
        rows = query.fetchall_dict()
        self.assertEquals(len(TEST_IDS), len(rows))

        i = 0
        while i < len(TEST_IDS):
            self.assertEquals(TEST_IDS[i], rows[i]['id'])
            self.assertEquals(TEST_NAMES[i], rows[i]['name'])
            i = i + 1

    def test_unicode_string_argument(self):
        query = rhnSQL.prepare("SELECT * FROM %s WHERE name=:name" % 
            self.temp_table)
        query.execute(name=u'blah')

#    def test_procedure(self):
#        sp = rhnSQL.Procedure("return_int")
#        ret = sp(5)
#        self.assertEquals(5, ret)



class PostgreSQLDatabaseTests(RhnSQLDatabaseTests):
    QUERY_CREATE_TABLE = """
        CREATE TABLE %s(id INT, name TEXT, num NUMERIC(5,2))
    """

    SIMPLE_PROCEDURE = """
CREATE OR REPLACE FUNCTION return_int(returnme INTEGER) RETURNS int AS $$
DECLARE
    myInt int;
BEGIN
    myInt := returnme;
    RETURN myInt;
END
$$ LANGUAGE 'plpgsql';
    """

    def setUp(self):
        self.temp_table = "testtable%s" % randint(1, 10000000)
        create_table_query = self.QUERY_CREATE_TABLE % self.temp_table
        cursor = rhnSQL.prepare(create_table_query)
        cursor.execute()

        RhnSQLDatabaseTests.setUp(self)

        cursor = rhnSQL.prepare(self.SIMPLE_PROCEDURE)
        cursor.execute()

    def tearDown(self):
        try:
            cursor = rhnSQL.prepare("DROP FUNCTION return_int(returnme integer)")
            cursor.execute()
        except:
            pass

        RhnSQLDatabaseTests.tearDown(self)



class OracleDatabaseTests(RhnSQLDatabaseTests):
    QUERY_CREATE_TABLE = """
        CREATE TABLE %s(id NUMBER, name VARCHAR2(256), num NUMBER(5,2))
    """

    SIMPLE_PROCEDURE = """
CREATE OR REPLACE FUNCTION 
    return_int(returnme in integer) 
RETURN INTEGER  AS
BEGIN
    RETURN returnme;
END;
    """

    def setUp(self):
        self.temp_table = "testtable%s" % randint(1, 10000000)
        create_table_query = self.QUERY_CREATE_TABLE % self.temp_table
        cursor = rhnSQL.prepare(create_table_query)
        cursor.execute()

        RhnSQLDatabaseTests.setUp(self)

        cursor = rhnSQL.prepare(self.SIMPLE_PROCEDURE)
        cursor.execute()

    def tearDown(self):
        cursor = rhnSQL.prepare("DROP FUNCTION return_int")
        cursor.execute()

        RhnSQLDatabaseTests.tearDown(self)



def postgresql_suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(PostgreSQLDatabaseTests))
    return suite

def oracle_suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(OracleDatabaseTests))
    return suite

