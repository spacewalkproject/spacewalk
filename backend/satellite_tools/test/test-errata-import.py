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
import sys
import xmlSource

from spacewalk.server import rhnSQL
from spacewalk.server.importlib.errataImport import ErrataImport
from spacewalk.server.importlib.backendOracle import OracleBackend

def main():
    #rhnSQL.initDB("satdev2/satdev2@testdb2")
    rhnSQL.initDB("satuser/satuser@satdev")
    handler = xmlSource.getHandler()
    container = xmlSource.ErrataContainer()
    handler.set_container(container)
    f = open("/tmp/erratum.xml")
    handler.process(f)
    for erratum in container.batch:
        #print erratum['packages']
        erratum['packages'] = []
        #print erratum['files']
        print erratum['cve']
    ei = ErrataImport(container.batch, OracleBackend().init())
    ei.ignoreMissing = 1
    ei.run()
    rhnSQL.commit()

if __name__ == '__main__':
    sys.exit(main() or 0)
