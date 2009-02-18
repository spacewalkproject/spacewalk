#!/usr/bin/python
#
# Test _smart_read over a slow socket
# Use lsof to see how many open files we have
#
# $Id$

import sys
sys.path.append('..')
from rhn.rpclib import transports

import time
from cStringIO import StringIO

class SlowSocket:
    def __init__(self):
        self._buf = StringIO()

    def read(self, amt=None):
        time.sleep(.01)
        return self._buf.read(amt)
    
    def __getattr__(self, name):
        return getattr(self._buf, name)

def t():
    buf = SlowSocket()
    for i in range(1024):
        buf.write(("%s" % (i % 10)) * 1023 + "\n")
    buf.seek(0, 2)
    amt = buf.tell()

    buf.seek(0, 0)
    print "Using temp file"
    f = transports._smart_read(buf, amt)
    f.seek(0, 2)
    print "Read", f.tell(), type(f._io)

    buf.seek(0, 0)
    print "Reading in memory..."
    f = transports._smart_read(buf, amt, max_mem_size=amt+1)
    f.seek(0, 2)
    print "Read", f.tell(), type(f._io)
    

if __name__ == '__main__':
    for i in range(1000):
        print "Running", i
        t()
