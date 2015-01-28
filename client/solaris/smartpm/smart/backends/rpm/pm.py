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
from smart.util.filetools import setCloseOnExec
from smart.sorter import ChangeSetSorter, LoopError
from smart.const import INSTALL, REMOVE, BLOCKSIZE
from smart.pm import PackageManager
from smart import *
import sys, os
import codecs
import locale
import errno
import fcntl
import rpm

ENCODING = locale.getpreferredencoding()

class RPMPackageManager(PackageManager):

    def commit(self, changeset, pkgpaths):

        prog = iface.getProgress(self, True)
        prog.start()
        prog.setTopic(_("Committing transaction..."))
        prog.set(0, len(changeset))
        prog.show()

        # Compute upgrading/upgraded packages
        upgrading = {}
        upgraded = {}
        for pkg in changeset.keys():
            if changeset.get(pkg) is INSTALL:
                upgpkgs = [upgpkg for prv in pkg.provides
                                  for upg in prv.upgradedby
                                  for upgpkg in upg.packages
                                  if upgpkg.installed]
                upgpkgs.extend([prvpkg for upg in pkg.upgrades
                                       for prv in upg.providedby
                                       for prvpkg in prv.packages
                                       if prvpkg.installed])
                if upgpkgs:
                    for upgpkg in upgpkgs:
                        # If any upgraded package will stay in the system,
                        # this is not really an upgrade for rpm.
                        if changeset.get(upgpkg) is not REMOVE:
                            break
                    else:
                        upgrading[pkg] = True
                        for upgpkg in upgpkgs:
                            upgraded[upgpkg] = True
                            if upgpkg in changeset:
                                del changeset[upgpkg]

        # FIXME (20050321): Solaris rpm 4.1 hack
        if sys.platform[:5] == "sunos":
            rpm.addMacro("_dbPath", sysconf.get("rpm-root", "/"))
            ts = rpm.TransactionSet()
        else:
            ts = rpm.ts(sysconf.get("rpm-root", "/"))

        if not sysconf.get("rpm-check-signatures", False):
            ts.setVSFlags(rpm._RPMVSF_NOSIGNATURES)

        # Let's help RPM, since it doesn't do a good
        # ordering job on erasures.
        try:
            sorter = ChangeSetSorter(changeset)
            sorted = sorter.getSorted()
            forcerpmorder = False
        except LoopError:
            lines = [_("Found unbreakable loops:")]
            for path in sorter.getLoopPaths(sorter.getLoops()):
                path = ["%s [%s]" % (pkg, op is INSTALL and "I" or "R")
                        for pkg, op in path]
                lines.append("    "+" -> ".join(path))
            lines.append(_("Will ask RPM to order it."))
            iface.error("\n".join(lines))
            sys.exit(1)
            forcerpmorder = True
        del sorter

        packages = 0
        reinstall = False
        for pkg, op in sorted:
            if op is INSTALL:
                if pkg.installed:
                    reinstall = True
                loader = [x for x in pkg.loaders if not x.getInstalled()][0]
                info = loader.getInfo(pkg)
                mode = pkg in upgrading and "u" or "i"
                path = pkgpaths[pkg][0]
                fd = os.open(path, os.O_RDONLY)
                try:
                    h = ts.hdrFromFdno(fd)
                except rpm.error, e:
                    os.close(fd)
                    raise Error, "%s: %s" % (os.path.basename(path), e)
                os.close(fd)
                ts.addInstall(h, (info, path), mode)
                packages += 1
            else:
                loader = [x for x in pkg.loaders if x.getInstalled()][0]
                offset = pkg.loaders[loader]
                try:
                    ts.addErase(offset)
                except rpm.error, e:
                    raise Error, "%s-%s: %s" % \
                                 (pkg.name, pkg.version, unicode(e))

        upgradednames = {}
        for pkg in upgraded:
            upgradednames[pkg.name] = True

        del sorted
        del upgraded
        del upgrading

        force = sysconf.get("rpm-force", True)
        if not force:
            probs = ts.check()
            if probs:
                problines = []
                for prob in probs:
                    name1 = "%s-%s-%s" % prob[0]
                    name2, version = prob[1]
                    if version:
                        sense = prob[2]
                        name2 += " "
                        if sense & rpm.RPMSENSE_LESS:
                            name2 += "<"
                        elif sense & rpm.RPMSENSE_GREATER:
                            name2 += ">"
                        if sense & rpm.RPMSENSE_EQUAL:
                            name2 += "="
                        name2 += " "
                        name2 += version
                    if prob[4] == rpm.RPMDEP_SENSE_REQUIRES:
                        line = _("%s requires %s") % (name1, name2)
                    else:
                        line = _("%s conflicts with %s") % (name1, name2)
                    problines.append(line)
                raise Error, "\n".join(problines)
        if forcerpmorder or sysconf.get("rpm-order"):
            ts.order()
        probfilter = rpm.RPMPROB_FILTER_OLDPACKAGE
        if force or reinstall:
            probfilter |= rpm.RPMPROB_FILTER_REPLACEPKG
            probfilter |= rpm.RPMPROB_FILTER_REPLACEOLDFILES
        ts.setProbFilter(probfilter)
        cb = RPMCallback(prog, upgradednames)
        cb.grabOutput(True)
        probs = None
        try:
            probs = ts.run(cb, None)
        finally:
            cb.grabOutput(False)
            prog.setDone()
            if probs:
                raise Error, "\n".join([x[0] for x in probs])
            prog.stop()

