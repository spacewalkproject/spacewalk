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

BUILD_PROPS_FILENAME = "build.py.props"
GLOBAL_BUILD_PROPS_FILENAME = "global.build.py.props"
GLOBALCONFIG_SECTION = "globalconfig"
DEFAULT_BUILDER = "default_builder"
DEFAULT_TAGGER = "default_tagger"
ASSUMED_NO_TAR_GZ_PROPS = """
[buildconfig]
builder = spacewalk.releng.builder.NoTgzBuilder
tagger = spacewalk.releng.tagger.ReleaseTagger
"""

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

def lookup_build_dir():
    """
    Read build_dir in from ~/.spacewalk-build-rc if it exists, otherwise
    return the current working directory.
    """
    file_loc = os.path.expanduser("~/.spacewalk-build-rc")
    try:
        f = open(file_loc)
    except:
        # File doesn't exist but that's ok because it's optional.
        return os.getcwd()
    config = {}
    for line in f.readlines():
        if line.strip() == "":
            continue
        tokens = line.split("=")
        if len(tokens) != 2:
            raise Exception("Error parsing ~/.spacewalk-build-rc: %s" % line)
        config[tokens[0]] = strip(tokens[1])

    build_dir = os.getcwd()
    if config.has_key('RPMBUILD_BASEDIR'):
        build_dir = config["RPMBUILD_BASEDIR"]

    return build_dir



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

        build_dir = lookup_build_dir()
        global_config = self._read_global_config()
        if options.tag:
            check_tag_exists(options.tag)

        pkg_config = self._read_project_config(build_dir, options.tag,
                options.no_cleanup)

        # Check for builder options and tagger options, if one or more from both
        # groups are found, error out:
        found_builder_options = (options.tgz or options.srpm or options.rpm)
        found_tagger_options = (options.tag_release)
        if found_builder_options and found_tagger_options:
            error_out("Cannot invoke both build and tag options at the " +
                    "same time.")

        # Use project specific config to determine which builder/tagger to use.
        # If none exists, use the global default builder/tagger.
        builder_class = None
        tagger_class = None
        if pkg_config.has_option("buildconfig", "builder"):
            builder_class = get_class_by_name(pkg_config.get("buildconfig",
                "builder"))
        else:
            builder_class = get_class_by_name(global_config.get(
                GLOBALCONFIG_SECTION, DEFAULT_BUILDER))
        if pkg_config.has_option("buildconfig", "tagger"):
            tagger_class = get_class_by_name(pkg_config.get("buildconfig",
                "tagger"))
        else:
            tagger_class = get_class_by_name(global_config.get(
                GLOBALCONFIG_SECTION, DEFAULT_TAGGER))

        debug("Using builder class: %s" % builder_class)
        debug("Using tagger class: %s" % tagger_class)

        # Now that we have command line options, instantiate builder/tagger:
        if found_builder_options:
            builder = builder_class(
                    build_dir=build_dir,
                    pkg_config=pkg_config,
                    global_config=global_config,
                    tag=options.tag,
                    dist=options.dist,
                    test=options.test)
            builder.run(options)

        if found_tagger_options:
            tagger = tagger_class(keep_version=options.keep_version)
            tagger.run(options)

    def _read_global_config(self):
        """
        Read global build.py configuration from the rel-eng dir of the git
        repository we're being run from.
        """
        rel_eng_dir = os.path.join(find_git_root(), "rel-eng")
        filename = os.path.join(rel_eng_dir, GLOBAL_BUILD_PROPS_FILENAME)
        config = ConfigParser.ConfigParser()
        config.read(filename)

        # Verify the config contains what we need from it:
        required_global_config = [
                (GLOBALCONFIG_SECTION, DEFAULT_BUILDER),
                (GLOBALCONFIG_SECTION, DEFAULT_TAGGER),
        ]
        for section, option in required_global_config:
            if not config.has_section(section) or not \
                config.has_option(section, option):
                    error_out("%s missing required config: %s %s" % (
                        filename, section, option))

        return config

    def _read_project_config(self, build_dir, tag, no_cleanup):
        """
        Read and return project build properties if they exist.

        This is done by checking for a build.py.props in the projects
        directory at the time the tag was made.

        To accomodate older tags prior to build.py, we also check for
        the presence of a Makefile with NO_TAR_GZ, and include a hack to
        assume build properties in this scenario.

        If no project specific config can be found, use the global config.
        """
        # TODO: Could pass this into builders/taggers instead of looking it up
        # twice.
        project_name = get_project_name(tag=tag)
        debug("Determined package name to be: %s" % project_name)

        properties_file = None
        wrote_temp_file = False

        # Use the properties file in the current project directory, if it
        # exists:
        current_props_file = os.path.join(os.getcwd(), BUILD_PROPS_FILENAME)
        if (os.path.exists(current_props_file)):
            properties_file = current_props_file

        # Check for a build.py.props back when this tag was created and use it
        # instead. (if it exists)
        if tag:
            relative_dir = get_relative_project_dir(project_name, tag)

            cmd = "git show %s:%s%s" % (tag, relative_dir,
                    BUILD_PROPS_FILENAME)
            debug(cmd)
            (status, output) = commands.getstatusoutput(cmd)

            temp_filename = "%s-%s" % (random.randint(1, 10000),
                    BUILD_PROPS_FILENAME)
            temp_props_file = os.path.join(build_dir, temp_filename)

            if status == 0:
                properties_file = temp_props_file
                f = open(properties_file, 'w')
                f.write(output)
                f.close()
                wrote_temp_file = True
            else:
                # HACK: No build.py.props found, but to accomodate packages
                # tagged before they existed, check for a Makefile with
                # NO_TAR_GZ defined and make some assumptions based on that.
                cmd = "git show %s:%s%s | grep NO_TAR_GZ" % \
                        (tag, relative_dir, "Makefile")
                debug(cmd)
                (status, output) = commands.getstatusoutput(cmd)
                if status == 0 and output != "":
                    properties_file = temp_props_file
                    debug("Found Makefile with NO_TAR_GZ")
                    f = open(properties_file, 'w')
                    f.write(ASSUMED_NO_TAR_GZ_PROPS)
                    f.close()
                    wrote_temp_file = True

        config = ConfigParser.ConfigParser()
        if properties_file != None:
            debug("Using build properties: %s" % properties_file)
            config.read(properties_file)
        else:
            debug("Unable to locate build properties for this package.")

        # TODO: Not thrilled with this:
        if wrote_temp_file and not no_cleanup:
            # Delete the temp properties file we created.
            run_command("rm %s" % properties_file)

        return config

