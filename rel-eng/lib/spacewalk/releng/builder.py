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

""" Code for building Spacewalk/Satellite tarballs, srpms, and rpms. """

import os
import re
import sys
import string
import commands

from spacewalk.releng.common import *

DEFAULT_KOJI_OPTS = "build --nowait"
DEFAULT_CVS_BUILD_DIR = "cvswork"

# List of CVS files to protect when syncing git with a CVS module:
CVS_PROTECT_FILES = ('branch', 'CVS', '.cvsignore', 'Makefile', 'sources')

class Builder(object):
    """
    Parent builder class.

    Includes functionality for a standard Spacewalk package build. Packages
    which require other unusual behavior can subclass this to inject the
    desired behavior.
    """

    def __init__(self, name=None, version=None, tag=None, build_dir=None,
            pkg_config=None, global_config=None, user_config=None, dist=None,
            test=False, offline=False):

        self.git_root = find_git_root()
        self.rel_eng_dir = os.path.join(self.git_root, "rel-eng")

        self.project_name = name
        self.build_tag = tag
        self.build_version = version
        self.dist = dist
        self.test = test
        self.global_config = global_config
        self.user_config = user_config
        self.offline=offline
        self.no_cleanup = False

        self.rpmbuild_basedir = build_dir
        self.display_version = self._get_display_version()

        self.git_commit_id = get_build_commit(tag=self.build_tag, 
                test=self.test)
        self.project_name_and_sha1 = "%s-%s" % (self.project_name,
                self.git_commit_id)

        self.relative_project_dir = get_relative_project_dir(
                project_name=self.project_name, commit=self.git_commit_id)

        tgz_base = self._get_tgz_name_and_ver()
        self.tgz_filename = tgz_base + ".tar.gz"
        self.tgz_dir = tgz_base

        temp_dir = "rpmbuild-%s" % self.project_name_and_sha1
        self.rpmbuild_dir = os.path.join(self.rpmbuild_basedir, temp_dir)
        if os.path.exists(self.rpmbuild_dir):
            print("WARNING: rpmbuild directory already exists, removing...")
            run_command("rm -rf self.rpmbuild_dir")
        self.rpmbuild_sourcedir = os.path.join(self.rpmbuild_dir, "SOURCES")
        self.rpmbuild_builddir = os.path.join(self.rpmbuild_dir, "BUILD")

        # A copy of the git code from commit we're building:
        self.rpmbuild_gitcopy = os.path.join(self.rpmbuild_sourcedir,
                self.tgz_dir)

        # Set to true if we've already created a tgz:
        self.ran_tgz = False

        # NOTE: These are defined later when/if we actually dump a copy of the
        # project source at the tag we're building. Only then can we search for
        # a spec file.
        self.spec_file_name = None
        self.spec_file = None

        # List of full path to all sources for this package.
        self.sources = []

        # Set to path to srpm once we build one.
        self.srpm_location = None

        # Configure CVS variables if possible. Will check later that
        # they're actually defined if the user requested CVS work be done.
        if self.global_config.has_section("cvs"):
            if self.global_config.has_option("cvs", "cvsroot"):
                self.cvs_root = self.global_config.get("cvs", "cvsroot")
                debug("cvs_root = %s" % self.cvs_root)
            if self.global_config.has_option("cvs", "branches"):
                self.cvs_branches = \
                    global_config.get("cvs", "branches").split(" ")

        # TODO: if it looks like we need custom CVSROOT's for different users,
        # allow setting of a property to lookup in ~/.spacewalk-build-rc to
        # use instead. (if defined)
        self.cvs_workdir = os.path.join(self.rpmbuild_basedir,
                DEFAULT_CVS_BUILD_DIR)
        debug("cvs_workdir = %s" % self.cvs_workdir)

        self.cvs_package_workdir = os.path.join(self.cvs_workdir,
                self.project_name)

        # When syncing files with CVS, only copy files with these extensions:
        self.cvs_copy_extensions = (".spec", ".patch")

    def run(self, options):
        """
        Perform the actions requested of the builder.

        NOTE: this method may do nothing if the user requested no build actions
        be performed. (i.e. only release tagging, etc)
        """
        print("Building package [%s]" % (self.build_tag))
        self.no_cleanup = options.no_cleanup

        if options.tgz:
            self.tgz()
        if options.srpm:
            self._srpm()
        if options.rpm:
            self._rpm()

        if options.release:
            self.release()
        elif options.cvs_release:
            self._cvs_release()
        elif options.koji_release:
            self._koji_release()

        self.cleanup()

    def tgz(self):
        """
        Create the .tar.gz required to build this package.

        Returns full path to the created tarball.
        """
        self._setup_sources()

        run_command("cp %s/%s %s/" %  \
                (self.rpmbuild_sourcedir, self.tgz_filename,
                    self.rpmbuild_basedir))

        self.ran_tgz = True
        full_path = os.path.join(self.rpmbuild_basedir, self.tgz_filename)
        print "Wrote: %s" % full_path
        self.sources.append(full_path)
        return full_path

    # TODO: reuse_cvs_checkout isn't needed here, should be cleaned up:
    def _srpm(self, dist=None, reuse_cvs_checkout=False):
        """
        Build a source RPM.
        """
        self._create_build_dirs()
        if not self.ran_tgz:
            self.tgz()

        if self.test:
            self._setup_test_specfile()

        debug("Creating srpm from spec file: %s" % self.spec_file)
        define_dist = ""
        if self.dist:
            define_dist = "--define 'dist %s'" % self.dist
        elif dist:
            define_dist = "--define 'dist %s'" % dist

        cmd = 'rpmbuild --define "_source_filedigest_algorithm md5"  --define "_binary_filedigest_algorithm md5" %s %s --nodeps -bs %s' % \
                (self._get_rpmbuild_dir_options(), define_dist, self.spec_file)
        output = run_command(cmd)
        print(output)
        self.srpm_location = self._find_wrote_in_rpmbuild_output(output)[0]

    def _rpm(self):
        """ Build an RPM. """
        self._create_build_dirs()
        if not self.ran_tgz:
            self.tgz()

        if self.test:
            self._setup_test_specfile()

        define_dist = ""
        if self.dist:
            define_dist = "--define 'dist %s'" % self.dist
        cmd = 'rpmbuild --define "_source_filedigest_algorithm md5"  --define "_binary_filedigest_algorithm md5" %s %s --clean -ba %s' % \
                (self._get_rpmbuild_dir_options(), define_dist, self.spec_file)
        output = run_command(cmd)
        print output
        files_written = self._find_wrote_in_rpmbuild_output(output)
        if len(files_written) < 2:
            error_out("Error parsing rpmbuild output")
        self.srpm_location = files_written[0]

    def release(self):
        """
        Release this package via configuration for this git repo and branch.

        Check if CVS support is configured in rel-eng/global.build.py.props
        and initiate CVS import/tag/build if so.

        Check for configured Koji branches also, if found create srpms and
        submit to those branches with proper disttag's.
        """
        if self._can_build_in_cvs():
            self._cvs_release()

        if self._can_build_in_koji():
            self._koji_release()

    def _cvs_release(self):
        """
        Sync spec file/patches with CVS, create tags, and submit to brew/koji.
        """

        self._verify_cvs_module_not_already_checked_out()

        print("Building release in CVS...")
        commands.getoutput("mkdir -p %s" % self.cvs_workdir)
        debug("cvs_branches = %s" % self.cvs_branches)

        self._cvs_checkout_module()
        self._cvs_verify_branches_exist()

        # Get the list of all sources from the builder:
        self.tgz()

        self._cvs_sync_files()

        # Important step here, ends up populating several important members
        # on the builder object so some of the below lines will not work
        # if moved above this one.
        self._cvs_upload_sources()

        self._cvs_user_confirm_commit()

        self._cvs_make_tag()
        self._cvs_make_build()

    def _koji_release(self):
        """
        Lookup autobuild Koji tags from global config, create srpms with
        appropriate disttags, and submit builds to Koji.
        """
        autobuild_tags = self.global_config.get("koji", "autobuild_tags")
        print("Building release in Koji...")
        debug("Koji tags: %s" % autobuild_tags)
        koji_tags = autobuild_tags.strip().split(" ")

        koji_opts = DEFAULT_KOJI_OPTS
        if self.user_config.has_key('KOJI_OPTIONS'):
            koji_opts = self.user_config['KOJI_OPTIONS']

        for koji_tag in koji_tags:
            # Lookup the disttag configured for this Koji tag:
            disttag = self.global_config.get(koji_tag, "disttag")
            if self.global_config.has_option(koji_tag, "whitelist"):
                # whitelist implies only those packages can be built to the
                # tag,regardless if blacklist is also defined.
                if self.project_name not in self.global_config.get(koji_tag,
                        "whitelist").strip().split(" "):
                    print("WARNING: %s not specified in whitelist for %s" % (
                        self.project_name, koji_tag))
                    print("   Package *NOT* submitted to Koji.")
                    continue
            elif self.global_config.has_option(koji_tag, "blacklist"):
                if self.project_name in self.global_config.get(koji_tag,
                        "blacklist").strip().split(" "):
                    print("WARNING: %s specified in blacklist for %s" % (
                        self.project_name, koji_tag))
                    print("   Package *NOT* submitted to Koji.")
                    continue

            # Getting tricky here, normally Builder's are only used to
            # create one rpm and then exit. Here we're going to try
            # to run multiple srpm builds:
            self._srpm(dist=disttag, reuse_cvs_checkout=True)

            self._submit_build("koji", koji_opts, koji_tag)

    def _setup_sources(self):
        """
        Create a copy of the git source for the project at the point in time
        our build tag was created.

        Created in the temporary rpmbuild SOURCES directory.
        """
        self._create_build_dirs()

        debug("Creating %s from git tag: %s..." % (self.tgz_filename,
            self.git_commit_id))
        create_tgz(self.git_root, self.tgz_dir, self.git_commit_id,
                self.relative_project_dir, self.rel_eng_dir,
                os.path.join(self.rpmbuild_sourcedir, self.tgz_filename))

        # Extract the source so we can get at the spec file, etc.
        debug("Copying git source to: %s" % self.rpmbuild_gitcopy)
        run_command("cd %s/ && tar xzf %s" % (self.rpmbuild_sourcedir,
            self.tgz_filename))

        # NOTE: The spec file we actually use is the one exported by git
        # archive into the temp build directory. This is done so we can
        # modify the version/release on the fly when building test rpms
        # that use a git SHA1 for their version.
        self.spec_file_name = find_spec_file(in_dir=self.rpmbuild_gitcopy)
        self.spec_file = os.path.join(self.rpmbuild_gitcopy, self.spec_file_name)

    def _verify_cvs_module_not_already_checked_out(self):
        """ Exit if CVS module appears to already be checked out. """
        # Make sure the cvs checkout directory doesn't already exist:
        cvs_co_dir = os.path.join(self.cvs_workdir, self.project_name)
        if os.path.exists(cvs_co_dir):
            error_out("CVS workdir exists, please remove and try again: %s"
                    % cvs_co_dir)

    def _cvs_checkout_module(self):
        print("Checking out cvs module [%s]" % self.project_name)
        os.chdir(self.cvs_workdir)
        run_command("cvs -d %s co %s" % (self.cvs_root, self.project_name))

    def _cvs_verify_branches_exist(self):
        """ Check that CVS checkout contains the branches we expect. """
        os.chdir(self.cvs_package_workdir)
        for branch in self.cvs_branches:
            if not os.path.exists(os.path.join(self.cvs_workdir,
                self.project_name, branch)):
                error_out("%s CVS checkout is missing branch: %s" %
                        (self.project_name, branch))

    def _cvs_upload_sources(self):
        """
        Upload any tarballs to the CVS lookaside directory. (if necessary)
        Uses the "make new-sources" target in common.
        """
        if len(self.sources) == 0:
            debug("No sources need to be uploaded.")
            return

        print("Uploading sources to dist-cvs lookaside:")
        for branch in self.cvs_branches:
            branch_dir = os.path.join(self.cvs_workdir, self.project_name,
                    branch)
            os.chdir(branch_dir)
            cmd = 'make new-sources FILES="%s"' % string.join(self.sources, " ")
            debug(cmd)
            output = run_command(cmd)
            debug(output)

    def _cvs_sync_files(self):
        """
        Copy files from git into each CVS branch and add them. Extra files
        found in CVS will then be deleted.

        A list of CVS safe files is used to protect critical files both from
        being overwritten by a git file of the same name, as well as being
        deleted after.
        """

        # Build the list of all files we will copy from git to CVS.
        debug("Searching for git files to copy to CVS:")

        # Include the spec file explicitly, in the case of SatelliteBuilder
        # we modify and then use a spec file copy from a different location.
        files_to_copy = [self.spec_file] # full paths
        filenames_to_copy = [os.path.basename(self.spec_file)] # just filenames

        for filename in os.listdir(self.rpmbuild_gitcopy):
            full_filepath = os.path.join(self.rpmbuild_gitcopy, filename)
            if os.path.isdir(full_filepath):
                # skip it
                continue
            if filename in CVS_PROTECT_FILES:
                debug("   skipping:  %s (protected file)" % filename)
                continue
            elif filename.endswith(".spec"):
                # Skip the spec file, we already copy this explicitly as it 
                # can come from a couple different locations depending on which
                # builder is in use.
                continue

            # Check if file ends with something this builder subclass wants
            # to copy:
            copy_it = False
            for extension in self.cvs_copy_extensions:
                if filename.endswith(extension):
                    copy_it = True
                    continue
            if copy_it:
                debug("   copying:   %s" % filename)
                files_to_copy.append(full_filepath)
                filenames_to_copy.append(filename)

        for branch in self.cvs_branches:
            branch_dir = os.path.join(self.cvs_workdir, self.project_name,
                    branch)
            os.chdir(branch_dir)
            print("Syncing files with CVS branch [%s]" % branch)
            for copy_me in files_to_copy:
                base_filename = os.path.basename(copy_me)
                dest_path = os.path.join(branch_dir, base_filename)

                # Check if file we're about to copy already exists in CVS so
                # we know if we need to run 'cvs add' or not:
                cvs_add = True
                if os.path.exists(dest_path):
                    cvs_add = False

                cmd = "cp %s %s" % (copy_me, dest_path)
                run_command(cmd)

                if cvs_add:
                    print("   added: %s" % base_filename)
                    commands.getstatusoutput("cvs add %s" %  base_filename)
                else:
                    print("   copied: %s" % base_filename)

            # Now delete any extraneous files in the CVS branch.
            for filename in os.listdir(branch_dir):
                if filename not in CVS_PROTECT_FILES and \
                        filename not in filenames_to_copy:
                    print("   deleted: %s" % filename)
                    # Can't delete via full path, must not chdir:
                    run_command("cvs rm -Rf %s" % filename)

    def _cvs_user_confirm_commit(self):
        """ Prompt user if they wish to proceed with commit. """
        print("")
        text = "Running 'cvs diff -u' in: %s" % self.cvs_package_workdir
        print("#" * len(text))
        print(text)
        print("#" * len(text))
        print("")

        os.chdir(self.cvs_package_workdir)
        (status, output) = commands.getstatusoutput("cvs diff -u")
        print(output)

        print("")
        print("##### Please review the above diff #####")
        answer = raw_input("Do you wish to proceed with commit? [y/n] ")
        if answer.lower() not in ['y', 'yes', 'ok', 'sure']:
            print("Fine, you're on your own!")
            self.cleanup()
            sys.exit(1)
        else:
            print("Proceeding with commit.")
            os.chdir(self.cvs_package_workdir)
            cmd = 'cvs commit -m "Update %s to %s"' % \
                    (self.project_name, self.build_version)
            debug("CVS commit command: %s" % cmd)
            output = run_command(cmd)

    def _cvs_make_tag(self):
        """ Create a CVS tag based on what we just committed. """
        os.chdir(self.cvs_package_workdir)
        print("Creating CVS tags...")
        for branch in self.cvs_branches:
            branch_dir = os.path.join(self.cvs_workdir, self.project_name,
                    branch)
            os.chdir(branch_dir)
            (status, output) = commands.getstatusoutput("make tag")
            print(output)
            if status > 1:
                self.cleanup()
                sys.exit(1)

    def _cvs_make_build(self):
        """ Build srpm and submit to build system. """
        os.chdir(self.cvs_package_workdir)
        print("Submitting CVS builds...")
        for branch in self.cvs_branches:
            branch_dir = os.path.join(self.cvs_workdir, self.project_name,
                    branch)
            os.chdir(branch_dir)
            output = run_command("BUILD_FLAGS=--nowait make build")
            print(output)

    def _can_build_in_cvs(self):
        """
        Return True if this repo and branch is configured to build in CVS.
        """
        if not self.global_config.has_section("cvs"):
            debug("Cannot build from CVS, no 'cvs' section found in global.build.py.props")
            return False

        if not self.global_config.has_option("cvs", "cvsroot"):
            debug("Cannot build from CVS, no 'cvsroot' defined in global.build.py.props")
            return False

        if not self.global_config.has_option("cvs", "branches"):
            debug("Cannot build from CVS no branches defined in global.build.py.props")
            return False

        return True

    def _can_build_in_koji(self):
        """
        Return True if this repo and branch are configured to auto build in
        any Koji tags.
        """
        if not self.global_config.has_section("koji"):
            debug("No 'koji' section found in global.build.py.props")
            return False

        if not self.global_config.has_option("koji", "autobuild_tags"):
            debug("Cannot build in Koji, no autobuild_tags defined in global.build.py.props")
            return False

        return True

    def _submit_build(self, executable, koji_opts, tag):
        """ Submit srpm to brew/koji. """
        cmd = "%s %s %s %s" % (executable, koji_opts, tag, self.srpm_location)
        print("\nSubmitting build with: %s" % cmd)
        output = run_command(cmd)
        print(output)

    def _find_wrote_in_rpmbuild_output(self, output):
        """
        Parse the output from rpmbuild looking for lines beginning with
        "Wrote:". Return a list of file names for each path found.
        """
        paths = []
        look_for = "Wrote: "
        for line in output.split("\n"):
            if line.startswith(look_for):
                paths.append(line[len(look_for):])
                debug("Found wrote line: %s" % paths[-1])
        if (len(paths) == 0):
            error_out("Unable to locate 'Wrote: ' lines in rpmbuild output")
        return paths

    def cleanup(self):
        """
        Remove all temporary files and directories.
        """
        if not self.no_cleanup:
            debug("Cleaning up [%s]" % self.rpmbuild_dir)
            commands.getoutput("rm -rf %s" % self.rpmbuild_dir)
            debug("Cleaning up [%s]" % self.cvs_package_workdir)
            run_command("rm -rf %s" % self.cvs_package_workdir)

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
            setup_specfile_script = os.path.join(SCRIPT_DIR,
                    "test-setup-specfile.pl")
            cmd = "perl %s %s %s %s-%s %s" % \
                    (
                        setup_specfile_script,
                        self.spec_file,
                        self.git_commit_id,
                        self.project_name,
                        self.display_version,
                        self.tgz_filename
                    )
            run_command(cmd)

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

    def _get_display_version(self):
        """
        Get the package display version to build.

        Normally this is whatever is rel-eng/packages/. In the case of a --test
        build it will be the SHA1 for the HEAD commit of the current git
        branch.
        """
        if self.test:
            version = "git-" + get_git_head_commit()
        else:
            version = self.build_version.split("-")[0]
        return version



