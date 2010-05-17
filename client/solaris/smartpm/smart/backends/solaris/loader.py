#
# Copyright (c) 2005--2010 Red Hat, Inc.
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
from smart.cache import Loader, PackageInfo
from smart.backends.solaris.base import *
from smart import *
import os, zipfile, re
import commands
import time
import string

NAMERE = re.compile("^([^ ]+) ?.*$")
PATCHRE = re.compile("^Patch: (.+) Obsoletes: *(.*) Requires: *(.*) Incompatibles: *(.*) Packages: (.*)$")
PNAMERE = re.compile("([^ ]+)-([0-9][0-9])")
#PDEPRE = re.compile("\n([PIR]+) ([^ \t]*)[ \t]*(.*)(?:\n[ \t]*\(([^\)]*)\)([^\n]*))?")
PDEPRE = re.compile("(?:\n|^)([PIR]+) ([^ \t\n]*)[ \t]*(.*)(?:\n[ \t]*\(([^\)]*)\)([^\n]*))?")
PKGTRANSRE = re.compile("Transferring <([^\>]*)>")
VERREV = re.compile("^(.+)-(.+)$")

class SolarisPackageInfo(PackageInfo):

    def __init__(self, package, info):
        PackageInfo.__init__(self, package)
        self._info = info

    def getGroup(self):
        return self._info.get("group", "")
        #return "Solaris"

    def getSummary(self):
        return self._info.get("summary", "")

    def getDescription(self):
        return self._info.get("description", "")

    def getURLs(self):
        info = self._info
        if "location" in info and "baseurl" in info:
            return [os.path.join(info["baseurl"], 
                                 info["location"],
                                 info["filename"])]
        return []

    def getPathList(self):
        return self._info.get("filelist", [])

class SolarisLoader(Loader):

    def __init__(self, baseurl=None):
        Loader.__init__(self)
        self._baseurl = baseurl

    def getInfoList(self):
        return []

    def load(self):

        prog = iface.getProgress(self._cache)

        for info in self.getInfoList():

            name = info["name"]
            version = info["version"]

            prvargs = info.get("provides", [])
            if not prvargs:
                prvargs = [(SolarisProvides, name, version)]
            if (SolarisProvides, name, version) not in prvargs:
                prvargs.append((SolarisProvides, name, version))
            m = VERREV.match(version)
            if m:
                if (SolarisProvides, name, m.groups()[0]) not in prvargs:
                    prvargs.append((SolarisProvides, name, m.groups()[0]))
            reqargs = info.get("depends", [])
            cnfargs = info.get("conflicts", [])
            upgargs = info.get("upgrades", [])
            upgargs.append((SolarisUpgrades, name, "<", version))

            pkg = self.buildPackage((SolarisPackage, name, version),
                                    prvargs, reqargs, upgargs, cnfargs)

            if self._baseurl:
                info["baseurl"] = self._baseurl
            
            pkg.loaders[self] = info

            prog.add(1)
            prog.show()

    def getInfo(self, pkg):
        return SolarisPackageInfo(pkg, pkg.loaders[self])

class SolarisDBLoader(SolarisLoader):

    def __init__(self, dir=None, pdir=None):
        SolarisLoader.__init__(self)
        if dir is None:
            dir = os.path.join(sysconf.get("solaris-root", "/"),
                               sysconf.get("solaris-packages-dir",
                                           "/var/sadm/pkg"))
        if pdir is None:
            pdir = os.path.join(sysconf.get("solaris-root", "/"),
                               sysconf.get("solaris-patches-dir",
                                           "/var/sadm/patch/"))
        self._dir = dir
        self._pdir = pdir
        self.setInstalled(True)
    
    def getInfoList(self):

        # Packages
        for entry in os.listdir(self._dir):
            pkgdir = os.path.join(self._dir, entry)
            pkgfile = pkgdir + "/pkginfo"
            depfile = pkgdir + "/install/depend"
            info = parsePackageFile(pkgfile)
            if info and info["name"]:
                info["location"] = None
                info["filename"] = None
                if os.path.isfile(depfile):
                    info2 = parseDependFile(depfile)
                    info["depends"] = info2["depends"]
                    info["conflicts"] = info2["conflicts"]
                yield info

        # Patches
