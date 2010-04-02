#!/usr/bin/python
#
# munge the headers to produce an error message
#
# $Id$
#
# USAGE:  $0 SERVER SYSTEMID

import sys
sys.path.append('..')
from rhn.rpclib import Server, GETServer, ProtocolError, reportError

SERVER = "xmlrpc.rhn.redhat.com"
HANDLER = "/XMLRPC"
system_id_file = '/etc/sysconfig/rhn/systemid'
try:
    SERVER = sys.argv[1]
    system_id_file = sys.argv[2]
except:
    pass

def get_test_server_https():
    global SERVER, HANDLER
    return Server("https://%s%s" % (SERVER, HANDLER))


s = get_test_server_https()
sysid = open(system_id_file).read()

dict = s.up2date.login(sysid)
print dict

dict['X-RHN-Auth-Server-Time'] = 1324

channels = dict['X-RHN-Auth-Channels']
channel_name, channel_version = channels[0][:2]

sg = GETServer("http://xmlrpc.rhn.redhat.com/XMLRPC", headers=dict)
try:
    l = sg.listPackages(channel_name, channel_version)
except ProtocolError, e:
    print reportError(e.headers)
    print("OK (error above expected)");
    sys.exit(0);
print("ERROR: Exception didn't occured!");
sys.exit(-1);
