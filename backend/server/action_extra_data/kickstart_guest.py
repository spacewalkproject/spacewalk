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
from common import log_debug, rhnFlags
from server.rhnServer import server_kickstart

__rhnexport__ = ['initiate', 'add_tools_channel', 'schedule_virt_guest_pkg_install']

def schedule_virt_guest_pkg_install(server_id, action_id, data={}):
    log_debug(3, server_id, action_id)
    
    action_status = rhnFlags.get('action_status')

    if action_status == 3:
        ks_state = 'failed'
        next_action_type = None
    else:
        ks_state = 'complete'
        next_action_type = None

    server_kickstart.update_kickstart_session(server_id, action_id,
        action_status, kickstart_state=ks_state,
        next_action_type=next_action_type)

    

def add_tools_channel(server_id, action_id, data={}):
    log_debug(3, action_id)

    action_status = rhnFlags.get('action_status')
    
    if action_status == 3:
        ks_state = 'failed'
        next_action_type = None
    else:
        ks_state = 'complete'
        next_action_type = 'kickstart_guest.schedule_virt_guest_pkg_install'

    server_kickstart.update_kickstart_session(server_id, action_id,
        action_status, kickstart_state=ks_state,
        next_action_type=next_action_type)


def initiate(server_id, action_id, data={}):
    log_debug(3, action_id)
    
    action_status = rhnFlags.get('action_status')

    if action_status == 3:
        ks_state = 'failed'
        next_action_type = None
    else:
        ks_state = 'in_progress'
        next_action_type = 'kickstart_guest.add_tools_channel'

    server_kickstart.update_kickstart_session(server_id, action_id,
        action_status, kickstart_state=ks_state,
        next_action_type=next_action_type)
