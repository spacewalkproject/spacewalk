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
#
# Infrastructure for building Spacewalk and Satellite packages from git tags.
#

import commands
import os
import os.path
import sys

from string import strip
from optparse import OptionParser

def read_config():
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

def find_spec_file():
    """
    Find the first spec file in the current directory. (hopefully there's
    only one)

    Returns only the file name, rather than the full path.
    """
    for f in os.listdir(os.getcwd()):
        if f.endswith(".spec"):
            return f
    raise Exception("Unable to locate a spec file in %s", os.getcwd())

def main(tagger=None, builder=None):
    """
    Main method called by all build.py's which can provide their own
    specific implementations of taggers and builders.

    tagger = Class which inherits from the base Tagger class. (used for
        tagging package versions.
    builder = Class which inherits from the base Builder class. (used for
        building tar.gz's, srpms, and rpms)
    """
    if not builder:
        builder = Builder()

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
    (options, args) = parser.parse_args()

    if len(sys.argv) < 2:
        print parser.error("Must supply an argument. Try -h for help.")

    # Some options imply other options, handle those deps here:
    if options.srpm:
        options.tgz = True
    if options.rpm:
        options.tgz = True

    builder.run(options)



class Builder:
    """
    Parent builder class.

    Includes functionality for a standard Spacewalk package build. Packages
    which require other unusual behavior can subclass this to inject the
    desired behavior.
    """

    def __init__(self):
        """
        Builder must always be instantiated from the project directory where
        the .spec file is located. No changes to the working directory should
        be made here in the constructor.
        """
        self.config = read_config()

        self.spec_file_name = find_spec_file()

        self.options = None # set when we run

        # Various settings we look up in constructor as we don't necessarily
        # know what working directory we'll be using at various points during
        # the build.
        self.git_root = self._get_git_root() # project root dir
        self.rel_eng_dir = os.path.join(self.git_root, "rel-eng")
        self.relative_project_dir = self._get_relative_project_dir(
                self.git_root) # i.e. java/
        self.full_project_dir = os.getcwd()
        self.project_name = self._get_project_name()

        # If the user has a RPMBUILD_BASEDIR defined in ~/.spacewalk-build-rc,
        # use it, otherwise use the current working directory. (i.e. location
        # of build.py)
        self.rpmbuild_basedir = self.full_project_dir
        if self.config.has_key('RPMBUILD_BASEDIR'):
            self.rpmbuild_basedir = self.config['RPMBUILD_BASEDIR']

        # Set when we run():
        self.spec_file = None
        self.project_version = None
        self.rpmbuild_dir = None
        self.rpmbuild_sourcedir = None
        self.rpmbuild_builddir = None
        self.rpmbuild_dir_opts = None

    def run(self, options):
        """
        Perform the actions requested of the builder.

        NOTE: this method may do nothing if the user requested no build actions
        be performed. (i.e. only release tagging, etc)
        """

        self.options = options

        # Setup some remaining member variables now that we have access to
        # the command line options:
        self.project_version = self._get_project_version()
        temp_dir = "rpmbuild-%s-%s" % (self.project_name, self.project_version)
        self.rpmbuild_dir = os.path.join(self.rpmbuild_basedir, temp_dir)
        self.rpmbuild_sourcedir = os.path.join(self.rpmbuild_dir, "SOURCES")
        self.rpmbuild_builddir = os.path.join(self.rpmbuild_dir, "BUILD")
        self.rpmbuild_dir_opts = """--define "_sourcedir %s" --define "_builddir %s" --define "_srcrpmdir %s" --define "_rpmdir %s" """ % \
            (self.rpmbuild_basedir, self.rpmbuild_builddir,
                    self.rpmbuild_basedir, self.rpmbuild_basedir)
        self.spec_file = os.path.join(self.rpmbuild_sourcedir,
                self.spec_file_name)

        if options.tgz:
            self._tgz()
        if options.srpm:
            self._srpm()
        if options.rpm:
            self._rpm()

        self._cleanup()

    def _tgz(self):
        """ Create the .tar.gz required to build this package. """
        self._create_build_dirs()
        os.chdir(os.path.abspath(self.git_root))
        tgz_base = self._get_tgz_project_name()
        tgz = tgz_base + ".tar.gz"
        tgz_dir = tgz_base
        tag = self._get_build_tag()
        print "Creating %s from git tag: %s..." % (tgz, tag)
        timestamp = self._get_commit_timestamp(tag)

        archive_cmd = "git archive --format=tar --prefix=%s/ %s:%s | perl %s/tar-fixup-stamp-comment.pl %s %s | gzip -n -c - | tee %s/%s | ( cd %s/ && tar xzf - )" % \
            (tgz_dir, tag, self.relative_project_dir, self.rel_eng_dir, timestamp, tag, self.rpmbuild_sourcedir, tgz,
                    self.rpmbuild_sourcedir)
        #print archive_cmd
        (status, output) = commands.getstatusoutput(archive_cmd)
        if status > 0:
            print "ERROR: %s" % output
            sys.exit(1)
        (status, output) = commands.getstatusoutput("mv %s/%s %s/" %  \
                (self.rpmbuild_sourcedir, tgz, self.rpmbuild_basedir))
        print "Wrote: %s/%s" % (self.rpmbuild_basedir, tgz)

    def _srpm(self):
        """
        Build a source RPM.
        """
        self._create_build_dirs()
        os.chdir(self.full_project_dir)
        define_dist = ""
        if self.options.dist:
            define_dist = "--define 'dist %s'" % self.options.dist

        cmd = "rpmbuild %s %s --nodeps -bs %s" % (self.rpmbuild_dir_opts, define_dist, self.spec_file)
        #print cmd
        (status, output) = commands.getstatusoutput(cmd)
        print output

    def _rpm(self):
        """ Build an RPM. """
        self._create_build_dirs()
        os.chdir(self.full_project_dir)

        define_dist = ""
        if self.options.dist:
            define_dist = "--define 'dist %s'" % self.options.dist
        cmd = "rpmbuild %s %s --nodeps --clean -ba %s" % (self.rpmbuild_dir_opts, define_dist, self.spec_file)
        #print cmd
        (status, output) = commands.getstatusoutput(cmd)
        print output

    def _cleanup(self):
        """
        Remove all temporary files and directories.
        """
        commands.getoutput("rm -rf %s" % self.rpmbuild_dir)

    def _create_build_dirs(self):
        """
        Create the build directories. Can safely be called multiple times.
        """
        commands.getoutput("mkdir -p %s %s %s %s" % (self.rpmbuild_basedir,
            self.rpmbuild_dir, self.rpmbuild_sourcedir, self.rpmbuild_builddir))

    def _get_tgz_project_name(self):
        """
        Returns the project name for the .tar.gz to build. Normally this is
        just the project name, but in the case of Satellite packages it may
        be different.
        """
        return "%s-%s" % (self.project_name, self.project_version)

    def _get_build_tag(self):
        """ Return the git tag or SHA1 we should build. """
        if self.options.test:
            return self._get_git_head_sha1()
        else:
            tag = self._get_tgz_project_name() + "-1" # Assume -1 for now.
            (status, output) = commands.getstatusoutput(
                    "git ls-remote ./. --tag %s | awk '{ print $1 ; exit }'"
                    % tag)
            return output

    def _get_commit_timestamp(self, sha1_or_tag):
        """
        Get the timestamp of the git commit or tag we're building. Used to
        keep the hash the same on all .tar.gz's we generate for a particular
        version regardless of when they are generated.
        """
        (status, output) = commands.getstatusoutput("git rev-list --timestamp --max-count=1 %s | awk '{print $1}'" % sha1_or_tag)
        return output

    def build_srpms(self):
        builddir = os.getcwd()
        cmd = "rpmbuild --nodeps --define 'dist .%s' --define '_sourcedir %s' --define '_builddir %s' --define '_srcrpmdir %s' --define '_rpmdir %s' -bs %s" % ("el4", builddir, builddir, builddir, builddir, self.project_spec)
        (status, output) = commands.getstatusoutput(cmd)
        print output

    def _get_git_root(self):
        """
        Get the top-level git project directory.

        Returned as a full path.
        """
        cdup = commands.getoutput("git rev-parse --show-cdup")
        if cdup == "":
            cdup = "./"
        return os.path.abspath(cdup)

    def _get_relative_project_dir(self, git_root):
        """
        Returns the patch to the project we're working with relative to the
        git root.

        *MUST* be called before doing any os.cwd().

        i.e. java/, satellite/install/Spacewalk-setup/, etc.
        """
        current_dir = os.getcwd()
        relative = current_dir[len(git_root) + 1:] + "/"
        return relative

    def _get_project_name(self):
        """
        Get the project name from the spec file.

        Uses the spec file in the current git branch as opposed to the copy
        we make using git archive. This is done because we use this
        information to know what git tag to use to generate that archive.
        """
        spec_file_path = os.path.join(self.full_project_dir,
                self.spec_file_name)
        if not os.path.exists(spec_file_path):
            raise Exception("Unable to get project name from spec file: %s" %
                    spec_file_path)

        (status, output) = commands.getstatusoutput(
            "cat %s | grep 'Name:' | awk '{ print $2 ; exit }'" %
            spec_file_path)
        return output

    def _get_project_version(self):
        """
        Get the package version to build.

        Normally this is whatever is defined in the spec file's Version
        field.

        In the case of a --test build it will be the SHA1 for the HEAD commit
        of the current git branch.

        """
        if self.options.test:
            version = "git-" + self._get_git_head_sha1()
        else:
            spec_file_path = os.path.join(self.full_project_dir,
                    self.spec_file_name)
            if not os.path.exists(spec_file_path):
                raise Exception("Unable to get project name from spec file: %s"
                        % spec_file_path)
            version = commands.getoutput(
                    "cat %s | grep Version | awk '{ print $2 ; exit }'" %
                    spec_file_path)
        return version

    def _get_git_head_sha1(self):
        """ Return the SHA1 of the HEAD commit on the current git branch. """
        return commands.getoutput('git rev-parse --verify HEAD')




class UpstreamBuilder(Builder):
    """
    Builder for packages that rename and patch upstream versions.

    i.e. satellite-java build on spacewalk-java.
    """
    def __init__(self, spec_file, upstream_project_name):
        Builder.__init__(self, spec_file)
        self.upstream_project_name = upstream_project_name

    def _get_tgz_project_name(self):
        """
        Override parent method to return the Spacewalk project name for this
        Satellite package.
        """
        return "%s-%s" % (self.upstream_project_name, self.project_version)



    #def _get_current_git_branch(self):
    #    """
    #    Get the current git branch. Used to restore to after we checkout a
    #    package tag.

    #    Uses the output of git branch and looks for the line starting with
    #    an '*'.

    #    Expects the cwd to be inside a git repo.
    #
    #    If there is no current working branch (i.e. the user checked out using
    #    an SHA1 or tag), method will return None.
    #    """
    #    results = commands.getoutput("git branch")
    #    current_branch = None
    #    for branch in results.split("\n"):
    #        if branch.startswith("* "):
    #            current_branch = branch[2:]
    #            break
    #    if current_branch != "(no branch)":
    #        return current_branch
    #    return None

