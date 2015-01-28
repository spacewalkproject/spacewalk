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
from smart.cache import Loader, PackageInfo
from smart.util.strtools import globdistance
from smart.util.tagfile import TagFile
from smart.channel import FileChannel
from smart.backends.deb.debver import parserelation, parserelations
from smart.backends.deb.base import *
from smart.progress import Progress
from smart import *
from cStringIO import StringIO
import locale
import stat
import os

ENCODING = locale.getpreferredencoding()

class DebPackageInfo(PackageInfo):

    class LazyDict(object):
        def __get__(self, obj, type):
            obj._dict = obj._loader.getDict(obj._package)
            return obj._dict

    _dict = LazyDict()

    def __init__(self, package, loader):
        PackageInfo.__init__(self, package)
        self._loader = loader

    def getURLs(self):
        url = self._loader.getURL()
        if url:
            return [os.path.join(url, self._loader.getFileName(self))]
        return []

    def getSize(self, url):
        return self._loader.getSize(self)

    def getMD5(self, url):
        return self._dict.get("md5sum")

    def getInstalledSize(self):
        size = self._dict.get("installed-size")
        if size:
            return long(size)*1024
        return None

    def getDescription(self):
        toks = self._dict.get("description").split("\n", 1)
        if len(toks) == 2:
            return toks[1]
        return ""

    def getSummary(self):
        description = self._dict.get("description")
        if description:
            return description.split("\n", 1)[0]
        return ""

    def getGroup(self):
        return self._loader.getSection(self._package)

class DebTagLoader(Loader):

    def __init__(self, baseurl=None):
        Loader.__init__(self)
        self._baseurl = baseurl
        self._sections = {}

    def getURL(self):
        return self._baseurl

    def getSection(self, pkg):
        return self._sections[pkg]

    def getInfo(self, pkg):
        return DebPackageInfo(pkg, self)

    def reset(self):
        Loader.reset(self)

    def load(self):
        Pkg = DebPackage
        Prv = DebProvides
        NPrv = DebNameProvides
        PreReq = DebPreRequires
        Req = DebRequires
        OrReq = DebOrRequires
        OrPreReq = DebOrPreRequires
        Upg = DebUpgrades
        Cnf = DebConflicts
        prog = iface.getProgress(self._cache)
        inst = self.getInstalled()
        for section, offset in self.getSections(prog):
            if inst:
                try:
                    want, flag, status = section.get("status", "").split()
                except ValueError:
                    continue
                if status != "installed":
                    continue

            name = section.get("package")
            version = section.get("version")

            prvargs = [(NPrv, name, version)]
            prvdict = {name: True}
            value = section.get("provides")
            if value:
                for prvname in value.split(","):
                    prvname = prvname.strip()
                    prvargs.append((Prv, intern(prvname), None))
                    prvdict[prvname] = True

            reqargs = []
            value = section.get("depends")
            if value:
                for relation in parserelations(value):
                    if type(relation) is not list:
                        n, r, v = relation
                        reqargs.append((Req, intern(n), r, v))
                    else:
                        reqargs.append((OrReq, tuple(relation)))
            value = section.get("pre-depends")
            if value:
                for relation in parserelations(value):
                    if type(relation) is not list:
                        n, r, v = relation
                        reqargs.append((PreReq, n, r, v))
                    else:
                        reqargs.append((OrPreReq, tuple(relation)))

            upgargs = [(Upg, name, '<', version)]

            cnfargs = []
            value = section.get("conflicts")
            if value:
                for relation in parserelations(value):
                    n, r, v = relation
                    cnfargs.append((Cnf, n, r, v))

            pkg = self.buildPackage((Pkg, name, version),
                                    prvargs, reqargs, upgargs, cnfargs)
            pkg.loaders[self] = offset
            self._sections[pkg] = intern(section.get("section", ""))

    def search(self, searcher):
        offsets = {}
        for pkg in self._packages:
            offsets[pkg.loaders[self]] = pkg

        for section, offset in self.getSections(Progress()):
            pkg = offsets.get(offset)
            if not pkg:
                continue

            ratio = 0
            if searcher.group:
                group = self._sections[pkg]
                for pat in searcher.group:
                    if pat.search(group):
                        ratio = 1
                        break
            if ratio == 1:
                searcher.addResult(pkg, ratio)
                continue

            if searcher.summary or searcher.description:
                toks = section.get("description", "").split("\n", 1)
                if len(toks) == 2:
                    summary, description = toks
                else:
                    summary, description = toks[0], ""

            if searcher.summary:
                for pat in searcher.summary:
                    if pat.search(summary):
                        ratio = 1
                        break
            if ratio == 1:
                searcher.addResult(pkg, ratio)
                continue
            if searcher.description:
                for pat in searcher.description:
                    if pat.search(description):
                        ratio = 1
                        break
            if ratio:
                searcher.addResult(pkg, ratio)

    def getSections(self, prog):
        raise TypeError, "Subclasses of DebTagLoader must " \
                         "implement the getSections() method"

    def getDict(self, pkg):
        raise TypeError, "Subclasses of DebTagLoader must " \
                         "implement the getDict() method"

    def getFileName(self, info):
        return self._baseurl
        raise TypeError, "Subclasses of DebTagLoader must " \
                         "implement the getFileName() method"


