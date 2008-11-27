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

from spacewalk.releng.common import find_spec_file, BuildCommon

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
        if options.tag_release:
            self._tag_release()

    def _tag_release(self):
        """ Tag a new version of the package. (i.e. x.y.z+1) """
        self._check_today_in_changelog()
        self._bump_version()

    def _check_today_in_changelog(self):
        """ Verify that there is a changelog entry for today's date. """
        pass
        # TODO: Get this working, but perhaps not required for tagging new
        # versions?
        #today = strftime("%a %b %d %Y")
        #print "Today = %s" % today
        #regex = '\n%changelog\w\n'
        #regex = '(\n%%changelog\n\\* %s.+?)\s*(\d\S+)?\n' % today
        """
        Builder must always be instantiated from the project directory where
        the .spec file is located. No changes to the working directory should
        be made here in the constructor.
        """
        #print regex

        #spec_file = open(self.spec_file, 'r')
        #if re.compile(regex).match(spec_file.read()):
        #    print "Found changelog entry for %s" % today
        #else:
        #    raise Exception("No changelog entry found: '* %s %s'" % (
        #        today, self._get_git_user()))

    def _bump_version(self):
        # TODO: Do this here instead of calling out to an external Perl script:
        old_version = self._get_spec_version()
        self.debug_print("Old package version: %s" % old_version)
        cmd = "perl %s/bump-version.pl bump-version --specfile %s" % \
                (self.rel_eng_dir, self.spec_file)
        run_command(cmd)
        new_version = self._get_spec_version()
        self.debug_print("New package version: %s" % new_version)

    def _get_git_user(self):
        """ Return the user.name git config value. """
        return run_command('git config --get user.name')

    def _get_spec_version(self):
        """ Get the package version from the spec file. """
        command = """rpm -q --qf '%%{version}-%%{release}\n' --define "_sourcedir %s" --define 'dist %%undefined' --specfile %s | head -1""" % (self.full_project_dir, self.spec_file_name)
        return run_command(command)



