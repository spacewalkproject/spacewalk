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
from rhn.rpclib import Server

SERVER = "xmlrpc.rhn.webqa.redhat.com"
HANDLER = "/XMLRPC"

def get_test_server_https():
    global SERVER, HANDLER
    return Server("https://%s%s" % (SERVER, HANDLER))

if __name__ == '__main__':
    if len(sys.argv) > 1:
        system_id_file = sys.argv[1]
    else:
        system_id_file = '/etc/sysconfig/rhn/systemid'

    print "PID:", os.getpid()
    systemid = open(system_id_file).read()

    s = get_test_server_https()

    i = 0
    while 1:
        dict = s.up2date.login(systemid)
        print "Called %-4d" % i
        i = i + 1

