#!/usr/bin/python
#
#
#
# $Id$


import sys
sys.path.append('..')
from rhn.rpclib import Server
from rhn.connections import HTTPProxyConnection, HTTPSConnection, HTTPSProxyConnection
from rhn.transports import Output

SERVER = "xmlrpc.rhn.redhat.com"
HANDLER = "/XMLRPC"
PROXY = "cellar.rhndev.redhat.com:3129"

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
    if len(sys.argv) > 1:
        system_id_file = sys.argv[1]
    else:
        system_id_file = '/etc/sysconfig/rhn/systemid'

    systemid = open(system_id_file).read()

    tests = [
        get_test_server_http,
        get_test_server_https,
        get_test_server_proxy_http,
        get_test_server_proxy_https,
    ]
    for gs in tests:
        s = gs()
        print s.up2date.login(systemid)
    
    sys.exit(0)

    h = HTTPSProxyConnection(PROXY, 'www.redhat.com')
    #h = HTTPSConnection('www.redhat.com')
    h.connect()
    h.putrequest("GET", "/")
    h.endheaders()
    response = h.getresponse()
    print "XXX", response.status
    print "YYY", response.reason
    print "XXX", response.msg
    print "--%s---" % response.read()
    
    sys.exit(0)
    h = Output()
    h.process("Googoogoo")
    headers, fd = h.send_http("roadrunner.devel.redhat.com", handler="/XMLRPC")
    print headers

    sys.exit(0)
    h = HTTPProxyConnection('tuxmonkey.support.redhat.com:8080', 
        'www.redhat.com')
    h.connect()
    h.putrequest("GET", "/")
    h.endheaders()
    response = h.getresponse()
    print "XXX", response.status
    print "YYY", response.reason
    print "XXX", response.msg
    print "GGG", response.read()

    sys.exit(0)
    s = Server("http://roadrunner.devel.redhat.com:2121/googgaaa")
    s.goo.gaa()
