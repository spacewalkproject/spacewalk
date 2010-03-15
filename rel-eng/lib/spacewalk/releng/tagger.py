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

""" Code for tagging Spacewalk/Satellite packages. """

import os
import re
import sys
import commands
import StringIO
import shutil
import subprocess
import tempfile
import textwrap

from time import strftime

from spacewalk.releng.cli import SCRIPT_DIR
from spacewalk.releng.common import * 

class VersionTagger(object):
    """
    Standard Tagger class, used for tagging packages built from source in
    git. (as opposed to packages which commit a tarball directly into git).

    Releases will be tagged by incrementing the package version,
    and the actual RPM "release" will always be set to 1.
    """
    def __init__(self, global_config=None, keep_version=False):
        self.git_root = find_git_root()
        self.rel_eng_dir = os.path.join(self.git_root, "rel-eng")
        self.config = global_config

        self.full_project_dir = os.getcwd()
        self.spec_file_name = find_spec_file()
        self.project_name = get_project_name(tag=None)

        self.relative_project_dir = self._get_relative_project_dir(
                self.git_root) # i.e. java/

        self.spec_file = os.path.join(self.full_project_dir,
                self.spec_file_name)
        self.keep_version = keep_version

        self.today = strftime("%a %b %d %Y")
        (self.git_user, self.git_email) = self._get_git_user_info()
        self.changelog_regex = re.compile('\\*\s%s\s%s(\s<%s>)?' % (self.today,
            self.git_user, self.git_email))

        self._no_auto_changelog = False

    def run(self, options):
        """
        Perform the actions requested of the tagger.

        NOTE: this method may do nothing if the user requested no build actions
        be performed. (i.e. only release tagging, etc)
        """
        if options.tag_release:
            print("WARNING: --tag-release option no longer necessary, 'tito tag' will accomplish the same thing.")
        if options.no_auto_changelog:
            self._no_auto_changelog=True
        self._tag_release()

    def _tag_release(self):
        """
        Tag a new version of the package. (i.e. x.y.z+1)
        """
        self._check_today_in_changelog()
        new_version = self._bump_version()
        self._check_tag_does_not_exist(self._get_new_tag(new_version))
        self._update_changelog(new_version)

        self._update_package_metadata(new_version)

    def _check_today_in_changelog(self):
        """ 
        Verify that there is a changelog entry for today's date and the git 
        user's name and email address.

        i.e. * Thu Nov 27 2008 My Name <me@example.com>
        """
        f = open(self.spec_file, 'r')
        found_changelog = False
        for line in f.readlines():
            match = self.changelog_regex.match(line)
            if not found_changelog and match:
                found_changelog = True
        f.close()

        if not found_changelog:
            if self._no_auto_changelog:
                error_out("No changelog entry found: '* %s %s <%s>'" % (
                    self.today, self.git_user, self.git_email))
            else:
                self._make_changelog()
        else:
            debug("Found changelog entry.")

    def _make_changelog(self):
        """
        Create a new changelog entry in the spec, with line items from git
        """
        in_f = open(self.spec_file, 'r')
        out_f = open(self.spec_file + ".new", 'w')

        found_changelog = False
        for line in in_f.readlines():
            out_f.write(line)

            if not found_changelog and line.startswith("%changelog"):
                found_changelog = True

                old_version = get_latest_tagged_version(self.project_name)

                # don't die if this is a new package with no history
                if old_version != None:
                    last_tag = "%s-%s" % (self.project_name, old_version)
                    patch_command = \
                            "git log --pretty=format:%%s\ \(%%ae\)" \
                            " --relative %s..%s -- %s" % \
                            (last_tag, "HEAD", ".")
                    output = run_command(patch_command)
                else:
                    output = "new package"

                fd, name = tempfile.mkstemp()
                os.write(fd, "# No changelog entry found; please edit the following\n")
                header = "* %s %s <%s>\n" % (self.today, self.git_user,
                        self.git_email)

                os.write(fd, header)

                for cmd_out in output.split("\n"):
                    os.write(fd, "- ")
                    os.write(fd, "\n  ".join(textwrap.wrap(cmd_out, 77)))
                    os.write(fd, "\n")

                os.write(fd, "\n")

                editor = 'vi'
                if os.environ.has_key("EDITOR"):
                    editor = os.environ["EDITOR"]

                subprocess.call([editor, name])

                os.lseek(fd, 0, 0)
                file = os.fdopen(fd)

                for line in file.readlines():
                    if not line.startswith("#"):
                        out_f.write(line)

                output = file.read()

                file.close()
                os.unlink(name)

        in_f.close()
        out_f.close()

        shutil.move(self.spec_file + ".new", self.spec_file)

    def _update_changelog(self, new_version):
        """
        Update the changelog with the new version.
        """
        # Not thrilled about having to re-read the file here but we need to
        # check for the changelog entry before making any modifications, then
        # bump the version, then update the changelog.
        f = open(self.spec_file, 'r')
        buf = StringIO.StringIO()
        found_match = False
        for line in f.readlines():
            match = self.changelog_regex.match(line)
            if match and not found_match:
                buf.write("%s %s\n" % (match.group(), new_version))
                found_match = True
            else:
                buf.write(line)
        f.close()

        # Write out the new file contents with our modified changelog entry:
        f = open(self.spec_file, 'w')
        f.write(buf.getvalue())
        f.close()
        buf.close()

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

    def _bump_version(self, release=False):
        """
        Bump up the package version in the spec file.

        Set release to True to bump the package release instead.

        Checks for the keep version option and if found, won't actually
        bump the version or release.
        """
        old_version = get_latest_tagged_version(self.project_name)
        if old_version == None:
            old_version = "untagged"
        # TODO: Do this here instead of calling out to an external Perl script:
        if not self.keep_version:
            bump_type = "bump-version"
            if release:
                bump_type = "bump-release"

            script_path = os.path.join(SCRIPT_DIR, "bump-version.pl")
            cmd = "perl %s %s --specfile %s" % \
                    (script_path, bump_type, self.spec_file)
            run_command(cmd)

        new_version = self._get_spec_version_and_release()
        if new_version.strip() == "":
            error_out("Error getting bumped package version. (can spec file be parsed?")
        print "Tagging new version of %s: %s -> %s" % (self.project_name,
            old_version, new_version)
        return new_version

    def _update_package_metadata(self, new_version, release=False):
        """
        We track package metadata in the rel-eng/packages/ directory. Each
        file here stores the latest package version (for the git branch you
        are on) as well as the relative path to the project's code. (from the
        git root)

        Set release to True when bumping the package release. (as opposed to
        it's version)
        """
        self._clear_package_metadata()

        suffix = ""
        # If global config specifies a tag suffix, use it:
        if self.config.has_option("globalconfig", "tag_suffix"):
            suffix = self.config.get("globalconfig", "tag_suffix")

        new_version_w_suffix = "%s%s" % (new_version, suffix)
        # Write out our package metadata:
        metadata_file = os.path.join(self.rel_eng_dir, "packages",
                self.project_name)
        f = open(metadata_file, 'w')
        f.write("%s %s\n" % (new_version_w_suffix, self.relative_project_dir))
        f.close()

        # Git add it (in case it's a new file):
        run_command("git add %s" % metadata_file)
        run_command("git add %s" % os.path.join(self.full_project_dir,
            self.spec_file_name))

        # Just an informative message appearing in the commit log:
        release_type = "release"
        if release:
            release_type = "minor release"

        run_command('git commit -m "Automatic commit of package ' +
                '[%s] %s [%s]."' % (self.project_name, release_type,
                    new_version_w_suffix))

        tag_msg = "Tagging package [%s] version [%s] in directory [%s]." % \
                (self.project_name, new_version_w_suffix,
                        self.relative_project_dir)

        new_tag = self._get_new_tag(new_version)
        print "Creating new tag [%s]" % new_tag
        run_command('git tag -m "%s" %s' % (tag_msg, new_tag))
        print("You must run [git push && git push --tags] before this " +
            "tag can be used")

    def _check_tag_does_not_exist(self, new_tag):
        status, output = commands.getstatusoutput('git tag | grep %s' % new_tag)
        if status == 0:
            raise Exception("Tag %s already exists!" % new_tag)

    def _clear_package_metadata(self):
        """
        Remove all rel-eng/packages/ files that have a relative path
        matching the package we're tagging a new version of. Normally
        this just removes the previous package file but if we were
        renaming oldpackage to newpackage, this would git rm
        rel-eng/packages/oldpackage and add
        rel-eng/packages/spacewalk-newpackage.
        """
        metadata_dir = os.path.join(self.rel_eng_dir, "packages")
        for filename in os.listdir(metadata_dir):
            metadata_file = os.path.join(metadata_dir, filename) # full path

            if os.path.isdir(metadata_file) or filename.startswith("."):
                continue

            temp_file = open(metadata_file, 'r')
            (version, relative_dir) = temp_file.readline().split(" ")
            relative_dir = relative_dir.strip() # sometimes has a newline

            if relative_dir == self.relative_project_dir:
                debug("Found metadata for our prefix: %s" %
                        metadata_file)
                debug("   version: %s" % version)
                debug("   dir: %s" % relative_dir)
                if filename == self.project_name:
                    debug("Updating %s with new version." %
                            metadata_file)
                else:
                    print "WARNING: %s also references %s" % (filename,
                            self.relative_project_dir)
                    print "Assuming package has been renamed and removing it."
                    run_command("git rm %s" % metadata_file)

    def _get_git_user_info(self):
        """ Return the user.name and user.email git config values. """
        return (run_command('git config --get user.name'), 
                run_command('git config --get user.email'))

    def _get_spec_version_and_release(self):
        """ Get the package version from the spec file. """
        return get_spec_version_and_release(self.full_project_dir, 
                self.spec_file_name)

    def _get_new_tag(self, new_version):
        """ Returns the actual tag we'll be creating. """
        suffix = ""
        # If global config specifies a tag suffix, use it:
        if self.config.has_option("globalconfig", "tag_suffix"):
            suffix = self.config.get("globalconfig", "tag_suffix")
        return "%s-%s%s" % (self.project_name, new_version, suffix)



class ReleaseTagger(VersionTagger):
    """
    Tagger which increments the spec file release instead of version.

    Used for:
      - Packages we build from a tarball checked directly into git.
      - Satellite packages built on top of Spacewalk tarballs.
    """

    def _tag_release(self):
        """
        Tag a new release of the package. (i.e. x.y.z-r+1)
        """
        self._check_today_in_changelog()
        new_version = self._bump_version(release=True)

        self._check_tag_does_not_exist(self._get_new_tag(new_version))
        self._update_changelog(new_version)
        self._update_package_metadata(new_version, release=True)


