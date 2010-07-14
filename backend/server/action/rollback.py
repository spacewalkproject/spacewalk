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
# rollback functions
#
#

from common import log_debug, log_error
from server import rhnSQL
from server.rhnLib import InvalidAction

# the "exposed" functions
__rhnexport__ = ['config', 'listTransactions', 'rollback']

def config(serverId, actionId, dry_run=0):
    log_debug(3)
    # XXX Not working
    return 1

def listTransactions(serverId, actionId, dry_run=0):
    log_debug(3)
    return None
    
def rollback(serverId, actionId, dry_run=0):
    log_debug(3, dry_run)
    h = rhnSQL.prepare("""
        select 
            rt1.rpm_trans_id from_rpm_trans_id,
            rt2.rpm_trans_id to_rpm_trans_id
        from 
            rhnActionTransactions rat, 
            rhnTransaction rt1, 
            rhnTransaction rt2
        where 
            rat.action_id = :action_id
            and rat.from_trans_id = rt1.id
            and rat.to_trans_id = rt2.id
            -- One row per customer, please
            and rownum < 2
    """)
    h.execute(action_id=actionId)
    row = h.fetchone_dict()
    if not row:
        log_error("Invalid rollback.rollback action %s for server id %s" % 
            (actionId, serverId))
        raise InvalidAction(
            "Invalid rollback.rollback action %s for server id %s" % 
            (actionId, serverId))
    return (row['from_rpm_trans_id'], row['to_rpm_trans_id'])

