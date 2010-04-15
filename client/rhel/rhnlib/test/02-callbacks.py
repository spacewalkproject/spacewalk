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

def refreshCallback(*args, **kwargs):
    print "Called refreshCallback, args %s, kwargs %s" % (args, kwargs)

def progressCallback(*args, **kwargs):
    print "Called progressCallback, args %s, kwargs %s" % (args, kwargs)

if __name__ == '__main__':
    sysid = open(system_id_file).read()

    s = Server(SERVER)
    s.set_refresh_callback(refreshCallback)
    s.set_progress_callback(progressCallback)

    dict = s.up2date.login(sysid)

    gs = GETServer(SERVER, headers=dict)
    gs.set_refresh_callback(refreshCallback)
    gs.set_progress_callback(progressCallback, 16384)

    channels = dict['X-RHN-Auth-Channels']
    cn, cv = channels[0][:2]
    
    print "Calling listPackages"
    l = gs.listPackages(cn, cv)
    for p in l:
        if p[0] == 'kernel':
            package = p
            break
    else:
        raise Exception("Package not found")
    
    print "PACKAGE TO DOWNLOAD: %s %s %s %s" % (package[0], package[1], package[2], package[4])
    filename = "%s-%s-%s.%s.rpm" % (package[0], package[1], package[2], package[4])
    print "Calling getPackages"
    fd = gs.getPackage(cn, filename)
    data_name = "/tmp/foobar"
    data = open(data_name, "w+").write(fd.read())
    print "PACKAGE DOWNLOADED AS: %s" % data_name

