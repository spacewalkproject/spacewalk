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
# Satellite specific authentication xmlrpc method.

import time

from common import CFG, rhnFault, log_debug
from common.rhnTranslate import _
from server import rhnHandler, rhnSQL, rhnLib

class Authentication(rhnHandler):
    """Simple authentication of a satellite server.
       XXX: need to do a full fledged login sequence sometime.
    """
    def __init__(self):
        log_debug(3)
        rhnHandler.__init__(self)        
        self.functions.append('check')
        self.functions.append('login')
        
        # our own defaults for authentication
        self.check_for_abuse = 0

    def auth_system(self, system_id):
        server = rhnHandler.auth_system(self, system_id)
        if not server.checkSatEntitlement():
            raise rhnFault(2002,
              _('RHN Management Satellite service not enabled for server profile: "%s"')
                % server.server["name"])
        return server
        
    def check(self, system_id):
        """xmlrpc authentication.
        """
        log_debug(3)

        # Authenticate server 
        try:
            self.auth_system(system_id)
        except rhnFault, e:
            if e.code == 2002:
                # Return an error code
                return 0
            # Pass the exception through
            raise
        # This is a satellite
        return 1

    def _auth_channel(self, channel):
        """ Raises 2003 if this satellite server is not allowed to access the
         channel
         XXX Find a way to share code with the exporter code
        """
        _channel_family_query = """
            select channel_family_id, quantity
              from rhnSatelliteChannelFamily
             where server_id = :server_id
            union
            select channel_family_id, to_number(null) quantity
              from rhnPublicChannelFamily
        """
        query = """
            select c.id channel_id, c.label,
                   TO_CHAR(c.last_modified, 'YYYYMMDDHH24MISS') last_modified
              from rhnChannel c, rhnChannelFamilyMembers cfm,
                   (%s
                   ) scf
             where scf.channel_family_id = cfm.channel_family_id
               and cfm.channel_id = c.id
        """ % _channel_family_query

        h = rhnSQL.prepare(query)
        h.execute(server_id=self.server_id)

        #all_channels_hash = self._cursor_to_hash(h, 'label')
        while 1:
            row = h.fetchone_dict()
            if not row:
                # Channel not found, or not allowed
                raise rhnFault(2003, "Unable to access channel %s" % channel, 
                    explain=0)
            label = row['label']
            if label == channel:
                break
        # If we got to this point, access is allowed to this channel


    def _cursor_to_hash(self, cursor, key):
        hash = {}
        while 1:
            row = cursor.fetchone_dict()
            if not row:
                break
            hash[row[key]] = row

        return hash

    # Log in routine.
    def login(self, system_id, extra_data={}):
        """Return a dictionary of session token/channel information.
           Also sets this information in the headers.
        """
        log_debug(5, system_id)
        # Authenticate the system certificate. We need the user record
        # to generate the tokens
        self.load_user = 1       
        self.auth_system(system_id)

        # log the entry
        log_debug(1, self.server_id)

        rhnServerTime = str(time.time())
        expireOffset = str(CFG.SATELLITE_AUTH_TIMEOUT)
        signature = rhnLib.computeSignature(CFG.SECRET_KEY,
                                     self.server_id,
                                     self.user,
                                     rhnServerTime,
                                     expireOffset)
        
        loginDict = {
                'X-RHN-Server-Id'           : self.server_id,
                'X-RHN-Auth-User-Id'        : self.user,
                'X-RHN-Auth'                : signature,
                'X-RHN-Auth-Server-Time'    : rhnServerTime,
                'X-RHN-Auth-Expire-Offset'  : expireOffset,
                }

        # XXX This request is not proxy-cacheable
        log_debug(5, "loginDict", loginDict)

        return loginDict

