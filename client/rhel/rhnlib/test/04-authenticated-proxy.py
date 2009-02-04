#!/usr/bin/python
#
#
#
# $Id$

import sys
import httplib
sys.path.append('..')
from rhn.rpclib import Server
from rhn.connections import HTTPProxyConnection, HTTPSProxyConnection

SERVER = "xmlrpc.rhn.redhat.com"
HANDLER = "/XMLRPC"
PROXY = "cellar.rhndev.redhat.com:3128"
PROXY_USERNAME = "rhn"
PROXY_PASSWORD = "rhn"

def get_test_server_proxy_http():
    global SERVER, HANDLER, PROXY
    return Server("http://%s%s" % (SERVER, HANDLER), proxy=PROXY,
        username=PROXY_USERNAME, password=PROXY_PASSWORD)

def get_test_server_proxy_https():
    global SERVER, HANDLER, PROXY
    return Server("https://%s%s" % (SERVER, HANDLER), proxy=PROXY,
        username=PROXY_USERNAME, password=PROXY_PASSWORD)

    
if __name__ == '__main__':
    if len(sys.argv) > 1:
        system_id_file = sys.argv[1]
    else:
        system_id_file = '/etc/sysconfig/rhn/systemid'

    systemid = open(system_id_file).read()

    tests = [
        get_test_server_proxy_http,
        get_test_server_proxy_https,
    ]
    for gs in tests:
        s = gs()
        print s.up2date.login(systemid)
