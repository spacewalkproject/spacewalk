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
from xml.sax.saxutils import escape
from xml.unicode.utf8_iso import code_to_utf8
import xml.sax.writer

def my_escape(data, entities={}):
    print "My own escape function"
    data = escape(data, entities)
    data = string.join(map(lambda x: code_to_utf8(1, x), data), "")
    return data

setattr(xml.sax.writer, 'escape', my_escape)

class XML_writer(xml.sax.writer.XmlWriter):
    def __init__(self, fp, standalone=None, dtdinfo=None, syntax=None,
                linelength=None, encoding='iso-8859-1'):
        xml.sax.writer.XmlWriter.__init__(self, fp, standalone=standalone, 
                dtdinfo=dtdinfo, syntax=syntax, linelength=linelength,
                encoding=encoding)
        self._stack = []

    def startElement(self, tag, attrs={}):
        xml.sax.writer.XmlWriter.startElement(self, tag, attrs)
        self._stack.append(tag)

    def characters(self, data, start=0, length=None):
        if length is None:
            length = len(data)
        # Close the open tag if necessary
        xml.sax.writer.XmlWriter.characters(self, data, start, length)
            
    def endElement(self, tag):
        xml.sax.writer.XmlWriter.endElement(self, tag)
        self._stack.pop()
    
    def endDocument(self):
        while self._stack:
            tag = self._stack[-1]
            self.endElement(tag)

f = open("/tmp/document.xml", "w+")
w = XML_writer(f, encoding='utf-8')

w.startDocument()
w.startElement("rhn-satellite", {"version" : 1})
w.startElement("rhn-channels")
w.startElement("rhn-channel", {
    'label'     : 'redhat-linux-i386-7.2',
    'arch'      : 'i386',
})
s = "0123456789 ©" * 100
w.characters(s)
w.endElement("rhn-channel")
w.endElement("rhn-channels")
w.endElement("rhn-satellite")
w.endDocument()
f.close()
