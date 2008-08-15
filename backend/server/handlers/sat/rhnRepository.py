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
# Overloads server.rhnRepository 
# Spacewalk specific authentication checking.

## common imports
from common import log_debug, rhnFault
from common.rhnTranslate import _

## server imports
from server import rhnRepository

## local imports
import rhnPackage

class Repository(rhnRepository.Repository):
    def __init__(self, channelName=None, server_id=None, username=None):
        log_debug(3, channelName, server_id)
        rhnRepository.Repository.__init__(self, channelName, server_id, username)

    """ Overload server's version of this method.
     check package fetch authorization... a seperate method so it can be
     easily overloaded.
    """
    def _checkPackageAuth(self, pkgFilename, source=0):
        # Authorize this package fetch.
        authYN = 1
        if source:
            authYN = rhnPackage.auth_for_source_package_name(self.server_id, pkgFilename, self.channelName)
        else:
            authYN = rhnPackage.auth_for_package_name(self.server_id, pkgFilename, self.channelName)
        if not authYN:
            raise rhnFault(17, _("Package does not exist or unauthorized to retrieve it %s") % str(pkgFilename))


