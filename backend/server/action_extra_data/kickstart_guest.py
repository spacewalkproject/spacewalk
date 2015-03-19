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
from spacewalk.common import rhnFlags
from spacewalk.common.rhnLog import log_debug
from spacewalk.server.rhnServer import server_kickstart

__rhnexport__ = ['initiate', 'add_tools_channel', 'schedule_virt_guest_pkg_install']


def _action(action_name, server_id, action_id, success_state, success_type):
    log_debug(3, action_name, server_id, action_id)

    action_status = rhnFlags.get('action_status')

    if action_status == 3:
        ks_state = 'failed'
        next_action_type = None
    else:
        ks_state = success_state
        next_action_type = success_type

    server_kickstart.update_kickstart_session(server_id, action_id,
                                              action_status, kickstart_state=ks_state,
                                              next_action_type=next_action_type)


def schedule_virt_guest_pkg_install(server_id, action_id, data={}):
    _action('schedule_virt_guest_pkg_install', server_id, action_id,
            'complete', None)


def add_tools_channel(server_id, action_id, data={}):
    _action('add_tools_channel', server_id, action_id,
            'complete', 'kickstart_guest.schedule_virt_guest_pkg_install')


def initiate(server_id, action_id, data={}):
    _action('initiate', server_id, action_id,
            'in_progress', 'kickstart_guest.add_tools_channel')
