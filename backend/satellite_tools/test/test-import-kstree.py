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
from spacewalk.server import rhnSQL
from spacewalk.server.importlib.kickstartImport import KickstartableTreeImport
from spacewalk.satellite_tools import xmlSource
from spacewalk.satellite_tools.diskImportLib import getBackend

class KickstartableTreesContainer(xmlSource.KickstartableTreesContainer):
    def endContainerCallback(self):
        if not self.batch:
            return
        importer = KickstartableTreeImport(self.batch, getBackend())
        importer.run()

if __name__ == '__main__':
    #rhnSQL.initDB("satuser/satuser@satdev")
    rhnSQL.initDB("rhnuser/rhnuser@webdev")
    f = open("test/ks-dump.xml")
    handler = xmlSource.getHandler()
    handler.set_container(KickstartableTreesContainer())
    handler.process(f)
