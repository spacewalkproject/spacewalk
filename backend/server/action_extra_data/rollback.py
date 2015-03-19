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

from spacewalk.common.rhnLog import log_debug

# the "exposed" functions
__rhnexport__ = ['config', 'listTransactions', 'rollback']


def config(server_id, action_id, data={}):
    if not data:
        return
    log_debug(2, "action_error.rollback.config: Should do something "
              "useful with this data", server_id, action_id, data)


def listTransactions(server_id, action_id, data={}):
    if not data:
        return
    log_debug(2, "action_error.rollback.listTransactions: Should do something "
              "useful with this data", server_id, action_id, data)


def rollback(server_id, action_id, data={}):
    if not data:
        return
    log_debug(2, "action_error.rollback.listTransactions: Should do something "
              "useful with this data", server_id, action_id, data)
