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
import cPickle
import md5

def getObjectDigest(obj):
    return ObjectDigest(obj).getDigest()

def getObjectHexDigest(obj):
    return ObjectDigest(obj).getHexDigest()

class ObjectDigest(object):

    def __init__(self, obj=None):
        self._digest = md5.md5()
        if obj:
            self.addObject(obj)

    def getDigest(self):
        return self._digest.digest()

    def getHexDigest(self):
        return self._digest.hexdigest()
    
    def addObject(self, obj):
        cPickle.dump(obj, DigestFile(self._digest), 2)

class DigestFile(object):

    def __init__(self, digest):
        self._digest = digest

    def write(self, data):
        self._digest.update(data)


