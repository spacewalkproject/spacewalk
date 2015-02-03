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
from smart.util.strtools import globdistance
from smart.const import BLOCKSIZE
from smart import *
import os

class StateVersionError(Error): pass

class Package(object):

    def __init__(self, name, version):
        self.name = name
        self.version = version
        self.provides = ()
        self.requires = ()
        self.upgrades = ()
        self.conflicts = ()
        self.installed = False
        self.essential = False
        self.priority = 0
        self.loaders = {}

    def getInitArgs(self):
        return (self.__class__, self.name, self.version)

    def equals(self, other):
        # These two packages are exactly the same?
        fk = dict.fromkeys
        if (self.name != other.name or
            self.version != other.version or
            len(self.upgrades) != len(other.upgrades) or
            len(self.conflicts) != len(other.conflicts) or
            fk(self.upgrades) != fk(other.upgrades) or
            fk(self.conflicts) != fk(other.conflicts) or
            fk([x for x in self.provides if x.name[0] != "/"]) !=
            fk([x for x in other.provides if x.name[0] != "/"]) or
            fk([x for x in self.requires if x.name[0] != "/"]) !=
            fk([x for x in other.requires if x.name[0] != "/"])):
            return False
        return True

    def coexists(self, other):
        # These two packages with the same name may coexist?
        return False

    def matches(self, relation, version):
        return False

    def search(self, searcher):
        myname = self.name
        myversion = self.version
        ratio = 0
        for nameversion, cutoff in searcher.nameversion:
            _, ratio1 = globdistance(nameversion, myname, cutoff)
            _, ratio2 = globdistance(nameversion,
                                     "%s-%s" % (myname, myversion), cutoff)
            ratio = max(ratio, ratio1, ratio2)
        if ratio:
            searcher.addResult(self, ratio)

    def getPriority(self):
        priority = pkgconf.getPriority(self)
        if priority is not None:
            return priority
        channelpriority = None
        for loader in self.loaders:
            priority = loader.getChannel().getPriority()
            if channelpriority is None or priority > channelpriority:
                channelpriority = priority
        return channelpriority+self.priority

    def __repr__(self):
        return str(self)

    def __str__(self):
        return "%s-%s" % (self.name, self.version)

    def __lt__(self, other):
        # This is used for sorting, and should be overloaded.
        rc = -1
        if isinstance(other, Package):
            rc = cmp(self.name, other.name)
            if rc == 0:
                rc = cmp(self.version, other.version)
        return rc == -1

    def __getstate__(self):
        return (self.name,
                self.version,
                self.provides,
                self.requires,
                self.upgrades,
                self.conflicts,
                self.installed,
                self.essential,
                self.priority,
                self.loaders)

    def __setstate__(self, state):
        (self.name,
         self.version,
         self.provides,
         self.requires,
         self.upgrades,
         self.conflicts,
         self.installed,
         self.essential,
         self.priority,
         self.loaders) = state

class PackageInfo(object):
    def __init__(self, package, order=0):
        self._package = package
        self._order = order

    def getPackage(self):
        return self._package

    def getDescription(self):
        return ""

    def getSummary(self):
        return ""

    def getGroup(self):
        return ""

    def getPathList(self):
        return []

    def pathIsDir(self, path):
        return None

    def pathIsLink(self, path):
        return None

    def pathIsFile(self, path):
        return None

    def pathIsSpecial(self, path):
        return None

    def getInstalledSize(self):
        return None

    def getReferenceURLs(self):
        return []

    def getURLs(self):
        return []

    def getSize(self, url):
        return None

    def getMD5(self, url):
        return None

    def getSHA(self, url):
        return None

    def validate(self, url, localpath, withreason=False):
        try:
            if not os.path.isfile(localpath):
                raise Error, _("File not found")

            size = self.getSize(url)
            if size:
                lsize = os.path.getsize(localpath)
                if lsize != size:
                    raise Error, _("Unexpected size (expected %d, got %d)") % \
                                 (size, lsize)

            filemd5 = self.getMD5(url)
            if filemd5:
                import md5
                digest = md5.md5()
                file = open(localpath)
                data = file.read(BLOCKSIZE)
                while data:
                    digest.update(data)
                    data = file.read(BLOCKSIZE)
                lfilemd5 = digest.hexdigest()
                if lfilemd5 != filemd5:
                    raise Error, _("Invalid MD5 (expected %s, got %s)") % \
                                 (filemd5, lfilemd5)
            else:
                filesha = self.getSHA(url)
                if filesha:
                    import sha
                    digest = sha.sha()
                    file = open(localpath)
                    data = file.read(BLOCKSIZE)
                    while data:
                        digest.update(data)
                        data = file.read(BLOCKSIZE)
                    lfilesha = digest.hexdigest()
                    if lfilesha != filesha:
                        raise Error, _("Invalid SHA (expected %s, got %s)") % \
                                     (filesha, lfilesha)
        except Error, reason:
            if withreason:
                return False, reason
            return False
        else:
            if withreason:
                return True, None
            return True

    def __lt__(self, other):
        return self._order < other._order

