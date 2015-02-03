#
# Copyright (c) 2004-2005 Conectiva, Inc.
#
# Written by Gustavo Niemeyer <niemeyer@conectiva.com>
#            Michael Scherer <misc@mandrake.org>
#
# Adapted from slack/loader.py and metadata.py by Michael Scherer.
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
from smart.backends.rpm.rpmver import splitarch
from smart.cache import PackageInfo, Loader
from smart.backends.rpm.base import *
from smart import *
import posixpath
import os
import re

DEPENDSRE = re.compile("^([^[]*)(\[\*\])?(\[.*\])?")
OPERATIONRE = re.compile("\[([<>=]*) *(.+)?\]")
EPOCHRE = re.compile("[0-9]+:")


class URPMISynthesisPackageInfo(PackageInfo):
    def __init__(self, package, loader, info):
        PackageInfo.__init__(self, package)
        self._loader = loader
        self._info = info

    def getURLs(self):
        name = self._package.name
        version, arch = splitarch(self._package.version)
        version = EPOCHRE.sub("", version)
        return [posixpath.join(self._loader._baseurl,
                               "%s-%s.%s.rpm" % (name, version, arch))]

    def getInstalledSize(self):
        return int(self._info.get("size"))

    def getSummary(self):
        return self._info.get("summary", "")

    def getGroup(self):
        return self._info.get("group", "")


class URPMISynthesisLoader(Loader):

    __stateversion__ = Loader.__stateversion__+2

    def __init__(self, filename, baseurl, filelistname):
        Loader.__init__(self)
        self._filename = filename
        self._baseurl = baseurl
        self._filelistname = filelistname

    def getInfo(self, pkg):
        return URPMISynthesisPackageInfo(pkg, self, pkg.loaders[self])

    def getLoadSteps(self):
        indexfile = open(self._filename)
        total = 0
        for line in indexfile:
            if line.startswith("@info@"):
                total += 1
        indexfile.close()
        return total

    def splitDepends(self, depsarray, _dependsre=DEPENDSRE,
                     _operationre=OPERATIONRE):
        result = []
        for deps in depsarray:
            depends = _dependsre.match(deps)
            if depends:
                name, flag, condition = depends.groups()
                operation = None
                version = None
                if condition:
                    o = _operationre.match(condition)
                    if o:
                        operation, version = o.groups()
                        if operation == "==":
                            operation = "="
                        if version and version.startswith("0:"):
                            version = version[2:]
                result.append((name, operation, version, bool(flag)))
        return result

    def load(self):

        Pkg = RPMPackage
        Prv = RPMProvides
        NPrv = RPMNameProvides
        PreReq = RPMPreRequires
        Req = RPMRequires
        Obs = RPMObsoletes
        Cnf = RPMConflicts

        requires = ()
        provides = ()
        conflicts = ()
        obsoletes = ()

        prog = iface.getProgress(self._cache)

        for line in open(self._filename):

            element = line[1:-1].split("@")
            id = element.pop(0)

            if id == "summary":
                summary = element[0]

            elif id == "provides":
                provides = self.splitDepends(element)

            elif id == "requires":
                requires = self.splitDepends(element)

            elif id == "conflicts":
                conflicts = self.splitDepends(element)

            elif id == "obsoletes":
                obsoletes = self.splitDepends(element)

            elif id == "info":

                rpmnameparts = element[0].split("-")

                version = "-".join(rpmnameparts[-2:])
                epoch = element[1]
                if epoch != "0":
                    version = "%s:%s" % (epoch, version)

                dot = version.rfind(".")
                if dot == -1:
                    arch = "unknown"
                else:
                    version, arch = version[:dot], version[dot+1:]
                versionarch = "@".join((version, arch))

                name = "-".join(rpmnameparts[0:-2])

                info = {"summary": summary,
                        "size"   : element[2],
                        "group"  : element[3]}

                prvdict = {}
                for n, r, v, f in provides:
                    if n == name and v == version:
                        prv = (NPrv, n, versionarch)
                    else:
                        prv = (Prv, n, v)
                    prvdict[prv] = True

                reqdict = {}
                for n, r, v, f in requires:
                    if f:
                        reqdict[(PreReq, n, r, v)] = True
                    else:
                        reqdict[(Req, n, r, v)] = True

                cnfdict = {}
                for n, r, v, f in conflicts:
                    cnfdict[(Cnf, n, r, v)] = True

                upgdict = {}
                upgdict[(Obs, name, "<", versionarch)] = True

                for n, r, v, f in obsoletes:
                    upg = (Obs, n, r, v)
                    upgdict[upg] = True
                    cnfdict[upg] = True

                pkg = self.buildPackage((Pkg, name, versionarch),
                                        prvdict.keys(), reqdict.keys(),
                                        upgdict.keys(), cnfdict.keys())
                pkg.loaders[self] = info

                prog.add(1)
                prog.show()

                provides = ()
                requires = ()
                conflicts = ()
                obsoletes = ()
