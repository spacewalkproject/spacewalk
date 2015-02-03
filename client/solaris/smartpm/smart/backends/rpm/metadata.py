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
from smart.cache import PackageInfo, Loader
from smart.backends.rpm.base import *
from smart import *
import posixpath
import locale
import rpm
import os

from xml.parsers import expat

NS_COMMON    = "http://linux.duke.edu/metadata/common"
NS_RPM       = "http://linux.duke.edu/metadata/rpm"
NS_FILELISTS = "http://linux.duke.edu/metadata/filelists"

BYTESPERPKG = 3000

class RPMMetaDataPackageInfo(PackageInfo):

    def __init__(self, package, loader, info):
        PackageInfo.__init__(self, package)
        self._loader = loader
        self._info = info

    def getURLs(self):
        url = self._info.get("location")
        if url:
            return [posixpath.join(self._loader._baseurl, url)]
        return []

    def getInstalledSize(self):
        return self._info.get("installed_size")

    def getSize(self, url):
        return self._info.get("size")

    def getMD5(self, url):
        return self._info.get("md5")

    def getSHA(self, url):
        return self._info.get("sha")

    def getDescription(self):
        return self._info.get("description", "")

    def getSummary(self):
        return self._info.get("summary", "")

    def getGroup(self):
        return self._info.get("group", "")


class RPMMetaDataLoader(Loader):

    __stateversion__ = Loader.__stateversion__+1

    def __init__(self, filename, filelistsname, baseurl):
        Loader.__init__(self)
        self._filename = filename
        self._filelistsname = filelistsname
        self._baseurl = baseurl
        self._fileprovides = {}
        self._pkgids = {}

    def reset(self):
        Loader.reset(self)
        self._fileprovides.clear()

    def loadFileProvides(self, fndict):
        bfp = self.buildFileProvides
        parsed = False
        for fn in fndict:
            if fn not in self._fileprovides:
                if not parsed:
                    parsed = True
                    self._fileprovides.clear()
                    XMLFileListsParser(self).parse(fndict)
                    if fn not in self._fileprovides:
                        pkgs = self._fileprovides[fn] = ()
                    else:
                        pkgs = self._fileprovides[fn]
                else:
                    pkgs = self._fileprovides[fn] = ()
            else:
                pkgs = self._fileprovides[fn]

            if pkgs:
                for pkg in pkgs:
                    bfp(pkg, (RPMProvides, fn, None))

    def getInfo(self, pkg):
        return RPMMetaDataPackageInfo(pkg, self, pkg.loaders[self])

    def getLoadSteps(self):
        return os.path.getsize(self._filename)/BYTESPERPKG

    def load(self):
        XMLParser(self).parse()


