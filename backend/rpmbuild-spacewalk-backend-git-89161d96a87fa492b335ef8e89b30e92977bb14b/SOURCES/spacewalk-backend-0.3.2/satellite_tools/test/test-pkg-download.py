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
import xmlrpclib

systemid = open("systemid-satellite-live").read()
#server = xmlrpclib.Server("https://rhn.webdev.redhat.com/cgi-bin/satellite.pl")
#server = xmlrpclib.Server("https://rhn.webqa.redhat.com/cgi-bin/satellite.pl")
#server = xmlrpclib.Server("http://minbar.devel.redhat.com/cgi-bin/satellite.pl")
#server = xmlrpclib.Server("https://rhn.redhat.com/cgi-bin/satellite.pl")
#server = xmlrpclib.Server("http://roadrunner.devel.redhat.com/SAT-DUMP")
server = xmlrpclib.Server("http://roadrunner.devel.redhat.com/SAT")
print server.package.get(systemid, 'redhat-advanced-server-i386', 
    ['tar', '1.13.25', '4.AS21.0', '', 'i386'])

print server.package.get(systemid, 'redhat-rhn-satellite-i386-7.2', 
    ['tkinter', '1.5.2', '36.rhn.2.7x', '', 'i386'])
