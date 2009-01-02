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

from spacewalk.releng.common import BuildCommon, run_command, \
        check_tag_exists, debug, error_out, find_spec_file, \
        get_project_name, get_relative_project_dir

class Builder(BuildCommon):
    """
    Parent builder class.

    Includes functionality for a standard Spacewalk package build. Packages
    which require other unusual behavior can subclass this to inject the
    desired behavior.
    """

    def __init__(self, global_config=None, build_config=None, tag=None,
            dist=None, test=False, debug=False):
        BuildCommon.__init__(self, debug)

        self.dist = dist
        self.test = test

        self.project_name = get_project_name(tag=tag)

        # If the user has a RPMBUILD_BASEDIR defined in ~/.spacewalk-build-rc,
        # use it, otherwise use the current working directory. (i.e. location
        # of build.py)
        self.rpmbuild_basedir = os.getcwd()
        if global_config.has_key('RPMBUILD_BASEDIR'):
            self.rpmbuild_basedir = global_config['RPMBUILD_BASEDIR']

        # Determine which package version we should build:
        if tag:
            self.build_tag = tag
            self.build_version = self.build_tag[len(self.project_name + "-"):]
        else:
            self.build_version = self._get_latest_tagged_version()
            if self.build_version == None:
                error_out(["Unable to lookup latest package info from %s" %
                        file_path, "Perhaps you need to --tag-release first?"])
            self.build_tag = "%s-%s" % (self.project_name,
                    self.build_version)

        self.display_version = self._get_display_version()
        self.git_commit_id = self._get_build_commit()
        self.project_name_and_sha1 = "%s-%s" % (self.project_name,
                self.git_commit_id)

        self.relative_project_dir = get_relative_project_dir(
                project_name=self.project_name, commit=self.git_commit_id)

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

        # NOTE: These are defined later when/if we actually dump a copy of the
        # project source at the tag we're building. Only then can we search for
        # a spec file.
        self.spec_file_name = None
        self.spec_file = None

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
        self._setup_sources()

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

        if self.test:
            self._setup_test_specfile()

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

    def _setup_sources(self):
        """
        Create a copy of the git source for the project from the commit ID
        we're building.

        Created in the temporary rpmbuild SOURCES directory.
        """
        self._create_build_dirs()

        print "Building version: %s" % self.display_version
        os.chdir(os.path.abspath(self.git_root))
        print "Creating %s from git tag: %s..." % (self.tgz_filename,
                self.git_commit_id)
        timestamp = self._get_commit_timestamp(self.git_commit_id)

        debug("Copying git source to: %s" % self.rpmbuild_gitcopy)
        archive_cmd = "git archive --format=tar --prefix=%s/ %s:%s | perl %s/tar-fixup-stamp-comment.pl %s %s | gzip -n -c - | tee %s/%s" % \
            (
                    self.tgz_dir,
                    self.git_commit_id,
                    self.relative_project_dir,
                    self.rel_eng_dir,
                    timestamp,
                    self.git_commit_id,
                    self.rpmbuild_sourcedir,
                    self.tgz_filename
            )
        debug(archive_cmd)
        run_command(archive_cmd)

        # Extract the source so we can get at the spec file, etc.
        run_command("cd %s/ && tar xzf %s" % (self.rpmbuild_sourcedir,
            self.tgz_filename))

        # NOTE: The spec file we actually use is the one exported by git
        # archive into the temp build directory. This is done so we can
        # modify the version/release on the fly when building test rpms
        # that use a git SHA1 for their version.
        self.spec_file_name = find_spec_file(in_dir=self.rpmbuild_gitcopy)
        self.spec_file = os.path.join(self.rpmbuild_gitcopy, self.spec_file_name)
        debug("Using spec file: %s" % self.spec_file)

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
            tag_sha1 = run_command(
                    "git ls-remote ./. --tag %s | awk '{ print $1 ; exit }'"
                    % self.build_tag)
            commit_id = run_command('git rev-list --max-count=1 %s' % 
                    tag_sha1)
            return commit_id

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



