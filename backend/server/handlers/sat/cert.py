#
# Copyright (c) 2008--2010 Red Hat, Inc.
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
# Satellite only package downloading methods.

# common imports
from spacewalk.common import rhnException, log_debug

# server imports
from spacewalk.server import rhnSQL
from auth import Authentication


class Certificate(Authentication):
    """ Downloads the satellite cert """
    def __init__(self):
        log_debug(3)
        Authentication.__init__(self)
        self.functions = [
            'download',
        ]
        
    def download(self, system_id):
        log_debug(3)
        self.auth_system(system_id)

        server_id = self.server.server['id']
        h = rhnSQL.prepare("""
            select cert
              from rhnSatelliteInfo si
             where si.server_id = :server_id""")
        h.execute(server_id=server_id)
        row = h.fetchone_dict()
        if not row:
            # This should not happen - we're already authenticated
            raise rhnException, "Satellite cert went away after auth?"

        # Bugzilla #219625
        # cert is now a blob
        cert = row['cert']            
        cert = cert.read()

        return cert
