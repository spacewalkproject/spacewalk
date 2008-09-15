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
import libxml2

chars = []

class Handler(libxml2.SAXCallback):
    def startElement(self, element, attrs):
        print "Start: %s" % element

    def endElement(self, element):
        print "End: %s" % element

    def characters(self, data):
        global chars
        chars.append(data)

    def error(self, msg):
        print "GGGGGGGGGGGGGGG", msg

handler = Handler()

f = open("/tmp/document.xml")

libxml2.initParser()
ctxt = libxml2.createPushParser(handler, '', 0, None)
while 1:
    print "Chunk"
    chunk = f.read(10)
    if not len(chunk):
        break
    ctxt.parseChunk(chunk, len(chunk), 0)

print "OK"
ctxt.parseChunk('', 0, 1)

data = string.join(chars, '')
print len(data)
print data

