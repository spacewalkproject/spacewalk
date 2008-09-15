#
# Copyright (c) 2005 Conectiva, Inc.
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

def distance(a, b, cutoff=None):
    """
    Compute Levenhstein distance - http://www.merriampark.com/ld.htm
    """
    if a == b:
        return 0, 1.0
    al = len(a)
    bl = len(b)
    if al > bl:
        a, al, b, bl = b, bl, a, al
    if cutoff and type(cutoff) is float:
        cutoff = int(bl-cutoff*bl)
    lst = range(1,bl+1)
    for ai in range(al):
        last, lst[0] = lst[0], min(lst[0]+1, ai+(b[0] != a[ai]))
        for bi in range(1, bl):
            last, lst[bi] = lst[bi], min(lst[bi-1]+1, lst[bi]+1,
                                         last+(b[bi] != b[ai]))
        if cutoff is not None and min(lst) > cutoff:
            return bl, 0.0
    res = lst[-1]
    if cutoff is not None and res > cutoff:
        return bl, 0.0
    return res, float(bl-res)/bl

def globdistance(a, b, cutoff=None):
    """
    Compute Levenhstein distance - http://www.merriampark.com/ld.htm

    Algorithm changed by Gustavo Niemeyer to implement wildcards support.
    """
    if a == b:
        return 0, 1.0
    al = len(a)
    bl = len(b)
    maxl = al > bl and al or bl
    if cutoff and type(cutoff) is float:
        cutoff = int(maxl-cutoff*maxl)
    lst = range(1,bl+1)
    for ai in range(al):
        if a[ai] == "*":
            last, lst[0] = lst[0], min(lst[0], ai)
            for bi in range(1,bl):
                last, lst[bi] = lst[bi], min(lst[bi-1], lst[bi], last)
        elif a[ai] == "?":
            last, lst[0] = lst[0], min(lst[0]+1, ai)
            for bi in range(1,bl):
                last, lst[bi] = lst[bi], min(lst[bi-1]+1, lst[bi]+1, last)
        else:
            last, lst[0] = lst[0], min(lst[0]+1, ai+(b[0] != a[ai]))
            for bi in range(1, bl):
                last, lst[bi] = lst[bi], min(lst[bi-1]+1, lst[bi]+1,
                                             last+(b[bi] != a[ai]))
        if cutoff is not None and min(lst) > cutoff:
            return bl, 0.0
    res = lst[-1]
    if cutoff is not None and res > cutoff:
        return bl, 0.0
    return res, float(maxl-res)/maxl

from cdistance import *
