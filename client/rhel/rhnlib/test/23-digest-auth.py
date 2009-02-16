#!/usr/bin/python
#
# Test case for digest authentication
#
# $Id$

# To run the test: nc -l -p 1235
# Run this script
# You should see a 'authorization: Basic # bG9uZ3VzZXJuYW1lMDEyMzQ1Njc4OTpsb25ncGFzc3dvcmQwMTIzNDU2Nzg5' header

import sys
sys.path.append('..')
from rhn.rpclib import Server

SERVER = "longusername0123456789:longpassword0123456789@localhost:1234"
HANDLER = "/XMLRPC"

if __name__ == '__main__':
    s = Server("http://%s/%s" % (SERVER, HANDLER))
    print s.test.method()
