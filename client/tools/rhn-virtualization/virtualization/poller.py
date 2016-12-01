#
# Copyright (c) 2008--2014 Red Hat, Inc.
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

import os
import subprocess
import sys
sys.path.append("/usr/share/rhn/")

import binascii
import traceback
import gettext
t = gettext.translation('rhn-virtualization', fallback=True)
_ = t.ugettext

from up2date_client import rhncli

try:
    import libvirt
except ImportError:
    # There might not be a libvirt.
    libvirt = None

from optparse import OptionParser

from virtualization.state              import State
from virtualization.errors             import VirtualizationException
from virtualization.constants          import PropertyType,        \
                                              VirtualizationType,  \
                                              IdentityType,        \
                                              VIRT_STATE_NAME_MAP, \
                                              VIRT_VDSM_STATUS_MAP
from virtualization.notification       import Plan,                \
                                              EventType,           \
                                              TargetType
from virtualization.util               import hyphenize_uuid,      \
                                              is_fully_virt
from virtualization.poller_state_cache import PollerStateCache

from virtualization.domain_directory   import DomainDirectory

from spacewalk.common.usix import raise_with_tb
###############################################################################
# Globals
###############################################################################

options = None

###############################################################################
# Public Interface
###############################################################################

def poll_hypervisor():
    """
    This function polls the hypervisor for information about the currently
    running set of domains.  It returns a dictionary object that looks like the
    following:

    { uuid : { 'name'        : '...',
               'uuid'        : '...',
               'virt_type'   : '...',
               'memory_size' : '...',
               'vcpus'       : '...',
               'state'       : '...' }, ... }
    """
    if not libvirt:
        return {}

    try:
        conn = libvirt.openReadOnly(None)
    except libvirt.libvirtError:
        # virConnectOpen() failed
        sys.stderr.write(rhncli.utf8_encode(_("Warning: Could not retrieve virtualization information!\n\t" +
                                              "libvirtd service needs to be running.\n")))
        conn = None

    if not conn:
        # No connection to hypervisor made
        return {}

    domainIDs = conn.listDomainsID()

    state = {}

    for domainID in domainIDs:
        try:
            domain = conn.lookupByID(domainID)
        except libvirt.libvirtError:
            lve = sys.exc_info()[1]
            raise_with_tb(VirtualizationException("Failed to obtain handle to domain %d: %s" % (domainID, repr(lve)),
                                                  sys.exc_info()[2]))

        uuid = binascii.hexlify(domain.UUID())
        # SEE: http://libvirt.org/html/libvirt-libvirt.html#virDomainInfo
        # for more info.
        domain_info = domain.info()

        # Set the virtualization type.  We can tell if the domain is fully virt
        # by checking the domain's OSType() attribute.
        virt_type = VirtualizationType.PARA
        if is_fully_virt(domain):
            virt_type = VirtualizationType.FULLY

        # we need to filter out the small per/minute KB changes
        # that occur inside a vm.  To do this we divide by 1024 to
        # drop our precision down to megabytes with an int then
        # back up to KB
        memory = int(domain_info[2] / 1024);
        memory = memory * 1024;
        properties = {
            PropertyType.NAME   : domain.name(),
            PropertyType.UUID   : uuid,
            PropertyType.TYPE   : virt_type,
            PropertyType.MEMORY : str(memory), # current memory
            PropertyType.VCPUS  : domain_info[3],
            PropertyType.STATE  : VIRT_STATE_NAME_MAP[domain_info[0]] }

        state[uuid] = properties

    if state: _log_debug("Polled state: %s" % repr(state))

    return state

def poll_through_vdsm(server):
    """
     This method polls all the virt guests running on a VDSM enabled Host.
     Libvirt is disabled by default on RHEV-M managed clients.
     * Imports the localvdsm client that talks to the localhost
       and fetches the list of vms and their info.
     * Extract the data and construct the state to pass it to the
       execution plan for guest polling.
     * The server should account for business rules similar to
       xen/kvm.
    """
    # Extract list of vm's. True returns full list
    try:
        domains = server.list(True)
    except:
        # Something went wrong in vdsm, exit
        return {}

    if not len(domains['vmList']):
        # No domains, exit.
        return {}

    state = {}
    for domain in domains['vmList']:
        #trim uuid
        uuid = domain['vmId'].lower().replace('-', '')
        # Map the VDSM status to libvirt for server compatibility
        status = 'nostate'
        if domain['status'] in VIRT_VDSM_STATUS_MAP:
            status = VIRT_VDSM_STATUS_MAP[domain['status']]
        # This is gonna be fully virt as its managed by VDSM
        virt_type = VirtualizationType.FULLY

        #Memory
        memory = int(domain['memSize']) * 1024

        # vcpus
        if 'smp' in domain:
            vcpus = domain['smp']
        else:
            vcpus = '1'

        properties = {
            PropertyType.NAME   : domain['vmName'],
            PropertyType.UUID   : uuid,
            PropertyType.TYPE   : virt_type,
            PropertyType.MEMORY : memory, # current memory
            PropertyType.VCPUS  : vcpus,
            PropertyType.STATE  : status}

        state[uuid] = properties

    if state: _log_debug("Polled state: %s" % repr(state))

    return state


