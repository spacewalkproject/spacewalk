#!/usr/bin/python
#
#
#
# $Id$
#
# Usage: $0 SERVER PROXY [SYSTEMID]

import sys
sys.path.append('..')
from rhn.rpclib import Server
from rhn.connections import HTTPProxyConnection, HTTPSConnection, HTTPSProxyConnection
from rhn.transports import Output

SERVER = "xmlrpc.rhn.redhat.com"
HANDLER = "/XMLRPC"
PROXY = "proxy.example.com:8080"
system_id_file = '/etc/sysconfig/rhn/systemid'

if len(sys.argv) < 3:
    print "Non efficient cmd-line arguments! Provide at least server & proxy!"
    sys.exit(1);
try:
    SERVER = sys.argv[1]
    PROXY = sys.argv[2]
    system_id_file = sys.argv[3]
except:
    pass

print "SERVER = %s" % SERVER
print "PROXY = %s" % PROXY
print "system_id_file = %s" % system_id_file

def get_test_server_proxy_http():
    global SERVER, HANDLER, PROXY
    return Server("http://%s%s" % (SERVER, HANDLER), proxy=PROXY)

def get_test_server_proxy_https():
    global SERVER, HANDLER, PROXY
    return Server("https://%s%s" % (SERVER, HANDLER), proxy=PROXY)

def get_test_server_https():
    global SERVER, HANDLER
    return Server("https://%s%s" % (SERVER, HANDLER))

def get_test_server_http():
    global SERVER, HANDLER
    return Server("http://%s%s" % (SERVER, HANDLER))

    
if __name__ == '__main__':
    systemid = open(system_id_file).read()

    tests = [
        get_test_server_http,
        get_test_server_https,
        get_test_server_proxy_http,
        get_test_server_proxy_https,
    ]
    for gs in tests:
        s = gs()
        print "--- %s ---" % gs
        print s.up2date.login(systemid)
    