#        pdb_file = os.path.join(self._pdir, ".patchDB")
#        if os.path.exists(pdb_file) and os.access(pdb_file, os.R_OK):
#            pdb = open(pdb_file)
#            for entry in pdb.readlines():
        # bug 165609: no file as .patchDB, so using my new found friend, showrev
        status, output = commands.getstatusoutput("showrev -p")
        if status == 0:
            if type(output) == type(""):
                output = output.splitlines()
            for entry in output:
                if not entry.startswith("Patch: "): 
                    continue
                info = parsePatchLine(entry.rstrip())
                if info and info["name"]:
                    info["location"] = None
                    info["filename"] = None
                    yield info

    def getLoadSteps(self):
        pkgs = len(os.listdir(self._dir))
        ptchs = 0
        pdb_file = os.path.join(self._pdir, ".patchDB")
        if os.path.exists(pdb_file) and os.access(pdb_file, os.R_OK):
            ptchs = len(open(pdb_file).readlines())
        return pkgs + ptchs


class SolarisDirLoader(SolarisLoader):

    def __init__(self, dir, filename=None):
        SolarisLoader.__init__(self, "file:///")
        self._dir = os.path.abspath(dir)
        if filename:
            self._filenames = [filename]
        else:
            self._filenames = os.listdir(dir)

    def getLoadSteps(self):
        return len(self._filenames)

    def getInfoList(self):
        phdr = "# PaCkAgE DaTaStReAm"

        packages = patches = []
        for filename in self._filenames:
            # FIXME (20050511): add tar'd patches support
            filepath = os.path.join(self._dir, filename)
            if os.path.isdir(filepath):
                if os.path.isfile(os.path.join(filepath, ".diPatch")):
                    patches.append(filepath)
                else:
                    packages.append(filepath)
            elif open(filepath).readline().startswith(phdr):
                packages.append(filepath)
            elif zipfile.is_zipfile(filepath):
                patches.append(filepath)

        for file in packages:
            (pkginfo, depend) = getPkgData(file)
            if not pkginfo: continue
            info = parsePackageInfo(pkginfo)
            if info and info["name"]:
                info["location"] = self._dir
                info["filename"] = file
                info2 = parseDepend(depend)
                info["depends"] = info2["depends"]
                info["conflicts"] = info2["conflicts"]
                yield info

        for file in patches:
            patchdata = getPatchData(file)
            if not patchdata: continue
            info = parsePatchData(patchdata)
            if info and info["name"]:
                info["location"] = self._dir
                info["filename"] = file
                yield info

            pass

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

