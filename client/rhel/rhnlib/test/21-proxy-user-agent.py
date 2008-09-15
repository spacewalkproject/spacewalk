import sys
sys.path.append('..')
from rhn import rpclib

s = rpclib.Server("https://xmlrpc.rhn.redhat.com/XMLRPC", 
    proxy="localhost:1234")

print s.a.b()
