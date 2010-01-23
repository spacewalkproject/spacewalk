#
# Copyright (c) 2005 Red Hat, Inc.
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

import commands
import os
import shutil
import tempfile
import zipfile

from smart.const import INSTALL
from smart.pm import PackageManager
from smart.sorter import ChangeSetSorter, LoopError
from smart.interfaces.up2date import rhnoptions
from smart import *

class UnzipException(Exception):
    pass

class PatchaddException(Exception):
    pass

def solinstall(adminfile, path, pkg, prog=None):
    # NOTE: all error handling and reporting is done via Exceptions

    if pkg.name.startswith("patch-"):
        # Patch and patch cluster install
        tdir = tempfile.mkdtemp('-dir', 'solinstall-', '/tmp')
        pkgdir = ""
        ret = 0

        # Save the CWD for later, since we may chdir below.
        saved_cwd = os.getcwd()

        try:
            if os.path.isdir(path):
                pkgdir = path

            else:
                if not zipfile.is_zipfile(path):
                    raise UnzipException("patch %s not in a zip file: %s" % \
                                             (pkg.name, path))

                cmdstr = "unzip -u %s -d %s" % (path, tdir)
                ret, x = commands.getstatusoutput(cmdstr)

                if ret != 0:
                    raise UnzipException("patch %s: unzip of %s into %s failed: %s" % \
                                             (pkg.name, path, tdir, x))

                zf = zipfile.ZipFile(path)
                pd = zf.namelist()[0].split('/')[0]
                zf.close()
#                zf = os.path.basename(path)
#                pd = zf.rstrip(".zip")

                pkgdir = os.path.join(tdir, pd)

                if not os.path.isdir(pkgdir):
                    raise UnzipException( \
                        "patch %s contained more than 1 directory: %s" % \
                            (pkg.name, pkgdir))

                if pkgdir == tdir:
                    raise UnzipException( \
                        "patch %s: zip file does not contain patch: %s" % \
                            (pkg.name, pkgdir))

            # change the permissions on the patch directory
            cmdstr = "chmod -R 777 %s" % pkgdir
            ret, x = commands.getstatusoutput(cmdstr)

            # default values
            status = 1
            output = ""
            cmd = ""

            if pkg.name.startswith("patch-cluster-solaris-"):
                cmd =  "%s/install_cluster -q" % pkgdir
                os.chdir(pkgdir)
            else:
                cmd = "patchadd -u %s" % pkgdir

#            print cmd
            status, output = commands.getstatusoutput(cmd)

            if status != 0:
                raise PatchaddException("status: %d, output: %s" % (status, output))

        finally:
            # Return to the saved working directory so we don't attempt to
            # remove the directory we're in.
            os.chdir(saved_cwd)

            # Cleanup temp dir
            if ret == 0:
                shutil.rmtree(tdir)

    else:
        # Package install
        #template = "pkgadd -a %s -n -d %s %s"
        template = "pkgadd -a %s" 

        os_version = os.uname()[2]
        if os_version == "5.10":
            if rhnoptions.hasOption("global_zone") and \
               rhnoptions.getOption("global_zone"):
                # '-G' option to only install into the global zone on solaris 10
                #template = "pkgadd -G -a %s -n -d %s %s"
                template += " -G "

        if rhnoptions.hasOption("response") and \
            rhnoptions.getOption("response"):
		responsefile = rhnoptions.getOption("response")
                template += " -r %s" % (responsefile)

        template += " -n -d %s %s"
        cmd = template % (adminfile, path, pkg.name)
        print cmd
        status, output = commands.getstatusoutput(cmd)

    return status, output


def solremove(adminfile, pkg, prog=None):
    if pkg.name.startswith("patch-solaris-"):
        # patchrm doesn't grok epoch and name prefix so strip it off
        patch = "-".join(str(pkg).split("-")[2:4])
#        print "patchrm %s" % (patch)
        status, output = commands.getstatusoutput("patchrm %s" % (patch))
    else:
        status, output = commands.getstatusoutput("pkgrm -a %s -n %s" %
                            (adminfile, pkg.name))
    return status, output


def solupgrade(adminfile, path, pkg, prog=None):
    if not pkg.name.startswith("patch-solaris-"):
        status, output = solinstall(adminfile, path, pkg, prog)
    else:
        status, output = solinstall(adminfile, path, pkg, prog)
        #status, output = solremove(adminfile, pkg, prog)
        #if status == 0:
        #    status, output = solinstall(adminfile, path, pkg, prog)
    return status, output


class SolarisPackageManager(PackageManager):

    def commit(self, changeset, pkgpaths):

        prog = iface.getProgress(self, True)
        prog.start()
        prog.setTopic(_("Committing transaction..."))
        prog.set(0, len(changeset))
        prog.show()

        if rhnoptions.hasOption("admin") and \
            rhnoptions.getOption("admin"):
		adminfile = rhnoptions.getOption("admin")
	else:
            adminfile = sysconf.get("solaris-adminfile", "/var/sadm/install/admin/default")

        # Compute upgrade packages
        upgrade = {}
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
                    upgrade[pkg] = True
                    for upgpkg in upgpkgs:
                        if upgpkg in changeset:
                            del changeset[upgpkg]
        try:
            sorter = ChangeSetSorter(changeset)
            sorted = sorter.getSorted()
        except LoopError:
            lines = [_("Found unbreakable loops:")]
            for path in sorter.getLoopPaths(sorter.getLoops()):
                path = ["%s [%s]" % (pkg, op is INSTALL and "I" or "R")
                        for pkg, op in path]
                lines.append("    "+" -> ".join(path))
            iface.error("\n".join(lines))
            sys.exit(-1)
        del sorter

        for pkg, op in sorted:
            if op is INSTALL and pkg in upgrade:
                # Upgrading something
                prog.setSubTopic(pkg, _("Upgrading %s") % pkg.name)
                prog.setSub(pkg, 0, 1, 1)
                prog.show()
                path = pkgpaths[pkg][0]
                status, output = solupgrade(adminfile, path, pkg, prog)
                prog.setSubDone(pkg)
                prog.show()
                if status != 0:
                    iface.warning(_("Got status %d upgrading %s:") % (status, pkg))
                    iface.warning(output)
                else:
                    iface.debug(_("Upgrading %s:") % pkg)
                    iface.debug(output)
            elif op is INSTALL:
                # Normal install
                prog.setSubTopic(pkg, _("Installing %s") % pkg.name)
                prog.setSub(pkg, 0, 1, 1)
                prog.show()
                path = pkgpaths[pkg][0]

                status = 0
                output = ""
                try:
                    status, output = solinstall(adminfile, path, pkg, prog)
                except PatchaddException, pae:
                    # Solaris patch cluster installs are tolerant of failed
                    # patches, and we should be too.  Just warn the user and
                    # keep going.
                    iface.warning( \
                        _("\nWARNING:  Installation of patch %s failed.\n%s") \
                            % (pkg.name, str(pae)))

                prog.setSubDone(pkg)
                prog.show()
                if status != 0:
                    iface.warning(_("Got status %d installing %s:") % (status, pkg))
                    iface.warning(output)
                else:
                    iface.debug(_("Installing %s:") % pkg)
                    iface.debug(output)
            else:
                # Remove
                prog.setSubTopic(pkg, _("Removing %s") % pkg.name)
                prog.setSub(pkg, 0, 1, 1)
                prog.show()
                status, output = solremove(adminfile, pkg, prog)
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

# vim:ts=4:sw=4:et