class SolarisRHNLoader(SolarisLoader):

    def __init__(self, pkgs):
        SolarisLoader.__init__(self)
        self._pkgs = pkgs
    
    def getInfoList(self):
        infolst = []
        for pkg in self._pkgs:
            info = {"provides": [], "depends": [], "conflicts": [], "upgrades": []}
            #filepath = os.path.join(self._dir, filename)
            info["name"] = pkg[0]
            info["version"] = pkg[1] + "-" + pkg[2]
            info["group"] = pkg[3]
            if pkg[0].startswith("SUNW"):
                info["summary"] = pkg[0]
            else:
                info["summary"] = ""
            info["baseurl"] = "rhn://%s/" % (pkg[-1])
            info["location"] = "%s/%s/%s/%s" % (pkg[0], pkg[1], pkg[2], pkg[4])

            name = info["name"]
            extension = "pkg"
            if name.startswith("patch-solaris-") or \
               name.startswith("patch-cluster-solaris-"):
                extension = "zip"
            
            info["filename"] = "%s-%s-%s.%s.%s" % (pkg[0], pkg[1], pkg[2], pkg[4], extension)

            # Provides
            for item in pkg[6]:
                m = item.split(" ")
                name, rel, ver = "", "", None
                if len(m) == 3:
                    name, rel, ver = m
                if len(m) == 1:
                    name = m[0]
                if name:
                    if ver: 
                        ver = ver
                    else:
                        ver = None
                    info["provides"].append((SolarisProvides, name, ver))
            if (SolarisProvides, pkg[0], pkg[1]) not in info["provides"]:
                info["provides"].append((SolarisProvides, pkg[0], pkg[1]))
            if (SolarisProvides, pkg[0], info["version"]) not in info["provides"]:
                info["provides"].append((SolarisProvides, pkg[0], info["version"]))
            # Requires
            for item in pkg[7]:
                m = item.split(" ")
                name, rel, ver = "", "", ""
                if len(m) == 3:
                    name, rel, ver = m
                if len(m) == 1:
                    name = m[0]
                    rel = ""
                info["depends"].append((SolarisDepends, name, rel, ver))
            # Conflicts
            for item in pkg[8]:
                m = item.split(" ")
                name, rel, ver = "", "", ""
                if len(m) == 3:
                    name, rel, ver = m
                if len(m) == 1:
                    name = m[0]
                    rel = ""
                info["conflicts"].append((SolarisConflicts, name, rel, ver))
            # Obsoletes
            for item in pkg[9]:
                m = item.split(" ")
                name, rel, ver = "", "", ""
                if len(m) == 3:
                    name, rel, ver = m
                if len(m) == 1:
                    name = m[0]
                    rel = ""
                info["upgrades"].append((SolarisUpgrades, name, rel, ver))
                info["conflicts"].append((SolarisConflicts, name, rel, ver))
            infolst.append(info)

        return infolst

    def getLoadSteps(self):
        return len(self._pkgs)

def parsePackageFile(filename):
    file = open(filename)
    text = file.read()
    info = parsePackageInfo(text)
    file.close()
    return info

_ver_regex = re.compile("(?P<ver>[^,-]+)((-|,[ \t\S]*REV=)(?P<rev>[^,\s-]+))?")
_illegal_ver_regex = re.compile("[/\\\?\*:\|\"'<>\~\$\(\)[\]{}&=\s,]")

def parsePackageInfo(text):
    pkg = name = version = revision = group = pstamp = None
    description = ""
    text = text.split("\n")
    for line in text:
        if line.startswith("PKG="):
            pkg = line[4:].strip()
        elif line.startswith("NAME="):
            name = line[5:].strip()
        elif line.startswith("VERSION="):
            verrev = line[8:].strip()
            version_match = _ver_regex.match(verrev)
            if version_match:
                version = _sanitize_string_version(string.rstrip(version_match.group("ver"))) or "0"
                revision = version_match.group("rev")
        elif line.startswith("CATEGORY="):
            group = line[9:].strip()
        elif line.startswith("DESC="):
            description = line[5:].strip()
        elif line.startswith("PSTAMP="):
            pstamp = parse_pstamp_string(line[7:].strip())
    
    info = {}
    if not pkg or not name:
        return info
    
    info["name"] = pkg
    if pkg.startswith("SUNW"):
        info["summary"] = pkg
    else:
        m = NAMERE.match(name)
        if m:
            info["summary"] = m.groups()[0]
        else:
            info["summary"] = pkg
    if pstamp is not None:
        if revision is None:
            revision = "1"
        revision = revision + pstamp
    info["version"] = "%s-%s" % (version, revision)
    info["group"] = group
    if name != description:
        description = name + "\n" + description
    info["description"] = description
    # FIXME (20050414): Solaris, find filelist from another location
    #filelist = False
    #line = line.rstrip()
    #if line != "./":
    #    line = "/"+line
    #    if "filelist" in info:
    #        info["filelist"].append(line)
    #    else:
    #        info["filelist"] = [line]
    return info

# Good example: /var/sadm/pkg/SUNWj2dem/install/depend
def parseDependFile(filename):
    file = open(filename)
    text = file.read()
    file.close()
    return parseDepend(text)

