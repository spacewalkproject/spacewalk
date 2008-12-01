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
Infrastructure for building Spacewalk and Satellite packages from git tags.
"""

import sys
import os

from optparse import OptionParser

from spacewalk.releng.builder import Builder
from spacewalk.releng.tagger import Tagger

def main(tagger_class=None, builder_class=None):
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

    parser.add_option("--tag-release", dest="tag_release", action="store_true",
            help="Tag a new release of the package. (i.e. x.y.z-R+1")
    (options, args) = parser.parse_args()

    if len(sys.argv) < 2:
        print parser.error("Must supply an argument. Try -h for help.")

    if options.debug:
        os.environ['DEBUG'] = "true"

    # Check for builder options and tagger options, if one or more from both
    # groups are found, error out:
    found_builder_options = (options.tgz or options.srpm or options.rpm)
    found_tagger_options = (options.tag_release)
    if found_builder_options and found_tagger_options:
        print "ERROR: Cannot invoke both build and tag options at the " + \
                "same time."
        sys.exit(1)

    # Some options imply other options, handle those deps here:
    if options.srpm:
        options.tgz = True
    if options.rpm:
        options.tgz = True

    # Now that we have command line options, instantiate builder/tagger:
    if found_builder_options:
        if not builder_class:
            builder_class = Builder
        builder = builder_class(
                tag=options.tag,
                dist=options.dist,
                test=options.test,
                debug=options.debug)
        builder.run(options)

    if found_tagger_options:
        if not tagger_class:
            tagger_class = Tagger
        tagger = tagger_class(debug=options.debug)
        tagger.run(options)