class NoTgzBuilder(Builder):
    """
    Builder for packages that do not require the creation of a tarball.
    Usually these packages have source tarballs checked directly into git.
    i.e. most of the packages in spec-tree.
    """
    def __init__(self, name=None, version=None, tag=None, build_dir=None,
            pkg_config=None, global_config=None, user_config=None, dist=None,
            test=False, offline=False):

        Builder.__init__(self, name=name, version=version, tag=tag,
                build_dir=build_dir, pkg_config=pkg_config,
                global_config=global_config, user_config=user_config, dist=dist,
                test=test, offline=offline)

        # When syncing files with CVS, copy everything from git:
        self.cvs_copy_extensions = ("",)

    def tgz(self):
        """ Override parent behavior, we already have a tgz. """
        # TODO: Does it make sense to allow user to create a tgz for this type
        # of project?
        self._setup_sources()
        self.ran_tgz = True

        source_suffixes = ('.tar.gz', '.tar', '.zip', '.jar', '.tar.bz2')
        debug("Scanning for sources.")
        for filename in os.listdir(self.rpmbuild_gitcopy):
            for suffix in source_suffixes:
                if filename.endswith(suffix):
                    self.sources.append(os.path.join(self.rpmbuild_gitcopy,
                        filename))
        debug("  Sources: %s" % self.sources)

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
            script = os.path.join(SCRIPT_DIR, "test-setup-specfile.pl")
            cmd = "perl %s %s %s" % \
                    (
                        script,
                        self.spec_file,
                        self.git_commit_id
                    )
            run_command(cmd)