class XMLParser(object):

    COMPMAP = { "EQ":"=", "LT":"<", "LE":"<=", "GT":">", "GE":">="}

    def __init__(self, loader):
        self._loader = loader

        self._lastoffset = 0
        self._mod = 0
        self._progress = None

        self._queue = []
        self._data = ""

        self._name = None
        self._version = None
        self._arch = None
        self._pkgid = None

        self._reqdict = {}
        self._prvdict = {}
        self._upgdict = {}
        self._cnfdict = {}
        self._filedict = {}

        self._info = {}

        self._skip = None

        self._starthandler = {}
        self._endhandler = {}

        for ns, attr in ((NS_COMMON, "MetaData"),
                         (NS_COMMON, "Package"),
                         (NS_COMMON, "Name"),
                         (NS_COMMON, "Arch"),
                         (NS_COMMON, "Version"),
                         (NS_COMMON, "Summary"),
                         (NS_COMMON, "Description"),
                         (NS_COMMON, "Size"),
                         (NS_COMMON, "Location"),
                         (NS_COMMON, "Format"),
                         (NS_COMMON, "CheckSum"),
                         (NS_COMMON, "File"),
                         (NS_RPM, "Group"),
                         (NS_RPM, "Entry"),
                         (NS_RPM, "Requires"),
                         (NS_RPM, "Provides"),
                         (NS_RPM, "Conflicts"),
                         (NS_RPM, "Obsoletes")):
            handlername = "handle%sStart" % attr
            handler = getattr(self, handlername, None)
            nsattr = "%s %s" % (ns, attr.lower())
            if handler:
                self._starthandler[nsattr] = handler
            handlername = "handle%sEnd" % attr
            handler = getattr(self, handlername, None)
            if handler:
                self._endhandler[nsattr] = handler
            setattr(self, attr.upper(), nsattr)

    def resetPackage(self):
        self._data = ""
        self._name = None
        self._version = None
        self._arch = None
        self._pkgid = None
        self._reqdict.clear()
        self._prvdict.clear()
        self._upgdict.clear()
        self._cnfdict.clear()
        self._filedict.clear()
        # Do not clear it. pkg.loaders has a reference.
        self._info = {}

    def startElement(self, name, attrs):
        if self._skip:
            return
        handler = self._starthandler.get(name)
        if handler:
            handler(name, attrs)
        self._data = ""
        self._queue.append((name, attrs))

    def endElement(self, name):
        if self._skip:
            if name == self._skip:
                self._skip = None
                _name = None
                while _name != name:
                    _name, attrs = self._queue.pop()
            return
        _name, attrs = self._queue.pop()
        assert _name == name
        handler = self._endhandler.get(name)
        if handler:
            handler(name, attrs, self._data)
        self._data = ""

    def charData(self, data):
        self._data += data

    def handleArchEnd(self, name, attrs, data):
        if rpm.archscore(data) == 0:
            self._skip = self.PACKAGE
        else:
            self._arch = data

    def handleNameEnd(self, name, attrs, data):
        self._name = data

    def handleVersionEnd(self, name, attrs, data):
        e = attrs.get("epoch")
        if e and e != "0":
            self._version = "%s:%s-%s" % (e, attrs.get("ver"), attrs.get("rel"))
        else:
            self._version = "%s-%s" % (attrs.get("ver"), attrs.get("rel"))

    def handleSummaryEnd(self, name, attrs, data):
        self._info["summary"] = data

    def handleDescriptionEnd(self, name, attrs, data):
        self._info["description"] = data

    def handleSizeEnd(self, name, attrs, data):
        self._info["size"] = int(attrs.get("package"))
        self._info["installed_size"] = int(attrs.get("installed"))

    def handleCheckSumEnd(self, name, attrs, data):
        self._info[attrs.get("type")] = data
        if attrs.get("pkgid") == "YES":
            self._pkgid = data

    def handleLocationEnd(self, name, attrs, data):
        self._info["location"] = attrs.get("href")

    def handleGroupEnd(self, name, attrs, data):
        self._info["group"] = intern(data)

    def handleEntryEnd(self, name, attrs, data):
        name = attrs.get("name")
        if not name or name[:7] in ("rpmlib(", "config("):
            return
        if "ver" in attrs:
            e = attrs.get("epoch")
            v = attrs.get("ver")
            r = attrs.get("rel")
            version = v
            if e and e != "0":
                version = "%s:%s" % (e, version)
            if r:
                version = "%s-%s" % (version, r)
            if "flags" in attrs:
                relation = self.COMPMAP.get(attrs.get("flags"))
            else:
                relation = None
        else:
            version = None
            relation = None
        lastname = self._queue[-1][0]
        if lastname == self.REQUIRES:
            if attrs.get("pre") == "1":
                self._reqdict[(RPMPreRequires, name, relation, version)] = True
            else:
                self._reqdict[(RPMRequires, name, relation, version)] = True
        elif lastname == self.PROVIDES:
            if name[0] == "/":
                self._filedict[name] = True
            else:
                if name == self._name and version == self._version:
                    version = "%s@%s" % (version, self._arch)
                    Prv = RPMNameProvides
                else:
                    Prv = RPMProvides
                self._prvdict[(Prv, name, version)] = True
        elif lastname == self.OBSOLETES:
            tup = (RPMObsoletes, name, relation, version)
            self._upgdict[tup] = True
            self._cnfdict[tup] = True
        elif lastname == self.CONFLICTS:
            self._cnfdict[(RPMConflicts, name, relation, version)] = True

    def handleFileEnd(self, name, attrs, data):
        self._filedict[data] = True

    def handlePackageStart(self, name, attrs):
        if attrs.get("type") != "rpm":
            self._skip = self.PACKAGE

    def handlePackageEnd(self, name, attrs, data):
        name = self._name
        version = self._version
        versionarch = "%s@%s" % (version, self._arch)

        self._upgdict[(RPMObsoletes, name, '<', versionarch)] = True

        reqargs = [x for x in self._reqdict
                   if (RPMProvides, x[1], x[3]) not in self._prvdict]
        prvargs = self._prvdict.keys()
        cnfargs = self._cnfdict.keys()
        upgargs = self._upgdict.keys()

        pkg = self._loader.buildPackage((RPMPackage, name, versionarch),
                                        prvargs, reqargs, upgargs, cnfargs)
        pkg.loaders[self._loader] = self._info

        if self._filedict:
            fileprovides = self._loader._fileprovides
            for filename in self._filedict:
                lst = fileprovides.get(filename)
                if not lst:
                    fileprovides[filename] = [pkg]
                else:
                    lst.append(pkg)

        if self._pkgid:
            self._loader._pkgids[self._pkgid] = pkg

        self.resetPackage()

        self.updateProgress()

    def updateProgress(self):
        offset = self._file.tell()
        div, self._mod = divmod(offset-self._lastoffset+self._mod, BYTESPERPKG)
        self._lastoffset = offset
        self._progress.add(div)
        self._progress.show()

    def parse(self):
        parser = expat.ParserCreate(namespace_separator=" ")
        parser.StartElementHandler = self.startElement
        parser.EndElementHandler = self.endElement
        parser.CharacterDataHandler = self.charData
        parser.returns_unicode = False

        self._lastoffset = 0
        self._mod = 0
        self._progress = iface.getProgress(self._loader._cache)

        self._file = open(self._loader._filename)
        try:
            parser.ParseFile(self._file)
        except expat.ExpatError, e:
            iface.error(_("Error parsing %s: %s") %
                        (self._loader._filename, unicode(e)))
        self.updateProgress()
        self._file.close()

