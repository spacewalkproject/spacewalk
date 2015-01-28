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
from smart.util.strtools import isGlob
from smart.option import OptionParser
from smart.cache import Provides, PreRequires, Package
from smart import *
import tempfile
import fnmatch
import string
import sys
import os
import re

USAGE=_("smart query [options] [package] ...")

DESCRIPTION=_("""
This command allows querying the known packages in many
different ways. Check also the 'search' command.
""")

EXAMPLES=_("""
smart query pkgname
smart query '*kgnam*'
smart query pkgname-1.0
smart query pkgname --show-requires
smart query --requires libpkg.so --show-providedby
smart query --installed
smart query --summary ldap
""")

def parse_options(argv, help=None):
    if help:
        parser = OptionParser(help=help)
    else:
        parser = OptionParser(usage=USAGE,
                              description=DESCRIPTION,
                              examples=EXAMPLES)
    parser.add_option("--installed", action="store_true",
                      help=_("consider only installed packages"))
    parser.add_option("--provides", action="append", default=[], metavar="DEP",
                      help=_("show only packages providing the given "
                             "dependency"))
    parser.add_option("--requires", action="append", default=[], metavar="DEP",
                      help=_("show only packages requiring the given "
                             "dependency"))
    parser.add_option("--conflicts", action="append", default=[], metavar="DEP",
                      help=_("show only packages conflicting with the given "
                             "dependency"))
    parser.add_option("--upgrades", action="append", default=[], metavar="DEP",
                      help=_("show only packages upgrading the given "
                             "dependency"))
    parser.add_option("--name", action="append", default=[], metavar="STR",
                      help=_("show only packages which match given name"))
    parser.add_option("--summary", action="append", default=[], metavar="STR",
                      help=_("show only packages which match given summary"))
    parser.add_option("--description", action="append", default=[], metavar="STR",
                      help=_("show only packages which match given "
                             "description"))
    parser.add_option("--path", action="append", default=[], metavar="STR",
                      help=_("show only packages which include the given "
                             "path in the available meta information"))
    parser.add_option("--url", action="append", default=[], metavar="STR",
                      help=_("show only packages which include the given "
                             "reference url in the available meta "
                             "information"))
    parser.add_option("--hide-version", action="store_true",
                      help=_("hide package version"))
    parser.add_option("--show-summary", action="store_true",
                      help=_("show package summaries"))
    parser.add_option("--show-provides", action="store_true",
                      help=_("show provides for the given packages"))
    parser.add_option("--show-requires", action="store_true",
                      help=_("show requires for the given packages"))
    parser.add_option("--show-prerequires", action="store_true",
                      help=_("show requires selecting only pre-dependencies"))
    parser.add_option("--show-upgrades", action="store_true",
                      help=_("show upgrades for the given packages"))
    parser.add_option("--show-conflicts", action="store_true",
                      help=_("show conflicts for the given packages"))
    parser.add_option("--show-providedby", action="store_true",
                      help=_("show packages providing dependencies"))
    parser.add_option("--show-requiredby", action="store_true",
                      help=_("show packages requiring provided information"))
    parser.add_option("--show-upgradedby", action="store_true",
                      help=_("show packages upgrading provided information"))
    parser.add_option("--show-conflictedby", action="store_true",
                      help=_("show packages conflicting with provided "
                             "information"))
    parser.add_option("--show-priority", action="store_true",
                      help=_("show package priority"))
    parser.add_option("--show-channels", action="store_true",
                      help=_("show channels that include this package"))
    parser.add_option("--show-all", action="store_true",
                      help=_("enable all --show-* options"))
    parser.add_option("--format", action="store", default="text",
                      metavar="FMT", help=_("change output format"))
    parser.add_option("--output", action="store", metavar="FILE",
                      help=_("redirect output to given filename"))
    opts, args = parser.parse_args(argv)
    opts.args = args
    if opts.show_all:
        for attr in dir(opts):
            if attr.startswith("show_"):
                setattr(opts, attr, True)
    return opts