class Provides(object):
    def __init__(self, name, version):
        self.name = name
        self.version = version
        self.packages = []
        self.requiredby = ()
        self.upgradedby = ()
        self.conflictedby = ()

    def getInitArgs(self):
        return (self.__class__, self.name, self.version)

    def search(self, searcher):
        myname = self.name
        myversion = self.version
        ratio = 0
        for provides, cutoff in searcher.provides:
            _, ratio1 = globdistance(provides, myname, cutoff)
            _, ratio2 = globdistance(provides, "%s-%s" % (myname, myversion),
                                     cutoff)
            ratio = max(ratio, ratio1, ratio2)
        if ratio:
            searcher.addResult(self, ratio)

    def __repr__(self):
        return str(self)

    def __str__(self):
        if self.version:
            return "%s = %s" % (self.name, self.version)
        return self.name

    def __cmp__(self, other):
        rc = cmp(self.name, other.name)
        if rc == 0:
            rc = cmp(self.version, other.version)
            if rc == 0:
                rc = cmp(self.__class__, other.__class__)
        return rc

    def __reduce__(self):
        return (self.__class__, (self.name, self.version))

class Depends(object):
    def __init__(self, name, relation, version):
        self.name = name
        self.relation = relation
        self.version = version
        self.packages = []
        self.providedby = ()

    def getInitArgs(self):
        return (self.__class__, self.name, self.relation, self.version)

    def getMatchNames(self):
        return (self.name,)

    def matches(self, prv):
        return False

    def __repr__(self):
        return str(self)

    def __str__(self):
        if self.version:
            return "%s %s %s" % (self.name, self.relation, self.version)
        else:
            return self.name

    def __cmp__(self, other):
        rc = cmp(self.name, other.name)
        if rc == 0:
            rc = cmp(self.version, other.version)
            if rc == 0:
                rc = cmp(self.__class__, other.__class__)
        return rc

    def __reduce__(self):
        return (self.__class__, (self.name, self.relation, self.version))

class PreRequires(Depends): pass
class Requires(Depends): pass
class Upgrades(Depends): pass
class Conflicts(Depends): pass

