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
#

from spacewalk.common import rhnFlags
from spacewalk.common.rhnLog import log_debug
from spacewalk.server.rhnServer import server_kickstart

# the "exposed" functions
__rhnexport__ = ['reboot']


def reboot(server_id, action_id, data={}):
    log_debug(3, action_id)

    action_status = rhnFlags.get('action_status')
    server_kickstart.update_kickstart_session(server_id, action_id,
                                              action_status, kickstart_state='restarted',
                                              next_action_type=None)
