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
from spacewalk.satellite_tools import connection

systemid = open("systemid-satellite-live").read()
#server_url = "http://satellite.rhn.webqa.redhat.com/SAT"
server_url = "http://satellite.rhn.redhat.com/SAT"

server = connection.StreamConnection(server_url)
#print server.kickstart.get_ks_file(systemid, 'ks-redhat-advanced-server-i386', 
print server.kickstart.get_ks_file(systemid, 'ks-rhel-i386-ws-4', 
    '.discinfo')
#print server.kickstart.get_ks_file(systemid, 'ks-rhel-i386-as-3', 
#    'images/pxeboot/initrd.img')