def main(ctrl, opts, reloadchannels=True):

    if reloadchannels:
        ctrl.reloadChannels()

    cache = ctrl.getCache()
    if not opts.args:
        packages = cache.getPackages()[:]
    else:
        packages = {}
        for arg in opts.args:
            ratio, results, suggestions = ctrl.search(arg, addprovides=False)
            if not results:
                if suggestions:
                    dct = {}
                    for r, obj in suggestions:
                        if isinstance(obj, Package):
                            dct[obj] = True
                        else:
                            dct.update(dct.fromkeys(obj.packages, True))
                    raise Error, _("'%s' matches no packages. "
                                   "Suggestions:\n%s") % \
                                 (arg, "\n".join(["    "+str(x) for x in dct]))
                else:
                    raise Error, _("'%s' matches no packages") % arg
            else:
                for obj in results:
                    if isinstance(obj, Package):
                        packages[obj] = True
                    else:
                        packages.update(dict.fromkeys(obj.packages, True))
        packages = packages.keys()

    if opts.installed:
        packages = [pkg for pkg in packages if pkg.installed]

    whoprovides = []
    for name in opts.provides:
        if '=' in name:
            name, version = name.split('=')
        else:
            version = None
        if isGlob(name):
            p = re.compile(fnmatch.translate(name), re.I)
            for prv in cache.getProvides():
                if p.match(prv.name):
                    whoprovides.append(Provides(prv.name, version))
        else:
            whoprovides.append(Provides(name, version))
    whorequires = []
    for name in opts.requires:
        if '=' in name:
            name, version = name.split('=')
        else:
            version = None
        if isGlob(name):
            p = re.compile(fnmatch.translate(name), re.I)
            for req in cache.getRequires():
                if p.match(req.name):
                    whorequires.append(Provides(req.name, version))
        else:
            whorequires.append(Provides(name, version))
    whoupgrades = []
    for name in opts.upgrades:
        if '=' in name:
            name, version = name.split('=')
        else:
            version = None
        if isGlob(name):
            p = re.compile(fnmatch.translate(name), re.I)
            for upg in cache.getUpgrades():
                if p.match(upg.name):
                    whoupgrades.append(Provides(upg.name, version))
        else:
            whoupgrades.append(Provides(name, version))
    whoconflicts = []
    for name in opts.conflicts:
        if '=' in name:
            name, version = name.split('=')
        else:
            version = None
        if isGlob(name):
            p = re.compile(fnmatch.translate(name), re.I)
            for cnf in cache.getConflicts():
                if p.match(cnf.name):
                    whoconflicts.append(Provides(cnf.name, version))
        else:
            whoconflicts.append(Provides(name, version))

    if whoprovides or whorequires or whoupgrades or whoconflicts:
        newpackages = {}
        for whoprv in whoprovides:
            for prv in cache.getProvides(whoprv.name):
                if not whoprv.version or prv.name == prv.version:
                    for pkg in prv.packages:
                        if pkg in packages:
                            newpackages[pkg] = True
        for whoreq in whorequires:
            for req in cache.getRequires(whoreq.name):
                if req.matches(whoreq):
                    for pkg in req.packages:
                        if pkg in packages:
                            newpackages[pkg] = True
        for whoupg in whoupgrades:
            for upg in cache.getUpgrades(whoupg.name):
                if upg.matches(whoupg):
                    for pkg in upg.packages:
                        if pkg in packages:
                            newpackages[pkg] = True
        for whocnf in whoconflicts:
            for cnf in cache.getConflicts(whocnf.name):
                if cnf.matches(whocnf):
                    for pkg in cnf.packages:
                        if pkg in packages:
                            newpackages[pkg] = True
        packages = newpackages.keys()

    hasname = []
    for token in opts.name:
        token = fnmatch.translate(token)[:-1].replace(r"\ ", " ")
        token = r"\s+".join(token.split())
        hasname.append(re.compile(token, re.I))
    hassummary = []
    for token in opts.summary:
        token = fnmatch.translate(token)[:-1].replace(r"\ ", " ")
        token = r"\s+".join(token.split())
        hassummary.append(re.compile(token, re.I))
    hasdescription = []
    for token in opts.description:
        token = fnmatch.translate(token)[:-1].replace(r"\ ", " ")
        token = r"\s+".join(token.split())
        hasdescription.append(re.compile(token, re.I))
    haspath = []
    for token in opts.path:
        token = fnmatch.translate(token).replace(r"\ ", " ")
        haspath.append(re.compile(token, re.I))
    hasurl = []
    for token in opts.url:
        token = fnmatch.translate(token)[:-1].replace(r"\ ", " ")
        hasurl.append(re.compile(token, re.I))

    if hasname or hassummary or hasdescription or haspath:
        newpackages = {}
        needsinfo = hassummary or hasdescription or haspath or hasurl
        for pkg in cache.getPackages():
            if hasname:
                for pattern in hasname:
                    if pattern.search(pkg.name):
                        newpackages[pkg] = True
            if needsinfo:
                info = pkg.loaders.keys()[0].getInfo(pkg)
                if hassummary:
                    for pattern in hassummary:
                        if pattern.search(info.getSummary()):
                            newpackages[pkg] = True
                if hasdescription:
                    for pattern in hasdescription:
                        if pattern.search(info.getDescription()):
                            newpackages[pkg] = True
                if haspath:
                    for pattern in haspath:
                        for path in info.getPathList():
                            if pattern.match(path):
                                newpackages[pkg] = True
                if hasurl:
                    for pattern in hasurl:
                        for url in info.getReferenceURLs():
                            if pattern.match(url):
                                newpackages[pkg] = True
        packages = newpackages.keys()


    format = opts.format.lower()+"output"
    for attr, value in globals().items():
        if attr.lower() == format:
            output = value(opts)
            break
    else:
        raise Error, "Output format unknown"

    output.startGrabOutput()

    output.start()

    packages.sort()
    for pkg in packages:
        output.showPackage(pkg)
        if pkg.provides and (opts.show_provides or whoprovides):
            pkg.provides.sort()
            first = True
            for prv in pkg.provides:
                if whoprovides:
                    for whoprv in whoprovides:
                        if (prv.name == whoprv.name and
                            (not whoprv.version or
                             prv.version == whoprv.version)):
                            break
                    else:
                        continue
                output.showProvides(pkg, prv)
                if opts.show_requiredby and prv.requiredby:
                    for req in prv.requiredby:
                        req.packages.sort()
                        for reqpkg in req.packages:
                            if opts.installed and not reqpkg.installed:
                                continue
                            output.showRequiredBy(pkg, prv, req, reqpkg)
                if opts.show_upgradedby and prv.upgradedby:
                    for upg in prv.upgradedby:
                        upg.packages.sort()
                        for upgpkg in upg.packages:
                            if opts.installed and not upgpkg.installed:
                                continue
                            output.showUpgradedBy(pkg, prv, upg, upgpkg)
                if opts.show_conflictedby and prv.conflictedby:
                    for cnf in prv.conflictedby:
                        cnf.packages.sort()
                        for cnfpkg in cnf.packages:
                            if cnfpkg is pkg:
                                continue
                            if opts.installed and not cnfpkg.installed:
                                continue
                            output.showConflictedBy(pkg, prv, cnf, cnfpkg)
        if pkg.requires and (opts.show_requires or opts.show_prerequires):
            pkg.requires.sort()
            first = True
            for req in pkg.requires:
                if opts.show_prerequires and not isinstance(req, PreRequires):
                    continue
                if whorequires:
                    matchnames = req.getMatchNames()
                    for whoreq in whorequires:
                        if whoreq.name in matchnames and req.matches(whoreq):
                            break
                    else:
                        continue
                output.showRequires(pkg, req)
                if opts.show_providedby and req.providedby:
                    for prv in req.providedby:
                        prv.packages.sort()
                        for prvpkg in prv.packages:
                            if opts.installed and not prvpkg.installed:
                                continue
                            output.showRequiresProvidedBy(pkg, req,
                                                          prv, prvpkg)
        if pkg.upgrades and opts.show_upgrades:
            pkg.upgrades.sort()
            first = True
            for upg in pkg.upgrades:
                if whoupgrades:
                    matchnames = upg.getMatchNames()
                    for whoupg in whoupgrades:
                        if whoupg.name in matchnames and upg.matches(whoupg):
                            break
                    else:
                        continue
                output.showUpgrades(pkg, upg)
                if opts.show_providedby and upg.providedby:
                    for prv in upg.providedby:
                        prv.packages.sort()
                        for prvpkg in prv.packages:
                            if opts.installed and not prvpkg.installed:
                                continue
                            output.showUpgradesProvidedBy(pkg, upg,
                                                          prv, prvpkg)
        if pkg.conflicts and opts.show_conflicts:
            pkg.conflicts.sort()
            first = True
            for cnf in pkg.conflicts:
                if whoconflicts:
                    matchnames = cnf.getMatchNames()
                    for whocnf in whoconflicts:
                        if whocnf.name in matchnames and cnf.matches(whocnf):
                            break
                    else:
                        continue
                output.showConflicts(pkg, cnf)
                if opts.show_providedby and cnf.providedby:
                    for prv in cnf.providedby:
                        prv.packages.sort()
                        for prvpkg in prv.packages:
                            if prvpkg is pkg:
                                continue
                            if opts.installed and not prvpkg.installed:
                                continue
                            output.showConflictsProvidedBy(pkg, upg,
                                                           prv, prvpkg)

    output.end()

    output.stopGrabOutput()


