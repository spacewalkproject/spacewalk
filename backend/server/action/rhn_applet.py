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
# rhn_applet related scheduled actions
#
# As a response to a queue.get, retrieves/deletes a queued action from
# the DB.
#

from common import log_debug

# the "exposed" functions
__rhnexport__ = ['use_satellite']


# tell the applet to copy up2date's configs,
# and tie the uuid to rhnServer.id
#
# effectively, a noop serverside until the scheduled action
# runs.
def use_satellite(serverId, actionId, dry_run=0):
    log_debug(3)
    return None
