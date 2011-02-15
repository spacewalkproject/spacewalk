#!/usr/bin/python -u
""" test on huge file which tends to expose "interesting" behavior """
import os
import sys
import time

print "NOTE: intended to be run from the gzipstream directory in CVS"
print

from gzipstream import GzipStream

INPUT = os.path.join(os.path.dirname(sys.argv[0]), 'huge-all-zeros.txt.gz')
BUFSIZE = 1024*16

t0 = time.time()

print "WARNING: This test takes a while to complete as it works on a very"
print "         file. It will:"
print "         - G*un*zipStream %s and count chars" % repr(INPUT)
print "         - compare with a zcat|wc"
print

try:
    # python 2.* only
    class File(file):
        seek = None
    fin = File(INPUT, 'rb')
    print "Opened file as file object with no seek for a 'socket-like' test."
except:
    print "Opened file as a normal file object."
    fin = open(INPUT, 'rb')

gzin = GzipStream(fin, 'r')

sys.stderr.write('reading...\n')
x = gzin.read(BUFSIZE)
count = len(x)

while x:
    x = gzin.read(BUFSIZE)
    count = count + len(x)

print "GzipStream's char count:\n%s" % count

print "'zcat <file> | wc -m' char count:"
os.system('zcat %s | wc -m' % INPUT)
print "They should match."

print 'Elapsed:', (time.time() - t0)/60.0, 'mins'
