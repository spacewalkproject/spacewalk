#
# Copyright (c) 2005 Red Hat, Inc.
#
# Written by Joel Martin <jmartin@redhat.com>
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
from smart.backends.solaris.loader import SolarisDirLoader
from smart.channel import PackageChannel
from smart import *
import os

class SolarisDirChannel(PackageChannel):

    def __init__(self, path, *args):
        super(SolarisDirChannel, self).__init__(*args)
        self._path = path

    def fetch(self, fetcher, progress):
        if not os.path.isdir(self._path):
            raise Error, _("Channel '%s' has invalid directory: %s") % \
                         (self, self._path)
        digest = os.path.getmtime(self._path)
        if digest == self._digest:
            return True
        self.removeLoaders()
        loader = SolarisDirLoader(self._path)
        loader.setChannel(self)
        self._loaders.append(loader)
        self._digest = digest
        return True

def create(alias, data):
    if data["removable"]:
        raise Error, _("%s channels cannot be removable") % data["type"]
    return SolarisDirChannel(data["path"],
                         data["type"],
                         alias,
                         data["name"],
                         data["manual"],
                         data["removable"],
                         data["priority"])