class Loader(object):

    def __init__(self):
        self._packages = []
        self._channel = None
        self._cache = None
        self._installed = False

    def getPackages(self):
        return self._packages

    def getChannel(self):
        return self._channel

    def setChannel(self, channel):
        self._channel = channel

    def getCache(self):
        return self._cache

    def setCache(self, cache):
        self._cache = cache

    def getInstalled(self):
        return self._installed

    def setInstalled(self, flag):
        self._installed = flag

    def getLoadSteps(self):
        return 0

    def getInfo(self, pkg):
        return None

    def reset(self):
        del self._packages[:]

    def load(self):
        pass

    def unload(self):
        self.reset()

    def loadFileProvides(self, fndict):
        pass

    def buildPackage(self, pkgargs, prvargs, reqargs, upgargs, cnfargs):
        cache = self._cache
        pkg = pkgargs[0](*pkgargs[1:])
        relpkgs = []
        if prvargs:
            pkg.provides = []
            for args in prvargs:
                prv = cache._objmap.get(args)
                if not prv:
                    prv = args[0](*args[1:])
                    cache._objmap[args] = prv
                    cache._provides.append(prv)
                relpkgs.append(prv.packages)
                pkg.provides.append(prv)

        if reqargs:
            pkg.requires = []
            for args in reqargs:
                req = cache._objmap.get(args)
                if not req:
                    req = args[0](*args[1:])
                    cache._objmap[args] = req
                    cache._requires.append(req)
                relpkgs.append(req.packages)
                pkg.requires.append(req)

        if upgargs:
            pkg.upgrades = []
            for args in upgargs:
                upg = cache._objmap.get(args)
                if not upg:
                    upg = args[0](*args[1:])
                    cache._objmap[args] = upg
                    cache._upgrades.append(upg)
                relpkgs.append(upg.packages)
                pkg.upgrades.append(upg)

        if cnfargs:
            pkg.conflicts = []
            for args in cnfargs:
                cnf = cache._objmap.get(args)
                if not cnf:
                    cnf = args[0](*args[1:])
                    cache._objmap[args] = cnf
                    cache._conflicts.append(cnf)
                relpkgs.append(cnf.packages)
                pkg.conflicts.append(cnf)

        found = False
        lst = cache._objmap.get(pkgargs)
        if lst is not None:
            for lstpkg in lst:
                if pkg.equals(lstpkg):
                    pkg = lstpkg
                    found = True
                    break
            else:
                lst.append(pkg)
        else:
            cache._objmap[pkgargs] = [pkg]

        if not found:
            cache._packages.append(pkg)
            for pkgs in relpkgs:
                pkgs.append(pkg)

        pkg.installed |= self._installed
        self._packages.append(pkg)

        return pkg

    def buildFileProvides(self, pkg, prvargs):
        cache = self._cache
        prv = cache._objmap.get(prvargs)
        if not prv:
            prv = prvargs[0](*prvargs[1:])
            cache._objmap[prvargs] = prv
            cache._provides.append(prv)
        elif prv in pkg.provides:
            return

        prv.packages.append(pkg)
        pkg.provides.append(prv)

        for req in pkg.requires[:]:
            if req.name == prv.name:
                pkg.requires.remove(req)
                req.packages.remove(pkg)
                if not req.packages:
                    cache._requires.remove(req)

    def search(self, searcher):
        # Loaders are responsible for searching on PackageInfo. They
        # should use the fastest possible method. The one here is
        # generic, and should be replaced if possible.
        for pkg in self._packages:
            info = self.getInfo(pkg)
            ratio = 0
            if searcher.url:
                for url, cutoff in searcher.url:
                    for refurl in info.getReferenceURLs():
                        _, newratio = globdistance(url, refurl, cutoff)
                        if newratio > ratio:
                            ratio = newratio
                            if ratio == 1:
                                break
                    else:
                        continue
                    break
            if ratio == 1:
                searcher.addResult(pkg, ratio)
                continue
            if searcher.path:
                for spath, cutoff in searcher.path:
                    for path in info.getPathList():
                        _, newratio = globdistance(spath, path, cutoff)
                        if newratio > ratio:
                            ratio = newratio
                            if ratio == 1:
                                break
                    else:
                        continue
                    break
            if ratio == 1:
                searcher.addResult(pkg, ratio)
                continue
            if searcher.group:
                for pat in searcher.group:
                    if pat.search(info.getGroup()):
                        ratio = 1
                        break
            if ratio == 1:
                searcher.addResult(pkg, ratio)
                continue
            if searcher.summary:
                for pat in searcher.summary:
                    if pat.search(info.getSummary()):
                        ratio = 1
                        break
            if ratio == 1:
                searcher.addResult(pkg, ratio)
                continue
            if searcher.description:
                for pat in searcher.description:
                    if pat.search(info.getDescription()):
                        ratio = 1
                        break
            if ratio:
                searcher.addResult(pkg, ratio)

    __stateversion__ = 1

    def __getstate__(self):
        state = self.__dict__.copy()
        state["__stateversion__"] = self.__stateversion__
        return state

    def __setstate__(self, state):
        if state["__stateversion__"] != self.__stateversion__:
            raise StateVersionError
        self.__dict__.update(state)
        del self.__stateversion__

