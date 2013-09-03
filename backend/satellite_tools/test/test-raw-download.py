#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#
import os
import httplib
import xmlrpclib

def make_request(server, systemid):
    buffer = xmlrpclib.dumps((systemid, ), methodname="dump.channel_families")
    h = httplib.HTTP(server)
    h.putrequest("POST", "/SAT-DUMP")
    h.putheader("X-RHN-Satellite-XML-Dump-Version", "2.0")
    h.putheader("Content-Length", str(len(buffer)))
    h.endheaders()
    h.send(buffer)
    errcode, errmsg, headers = h.getreply()
    print errcode, errmsg
    f = h.getfile()
    open("/tmp/ggg.gz", "w+").write(f.read())
    f.close()

if __name__ == '__main__':
    server = "coyote.devel.redhat.com"
    systemid = open("systemid-satellite-live").read()
    print "PID:", os.getpid()
    for i in range(1000):
        print i
        make_request(server, systemid)
