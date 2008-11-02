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
import xmlrpclib

#systemid = open("systemid-satellite-live").read()
systemid = open("systemid-satellite-devel").read()
server = xmlrpclib.Server("http://umberto.devel.redhat.com/SAT")

if 1:
    login = server.authentication.login(systemid)
    print login
    sys.exit(1)

#f = server.dump.arches(systemid)
#f = server.dump.channel_families(systemid)
#f = server.dump.channels(systemid)
#f = server.dump.channels(systemid, ["redhat-linux-i386-7.2"])
#f = server.dump.packages(systemid, ["rhn-package-20514", "rhn-package-46019",
#    "rhn-package-46020", "rhn-package-46021", "rhn-package-46022"])
f = server.dump.packages_short(systemid, ["rhn-package-short-20514", 
    "rhn-package-short-46019", "rhn-package-short-46020", 
    "rhn-package-short-46021", "rhn-package-short-46022"])
#f = server.dump.source_packages(systemid, [
#    'rhn-source-package-110855',
#    'rhn-source-package-10925',
#    'rhn-source-package-10847',
#])
                    
#f = server.dump.errata(systemid, ["rhn-erratum-906"])
#f = server.packages_short(21817, 21818, 21819)
#f = server.packages(systemid, ["rhn-package-20514"])
data = f.read()
open("/tmp/output.gz", "w+").write(data)
#print f
