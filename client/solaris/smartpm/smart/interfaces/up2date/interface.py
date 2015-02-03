#
# Copyright (c) 2004 Conectiva, Inc.
# Copyright (c) 2005--2013 Red Hat, Inc.
#
# From code written by Gustavo Niemeyer <niemeyer@conectiva.com>
# Modified by Joel Martin <jmartin@redhat.com>
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
from smart.interfaces.up2date.progress import Up2dateProgress
from smart.interfaces.up2date import rhnoptions
from smart.interface import Interface, getScreenWidth
from smart.util.strtools import sizeToStr, printColumns
from smart.const import OPTIONAL, ALWAYS, DEBUG
from smart.fetcher import Fetcher
from smart.report import Report
from smart import *
from smart.transaction import PolicyInstall

from rhn.client.rhnPackages import ServerSettings
from rhn.client import rhnAuth

import getpass
import sys
import os
import commands

class Up2dateInterface(Interface):

    def __init__(self, ctrl):
        Interface.__init__(self, ctrl)
        self._progress = Up2dateProgress()
        self._activestatus = False

    def getPackages(self, reload=True):
        if reload: self._ctrl.reloadChannels()
        cache = self._ctrl.getCache()
        pkgs = cache.getPackages()
        return pkgs

    def getRHNPackages(self, reload=True, latest=False):
        if reload: self._ctrl.reloadChannels()
        cache = self._ctrl.getCache()
        pkgs = cache.getPackages()
        retpkgs = []

        patchlist = []
        status, output = commands.getstatusoutput("showrev -p")
        if status == 0:
            if type(output) == type(""):
                output = output.splitlines()
            for line in output:
                # Patch: 190001-01 Obsoletes:  Requires:  Incompatibles:  Packages: Zpkg2, Zpkg1
                if not line.startswith("Patch:"):
                    continue
                parts = line.split()
                patchlist.append("patch-solaris-" + parts[1])

        for pkg in pkgs:

            if pkg.name.startswith("patch-solaris") and not pkg.installed:
                matchname = pkg.name + "-" + pkg.version
                for patchname in patchlist:
                    if matchname.startswith(patchname + "-"):
                        pkg.installed |= 1

            for loader in pkg.loaders:
                channel = loader.getChannel()
                if channel.getType() == "solaris-rhn":
                    retpkgs.append(pkg)
        if latest:
            apkgs = []
            for pkg in retpkgs:
                found = False
                for apkg in apkgs:
                    if pkg.name == apkg.name:
                        found = True
                        if pkg > apkg:
                            apkgs.remove(apkg)
                            apkgs.append(pkg)
                            break
                if not found:
                    apkgs.append(pkg)
            retpkgs = apkgs
        return retpkgs

    def run(self, command=None, argv=None):
        # argv is the list of packages to install if any
        #print "Up2date run() command: ", command, "pkgs: ", argv
        action = command["action"]

        if command.has_key("channel"):
            rhnoptions.setOption("channel", command["channel"])
        if command.has_key("global_zone"):
            rhnoptions.setOption("global_zone", command["global_zone"])
        if command.has_key("admin"):
            rhnoptions.setOption("admin", command["admin"])
        if command.has_key("response"):
            rhnoptions.setOption("response", command["response"])


        rhnoptions.setOption("action", action)

        result = None
        if action in ("", "installall"):
            if action == "":
                pkgs = argv
            if action == "installall":
                pkgs = self.getRHNPackages(latest=True)
                pkgs = [str(x) for x in pkgs if not x.installed]
            import smart.commands.install as install
            opts = install.parse_options([])
            opts.args = pkgs
            opts.yes = True

            # Use a custom policy for breaking ties with patches.
            if command.has_key("act_native"):
                result = install.main(self._ctrl, opts, RHNSolarisGreedyPolicyInstall)
            else:
                result = install.main(self._ctrl, opts, RHNSolarisPolicyInstall)

        if action == "list":
            pkgs = self.getRHNPackages()
            print _("""
Name                                    Version        Rel
----------------------------------------------------------""")
            for pkg in pkgs:
                if pkg.installed: continue
                found = False
                for upgs in pkg.upgrades:
                    for prv in upgs.providedby:
                        for p in prv.packages:
                            if p.installed:
                                found = True
                if found:
                    parts = pkg.version.split("-")
                    version = parts[0]
                    release = "-".join(parts[1:])
                    print "%-40s%-15s%-20s" % (pkg.name, version, release)
        # bug 165383: run the packages command after an install
        if action in ("", "installall", "packages"):
            from rhn.client import rhnPackages
            import string

            pkglist = self.getPackages()

            pkgs = []

            #8/8/2005 wregglej 165046
            #make sure patches get refreshed by checking to see if they're installed
            #and placing them in the pkgs list.
            patchlist = []
            status, output = commands.getstatusoutput("showrev -p")
            if status == 0:
                if type(output) == type(""):
                    output = output.splitlines()
                for line in output:
                    # Patch: 190001-01 Obsoletes:  Requires:  Incompatibles:  Packages: Zpkg2, Zpkg1
                    if not line.startswith("Patch:"):
                        continue
                    parts = line.split()
                    patchlist.append("patch-solaris-" + parts[1] + "-1")

            for pkg in pkglist:
                if pkg.name.startswith("patch-solaris"):
                    matchname = pkg.name + "-" + pkg.version
                    for patchname in patchlist:
                        if string.find(matchname, patchname) > -1:
                            parts = string.split(pkg.version, "-")
                            version = parts[0]
                            revision = string.join(parts[1:]) or 1
                            arch = "sparc-solaris-patch"
                            pkgs.append((pkg.name, version, revision, "", arch))
                elif pkg.installed:
                    # We won't be listing patch clusters: once installed
                    # they are just patches
                    if pkg.name.startswith("patch-solaris"):
                        arch = "sparc-solaris-patch"
                    else:
                        arch = "sparc-solaris"
                    parts = string.split(pkg.version, "-")
                    version = string.join(parts[0:-1], "-")
                    revision = parts[-1] or 1
                    # bug 164540: removed hard-coded '0' epoch
                    pkgs.append((pkg.name, version, revision, "", arch))

            rhnPackages.refreshPackages(pkgs)

            # FIXME (20050415): Proper output method
            print "Package list refresh successful"
        if action == "hardware":
            from rhn.client import rhnHardware
            rhnHardware.updateHardware()
            # FIXME (20050415): Proper output method
            print "Hardware profile refresh successful"
        if action == "showall" or action == "show_available" \
                or action == "showall_with_channels" or action == "show_available_with_channels":
            # Show the latest of each package in RHN
            pkgs = self.getRHNPackages(latest=True)
            for pkg in pkgs:
                if action.startswith("show_available") and pkg.installed: continue
                if action.endswith("_with_channels"):
                    channelName = ""
                    for (ldr,info) in pkg.loaders.items():
                        channel = ldr.getChannel()
                        if channel.getType() == "solaris-rhn":
                            channelLabel = info['baseurl'][6:-1]
                            break
                    print "%-40s%-30s" % (str(pkg), channelLabel)
                else:
                    print str(pkg)
        if action == "show_orphans":
            pkgs = self.getPackages()
            rhn_pkgs = self.getRHNPackages(reload=False)
            for pkg in pkgs:
                if pkg not in rhn_pkgs:
                    print str(pkg)
        if action == "get":
            import smart.commands.download as download
            opts = download.parse_options([])
            opts.args = argv
            opts.yes = True
            result = download.main(self._ctrl, opts)
        if action == "show_channels":
            serverSettings = ServerSettings()
            li = rhnAuth.getLoginInfo()
            channels = li.get('X-RHN-Auth-Channels')
            for channelInfo in channels:
                print channelInfo[0]

        return result

    def getProgress(self, obj, hassub=False):
        self._progress.setHasSub(hassub)
        self._progress.setFetcherMode(isinstance(obj, Fetcher))
        return self._progress

    def getSubProgress(self, obj):
        return self._progress

    def showStatus(self, msg):
        if self._activestatus:
            pass
