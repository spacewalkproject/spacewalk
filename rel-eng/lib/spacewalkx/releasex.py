#
# Copyright (c) 2011 Red Hat, Inc.
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

from tito.release import KojiReleaser
from tito.common import run_command

class KojiReleaserGit(KojiReleaser):

    def _koji_release(self):
        self.builder.no_srpm = 1
        KojiReleaser._koji_release(self)
        self.builder.no_srpm = 0

    def _submit_build(self, executable, koji_opts, tag):
        """ Submit build to koji. """
        cmd = "%s %s %s git://git.fedorahosted.org/git/spacewalk.git/#%s" % (executable, koji_opts, tag, self.builder.build_tag)
        print("\nSubmitting build with: %s" % cmd)

        if self.dry_run:
            self.print_dry_run_warning(cmd)
            return

        output = run_command(cmd)
        print(output)

