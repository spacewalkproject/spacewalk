#!/usr/bin/python
#
# Test case for digest authentication
#
# $Id$
#
# USAGE: (echo -n) | $0 PORT
#
# Few notes about what is done here:
#   - thread AUTH sends authentication digest
#   - thread NC uses netcat and grep to see results
#   - Little hack with (echo -n) is much more easier to use, 
#     than some settrace machinary

import sys
import socket
import os
import httplib
from threading import Thread
sys.path.append('..')
from rhn.rpclib import Server

SERVER = "longusername0123456789:longpassword0123456789@localhost"
PORT = "1234"
HANDLER = "/XMLRPC"
try:
    PORT = sys.argv[1]
except:
    pass

class killable(Thread):
    """Just Thread with a kill() method."""
    def __init__(self, *args, **keywords):
        Thread.__init__(self, *args, **keywords)
        self.killed = False

    def start(self):
        self.__run_backup = self.run
        self.run = self.__run # Force the Thread to install our trace.
        Thread.start(self)

    def __run(self):
        sys.settrace(self.globaltrace)
        self.__run_backup()
        self.run = self.__run_backup

    def globaltrace(self, frame, why, arg):
        if why == 'call':
             return self.localtrace
        else:
             return None

    def localtrace(self, frame, why, arg):
        if self.killed:
            if why == 'line':
                raise SystemExit()
        return self.localtrace

    def kill(self):
        self.killed = True


def authenticate():
    global SERVER, PORT, HANDLER
    s = Server("http://" + SERVER + ":" + PORT + HANDLER);
    connected = False;
    while not connected:
        try:
            connected = True;
            print s.test.method()
        except socket.error, e:
            # nobody is listenning, try to authenticate again
            connected = False;
            pass;    
        except httplib.BadStatusLine, e:
            # This is ok, netcat does not send apropriate response
            pass


def netcat():
    global auth
    cmd = "nc -l " + PORT + " | grep authorization\:\ Basic\ bG9uZ3VzZXJuYW1lMDEyMzQ1Njc4OTpsb25ncGFzc3dvcmQwMTIzNDU2Nzg5"
    result = os.system(cmd);
    if (result == 0):
        print "Tests PASSES"
    else:
        auth.kill();
        print "Test FAILS"


if __name__ == '__main__':
    global nc, auth
    nc  = killable(target = netcat);
    auth = killable(target = authenticate);
    
    nc.start();
    auth.start();

