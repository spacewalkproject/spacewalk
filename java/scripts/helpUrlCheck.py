#!/usr/bin/python
# Scan the given source files for RHN Help URLs and check to see if they're
# valid on the given satellite.

import sys
import re
import urllib2

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print "USAGE: %s <satellite host> <list of filenames>" % sys.argv[0]
        print "   i.e. %s rlx-3-12.rhndev.redhat.com **/*.jsp" % sys.argv[0]
        sys.exit(0)

    satUrl = "http://" + sys.argv[1]
    print "Checking for valid help URLs on: %s" % satUrl

    files = sys.argv[2:]

    regex = re.compile(r"(\")(\/rhn\/help.*\.jsp)(\")")

    # Map broken URLs to the access error and a list of files it's found in:
    brokenUrls = {}

    # Store the list of URLs we've already checked for speed:
    processedUrls = []

    for filename in files:
        f = open(filename, 'r')
        for line in f:
            match = regex.search(line)
            if match:
                helpPath = match.group(2) # matched text excluding the quotes
                helpUrl = satUrl + helpPath

                # If we've already found this URL to be broken, add it's
                # source filename:
                if brokenUrls.has_key(helpUrl):
                    brokenUrls[helpUrl]['files'].append(filename)
                    continue

                # Skip URLs we've already checked for speed
                if helpUrl in processedUrls:
                    continue

                print "Checking %s" % helpUrl,
                processedUrls.append(helpUrl)
                try:
                    urllib2.urlopen(helpUrl)
                    print " ok"
                except Exception, e:
                    print " BROKEN!"
                    brokenUrls[helpUrl] = {'files' : [filename], 'error' : e}

    if len(brokenUrls) == 0:
        print "All URLs valid!"
    else:
        print "WARNING: Broken help URLs were found!!!"
        for key in brokenUrls.keys():
            print "   %s" % key
            print "      Error: %s" % brokenUrls[key]['error']
            print "      Files: (note: may include multiple occurrences)" 
            filesProcessed = []
            for filename in brokenUrls[key]['files']:
                if filename not in filesProcessed:
                    print "         %s" % filename
                    filesProcessed.append(filename)

