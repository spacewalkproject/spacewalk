#!/usr/bin/python
# Copyright (c) 2005, Red Hat Inc.
#
# $Id: verify.py,v 1.5 2005-07-05 17:56:47 wregglej Exp $

import os, sys, cPickle
from server import rhnSQL
from common.rhnException import rhnException

from DBObjects import Schema

def getVersion():
    r = 1
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
	# sucky, sucky assumption.
	return '0.9.2-24'
    epoch = ''
    if not r['epoch'] is None:
	epoch = '%s:' % (r['epoch'], )
    retval = epoch + '%s-%s' % (r['version'], r['release'])
    return retval

if __name__ == '__main__':
    argvLen = len(sys.argv)
    if not argvLen >= 2 and not len(sys.argv) <= 4:
	print 'usage: ./verify.py connect_string'
	sys.exit(1)

    # XXX: probably we don't really need to hardcode this one in here
    schemaFileName = '/usr/share/rhn/schema/data'
    if len(sys.argv) >= 3:
	schemaFileName = sys.argv[2]

    version = None
    if len(sys.argv) >= 4:
	version = sys.argv[3]
    else:
	version = getVersion()

    connectString = sys.argv[1]

    schemaFile = open(schemaFileName,'r')
    schemas = cPickle.load(schemaFile)

    rhnSQL.initDB(connectString)

    storedSchema = Schema()
    try:
    	storedSchema.populateFromPickleString(schemas[version])
    except KeyError:
	print 'version: %s' % (getVersion(),)
	sys.exit(1)
    dbSchema = Schema()
    dbSchema.populateFromDB()

    from pprint import pprint
    cmplist = dbSchema.cmpList(storedSchema)
    cmpData = {}
    for cmp in cmplist:
	del cmp['diff']
	if not cmp['value'] == 0:
	    if not cmpData.has_key(cmp['type']):
		cmpData[cmp['type']] = []
	    cmpData[cmp['type']].append(cmp)
    pprint(cmpData)