def poll_state(uuid):
    """
    Polls just the state of the guest with the provided UUID.  This state is
    returned.
    """
    conn = libvirt.openReadOnly(None)
    if not conn:
        raise VirtualizationException("Failed to open connection to hypervisor.")

    # Attempt to connect to the domain.  Since there is technically no
    # "stopped" state, we will assume that if we cannot connect the domain is
    # not running.  Unfortunately, we can't really determine if the domain
    # actually exists.
    domain = None
    try:
        domain = conn.lookupByUUIDString(hyphenize_uuid(uuid))
    except libvirt.libvirtError:
        # Can't find domain.  Return stopped state.
        return State(None)

    # Now that we have the domain, lookup the state.
    domain_info = domain.info()
    return State(VIRT_STATE_NAME_MAP[domain_info[0]])

###############################################################################
# Helper Functions
###############################################################################

def _send_notifications(poller_state):
    """
    This function will send notifications based on vm state change to the
    server.  To reduce the possibility of spamming the server but still
    maintain an element of consistency, it will compare the previous poll state
    against the current poll state and only send notifications if something has
    changed.  In the event that the cache might have gotten into an
    inconsistent state, the cache will be removed after every 50 polls (this is
    about every 1.5 hours).  This will cause the full state to be re-uploaded
    and put things back in sync, if necessary.
    """
    # Now, if anything changed, send the appropriate notification for it.
    if poller_state.is_changed():
        added    = poller_state.get_added()
        removed  = poller_state.get_removed()
        modified = poller_state.get_modified()

        plan = Plan()

        # Declare virtualization host first
        plan.add(EventType.EXISTS,
                 TargetType.SYSTEM,
                 { PropertyType.IDENTITY : IdentityType.HOST,
                   PropertyType.UUID     : '0000000000000000' })

        for (uuid, data) in added.items():
            plan.add(EventType.EXISTS, TargetType.DOMAIN, data)

        for (uuid, data) in modified.items():
            plan.add(EventType.EXISTS, TargetType.DOMAIN, data)

        for (uuid, data) in removed.items():
            plan.add(EventType.REMOVED, TargetType.DOMAIN, data)

        plan.execute()

def _parse_options():
    usage = "Usage: %prog [options]"
    parser = OptionParser(usage)
    parser.set_defaults(debug=False)
    parser.add_option("-d", "--debug", action="store_true", dest="debug")
    global options
    (options, args) = parser.parse_args()

def _log_debug(msg, include_trace = 0):
    if options and options.debug:
        print("DEBUG: " + str(msg))
        if include_trace:
            e_info = sys.exc_info()
            traceback.print_exception(e_info[0], e_info[1], e_info[2])

###############################################################################
# Main Program
###############################################################################

if __name__ == "__main__":

    # First, handle the options.
    _parse_options()

    vdsm_enabled = False
    server = None
    try:
        from virtualization import localvdsm

        if sys.version_info[0] == 3:
            status, msg = subprocess.getstatusoutput("/etc/init.d/vdsmd status")
        else:
            import commands
            status, msg = commands.getstatusoutput("/etc/init.d/vdsmd status")

        if status == 0:
            server = localvdsm.connect()
            vdsm_enabled = True
    except ImportError:
        pass

    # Crawl each of the domains on this host and obtain the new state.
    if vdsm_enabled:
        domain_list = poll_through_vdsm(server)
    elif libvirt:
        # If libvirt is present but not running, this program is useless.
        # Libvirt currently writes to stderr if you attempt to connect
        # and the daemon is not running. The libvirt python bindings provide
        # no way to change this behavior. Anything written to stderr or stdout
        # will cause cron to email root with the output. It is not our
        # job to nag the user every two minutes if libvirt is not running.
        # The only way to avoid this is to shell out to check if libvirt
        # is running, and exit if it's not.
        # See if the libvirtd service is running, discarding all output.
        # Non-zero exit code means it's not running.
        if (subprocess.call(['/sbin/service','libvirtd','status'],
                stdout=open(os.devnull, 'wb'),
                stderr=subprocess.STDOUT) != 0):
            sys.exit(0)
        domain_list = poll_hypervisor()
    else:
        # If no libvirt nor vdsm is present, this program is pretty much
        # useless.  Just exit.
        sys.exit(0)

    # create the unkonwn domain config files (for libvirt only)
    if libvirt and not vdsm_enabled:
        uuid_list = list(domain_list.keys())
        domain = DomainDirectory()
        domain.save_unknown_domain_configs(uuid_list)

    cached_state = PollerStateCache(domain_list,
                                    debug = options and options.debug)

    # Send notifications, if necessary.
    _send_notifications(cached_state)

    # Save the new state.
    cached_state.save()