class DebTagFileLoader(DebTagLoader):

    def __init__(self, filename, baseurl=None):
        DebTagLoader.__init__(self, baseurl)
        self._filename = filename
        self._tagfile = TagFile(self._filename)

    def getLoadSteps(self):
        return os.path.getsize(self._filename)/800

    def getSections(self, prog):
        tf = self._tagfile
        tf.setOffset(0)
        lastoffset = offset = mod = 0
        while tf.advanceSection():
            yield tf, offset
            offset = tf.getOffset()
            div, mod = divmod(offset-lastoffset+mod, 800)
            prog.add(div)
            prog.show()
            lastoffset = offset

    def getDict(self, pkg):
        self._tagfile.setOffset(pkg.loaders[self])
        self._tagfile.advanceSection()
        return self._tagfile.copy()

    def getFileName(self, info):
        return info._dict.get("filename")

    def getSize(self, info):
        size = info._dict.get("size")
        if size:
            return long(size)
        return None

class DebDirLoader(DebTagLoader):

    def __init__(self, dir, filename=None):
        DebTagLoader.__init__(self, "file:///")
        self._dir = os.path.abspath(dir)
        if filename:
            self._filenames = [filename]
        else:
            self._filenames = [x for x in os.listdir(dir)
                                  if x.endswith(".deb")]

    def getLoadSteps(self):
        return len(self._filenames)

    def getSections(self, prog):
        for i, filename in enumerate(self._filenames):
            filepath = os.path.join(self._dir, filename)
            control = getControl(filepath)
            tf = TagFile(StringIO(control))
            tf.advanceSection()
            yield (tf, i)
            prog.add(1)
            prog.show()

    def getDict(self, pkg):
        filename = self._filenames[pkg.loaders[self]]
        filepath = os.path.join(self._dir, filename)
        control = getControl(filepath)
        tf = TagFile(StringIO(control))
        tf.advanceSection()
        return tf

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

class DebFileChannel(FileChannel):

    def fetch(self, fetcher, progress):
        digest = os.path.getmtime(self._filename)
        if digest == self._digest:
            return True
        self.removeLoaders()
        dirname, basename = os.path.split(self._filename)
        loader = DebDirLoader(dirname, basename)
        loader.setChannel(self)
        self._loaders.append(loader)
        self._digest = digest
        return True

def createFileChannel(filename):
    if filename.endswith(".deb"):
        return DebFileChannel(filename)
    return None

hooks.register("create-file-channel", createFileChannel)

def getControl(filename):
    from cStringIO import StringIO
    from tarfile import TarFile
    file = open(filename)
    if file.read(8) != "!<arch>\n":
        raise ValueError, "Invalid file"
    while True:
        name = file.read(16)
        date = file.read(12)
        uid = file.read(6)
        gid = file.read(6)
        mode = file.read(8)
        size = file.read(10)
        magic = file.read(2)
        if name == "control.tar.gz  ":
            data = file.read(int(size))
            sio = StringIO(data)
            control = TarFile.gzopen("", fileobj=sio).extractfile("control")
            return control.read()
        else:
            file.seek(int(size), 1)
    return None
