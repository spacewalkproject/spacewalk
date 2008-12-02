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

""" Code for building Spacewalk/Satellite tarballs, srpms, and rpms. """

import os
import sys
import commands

from spacewalk.releng.common import BuildCommon, read_config, run_command, \
        check_tag_exists, debug

class Builder(BuildCommon):
    """
    Parent builder class.

    Includes functionality for a standard Spacewalk package build. Packages
    which require other unusual behavior can subclass this to inject the
    desired behavior.
    """

    def __init__(self, tag=None, dist=None, test=False, debug=False):
        BuildCommon.__init__(self, debug)

        self.dist = dist
        self.test = test

        # If the user has a RPMBUILD_BASEDIR defined in ~/.spacewalk-build-rc,
        # use it, otherwise use the current working directory. (i.e. location
        # of build.py)
        self.config = read_config()
        self.rpmbuild_basedir = self.full_project_dir
        if self.config.has_key('RPMBUILD_BASEDIR'):
            self.rpmbuild_basedir = self.config['RPMBUILD_BASEDIR']

        # Determine which package version we should build:
        if tag:
            self.build_tag = tag
            self.build_version = self.build_tag[len(self.project_name + "-"):]
        else:
            self.build_version = self._get_latest_tagged_version()
            self.build_tag = "%s-%s" % (self.project_name,
                    self.build_version)
        check_tag_exists(self.build_tag)

        self.display_version = self._get_display_version()
        self.git_commit_id = self._get_build_commit()
        self.project_name_and_sha1 = "%s-%s" % (self.project_name,
                self.git_commit_id)

        tgz_base = self._get_tgz_name_and_ver()
        self.tgz_filename = tgz_base + ".tar.gz"
        self.tgz_dir = tgz_base

        temp_dir = "rpmbuild-%s" % self.project_name_and_sha1
        self.rpmbuild_dir = os.path.join(self.rpmbuild_basedir, temp_dir)
        self.rpmbuild_sourcedir = os.path.join(self.rpmbuild_dir, "SOURCES")
        self.rpmbuild_builddir = os.path.join(self.rpmbuild_dir, "BUILD")

        # A copy of the git code from commit we're building:
        self.rpmbuild_gitcopy = os.path.join(self.rpmbuild_sourcedir,
                self.tgz_dir)

        # NOTE: The spec file we actually use is the one exported by git
        # archive into the temp build directory. This is done so we can
        # modify the version/release on the fly when building test rpms
        # that use a git SHA1 for their version.
        self.spec_file = os.path.join(self.rpmbuild_gitcopy, self.spec_file_name)

    def run(self, options):
        """
        Perform the actions requested of the builder.

        NOTE: this method may do nothing if the user requested no build actions
        be performed. (i.e. only release tagging, etc)
        """

        self._validate_options(options)

        if options.tgz:
            self._tgz()
        if options.srpm:
            self._srpm()
        if options.rpm:
            self._rpm()

        if not options.no_cleanup:
            self._cleanup()

    def _validate_options(self, options):
        """ Check for option combinations that make no sense. """
        if options.test and options.tag:
            raise Exception("Cannot build test version of specific tag.")

    def _tgz(self):
        """ Create the .tar.gz required to build this package. """
        self._create_git_copy()

        run_command("cp %s/%s %s/" %  \
                (self.rpmbuild_sourcedir, self.tgz_filename,
                    self.rpmbuild_basedir))

        print "Wrote: %s/%s" % (self.rpmbuild_basedir, self.tgz_filename)

    def _srpm(self):
        """
        Build a source RPM.
        """
        self._create_build_dirs()

        if self.test:
            self._setup_test_specfile()

        # TODO: Looks wrong, this might be using the latest spec file in git
        # when it should be using the spec file from the git commit we're
        # building:
        os.chdir(self.full_project_dir)

        define_dist = ""
        if self.dist:
            define_dist = "--define 'dist %s'" % self.dist

        cmd = "rpmbuild %s %s --nodeps -bs %s" % \
                (self._get_rpmbuild_dir_options(), define_dist, self.spec_file)
        output = run_command(cmd)
        print output

    def _rpm(self):
        """ Build an RPM. """
        self._create_build_dirs()

        define_dist = ""
        if self.dist:
            define_dist = "--define 'dist %s'" % self.dist
        cmd = "rpmbuild %s %s --nodeps --clean -ba %s" % \
                (self._get_rpmbuild_dir_options(), define_dist, self.spec_file)
        output = run_command(cmd)
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

    def _setup_test_specfile(self):
        if self.test:
            # If making a test rpm we need to get a little crazy with the spec
            # file we're building off. (note that this is a temp copy of the
            # spec) Swap out the actual release for one that includes the git
            # SHA1 we're building for our test package:
            cmd = "perl %s/test-setup-specfile.pl %s %s %s-%s %s" % \
                    (
                        self.rel_eng_dir,
                        self.spec_file,
                        self.git_commit_id,
                        self.project_name,
                        self.display_version,
                        self.tgz_filename
                    )
            run_command(cmd)

    def _create_git_copy(self):
        """
        Create a copy of the git source for the project from the commit ID
        we're building.

        Created in the temporary rpmbuild SOURCES directory.
        """
        self._create_build_dirs()

        print "Building version: %s" % self.display_version
        debug("Using spec file: %s" % self.spec_file)
        os.chdir(os.path.abspath(self.git_root))
        print "Creating %s from git tag: %s..." % (self.tgz_filename,
                self.git_commit_id)
        timestamp = self._get_commit_timestamp(self.git_commit_id)

        archive_cmd = "git archive --format=tar --prefix=%s/ %s:%s | perl %s/tar-fixup-stamp-comment.pl %s %s | gzip -n -c - | tee %s/%s | ( cd %s/ && tar xzf - )" % \
            (
                    self.tgz_dir,
                    self.git_commit_id,
                    self.relative_project_dir,
                    self.rel_eng_dir,
                    timestamp,
                    self.git_commit_id,
                    self.rpmbuild_sourcedir,
                    self.tgz_filename,
                    self.rpmbuild_sourcedir
            )
        run_command(archive_cmd)

    def _get_rpmbuild_dir_options(self):
        return """--define "_sourcedir %s" --define "_builddir %s" --define "_srcrpmdir %s" --define "_rpmdir %s" """ % \
            (self.rpmbuild_sourcedir, self.rpmbuild_builddir,
                    self.rpmbuild_basedir, self.rpmbuild_basedir)

    def _get_tgz_name_and_ver(self):
        """
        Returns the project name for the .tar.gz to build. Normally this is
        just the project name, but in the case of Satellite packages it may
        be different.
        """
        return "%s-%s" % (self.project_name, self.display_version)

    def _get_build_commit(self):
        """ Return the git commit we should build. """
        if self.test:
            return self._get_git_head_commit()
        else:
            output = run_command(
                    "git ls-remote ./. --tag %s | awk '{ print $1 ; exit }'"
                    % self.build_tag)
            return output

    def _get_commit_timestamp(self, sha1_or_tag):
        """
        Get the timestamp of the git commit or tag we're building. Used to
        keep the hash the same on all .tar.gz's we generate for a particular
        version regardless of when they are generated.
        """
        output = run_command(
                "git rev-list --timestamp --max-count=1 %s | awk '{print $1}'"
                % sha1_or_tag)
        return output

    def _get_display_version(self):
        """
        Get the package display version to build.

        Normally this is whatever is rel-eng/packages/. In the case of a --test
        build it will be the SHA1 for the HEAD commit of the current git
        branch.
        """
        if self.test:
            version = "git-" + self._get_git_head_commit()
        else:
            version = self.build_version.split("-")[0]
        return version

    def _get_git_head_commit(self):
        """ Return the SHA1 of the HEAD commit on the current git branch. """
        return commands.getoutput('git rev-parse --verify HEAD')



