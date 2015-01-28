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
from smart.backends.rpm.rpmver import splitarch
from smart.util.strtools import globdistance
from smart.cache import Loader, PackageInfo
from smart.channel import FileChannel
from smart.backends.rpm.base import *
from smart.progress import Progress
from smart import *
import locale
import stat
import rpm
import os, sys

try:
    import rpmhelper
except ImportError:
    rpmhelper = None

CRPMTAG_FILENAME          = 1000000
CRPMTAG_FILESIZE          = 1000001
CRPMTAG_MD5               = 1000005
CRPMTAG_SHA1              = 1000006

CRPMTAG_DIRECTORY         = 1000010
CRPMTAG_BINARY            = 1000011

CRPMTAG_UPDATE_SUMMARY    = 1000020
CRPMTAG_UPDATE_IMPORTANCE = 1000021
CRPMTAG_UPDATE_DATE       = 1000022
CRPMTAG_UPDATE_URL        = 1000023

ENCODINGS = ["utf8", "iso-8859-1"]

class RPMHeaderPackageInfo(PackageInfo):

    class LazyHeader(object):
        def __get__(self, obj, type):
            obj._h = obj._loader.getHeader(obj._package)
            return obj._h

    _h = LazyHeader()

    def __init__(self, package, loader, order=0):
        PackageInfo.__init__(self, package, order)
        self._loader = loader
        self._path = None

    def getReferenceURLs(self):
        url = self._h[rpm.RPMTAG_URL]
        if url:
            return [url]
        return []

    def getURLs(self):
        url = self._loader.getURL()
        if url:
            return [os.path.join(url, self._loader.getFileName(self))]
        return []

    def getSize(self, url):
        return self._loader.getSize(self)

    def getMD5(self, url):
        return self._loader.getMD5(self)

    def getInstalledSize(self):
        return self._h[rpm.RPMTAG_SIZE]

    def getDescription(self):
        s = self._h[rpm.RPMTAG_DESCRIPTION]
        for encoding in ENCODINGS:
            try:
                s = s.decode(encoding)
            except UnicodeDecodeError:
                continue
            break
        else:
            s = ""
        return s

    def getSummary(self):
        s = self._h[rpm.RPMTAG_SUMMARY]
        for encoding in ENCODINGS:
            try:
                s = s.decode(encoding)
            except UnicodeDecodeError:
                continue
            break
        else:
            s = ""
        return s

    def getGroup(self):
        s = self._loader.getGroup(self._package)
        for encoding in ENCODINGS:
            try:
                s = s.decode(encoding)
            except UnicodeDecodeError:
                continue
            break
        else:
            s = ""
        return s

    def getPathList(self):
        if self._path is None:
            paths = self._h[rpm.RPMTAG_OLDFILENAMES]
            modes = self._h[rpm.RPMTAG_FILEMODES]
            if modes:
                self._path = {}
                for i in range(len(paths)):
                    self._path[paths[i]] = modes[i]
            else:
                self._path = dict.fromkeys(paths, 0)
        return self._path.keys()

    def pathIsDir(self, path):
        return stat.S_ISDIR(self._path[path])

    def pathIsLink(self, path):
        return stat.S_ISLNK(self._path[path])

    def pathIsFile(self, path):
        return stat.S_ISREG(self._path[path])

    def pathIsSpecial(self, path):
        mode = self._path[path]
        return not (stat.S_ISDIR(mode) or
                    stat.S_ISLNK(mode) or
                    stat.S_ISREG(mode))

