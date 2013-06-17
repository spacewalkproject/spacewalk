#
# ElementTree
#
# a simple tree builder, for HTML input
#
# history:
# 2002-04-06 fl   created
# 2002-04-07 fl   ignore IMG and HR end tags
# 2002-04-07 fl   added support for 1.5.2 and later
# 2003-04-13 fl   added HTMLTreeBuilder alias
#
# Copyright (c) 1999-2003 by Fredrik Lundh.  All rights reserved.
#
# fredrik@pythonware.com
# http://www.pythonware.com
#
# --------------------------------------------------------------------
# The ElementTree toolkit is
#
# Copyright (c) 1999-2003 by Fredrik Lundh
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

import htmlentitydefs
import string

import ElementTree

AUTOCLOSE = "p", "li", "tr", "th", "td", "head", "body"
IGNOREEND = "img", "hr", "meta", "link"

try:
    from HTMLParser import HTMLParser
except ImportError:
    from sgmllib import SGMLParser
    # hack to use sgmllib's SGMLParser to emulate 2.2's HTMLParser
    class HTMLParser(SGMLParser):
        # the following only works as long as this class doesn't
        # provide any do, start, or end handlers
        def unknown_starttag(self, tag, attrs):
            self.handle_starttag(tag, attrs)
        def unknown_endtag(self, tag):
            self.handle_endtag(tag)

##
# ElementTree builder for HTML source code.  This builder converts an
# HTML document or fragment to an ElementTree.
# <p>
# The parser is relatively picky, and requires balanced tags for most
# elements.  However, elements belonging to the following group are
# automatically closed: P, LI, TR, TH, and TD.  In addition, the
# parser automatically inserts end tags immediately after the start
# tag, and ignores any end tags for the following group: IMG, HR,
# META, and LINK.
#
# @see elementtree.ElementTree

class HTMLTreeBuilder(HTMLParser):

    def __init__(self):
        self.__stack = []
        self.__builder = ElementTree.TreeBuilder()
        HTMLParser.__init__(self)

    ##
    # Flush parser buffers, and return the root element.
    #
    # @return An Element instance.

    def close(self):
        HTMLParser.close(self)
        return self.__builder.close()

    #
    # all other methods are internal

    def handle_starttag(self, tag, attrs):
        if tag in AUTOCLOSE:
            if self.__stack and self.__stack[-1] == tag:
                self.handle_endtag(tag)
        self.__stack.append(tag)
        attrib = {}
        if attrs:
            for k, v in attrs:
                attrib[string.lower(k)] = v
        self.__builder.start(tag, attrib)
        if tag in IGNOREEND:
            self.__stack.pop()
            self.__builder.end(tag)

    def handle_endtag(self, tag):
        if tag in IGNOREEND:
            return
        lasttag = self.__stack.pop()
        if tag != lasttag and lasttag in AUTOCLOSE:
            self.handle_endtag(lasttag)
        self.__builder.end(tag)

    def handle_charref(self, char):
        if char[:1] == "x":
            char = int(char[1:], 16)
        else:
            char = int(char)
        if 0 <= char < 256:
            self.__builder.data(chr(char))
        else:
            self.__builder.data(unichr(char)) # hmm...

    def handle_entityref(self, name):
        entity = htmlentitydefs.entitydefs.get(name)
        if entity and len(entity) == 1:
            self.__builder.data(entity)
        else:
            # FIXME: deal with it
            print "UNSUPPORTED ENTITY", name, entity

    def handle_data(self, data):
        self.__builder.data(data)

##
# An alias for the <b>HTMLTreeBuilder</b> class.

TreeBuilder = HTMLTreeBuilder

##
# Parse an HTML document or document fragment.
#
# @param source A filename or file object containing HTML data.
# @return An ElementTree instance

def parse(source):
    return ElementTree.parse(source, TreeBuilder())

if __name__ == "__main__":
    import sys
    ElementTree.dump(parse(open(sys.argv[1])))
