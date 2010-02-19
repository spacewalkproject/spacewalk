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
from virtualization import support, errors

__rhnexport__ = [
    'refresh',
    'shutdown',
    'suspend',
    'start',
    'resume',
    'reboot',
    'destroy',
    'setMemory',
    'setVCPUs',
    'schedulePoller']

##
# Refreshes the virtualization info for this host and any subdomains on the
# server.
#
def refresh():
    try:
        support.refresh()
    except errors.VirtualizationException, ve:
        return (1, str(ve), {})
    return (0, "Virtualization Info refreshed.", {})

def shutdown(uuid):
    try:
        support.shutdown(uuid)
    except errors.VirtualizationException, ve:
        return (1, str(ve), {})
    return (0, "Domain %s shutdown." % str(uuid), {})

def start(uuid):
    try:
        support.start(uuid)
    except errors.VirtualizationException, ve:
        return (1, str(ve), {})
    return (0, "Domain %s started." % str(uuid), {})

def suspend(uuid):
    try:
        support.suspend(uuid)
    except errors.VirtualizationException, ve:
        return (1, str(ve), {})
    return (0, "Domain %s suspended." % str(uuid), {})

def resume(uuid):
    try:
        support.resume(uuid)
    except errors.VirtualizationException, ve:
        return (1, str(ve), {})
    return (0, "Domain %s resumed." % str(uuid), {})

def reboot(uuid):
    try:
        support.reboot(uuid)
    except errors.VirtualizationException, ve:
        return (1, str(ve), {})
    return (0, "Domain %s rebooted." % str(uuid), {})

def destroy(uuid):
    try:
        support.destroy(uuid)
    except errors.VirtualizationException, ve:
        return (1, str(ve), {})
    return (0, "Domain %s destroyed." % str(uuid), {})

def setMemory(uuid, memory):
    try:
        support.setMemory(uuid, memory)
    except errors.VirtualizationException, ve:
        return (1, str(ve), {})
    return (0, "Memory set to %s on %s." % (str(memory), str(uuid)), {})

def setVCPUs(uuid, vcpus):
    try:
        support.setVCPUs(uuid, vcpus)
    except errors.VirtualizationException, ve:
        return (1, str(ve), {})
    return (0, "VCPUs set to %s on %s." % (str(vcpus), str(uuid)), {})

def schedulePoller(minute, hour, dom, month, dow):
    ret_val = support.schedulePoller(minute, hour, dom, month, dow)
    return (ret_val[0], ret_val[1], {})

###############################################################################
# Test Routine
###############################################################################

if __name__ == "__main__":
    import sys
    import actions.virt
    func = getattr(actions.virt, sys.argv[1])
    print apply(func, tuple(sys.argv[2:]))