class Cache(object):

    def __init__(self):
        self._loaders = []
        self._packages = []
        self._provides = []
        self._requires = []
        self._upgrades = []
        self._conflicts = []
        self._objmap = {}

    def reset(self):
        for prv in self._provides:
            del prv.packages[:]
            if prv.requiredby:
                del prv.requiredby[:]
            if prv.upgradedby:
                del prv.upgradedby[:]
            if prv.conflictedby:
                del prv.conflictedby[:]
        for req in self._requires:
            del req.packages[:]
            if req.providedby:
                del req.providedby[:]
        for upg in self._upgrades:
            del upg.packages[:]
            if upg.providedby:
                del upg.providedby[:]
        for cnf in self._conflicts:
            del cnf.packages[:]
            if cnf.providedby:
                del cnf.providedby[:]
        del self._packages[:]
        del self._provides[:]
        del self._requires[:]
        del self._upgrades[:]
        del self._conflicts[:]
        self._objmap.clear()

    def addLoader(self, loader):
        if loader:
            if loader not in self._loaders:
                self._loaders.append(loader)
                loader.setCache(self)

    def removeLoader(self, loader):
        if loader:
            if loader in self._loaders:
                self._loaders.remove(loader)
                loader.setCache(None)
                loader.unload()

    def _reload(self):
        packages = {}
        provides = {}
        requires = {}
        upgrades = {}
        conflicts = {}
        objmap = self._objmap
        loaders = dict.fromkeys(self._loaders, True)
        for loader in loaders:
            for pkg in loader._packages:
                if pkg in packages:
                    pkg.installed |= loader._installed
                else:
                    pkg.installed = loader._installed
                    packages[pkg] = True
                    objmap.setdefault(pkg.getInitArgs(), []).append(pkg)
                    for pkgloader in pkg.loaders.keys():
                        if pkgloader not in loaders:
                            del pkg.loaders[pkgloader]
                    for prv in pkg.provides:
                        prv.packages.append(pkg)
                        if prv not in provides:
                            provides[prv] = True
                            objmap[prv.getInitArgs()] = prv
                    for req in pkg.requires[:]:
                        req.packages.append(pkg)
                        if req not in requires:
                            objmap[req.getInitArgs()] = req
                            requires[req] = True
                    for upg in pkg.upgrades:
                        upg.packages.append(pkg)
                        if upg not in upgrades:
                            upgrades[upg] = True
                            objmap[upg.getInitArgs()] = upg
                    for cnf in pkg.conflicts:
                        cnf.packages.append(pkg)
                        if cnf not in conflicts:
                            conflicts[cnf] = True
                            objmap[cnf.getInitArgs()] = cnf
        self._packages[:] = packages.keys()
        self._provides[:] = provides.keys()
        self._requires[:] = requires.keys()
        self._upgrades[:] = upgrades.keys()
        self._conflicts[:] = conflicts.keys()

    def load(self):
        self._reload()
        prog = iface.getProgress(self)
        prog.start()
        prog.setTopic(_("Updating cache..."))
        prog.set(0, 1)
        prog.show()
        total = 1
        for loader in self._loaders:
            if not loader._packages:
                total += loader.getLoadSteps()
        prog.set(0, total)
        prog.show()
        for loader in self._loaders:
            if not loader._packages:
                loader.load()
        self.loadFileProvides()
        self._objmap.clear()
        self.linkDeps()
        prog.setDone()
        prog.show()
        prog.stop()

    def unload(self):
        self.reset()
        for loader in self._loaders:
            loader.unload()

    def loadFileProvides(self):
        fndict = {}
        for req in self._requires:
            name = req.name
            if name[0] == "/":
                fndict[name] = name
        for loader in self._loaders:
            loader.loadFileProvides(fndict)

    def linkDeps(self):
        reqnames = {}
        for req in self._requires:
            for name in req.getMatchNames():
                lst = reqnames.get(name)
                if lst:
                    lst.append(req)
                else:
                    reqnames[name] = [req]
        upgnames = {}
        for upg in self._upgrades:
            for name in upg.getMatchNames():
                lst = upgnames.get(name)
                if lst:
                    lst.append(upg)
                else:
                    upgnames[name] = [upg]
        cnfnames = {}
        for cnf in self._conflicts:
            for name in cnf.getMatchNames():
                lst = cnfnames.get(name)
                if lst:
                    lst.append(cnf)
                else:
                    cnfnames[name] = [cnf]
        for prv in self._provides:
            lst = reqnames.get(prv.name)
            if lst:
                for req in lst:
                    if req.matches(prv):
                        if req.providedby:
                            req.providedby.append(prv)
                        else:
                            req.providedby = [prv]
                        if prv.requiredby:
                            prv.requiredby.append(req)
                        else:
                            prv.requiredby = [req]
            lst = upgnames.get(prv.name)
            if lst:
                for upg in lst:
                    if upg.matches(prv):
                        if upg.providedby:
                            upg.providedby.append(prv)
                        else:
                            upg.providedby = [prv]
                        if prv.upgradedby:
                            prv.upgradedby.append(upg)
                        else:
                            prv.upgradedby = [upg]
            lst = cnfnames.get(prv.name)
            if lst:
                for cnf in lst:
                    if cnf.matches(prv):
                        if cnf.providedby:
                            cnf.providedby.append(prv)
                        else:
                            cnf.providedby = [prv]
                        if prv.conflictedby:
                            prv.conflictedby.append(cnf)
                        else:
                            prv.conflictedby = [cnf]

    def getPackages(self, name=None):
        if not name:
            return self._packages
        else:
            return [x for x in self._packages if x.name == name]

    def getProvides(self, name=None):
        if not name:
            return self._provides
        else:
            return [x for x in self._provides if x.name == name]

    def getRequires(self, name=None):
        if not name:
            return self._requires
        else:
            return [x for x in self._requires if x.name == name]

    def getUpgrades(self, name=None):
        if not name:
            return self._upgrades
        else:
            return [x for x in self._upgrades if x.name == name]

    def getConflicts(self, name=None):
        if not name:
            return self._conflicts
        else:
            return [x for x in self._conflicts if x.name == name]

    def search(self, searcher):
        if searcher.nameversion:
            for pkg in self._packages:
                pkg.search(searcher)
        if searcher.provides:
            for prv in self._provides:
                prv.search(searcher)
        if searcher.requires:
            for prv in searcher.requires:
                prvname = prv.name
                for req in self._requires:
                    if prvname in req.getMatchNames() and req.matches(prv):
                        searcher.addResult(req)
        if searcher.upgrades:
            for prv in searcher.upgrades:
                prvname = prv.name
                for upg in self._upgrades:
                    if prvname in upg.getMatchNames() and upg.matches(prv):
                        searcher.addResult(upg)
        if searcher.conflicts:
            for prv in searcher.conflicts:
                prvname = prv.name
                for cnf in self._conflicts:
                    if prvname in cnf.getMatchNames() and cnf.matches(prv):
                        searcher.addResult(cnf)
        if searcher.needsPackageInfo():
            for loader in self._loaders:
                loader.search(searcher)

    __stateversion__ = 1

    def __getstate__(self):
        state = {}
        state["__stateversion__"] = self.__stateversion__
        state["_loaders"] = self._loaders
        state["_packages"] = self._packages
        return state

    def __setstate__(self, state):
        if state["__stateversion__"] != self.__stateversion__:
            raise StateVersionError
        self._loaders = state["_loaders"]
        self._packages = state["_packages"]
        provides = {}
        requires = {}
        upgrades = {}
        conflicts = {}
        for pkg in self._packages:
            for prv in pkg.provides:
                prv.packages.append(pkg)
                provides[prv] = True
            for req in pkg.requires:
                req.packages.append(pkg)
                requires[req] = True
            for upg in pkg.upgrades:
                upg.packages.append(pkg)
                upgrades[upg] = True
            for cnf in pkg.conflicts:
                cnf.packages.append(pkg)
                conflicts[cnf] = True
        self._provides = provides.keys()
        self._requires = requires.keys()
        self._upgrades = upgrades.keys()
        self._conflicts = conflicts.keys()
        self._objmap = {}

from ccache import *