class RPMCallback:
    def __init__(self, prog, upgradednames):
        self.prog = prog
        self.upgradednames = upgradednames
        self.data = {"item-number": 0}
        self.fd = None
        self.rpmout = None
        self.lasttopic = None
        self.topic = None

    def grabOutput(self, flag):
        if flag:
            if not self.rpmout:
                # Grab rpm output, but not the python one.
                self.stdout = sys.stdout
                self.stderr = sys.stderr
                writer = codecs.getwriter(ENCODING)
                reader = codecs.getreader(ENCODING)
                sys.stdout = writer(os.fdopen(os.dup(1), "w"))
                sys.stderr = writer(os.fdopen(os.dup(2), "w"))
                pipe = os.pipe()
                os.dup2(pipe[1], 1)
                os.dup2(pipe[1], 2)
                os.close(pipe[1])
                self.rpmout = reader(os.fdopen(pipe[0], "r"))
                setCloseOnExec(self.rpmout.fileno())
                flags = fcntl.fcntl(self.rpmout.fileno(), fcntl.F_GETFL, 0)
                flags |= os.O_NONBLOCK
                fcntl.fcntl(self.rpmout.fileno(), fcntl.F_SETFL, flags)
        else:
            if self.rpmout:
                self._rpmout()
                os.dup2(sys.stdout.fileno(), 1)
                os.dup2(sys.stderr.fileno(), 2)
                sys.stdout = self.stdout
                sys.stderr = self.stderr
                del self.stdout
                del self.stderr
                self.rpmout.close()
                self.rpmout = None

    def _rpmout(self):
        if self.rpmout:
            try:
                output = self.rpmout.read(BLOCKSIZE)
            except (OSError, IOError), e:
                if e[0] != errno.EWOULDBLOCK:
                    raise
            else:
                if output:
                    if self.topic and self.topic != self.lasttopic:
                        self.lasttopic = self.topic
                        iface.info(self.topic)
                    iface.info(output)

    def __call__(self, what, amount, total, infopath, data):

        self._rpmout()

        if what == rpm.RPMCALLBACK_INST_OPEN_FILE:
            info, path = infopath
            pkgstr = str(info.getPackage())
            iface.debug(_("Processing %s in %s") % (pkgstr, path))
            self.topic = _("Output from %s:") % pkgstr
            self.fd = os.open(path, os.O_RDONLY)
            setCloseOnExec(self.fd)
            return self.fd

        elif what == rpm.RPMCALLBACK_INST_CLOSE_FILE:
            if self.fd is not None:
                os.close(self.fd)
                self.fd = None

        elif what == rpm.RPMCALLBACK_INST_START:
            info, path = infopath
            pkg = info.getPackage()
            self.data["item-number"] += 1
            self.prog.add(1)
            self.prog.setSubTopic(infopath, _("Installing %s") % pkg.name)
            self.prog.setSub(infopath, 0, 1, subdata=self.data)
            self.prog.show()

        elif (what == rpm.RPMCALLBACK_TRANS_PROGRESS or
              what == rpm.RPMCALLBACK_INST_PROGRESS):
            self.prog.setSub(infopath or "trans", amount, total,
                             subdata=self.data)
            self.prog.show()

        elif what == rpm.RPMCALLBACK_TRANS_START:
            self.prog.setSubTopic("trans", _("Preparing..."))
            self.prog.setSub("trans", 0, 1)
            self.prog.show()

        elif what == rpm.RPMCALLBACK_TRANS_STOP:
            self.prog.setSubDone("trans")
            self.prog.show()

        elif what == rpm.RPMCALLBACK_UNINST_START:
            self.topic = _("Output from %s:") % infopath
            subkey =  "R*"+infopath
            self.data["item-number"] += 1
            self.prog.add(1)
            if infopath in self.upgradednames:
                topic = _("Cleaning %s") % infopath
            else:
                topic = _("Removing %s") % infopath
            self.prog.setSubTopic(subkey, topic)
            self.prog.setSub(subkey, 0, 1, subdata=self.data)
            self.prog.show()

        elif what == rpm.RPMCALLBACK_UNINST_STOP:
            self.topic = None
            subkey = "R*"+infopath
            if not self.prog.getSub(subkey):
                self.data["item-number"] += 1
                self.prog.add(1)
                if infopath in self.upgradednames:
                    topic = _("Cleaning %s") % infopath
                else:
                    topic = _("Removing %s") % infopath
                self.prog.setSubTopic(subkey, topic)
                self.prog.setSub(subkey, 1, 1, subdata=self.data)
            else:
                self.prog.setSubDone(subkey)
            self.prog.show()
