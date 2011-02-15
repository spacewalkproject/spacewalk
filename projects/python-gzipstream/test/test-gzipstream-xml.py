""" an inelegant test of how we work with gzipstream in a satellite-sync
    like manner.
"""

import os
import sys

print "NOTE: intended to be run from the gzipstream directory in CVS"
print

import gzipstream
from satellite_tools import connection

INPUT = os.path.join(os.path.dirname(sys.argv[0]), "f.xml.gz")

# append rhn/backend/satellite_tools
sys.path.append('../../backend')

from rhn import rpclib
from xml.sax import saxutils, make_parser, _exceptions
from xml.sax.handler import feature_namespaces

class Foo(saxutils.DefaultHandler):
    def startElement(self, tag, attrs):
        print "startElement", tag

    def characters(self, data):
        pass

    def endElement(self, tag):
        print "endElement", tag


f = open(INPUT)

gz = gzipstream.GzipStream(f, "r")

cs = connection.CompressedStream(gz)

fi = rpclib.transports.File(cs)

h = Foo()

parser = make_parser(feature_namespaces)
parser.setContentHandler(h)
parser.setErrorHandler(h)
parser.parse(fi)
