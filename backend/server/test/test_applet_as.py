#
# Copyright (c) 2008--2016 Red Hat, Inc.
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
from rhn import rpclib

#server = "xmlrpc.rhn.redhat.com"
server = "coyote.devel.redhat.com"

s = rpclib.Server("http://%s/APPLET" % server)

dict = s.applet.poll_packages('2.1AS', 'i386')
pkg_count = len(dict['contents'])
print("Available packages: %d" % pkg_count)
assert pkg_count > 0, "No packages available for 2.1AS"
