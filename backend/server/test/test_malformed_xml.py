#
# Copyright (c) 2008--2016 Red Hat, Inc.
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
from rhn.rpclib import transports

httplib = transports.connections.httplib

#server = "rhn.webdev.redhat.com"
server = "coyote.devel.redhat.com"
#server = "rhn.webqa.redhat.com"

data = """
    <?xml version='1.0'?>
    <methodCall>
    <methodName>abc</methodName>
    <params>
    <param>
    <value><string>a</string></value>
    </param>
    <param>
    <value><string>b</string></value>
    </param>
    </params>

    </methodCall>
    ember>
    <name>count</name>
    <value><int>1</int></value>
    </member>
    </struct></value>
    <value><struct>
    <member>
"""

h = httplib.HTTPConnection(server)

h.putrequest("POST", "/XMLRPC")

h.putheader('Content-Length', str(len(data)))
h.endheaders()

h.send(data)

r = h.getresponse()
print(r.msg.headers)

print(r.read())
