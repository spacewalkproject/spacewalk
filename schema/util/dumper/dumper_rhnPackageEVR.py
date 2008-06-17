#!/usr/bin/python
#
# This script dumps a database into a pickle format
#
# $Id$

import os
import sys
import time
import dbhash
import shelve
import string
import cPickle
import getopt

# Oracle lib
import DCOracle

# A shelve class that it is easier to work with
class Shelve(shelve.BsdDbShelf):
    def __init__(self, filename, flag='c'):
        shelve.BsdDbShelf.__init__(self, dbhash.open(filename, flag))
        
    # make these methods more efficient
    def __getitem__(self, key):
        return cPickle.loads(self.dict[key])
    def __setitem__(self, key, value):
        self.dict[key] = cPickle.dumps(value, 1)

# Globals
Oracle = None
Table = "rhnPackageEVR"
Output = None

# Parse args
opts, args = getopt.getopt(sys.argv[1:], "t:o:", ["oracle="])
for opt, arg in opts:
    if opt == "-o" or opt == "--oracle":
        Oracle = arg

# check the args
if Oracle is None or Table is None:
    print "ERROR: --oracle needs to be specified"
    sys.exit(-1)

# where do we output stuff
if args:
    Output = args[0]
else:
    Output = "%s.dump" % Table
out_file = Shelve(Output, "n")

# attempt Oracle connection
c = DCOracle.Connect(Oracle)

# test database
h = c.prepare("select sysdate from dual")
h.execute()
ret = h.fetchall_dict()
if not ret:
    print "ERROR: could not issue sample query to database"
    sys.exit(-1)
    
# prepare the request
msg = "Dumping Table %s..." % Table
h = c.prepare("select id, epoch, version, release from %s" % Table)
h.execute()
recno = 0
while 1:
    ret = h.fetchone_dict()
    if not ret:
        break
    recno = recno + 1    
    out_file["recno_%d" % recno] = ret
    sys.stdout.write("%s %d\r" % (msg, recno))
out_file.close()
print msg, recno, "records extracted into file", Output
