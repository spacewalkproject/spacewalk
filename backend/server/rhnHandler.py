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
#

from common import RPC_Base, rhnFault, log_debug, log_error, CFG
from common.rhnTranslate import _

from server import rhnServer

disabled_error_msg = _("""
     Your demo account has been disabled. To enable your account, you must 
     verify your email address by visiting:

     %(email_link)s

     You may also enable your account by purchasing Red Hat Network service at:

     https://rhn.redhat.com/network/sales/index.pxt
                    
     Your account name:      %(login)s
     Current email on file:  %(email)s
""")

disabled_freeloader_msg = _("""
     Your demo account has been disabled.  To enable your account, you must
     fill out the latest Red Hat Network survey by visiting:

     %(survey_link)s

     You may also enable your Red Hat Network account by purchasing service at:

     https://rhn.redhat.com/network/sales/index.pxt

     Your account name:      %(login)s
""")

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
    # Since this handler is only for ISS and if we got here, our IP is
    # allowed. And since we do not manage certificates of slaves satellites,
    # we allow all.
    #
    # We return 1 if everything went fine.    
    def auth_system(self, system_id):
        """ Authenticate a system based on the certificate. There are a lot
        of modifiers that can be set before this function is called (see
        the __init__ function for this class).
        Since this handler is only for ISS and if we got here, our IP is
        allowed. And since we do not manage certificates of slaves satellites,
        we allow all.
    
        We return 1 if everything went fine.
        """
        log_debug(3)

        if self.user is None:
            self.user = ""
        # Throttle users if necessary
        if self.throttle:
            server.throttle()
        # Set QOS
        if self.set_qos:
            server.set_qos()
        return 1
