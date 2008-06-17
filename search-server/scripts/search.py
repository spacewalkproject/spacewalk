#!/usr/bin/python

import xmlrpclib
from optparse import OptionParser

type = "package"
usage = "usage: %prog [options] search term"
desc = "%prog searches for package (default) or systems with the given \
search criteria"
parser = OptionParser(usage=usage, description=desc)
parser.add_option("--sessionid", dest="sessionid", type="int", help="PXT sessionid")
parser.add_option("--package", action="store_true", dest="package", 
                  help="search packages", default=True)
parser.add_option("--system", action="store_true", dest="system", 
                  help="search systems", default=False)
parser.add_option("--debug", action="store_true", dest="debug", default=False,
                  help="enable debug output")

(options, terms) = parser.parse_args()
if len(terms) < 1:
    parser.error("please supply a search term\n" + str(parser.print_help()))

if not options.sessionid:
    print parser.print_help()
    parser.exit()

if options.system:
    options.package = False
    type = "system"

#rhnclient = xmlrpclib.Server("http://localhost/rhn/rpc/api")
#sessionid = rhnclient.auth.login("admin", "redhat")
url = "http://localhost:2828/RPC2"
print "Connecting to (%s)" % url
client = xmlrpclib.Server(url, verbose=options.debug)
term = " ".join(terms)
print "searching for (%s) matching criteria: (%s)" % (type, str(term))
#pkgs = client.index.search(int(sessionid.split('x')[0]), type, term)
pkgs = client.index.search(options.sessionid, type, term)
print "We got (%d) items back." % len(pkgs)
print pkgs
#rhnclient.auth.logout(sessionid)
