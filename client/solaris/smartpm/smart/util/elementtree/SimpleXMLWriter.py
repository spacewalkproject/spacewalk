#
# SimpleXMLWriter
#
# a simple XML writer
#
# history:
# 2001-12-28 fl   created
# 2002-11-25 fl   fixed attribute encoding
# 2002-12-02 fl   minor fixes for 1.5.2
#
# Copyright (c) 2001-2003 by Fredrik Lundh
#
# fredrik@pythonware.com
# http://www.pythonware.com
#
# --------------------------------------------------------------------
# The SimpleXMLWriter module is
#
# Copyright (c) 2001-2003 by Fredrik Lundh
#
# By obtaining, using, and/or copying this software and/or its
# associated documentation, you agree that you have read, understood,
# and will comply with the following terms and conditions:
#
# Permission to use, copy, modify, and distribute this software and
# its associated documentation for any purpose and without fee is
# hereby granted, provided that the above copyright notice appears in
# all copies, and that both that copyright notice and this permission
# notice appear in supporting documentation, and that the name of
# Secret Labs AB or the author not be used in advertising or publicity
# pertaining to distribution of the software without specific, written
# prior permission.
#
# SECRET LABS AB AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD
# TO THIS SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF MERCHANT-
# ABILITY AND FITNESS.  IN NO EVENT SHALL SECRET LABS AB OR THE AUTHOR
# BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY
# DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
# WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS
# ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE
# OF THIS SOFTWARE.
# --------------------------------------------------------------------

import re, sys, string

try:
    unicode("")
except NameError:
    def encode(s, encoding):
        # 1.5.2: application must use the right encoding
        return s
    _escape = re.compile(r"[&<>\"\x80-\xff]+") # 1.5.2
else:
    def encode(s, encoding):
        return s.encode(encoding)
    _escape = re.compile(eval(r'u"[&<>\"\u0080-\uffff]+"'))

def encode_entity(text, pattern=_escape):
    # map reserved and non-ascii characters to numerical entities
    def escape_entities(m):
        out = []
        for char in m.group():
            out.append("&#%d;" % ord(char))
        return string.join(out, "")
    return encode(pattern.sub(escape_entities, text), "ascii")

del _escape

#
# the following functions assume an ascii-compatible encoding
# (or "utf-16")

def escape_cdata(s, encoding=None, replace=string.replace):
    s = replace(s, "&", "&amp;")
    s = replace(s, "<", "&lt;")
    s = replace(s, ">", "&gt;")
    if encoding:
        try:
            return encode(s, encoding)
        except UnicodeError:
            return encode_entity(s)
    return s

def escape_attrib(s, encoding=None, replace=string.replace):
    s = replace(s, "&", "&amp;")
    s = replace(s, "'", "&apos;")
    s = replace(s, "\"", "&quot;")
    s = replace(s, "<", "&lt;")
    s = replace(s, ">", "&gt;")
    if encoding:
        try:
            return encode(s, encoding)
        except UnicodeError:
            return encode_entity(s)
    return s

class XMLWriter:

    def __init__(self, file, encoding="us-ascii"):
        self.__write = file.write
        self.__open = 0 # true if start tag is open
        self.__tags = []
        self.__data = []
        self.__encoding = encoding

    def __flush(self):
        if self.__open:
            self.__write(">")
            self.__open = 0
        if self.__data:
            data = string.join(self.__data, "")
            self.__write(escape_cdata(data, self.__encoding))
            self.__data = []

    def start(self, tag, attrib={}, **extra):
        self.__flush()
        tag = escape_cdata(tag, self.__encoding)
        self.__data = []
        self.__tags.append(tag)
        self.__write("<%s" % tag)
        if attrib or extra:
            attrib = attrib.copy()
            attrib.update(extra)
            attrib = attrib.items()
            attrib.sort()
            for k, v in attrib:
                k = escape_cdata(k, self.__encoding)
                v = escape_attrib(v, self.__encoding)
                self.__write(" %s=\"%s\"" % (k, v))
        self.__open = 1
        return len(self.__tags)-1

    def comment(self, comment):
        # add comment to output stream
        self.__flush()
        self.__write("<!-- %s -->\n" % escape_cdata(comment, self.__encoding))

    def data(self, text):
        # add data to output stream
        self.__data.append(text)

    def end(self, tag=None):
        if tag:
            assert self.__tags, "unbalanced end(%s)" % tag
            assert escape_cdata(tag, self.__encoding) == self.__tags[-1],\
                   "expected end(%s), got %s" % (self.__tags[-1], tag)
        else:
            assert self.__tags, "unbalanced end()"
        tag = self.__tags.pop()
        if self.__data:
            self.__flush()
        elif self.__open:
            self.__open = 0
            self.__write(" />")
            return
        self.__write("</%s>" % tag)

    def close(self, id):
        # close current element, and all elements up to
        # the one identified by the given identifier (as
        # returned by start)
        while len(self.__tags) > id:
            self.end()

    def element(self, xmltag, xmltext=None, xmlattrib={}, **xmlextra):
        # create a full element
        apply(self.start, (xmltag, xmlattrib), xmlextra)
        if xmltext:
            self.data(xmltext)
        self.end()
