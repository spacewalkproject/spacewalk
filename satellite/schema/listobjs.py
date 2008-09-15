#!/usr/bin/python
# Copyright (c) 2005, Red Hat Inc.
import os, sys, cPickle
_path = "/usr/share/rhn"
if _path not in sys.path:
    sys.path.append(_path)
from server import rhnSQL
from common.rhnException import rhnException
from DBObjects import Schema

if __name__ == '__main__':
    if not len(sys.argv) == 2:
	print 'usage: ./listobjs.py connect_string [owner]'
        sys.exit(1)

    connectString = sys.argv[1]
    owner = None
    if len(sys.argv) == 3:
	owner = sys.argv[2]

    rhnSQL.initDB(connectString)
    schema = Schema(owner)
    schema.populateFromDB()

    schema.listObjects()
