#
# ElementTree
#
# tree builder based on the _elementtidy tidylib wrapper
#
# history:
# 2003-07-06 fl   created
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

import ElementTree
import _elementtidy
import string

##
# ElementTree builder for HTML source code.  This builder converts an
# HTML document or fragment to an XHTML ElementTree, by running it
# through the _elementtidy processor.
#
# @see elementtree.ElementTree

class TidyHTMLTreeBuilder:

    def __init__(self):
        self.__data = []

    ##
    # Add data to parser buffers.

    def feed(self, text):
        self.__data.append(text)

    ##
    # Flush parser buffers, and return the root element.
    #
    # @return An Element instance.

    def close(self):
        data = _elementtidy.fixup(string.join(self.__data, ""))
        return ElementTree.XML(data)

##
# An alias for the <b>TidyHTMLTreeBuilder</b> class.

TreeBuilder = TidyHTMLTreeBuilder

##
# Parse an HTML document into an XHTML-style element tree.
#
# @param source A filename or file object containing HTML data.
# @return An ElementTree instance

def parse(source):
    return ElementTree.parse(source, TreeBuilder())

if __name__ == "__main__":
    import sys
    ElementTree.dump(parse(open(sys.argv[1])))
