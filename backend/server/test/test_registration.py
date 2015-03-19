#
# Copyright (c) 2008--2015 Red Hat, Inc.
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

from spacewalk.common.rhnConfig import initCFG
from spacewalk.server.rhnSQL import initDB
from spacewalk.server.xmlrpc import registration

initCFG("server.xmlrpc")
initDB('rhnuser/rhnuser@webdev')

r = registration.Registration()

data = {
    'os_release': '8.0',
    'profile_name': 'test local',
    'architecture': 'i686',
    'token': '382c712e94b2505f6070f011e8ec1a7e',
}

open("/tmp/rereg-systemid", "w+").write(r.new_system(data))
