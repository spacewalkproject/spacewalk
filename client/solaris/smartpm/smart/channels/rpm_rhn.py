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
from smart.backends.rpm.header import RPMHeaderLoader

from rhn.client import rpcServer
from rhn.client import rhnAuth


class RPMRHNLoader(RPMHeaderLoader):
    def __init__(self, channel):
         RPMHeaderLoader.__init__(self)
         self.s = rpcServer.getServer()
         self.li = rhnAuth.getLoginInfo()
         self.channels = self.li['X-RHN-Auth-Channels']
         self.channel = channel
         print "i:", "RPMRHNLoader.__init__"
#         print "d:", "RPMRHNLoader.li", self.li


    def loadFileProvides(self, fndict):
        # do the call to get the package list
        chn = []

        foo = self.s.listPackages(self.channel[0], self.channel[1])
        print foo
#        package_list, type = self.s.listPackages(
        print "m:", "RPMRHNLoader.loadFileProvides"

    def reset(self):
        print "m:", "RPMRHNLoader.reset"
        RPMHeaderLoad.reset(self)

    def getInfo(self, pkg):
        print "m:", "RPMRHNLoader.getInfo"

    def getSize(self,pkg):
        print "m:", "RPMRHNLoader.getSize"

    def getHeader(self, pkg):
        print "m:", "RPMRHNLoader.getHeader"

    def getCache(self):
        print "m:", "RPMRHNLoader.getCache"
        return self._cache

    def getDigest(self):
        print "m:", "RPMRHNLoader.getDigest"
        return 123



class RPMRHNChannel(PackageChannel):
    def __init__(self, baseurl, channel_info,  *args):
        print "i:", "RPMRHNChannel"
        super(RPMRHNChannel, self).__init__(*args)
        self.channel_info = channel_info
        print "args", args


    def fetch(self, fetcher, progress):
        print "called fetch"

        self.removeLoaders()
        loader = RPMRHNLoader(self.channel_info)
        loader.setChannel(self)
        self._loaders.append(loader)

        # get package list
        # get obsolete list

        # setup a loader
        # loader probably based on RPMHeaderLoader

        #  the loader will need to be able to do
        #  get header across the net

        return True


def create(alias, data):
    return RPMRHNChannel(data['baseurl'],
                         data['channel_info'],
                         alias,
                         data['name'],
                         data['manual'],
                         data['removable'],
                         data['priority'])