def parseDepend(text):
    info = {"depends": [], "conflicts": [], "reverse": []}
    m = PDEPRE.findall(text)
    for item in m:
        ver = item[4]
        prvver = item[4]
        rel = "="
        if ver.find(",REV=") >= 0:
            prvver = ver.split(",REV=")[0]
            ver = prvver + '-' + ver.split(",REV=")[1]
        if not ver: rel = ""
        if item[0] == 'P':
            info["depends"].append((SolarisDepends, item[1], rel, prvver))
        if item[0] == 'I':
            info["conflicts"].append((SolarisConflicts, item[1], rel, prvver))
        #if item[0] == 'R':
        #    info["reverse"].append((SolarisProvides, item[1], "", ""))
    return info

# The following three functions come from solaris2mpm (the last one modified).
def _sanitize_string(str):
    """Replaces all non-alphanumeric chars with an underscore and returns the
       result.
    """
    result = ''
    underscore_mode = 0

    for c in str:
        if not c.isalnum():
            underscore_mode = 1
        else:
            if underscore_mode:
                result += '_'
                underscore_mode = 0
            result += c

    if underscore_mode:
        result += '_'

    return result

def _sanitize_string_version(str):
    """Replaces all none-valid version chars with an underscore and returns the
       result.
    """
    result = ''
    underscore_mode = 0

    for c in str:
       if _illegal_ver_regex.match(c) is not None:
            underscore_mode = 1
       else:
            if underscore_mode:
                result += '_'
                underscore_mode = 0
            result += c

    if underscore_mode:
        result += '_'

    return result
def parse_pstamp_string(pstamp):
    """
    This function convert a PSTAMP in the format

        nameYYMMDDHHMMSS

    into a release number of the format

        _PSTAMP_YYYY.MM.DD.HH.MM

    If the PSTAMP is of an unknown format,

        _PSTAMP_ + sanitized_version_of_the_string is returned.
    """

    if pstamp is None:
        return None

    delimiter = '_PSTAMP_'
    # Extract the last 12 characters from the pstamp.  This will represent the
    # date and time.
    date_time_stamp = pstamp[-12:]
    if len(date_time_stamp) != 12:
        return delimiter + _sanitize_string(pstamp)

    # Now break the date/time stamp into a time structure.
    date_time_struct = None
    try:
        date_time_struct = time.strptime(date_time_stamp, "%y%m%d%H%M%S")
    except ValueError, ve:
        return delimiter + _sanitize_string(pstamp)

    # Convert the structure into a string in the release number format.
    return delimiter + time.strftime("%Y.%m.%d.%H.%M", date_time_struct)

def parsePatchLine(line):
    # Pick out the fields
    m = PATCHRE.match(line)
    (patch, obsoletes, requires, conflicts, packages) = m.groups()

    # Change them to lists
    obsoletes = obsoletes and obsoletes.split(", ") or []
    requires = requires and requires.split(", ") or []
    
    # bug 170725: remove invalid output from showrev -p
    # thank you Richard from UBS
    my_temp = []
    for my_patch in requires:
       if re.match("\s+",my_patch):
         my_temp.append(my_patch)
       if my_patch == "":
         my_temp.append(my_patch)

    for my_patch in my_temp:
       requires.remove(my_patch)
       
    conflicts = conflicts and conflicts.split(", ") or []
    packages = packages and packages.split(", ") or []

    info = createPatchInfo(patch, packages, requires, obsoletes, conflicts)

    return info

# Grok a concatenated blob of all the pkginfo files from a patch
def parsePatchData(text):
    patch = name = version = None
    requires = obsoletes = conflicts = None
    packages = []
    text = text.split("\n")
    for line in text:
        if line.startswith("SUNW_PATCHID="):
            patch = line[13:].strip()
        elif line.startswith("SUNW_REQUIRES="):
            requires = line[14:].strip()
            requires = requires and requires.split(" ") or []
        elif line.startswith("SUNW_OBSOLETES="):
            obsoletes = line[15:].strip()
            obsoletes = obsoletes and obsoletes.split(" ") or []
        elif line.startswith("SUNW_INCOMPAT="):
            conflicts = line[15:].strip()
            conflicts = conflicts and conflicts.split(" ") or []
        elif line.startswith("PKG="):
            packages.append(line[4:].strip())
    
    if not patch:
        return {}
   
    info = createPatchInfo(patch, packages, requires, obsoletes, conflicts)

    return info

