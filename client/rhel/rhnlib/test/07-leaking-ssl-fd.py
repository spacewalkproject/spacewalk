#!/usr/bin/python
#
# tests leaking file descriptors
#
# $Id$
#
# USAGE:  $0 SERVER SYSTEMID

import os
import sys
import httplib
sys.path.append('..')
from rhn.rpclib import Server, GETServer
from threading import Thread

SERVER = "xmlrpc.rhn.redhat.com"
HANDLER = "/XMLRPC"
system_id_file = '/etc/sysconfig/rhn/systemid'
try:
    SERVER = sys.argv[1]
    system_id_file = sys.argv[2]
except:
    pass


"""Make few attempts"""
class makeAttempts(Thread):
    def __init__(self):
        Thread.__init__(self);
        self.server = self.get_test_server_https()
        self.term = False;

    def run(self):
        global system_id_file
        systemid = open(system_id_file).read()
        
        dict = self.server.up2date.login(systemid)
        channels = dict['X-RHN-Auth-Channels']
        c = channels[0]

        gs = self.get_test_GET_server_https(dict)
        lp = gs.listPackages(c[0], c[1])
        package_count = len(lp)
        i = 0
        pi = 0
        while i < 1000 and not self.term:
            if pi == package_count:
                # Wrap
                pi = 0
            p = lp[pi]
            pn = self.get_package_name(p)
            try:
                fd = gs.getPackageHeader(c[0], pn)
            except Exception, e:
                if (str(e) == "(4, 'Interrupted system call')"):
                    pass
                    continue;
                else:
                    raise e;

            buffer = fd.read()
            assert len(buffer) != 0
            print "Called %4d; header length: %-6d for %s" % (i, len(buffer), pn)
            i = i + 1
            pi = pi + 1

    def terminate(self):
        self.term = True;

    def get_test_server_https(self):
        global SERVER, HANDLER
        return Server("https://%s%s" % (SERVER, HANDLER))

    def get_test_GET_server_https(self, headers):
        global SERVER, HANDLER
        return GETServer("https://%s%s" % (SERVER, HANDLER), headers=headers)

    def get_package_name(self, p):
        return "%s-%s-%s.%s.rpm" % (p[0], p[1], p[2], p[4])

import time;

if __name__ == '__main__':
    print "PID:", os.getpid()

    attempt = makeAttempts();
    attempt.start();
    time.sleep(3);

    # Try to catch netstat, while thread is still running
    port443 = "netstat -tanp |grep :443 | grep %s/python" % os.getpid()
    port80 = "netstat -tanp |grep :80 | grep %s/python" % os.getpid()
    while attempt.isAlive():
        res80 = os.system(port80)
        if (res80 == 0):        # Port 80 is used ERROR
            attemt.terminate();
            attempt.join();
            print "ERROR: Port 80 is used!"
            sys.exit(1);

        res443 = os.system(port443)
        if (res443 == 0):       # Port 443 is used ok
            attempt.terminate();
            attempt.join();
            print "OK"
            sys.exit(0);

    attempt.join();
    print("ERROR: Port 443 was not used!");
    sys.exit(-1);




