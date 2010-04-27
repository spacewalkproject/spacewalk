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
import time

SERVER = "xmlrpc.rhn.redhat.com"
HANDLER = "/XMLRPC"
PROXY=None
system_id_file = '/etc/sysconfig/rhn/systemid'
try:
    SERVER = sys.argv[1]
    system_id_file = sys.argv[2]
    PROXY = sys.argv[3]
except:
    pass



"""Make few attempts over ssl"""
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
        p = lp[0]
        pn = "%s-%s-%s.%s.rpm" % (p[0], p[1], p[2], p[4])
        print pn

        i = 0
        while i < 100 and not self.term: # Make few attempts
            try:
                fd = gs.getPackageHeader(c[0], pn)
                print "Called %-4d" % i
            except Exception, e:
                if (str(e) == "(4, 'Interrupted system call')"):
                    pass
                else:
                    raise e;
            i = i + 1

        return 0;

    def terminate(self):
        self.term = True;

    def get_test_server_https(self):
        global SERVER, HANDLER, PROXY
        return Server("https://%s%s" % (SERVER, HANDLER), proxy=PROXY)

    def get_test_GET_server_https(self, headers):
        global SERVER, HANDLER, PROXY
        return GETServer("https://%s%s" % (SERVER, HANDLER), headers=headers,proxy=PROXY)


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
            attempt.terminate();
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

