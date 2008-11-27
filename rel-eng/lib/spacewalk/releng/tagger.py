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
import commands

from time import strftime

from spacewalk.releng.common import find_spec_file, run_command, BuildCommon

class Tagger(BuildCommon):
    """
    Parent package tagging class.

    Includes functionality for a standard Spacewalk package build. Packages
    which require other unusual behavior can subclass this to inject the
    desired behavior.
    """
    def __init__(self, debug=False):
        BuildCommon.__init__(self, debug)

        self.spec_file = os.path.join(self.full_project_dir,
                self.spec_file_name)

    def run(self, options):
        """
        Perform the actions requested of the tagger.

        NOTE: this method may do nothing if the user requested no build actions
        be performed. (i.e. only release tagging, etc)
        """
        if options.tag_version:
            self._tag_version()

    def _tag_version(self):
        """ Tag a new version of the package. (i.e. x.y.z+1) """
        self._check_today_in_changelog()
        self._bump_version()

    def _check_today_in_changelog(self):
        """ 
        Verify that there is a changelog entry for today's date and the git 
        user's name and email address.

        i.e. * Thu Nov 27 2008 My Name <me@example.com>
        """
        today = strftime("%a %b %d %Y")
        (git_user, git_email) = self._get_git_user_info()
        regex = re.compile('\\*\s%s\s%s\s<%s>' % (today, git_user, git_email))

        f = open(self.spec_file, 'r')
        found_changelog = False
        for line in f.readlines():
            if regex.match(line):
                found_changelog = True
                break

        if not found_changelog:
            raise Exception("No changelog entry found: '* %s %s <%s>'" % (
                today, git_user, git_email))
        else:
            self.debug_print("Found changelog entry for today.")

    def _bump_version(self):
        # TODO: Do this here instead of calling out to an external Perl script:
        old_version = self._get_spec_version()
        self.debug_print("Old package version: %s" % old_version)
        cmd = "perl %s/bump-version.pl bump-version --specfile %s" % \
                (self.rel_eng_dir, self.spec_file)
        run_command(cmd)
        new_version = self._get_spec_version()
        self.debug_print("New package version: %s" % new_version)

    def _get_git_user_info(self):
        """ Return the user.name and user.email git config values. """
        return (run_command('git config --get user.name'), 
                run_command('git config --get user.email'))

    def _get_spec_version(self):
        """ Get the package version from the spec file. """
        command = """rpm -q --qf '%%{version}-%%{release}\n' --define "_sourcedir %s" --define 'dist %%undefined' --specfile %s | head -1""" % (self.full_project_dir, self.spec_file_name)
        return run_command(command)



