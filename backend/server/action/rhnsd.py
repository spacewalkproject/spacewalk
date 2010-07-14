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
# reboot functions
#
#

from server import rhnSQL
from common import log_debug, rhnException

# the "exposed" functions
__rhnexport__ = ['configure']

_query_lookup_interval = rhnSQL.Statement("""
    select interval, decode(restart, 'Y', 1, 'N', 0) restart
      from rhnActionDaemonConfig
     where action_id = :action_id
""")

def configure(serverId, actionId, dry_run=0):
    log_debug(3, dry_run)
    h = rhnSQL.prepare(_query_lookup_interval)
    h.execute(action_id=actionId)
    row = h.fetchone_dict()
    if not row:
        raise rhnException("rhnsd reconfig action scheduled, but no entries "
            "in rhnActionDaemonConfig found")
    # Format: (interval, restart)
    return (row['interval'], row['restart'])