def createPatchInfo(patch, packages, requires, obsoletes, conflicts):
    info = {"provides": [], "depends": [], "conflicts": [], "upgrades": []}
    m = PNAMERE.match(patch)
    if m:
        (name, prvversion) = m.groups()
    else: # some custom patch with unkown format of SUNW_PATCHID, let fake up something
        name = patch
        prvversion = '1'
    name = "patch-solaris-" + name
    version = prvversion + "-1"
    info["name"] = name
    info["version"] = version
    info["summary"] = "Solaris Patch %s" % patch
    info["group"] = "solaris patch"
    info["description"] = """Patch %s\nPatches: %s""" % (patch, packages)

    info["provides"].append((SolarisProvides, name, version))
    info["provides"].append((SolarisProvides, name, prvversion))
    for item in requires:
        m = PNAMERE.match(item)
        (name, version) = m.groups()
        name = "patch-solaris-" + name
        info["depends"].append((SolarisDepends, name, ">=", version))
    for item in obsoletes:
        m = PNAMERE.match(item)
        (name, version) = m.groups()
        name = "patch-solaris-" + name
        info["upgrades"].append((SolarisUpgrades, name, "<=", version))
        info["provides"].append((SolarisProvides, name, version))
    for item in (conflicts + obsoletes):
        m = PNAMERE.match(item)
        (name, version) = m.groups()
        name = "patch-solaris-" + name
        info["conflicts"].append((SolarisConflicts, name, "<=", version))
    # FIXME (20050510): Solaris: what to do with package list
    return info

# The package info format is a cpio archive once
# chop off the header up to "TRAILER!!!<NULL...>
# Then you can use:
# /usr/bin/cpio -icdumD -C 512
# to dump the internal contents.
# For now this uses pkgtrans to extract the info
#
# returns the text of the pkginfo file and
# the text of the depend file (if it exists)
def getPkgData(filename):

    pkginfo = depend = tdir = ""

    try:
        if os.path.isdir(filename):
            pkgdir = filename
        else:
            import tempfile
            import subprocess
            tdir = tempfile.mkdtemp()
            c = subprocess.Popen(("pkgtrans", filename, tdir, "all"),
                    stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE, close_fds=True)
            ret = c.wait()
            if ret: return (pkginfo, depend)
            m = PKGTRANSRE.match(c.stderr.read())
            if not m: return (pkginfo, depend)
            pkgname = m.groups()[0]
            pkgdir = os.path.join(tdir, pkgname)

        finfo = os.path.join(pkgdir, "pkginfo")
        fdep = os.path.join(pkgdir, "install/depend")
        if os.path.isfile(finfo):
            pkginfo = open(finfo).read()
        else:
            return (pkginfo, depend)

        if os.path.isfile(fdep):
            depend = open(fdep).read()

        return (pkginfo, depend)

    finally:
        # Cleanup temp dir
        if tdir and tdir.startswith("/tmp/"):
            for root, dirs, files in os.walk(tdir, topdown=False):
                for name in files:
                    os.remove(os.path.join(root, name))
                for name in dirs:
                    os.rmdir(os.path.join(root, name))
            os.rmdir(tdir)


# Patches are usually delivered as zip files but can also just be
# a "filesystem" (directory)
#
# concatenates the all the pkginfo files into a single
# text blob and returns it.
def getPatchData(filename):

    data = ""

    if os.path.isdir(filename):
        for pkg in os.listdir(filename):
            info = os.path.join(filename, pkg, "pkginfo")
            if os.path.isfile(info):
                data = data + open(info).read()
                data = data + "\n"
    elif zipfile.is_zipfile(filename):
        z = zipfile.ZipFile(filename)

        for file in z.namelist():
            if not file.endswith("pkginfo"): continue
            data = data + z.read(file)
            data = data + "\n"
    
    return data


# vim:ts=4:sw=4:et
