#!/usr/bin/python
#
#
#
# $Id$
#
# Usage: $0 SERVER PROXY 


import sys
sys.path.append('..')
from rhn.connections import HTTPSProxyConnection

try:
    SERVER = sys.argv[1];
    PROXY = sys.argv[2];
except:
    print "Non efficient cmd-line arguments! Provide at least server & proxy!"
    sys.exit(1);

h = HTTPSProxyConnection(PROXY, SERVER)
h.connect()

