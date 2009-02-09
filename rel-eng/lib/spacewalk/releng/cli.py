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
        check_tag_exists, get_latest_tagged_version

DEFAULT_BUILD_DIR = "/tmp/spacewalk-build"
DEFAULT_CVS_BUILD_DIR = os.path.join(DEFAULT_BUILD_DIR, "cvswork")
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
    build_dir = DEFAULT_BUILD_DIR
    file_loc = os.path.expanduser("~/.spacewalk-build-rc")
    try:
        f = open(file_loc)
    except:
        # File doesn't exist but that's ok because it's optional.
        return build_dir

    config = {}
    for line in f.readlines():
        if line.strip() == "":
            continue
        tokens = line.split("=")
        if len(tokens) != 2:
            raise Exception("Error parsing ~/.spacewalk-build-rc: %s" % line)
        config[tokens[0]] = strip(tokens[1])

    if config.has_key('RPMBUILD_BASEDIR'):
        build_dir = config["RPMBUILD_BASEDIR"]

    return build_dir



class CLI:
    """ Parent command line interface class. """

    def main(self):
        usage = "usage: %prog [options] arg"
        parser = OptionParser(usage)

        # Options for building tar.gz, srpm, and rpm:
        parser.add_option("--tgz", dest="tgz", action="store_true",
                help="Build .tar.gz")
        parser.add_option("--srpm", dest="srpm", action="store_true",
                help="Build srpm")
        parser.add_option("--rpm", dest="rpm", action="store_true",
                help="Build rpm")
        parser.add_option("--dist", dest="dist", metavar="DISTTAG",
                help="Dist tag to apply to srpm and/or rpm. (i.e. .el5)")
        parser.add_option("--test", dest="test", action="store_true",
                help="use current branch HEAD instead of latest package tag")
        parser.add_option("--no-cleanup", dest="no_cleanup", action="store_true",
                help="do not clean up temporary build directories/files")
        parser.add_option("--tag", dest="tag", metavar="PKGTAG",
                help="build a specific tag instead of the latest version " +
                    "(i.e. spacewalk-java-0.4.0-1)")

        # Options for submitting srpms to brew or koji:
        parser.add_option("--brew", dest="brew", metavar="BREWTAG",
                help="Submit srpm for build in a brew tag.")
        parser.add_option("--koji", dest="koji", metavar="KOJITAG",
                help="Submit srpm for build in a koji tag.")
        parser.add_option("--koji-opts", dest="koji_opts", metavar="KOJIOPTIONS",
                help="%s %s %s" %
                (
                    "Options to use with brew/koji command.",
                    "Tag and package name will be appended automatically.",
                    "Default is 'build --nowait'.",
                ))

        # Options used for many different activities:
        parser.add_option("--debug", dest="debug", action="store_true",
                help="print debug messages", default=False)
        parser.add_option("--offline", dest="offline", action="store_true",
                help="do not attempt any remote communication (avoid using this please)",
                default=False)

        # Options for tagging new package releases:
        parser.add_option("--tag-release", dest="tag_release",
                action="store_true",
                help="Tag a new release of the package.")
        parser.add_option("--keep-version", dest="keep_version",
                action="store_true",
                help="Use spec file version/release to tag package.")

        # Options for other high level tasks:
        parser.add_option("--untagged-diffs", dest="untagged_report",
                action="store_true",
                help= "%s %s %s" % (
                    "Print out diffs for all packages with changes between",
                    "their most recent tag and HEAD. Useful for determining",
                    "which packages are in need of a re-tag."
                ))
        parser.add_option("--cvs-release", dest="cvs_release",
                action="store_true", help="%s %s" % (
                    "Import sources into CVS, tag, and build package using",
                    "brew/koji. Relies on rel-eng configuration to know which"
                    "CVS repository and build system to use."
                ))

        (options, args) = parser.parse_args()

        if len(sys.argv) < 2:
            print parser.error("Must supply an argument. Try -h for help.")

        global_config = self._read_global_config()

        if options.debug:
            os.environ['DEBUG'] = "true"

        # TODO: Shortcut here, build.py does some things unrelated to
        # building/tagging packages, check for these options, do what's
        # requested, and exit rather than start looking up data specific
        # to building etc. This really should be cleaned up.
        if options.untagged_report:
            self._run_untagged_report(global_config)
            sys.exit(1)

        # TODO: Another shortcut, clean this up when refactoring to a command
        # based model:
        if options.cvs_release:
            self._run_cvs_release(global_config)
            sys.exit(1)

        # Check for builder options and tagger options, if one or more from both
        # groups are found, error out:
        (building, tagging) = self._validate_options(options)

        build_dir = lookup_build_dir()
        package_name = get_project_name(tag=options.tag)

        build_tag = None
        build_version = None
        # Determine which package version we should build:
        if options.tag:
            build_tag = options.tag
            build_version = build_tag[len(package_name + "-"):]
        elif building:
            build_version = get_latest_tagged_version(package_name)
            if build_version == None:
                error_out(["Unable to lookup latest package info.",
                        "Perhaps you need to --tag-release first?"])
            build_tag = "%s-%s" % (package_name, build_version)

        if not options.test and building:
            check_tag_exists(build_tag, offline=options.offline)

        pkg_config = self._read_project_config(package_name, build_dir,
                options.tag, options.no_cleanup)

        # Actually do things:
        if building:
            self._run_builder(package_name, build_tag, build_version, options,
                    pkg_config, global_config, build_dir)
        elif tagging:
            self._run_tagger(options, pkg_config, global_config)

    def _run_builder(self, package_name, build_tag, build_version, options,
            pkg_config, global_config, build_dir):

        builder_class = None
        if pkg_config.has_option("buildconfig", "builder"):
            builder_class = get_class_by_name(pkg_config.get("buildconfig",
                "builder"))
        else:
            builder_class = get_class_by_name(global_config.get(
                GLOBALCONFIG_SECTION, DEFAULT_BUILDER))
        debug("Using builder class: %s" % builder_class)

        # Instantiate the builder:
        builder = builder_class(
                name=package_name,
                version=build_version,
                tag=build_tag,
                build_dir=build_dir,
                pkg_config=pkg_config,
                global_config=global_config,
                dist=options.dist,
                test=options.test,
                offline=options.offline)

        builder.run(options)

    def _run_tagger(self, options, pkg_config, global_config):
        tagger_class = None
        if pkg_config.has_option("buildconfig", "tagger"):
            tagger_class = get_class_by_name(pkg_config.get("buildconfig",
                "tagger"))
        else:
            tagger_class = get_class_by_name(global_config.get(
                GLOBALCONFIG_SECTION, DEFAULT_TAGGER))
        debug("Using tagger class: %s" % tagger_class)

        tagger = tagger_class(global_config=global_config,
                keep_version=options.keep_version)
        tagger.run(options)

    def _run_untagged_report(self, global_config):
        """
        Display a report of all packages with differences between HEAD and
        their most recent tag, as well as a patch for that diff. Used to
        determine which packages are in need of a rebuild.
        """
        print("Scanning for packages that may need a --tag-release...")
        print("")
        git_root = find_git_root()
        rel_eng_dir = os.path.join(git_root, "rel-eng")
        os.chdir(git_root)
        package_metadata_dir = os.path.join(rel_eng_dir, "packages")
        for root, dirs, files in os.walk(package_metadata_dir):
            for md_file in files:
                if md_file[0] == '.':
                    continue
                f = open(os.path.join(package_metadata_dir, md_file))
                (version, relative_dir) = f.readline().strip().split(" ")
                project_dir = os.path.join(git_root, relative_dir)
                self._print_diff(global_config, md_file, version, project_dir)

    def _run_cvs_release(self, global_config):
        """
        Import sources into CVS, tag and build in the build system configured
        for this git repository.
        """
        print("Building release from CVS...")

        if not global_config.has_section("cvs"):
            error_out("No 'cvs' section found in global.build.py.props")

        if not global_config.has_option("cvs", "cvsroot"):
            error_out(["Cannot build from CVS",
                "no 'cvsroot' defined in global.build.py.props"])

        if not global_config.has_option("cvs", "branches"):
            error_out(["Cannot build from CVS",
                "no branches defined in global.build.py.props"])

        cvs_root = global_config.get("cvs", "cvsroot")
        debug("cvs_root = %s" % cvs_root)
        # TODO: if it looks like we need custom CVSROOT's for different users,
        # allow setting of a property to lookup in ~/.spacewalk-build-rc to
        # use instead. (if defined)
        cvs_workdir = DEFAULT_CVS_BUILD_DIR
        debug("cvs_workdir = %s" % cvs_workdir)
        commands.getoutput("mkdir -p %s" % cvs_workdir)
        cvs_branches = global_config.get("cvs", "branches").split(" ")
        print("cvs_branches = %s" % cvs_branches)

    def _print_diff(self, global_config, package_name, version, project_dir):
        """
        Print a diff between the most recent package tag and HEAD, if
        necessary.
        """
        last_tag = "%s-%s" % (package_name, version)
        os.chdir(project_dir)
        patch_command = "git diff --relative %s..%s" % \
                (last_tag, "HEAD")
        output = run_command(patch_command)

        # If the diff contains 1 line then there is no diff:
        linecount = len(output.split("\n"))
        if linecount == 1:
            return

        # Otherwise, print out info on the diff for this package:
        print("#" * len(package_name))
        print(package_name)
        print("#" * len(package_name))
        print("")
        print patch_command
        print("")
        print(output)
        print("")
        print("")
        print("")
        print("")
        print("")

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

    def _read_project_config(self, project_name, build_dir, tag, no_cleanup):
        """
        Read and return project build properties if they exist.

        This is done by checking for a build.py.props in the projects
        directory at the time the tag was made.

        To accomodate older tags prior to build.py, we also check for
        the presence of a Makefile with NO_TAR_GZ, and include a hack to
        assume build properties in this scenario.

        If no project specific config can be found, use the global config.
        """
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

    def _validate_options(self, options):
        found_builder_options = (options.tgz or options.srpm or options.rpm)
        found_tagger_options = (options.tag_release)
        if found_builder_options and found_tagger_options:
            error_out("Cannot invoke both build and tag options at the " +
                    "same time.")
        if options.srpm and options.rpm:
            error_out("Please choose only one of --srpm and --rpm")
        if (options.brew or options.koji) and not (options.rpm or options.srpm):
            error_out("Must specify --srpm or --rpm with --brew/--koji")
        if options.test and options.tag:
            error_out("Cannot build test version of specific tag.")
        return (found_builder_options, found_tagger_options)
