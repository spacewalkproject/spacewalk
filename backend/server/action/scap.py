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
    d = h.fetchone_dict()
    if not d:
        raise InvalidAction("scap.xccdf_eval: Unknown action id "
            "%s for server %s" % (action_id, server_id))
    return ({
        'path': d['path'],
        'id': action_id,
        'file_size': _scap_file_limit(server_id),
        'params': rhnSQL.read_lob(d['parameters']) or ''
        },)

def _scap_file_limit(server_id):
    statement = """
        select roc.scap_file_sizelimit as limit, roc.scapfile_upload_enabled as enabled
        from rhnOrgConfiguration roc,
             rhnServer rs
        where rs.id = :server_id
          and rs.org_id = roc.org_id"""
    h = rhnSQL.prepare(statement)
    h.execute(server_id=server_id)
    d = h.fetchone_dict()
    if not d or d['enabled'] != 'Y':
        return 0
    return d['limit']