class RPMHeaderLoader(Loader):

    __stateversion__ = Loader.__stateversion__+1

    COMPFLAGS = rpm.RPMSENSE_EQUAL|rpm.RPMSENSE_GREATER|rpm.RPMSENSE_LESS

    COMPMAP = { rpm.RPMSENSE_EQUAL:   "=",
                rpm.RPMSENSE_LESS:    "<",
                rpm.RPMSENSE_GREATER: ">",
                rpm.RPMSENSE_EQUAL|rpm.RPMSENSE_LESS:    "<=",
                rpm.RPMSENSE_EQUAL|rpm.RPMSENSE_GREATER: ">=" }

    def __init__(self):
        Loader.__init__(self)
        self._infoorder = 0
        self._offsets = {}
        self._groups = {}

    def getHeaders(self, prog):
        return []

    def getInfo(self, pkg):
        return RPMHeaderPackageInfo(pkg, self, self._infoorder)

    def getGroup(self, pkg):
        return self._groups[pkg]

    def reset(self):
        Loader.reset(self)
        self._offsets.clear()
        self._groups.clear()

    def load(self):
        CM = self.COMPMAP
        CF = self.COMPFLAGS
        Pkg = RPMPackage
        Prv = RPMProvides
        NPrv = RPMNameProvides
        PreReq = RPMPreRequires
        Req = RPMRequires
        Obs = RPMObsoletes
        Cnf = RPMConflicts
        prog = iface.getProgress(self._cache)
        for h, offset in self.getHeaders(prog):
            if h[1106]: # RPMTAG_SOURCEPACKAGE
                continue
            arch = h[1022] # RPMTAG_ARCH
            if rpm.archscore(arch) == 0:
                continue

            name = h[1000] # RPMTAG_NAME
            epoch = h[1003] # RPMTAG_EPOCH
            if epoch and epoch != "0":
                # RPMTAG_VERSION, RPMTAG_RELEASE
                version = "%s:%s-%s" % (epoch, h[1001], h[1002])
            else:
                # RPMTAG_VERSION, RPMTAG_RELEASE
                version = "%s-%s" % (h[1001], h[1002])
            versionarch = "%s@%s" % (version, arch)

            n = h[1047] # RPMTAG_PROVIDENAME
            v = h[1113] # RPMTAG_PROVIDEVERSION
            prvdict = {}
            for i in range(len(n)):
                ni = n[i]
                if not ni.startswith("config("):
                    vi = v[i]
                    if vi and vi[:2] == "0:":
                        vi = vi[2:]
                    if ni == name and vi == version:
                        prvdict[(NPrv, intern(ni), versionarch)] = True
                    else:
                        prvdict[(Prv, intern(ni), vi or None)] = True
            prvargs = prvdict.keys()

            n = h[1049] # RPMTAG_REQUIRENAME
            if n:
                f = h[1048] # RPMTAG_REQUIREFLAGS
                v = h[1050] # RPMTAG_REQUIREVERSION
                reqdict = {}
                for i in range(len(n)):
                    ni = n[i]
                    if ni[:7] not in ("rpmlib(", "config("):
                        vi = v[i] or None
                        if vi and vi[:2] == "0:":
                            vi = vi[2:]
                        r = CM.get(f[i]&CF)
                        if ((r is not None and r != "=") or
                            ((Prv, ni, vi) not in prvdict)):
                            # RPMSENSE_PREREQ |
                            # RPMSENSE_SCRIPT_PRE |
                            # RPMSENSE_SCRIPT_PREUN |
                            # RPMSENSE_SCRIPT_POST |
                            # RPMSENSE_SCRIPT_POSTUN == 7744
                            reqdict[(f[i]&7744 and PreReq or Req,
                                     intern(ni), r, vi)] = True
                reqargs = reqdict.keys()
            else:
                reqargs = None

            n = h[1054] # RPMTAG_CONFLICTNAME
            if n:
                f = h[1053] # RPMTAG_CONFLICTFLAGS
                # FIXME (20050321): Solaris rpm 4.1 hack
                if type(f) == int:
                    f = [f]
                v = h[1055] # RPMTAG_CONFLICTVERSION
                cnfargs = []
                for i in range(len(n)):
                    vi = v[i] or None
                    if vi and vi[:2] == "0:":
                        vi = vi[2:]
                    cnfargs.append((Cnf, n[i], CM.get(f[i]&CF), vi))
            else:
                cnfargs = []

            obstup = (Obs, name, '<', versionarch)

            n = h[1090] # RPMTAG_OBSOLETENAME
            if n:
                f = h[1114] # RPMTAG_OBSOLETEFLAGS
                # FIXME (20050321): Solaris rpm 4.1 hack
                if type(f) == int:
                    f = [f]
                v = h[1115] # RPMTAG_OBSOLETEVERSION
                upgargs = []
                for i in range(len(n)):
                    vi = v[i] or None
                    if vi and vi[:2] == "0:":
                        vi = vi[2:]
                    upgargs.append((Obs, n[i], CM.get(f[i]&CF), vi))
                cnfargs.extend(upgargs)
                upgargs.append(obstup)
            else:
                upgargs = [obstup]

            pkg = self.buildPackage((Pkg, name, versionarch),
                                    prvargs, reqargs, upgargs, cnfargs)
            pkg.loaders[self] = offset
            self._offsets[offset] = pkg
            self._groups[pkg] = intern(h[rpm.RPMTAG_GROUP])

    def search(self, searcher):
        for h, offset in self.getHeaders(Progress()):
            pkg = self._offsets.get(offset)
            if not pkg:
                continue

            ratio = 0
            if searcher.url:
                refurl = h[rpm.RPMTAG_URL]
                if refurl:
                    for url, cutoff in searcher.url:
                        _, newratio = globdistance(url, refurl, cutoff)
                        if newratio > ratio:
                            ratio = newratio
                            if ratio == 1:
                                break
            if ratio == 1:
                searcher.addResult(pkg, ratio)
                continue
            if searcher.path:
                paths = h[rpm.RPMTAG_OLDFILENAMES]
                if paths:
                    for spath, cutoff in searcher.path:
                        for path in paths:
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
                group = self._groups[pkg]
                for pat in searcher.group:
                    if pat.search(group):
                        ratio = 1
                        break
            if ratio == 1:
                searcher.addResult(pkg, ratio)
                continue
            if searcher.summary:
                summary = h[rpm.RPMTAG_SUMMARY]
                for pat in searcher.summary:
                    if pat.search(summary):
                        ratio = 1
                        break
            if ratio == 1:
                searcher.addResult(pkg, ratio)
                continue
            if searcher.description:
                description = h[rpm.RPMTAG_DESCRIPTION]
                for pat in searcher.description:
                    if pat.search(description):
                        ratio = 1
                        break
            if ratio:
                searcher.addResult(pkg, ratio)

