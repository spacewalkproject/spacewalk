#!/usr/bin/python
# Copyright (c) 2005, Red Hat Inc.
#
# $Id: listversions.py,v 1.3 2005-07-05 17:56:47 wregglej Exp $

import os, sys, cPickle
from DBObjects import Schema

if __name__ == '__main__':
    if not len(sys.argv) == 2:
	print 'usage: ./listversions.py dump_file'
        sys.exit(1)

    dumpFile = sys.argv[1]

    try:
        schemaFile = open(dumpFile,'r+')
        schemas = cPickle.load(schemaFile)
    except IOError:
        schemas = {}

    print schemas.keys()
