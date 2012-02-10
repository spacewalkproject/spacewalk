#
# Copyright (c) 2008--2011 Red Hat, Inc.
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
# Satellite specific authentication xmlrpc method.

import time
from rhn.connections import idn_ascii_to_pune

from spacewalk.common.rhnLog import log_debug
from spacewalk.common.rhnConfig import CFG
from spacewalk.common.rhnException import rhnFault
from spacewalk.common.rhnTranslate import _
from spacewalk.server.rhnHandler import rhnHandler
from spacewalk.server import rhnLib

class Authentication(rhnHandler):
    """ Simple authentication based on hostname and allowed_iss_slaves
    variable in rhn_server_iss.conf
    """
    def __init__(self):
        log_debug(3)
        rhnHandler.__init__(self)
        self.functions.append('check')
        self.functions.append('login')
        
        # our own defaults for authentication
        self.check_for_abuse = 0

        # this is populated directly by server.apacheRequest.py
        self.remote_hostname = ''

    def auth_system(self):
        if CFG.DISABLE_ISS:
            raise rhnFault(2005, _('ISS is disabled on this satellite.'))

        if CFG.ALLOWED_ISS_SLAVES:
            if not isinstance(CFG.ALLOWED_ISS_SLAVES, list):
                allowed_iss_slaves = [CFG.ALLOWED_ISS_SLAVES]
            else:
                allowed_iss_slaves = CFG.ALLOWED_ISS_SLAVES
            allowed_iss_slaves = [idn_ascii_to_pune(x) for x in allowed_iss_slaves]
        else:
            allowed_iss_slaves = []

        if self.remote_hostname not in allowed_iss_slaves:
            raise rhnFault(2004,
              _('Server "%s" is not enabled for ISS.')
                % self.remote_hostname)
        return self.remote_hostname
        
    def check(self, system_id_ignored):
        """xmlrpc authentication.
        """
        log_debug(3)

        # Authenticate server 
        try:
            self.auth_system()
        except rhnFault, e:
            if e.code == 2002:
                # Return an error code
                return 0
            # Pass the exception through
            raise
        # This is a satellite
        return 1

    # Log in routine.
    def login(self, system_id, extra_data={}):
        """Return a dictionary of session token/channel information.
           Also sets this information in the headers.
        """
        log_debug(5, self.remote_hostname)
        # Authenticate the system certificate.
        self.auth_system()

        # log the entry
        log_debug(1, self.remote_hostname)

        rhnServerTime = str(time.time())
        expireOffset = str(CFG.SATELLITE_AUTH_TIMEOUT)
        signature = rhnLib.computeSignature(CFG.SECRET_KEY,
                                     self.remote_hostname,
                                     rhnServerTime,
                                     expireOffset)
        
        loginDict = {
                'X-RHN-Server-Hostname'     : self.remote_hostname,
                'X-RHN-Auth'                : signature,
                'X-RHN-Auth-Server-Time'    : rhnServerTime,
                'X-RHN-Auth-Expire-Offset'  : expireOffset,
                }

        # XXX This request is not proxy-cacheable
        log_debug(5, "loginDict", loginDict)

        return loginDict

