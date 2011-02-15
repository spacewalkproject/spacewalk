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
from spacewalk.server.rhnServer import satellite_cert

if len(sys.argv) != 2:
    print "Usage: %s <cert-file>" % sys.argv[0]
    sys.exit(1)

c = satellite_cert.SatelliteCert()
c.load(open(sys.argv[1]).read())
print c, dir(c)
print getattr(c, "provisioning-slots")
