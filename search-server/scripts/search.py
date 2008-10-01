#!/usr/bin/python

import xmlrpclib
from optparse import OptionParser

indexName = "package"
usage = "usage: %prog [options] search term"
desc = "%prog searches for package (default) or systems with the given \
search criteria"

parser = OptionParser(usage=usage, description=desc)
parser.add_option("--sessionid", dest="sessionid", type="int", help="PXT sessionid")
parser.add_option("--package", action="store_true", dest="package", 
                  help="search packages", default=True)
parser.add_option("--system", action="store_true", dest="system", 
                  help="search systems", default=False)
parser.add_option("--indexName", dest="indexName", type="string",
        help="lucene index name to search ex: package server hwdevice snapshotTag errata")
parser.add_option("--serverAddr", dest="serverAddr", type="string", default="localhost",
                  help="Server to authenticate to, NOT WHERE SEARCH SERVER RUNS")
parser.add_option("--username", dest="username", type="string", help="username")
parser.add_option("--password", dest="password", type="string", help="password")
parser.add_option("--debug", action="store_true", dest="debug", default=False,
                  help="enable debug output")

(options, terms) = parser.parse_args()
if len(terms) < 1:
    parser.error("please supply a search term\n" + str(parser.print_help()))

if not options.sessionid and (not options.username or not options.password):
    print parser.print_help()
    parser.exit()


if options.package:
    indexName = "package"

if options.system:
    indexName = "server"

if options.indexName:
    indexName = options.indexName


sessionid = None
if options.sessionid:
    sessionid = options.sessionid
    print "Using passed in authentication info, sessionid = %s" % (sessionid)
else:
    xmlrpcURL = "http://%s/rhn/rpc/api" % (options.serverAddr)
    print "Getting authentication information from: %s" % (xmlrpcURL)
    rhnclient = xmlrpclib.Server(xmlrpcURL)
    authSessionId = rhnclient.auth.login(options.username, options.password)
    sessionid = int(authSessionId.split('x')[0])

url = "http://localhost:2828/RPC2"
print "Connecting to SearchServer: (%s)" % url
client = xmlrpclib.Server(url, verbose=options.debug)

term = " ".join(terms)
print "searching for (%s) matching criteria: (%s)" % (indexName, str(term))
items = client.index.search(sessionid, indexName, term)

print "We got (%d) items back." % len(items)
print items

#Remember to logout if the user didn't supply the sessionid
if not options.sessionid:
    rhnclient.auth.logout(authSessionId)
