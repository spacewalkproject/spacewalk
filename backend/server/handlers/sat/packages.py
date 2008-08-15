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
# Satellite only package downloading methods.

# system imports
from rhn import rpclib

# common imports
from common import log_debug

# server imports
from auth import Authentication

# local imports
import rhnPackage

class Packages(Authentication):
    """Package fetcher for satellite sync code.
    """
    def __init__(self):
        log_debug(3)
        Authentication.__init__(self)
        self.functions = [
            'get',
        ]
        
    def get(self, system_id, channel, nvrea):
        """xmlrpc package fetch for satellite only.
        
        NOTE: eventually this needs to go away and we'll reuse the
              regular server GET request codepath.
        """
        log_debug(3)

        # Authenticate server 
        # NOTE: we temp disable abuse checking here (satellites can't abuse)
        server = self.auth_system(system_id)

        # log the entry
        log_debug(1, self.server_id)

        self._auth_channel(channel)

        filePath, pkgId = rhnPackage.get_package_path_by_nvrea(server,
            nvrea, channel)

        return rpclib.File(open(filePath, "r"))
