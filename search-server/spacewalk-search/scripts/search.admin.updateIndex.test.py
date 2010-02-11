#!/usr/bin/env python

import sys
import xmlrpclib

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print "Usage: %s INDEX_NAME" % (sys.argv[0])
        sys.exit(1)
    port = 2828
    addr = "http://127.0.0.1:%s" % (port)
    client  = xmlrpclib.ServerProxy(addr)
    indexName = sys.argv[1]
    result = client.admin.updateIndex(indexName)
    print "Return from admin.updateIndex(%s) = %s" % (indexName, result)
