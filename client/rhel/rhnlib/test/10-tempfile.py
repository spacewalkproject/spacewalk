#!/usr/bin/python
#
# Test for tempfile creation
# Use lsof to see how many open files we have
#
# $Id$

import sys
sys.path.append('..')
from rhn.SmartIO import _tempfile

def t():
    f = _tempfile()
    for i in range(1024):
        f.write(("%s" % (i % 10)) * 1023 + "\n")

    f.seek(0, 2)
    assert(f.tell() == 1048576)
    return f

if __name__ == '__main__':
    print "Running and saving stream object references"
    ret = []
    for i in range(100):
        print "Saving", i
        ret.append(t())

    del ret
        
    print "Running without saving object references"
    for i in range(1000):
        print "Running", i
        t()
