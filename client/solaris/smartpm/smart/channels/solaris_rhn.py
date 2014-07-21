#
# Copyright (c) 2005--2013 Red Hat, Inc.
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

from smart import *
from smart.const import SUCCEEDED, FAILED, NEVER, ALWAYS
from smart.channel import PackageChannel
from smart.backends.solaris.loader import SolarisRHNLoader
from smart.interfaces.up2date import rhnoptions

from rhn.client import rhnPackages


class SolarisRHNChannel(PackageChannel):
    def __init__(self, baseurl, *args):
        super(SolarisRHNChannel, self).__init__(*args)
        self._baseurl = baseurl

    def getFetchSteps(self):
        return 3

    def fetch(self, fetcher, progress):
        # FIXME (20050517): figure out a way to show progress

        # FIXME (20050517): we need a digest and RPC call to compare
        # against latest digest

        # Figure out how to constrain the rhn channel retrieval, if at all.
        channelList = None
        if rhnoptions.hasOption("channel"):
            channelList = rhnoptions.getOption("channel")

        pkgs = rhnPackages.listAllAvailablePackagesComplete(channelList)
        progress.show()

        # If this is an installall operation, we will purposely exclude patch
        # clusters because all available patches will be installed anyway.
        if rhnoptions.hasOption("action") and \
           rhnoptions.getOption("action") == "installall":
            toRemove = []
            for pkg in pkgs:
                name = pkg[0]
                if name.startswith("patch-cluster-solaris-"):
                    toRemove.append(pkg)
            for pkg in toRemove:
                pkgs.remove(pkg)

        #print "  fetch(), pkgs: ", len(pkgs)

        self._pkgs = pkgs

        self.removeLoaders()
        loader = SolarisRHNLoader(self._pkgs)
        loader.setChannel(self)
        self._loaders.append(loader)


        return True


def create(alias, data):
    return SolarisRHNChannel(data['baseurl'],
                             data['type'],
                             alias,
                             data['name'],
                             data['manual'],
                             data['removable'],
                             data['priority'])
