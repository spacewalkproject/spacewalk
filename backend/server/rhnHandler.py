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
#

from common import RPC_Base, rhnFault, log_debug, log_error, CFG
from common.rhnTranslate import _

from server import rhnServer

# extend the RPC_Base base class
class rhnHandler(RPC_Base):
    def __init__(self):
        RPC_Base.__init__(self)
        # extra class members we handle
        self.server = None
        self.server_id = None
        
        # XXX Some subclasses set this as a string, others as an rhnUser
        self.user = None

        # defaults that can be easily overridden through assignement of self.*
        # do we load the user infomation (seldomly needed)
        self.load_user = 0
        # do we check for entitlement of the server
        self.check_entitlement = 1
        # do we check for abuse
        self.check_for_abuse = 1
        # do we attempt throttling 
        self.throttle = 1
        # attempt quality of service checks
        self.set_qos = 0
        # do we update the checking counters
        self.update_checkin = 1
            
    # Authenticate a system based on the certificate. There are a lot
    # of modifiers that can be set before this function is called (see
    # the __init__ function for this class).

    def auth_system(self, system_id):
        log_debug(3)

        server = rhnServer.get(system_id, load_user = self.load_user)
        if not server:
            # Invalid server certificate.
            raise rhnFault(9, _(
                "Please run rhn_register "
                "(or up2date --register on Red Hat Enterprise Linux 3 or later)\n"
                "as root on this client"))
        self.server_id = server.getid()
        self.server = server
        # update the latest checkin time
        if self.update_checkin:
            server.checkin(check_for_abuse = self.check_for_abuse)

        if not server.validateSatCert():
            log_error("Satellite Certificate has expired")
            raise rhnFault(3006, "Satellite Certificate has expired")

        # is the server entitled?
        if self.check_entitlement:
            entitlements = server.check_entitlement()
            if not entitlements: # we require entitlement for this functionality
                log_error("Server Not Entitled", self.server_id)
                raise rhnFault(31, _(
                    'Service not enabled for system profile: "%s"')
                               % server.server["name"])

        # Kind of poking where we shouldn't, but what the hell
        if self.load_user and not self.user is None:
            self.user = server.user.username
        else:
            self.user = None

        if self.user is None:
            self.user = ""
        # Throttle users if necessary
        if self.throttle:
            server.throttle()
        # Set QOS
        if self.set_qos:
            server.set_qos()
        return server