#            print
        else:
            self._activestatus = True
        #sys.stdout.write(msg)
        #sys.stdout.flush()

    def hideStatus(self):
        if self._activestatus:
            self._activestatus = False
            print

    def askYesNo(self, question, default=False):
        self.hideStatus()
        mask = default and _("%s (Y/n): ") or _("%s (y/N): ")
        res = raw_input(mask % question).strip().lower()
        print
        if res:
            return (_("yes").startswith(res) and not
                    _("no").startswith(res))
        return default

    def askContCancel(self, question, default=False):
        self.hideStatus()
        if default:
            mask = _("%s (Continue/cancel): ")
        else:
            mask = _("%s (continue/Cancel): ")
        res = raw_input(mask % question).strip().lower()
        print
        if res:
            return (_("continue").startswith(res) and not
                    _("cancel").startswith(res))
        return default

    def askOkCancel(self, question, default=False):
        self.hideStatus()
        mask = default and _("%s (Ok/cancel): ") or _("%s (ok/Cancel): ")
        res = raw_input(mask % question).strip().lower()
        print
        if res:
            return (_("ok").startswith(res) and not
                    _("cancel").startswith(res))
        return default

    def confirmChangeSet(self, changeset):
        return self.showChangeSet(changeset, confirm=True)

    def askInput(self, prompt, message=None, widthchars=None, echo=True):
        print
        if message:
            print message
        prompt += ": "
        try:
            if echo:
                res = raw_input(prompt)
            else:
                res = getpass.getpass(prompt)
        except KeyboardInterrupt:
            res = ""
        print
        return res

    def askPassword(self, location, caching=OPTIONAL):
        self._progress.lock()
        passwd = Interface.askPassword(self, location, caching)
        self._progress.unlock()
        return passwd

    def insertRemovableChannels(self, channels):
        self.hideStatus()
        print
        print _("Insert one or more of the following removable channels:")
        print
        for channel in channels:
            print "   ", str(channel)
        print
        return self.askOkCancel(_("Continue?"), True)

    # Non-standard interface methods:

    def showChangeSet(self, changeset, keep=None, confirm=False):
        self.hideStatus()
        report = Report(changeset)
        report.compute()

        screenwidth = getScreenWidth()

        hideversion = sysconf.get("text-hide-version", len(changeset) > 40)
        if hideversion:
            def cvt(lst):
                return [x.name for x in lst]
        else:
            def cvt(lst):
                return lst

        print
        if keep:
            keep = cvt(keep)
            keep.sort()
            print _("Kept packages (%d):") % len(keep)
            printColumns(keep, indent=2, width=screenwidth)
            print
        pkgs = report.upgrading.keys()
        if pkgs:
            pkgs = cvt(pkgs)
            pkgs.sort()
            print _("Upgrading packages (%d):") % len(pkgs)
            printColumns(pkgs, indent=2, width=screenwidth)
            print
        pkgs = report.downgrading.keys()
        if pkgs:
            pkgs = cvt(pkgs)
            pkgs.sort()
            print _("Downgrading packages (%d):") % len(pkgs)
            printColumns(pkgs, indent=2, width=screenwidth)
            print
        pkgs = report.installing.keys()
        if pkgs:
            pkgs = cvt(pkgs)
            pkgs.sort()
            print _("Installed packages (%d):") % len(pkgs)
            printColumns(pkgs, indent=2, width=screenwidth)
            print
        pkgs = report.removed.keys()
        if pkgs:
            pkgs = cvt(pkgs)
            pkgs.sort()
            print _("Removed packages (%d):") % len(pkgs)
            printColumns(pkgs, indent=2, width=screenwidth)
            print
        dsize = report.getDownloadSize()
        size = report.getInstallSize() - report.getRemoveSize()
        if dsize:
            sys.stdout.write(_("%s of package files are needed. ") %
                             sizeToStr(dsize))
        if size > 0:
            sys.stdout.write(_("%s will be used.") % sizeToStr(size))
        elif size < 0:
            size *= -1
            sys.stdout.write(_("%s will be freed.") % sizeToStr(size))
        if dsize or size:
            sys.stdout.write("\n\n")
        if confirm:
            return self.askYesNo(_("Confirm changes?"), True)
        return True