class CvsBuilder(NoTgzBuilder):
    """ 
    CVS Builder

    Builder for packages whose sources are managed in dist-cvs/Fedora CVS.
    """
    def __init__(self, name=None, version=None, tag=None, build_dir=None,
            pkg_config=None, global_config=None, user_config=None, dist=None,
            test=False, offline=False):

        NoTgzBuilder.__init__(self, name=name, version=version, tag=tag,
                build_dir=build_dir, pkg_config=pkg_config,
                global_config=global_config, user_config=user_config, dist=dist,
                test=test, offline=offline)

        # TODO: Hack to override here, patches are in a weird place with this
        # builder.
        self.patch_dir = self.rpmbuild_gitcopy

    def run(self, options):
        """ Override parent to validate any new sources that. """
        # Convert new sources to full paths right now, before we chdir:
        if options.cvs_new_sources is not None:
            for new_source in options.cvs_new_sources:
                self.sources.append(os.path.abspath(os.path.expanduser(new_source)))
        debug("CvsBuilder sources: %s" % self.sources)
        NoTgzBuilder.run(self, options)

    def _srpm(self, dist=None, reuse_cvs_checkout=False):
        """ Build an srpm from CVS. """
        rpms = self._cvs_rpm_common(target="test-srpm", dist=dist,
                reuse_cvs_checkout=reuse_cvs_checkout)
        # Should only be one rpm returned for srpm:
        self.srpm_location = rpms[0]

    def _rpm(self):
        # Lookup the architecture of the system for the correct make target:
        arch = run_command("uname -i")
        self._cvs_rpm_common(target=arch, all_branches=True)

    def _cvs_rpm_common(self, target, all_branches=False, dist=None, 
            reuse_cvs_checkout=False):
        """ Code common to building both rpms and srpms with CVS tools. """
        self._create_build_dirs()
        if not self.ran_tgz:
            self.tgz()

        if not self._can_build_in_cvs():
            error_out("Repo not properly configured to build in CVS. (--debug for more info)")

        if not reuse_cvs_checkout:
            self._verify_cvs_module_not_already_checked_out()

        commands.getoutput("mkdir -p %s" % self.cvs_workdir)
        self._cvs_checkout_module()
        self._cvs_verify_branches_exist()

        if self.test:
            self._setup_test_specfile()

        # Copy latest spec so we build that version, even if it isn't the
        # latest actually committed to CVS:
        self._cvs_sync_files()

        self._cvs_upload_sources()

        # Use "make srpm" target to create our source RPM:
        os.chdir(self.cvs_package_workdir)
        print("Building with CVS make %s..." % target)

        # Only running on the last branch, good enough?
        branch = self.cvs_branches[-1]
        branch_dir = os.path.join(self.cvs_workdir, self.project_name,
                branch)
        os.chdir(branch_dir)

        disttag = ""
        if self.dist is not None:
            disttag = "DIST=%s" % self.dist
        elif dist is not None:
            disttag = "DIST=%s" % dist

        output = run_command("make %s %s" % (disttag, target))
        debug(output)
        rpms = []
        for line in output.split("\n"):
            if line.startswith("Wrote: "):
                srpm_path = line.strip().split(" ")[1]
                filename = os.path.basename(srpm_path)
                run_command("mv %s %s" % (srpm_path, self.rpmbuild_basedir))
                final_rpm_path = os.path.join(self.rpmbuild_basedir, filename)
                print("Wrote: %s" % final_rpm_path)
                rpms.append(final_rpm_path)
        if not self.test:
            print("Please be sure to run --release to commit/tag/build this package in CVS.")
        return rpms