class XMLFileListsParser(object):

    def __init__(self, loader):
        self._loader = loader

        self._queue = []
        self._data = ""

        self._fndict = None
        self._pkgid = None

        self._skip = None

        self._starthandler = {}
        self._endhandler = {}

        for ns, attr in ((NS_FILELISTS, "MetaData"),
                         (NS_FILELISTS, "Package"),
                         (NS_FILELISTS, "File")):
            handlername = "handle%sStart" % attr
            handler = getattr(self, handlername, None)
            nsattr = "%s %s" % (ns, attr.lower())
            if handler:
                self._starthandler[nsattr] = handler
            handlername = "handle%sEnd" % attr
            handler = getattr(self, handlername, None)
            if handler:
                self._endhandler[nsattr] = handler
            setattr(self, attr.upper(), nsattr)

    def startElement(self, name, attrs):
        if self._skip:
            return
        handler = self._starthandler.get(name)
        if handler:
            handler(name, attrs)
        self._data = ""
        self._queue.append((name, attrs))

    def endElement(self, name):
        if self._skip:
            if name == self._skip:
                self._skip = None
                _name = None
                while _name != name:
                    _name, attrs = self._queue.pop()
            return
        _name, attrs = self._queue.pop()
        assert _name == name
        handler = self._endhandler.get(name)
        if handler:
            handler(name, attrs, self._data)
        self._data = ""

    def charData(self, data):
        self._data += data

    def handlePackageStart(self, name, attrs):
        if attrs.get("arch") == "src":
            self._skip = self.PACKAGE
        else:
            self._pkg = self._pkgids.get(attrs.get("pkgid"))
            if not self._pkg:
                self._skip = self.PACKAGE

    def handleFileEnd(self, name, attrs, data):
        if data in self._fndict:
            pkgs = self._fileprovides.get(data)
            if not pkgs:
                self._fileprovides[data] = [self._pkg]
            else:
                pkgs.append(self._pkg)

    def parse(self, fndict):
        self._fndict = fndict

        self._fileprovides = self._loader._fileprovides
        self._pkgids = self._loader._pkgids

        parser = expat.ParserCreate(namespace_separator=" ")
        parser.StartElementHandler = self.startElement
        parser.EndElementHandler = self.endElement
        parser.CharacterDataHandler = self.charData
        parser.returns_unicode = True

        file = open(self._loader._filelistsname)
        try:
            parser.ParseFile(file)
        except expat.ExpatError, e:
            iface.error(_("Error parsing %s: %s") %
                        (self._loader._filelistsname, unicode(e)))
        file.close()
