import sys
sys.path.append('..')
from rhn.connections import HTTPSProxyConnection

h = HTTPSProxyConnection("localhost:1234", "xmlrpc.rhn.redhat.com")
h.connect()
