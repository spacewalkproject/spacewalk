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
from spacewalk.server import rhnSQL
from spacewalk.common.rhnLog import initLOG
from spacewalk.common.rhnConfig import initCFG
from spacewalk.server.xmlrpc import queue

initLOG("stderr", 4)
initCFG('server.xmlrpc')
rhnSQL.initDB('rhnuser/rhnuser@webdev')

q = queue.Queue()
if 1:
    systemid = open("../../test/backend/checks/systemid-farm06").read()
    print(q.get(systemid, version=2))
else:
    q.server_id = 1003485791

    q._invalidate_failed_prereq_actions()

# rhnSQL.rollback()
rhnSQL.commit()
