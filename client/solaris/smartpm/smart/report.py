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
from smart.const import INSTALL, REMOVE

class Report(object):

    def __init__(self, changeset):
        self._changeset = changeset

        self.exclude = {}

        self.install = {}
        self.remove = {}

        self.removed = {}
        self.upgraded = {}
        self.downgraded = {}

        self.installing = {}
        self.upgrading = {}
        self.downgrading = {}

        self.notupgraded = {}

        self.conflicts = {}
        self.requires = {}
        self.requiredby = {}

    def reset(self):
        self.exclude.clear()
        self.install.clear()
        self.remove.clear()
        self.removed.clear()
        self.upgraded.clear()
        self.downgraded.clear()
        self.installing.clear()
        self.upgrading.clear()
        self.downgrading.clear()
        self.notupgraded.clear()
        self.conflicts.clear()
        self.requires.clear()
        self.requiredby.clear()

    def compute(self):
        changeset = self._changeset
        for pkg in changeset.getCache().getPackages():
            if pkg in self.exclude:
                continue
            if changeset.get(pkg) is REMOVE:
                self.remove[pkg] = True
                lst = None
                for prv in pkg.provides:
                    for upg in prv.upgradedby:
                        for upgpkg in upg.packages:
                            if changeset.get(upgpkg) is INSTALL:
                                if lst:
                                    if upgpkg not in lst:
                                        lst.append(upgpkg)
                                else:
                                    lst = self.upgraded[pkg] = [upgpkg]
                lst = None
                for upg in pkg.upgrades:
                    for prv in upg.providedby:
                        for prvpkg in prv.packages:
                            if changeset.get(prvpkg) is INSTALL:
                                if lst:
                                    if prvpkg not in lst:
                                        lst.append(prvpkg)
                                else:
                                    lst = self.downgraded[pkg] = [prvpkg]
                if (pkg not in self.upgraded and
                    pkg not in self.downgraded):
                    self.removed[pkg] = True
            elif changeset.get(pkg) is INSTALL:
                self.install[pkg] = True
                lst = None
                for upg in pkg.upgrades:
                    for prv in upg.providedby:
                        for prvpkg in prv.packages:
                            if prvpkg.installed:
                                if lst:
                                    if prvpkg not in lst:
                                        lst.append(prvpkg)
                                else:
                                    lst = self.upgrading[pkg] = [prvpkg]
                lst = None
                for prv in pkg.provides:
                    for upg in prv.upgradedby:
                        for upgpkg in upg.packages:
                            if upgpkg.installed:
                                if lst:
                                    if upgpkg not in lst:
                                        lst.append(upgpkg)
                                else:
                                    lst = self.downgrading[pkg] = [upgpkg]
                if (pkg not in self.upgrading and
                    pkg not in self.downgrading):
                    self.installing[pkg] = True
            elif pkg.installed:
                notupgraded = {}
                try:
                    for prv in pkg.provides:
                        for upg in prv.upgradedby:
                            for upgpkg in upg.packages:
                                if changeset.get(upgpkg) is INSTALL:
                                    raise StopIteration
                                else:
                                    notupgraded[upgpkg] = True
                except StopIteration:
                    pass
                else:
                    if notupgraded:
                        self.notupgraded[pkg] = notupgraded.keys()

            pkgop = changeset.get(pkg)
            if pkgop:
                map = {}
                for cnf in pkg.conflicts:
                    for prv in cnf.providedby:
                        for prvpkg in prv.packages:
                            if prvpkg is pkg:
                                continue
                            if changeset.get(prvpkg):
                                map[prvpkg] = True
                for prv in pkg.provides:
                    for cnf in prv.conflictedby:
                        for cnfpkg in cnf.packages:
                            if cnfpkg is pkg:
                                continue
                            if changeset.get(cnfpkg):
                                map[cnfpkg] = True
                if map:
                    self.conflicts[pkg] = map.keys()
                    map.clear()
                for req in pkg.requires:
                    for prv in req.providedby:
                        for prvpkg in prv.packages:
                            if changeset.get(prvpkg) is pkgop:
                                map[prvpkg] = True
                if map:
                    self.requires[pkg] = map.keys()
                    map.clear()
                for prv in pkg.provides:
                    for req in prv.requiredby:
                        for reqpkg in req.packages:
                            if changeset.get(reqpkg) is pkgop:
                                map[reqpkg] = True
                if map:
                    self.requiredby[pkg] = map.keys()

    def getDownloadSize(self):
        total = 0
        for pkg in self.install:
            for loader in pkg.loaders:
                if not loader.getInstalled():
                    break
            else:
                continue
            info = loader.getInfo(pkg)
            for url in info.getURLs():
                size = info.getSize(url)
                if size:
                    total += size
        return total

    def getInstallSize(self):
        total = 0
        for pkg in self.install:
            loader = iter(pkg.loaders).next()
            info = loader.getInfo(pkg)
            size = info.getInstalledSize()
            if size:
                total += size
        return total

    def getRemoveSize(self):
        total = 0
        for pkg in self.remove:
            loader = iter(pkg.loaders).next()
            info = loader.getInfo(pkg)
            size = info.getInstalledSize()
            if size:
                total += size
        return total

# vim:ts=4:sw=4:et
