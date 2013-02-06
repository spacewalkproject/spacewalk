#!/usr/bin/python
#
# Test for tempfile creation
# Use lsof to see how many open files we have
#
# $Id$

import sys
import os
import glob
sys.path.append('..')
from rhn.SmartIO import _tempfile

def t():
    f = _tempfile()
    for i in range(1024):
        f.write(("%s" % (i % 10)) * 1023 + "\n")

    f.seek(0, 2)
    assert(f.tell() == 1048576)
    return f

def openedFiles():
    global pid
    path = '/proc/' + pid + '/fd/';
    return len(glob.glob(os.path.join(path, '*')));


if __name__ == '__main__':
    global pid
    pid = str(os.getpid());
    print "PID: ", pid;

    failed = False;

    print "Running and saving stream object references"
    ret = []
    for i in range(100):
        print "Saving", i
        ret.append(t())
        if openedFiles() != i + 5:
            print "FAIL: Opened files: ", openedFiles(), "but expected: ", str(i + 5);
            failed = True;

    del ret
        
    print "Running without saving object references"
    for i in range(1000):
        print "Running", i
        t()
        if openedFiles() not in  [4, ]:
            print "FAIL: Opened files: ", openedFiles(), "but expected 4!";
            failed = True;

    if failed:
        print "Test FAILS!"
        sys.exit(1);
    else:
        print "Test PASSES!"
        sys.exit(0);
