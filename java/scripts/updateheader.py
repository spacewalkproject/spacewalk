#!/usr/bin/python

from optparse import OptionParser

usage = "usage: %prog header file"
parser = OptionParser(usage=usage, description="")
(options, terms) = parser.parse_args()

if len(terms) < 2:
    parser.error("please supply a file to modify")

hdrfile = terms[0]
dafile = terms[1]

f = open(hdrfile, "r")
hdr = f.readlines()
hdrsz = len(hdr)
f.close()

f = open(dafile, "r")
toupdate = f.readlines()
sz = len(toupdate)
f.close()

f = open(dafile, "w")
f.writelines(hdr)
f.writelines(toupdate[hdrsz:sz])
f.close()
