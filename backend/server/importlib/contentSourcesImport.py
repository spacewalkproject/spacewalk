#
# Copyright (c) 2016 Red Hat, Inc.
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

from importLib import Import


class ContentSourcesImport(Import):

    def __init__(self, batch, backend):
        Import.__init__(self, batch, backend)

    def preprocess(self):
        pass

    def fix(self):
        pass

    def submit(self):
        try:
            self.backend.processContentSources(self.batch)
        except:
            self.backend.rollback()
            raise
        self.backend.commit()