class NullOutput(object):

    def __init__(self, opts):
        self.opts = opts
        self.output = None
        self.__sys_stdout = None

    def start(self):
        pass

    def end(self):
        pass

    def startGrabOutput(self, output=None):
        if output or self.opts.output:
            self.output = output or open(self.opts.output, "w")
            self.__sys_stdout = sys.stdout
            sys.stdout = self.output
        else:
            self.output = sys.stdout
            self.__sys_stdout = None

    def stopGrabOutput(self):
        if self.__sys_stdout:
            sys.stdout = self.__sys_stdout
            self.__sys_stdout = None
            if self.output is not sys.stdout:
                self.output.close()
        self.output = None

    def showPackage(self, pkg):
        pass

    def showProvides(self, pkg, prv):
        pass

    def showRequiredBy(self, pkg, prv, req, reqpkg):
        pass

    def showUpgradedBy(self, pkg, prv, upg, upgpkg):
        pass

    def showConflictedBy(self, pkg, prv, cnf, cnfpkg):
        pass

    def showRequires(self, pkg, req):
        pass

    def showRequiresProvidedBy(self, pkg, req, prv, prvpkg):
        pass

    def showUpgrades(self, pkg, upg):
        pass

    def showUpgradesProvidedBy(self, pkg, upg, prv, prvpkg):
        pass

    def showConflicts(self, pkg, cnf):
        pass

    def showConflictsProvidedBy(self, pkg, cnf, prv, prvpkg):
        pass