class RHNSolarisPolicyInstall(PolicyInstall):

    def getPriorityWeights(self, targetPkg, providingPkgs):

        # We first need to determine whether we are dealing with a package
        # or a patch.  For packages, we'll defer to the standard installation
        # policy; we only want special behavior for patches.
        #
        if not targetPkg.isPatch():
            return \
                PolicyInstall.getPriorityWeights(self, targetPkg, providingPkgs)

        # At this point, we have a list of patches.  We'll assign weights based
        # on how qualified each providing package is.  Here's how:
        #
        # Let T be the package we wish to find the best provider for.
        # Let P be the set of patches which was determined to provide T.
        # For each P[i], let X be the the set of patches that provides P[i].
        #
        # We determine qualification based on count(X) for each P[i].  The
        # lower the count(X), the more qualified P[i] is, and the higher it
        # will be weighted.
        #
        # In the SmartPM dep solver, a lower weight indicates a better match.
        # Therefore, at the end of this algorithm, the P[i] with the lowest
        # count(X) should be the lowest-weighted.  In the event of a tie, where
        # more than one P[i] is of equally low weight, we allow the "winner" to
        # be arbitrarily picked by the calling code.
        #
        # If P[i] is not a patch, it must be a package.  In this case, we
        # automatically weight it with the highest value and exclude it from
        # our search.  We never want a package to override a patch.  We
        # shouldn't see this scenario, but we'll account for it just in case.
        #
        # This algorithm makes a number of assumptions based on extensive
        # observations of the Solaris patch distribution web page at SunSolve
        # (http://sunsolve.sun.com/pub-cgi/show.pl?target=patches/patch-access).
        # These are:
        #
        #     - If a patch P2 obsoletes another path, P1, then P2 will provide
        #       both P2 and P1.
        #
        #     - If a patch P3 then obsoletes P2, P3 will provide both P3, P2,
        #       and P1.
        #
        #     - In no case will two patches, P4 and P3, both obsolete another
        #       patch P2 without P4 also obsoleting P3 or vice-versa.  In other
        #       words, patches must be accumulated in a hierarchical manner;
        #       two or more patches may not accumulate another at the same tree
        #       level.

        result    = {}
        nameTable = {}

        # First, populate the result set with the lowest possible weights.
        # Then, create a mapping between package names and the actual package
        # objects.  Since pkg.provides is a collection of Provides objects,
        # this will allow us to efficiently reference back to the original
        # packages.
        for providingPkg in providingPkgs:
            result[providingPkg] = 0.0
            nameTable[providingPkg.name] = providingPkg

        # Now iterate again and adjust the weights according to the number of
        # providers for each patch.
        for providingPkg in providingPkgs:

            # Non-patches just don't make sense in this context.  Give them a
            # very high weight.
            if not providingPkg.isPatch():
                result[providingPkg] = 9999999.0
            else:
                # Iterate over each patch that this patch provides and add
                # to the weight each time it appears.  This will allow the
                # more qualified patches to rise to the top.  A lower weight
                # indicates a better qualification.
                for providedPkg in providingPkg.provides:
                    # Only include it in the result if its in the set we're
                    # working with.
                    if nameTable.has_key(providedPkg.name):
                        result[nameTable[providedPkg.name]] += 10.0

        return result


class RHNSolarisGreedyPolicyInstall(RHNSolarisPolicyInstall):

    def getWeight(self, changeset):
        # Do not peanlize for bringing in extra packages
        # BZ: #428490
        return 0
