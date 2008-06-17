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
from smart.const import BLOCKSIZE
from smart import *

class Uncompressor(object):

    _handlers = [] 

    def addHandler(self, handler):
        self._handlers.append(handler())
    addHandler = classmethod(addHandler)

    def getHandler(self, localpath):
        for handler in self._handlers:
            if handler.query(localpath):
                return handler
    getHandler = classmethod(getHandler)

    def uncompress(self, localpath):
        for handler in self._handlers:
            if handler.query(localpath):
                return handler.uncompress(localpath)
        else:
            raise Error, _("Unknown compressed file: %s") % localpath

class UncompressorHandler(object):

    def query(self, localpath):
        return None

    def getTargetPath(self, localpath):
        return None

    def uncompress(self, localpath):
        raise Error, _("Unsupported file type")

class BZ2Handler(UncompressorHandler):

    def query(self, localpath):
        if localpath.endswith(".bz2"):
            return True

    def getTargetPath(self, localpath):
        return localpath[:-4]

    def uncompress(self, localpath):
        import bz2
        try:
            input = bz2.BZ2File(localpath)
            output = open(self.getTargetPath(localpath), "w")
            data = input.read(BLOCKSIZE)
            while data:
                output.write(data)
                data = input.read(BLOCKSIZE)
        except (IOError, OSError), e:
            raise Error, "%s: %s" % (localpath, e)

Uncompressor.addHandler(BZ2Handler)

class GZipHandler(UncompressorHandler):

    def query(self, localpath):
        if localpath.endswith(".gz"):
            return True

    def getTargetPath(self, localpath):
        return localpath[:-3]

    def uncompress(self, localpath):
        import gzip
        try:
            input = gzip.GzipFile(localpath)
            output = open(self.getTargetPath(localpath), "w")
            data = input.read(BLOCKSIZE)
            while data:
                output.write(data)
                data = input.read(BLOCKSIZE)
        except (IOError, OSError), e:
            raise Error, "%s: %s" % (localpath, e)


Uncompressor.addHandler(GZipHandler)
