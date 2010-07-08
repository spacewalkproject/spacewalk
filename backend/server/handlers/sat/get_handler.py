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
# GET handler for /SAT

import auth

from common import log_debug 
from server import apacheRequest

class GetHandler(apacheRequest.GetHandler):
    """ handles the GET requests for /SAT requests """

    def method_ref(self, method):
        """ get a function reference for the GET request """
        log_debug(3, self.server, method)

        remote_host = self.req.get_remote_host(apache.REMOTE_DOUBLE_REV)
        # Authorize using remote address
        auth_obj = auth.Authentication(remote_host)

        repository = Repository(self.channel)
            
        f = repository.get_function(method)
        if f is None:
            raise apacheRequest.UnknownXML(
                "function '%s' invalid; path_info is %s" % (
                    method, self.req.path_info))
        return f

