#
# Copyright (c) 2014--2016 Red Hat, Inc.
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

import sys

if sys.version_info[0] == 3:
    unicode = str
sys.path.append("/usr/share/rhn/")

from up2date_client import rhnreg
from up2date_client import rhnserver
from up2date_client import up2dateAuth

__rhnexport__ = [ 'update_client_cert' ]

def update_client_cert(cache_only=None):
    server = rhnserver.RhnServer()

    if not server.capabilities.hasCapability('registration.update_systemid'):
        return(1, 'parent lacks registration.update_systemid capability', {})

    old_system_id = up2dateAuth.getSystemId().strip()
    new_system_id = server.registration.update_systemid(old_system_id).strip()

    if old_system_id == new_system_id:
        return (1, 'not updating client certificate: old and new certificates match', {})

    # Write out the new client certificate
    if isinstance(new_system_id, unicode):
        rhnreg.writeSystemId(unicode.encode(new_system_id, 'utf-8'))
    else:
        rhnreg.writeSystemId(new_system_id)

    return (0, 'client certificate updated', {})
