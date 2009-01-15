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
import string
from xml.sax import make_parser, saxutils
from xml.sax.handler import feature_namespaces
from xml.unicode.utf8_iso import utf8_to_code

parser = make_parser(feature_namespaces)

chars = []

def utf8_to_string(charlist):
    ret = []
    while charlist:
        c, charlist = utf8_to_code(1, charlist)
        ret.append(c)
    return string.join(ret, "")

class Handler(saxutils.DefaultHandler):
    def startElement(self, element, attrs):
        print "Start: %s" % element

    def endElement(self, element):
        print "End: %s" % element

    def characters(self, data):
        global chars
        chars.append(data)

f = open("/tmp/document.xml")
h = Handler()
parser.setContentHandler(h)

parser.parse(f)

chars = string.join(chars, "")
chars = utf8_to_string(chars)
print len(chars)
print chars
