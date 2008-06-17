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

class PkgConfig(object):
    
    def __init__(self, config):
        self._config = config

    def getFlagNames(self):
        return self._config.keys("package-flags", ())

    def getFlagTargets(self, flag):
        return self._config.get(("package-flags", flag), {})

    def createFlag(self, flag):
        return self._config.set(("package-flags", flag), {})

    def flagExists(self, flag):
        return self._config.has(("package-flags", flag))

    def getFlag(self, flag):
        return self._config.get(("package-flags", flag))

    def renameFlag(self, oldname, newname):
        config = self._config
        config.set(("package-flags", newname),
                   config.get(("package-flags", oldname)))
        config.remove(("package-flags", oldname))

    def setFlag(self, flag, name, relation=None, version=None):
        self._config.add(("package-flags", flag, name),
                         (relation, version), unique=True)


    def clearFlag(self, flag, name=None, relation=(), version=()):
        if name:
            if relation is () or version is ():
                return self._config.remove(("package-flags", flag, name))
            else:
                return self._config.remove(("package-flags", flag, name),
                                           (relation, version))
        else:
            return self._config.remove(("package-flags", flag))

    def testFlag(self, flag, pkg):
        for item in self._config.get(("package-flags", flag, pkg.name), ()):
            if pkg.matches(*item):
                return True
        return False

    def filterByFlag(self, flag, pkgs):
        fpkgs = []
        names = self._config.get(("package-flags", flag))
        if names:
            for pkg in pkgs:
                lst = names.get(pkg.name)
                if lst:
                    for item in lst:
                        if pkg.matches(*item):
                            fpkgs.append(pkg)
                            break
        return fpkgs

    def testAllFlags(self, pkg):
        result = []
        for flag in self._config.keys("package-flags", ()):
            if self.testFlag(flag, pkg):
                result.append(flag)
        return result

    def getPriority(self, pkg):
        priority = None
        priorities = self._config.get(("package-priorities", pkg.name))
        if priorities:
            priority = None
            for loader in pkg.loaders:
                inchannel = priorities.get(loader.getChannel().getAlias())
                if (inchannel is not None and priority is None or
                    inchannel > priority):
                    priority = inchannel
            if priority is None:
                priority = priorities.get(None)
        return priority

    def setPriority(self, name, channelalias, priority):
        self._config.set(("package-priorities", name, channelalias), priority)

    def removePriority(self, name, channelalias):
        return self._config.remove(("package-priorities", name, channelalias))

