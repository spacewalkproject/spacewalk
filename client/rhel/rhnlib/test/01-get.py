#!/usr/bin/python
#
#
#
# $Id$

import sys
sys.path.append('..')
from rhn.rpclib import Server, GETServer

SERVER = "http://xmlrpc.rhn.redhat.com/XMLRPC"
#SERVER = "http://xmlrpc.rhn.webqa.redhat.com/XMLRPC"

s = Server(SERVER)
if len(sys.argv) > 1:
    systemid_file = sys.argv[1]
else:
    systemid_file = "/etc/sysconfig/rhn/systemid"
sysid = open(systemid_file).read()

dict = s.up2date.login(sysid)
print dict

channels = dict['X-RHN-Auth-Channels']

channel_name, channel_version = channels[0][:2]

sg = GETServer(SERVER, headers=dict)
l = sg.listPackages(channel_name, channel_version)

print l

# Package download
package = l[0]
filename = "%s-%s-%s.%s.rpm" % (package[0], package[1], package[2],
                package[4])
fd = sg.getPackage(channel_name, filename)
f = open("/tmp/test-get-%s" % filename, "w+")
f.write(fd.read())
f.close()
