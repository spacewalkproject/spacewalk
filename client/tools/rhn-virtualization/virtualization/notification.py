#
# Copyright (c) 2008--2013 Red Hat, Inc.
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
# This module defines notification-related functions and constants, for use
# with the client-side virtualization code.
#

import sys

import time

from up2date_client import up2dateAuth
from up2date_client import up2dateErrors
from up2date_client import rhnserver
from up2date_client import up2dateLog
from virtualization.errors import NotRegistered

log = up2dateLog.initLog()

###############################################################################
# Constants
###############################################################################

class EventType:
    EXISTS      = 'exists'
    REMOVED     = 'removed'
    CRAWL_BEGAN = 'crawl_began'
    CRAWL_ENDED = 'crawl_ended'

class TargetType:
    SYSTEM      = 'system'
    DOMAIN      = 'domain'
    LOG_MSG     = 'log_message'

###############################################################################
# Plan Class
###############################################################################

class Plan:

    def __init__(self):
        self.__items = []

    def add(self, event, target = None, properties = {}):
        """
        Creates a new plan item and adds it to the list.
        """
        self.__items.append(self.__make_item(event, target, properties))

    def execute(self):
        """
        Sends all items in the plan to the satellite.
        """
        systemid = up2dateAuth.getSystemId()

        if systemid is None:
            raise NotRegistered("System ID not found.")

        server = rhnserver.RhnServer()

        try:
            server.registration.virt_notify(systemid, self.__items)
        except up2dateErrors.CommunicationError:
            e = sys.exc_info()[1]
            log.trace_me()
            log.log_me(e)


    def __make_item(self, event, target, properties):
        """
        Creates a new plan item.
        """

        # Get the current time.
        current_time = int(time.time())
        return ( current_time, event, target, properties )

