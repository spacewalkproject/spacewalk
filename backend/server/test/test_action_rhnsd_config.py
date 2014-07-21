#
# Copyright (c) 2008--2013 Red Hat, Inc.
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
from spacewalk.server import rhnSQL, rhnAction

rhnSQL.initDB('rhnuser/rhnuser@webdev')

server_id = 1003486768
try:
    action_id = rhnAction.schedule_server_action(server_id, 'rhnsd.configure')

    h = rhnSQL.prepare("""
        insert into rhnActionDaemonConfig (action_id, interval)
        values (:action_id, 10)
    """)
    h.execute(action_id=action_id)

except:
    rhnSQL.rollback()
    raise
rhnSQL.commit()
