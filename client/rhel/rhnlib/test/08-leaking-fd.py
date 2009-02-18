#!/usr/bin/python
#
# tests leaking file descriptors
#
# $Id$

# How to test: run the script and do netstat -tanp | grep 80 in a different
# terminal

import os
import sys
import httplib
sys.path.append('..')
from rhn.rpclib import Server, GETServer

SERVER = "xmlrpc.rhn.webqa.redhat.com"
HANDLER = "/XMLRPC"
#PROXY="rhn-cellar.back-webdev.redhat.com:3129"
PROXY=None

def get_test_server_https():
    global SERVER, HANDLER, PROXY
    return Server("https://%s%s" % (SERVER, HANDLER), proxy=PROXY)

def get_test_GET_server_https(headers):
    global SERVER, HANDLER, PROXY
    return GETServer("https://%s%s" % (SERVER, HANDLER), headers=headers,
        proxy=PROXY)

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
    p = lp[0]
    pn = "%s-%s-%s.%s.rpm" % (p[0], p[1], p[2], p[4])
    print pn

    i = 0
    while 1:
        fd = gs.getPackageHeader(c[0], pn)
        print "Called %-4d" % i
        i = i + 1

