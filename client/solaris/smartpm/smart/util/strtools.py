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
from smart import _

from smart.util.distance import *

import posixpath
import string
import md5
import sys

class ShortURL(object):
    def __init__(self, maxlen):
        self._cache = {}
        self._maxlen = maxlen

    def reset(self):
        self._cache.clear()

    def get(self, url):
        shorturl = self._cache.get(url)
        if not shorturl:
            if len(url) > self._maxlen and url.count("/") > 3:
                dir, base = posixpath.split(url)
                while len(dir)+len(base)+5 > self._maxlen:
                    if dir.count("/") < 3:
                        break
                    dir, _ = posixpath.split(dir)
                shorturl = posixpath.join(dir, ".../", base)
            else:
                shorturl = url
            self._cache[url] = shorturl
        return shorturl

def sizeToStr(bytes):
    if bytes is None:
        return _("Unknown")
    if bytes < 1024:
        return "%dB" % bytes
    elif bytes < 1024000:
        return "%.1fkB" % (bytes/1024.)
    else:
        return "%.1fMB" % (bytes/1024000.)

def speedToStr(speed):
    if speed < 1:
        return _("Stalled")
    elif speed < 1024:
        return "%dB/s" % speed
    elif speed < 1024000:
        return "%.1fkB/s" % (speed/1024.)
    else:
        return "%.1fMB/s" % (speed/1024000.)

_nulltrans = string.maketrans('', '')
def isRegEx(s):
    return s.translate(_nulltrans, '^{[*') != s

def isGlob(s):
    return s.translate(_nulltrans, '*?') != s

def strToBool(s, default=False):
    if type(s) in (bool, int):
        return bool(s)
    if not s:
        return default
    s = s.strip().lower()
    if s in ("y", "yes", "true", "1", _("y"), _("yes"), _("true")):
        return True
    if s in ("n", "no", "false", "0", _("n"), _("no"), _("false")):
        return False
    return default

def printColumns(lst, indent=0, spacing=2, width=80, out=None):
    maxstrlen = 0
    for item in lst:
        strlen = len(str(item))
        if strlen > maxstrlen:
            maxstrlen = strlen

    perline = (width-indent)/(maxstrlen+spacing)
    if perline == 0:
        perline = 1

    columnlen = (width-indent)/perline
    numitems = len(lst)
    numlines = (numitems+perline-1)/perline
    blank = " "*columnlen
    if out is None:
        out = sys.stdout
    for line in range(numlines):
        out.write(" "*indent)
        for entry in range(perline):
            k = line+(entry*numlines)
            if k >= numitems:
                break
            s = str(lst[k])
            out.write(s)
            out.write(" "*(columnlen-len(s)))
        print
