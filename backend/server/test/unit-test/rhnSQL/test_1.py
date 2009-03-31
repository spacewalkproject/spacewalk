#!/usr/bin/python
#Copyright (c) 2005, Red Hat Inc.
#
#
#
# $Id$

import os
import string
import unittest
import time
import types
from server import rhnSQL

DB = 'rhnuser/rhnuser@webdev'

class Tests1(unittest.TestCase):

    def setUp(self):
        self.table_name = "misatest_%d" % os.getpid()
        rhnSQL.initDB(DB)
        self._cleanup()

        rhnSQL.execute("create table %s (id int, val varchar2(10))" %
            self.table_name)
        rhnSQL.commit()

    def _cleanup(self):
        try:
            rhnSQL.execute("drop table %s" % self.table_name)
        except rhnSQL.SQLStatementPrepareError:
            pass
        
    def tearDown(self): 
        self._cleanup()
       
        rhnSQL.commit() 

    def test_exception_procedure_1(self):
        "Tests exceptions raised by procedure calls"
        p = rhnSQL.Procedure("rhn_channel.subscribe_server")
        self.assertRaises(rhnSQL.SQLSchemaError, p, 1000102174, 33)

    def test_function_1(self):
        "Tests function calls"
        p = rhnSQL.Function("rhn_entitlements.get_server_entitlement", 
            rhnSQL.types.STRING())
        ret = p(1000102174)
        self.failUnless(isinstance(ret, types.StringType))

    def _run_stproc(self):
        p = rhnSQL.Procedure("create_new_org")
        username = password = "unittest-%.3f" % time.time()
        args = (username, password, None, None, 'P', rhnSQL.types.NUMBER(),
            rhnSQL.types.NUMBER(), rhnSQL.types.NUMBER())
        return apply(p, args), args
        
    def test_procedure_1(self):
        "Tests procedure calls that return things in their OUT variables"
        ret, args = self._run_stproc()
        self.assertEqual(len(args), len(ret))
        self.assertEqual(args[0], ret[0])
        self.assertEqual(args[1], ret[1])
        self.assertEqual(args[2], ret[2])
        self.assertEqual(args[3], ret[3])
        self.assertEqual(args[4], ret[4])
        self.assertNotEqual(args[5], None)
        self.assertNotEqual(args[6], None)
        self.assertNotEqual(args[7], None)

    def test_procedure_2(self):
        """Run the same stored procedure twice. This should excerise the
        cursor cache"""
        self.test_procedure_1()
        self.test_procedure_1()

    def test_executemany_1(self):
        """Tests executemany"""
        q = "insert into %s (id, val) values (:id, :val)" % self.table_name
        h = rhnSQL.prepare(q)
        ids = [1, 2, 3] * 100
        vals = [11, 22, 33] * 100
        h.executemany(id=ids, val=vals)

    def test_ddl_1(self):
        """Tests table creation/table removal"""
        table_name = self.table_name + "_1"
        rhnSQL.execute("create table %s (id int)" % table_name)
        tables = self._list_tables()
        self.failUnless(string.upper(table_name) in tables, 
            "Table %s not created" % table_name)
        rhnSQL.execute("drop table %s" % table_name)

    def test_ddl_2(self):
        """Tests table creation twice"""
        self.test_ddl_1()
        self.test_ddl_1()

    def test_execute_rowcount(self):
        """Tests row counts"""
        # XXX
        table_name = "misatest"
        rhnSQL.execute("delete from misatest")
        ret = rhnSQL.execute("insert into misatest values (1, 1)")
        self.assertEqual(ret, 1)
        ret = rhnSQL.execute("insert into misatest values (2, 2)")
        self.assertEqual(ret, 1)

        ret = rhnSQL.execute("delete from misatest")
        self.assertEqual(ret, 2)
        rhnSQL.commit()

    def _list_tables(self):
        h = rhnSQL.prepare("select table_name from user_tables")
        h.execute()
        return map(lambda x: string.upper(x['table_name']), h.fetchall_dict()
            or [])

if __name__ == '__main__':
    unittest.main()