class SatelliteBuilder(NoTgzBuilder):
    """
    Builder for packages that are based off some upstream version in Spacewalk
    git. Commits applied in Satellite git become patches applied to the 
    upstream Spacewalk tarball.

    i.e. satellite-java-0.4.0-5 built from spacewalk-java-0.4.0-1 and any 
    patches applied in satellite git.
    i.e. spacewalk-setup-0.4.0-20 built from spacewalk-setup-0.4.0-1 and any
    patches applied in satellite git.
    """
    def __init__(self, name=None, version=None, tag=None, build_dir=None,
            pkg_config=None, global_config=None, user_config=None, dist=None,
            test=False, offline=False):

        NoTgzBuilder.__init__(self, name=name, version=version, tag=tag,
                build_dir=build_dir, pkg_config=pkg_config,
                global_config=global_config, user_config=user_config, dist=dist,
                test=test, offline=offline)

        if not pkg_config or not pkg_config.has_option("buildconfig",
                "upstream_name"):
            # No upstream_name defined, assume we're keeping the project name:
            self.upstream_name = self.project_name
        else:
            self.upstream_name = pkg_config.get("buildconfig", "upstream_name")
        # Need to assign these after we've exported a copy of the spec file:
        self.upstream_version = None 
        self.upstream_tag = None
        self.patch_filename = None
        self.patch_file = None

        # When syncing files with CVS, only copy files with these extensions:
        self.cvs_copy_extensions = (".spec", ".patch")

    def tgz(self):
        """
        Override parent behavior, we need a tgz from the upstream spacewalk
        project we're based on.
        """
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

        print("Building upstream tgz for tag [%s]" % (self.upstream_tag))
        if self.upstream_tag != self.build_tag:
            check_tag_exists(self.upstream_tag, offline=self.offline)

        self.spec_file = os.path.join(self.rpmbuild_sourcedir, 
                self.spec_file_name)
        run_command("cp %s %s" % (os.path.join(self.rpmbuild_gitcopy, 
            self.spec_file_name), self.spec_file))

        # Create the upstream tgz:
        prefix = "%s-%s" % (self.upstream_name, self.upstream_version)
        tgz_filename = "%s.tar.gz" % prefix
        commit = get_build_commit(tag=self.upstream_tag)
        relative_dir = get_relative_project_dir(
                project_name=self.upstream_name, commit=commit)
        tgz_fullpath = os.path.join(self.rpmbuild_sourcedir, tgz_filename)
        print("Creating %s from git tag: %s..." % (tgz_filename, commit))
        create_tgz(self.git_root, prefix, commit, relative_dir, 
                self.rel_eng_dir, tgz_fullpath)
        self.ran_tgz = True
        self.sources.append(tgz_fullpath)

        # If these are equal then the tag we're building was likely created in 
        # Spacewalk and thus we don't need to do any patching.
        if (self.upstream_tag == self.build_tag and not self.test):
            return

        self._generate_patches()
        self._insert_patches_into_spec_file()

    def _generate_patches(self):
        """
        Generate patches for any differences between our tag and the
        upstream tag.
        """
        self.patch_filename = "%s-to-%s-%s.patch" % (self.upstream_tag,
                self.project_name, self.build_version)
        self.patch_file = os.path.join(self.rpmbuild_gitcopy,
                self.patch_filename)
        os.chdir(os.path.join(self.git_root, self.relative_project_dir))
        print("Generating patch [%s]" % self.patch_filename)
        debug("Patch: %s" % self.patch_file)
        patch_command = "git diff --relative %s..%s > %s" % \
                (self.upstream_tag, self.git_commit_id, self.patch_file)
        debug("Generating patch with: %s" % patch_command)
        output = run_command(patch_command)
        print(output)
        # Creating two copies of the patch here in the temp build directories
        # just out of laziness. Some builders need sources in SOURCES and
        # others need them in the git copy. Being lazy here avoids one-off
        # hacks and both copies get cleaned up anyhow.
        run_command("cp %s %s" % (self.patch_file, self.rpmbuild_sourcedir))

    def _insert_patches_into_spec_file(self):
        """
        Insert the generated patches into the copy of the spec file we'll be
        building with.
        """
        f = open(self.spec_file, 'r')
        lines = f.readlines()

        patch_pattern = re.compile('^Patch(\d+):')
        source_pattern = re.compile('^Source\d+:')

        # Find the largest PatchX: line, or failing that SourceX:
        patch_number = 0 # What number should we use for our PatchX line
        patch_insert_index = 0 # Where to insert our PatchX line in the list
        patch_apply_index = 0 # Where to insert our %patchX line in the list
        array_index = 0 # Current index in the array
        for line in lines:
            match = source_pattern.match(line)
            if match:
                patch_insert_index = array_index + 1

            match = patch_pattern.match(line)
            if match:
                patch_insert_index = array_index + 1
                patch_number = int(match.group(1)) + 1

            if line.startswith("%prep"):
                # We'll apply patch right after prep if there's no %setup line
                patch_apply_index = array_index + 2
            elif line.startswith("%setup"):
                patch_apply_index = array_index + 2 # already added a line

            array_index += 1
        
        debug("patch_insert_index = %s" % patch_insert_index)
        debug("patch_apply_index = %s" % patch_apply_index)
        if patch_insert_index == 0 or patch_apply_index == 0:
            error_out("Unable to insert PatchX or %patchX lines in spec file")

        lines.insert(patch_insert_index, "Patch%s: %s\n" % (patch_number, 
            self.patch_filename))
        lines.insert(patch_apply_index, "%%patch%s -p1\n" % (patch_number))
        f.close()

        # Now write out the modified lines to the spec file copy:
        f = open(self.spec_file, 'w')
        for line in lines:
            f.write(line)
        f.close()

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

        if self.test:
            return self.build_version.split("-")[0]
        # Otherwise, assume we use our version:
        else:
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


