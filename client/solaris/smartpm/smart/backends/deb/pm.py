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
from smart.const import INSTALL, REMOVE, OPTIONAL, ENFORCE
from smart.pm import PackageManager
from smart.sorter import *
from smart import *
import sys, os
import signal

# Part of the logic in this file was based on information found in APT.

UNPACK = 10
CONFIG = 11

class DebSorter(ElementSorter):

    def __init__(self, changeset=None):
        ElementSorter.__init__(self)
        if changeset:
            self.setChangeSet(changeset)

    def setChangeSet(self, changeset):
        self.reset()
        for pkg in changeset:
            op = changeset[pkg]

            if op is INSTALL:
                unpack = (pkg, UNPACK)
                config = (pkg, CONFIG)
                self.addSuccessor(unpack, config)
            else:
                remove = (pkg, REMOVE)
                self.addElement(remove)

            # Packages being installed or removed must go in
            # before their dependencies are removed, or after
            # their dependencies are reinstalled.
            for req in pkg.requires:
                group = ElementOrGroup()
                for prv in req.providedby:
                    for prvpkg in prv.packages:
                        if changeset.get(prvpkg) is INSTALL:
                            if op is INSTALL:
                                group.addSuccessor((prvpkg, CONFIG), unpack)
                            else:
                                group.addSuccessor((prvpkg, CONFIG), remove)
                        elif prvpkg.installed:
                            if changeset.get(prvpkg) is not REMOVE:
                                break
                            if op is INSTALL:
                                group.addSuccessor(config, (prvpkg, REMOVE))
                            else:
                                group.addSuccessor(remove, (prvpkg, REMOVE))
                    else:
                        continue
                    break
                else:
                    if isinstance(req, PreRequires):
                        kind = ENFORCE
                    else:
                        kind = OPTIONAL
                    self.addGroup(group, kind)

            if op is INSTALL:

                # That's a nice trick. We put the removed package after
                # the upgrading package installation. If this relation
                # is broken, it means that some conflict has moved the
                # upgraded package removal due to a loop. In these cases
                # we remove the package before the upgrade process,
                # otherwise we do the upgrade and forget about the
                # removal which is after.
                upgpkgs = [upgpkg for prv in pkg.provides
                                  for upg in prv.upgradedby
                                  for upgpkg in upg.packages]
                upgpkgs.extend([prvpkg for upg in pkg.upgrades
                                       for prv in upg.providedby
                                       for prvpkg in prv.packages])
                for upgpkg in upgpkgs:
                    if changeset.get(upgpkg) is REMOVE:
                        self.addSuccessor(config, (upgpkg, REMOVE), OPTIONAL)

                # Conflicted packages being removed must go in
                # before this package's installation.
                cnfpkgs = [prvpkg for cnf in pkg.conflicts
                                  for prv in cnf.providedby
                                  for prvpkg in prv.packages
                                   if prvpkg is not pkg]
                cnfpkgs.extend([cnfpkg for prv in pkg.provides
                                       for cnf in prv.conflictedby
                                       for cnfpkg in cnf.packages
                                        if cnfpkg is not pkg])
                for cnfpkg in cnfpkgs:
                    if changeset.get(cnfpkg) is REMOVE:
                        self.addSuccessor((cnfpkg, REMOVE), unpack, ENFORCE)

class DebPackageManager(PackageManager):

    MAXPKGSPEROP = 50

    def commit(self, changeset, pkgpaths):

        prog = iface.getProgress(self)
        prog.start()
        prog.setTopic(_("Committing transaction..."))
        prog.show()
        print

        # Compute upgraded packages
        upgraded = {}
        for pkg in changeset.keys():
            if changeset[pkg] is INSTALL:
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
                        assert changeset.get(upgpkg) is REMOVE, \
                               "Installing %s while %s is kept?" % \
                               (pkg, upgpkg)
                        upgraded[upgpkg] = pkg

        try:
            sorter = DebSorter(changeset)
            sorted = sorter.getSorted()
        except LoopError:
            lines = [_("Found unbreakable loops:")]
            opname = {REMOVE: "remove", CONFIG: "config", UNPACK: "unpack"}
            for loop in sorter.getLoops():
                for path in sorter.getLoopPaths(loop):
                    path = ["%s [%s]" % (pkg, opname[op]) for pkg, op in path]
                    lines.append("    "+" -> ".join(path))
            iface.error("\n".join(lines))
            return
        del sorter

        prog.set(0, len(sorted))

        baseargs = [sysconf.get("dpkg", "dpkg")]

        opt = sysconf.get("deb-root")
        if opt:
            baseargs.append("--root=%s" % opt)
        opt = sysconf.get("deb-admindir")
        if opt:
            baseargs.append("--admindir=%s" % opt)
        opt = sysconf.get("deb-instdir")
        if opt:
            baseargs.append("--instdir=%s" % opt)

        done = {}
        while sorted:

            pkgs = []
            op = sorted[0][1]
            while (sorted and sorted[0][1] is op and
                   len(pkgs) < self.MAXPKGSPEROP):
                pkg, op = sorted.pop(0)
                if op is REMOVE and upgraded.get(pkg) in done:
                    continue
                done[pkg] = True
                opname = {REMOVE: "remove", CONFIG: "config", UNPACK: "unpack",
                          INSTALL: "install"}
                print "[%s] %s" % (opname[op], pkg)
                pkgs.append(pkg)

            if not pkgs:
                continue

            args = baseargs[:]

            if op is REMOVE:
                args.append("--force-depends")
                args.append("--force-remove-essential")
                args.append("--remove")
            elif op is UNPACK:
                args.append("--unpack")
            elif op is CONFIG:
                args.append("--force-depends")
                args.append("--force-remove-essential")
                args.append("--configure")

            if op is UNPACK:
                for pkg in pkgs:
                    args.append(pkgpaths[pkg][0])
            else:
                for pkg in pkgs:
                    args.append(pkg.name)

            quithandler = signal.signal(signal.SIGQUIT, signal.SIG_IGN)
            inthandler  = signal.signal(signal.SIGINT, signal.SIG_IGN)

            print " ".join(args)
            pid = os.fork()
            if not pid:
                os.execvp(args[0], args)
                os._exit(1)

            while True:
                _pid, status = os.waitpid(pid, 0)
                if _pid == pid:
                    break

            signal.signal(signal.SIGQUIT, quithandler)
            signal.signal(signal.SIGINT,  inthandler)

            if not os.WIFEXITED(status) or os.WEXITSTATUS(status) != 0:

                if os.WIFSIGNALED(status) and os.WTERMSIG(status):
                    iface.error(_("Sub-process %s has received a "
                                  "segmentation fault") % args[0])
                elif os.WIFEXITED(status):
                    iface.error(_("Sub-process %s returned an error code "
                                  "(%d)") % (args[0], os.WEXITSTATUS(status)))
                else:
                    iface.error(_("Sub-process %s exited unexpectedly")
                                % args[0])
                prog.setDone()
                prog.stop()
                return

            print
            prog.add(len(pkgs))
            prog.show()
            print

        prog.setDone()
        prog.stop()
