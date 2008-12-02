#
# Copyright (c) 2008 Red Hat, Inc.
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

"""
Command line interface for building Spacewalk and Satellite packages from git tags.
"""

import sys
import os
import ConfigParser

from optparse import OptionParser

from spacewalk.releng.builder import Builder, FromTarballBuilder
from spacewalk.releng.tagger import Tagger, ReleaseTagger
from spacewalk.releng.common import find_spec_file, find_git_root, \
        error_out, debug

class CLI:
    """ Parent command line interface class. """

    def main(self):
        """
        Main method called by all build.py's which can provide their own
        specific implementations of taggers and builders.

        tagger_class = Class object which inherits from the base Tagger class.
            (used for tagging package versions)
        builder_class = Class object which inherits from the base Builder class.
            (used for building tar.gz's, srpms, and rpms)
        """

        usage = "usage: %prog [options] arg"
        parser = OptionParser(usage)
        parser.add_option("--tgz", dest="tgz", action="store_true",
                help="build .tar.gz")
        parser.add_option("--srpm", dest="srpm", action="store_true",
                help="build srpm")
        parser.add_option("--rpm", dest="rpm", action="store_true",
                help="build rpm")
        parser.add_option("--dist", dest="dist",
                help="dist tag to apply to srpm and/or rpm (i.e. .el5)")
        parser.add_option("--test", dest="test", action="store_true",
                help="Use current branch HEAD instead of latest package tag.")
        parser.add_option("--no-cleanup", dest="no_cleanup", action="store_true",
                help="Do not clean up temporary build directories/files.")
        parser.add_option("--tag", dest="tag",
                help="Build a specific tag instead of the latest version. " +
                    "(i.e. spacewalk-java-0.4.0-1)")
        parser.add_option("--debug", dest="debug", action="store_true",
                help="Print debug messages.", default=False)

        parser.add_option("--tag-release", dest="tag_release",
                action="store_true",
                help="Tag a new release of the package. (i.e. x.y.z-R+1")
        parser.add_option("--keep-version", dest="keep_version",
                action="store_true",
                help="Use spec file version/release to tag package.")
        (options, args) = parser.parse_args()

        if len(sys.argv) < 2:
            print parser.error("Must supply an argument. Try -h for help.")

        if options.debug:
            os.environ['DEBUG'] = "true"

        project_dir = os.getcwd()
        self._check_for_project_dir()
        config = self._read_project_config(project_dir)

        # Check for builder options and tagger options, if one or more from both
        # groups are found, error out:
        found_builder_options = (options.tgz or options.srpm or options.rpm)
        found_tagger_options = (options.tag_release)
        if found_builder_options and found_tagger_options:
            error_out("Cannot invoke both build and tag options at the " +
                    "same time.")

        # Some options imply other options, handle those deps here:
        if options.srpm:
            options.tgz = True
        if options.rpm:
            options.tgz = True

        # Check what type of package we're building:
        builder_class = Builder
        tagger_class = Tagger
        if config.has_option("buildconfig", "packed_source"):
            debug("Building project from pre-packed source.")
            builder_class = FromTarballBuilder
            tagger_class = ReleaseTagger

        # Now that we have command line options, instantiate builder/tagger:
        if found_builder_options:
            builder = builder_class(
                    tag=options.tag,
                    dist=options.dist,
                    test=options.test,
                    debug=options.debug)
            builder.run(options)

        if found_tagger_options:
            tagger = tagger_class(keep_version=options.keep_version,
                    debug=options.debug)
            tagger.run(options)

    def _check_for_project_dir(self):
        """
        Make sure we're running against a project directory we can build.
        
        Check for exactly one spec file and ensure dir is somewhere within a 
        git checkout.
        """
        find_spec_file()
        find_git_root()

    def _read_project_config(self, project_dir):
        """
        Read and return project build properties if they exist.
        """
        config = ConfigParser.ConfigParser()
        path = os.path.join(project_dir, "build.py.props")
        config.read(path)
        return config