class TextOutput(NullOutput):

    def end(self):
        print

    def showPackage(self, pkg):
        if self.opts.hide_version:
            print pkg.name,
        else:
            print pkg,
        if self.opts.show_priority:
            print "{%s}" % pkg.getPriority(),
        if self.opts.show_channels:
            channels = []
            for loader in pkg.loaders:
                channels.append(loader.getChannel().getAlias())
            channels.sort()
            print "[%s]" % ', '.join(channels),
        if self.opts.show_summary:
            info = pkg.loaders.keys()[0].getInfo(pkg)
            print "-", info.getSummary(),
        print

        self._firstprovides = True
        self._firstrequiredby = True
        self._firstupgradedby = True
        self._firstconflictedby = True
        self._firstrequires = True
        self._firstrequiresprovidedby = True
        self._firstupgrades = True
        self._firstupgradesprovidedby = True
        self._firstconflicts = True
        self._firstconflictsprovidedby = True

    def showProvides(self, pkg, prv):
        if self._firstprovides:
            self._firstprovides = False
            print " ", _("Provides:")
        print "   ", prv

    def showRequiredBy(self, pkg, prv, req, reqpkg):
        if self._firstrequiredby:
            self._firstrequiredby = False
            print "     ", _("Required By:")
        if isinstance(req, PreRequires):
            print "       ", "%s (%s) [%s]" % \
                  (reqpkg, prv, _("pre"))
        else:
            if self.opts.hide_version:
                name = reqpkg.name
            else:
                name = str(reqpkg)
            print "       ", "%s (%s)" % (name, prv)

    def showUpgradedBy(self, pkg, prv, upg, upgpkg):
        if self._firstupgradedby:
            self._firstupgradedby = False
            print "     ", _("Upgraded By:")
        if self.opts.hide_version:
            name = upgpkg.name
        else:
            name = str(upgpkg)
        print "       ", "%s (%s)" % (name, prv)

    def showConflictedBy(self, pkg, prv, cnf, cnfpkg):
        if self._firstconflictedby:
            self._firstconflictedby = False
            print "     ", _("Conflicted By:")
        if self.opts.hide_version:
            name = cnfpkg.name
        else:
            name = str(cnfpkg)
        print "       ", "%s (%s)" % (name, prv)

    def showRequires(self, pkg, req):
        if self._firstrequires:
            self._firstrequires = False
            print " ", _("Requires:")
        if isinstance(req, PreRequires):
            print "   ", req, "[%s]" % _("pre")
        else:
            print "   ", req

    def showRequiresProvidedBy(self, pkg, req, prv, prvpkg):
        if self._firstrequiresprovidedby:
            self._firstrequiresprovidedby = False
            print "     ", _("Provided By:")
        if self.opts.hide_version:
            name = prvpkg.name
        else:
            name = str(prvpkg)
        print "       ", "%s (%s)" % (name, prv)

    def showUpgrades(self, pkg, upg):
        if self._firstupgrades:
            self._firstupgrades = False
            print " ", _("Upgrades:")
        print "   ", upg

    def showUpgradesProvidedBy(self, pkg, upg, prv, prvpkg):
        if self._firstupgradesprovidedby:
            self._firstupgradesprovidedby = False
            print "     ", _("Provided By:")
        if self.opts.hide_version:
            name = prvpkg.name
        else:
            name = str(prvpkg)
        print "       ", "%s (%s)" % (name, prv)

    def showConflicts(self, pkg, cnf):
        if self._firstconflicts:
            self._firstconflicts = False
            print " ", _("Conflicts:")
        print "   ", cnf

    def showConflictsProvidedBy(self, pkg, cnf, prv, prvpkg):
        if self._firstconflictsprovidedby:
            self._firstconflictsprovidedby = False
            print "     ", _("Provided By:")
        if self.opts.hide_version:
            name = prvpkg.name
        else:
            name = str(prvpkg)
        print "       ", "%s (%s)" % (name, prv)


