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
# remote script functions
#

from common import log_debug
from server import rhnSQL

# the "exposed" functions
__rhnexport__ = ['run']

_query_action_script = rhnSQL.Statement("""
    select script, username, groupname, timeout,
           TO_CHAR(sysdate, 'YYYY-MM-DD HH24:MI:SS') as now
      from rhnActionScript
     where action_id = :action_id
""")

def run(server_id, action_id, dry_run=0):
    log_debug(3, dry_run)

    data = {}

    h = rhnSQL.prepare(_query_action_script)
    h.execute(action_id=action_id)

    info = h.fetchone_dict() or []

    if info:
        data['username'] = info['username']
        data['groupname'] = info['groupname']
        data['timeout'] = info['timeout'] or ''
        data['script'] = rhnSQL.read_lob(info['script']) or ''
        # used to make the resulting times make some sense in the db
        data['now'] = info['now']


    return action_id, data
