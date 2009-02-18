#!/usr/bin/python
#
# Tests the encodings in Input and Output objects
#
# $Id$

import string
import sys 
sys.path.append('..')
from rhn import rpclib

if len(sys.argv) > 1:
    system_id_file = sys.argv[1]
else:
    system_id_file = '/etc/sysconfig/rhn/systemid'

systemid = open(system_id_file).read()
#server_url = "http://coyote.devel.redhat.com/XMLRPC"
server_url = "http://xmlrpc.rhn.webdev.redhat.com/XMLRPC"

s = rpclib.Server(server_url)
cookie = s.up2date.login(systemid)

gs = rpclib.GETServer(server_url, headers=cookie)
gs.set_transport_flags(allow_partial_content=1)

channel_name, channel_version = cookie['X-RHN-Auth-Channels'][0][:2]

package_list = gs.listPackages(channel_name, channel_version)

for p in package_list:
    if p[0] == 'python':
        break
pn, pv, pr, pe, pa = p[:5]
package_name = "%s-%s-%s.%s.rpm" % (pn, pv, pr, pa)

fd = gs.getPackage(channel_name, package_name, offset=1023)
#, amount=10)

print gs.get_response_headers()
print "Status", gs.get_response_status()
print "Reason", gs.get_response_reason()
h = gs.get_content_range()
print h
assert(h['first_byte_pos'] == 1023, h['first_byte_pos'])
