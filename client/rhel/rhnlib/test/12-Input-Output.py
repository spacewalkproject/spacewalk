#!/usr/bin/python
#
# Tests the encodings in Input and Output objects
#
# $Id$

import sys
sys.path.append('..')
from rhn import transports
from cStringIO import StringIO

REFERENCE = "the quick brown fox jumps over the lazy dog" * 1024

def t(transfer, encoding):
    print "\n---> Testing transfer=%s, encoding=%s" % (transfer, encoding)
    o = transports.Output(transfer=transfer, encoding=encoding)
    o.process(REFERENCE)
    print "Output: data length: %s; headers: %s" % (len(o.data), o.headers)

    i = transports.Input(o.headers)
    i.read(StringIO(o.data))
    io = i.decode()
    io.seek(0, 0)
    data = io.read()
    assert(REFERENCE == data)

if __name__ == '__main__':
    tests = []
    for transfer in range(3):
        for encoding in range(3):
            tests.append((transfer, encoding))
        
    for test in tests:
        t(test[0], test[1])
