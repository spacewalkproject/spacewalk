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
# rollback functions
#
#

from spacewalk.common.rhnLog import log_debug, log_error
from spacewalk.server.rhnLib import InvalidAction

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
    # since rhnActionTransactions table is gone, this call have to fail
    log_error("Invalid rollback.rollback action %s for server id %s" %
              (actionId, serverId))
    raise InvalidAction(
        "Invalid rollback.rollback action %s for server id %s" %
        (actionId, serverId))
