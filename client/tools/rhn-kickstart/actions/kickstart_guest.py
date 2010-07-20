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


import sys

rhnpath="/usr/share/rhn"
if rhnpath not in sys.path:
    sys.path.append(rhnpath)

from rhnkickstart import kickstart_guest
from rhnkickstart.virtualization_kickstart_exceptions \
    import VirtualizationKickstartException

from virtualization.batching_log_notifier import BatchNotifyHandler
from virtualization.constants             import PropertyType
from virtualization.notification          import Plan,                \
                                                 EventType,           \
                                                 TargetType

__rhnexport__ = [
    'initiate'
]

###############################################################################
# Public Interface
###############################################################################

def initiate(ks_session_id, name, mem_kb, vcpus, disk_gb, extra_append, cache_only=None):
    if cache_only:
        return (0, "no-ops for caching", {})
    error_code = 0
    status_message = 'Guest kickstart initiated successfully.'
    error_messages = {}

    log_notify_handler = KickstartLogNotifyHandler(ks_session_id)

    try:
        kickstart_guest.initiate_guest(name, mem_kb, vcpus, disk_gb, 
                extra_append, log_notify_handler)
    except VirtualizationKickstartException, ke:
        error_code = 1
        status_message = str(ke)
    except Exception, e:
        error_code = 1
        status_message = str(e)

    return (error_code, status_message, error_messages)

###############################################################################
# LogNotifyHandler Class
###############################################################################

class KickstartLogNotifyHandler(BatchNotifyHandler):
    
    def __init__(self, ks_session_id):
        self.__ks_session_id = ks_session_id
        self.__plan = None

    def batch_began(self):
        self.__plan = Plan()

    def log_message_discovered(self, log_message):
        self.__plan.add(
            EventType.EXISTS,
            TargetType.LOG_MSG,
            { PropertyType.ID      : self.__ks_session_id,
              PropertyType.MESSAGE : log_message })

    def batch_ended(self):
        self.__plan.execute()

