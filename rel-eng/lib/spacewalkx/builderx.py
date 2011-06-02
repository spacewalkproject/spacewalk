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

from tito import builder
from spacewalkx.releasex import KojiReleaserGit

class Builder(builder.Builder):

    def release(self):
        koji_releaser = KojiReleaserGit(self)
        koji_releaser.release(self.dry_run)

    def srpm(self, dist=None, reuse_cvs_checkout=False):
        try:
	    if self.no_srpm == 1:
                return
        except AttributeError:
            pass
        return super(Builder, self).srpm(dist, reuse_cvs_checkout)

class NoTgzBuilder(builder.NoTgzBuilder, Builder):

    pass

