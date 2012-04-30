#
# Copyright (c) 2012 Red Hat, Inc.
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

from spacewalk.common.rhnLog import log_debug
from spacewalk.server import rhnSQL
from spacewalk.server.rhnLib import InvalidAction

__rhnexport__ = ['xccdf_eval']

def xccdf_eval(server_id, action_id, dry_run=0):
    log_debug(3)
    statement = """
        select path, parameters
        from rhnActionScap
        where action_id = :action_id"""
    h = rhnSQL.prepare(statement)
    h.execute(action_id=action_id)
    dict = h.fetchone_dict()
    if not dict:
        raise InvalidAction("scap.xccdf_eval: Unknown action id "
            "%s for server %s" % (action_id, server_id))
    return ({
        'path': dict['path'],
        'params': rhnSQL.read_lob(dict['parameters']) or ''
        },)