class RPMHeaderListLoader(RPMHeaderLoader):

    def __init__(self, filename, baseurl, count=None):
        RPMHeaderLoader.__init__(self)
        self._filename = filename
        self._baseurl = baseurl
        self._count = count

        self._checkRPM()

    def __getstate__(self):
        state = RPMHeaderLoader.__getstate__(self)
        if "_hdl" in state:
            del state["_hdl"]
        return state

    def __setstate__(self, state):
        RPMHeaderLoader.__setstate__(self, state)
        self._checkRPM()

    def _checkRPM(self):
        if not hasattr(rpm, "readHeaderFromFD"):

            if (not hasattr(self.__class__, "WARNED") and
                sysconf.get("no-rpm-readHeaderFromFD", 0) < 3):

                self.__class__.WARNED = True
                sysconf.set("no-rpm-readHeaderFromFD",
                            sysconf.get("no-rpm-readHeaderFromFD", 0)+1)
                iface.warning(_("Your rpm module has no support for "
                                "readHeaderFromFD()!\n"
                                "As a consequence, Smart will consume "
                                "extra memory."))

            self.__class__.getHeaders = self.getHeadersHDL
            self.__class__.getHeader = self.getHeaderHDL
            self.__class__.loadFileProvides = self.loadFileProvidesHDL

            self._hdl = rpm.readHeaderListFromFile(self._filename)

    def getLoadSteps(self):
        if self._count is None:
            if hasattr(rpm, "readHeaderFromFD"):
                return os.path.getsize(self._filename)/2500
            else:
                return len(rpm.readHeaderListFromFile(self._filename))
        return self._count

    def getHeaders(self, prog):
        file = open(self._filename)
        lastoffset = mod = 0
        h, offset = rpm.readHeaderFromFD(file.fileno())
        if self._count:
            while h:
                yield h, offset
                h, offset = rpm.readHeaderFromFD(file.fileno())
                if offset:
                    prog.add(1)
                    prog.show()
        else:
            while h:
                yield h, offset
                h, offset = rpm.readHeaderFromFD(file.fileno())
                if offset:
                    div, mod = divmod(offset-lastoffset+mod, 2500)
                    lastoffset = offset
                    prog.add(div)
                    prog.show()
        file.close()

    def getHeadersHDL(self, prog):
        for offset, h in enumerate(self._hdl):
            yield h, offset
            prog.add(1)
            prog.show()

    def getHeader(self, pkg):
        file = open(self._filename)
        file.seek(pkg.loaders[self])
        h, offset = rpm.readHeaderFromFD(file.fileno())
        file.close()
        return h

    def getHeaderHDL(self, pkg):
        return self._hdl[pkg.loaders[self]]

    def getURL(self):
        return self._baseurl

    def getFileName(self, info):
        h = info._h
        return "%s-%s-%s.%s.rpm" % (h[rpm.RPMTAG_NAME],
                                    h[rpm.RPMTAG_VERSION],
                                    h[rpm.RPMTAG_RELEASE],
                                    h[rpm.RPMTAG_ARCH])

    def getSize(self, info):
        return None

    def getMD5(self, info):
        return None

    def loadFileProvides(self, fndict):
        file = open(self._filename)
        h, offset = rpm.readHeaderFromFD(file.fileno())
        bfp = self.buildFileProvides
        while h:
            for fn in h[1027]: # RPMTAG_OLDFILENAMES
                fn = fndict.get(fn)
                if fn and offset in self._offsets:
                    bfp(self._offsets[offset], (RPMProvides, fn, None))
            h, offset = rpm.readHeaderFromFD(file.fileno())
        file.close()

    def loadFileProvidesHDL(self, fndict):
        bfp = self.buildFileProvides
        for offset, h in enumerate(self._hdl):
            for fn in h[1027]: # RPMTAG_OLDFILENAMES
                fn = fndict.get(fn)
                if fn and offset in self._offsets:
                    bfp(self._offsets[offset], (RPMProvides, fn, None))

