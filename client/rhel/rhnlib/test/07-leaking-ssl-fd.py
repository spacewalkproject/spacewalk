#!/usr/bin/python
#
# tests leaking file descriptors
#
# $Id$

# How to test: run the script and do netstat -tanp | grep 443 in a different
# terminal

import os
import sys
import httplib
sys.path.append('..')
from rhn.rpclib import Server, GETServer

SERVER = "xmlrpc.rhn.redhat.com"
HANDLER = "/XMLRPC"

def get_test_server_https():
    global SERVER, HANDLER
    return Server("https://%s%s" % (SERVER, HANDLER))

def get_test_GET_server_https(headers):
    global SERVER, HANDLER
    return GETServer("https://%s%s" % (SERVER, HANDLER), headers=headers)

def get_package_name(p):
    return "%s-%s-%s.%s.rpm" % (p[0], p[1], p[2], p[4])

if __name__ == '__main__':
    if len(sys.argv) > 1:
        system_id_file = sys.argv[1]
    else:
        system_id_file = '/etc/sysconfig/rhn/systemid'

    print "PID:", os.getpid()
    systemid = open(system_id_file).read()

    s = get_test_server_https()

    dict = s.up2date.login(systemid)
    channels = dict['X-RHN-Auth-Channels']
    c = channels[0]

    gs = get_test_GET_server_https(dict)
    lp = gs.listPackages(c[0], c[1])

    package_count = len(lp)
    i = 0
    pi = 0
    while 1:
        if pi == package_count:
            # Wrap
            pi = 0
        p = lp[pi]
        pn = get_package_name(p)
        
        fd = gs.getPackageHeader(c[0], pn)
        buffer = fd.read()
        assert len(buffer) != 0
        print "Called %-4d; header length: %-6d for %s" % (i, len(buffer), pn)
        i = i + 1
        pi = pi + 1
