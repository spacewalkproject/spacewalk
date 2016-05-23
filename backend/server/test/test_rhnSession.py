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

from spacewalk.common.rhnConfig import initCFG
from spacewalk.server import rhnSQL, rhnUser

rhnSQL.initDB("rhnuser/rhnuser@webdev")
initCFG('server.xmlrpc')

u = rhnUser.search("mibanescu-channel-admin")
session = u.create_session()

s = session.get_session()

print("Checking with session", s)

u = rhnUser.session_reload(s)
print(u)
print(u.username)
