#!/usr/bin/python
#
# munge the headers to produce an error message
#
# $Id$

import sys
sys.path.append('..')
from rhn.rpclib import Server, GETServer, ProtocolError, reportError

s = Server("http://xmlrpc.rhn.redhat.com/XMLRPC")
if len(sys.argv) > 1:
    system_id_file = sys.argv[1]
else:
    system_id_file = '/etc/sysconfig/rhn/systemid'

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