class FromTarballBuilder(Builder):
    """
    Builder for packages that are built from a tarball stored directly in
    git.

    i.e. most of the packages in spec-tree.
    """

    def _tgz(self):
        """ Override parent behavior, we already have a tgz. """
        #raise Exception("Cannot build .tar.gz for project %s" %
        #        self.project_name)
        self._create_git_copy()

    def _get_rpmbuild_dir_options(self):
        """
        Override parent behavior slightly.

        These packages store tar's, patches, etc, directly in their project
        dir, use the git copy we create as the sources directory when
        building package so everything can be found:
        """
        return """--define "_sourcedir %s" --define "_builddir %s" --define "_srcrpmdir %s" --define "_rpmdir %s" """ % \
            (self.rpmbuild_gitcopy, self.rpmbuild_builddir,
                    self.rpmbuild_basedir, self.rpmbuild_basedir)

    def _setup_test_specfile(self):
        """ Override parent behavior. """
        if self.test:
            # If making a test rpm we need to get a little crazy with the spec
            # file we're building off. (note that this is a temp copy of the
            # spec) Swap out the actual release for one that includes the git
            # SHA1 we're building for our test package:
            cmd = "perl %s/test-setup-specfile.pl %s %s" % \
                    (
                        self.rel_eng_dir,
                        self.spec_file,
                        self.git_commit_id
                    )
            run_command(cmd)



#class UpstreamBuilder(Builder):
#    """
#    Builder for packages that rename and patch upstream versions.

#    i.e. satellite-java build on spacewalk-java.
#    """
#    def __init__(self, spec_file, upstream_project_name):
#        Builder.__init__(self, spec_file)
#        self.upstream_project_name = upstream_project_name

#    def _get_tgz_name_and_ver(self):
#        """
#        Override parent method to return the Spacewalk project name for this
#        Satellite package.
#        """
#        return "%s-%s" % (self.upstream_project_name, self.display_version)




