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


__rhnexport__ = ['schedulePoller',
                 'reboot',
                 'resume',
                 'start',
                 'suspend',
                 'shutdown',
                 'destroy',
                 'setMemory',
                 'setVCPUs'
                 ]


def _do_nothing(server_id, action_id):
    log_debug(4, action_id)
    action_status = rhnFlags.get('action_status')
    log_debug(4, "Action ID: %s, Action Status: %s" % (str(action_id), str(action_status)))


def schedulePoller(server_id, action_id, data={}):
    _do_nothing(server_id, action_id)


def reboot(server_id, action_id, data={}):
    _do_nothing(server_id, action_id)


def resume(server_id, action_id, data={}):
    _do_nothing(server_id, action_id)


def start(server_id, action_id, data={}):
    _do_nothing(server_id, action_id)


def suspend(server_id, action_id, data={}):
    _do_nothing(server_id, action_id)


def shutdown(server_id, action_id, data={}):
    _do_nothing(server_id, action_id)


def destroy(server_id, action_id, data={}):
    _do_nothing(server_id, action_id)


def setMemory(server_id, action_id, data={}):
    _do_nothing(server_id, action_id)


def setVCPUs(server_id, action_id, data={}):
    _do_nothing(server_id, action_id)
