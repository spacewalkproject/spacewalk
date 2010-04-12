#!/usr/bin/python
#
#
#
# $Id$


import sys
sys.path.append('..')

from rhn.rpclib import get_proxy_info

tests = [
    ["http://user:pass@host:https", ('host', 'https', 'user', 'pass')],
    ["ftp://user@host", ('host', None, 'user', None)],
    ["http://user:@host:8080", ('host', '8080', 'user', '')],
    ["user:pass@host", ('host', None, 'user', 'pass')],
]

fail=0
for url, result in tests:
    r = get_proxy_info(url)
    if result != r:
        print "Test failed", url, r, result
        fail += 1

if (not fail):
    print "Test PASSES"
sys.exit(fail);

