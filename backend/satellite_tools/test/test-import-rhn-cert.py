#
# Copyright (c) 2008--2010 Red Hat, Inc.
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
from spacewalk.server import rhnSQL
from spacewalk.satellite_tools import satCerts

def main():
    if len(sys.argv) != 2:
        print "Usage: %s <cert>" % sys.argv[0]
        return 1
    cert = sys.argv[1]

    rhnSQL.initDB()

    satCerts.storeRhnCert(open(cert).read())

if __name__ == '__main__':
    sys.exit(main() or 0)
