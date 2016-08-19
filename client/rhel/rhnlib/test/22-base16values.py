#!/usr/bin/python
#
# Checking if the values encoded in hex (base 16) are properly decoded.
#

import os
import sys
filename = "base16values.txt"
filename = os.path.join(os.path.dirname(sys.argv[0]), filename)
f = open(filename)

while 1:
    line = f.readline()
    if not line:
        break
    arr = line.split(" ", 1)
    if len(arr) != 2:
        break
    i = int(arr[0])
    val = int(arr[1], 16)
    assert i == val, i

