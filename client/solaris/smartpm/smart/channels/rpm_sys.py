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
from smart.backends.rpm.header import RPMDBLoader
from smart.channel import PackageChannel
from smart import *
import os

class RPMSysChannel(PackageChannel):

    def __init__(self, *args):
        super(RPMSysChannel, self).__init__(*args)

    def fetch(self, fetcher, progress):
        path = os.path.join(sysconf.get("rpm-root", "/"),
                            "var/lib/rpm/Packages")
        digest = os.path.getmtime(path)
        if digest == self._digest:
            return True
        self.removeLoaders()
        loader = RPMDBLoader()
        loader.setChannel(self)
        self._loaders.append(loader)
        self._digest = digest
        return True

def create(alias, data):
    if data["removable"]:
        raise Error, _("%s channels cannot be removable") % data["type"]
    return RPMSysChannel(data["type"],
                         alias,
                         data["name"],
                         data["manual"],
                         data["removable"],
                         data["priority"])
