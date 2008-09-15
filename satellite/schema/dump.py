#!/usr/bin/python
# Copyright (c) 2005, Red Hat Inc.
#
# $Id: dump.py,v 1.7 2005-07-05 17:56:47 wregglej Exp $

import os, sys, cPickle
_path = "/usr/share/rhn"
if _path not in sys.path:
    sys.path.append(_path)

from server import rhnSQL
from common.rhnException import rhnException

from DBObjects import Schema

def getVersion():
    try:
	h = rhnSQL.prepare("""\
	    select
		rpn.name	    name,
		rpe.epoch	    epoch,
		rpe.version	    version,
		rpe.release	    release
	    from
		rhnPackageEVR   rpe,
		rhnPackageName  rpn,
		rhnVersionInfo  rvi
	    where
		rvi.label = 'schema'
		and rvi.name_id = rpn.id
		and rvi.evr_id = rpe.id
	""")
	h.execute()
	r = h.fetchone_dict()
    except:
	return '0.9.2-24'
    epoch = ''
    if not r['epoch'] is None:
	epoch = '%s:' % (r['epoch'], )
    retval = epoch + '%s-%s' % (r['version'], r['release'])
    return retval

if __name__ == '__main__':
    if not len(sys.argv) == 3:
	print 'usage: ./dump.py dump_file connect_string [owner]'
        sys.exit(1)

    dumpFile = sys.argv[1]
    connectString = sys.argv[2]
    owner = None
    if len(sys.argv) == 4:
	owner = sys.argv[3]

    try:
        schemaFile = open(dumpFile,'r+')
        schemas = cPickle.load(schemaFile)
    except IOError:
        schemas = {}

    rhnSQL.initDB(connectString)
    version = getVersion()
    schema = Schema(owner)
    schema.populateFromDB()

    schemas[version] = schema.pickleToString()

    schemaFile = open(dumpFile,"w+")
    # XXX blah.  we don't _really_ need to pickle this stuff twice.
    cPickle.dump(schemas, schemaFile)
