#!/usr/bin/python
#Copyright (c) 2005, Red Hat Inc.
#
#
#
# $Id$

raise Exception("""

This test is no more valid; see the bug
  https://bugzilla.redhat.com/show_bug.cgi?id=423351
""")

import os
import unittest
from server import rhnSQL

DB = 'rhnuser/rhnuser@webdev'

class ExecutemanyTest(unittest.TestCase):
    def setUp(self):
        self.table_name = "misatest_%d" % os.getpid()
        rhnSQL.initDB(DB)
        self._cleanup()
       #PGPORT_4:QUERY_REWRITE(data-type) 
        rhnSQL.execute("create table %s (id int, val varchar2(10))" %
            self.table_name)
    

    def _cleanup(self):
        try:
            rhnSQL.execute("drop table %s" % self.table_name)
        except rhnSQL.SQLStatementPrepareError:
            pass
        
    def tearDown(self): 
        self._cleanup()
       
        rhnSQL.commit() 

    def test_executemany(self):
        """
        Tests the case of passing an integer as a value into a VARCHAR2 column
        (executemany makes it more interesting because the driver generally
        verifies the param types; passing a string and an Int takes it one
        step further)
        """
       #PGPORT_1:NO Change
        h = rhnSQL.prepare("""
            insert into %s (id, val) values (:id, :val)
        """ % self.table_name)
        params = {
            'id'    : [1, 2],
            'val'   : ['', 3],
        }
        apply(h.executemany, (), params)
       #PGPORT_1:NO Change
        h = rhnSQL.prepare("select id, val from %s" % self.table_name)
        h.execute()
        rows = h.fetchall_dict()
        self.assertEqual(len(rows), 2)
        v_id, v_val = rows[0]['id'], rows[0]['val']
        self.assertEqual(v_id, 1)
        self.assertEqual(v_val, None)
        v_id, v_val = rows[1]['id'], rows[1]['val']
        self.assertEqual(v_id, 2)
        self.assertEqual(v_val, '3')


if __name__ == '__main__':
    unittest.main()
