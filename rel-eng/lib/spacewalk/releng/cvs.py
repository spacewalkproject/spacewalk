#
# Copyright (c) 2009 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#

""" Module for building packages in brew/koji from cvs. """

import os
import commands

from spacewalk.releng.common import DEFAULT_BUILD_DIR
from spacewalk.releng.common import run_command, error_out, debug

DEFAULT_CVS_BUILD_DIR = os.path.join(DEFAULT_BUILD_DIR, "cvswork")

class CvsReleaser(object):
    """
    Imports sources into CVS, tags packages, and submits to build system.

    Currently this class is only tested with the brew build system. Fedora
    CVS may require some small modifications when we're ready to use it as
    such.
    """

    def __init__(self, global_config, builder):
        self.global_config = global_config
        self.builder = builder
        self.package_name = builder.project_name

        if not self.global_config.has_section("cvs"):
            error_out("No 'cvs' section found in global.build.py.props")

        if not self.global_config.has_option("cvs", "cvsroot"):
            error_out(["Cannot build from CVS",
                "no 'cvsroot' defined in global.build.py.props"])

        if not self.global_config.has_option("cvs", "branches"):
            error_out(["Cannot build from CVS",
                "no branches defined in global.build.py.props"])

        self.cvs_root = self.global_config.get("cvs", "cvsroot")
        debug("cvs_root = %s" % self.cvs_root)
        # TODO: if it looks like we need custom CVSROOT's for different users,
        # allow setting of a property to lookup in ~/.spacewalk-build-rc to
        # use instead. (if defined)
        self.cvs_workdir = DEFAULT_CVS_BUILD_DIR
        debug("cvs_workdir = %s" % self.cvs_workdir)
        self.cvs_branches = global_config.get("cvs", "branches").split(" ")

    def run(self):
        """
        Actually build the package in CVS and submit to build system.
        """
        print("Building release from CVS...")
        commands.getoutput("mkdir -p %s" % self.cvs_workdir)
        debug("cvs_branches = %s" % self.cvs_branches)

        print("Checking out cvs module [%s]" % self.package_name)
        # Checkout the project from cvs:
        os.chdir(self.cvs_workdir)
        run_command("cvs -d %s co %s" % (self.cvs_root, self.package_name))

        self._verify_branches_exist()
        self._upload_sources()

        # TODO: cleanup

    def _verify_branches_exist(self):
        """ Check that CVS checkout contains the branches we expect. """
        os.chdir(os.path.join(self.cvs_workdir, self.package_name))
        for branch in self.cvs_branches:
            if not os.path.exists(os.path.join(self.cvs_workdir,
                self.package_name, branch)):
                error_out("%s CVS checkout is missing branch: %s" %
                        (self.package_name, branch))

    def _upload_sources(self):
        """
        Upload any tarballs to the CVS lookaside directory. (if necessary)
        Uses the "make upload" target in common.
        """
        # Create the tarball using our builder class:
        tarball_file = self.builder.tgz()
        tarball_filename = os.path.basename(tarball_file)

        # TODO: Check if source already exists in sources file.

        # NOTE: Simulating make new-sources in Fedora CVS here. Once this
        # target is available in dist-cvs, this can be replaced.
        for branch in self.cvs_branches:
            branch_dir = os.path.join(self.cvs_workdir, self.package_name,
                    branch)
            os.chdir(branch_dir)
            output = run_command('make upload FILES="%s"' % tarball_file)
            debug(output)
            self._remove_old_sources(os.path.join(branch_dir, "sources"),
                    tarball_filename)
            self._remove_old_cvsignores()

    def _remove_old_sources(self, sources_file, new_source_filename):
        """
        Remove old entries in cvs sources file.

        make upload does not remove old sources, only adds the new. This will
        be required until make new-sources is supported from Fedora cvs.
        """
        debug("Removing old sources from: %s" % sources_file)
        f = open(sources_file, 'r')
        lines = f.readlines()
        f.close()
        new_lines = []
        f = open(sources_file, 'w') # overwriting the file now
        for line in lines:
            # NOTE: Looks like two spaces between md5 and filename can be
            # expected:
            (md5, filename) = line.split("  ")
            if filename.strip() == new_source_filename:
                debug("   keeping:  %s" % line.strip())
                f.write(line)
            else:
                debug("   removing: %s" % line.strip())
        f.close()

    def _remove_old_cvsignores(self):
        """
        Remove old entries in cvs cvsignore file.
        """
        pass
