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
from smart.const import INSTALL, REMOVE
from smart.pm import PackageManager
from smart import *
import commands

class SlackPackageManager(PackageManager):

    def commit(self, changeset, pkgpaths):

        prog = iface.getProgress(self, True)
        prog.start()
        prog.setTopic(_("Committing transaction..."))
        prog.show()

        install = {}
        remove = {}
        for pkg in changeset:
            if changeset[pkg] is INSTALL:
                install[pkg] = True
            else:
                remove[pkg] = True
        upgrade = {}
        for pkg in install.keys():
            for upg in pkg.upgrades:
                for prv in upg.providedby:
                    for prvpkg in prv.packages:
                        if prvpkg.installed:
                            if prvpkg in remove:
                                del remove[prvpkg]
                            if pkg in install:
                                del install[pkg]
                            upgrade[pkg] = True

        total = len(install)+len(upgrade)+len(remove)
        prog.set(0, total)

        for pkg in install:
            prog.setSubTopic(pkg, _("Installing %s") % pkg.name)
            prog.setSub(pkg, 0, 1, 1)
            prog.show()
            status, output = commands.getstatusoutput("installpkg %s" %
                                                      pkgpaths[pkg][0])
            prog.setSubDone(pkg)
            prog.show()
            if status != 0:
                iface.warning(_("Got status %d installing %s:") % (status, pkg))
                iface.warning(output)
            else:
                iface.debug(_("Installing %s:") % pkg)
                iface.debug(output)
        for pkg in upgrade:
            prog.setSubTopic(pkg, _("Upgrading %s") % pkg.name)
            prog.setSub(pkg, 0, 1, 1)
            prog.show()
            status, output = commands.getstatusoutput("upgradepkg %s" %
                                                      pkgpaths[pkg][0])
            prog.setSubDone(pkg)
            prog.show()
            if status != 0:
                iface.warning(_("Got status %d upgrading %s:") % (status, pkg))
                iface.warning(output)
            else:
                iface.debug(_("Upgrading %s:") % pkg)
                iface.debug(output)
        for pkg in remove:
            prog.setSubTopic(pkg, _("Removing %s") % pkg.name)
            prog.setSub(pkg, 0, 1, 1)
            prog.show()
            status, output = commands.getstatusoutput("removepkg %s" %
                                                      pkg.name)
            prog.setSubDone(pkg)
            prog.show()
            if status != 0:
                iface.warning(_("Got status %d removing %s:") % (status, pkg))
                iface.warning(output)
            else:
                iface.debug(_("Removing %s:") % pkg)
                iface.debug(output)

        prog.setDone()
        prog.stop()