class GraphVizOutput(NullOutput):

    def start(self):
        self._shown = {}
        print "digraph Packages {"
        print "    rankdir=LR;"

    def end(self):
        print "}"

    def showPackage(self, pkg):
        if pkg not in self._shown:
            self._shown[pkg] = True
            print '    "%s" [ shape = box ];' % pkg

    def showProvides(self, pkg, prv):
        if (pkg, prv) not in self._shown:
            self._shown[pkg, prv] = True
            print '    "Provides: %s" -> "%s";' % (prv, pkg)

    def showRequiredBy(self, pkg, prv, req, reqpkg):
        self.showPackage(reqpkg)
        self.showRequires(reqpkg, req)
        if (req, prv) not in self._shown:
            self._shown[req, prv] = True
            print '    "Requires: %s" -> "Provides: %s";' % (req, prv)

    def showUpgradedBy(self, pkg, prv, upg, upgpkg):
        self.showPackage(upgpkg)
        self.showUpgrades(upgpkg, upg)
        if (upg, prv) not in self._shown:
            self._shown[upg, prv] = True
            print '    "Upgrades: %s" -> "Provides: %s";' % (upg, prv)

    def showConflictedBy(self, pkg, prv, cnf, cnfpkg):
        self.showPackage(cnfpkg)
        self.showConflicts(cnfpkg, cnf)
        if (cnf, prv) not in self._shown:
            self._shown[cnf, prv] = True
            print '    "Conflicts: %s" -> "Provides: %s";' % (cnf, prv)

    def showRequires(self, pkg, req):
        if (pkg, req) not in self._shown:
            self._shown[pkg, req] = True
            print '    "%s" -> "Requires: %s";' % (pkg, req)

    def showRequiresProvidedBy(self, pkg, req, prv, prvpkg):
        self.showPackage(prvpkg)
        self.showProvides(prvpkg, prv)
        if (req, prv) not in self._shown:
            self._shown[req, prv] = True
            print '    "Requires: %s" -> "Provides: %s";' % (req, prv)

    def showUpgrades(self, pkg, upg):
        if (pkg, upg) not in self._shown:
            self._shown[pkg, upg] = True
            print '    "%s" -> "Upgrades: %s";' % (pkg, upg)

    def showUpgradesProvidedBy(self, pkg, upg, prv, prvpkg):
        self.showPackage(prvpkg)
        self.showProvides(prvpkg, prv)
        if (upg, prv) not in self._shown:
            self._shown[upg, prv] = True
            print '    "Upgrades: %s" -> "Provides: %s";' % (upg, prv)

    def showConflicts(self, pkg, cnf):
        if (pkg, cnf) not in self._shown:
            self._shown[pkg, cnf] = True
            print '    "%s" -> "Conflicts: %s";' % (pkg, cnf)

    def showConflictsProvidedBy(self, pkg, cnf, prv, prvpkg):
        self.showPackage(prvpkg)
        self.showProvides(prvpkg, prv)
        if (cnf, prv) not in self._shown:
            self._shown[cnf, prv] = True
            print '    "Conflicts: %s" -> "Provides: %s";' % (cnf, prv)

