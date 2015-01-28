#
# Copyright (c) 2004 Conectiva, Inc.
#
# Written by Gustavo Niemeyer <niemeyer@conectiva.com>
#
# This file is part of Smart Package Manager.
#
# Smart Package Manager is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 2 of the License, or (at
# your option) any later version.
#
# Smart Package Manager is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Smart Package Manager; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
import re

VERRE = re.compile("(?:([0-9]+):)?(.+?)(?:-([^-]+))?$")

CM = {"=": "=", "<<": "<", ">>": ">", "<=": "<=",
      ">=": ">=", ">": ">=", "<": "<="}

SPLITRE = re.compile(" *([<>=]+) *")

def parserelation(str, cm=CM):
    open = str.find("(")
    if open != -1:
        close = str.find(")")
        toks = SPLITRE.split(str[open+1:close].strip())
        l = len(toks)
        if l == 3:
            return str[:open].strip(), cm.get(toks[1]), toks[2]
        else:
            return str[:open].strip(), None, None
    else:
        return str.strip(), None, None

def parserelations(str):
    ret = []
    for descr in str.split(","):
        group = descr.split("|")
        if len(group) == 1:
            ret.append(parserelation(group[0]))
        else:
            ret.append([parserelation(x) for x in group])
    return ret

def checkdep(s1, rel, s2):
    cmp = vercmp(s1, s2)
    if cmp == 0:
        return '=' in rel
    elif cmp < 0:
        return '<' in rel
    else:
        return '>' in rel

def vercmp(s1, s2):
    return vercmpparts(*(VERRE.match(s1).groups()+VERRE.match(s2).groups()))

# compare alpha and numeric segments of two versions
# return 1: first is newer than second
#        0: first and second are the same version
#       -1: second is newer than first
def vercmpparts(e1, v1, r1, e2, v2, r2):
    rc = vercmppart(e1, e2)
    if not rc:
        rc = vercmppart(v1, v2)
        if not rc:
            rc = vercmppart(r1, r2)
    return rc

# compare alpha and numeric segments of two versions
# return 1: a is newer than b
#        0: a and b are the same version
#       -1: b is newer than a
def vercmppart(a, b):
    if a == b:
        return 0
    if not a:
        if b and b[0] == "~":
            return 1
        return -1
    if not b:
        if a and a[0] == "~":
            return -1
        return 1
    ai = 0
    bi = 0
    la = len(a)
    lb = len(b)
    while ai < la and bi < lb:
        first_diff = 0
        while (ai != la and bi != lb and
               (not a[ai].isdigit() or not b[bi].isdigit())):
            vc = ORDER[a[ai]]
            rc = ORDER[b[bi]]
            if vc > rc:
                return 1
            if vc < rc:
                return -1;
            ai += 1
            bi += 1
        while ai != la and a[ai] == "0":
            ai += 1
        while bi != lb and b[bi] == "0":
            bi += 1
        while (ai != la and bi != lb and
               a[ai].isdigit() and b[bi].isdigit()):
            if not first_diff:
                first_diff = ord(a[ai]) - ord(b[bi])
            ai += 1
            bi += 1
        if ai != la and a[ai].isdigit():
            return 1
        if bi != lb and b[bi].isdigit():
            return -1
        if first_diff > 0:
            return 1
        if first_diff < 0:
            return -1
    if ai == la and bi == lb:
        return 0
    if ai == la:
        if bi != lb and b[bi] == '~':
            return 1
        return -1
    if bi == lb:
        if ai != la and a[ai] == '~':
            return -1
        return 1
    return 1

ORDER = {}
for i in range(256):
    c = chr(i)
    if c == "~":
        ORDER[c] = -1
    elif c.isdigit():
        ORDER[c] = 0
    elif c.isalpha():
        ORDER[c] = i
    else:
        ORDER[c] = i+256

from cdebver import *
