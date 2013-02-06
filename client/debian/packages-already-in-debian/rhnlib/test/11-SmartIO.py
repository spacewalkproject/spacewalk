#!/usr/bin/python
#
# Test for SmartIO objects
#
# $Id$

import sys
sys.path.append('..')
from rhn.SmartIO import SmartIO
from cStringIO import OutputType

if __name__ == '__main__':
    s = SmartIO(max_mem_size=16384)
    for i in range(20):
        s.write(("%d" % (i % 10)) * 1023 + '\n')
        if i < 16:
            assert(isinstance(s._io, OutputType))
        else:
            assert(not isinstance(s._io, OutputType))
        print i, type(s._io), s._io.tell()
