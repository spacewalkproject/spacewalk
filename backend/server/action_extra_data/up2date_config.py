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
# errata-related error handling functions
#

from spacewalk.common.rhnLog import log_debug

# the "exposed" functions
__rhnexport__ = ['get', 'update', ]


def get(server_id, action_id, data={}):
    if not data:
        return
    log_debug(2, "action_error.up2date_config.get: Should do something "
              "useful with this data", server_id, action_id, data)


def update(server_id, action_id, data={}):
    if not data:
        return
    log_debug(2, "action_error.up2date_config.update: Should do something "
              "useful with this data", server_id, action_id, data)
