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
sys.path.append("/usr/share/rhn/")

###############################################################################
# Constants
###############################################################################

class StateType:
    NOSTATE     = 'nostate'
    RUNNING     = 'running'
    BLOCKED     = 'blocked'
    PAUSED      = 'paused'
    SHUTDOWN    = 'shutdown'
    SHUTOFF     = 'shutoff'
    CRASHED     = 'crashed'

class VirtualizationType:
    PARA  = 'para_virtualized'
    FULLY = 'fully_virtualized'

class IdentityType:
    HOST        = 'host'
    GUEST       = 'guest'

class PropertyType:
    NAME        = 'name'
    UUID        = 'uuid'
    TYPE        = 'virt_type'
    MEMORY      = 'memory_size'
    VCPUS       = 'vcpus'
    STATE       = 'state'
    IDENTITY    = 'identity'
    ID          = 'id'
    MESSAGE     = 'message'

##
# This structure maps the libvirt state enumeration to labels that RHN 
# understands.
# Reasons we don't care about differences between NOSTATE, RUNNING and BLOCKED:
# 1. technically, the domain is still "running"
# 2. RHN / RHN Satellite / Spacewalk are not able to display 'blocked' & 'nostate'
#    as valid states
# 3. to avoid 'Abuse of Service' messages: bugs #230106 and #546676

VIRT_STATE_NAME_MAP = ( StateType.RUNNING,  # VIR_DOMAIN_NOSTATE
                        StateType.RUNNING,  # VIR_DOMAIN_RUNNING
                        StateType.RUNNING,  # VIR_DOMAIN_BLOCKED
                        StateType.PAUSED,   # VIR_DOMAIN_PAUSED
                        StateType.SHUTDOWN, # VIR_DOMAIN_SHUTDOWN
                        StateType.SHUTOFF,  # VIR_DOMAIN_SHUTOFF
                        StateType.CRASHED)  # VIR_DOMAIN_CRASHED

VIRT_VDSM_STATUS_MAP = {
  'Up'  : 'running',
  'Down': 'shutdown',
  'Paused' : 'paused',
  'Powering down' : 'shutoff',
}