DotOutput = GraphVizOutput

class DottyOutput(GraphVizOutput):

    def startGrabOutput(self):
        if self.opts.output:
            self.__filename = self.opts.output
            output = None
        else:
            fd, filename = tempfile.mkstemp()
            self.__filename = filename
            output = os.fdopen(fd, "w")
        GraphVizOutput.startGrabOutput(self, output)

    def end(self):
        GraphVizOutput.end(self)
        self.stopGrabOutput()
        try:
            os.system("dotty %s" % self.__filename)
        finally:
            if self.__filename != self.opts.output:
                os.unlink(self.__filename)

class PrologOutput(NullOutput):

    def add(self, fact):
        self._facts[fact] = True

    def start(self):
        self._facts = {}
        self._firstrequires = True
        self._firstrequiredby = True

    def end(self):
        facts = self._facts.keys()
        self._facts.clear()
        facts.sort()
        for fact in facts:
            print fact
        print

    def showPackage(self, pkg):
        self.add("package('%s')." % pkg)
        if self.opts.show_priority:
            self.add("priority('%s', %d)." % (pkg, pkg.getPriority()))

    def showProvides(self, pkg, prv):
        self.add("provides('%s', '%s')." % (pkg, prv))

    def showRequiredBy(self, pkg, prv, req, reqpkg):
        self.showPackage(reqpkg)
        self.showRequires(reqpkg, req)
        tup = (prv, req)
        if isinstance(req, PreRequires):
            self.add("prerequiredby('%s', '%s')." % (prv, req))
        else:
            self.add("requiredby('%s', '%s')." % (prv, req))
        if self._firstrequiredby:
            self._firstrequiredby = False
        self.add("requiredby(X, Y) :- prerequiredby(X, Y).")

    def showUpgradedBy(self, pkg, prv, upg, upgpkg):
        self.showPackage(upgpkg)
        self.showUpgrades(upgpkg, upg)
        self.add("upgradedby('%s', '%s')." % (prv, upg))

    def showConflictedBy(self, pkg, prv, cnf, cnfpkg):
        self.showPackage(cnfpkg)
        self.showConflicts(cnfpkg, cnf)
        self.add("conflictedby('%s', '%s')." % (prv, cnf))

    def showRequires(self, pkg, req):
        if isinstance(req, PreRequires):
            self.add("prerequires('%s', '%s')." % (pkg, req))
        else:
            self.add("requires('%s', '%s')." % (pkg, req))
        if self._firstrequires:
            self._firstrequires = False
            self.add("requires(X, Y) :- prerequires(X, Y).")

    def showRequiresProvidedBy(self, pkg, req, prv, prvpkg):
        self.showPackage(prvpkg)
        self.showProvides(prvpkg, prv)
        if isinstance(req, PreRequires):
            self.add("prerequiredby('%s', '%s')." % (prv, req))
        else:
            self.add("requiredby('%s', '%s')." % (prv, req))

    def showUpgrades(self, pkg, upg):
        self.add("upgrades('%s', '%s')." % (pkg, upg))

    def showUpgradesProvidedBy(self, pkg, upg, prv, prvpkg):
        self.showPackage(prvpkg)
        self.showProvides(prvpkg, prv)
        self.add("upgradedby('%s', '%s')." % (prv, upg))

    def showConflicts(self, pkg, cnf):
        self.add("conflicts('%s', '%s')." % (pkg, cnf))

    def showConflictsProvidedBy(self, pkg, cnf, prv, prvpkg):
        self.showPackage(prvpkg)
        self.showProvides(prvpkg, prv)
        self.add("conflictedby('%s', '%s')." % (prv, cnf))
