import socket
import sys
sys.path.append('..')
from rhn.connections import HTTPConnection 

def callback(r, w, x, u):
    print "Callback called"
    print r[0].read()

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(("localhost", 5555))
f = s.makefile()


h = HTTPConnection("roadrunner.devel.redhat.com", 8001)
h.set_callback([f], [], [], None, callback)
h.putrequest("GET", "/")
h.endheaders()
resp = h.getresponse()
print resp.status
print resp.read()
