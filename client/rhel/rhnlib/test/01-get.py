#!/usr/bin/python
#
#
#
# $Id$

import sys
sys.path.append('..')
from rhn.rpclib import Server, GETServer

SERVER = "http://xmlrpc.rhn.redhat.com/XMLRPC"
system_id_file = "/etc/sysconfig/rhn/systemid"
try:
    SERVER = "http://%s/XMLRPC" % sys.argv[1]
    system_id_file = sys.argv[2]
except:
    pass
print "SERVER = %s" % SERVER
print "system_id_file = %s" % system_id_file

s = Server(SERVER)
sysid = open(system_id_file).read()

dict = s.up2date.login(sysid)
print dict

channels = dict['X-RHN-Auth-Channels']

channel_name, channel_version = channels[0][:2]

sg = GETServer(SERVER, headers=dict)
l = sg.listPackages(channel_name, channel_version)

print l

# Package download
package = l[0]
print "PACKAGE TO DOWNLOAD: %s %s %s %s" % (package[0], package[1], package[2], package[4])
filename = "%s-%s-%s.%s.rpm" % (package[0], package[1], package[2],
                package[4])
fd = sg.getPackage(channel_name, filename)
f_name = "/tmp/test-get-%s" % filename
f = open(f_name, "w+")
f.write(fd.read())
f.close()
print "PACKAGE DOWNLOADED AS: %s" % f_name

