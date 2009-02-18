#!/usr/bin/python
#
# Tests the encodings in Input and Output objects
#
# $Id$
#
# 2004-11-29: fails, but it looks like it never worked. Need to investigate

import string
import sys 
sys.path.append('..')
from rhn import transports, xmlrpclib
from cStringIO import StringIO

REFERENCE_XML = {
    'a'     : [1, 'b', '3'],
    '2'     : [1, {'b' : 2}],
}

REFERENCE_BLOB = "a1b2c3d4e5" * 100

def test_xmlrpc(transfer, encoding):
    print "\n---> XML Testing transfer=%s, encoding=%s" % (transfer, encoding)
    data = xmlrpclib.dumps((REFERENCE_XML, ), methodresponse=1)
    o = transports.Output(transfer=transfer, encoding=encoding)
    o.set_header('Content-Type', 'text/xml')
    o.process(data)
    headers = o.headers
    # Added by the connection layer
    headers['Content-Length'] = len(o.data)
    print "Output: headers: %s" % headers.items()

    i = transports.Input(headers)
    io = i.decode(StringIO(o.data))
    assert(string.lower(i.type) == 'text/xml')

    io.seek(0, 0)
    data = io.read()
    params, dummy = xmlrpclib.loads(data)
    assert(REFERENCE_XML == params[0])

def test_blob(transfer, encoding):
    print "\n---> BLOB Testing transfer=%s, encoding=%s" % (transfer, encoding)
    o = transports.Output(transfer=transfer, encoding=encoding)
    o.set_header('Content-Type', 'application/binary')
    o.process(REFERENCE_BLOB)
    headers = o.headers
    # Added by the connection layer
    headers['Content-Length'] = len(o.data)
    print "Output: headers: %s" % headers.items()

    i = transports.Input(headers)
    io = i.decode(StringIO(o.data))
    assert(string.lower(i.type) == 'application/binary')

    io.seek(0, 0)
    data = io.read()
    assert(REFERENCE_BLOB == data)

if __name__ == '__main__':
    tests = []
    for transfer in range(3):
        for encoding in range(3):
            tests.append((transfer, encoding))
        
    for test in tests:
        test_xmlrpc(test[0], test[1])
        test_blob(test[0], test[1])
