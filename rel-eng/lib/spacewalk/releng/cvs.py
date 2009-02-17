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
import sys
import commands

from spacewalk.releng.common import DEFAULT_BUILD_DIR
from spacewalk.releng.common import run_command, error_out, debug, \
        find_spec_file

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
        self.package_version = builder.build_version

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
        self.cvs_package_workdir = os.path.join(self.cvs_workdir,
                self.package_name)

        # TODO: Looking for spec file in current dir only. This will need
        # to change if we decide to support cvs releases using an arbitrary
        # --tag parameter.
        self.spec_file_name = find_spec_file(in_dir=os.getcwd())
        self.spec_file = os.path.join(os.getcwd(), self.spec_file_name)
        debug("Using spec file: %s" % self.spec_file)

        # TODO: Refuse to run on an upushed tag.

        self.cleanup = True

    def run(self, options):
        """
        Actually build the package in CVS and submit to build system.
        """
        self.cleanup = not options.no_cleanup

        print("Building release from CVS...")
        commands.getoutput("mkdir -p %s" % self.cvs_workdir)
        debug("cvs_branches = %s" % self.cvs_branches)

        print("Checking out cvs module [%s]" % self.package_name)
        # Checkout the project from cvs:
        os.chdir(self.cvs_workdir)
        run_command("cvs -d %s co %s" % (self.cvs_root, self.package_name))

        self._verify_branches_exist()
        self._upload_sources()
        self._sync_spec()

        self._user_confirm_commit()

        self._make_cvs_tag()
        self._make_cvs_build()

        self._finish()

    def _finish(self):
        """ Cleanup if necessary and exit. """
        debug("Exiting.")
        # TODO: cleanup
        if self.cleanup:
            debug("Cleaning up [%s]" % self.cvs_package_workdir)
            run_command("rm -rf %s" % self.cvs_package_workdir)
        sys.exit(1)

    def _verify_branches_exist(self):
        """ Check that CVS checkout contains the branches we expect. """
        os.chdir(self.cvs_package_workdir)
        for branch in self.cvs_branches:
            if not os.path.exists(os.path.join(self.cvs_workdir,
                self.package_name, branch)):
                error_out("%s CVS checkout is missing branch: %s" %
                        (self.package_name, branch))

    def _upload_sources(self):
        """
        Upload any tarballs to the CVS lookaside directory. (if necessary)
        Uses the "make new-sources" target in common.
        """
        # Create the tarball using our builder class:
        tarball_file = self.builder.tgz()
        tarball_filename = os.path.basename(tarball_file)

        # TODO: Check if source already exists in sources file.

        for branch in self.cvs_branches:
            branch_dir = os.path.join(self.cvs_workdir, self.package_name,
                    branch)
            os.chdir(branch_dir)
            output = run_command('make new-sources FILES="%s"' % tarball_file)
            debug(output)
            #self._remove_old_sources(os.path.join(branch_dir, "sources"),
            #        tarball_filename)
            #self._remove_old_cvsignores()

    def _sync_spec(self):
        """
        Copy spec file and any required patches into CVS branches.

        TODO: Implement patch copying, if it turns out to be required. (not
        sure if we actually need it yet)
        """
        for branch in self.cvs_branches:
            branch_dir = os.path.join(self.cvs_workdir, self.package_name,
                    branch)
            os.chdir(branch_dir)
            debug("Copying spec file: %s" % self.builder.spec_file)
            debug("  To: %s" % branch_dir)
            run_command("cp %s %s" % (self.builder.spec_file, branch_dir))

    def _user_confirm_commit(self):
        """ Prompt user if they wish to proceed with commit. """
        print("")
        print("Preparing to commit [%s]" % self.cvs_package_workdir)
        print("Switch terminals and run cvs diff in this directory to " +
                "examine the changes.")
        answer = raw_input("Do you wish to proceed with commit? [y/n] ")
        if answer.lower() not in ['y', 'yes', 'ok', 'sure']:
            print("Fine, you're on your own!")
            self._finish()
        else:
            print("Proceeding with commit.")
            os.chdir(self.cvs_package_workdir)
            cmd = 'cvs commit -m "Update %s to %s"' % \
                    (self.package_name, self.package_version)
            debug("CVS commit command: %s" % cmd)
            #output = run_command(cmd)

    def _make_cvs_tag(self):
        """ Create a CVS tag based on what we just committed. """
        os.chdir(self.cvs_package_workdir)
        # TODO: foreach branch:
        #output = run_command("make tag")

    def _make_cvs_build(self):
        """ Build srpm and submit to build system. """
        pass

