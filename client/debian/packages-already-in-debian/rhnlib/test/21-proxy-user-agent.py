#!/usr/bin/python
#
# tests rhn.rpclib.Server(), connection through proxy
#
# $Id$
#
# USAGE:  $0 SERVER PROXY [SYSTEMID]

import sys
sys.path.append('..')
from rhn import rpclib

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

SERVER_URL = "https://" + SERVER + HANDLER

systemid = open(system_id_file).read()

s = rpclib.Server(SERVER_URL, proxy = PROXY)

dict = s.up2date.login(systemid);

print "Test PASSES"
