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

from spacewalk.server import rhnSQL
from spacewalk.common.rhnLog import log_debug
from spacewalk.server.rhnHandler import rhnHandler

_query_delete_data = rhnSQL.Statement("""
delete from rhnAbrtInfo where server_id = :server_id
""")

_query_store_data = rhnSQL.Statement("""
insert into rhnAbrtInfo(
    id,
    server_id,
    num_crashes,
    created)
values (
    sequence_nextval('rhn_abrt_info_id_seq'),
    :server_id,
    :num_crashes,
    current_timestamp
    )
""")

class Abrt(rhnHandler):
    def __init__(self):
        rhnHandler.__init__(self)
        self.functions.append('handle')

    def handle(self, system_id, version, status, message, data):
        self.auth_system(system_id)
        log_debug(1, self.server_id, version, status, message, data)

        if status == 0:
            h = rhnSQL.prepare(_query_delete_data)
            h.execute(server_id=self.server_id)

            h = rhnSQL.prepare(_query_store_data)
            h.execute(server_id=self.server_id,
                num_crashes=data['num_crashes'])

            rhnSQL.commit()

            return True

        return False
