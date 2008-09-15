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
from smart.const import SUCCEEDED, FAILED, NEVER
from smart.channel import MirrorsChannel
from smart import *
import posixpath
import os

ARCHS = ["i386", "x86_64"]

class Up2DateMirrorsChannel(MirrorsChannel):

    def __init__(self, url, *args):
        super(Up2DateMirrorsChannel, self).__init__(*args)
        self._url = url

    def getFetchSteps(self):
        return 1

    def fetch(self, fetcher, progress):
        mirrors = self._mirrors
        mirrors.clear()
        fetcher.reset()
        item = fetcher.enqueue(self._url, uncomp=True)
        fetcher.run(progress=progress)
        if item.getStatus() == SUCCEEDED:
            localpath = item.getTargetPath()
            file = open(localpath)
            origin = file.readline().strip()
            for mirror in file:
                mirror = mirror.strip()
                if mirror:
                    for arch in ARCHS:
                        _origin = origin.replace("$ARCH", arch)
                        _mirror = mirror.replace("$ARCH", arch)
                        if _origin in mirrors:
                            if _mirror not in mirrors[_origin]:
                                mirrors[_origin].append(_mirror)
                        else:
                            mirrors[_origin] = [_mirror]
        elif fetcher.getCaching() is NEVER:
            lines = [_("Failed acquiring information for '%s':") % self,
                     u"%s: %s" % (item.getURL(), item.getFailedReason())]
            raise Error, "\n".join(lines)
        return True

def create(alias, data):
    return Up2DateMirrorsChannel(data["url"],
                                 data["type"],
                                 alias,
                                 data["name"],
                                 data["manual"],
                                 data["removable"])

# vim:ts=4:sw=4:et
