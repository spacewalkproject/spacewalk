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
import httplib
import xmlrpclib


systemid = open('systemid-satellite-live').read()
data = xmlrpclib.dumps((systemid, ), methodname="dump.channel_families")

h = httplib.HTTP("roadrunner.devel.redhat.com")
h.putrequest("POST", "/SAT-DUMP")
h.putheader("Content-Type", "text/xml")
h.putheader("Content-Length", str(len(data)))
h.endheaders()
h.send(data)
errcode, errmsg, headers = h.getreply()
print "Errcode: ", errcode
print "Errmsg: ", errmsg
print headers
