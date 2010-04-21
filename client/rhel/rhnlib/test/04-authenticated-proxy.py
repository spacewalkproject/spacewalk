#!/usr/bin/python
#
#
#
# $Id$ 
#
# Usage: $0 SERVER PROXY:PORT [SYSTEMID] [PROXY_USER] [PROXY_PASS]

import sys
import httplib
sys.path.append('..')
from rhn.rpclib import Server
from rhn.connections import HTTPProxyConnection, HTTPSProxyConnection

SERVER = "xmlrpc.rhn.redhat.com"
HANDLER = "/XMLRPC"
PROXY = "proxy.example.com:8080"
PROXY_USERNAME = None
PROXY_PASSWORD = None
system_id_file = '/etc/sysconfig/rhn/systemid'

if len(sys.argv) < 3: 
    print "Non efficient cmd-line arguments! Provide at least server & proxy!"
    sys.exit(1);

try:
    SERVER = sys.argv[1];
    PROXY = sys.argv[2];
    system_id_file = sys.argv[3]
    PROXY_USERNAME = sys.argv[4];
    PROXY_PASSWORD = sys.argv[5];
except:
    pass



def get_test_server_proxy_http():
    global SERVER, HANDLER, PROXY
    return Server("http://%s%s" % (SERVER, HANDLER), proxy=PROXY,
        username=PROXY_USERNAME, password=PROXY_PASSWORD)

def get_test_server_proxy_https():
    global SERVER, HANDLER, PROXY
    return Server("https://%s%s" % (SERVER, HANDLER), proxy=PROXY,
        username=PROXY_USERNAME, password=PROXY_PASSWORD)

    
if __name__ == '__main__':
    systemid = open(system_id_file).read()

    tests = [
        get_test_server_proxy_http,
        get_test_server_proxy_https,
    ]
    for gs in tests:
        s = gs()
        print s.up2date.login(systemid)
