#!/usr/bin/python
#
# Tests the encodings in Input and Output objects
#
# $Id$

import string
import sys 
sys.path.append('..')
from rhn import rpclib

gs = rpclib.GETServer("http://coyote.devel.redhat.com/DOWNLOAD")
gs.set_transport_flags(allow_partial_content=1)

fd = gs.a.b('a', 'b', 'c', offset=9, amount=1)
#fd = gs.a.b('a', 'b', 'c')
print fd.read()

print gs.get_response_headers()
print "Status", gs.get_response_status()
print "Reason", gs.get_response_reason()
print gs.get_content_range()
