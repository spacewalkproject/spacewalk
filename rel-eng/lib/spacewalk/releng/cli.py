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
import random
import commands
import ConfigParser

from optparse import OptionParser
from string import strip

from spacewalk.releng.builder import Builder, NoTgzBuilder
from spacewalk.releng.tagger import VersionTagger, ReleaseTagger
from spacewalk.releng.common import find_git_root, run_command, \
        error_out, debug, get_project_name, get_relative_project_dir, \
        check_tag_exists

def get_class_by_name(name):
    """
    Get a Python class specified by it's fully qualified name.

    NOTE: Does not actually create an instance of the object, only returns
    a Class object.
    """
    # Split name into module and class name:
    tokens = name.split(".")
    class_name = tokens[-1]
    module = ""

    for s in tokens[0:-1]:
        if len(module) > 0:
            module = module + "."
        module = module + s

    mod = __import__(tokens[0])
    components = name.split('.')
    for comp in components[1:-1]:
        mod = getattr(mod, comp)

    debug("Importing %s" % name)
    c = getattr(mod, class_name)
    return c

def read_global_config():
    """
    Read config settings in from ~/.spacewalk-build-rc.
    """
    file_loc = os.path.expanduser("~/.spacewalk-build-rc")
    try:
        f = open(file_loc)
    except:
        # File doesn't exist but that's ok because it's optional.
        return {}
    config = {}
    #print "Reading config file: %s" % file_loc
    for line in f.readlines():
        tokens = line.split(" = ")
        if len(tokens) != 2:
            raise Exception("Error parsing ~/.spacewalk-build-rc: %s" % line)
        config[tokens[0]] = strip(tokens[1])
        #print "   %s = %s" % (tokens[0], strip(tokens[1]))
    return config



class CLI:
    """ Parent command line interface class. """

    def main(self):
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
                help="Tag a new release of the package.")
        parser.add_option("--keep-version", dest="keep_version",
                action="store_true",
                help="Use spec file version/release to tag package.")
        (options, args) = parser.parse_args()

        if len(sys.argv) < 2:
            print parser.error("Must supply an argument. Try -h for help.")

        if options.debug:
            os.environ['DEBUG'] = "true"

        if options.tag:
            check_tag_exists(options.tag)

        global_config = read_global_config()

        # TODO: necessary?
        self._check_for_project_dir()

        config = self._read_project_config(global_config, options.tag,
                options.no_cleanup)

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
        tagger_class = VersionTagger
        if config.has_option("buildconfig", "builder"):
            builder_class = get_class_by_name(config.get("buildconfig", "builder"))
        if config.has_option("buildconfig", "tagger"):
            tagger_class = get_class_by_name(config.get("buildconfig", "tagger"))

        debug("Using builder class: %s" % builder_class)
        debug("Using tagger class: %s" % tagger_class)

        # Now that we have command line options, instantiate builder/tagger:
        if found_builder_options:
            builder = builder_class(
                    global_config=global_config,
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
        find_git_root()

    def _read_project_config(self, global_config, tag, no_cleanup):
        """
        Read and return project build properties if they exist.
        """
        # TODO: Could pass this into builders/taggers instead of looking it up
        # twice.
        project_name = get_project_name(tag=tag)
        debug("Determined package name to be: %s" % project_name)

        properties_file = os.path.join(os.getcwd(), "build.py.props")

        if tag:
            # Check for a build.py.props back when this tag was created:
            relative_dir = get_relative_project_dir(project_name, tag)
            temp_filename = "%s-%s" % (random.randint(1, 10000),
                    "build.py.props")
            properties_file = os.path.join(os.getcwd(), temp_filename)
            if global_config.has_key('RPMBUILD_BASEDIR'):
                properties_file = os.path.join(global_config[
                    'RPMBUILD_BASEDIR'], temp_filename)

            # Touch the file, if the git show fails it will remain empty.
            run_command("touch %s" % properties_file)
            cmd = "git show %s:%s%s" % (tag, relative_dir,
                    "build.py.props")
            debug(cmd)
            (status, output) = commands.getstatusoutput(cmd)
            if status == 0:
                f = open(properties_file, 'w')
                f.write(output)
                f.write("\n\n")
                f.close()

        debug("Checking build.py.props: %s" % properties_file)

        config = ConfigParser.ConfigParser()
        config.read(properties_file)

        # TODO: This should be safe but still feels wrong:
        if tag and not no_cleanup:
            # Delete the temp properties file we created.
            run_command("rm %s" % properties_file)

        return config

