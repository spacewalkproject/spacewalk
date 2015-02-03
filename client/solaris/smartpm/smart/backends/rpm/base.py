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

# Import it before rpm to avoid segfault with zlib symbols
# being linked with rpm. :-(
import zlib

from smart.backends.rpm.pm import RPMPackageManager
from rpmver import checkdep, vercmp, splitarch, splitrelease
from smart.util.strtools import isGlob
from smart.cache import *
import fnmatch
import string
import os, re

from rpm import archscore

__all__ = ["RPMPackage", "RPMProvides", "RPMNameProvides", "RPMPreRequires",
           "RPMRequires", "RPMUpgrades", "RPMConflicts", "RPMObsoletes"]

class RPMPackage(Package):

    packagemanager = RPMPackageManager

    def equals(self, other):
        if self.name != other.name or self.version != other.version:
            return False
        if Package.equals(self, other):
            return True
        fk = dict.fromkeys
        if (len(self.upgrades) != len(other.upgrades) or
            len(self.conflicts) != len(other.conflicts) or
            fk(self.upgrades) != fk(other.upgrades) or
            fk(self.conflicts) != fk(other.conflicts) or
            fk([x for x in self.provides if x.name[0] != "/"]) !=
            fk([x for x in other.provides if x.name[0] != "/"])):
            return False
        sreqs = fk(self.requires)
        oreqs = fk(other.requires)
        if sreqs != oreqs:
            for sreq in sreqs:
                if sreq.name[0] == "/" or sreq in oreqs:
                    continue
                for oreq in oreqs:
                    if (sreq.name == oreq.name and
                        sreq.relation == oreq.relation and
                        sreq.version == oreq.version):
                        break
                else:
                    return False
            for oreq in oreqs:
                if oreq.name[0] == "/" or oreq in sreqs:
                    continue
                for sreq in sreqs:
                    if (sreq.name == oreq.name and
                        sreq.relation == oreq.relation and
                        sreq.version == oreq.version):
                        break
                else:
                    return False
        return True

    def coexists(self, other):
        if not isinstance(other, RPMPackage):
            return True
        if self.version == other.version:
            return False
        selfver, selfarch = splitarch(self.version)
        otherver, otherarch = splitarch(other.version)
        if getArchColor(selfarch) != getArchColor(otherarch):
            return True
        if not pkgconf.testFlag("multi-version", self):
            return False
        return selfver != otherver

    def matches(self, relation, version):
        if not relation:
            return True
        selfver, selfarch = splitarch(self.version)
        ver, arch = splitarch(version)
        return checkdep(selfver, relation, ver)

    def search(self, searcher, _epochre=re.compile("[0-9]+:")):
        myname = self.name
        myversion, myarch = splitarch(self.version)
        myversion = _epochre.sub("", myversion)
        ratio = 0
        for nameversion, cutoff in searcher.nameversion:
            nameversion = _epochre.sub("", nameversion)
            if '@' in nameversion:
                _, ratio1 = globdistance(nameversion, "%s-%s" %
                                         (myname, self.version), cutoff)
                _, ratio2 = globdistance(nameversion, "%s@%s" %
                                         (myname, myarch), cutoff)
                _, ratio3 = globdistance(nameversion, "%s-%s@%s" %
                                         (myname, splitrelease(myversion)[0],
                                          myarch), cutoff)
            else:
                _, ratio1 = globdistance(nameversion, myname, cutoff)
                _, ratio2 = globdistance(nameversion,
                                         "%s-%s" % (myname, myversion), cutoff)
                _, ratio3 = globdistance(nameversion, "%s-%s" %
                                         (myname, splitrelease(myversion)[0]),
                                         cutoff)
            ratio = max(ratio, ratio1, ratio2, ratio3)
        if ratio:
            searcher.addResult(self, ratio)

    def __lt__(self, other):
        rc = cmp(self.name, other.name)
        if type(other) is RPMPackage:
            if rc == 0 and self.version != other.version:
                selfver, selfarch = splitarch(self.version)
                otherver, otherarch = splitarch(other.version)
                if selfver != otherver:
                    rc = vercmp(self.version, other.version)
                if rc == 0:
                    rc = -cmp(archscore(selfarch), archscore(otherarch))
        return rc == -1

class RPMProvides(Provides): pass
class RPMNameProvides(RPMProvides): pass

class RPMDepends(Depends):

    def matches(self, prv):
        if not isinstance(prv, RPMProvides) and type(prv) is not Provides:
            return False
        if not self.version or not prv.version:
            return True
        selfver, selfarch = splitarch(self.version)
        prvver, prvarch = splitarch(prv.version)
        return checkdep(prvver, self.relation, selfver)

class RPMPreRequires(RPMDepends,PreRequires): pass
class RPMRequires(RPMDepends,Requires): pass
class RPMUpgrades(RPMDepends,Upgrades): pass
class RPMConflicts(RPMDepends,Conflicts): pass

class RPMObsoletes(Depends):

    def matches(self, prv):
        if not isinstance(prv, RPMNameProvides) and type(prv) is not Provides:
            return False
        if self.version and not prv.version:
            return False
        if not self.version and prv.version:
            return True
        selfver, selfarch = splitarch(self.version)
        prvver, prvarch = splitarch(prv.version)
        if (prvarch and selfarch and
            getArchColor(selfarch) != getArchColor(prvarch)):
            return False
        return checkdep(prvver, self.relation, selfver)

# TODO: Embed color into nameprovides and obsoletes relations.
_COLORMAP = {"x86_64": 2, "ppc64": 2, "s390x": 2, "sparc64": 2}
def getArchColor(arch, _cm=_COLORMAP):
    return _cm.get(arch, 1)
