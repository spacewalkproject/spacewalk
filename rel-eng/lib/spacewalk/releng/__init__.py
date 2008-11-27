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

    parser.add_option("--tag-version", dest="tag_version", action="store_true",
            help="Tag a new version of the package. (i.e. x.y.z+1)")
    (options, args) = parser.parse_args()

    if len(sys.argv) < 2:
        print parser.error("Must supply an argument. Try -h for help.")

    # Some options imply other options, handle those deps here:
    if options.srpm:
        options.tgz = True
    if options.rpm:
        options.tgz = True

    # Now that we have command line options, instantiate builder/tagger:
    if not builder_class:
        builder_class = Builder
    builder = builder_class(
            tag=options.tag,
            dist=options.dist,
            test=options.test,
            debug=options.debug)

    if not tagger_class:
        tagger_class = Tagger
    tagger = tagger_class(debug=options.debug)

    builder.run(options)
    tagger.run(options)