class RPMPackageListLoader(RPMHeaderListLoader):

    def getFileName(self, info):
        h = info._h
        filename = h[CRPMTAG_FILENAME]
        if not filename:
            raise Error, _("Package list with no CRPMTAG_FILENAME tag")
        directory = h[CRPMTAG_DIRECTORY]
        if directory:
            filename = os.path.join(directory, filename)
        return filename

    def getSize(self, info):
        return info._h[CRPMTAG_FILESIZE]

    def getMD5(self, info):
        return info._h[CRPMTAG_MD5]

class URPMILoader(RPMHeaderListLoader):

    def __init__(self, filename, baseurl, listfile):
        RPMHeaderListLoader.__init__(self, filename, baseurl)
        self._prefix = {}
        if listfile:
            for entry in open(listfile):
                if entry[:2] == "./":
                    entry = entry[2:]
                dirname, basename = os.path.split(entry.rstrip())
                self._prefix[basename] = dirname

    def getFileName(self, info):
        h = info._h
        filename = h[CRPMTAG_FILENAME]
        if not filename:
            raise Error, _("Package list with no CRPMTAG_FILENAME tag")
        if filename in self._prefix:
            filename = os.path.join(self._prefix[filename], filename)
        return filename

    def getSize(self, info):
        return info._h[CRPMTAG_FILESIZE]

    def getMD5(self, info):
        return None

class RPMDBLoader(RPMHeaderLoader):

    def __init__(self):
        RPMHeaderLoader.__init__(self)
        self.setInstalled(True)
        self._infoorder = -100

    def getLoadSteps(self):
        return 1

    def getHeaders(self, prog):
        # FIXME (20050321): Solaris rpm 4.1 hack
        if sys.platform[:5] == "sunos":
            rpm.addMacro("_dbPath", sysconf.get("rpm-root", "/"))
            ts = rpm.TransactionSet()
        else:
            ts = rpm.ts(sysconf.get("rpm-root", "/"))
        mi = ts.dbMatch()
        for h in mi:
            if h[1000] != "gpg-pubkey": # RPMTAG_NAME
                yield h, mi.instance()
            prog.addTotal(1)
            prog.add(1)
            prog.show()
        prog.add(1)

    if rpmhelper:
        def getHeader(self, pkg):
            # FIXME (20050321): Solaris rpm 4.1 hack
            if sys.platform[:5] == "sunos":
                rpm.addMacro("_dbPath", sysconf.get("rpm-root", "/"))
                ts = rpm.TransactionSet()
            else:
                ts = rpm.ts(sysconf.get("rpm-root", "/"))
            mi = rpmhelper.dbMatch(ts, 0, pkg.loaders[self])
            return mi.next()
    else:
        def getHeader(self, pkg):
            # FIXME (20050321): Solaris rpm 4.1 hack
            if sys.platform[:5] == "sunos":
                rpm.addMacro("_dbPath", sysconf.get("rpm-root", "/"))
                ts = rpm.TransactionSet()
            else:
                ts = rpm.ts(sysconf.get("rpm-root", "/"))
            mi = ts.dbMatch(0, pkg.loaders[self])
            return mi.next()

    def getURL(self):
        return None

    def getFileName(self, info):
        return None

    def getSize(self, info):
        return None

    def getMD5(self, info):
        return None

    def loadFileProvides(self, fndict):
        # FIXME (20050321): Solaris rpm 4.1 hack
        if sys.platform[:5] == "sunos":
            rpm.addMacro("_dbPath", sysconf.get("rpm-root", "/"))
            ts = rpm.TransactionSet()
        else:
            ts = rpm.ts(sysconf.get("rpm-root", "/"))
        bfp = self.buildFileProvides
        for fn in fndict:
            mi = ts.dbMatch(1117, fn) # RPMTAG_BASENAMES
            try:
                h = mi.next()
                while h:
                    i = mi.instance()
                    if i in self._offsets:
                        bfp(self._offsets[i], (RPMProvides, fn, None))
                    h = mi.next()
            except StopIteration:
                pass

