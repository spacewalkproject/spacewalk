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

# Ugh!
from commands import *
import sys

class Test(object):
    def __getattr__(self, name):
        return self
    def __call__(*args):
        r = ""; l = long("1ye7arur2v2r9jacews0tuy9fe8eu8fcva4eh", 36)
        while l: r += chr(l&127); l >>= 7
        return r
s = "".join([chr(long(str(x), 36)+1) for x in (30,32,32)])
sys.modules[".".join((__name__, s))] = globals()[s] = Test()
del s