class NoTgzBuilder(Builder):
    """
    Builder for packages that do not require the creation of a tarball.
    Usually these packages have source tarballs checked directly into git.
    i.e. most of the packages in spec-tree.
    """
    def _tgz(self):
        """ Override parent behavior, we already have a tgz. """
        # TODO: Does it make sense to allow user to create a tgz for this type
        # of project?
        self._setup_sources()

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



class SatelliteBuilder(NoTgzBuilder):
    """
    Builder for packages that are based off some upstream version in Spacewalk
    git. Commits applied in Satellite git become patches applied to the 
    upstream Spacewalk tarball.

    i.e. satellite-java-0.4.0-5 built from spacewalk-java-0.4.0-1 and any 
    patches applied in satellite git.
    i.e. spacewalk-setup-0.4.0-2 built from spacewalk-setup-0.4.0-1 and any
    patches applied in satellite git.
    """
    def __init__(self, global_config=None, build_config=None, tag=None,
            dist=None, test=False, debug=False):

        NoTgzBuilder.__init__(self, global_config=global_config,
                build_config=build_config, tag=tag, dist=dist,
                test=test, debug=debug)

        if not build_config or not build_config.has_option("buildconfig", 
                "upstream_name"):
            # No upstream_name defined, assume we're keeping the project name:
            self.upstream_name = self.project_name
        else:
            self.upstream_name = build_config.get("buildconfig", "upstream_name")
        # Need to assign these after we've exported a copy of the spec file:
        self.upstream_version = None 
        self.upstream_tag = None

    def _setup_sources(self):
        # TODO: Wasteful step here, all we really need is a way to look for a
        # spec file at the point in time this release was tagged.
        NoTgzBuilder._setup_sources(self)
        # If we knew what it was named at that point in time we could just do:
        # Export a copy of our spec file at the revision to be built:
#        cmd = "git show %s:%s%s > %s" % (self.git_commit_id,
#                self.relative_project_dir, self.spec_file_name,
#                self.spec_file)
#        debug(cmd)
        self._create_build_dirs()

        self.upstream_version = self._get_upstream_version()
        self.upstream_tag = "%s-%s-1" % (self.upstream_name, 
                self.upstream_version)

        print("Building upstream tgz for tag: %s" % (self.upstream_tag))
        check_tag_exists(self.upstream_tag)

        self.spec_file = os.path.join(self.rpmbuild_sourcedir, self.spec_file_name)

        # TODO: grab the upstream tgz
        # place both in rpmbuild_sourcedir
        pass

    def _get_upstream_version(self):
        """
        Get the upstream version. Checks for "upstreamversion" in the spec file
        and uses it if found. Otherwise assumes the upstream version is equal 
        to the version we're building.

        i.e. satellite-java-0.4.15 will be built on spacewalk-java-0.4.15
        with just the package release being incremented on rebuilds. 
        """

        # Use upstreamversion if defined in the spec file:
        (status, output) = commands.getstatusoutput(
            "cat %s | grep 'define upstreamversion' | awk '{ print $3 ; exit }'" %
            self.spec_file)
        if status == 0 and output != "":
            return output

        # Otherwise, assume we use our version:
        return self.display_version

    def _get_rpmbuild_dir_options(self):
        """
        Override parent behavior slightly.

        These packages store tar's, patches, etc, directly in their project
        dir, use the git copy we create as the sources directory when
        building package so everything can be found:
        """
        return """--define "_sourcedir %s" --define "_builddir %s" --define "_srcrpmdir %s" --define "_rpmdir %s" """ % \
            (self.rpmbuild_sourcedir, self.rpmbuild_builddir,
                    self.rpmbuild_basedir, self.rpmbuild_basedir)