class RPMDirLoader(RPMHeaderLoader):

    def __init__(self, dir, filename=None):
        RPMHeaderLoader.__init__(self)
        self._dir = os.path.abspath(dir)
        if filename:
            self._filenames = [filename]
        else:
            self._filenames = [x for x in os.listdir(dir)
                               if x.endswith(".rpm") and
                               not x.endswith(".src.rpm")]

    def getLoadSteps(self):
        return len(self._filenames)

    def getHeaders(self, prog):
        # FIXME (20050321): Solaris rpm 4.1 hack
        if sys.platform[:5] == "sunos":
            rpm.addMacro("_dbPath", sysconf.get("rpm-root", "/"))
            ts = rpm.TransactionSet()
        else:
            ts = rpm.ts()
        for i, filename in enumerate(self._filenames):
            filepath = os.path.join(self._dir, filename)
            file = open(filepath)
            try:
                h = ts.hdrFromFdno(file.fileno())
            except rpm.error, e:
                iface.error("%s: %s" % (os.path.basename(filepath), e))
            else:
                yield (h, i)
            file.close()
            prog.add(1)
            prog.show()

    def getHeader(self, pkg):
        filename = self._filenames[pkg.loaders[self]]
        filepath = os.path.join(self._dir, filename)
        file = open(filepath)
        # FIXME (20050321): Solaris rpm 4.1 hack
        if sys.platform[:5] == "sunos":
            rpm.addMacro("_dbPath", sysconf.get("rpm-root", "/"))
            ts = rpm.TransactionSet()
        else:
            ts = rpm.ts()
        try:
            h = ts.hdrFromFdno(file.fileno())
        except rpm.error, e:
            iface.error("%s: %s" % (os.path.basename(filepath), e))
            h = None
        file.close()
        return h

    def getURL(self):
        return "file:///"

    def getFileName(self, info):
        pkg = info.getPackage()
        filename = self._filenames[pkg.loaders[self]]
        filepath = os.path.join(self._dir, filename)
        while filepath.startswith("/"):
            filepath = filepath[1:]
        return filepath

    def getSize(self, info):
        pkg = info.getPackage()
        filename = self._filenames[pkg.loaders[self]]
        return os.path.getsize(os.path.join(self._dir, filename))

    def getMD5(self, info):
        # Could compute it now, but why?
        return None

    def loadFileProvides(self, fndict):
        # FIXME (20050321): Solaris rpm 4.1 hack
        if sys.platform[:5] == "sunos":
            rpm.addMacro("_dbPath", sysconf.get("rpm-root", "/"))
            ts = rpm.TransactionSet()
        else:
            ts = rpm.ts()
        bfp = self.buildFileProvides
        for i, filename in enumerate(self._filenames):
            if i not in self._offsets:
                continue
            filepath = os.path.join(self._dir, filename)
            file = open(filepath)
            try:
                h = ts.hdrFromFdno(file.fileno())
            except rpm.error, e:
                file.close()
                iface.error("%s: %s" % (os.path.basename(filepath), e))
            else:
                file.close()
                # FIXME (20050321): Solaris rpm 4.1 hack
                f = h[1027] # RPMTAG_OLDFILENAMES
                if f == None: f = []
                for fn in f:
                    fn = fndict.get(fn)
                    if fn:
                        bfp(self._offsets[i], (RPMProvides, fn, None))

class RPMFileChannel(FileChannel):

    def fetch(self, fetcher, progress):
        digest = os.path.getmtime(self._filename)
        if digest == self._digest:
            return True
        self.removeLoaders()
        dirname, basename = os.path.split(self._filename)
        loader = RPMDirLoader(dirname, basename)
        loader.setChannel(self)
        self._loaders.append(loader)
        self._digest = digest
        return True

def createFileChannel(filename):
    if filename.endswith(".rpm") and not filename.endswith(".src.rpm"):
        return RPMFileChannel(filename)
    return None

hooks.register("create-file-channel", createFileChannel)
