# -*- coding: ISO-8859-1 -*-
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
# UTF-8 aware XML writer
#

import re
import sys


class XMLWriter:

    """
    XML writer, UTF-8 aware
    """

    # We escape &<>'" and chars UTF-8 does not properly escape (everything
    # other than tab (\x09), newline and carriage return (\x0a and \x0d) and
    # stuff above ASCII 32)
    _re = re.compile("(&|<|>|'|\"|[^\x09\x0a\x0d\x20-\xFF])")
    _escaped_chars = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&apos;',
    }

    def __init__(self, stream=sys.stdout, skip_xml_decl=0):
        self.tag_stack = []
        self.stream = stream
        if not skip_xml_decl:
            self.stream.write('<?xml version="1.0" encoding="UTF-8"?>')

    def open_tag(self, name, attributes=None, namespace=None):
        "Opens a tag with the specified attributes"
        return self._open_tag(None, name, attributes=attributes,
                              namespace=namespace)

    def empty_tag(self, name, attributes=None, namespace=None):
        "Writes an empty tag with the specified attributes"
        return self._open_tag(1, name, attributes=attributes,
                              namespace=namespace)

    # Now the function that does most of the work for open_tag and empty_tag
    def _open_tag(self, empty, name, attributes=None, namespace=None):
        if namespace:
            name = "%s:%s" % (namespace, name)
        self.stream.write("<")
        self.data(name)
        # Dump the attributes, if any
        if attributes:
            for k, v in attributes.items():
                self.stream.write(" ")
                self.data(k)
                self.stream.write('="')
                self.data(str(v))
                self.stream.write('"')
        if empty:
            self.stream.write("/")
        self.stream.write(">")

        if not empty:
            self.tag_stack.append(name)

    def close_tag(self, name, namespace=None):
        """
        Closes a previously open tag.
        This function raises an exception if the tag was not opened before, or
        if it's been closed already.
        """
        if not self.tag_stack:
            raise Exception("Could not close tag %s: empty tag stack" % name)
        if namespace:
            name = "%s:%s" % (namespace, name)

        if self.tag_stack[-1] != name:
            raise Exception("Could not close tag %s if not opened before" \
                % name)
        self.tag_stack.pop()

        self.stream.write("</")
        self.data(name)
        self.stream.write(">")

    def data(self, data_string):
        """
        Writes the data, performing the necessary UTF-8 conversions
        max_bytes is the satellite schema dependent maximum value (in bytes)
        which can fit in the matching table row. Yeah, this is very gross.
        """
        if data_string is None:
            data_string = ""
        else:
            data_string = str(data_string)

        data_string = self._re.sub(self._sub_function, data_string)
        self.stream.write(data_string)

    # Helper functions

    # Substitution function for re
    def _sub_function(self, match_object):
        c = match_object.group()
        if c in self._escaped_chars:
            return self._escaped_chars[c]
        # return "&#%d;" % ord(c)
        return '?'

    def flush(self):
        self.stream.flush()

if __name__ == '__main__':
    weirdtag = chr(248) + 'gootag'
    writer = XMLWriter()
    writer.open_tag(weirdtag)
    writer.open_tag("message")
    writer.open_tag("text", attributes={'from': 'Trond Eivind Glomsr�d', 'to': "Bernhard Rosenkr)B�nzer"})
    writer.data("String with \"quotes\", 'apostroph', Trond Eivind Glomsr�d\n  and Bernhard Rosenkr)B�nzer")
    r = re.compile("(&|<|>|'|\"|[^\x09\x0a\x0d\x20-\xFF])")
    writer.close_tag("text")
    writer.close_tag("message")
    writer.empty_tag("yahoo", attributes={'abc': 1})
    writer.close_tag(weirdtag)
    print("")
