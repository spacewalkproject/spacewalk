#
# Copyright (c) 2006--2012 Red Hat, Inc.  Distributed under GPL.
#
# Author: Peter Vetere <pvetere@redhat.com>
#
# This module handles virtual domain control requests.
#

import sys
sys.path.append("/usr/share/rhn/")

from virtualization import poller, start_domain

from virtualization.errors import VirtualizationException
from virtualization.util   import hyphenize_uuid

try:
    import libvirt
except:
    # The libvirt library is not installed.  That's ok, we can't assume it will
    # be on every system.
    libvirt = None

###############################################################################
# Public Interface
###############################################################################

def shutdown(uuid):
    """
    Shuts down the domain with the given UUID.  If the instance is crashed, it
    is destroyed.  If the instance is paused, it is unpaused and shutdown 
    cleanly.
    """
    state = poller.poll_state(uuid)
    if state.is_crashed():
        destroy(uuid)
    elif state.is_paused():
        resume(uuid)
        shutdown(uuid)
    else:
        _call_domain_control_routine(uuid, "shutdown")

def start(uuid):
    """
    Starts up the domain with the given UUID.
    """
    state = poller.poll_state(uuid)
    if state.is_crashed():
        destroy(uuid)
        start(uuid)
    elif state.is_paused():
        resume(uuid)
    else:
        start_domain.start_domain(uuid)    

def suspend(uuid):
    """
    Suspends the domain with the given UUID.
    """
    _call_domain_control_routine(uuid, "suspend")

def resume(uuid):
    """
    Resumes the domain with the given UUID.
    """
    _call_domain_control_routine(uuid, "resume")

def reboot(uuid):
    """
    Reboots the domain with the given UUID.  If the system is paused, we
    unpause and reboot it.  If the system is stopped, we start it.  If the 
    system is crashed, we destroy and restart it.
    """
    state = poller.poll_state(uuid)
    if state.is_stopped():
        start(uuid)
    elif state.is_paused():
        resume(uuid)
        reboot(uuid)
    elif state.is_crashed():
        destroy(uuid)
        start(uuid)
    else:
        _call_domain_control_routine(uuid, "reboot", 0)

def destroy(uuid):
    """
    Destroys the domain with the given UUID.
    """
    _call_domain_control_routine(uuid, "destroy")

def setMemory(uuid, memory):
    """
    Sets the max memory usage for the domain with the given UUID.
    """
    _call_domain_control_routine(uuid, "setMemory", memory)

def setVCPUs(uuid, vcpus):
    """
    Sets the number of vcpus for the domain with the given UUID.
    """
    _call_domain_control_routine(uuid, "setVcpus", vcpus)
    

###############################################################################
# Helper Routines
###############################################################################

def _get_domain(uuid):
    """
    Lookup the domain by its UUID.  If not found, raise an exception.
    """
    conn = libvirt.open(None)
    domain = None
    hyphenized_uuid = hyphenize_uuid(uuid)
    try:
        domain = conn.lookupByUUIDString(hyphenized_uuid)
    except libvirt.libvirtError, lve:
        raise VirtualizationException, \
              "Domain UUID '%s' not found: %s" (hyphenized_uuid, str(lve)), sys.exc_info()[2]
    return (conn, domain)

def _call_domain_control_routine(uuid, routine_name, *args):
    """
    Call a function in a domain, optionally with a set of arguments.
    """

    # If libvirt is not available, this is a no-op.
    if not libvirt: return

    # Lookup the domain by its UUID.
    (conn, domain) = _get_domain(uuid)

    # Get a reference to the domain's control routine.
    ctrl_func = None
    try:
        ctrl_func = getattr(domain, routine_name)
    except AttributeError:
        raise VirtualizationException, "Unknown function: %s" % routine_name, sys.exc_info()[2]

    result = 0
    try:
        result = apply(ctrl_func, args)
    except TypeError, te:
        raise VirtualizationException, \
              "Invalid arguments (%s) to %s: %s" % \
                  (str(args), routine_name, str(te)), sys.exc_info()[2]
    
    # Handle the return code.  Anything non-zero is an error.
    if result != 0:
        raise VirtualizationException, \
              "Could not perform function '%s' on domain %s.  Error: %s" % \
                  (routine_name, uuid, str(result)), sys.exc_info()[2]
    
