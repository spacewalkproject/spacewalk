#!/usr/bin/python
# Copyright (c) 2005--2010 Red Hat, Inc.
#
#
#

import unittest
from spacewalk.server import rhnSQL

import misc_functions

DB_SETTINGS = misc_functions.db_settings("oracle")

class ExceptionsTest(unittest.TestCase):
    def setUp(self):
        rhnSQL.initDB(
            backend  = "oracle",
            username = DB_SETTINGS["user"],
            password = DB_SETTINGS["password"],
            database = DB_SETTINGS["database"]
        )
        self._cleanup()

        rhnSQL.execute("create table misatestlob (id int, val blob)")
        rhnSQL.execute("create sequence misatestlob_id_seq")


    def _cleanup(self):
        try:
            rhnSQL.execute("drop table misatestlob")
        except rhnSQL.SQLStatementPrepareError:
            pass

        try:
            rhnSQL.execute("drop sequence misatestlob_id_seq")
        except rhnSQL.SQLStatementPrepareError:
            pass
        except rhnSQL.SQLError, e:
            if e.args[0] != 2289:
                raise

    def tearDown(self):
        self._cleanup()

        rhnSQL.commit()

    def test_lobs(self):
        new_id = rhnSQL.Sequence('misatestlob_id_seq').next()
        h = rhnSQL.prepare("""
            insert into misatestlob (id, val) values (:id, empty_blob())
        """)
        h.execute(id=new_id)

        h = rhnSQL.prepare("""
            select val from misatestlob where id = :id for update of val
        """)
        h.execute(id=new_id)
        row = h.fetchone_dict()
        self.assertNotEqual(row, None)
        lob = row['val']
        s = ""
        for i in range(256):
            s = s + chr(i)
        lob.write(s)
        rhnSQL.commit()

        h = rhnSQL.prepare("""
            select val from misatestlob where id = :id
        """)
        h.execute(id=new_id)
        row = h.fetchone_dict()
        self.assertNotEqual(row, None)
        lob = row['val']
        data = rhnSQL.read_lob(lob)
        self.assertEqual(data, s)


if __name__ == '__main__':
    unittest.main()
