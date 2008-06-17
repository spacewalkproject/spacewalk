#!/usr/bin/python
#
# Checking if the values encoded in hex (base 16) are properly decoded.
#
# $Id$

import os
import sys
import string
filename = "base16values.txt"
filename = os.path.join(os.path.dirname(sys.argv[0]), filename)
f = open(filename)

while 1:
    line = f.readline()
    if not line:
        break
    arr = string.split(line, " ", 1)
    if len(arr) != 2:
        break
    i = int(arr[0])
    val = string.atoi(arr[1], 16)
    assert i == val, i

