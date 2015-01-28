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
from smart.backends.solaris.loader import SolarisDBLoader
from smart.channel import PackageChannel
from smart import *
import os

class SolarisSysChannel(PackageChannel):

    def __init__(self, *args):
        super(SolarisSysChannel, self).__init__(*args)
        self._digest = None
        self._pdigest = None

    def fetch(self, fetcher, progress):
        dir = os.path.join(sysconf.get("solaris-root", "/"),
                           sysconf.get("solaris-packages-dir",
                                       "var/sadm/pkg"))
        pdir = os.path.join(sysconf.get("solaris-root", "/"),
                           sysconf.get("solaris-patches-dir",
                                       "var/sadm/patch/"))
        #print "In solaris_sys.py:SolarisSysChannel.fetch(), dir: ", dir
        digest = os.path.getmtime(dir)
        try:
            pdigest = os.path.getmtime(pdir)
        except:
            pdigest = self._pdigest
        if digest == self._digest and pdigest == self._pdigest:
            return True
        self.removeLoaders()
        loader = SolarisDBLoader()
        loader.setChannel(self)
        self._loaders.append(loader)
        self._digest = digest
        self._pdigest = pdigest
        return True

def create(alias, data):
    if data["removable"]:
        raise Error, _("%s channels cannot be removable") % data["type"]
    return SolarisSysChannel(data["type"],
                           alias,
                           data["name"],
                           data["manual"],
                           data["removable"],
                           data["priority"])
