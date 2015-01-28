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
from smart.backends.solaris.pm import SolarisPackageManager
from solarisver import checkdep, vercmp
from smart.util.strtools import isGlob
from smart.cache import *
import fnmatch
import re

__all__ = ["SolarisPackage", "SolarisProvides", "SolarisDepends",
          "SolarisUpgrades", "SolarisConflicts"]

class SolarisPackage(Package):

    packagemanager = SolarisPackageManager

    def isPatch(self):
        return self.name.startswith("patch-solaris")

    def isPatchCluster(self):
        return self.name.startswith("patch-cluster-solaris")

    def matches(self, relation, version):
        if not relation:
            return True
        return checkdep(self.version, relation, version)

    def search(self, searcher):
        myname = self.name
        myversion = self.version
        ratio = 0
        for nameversion, cutoff in searcher.nameversion:
            _, ratio1 = globdistance(nameversion, myname, cutoff)
            _, ratio2 = globdistance(nameversion,
                                     "%s-%s" % (myname, myversion), cutoff)
            _, ratio3 = globdistance(nameversion, "%s-%s" %
                                     (myname, myversion.split("-", 1)[-1]),
                                     cutoff)
            ratio = max(ratio, ratio1, ratio2, ratio3)
        if ratio:
            searcher.addResult(self, ratio)

    def coexists(self, other):
        if not isinstance(other, SolarisPackage):
            return True
        return False

    def __lt__(self, other):
        rc = cmp(self.name, other.name)
        if type(other) is SolarisPackage:
            if rc == 0 and self.version != other.version:
                rc = vercmp(self.version, other.version)
        return rc == -1

class SolarisProvides(Provides): pass

class SolarisDepends(Depends):

    def matches(self, prv):
        if not isinstance(prv, SolarisProvides) and type(prv) is not Provides:
            return False
        if not self.version or not prv.version:
            return True
        return checkdep(prv.version, self.relation, self.version)

class SolarisUpgrades(SolarisDepends,Upgrades): pass

class SolarisConflicts(SolarisDepends,Conflicts): pass
