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
# Kickstart functions for Xen guests.
#

import os
import random
import stat
import string
import struct
import sys
import time
import traceback
import socket

# Import some support functionality.
import virtualization.start_domain as domain_starter

import virtualization.support as virt_support

from virtualization.domain_directory import DomainDirectory
from virtualization.util import hyphenize_uuid

# Import the umbrella virtualization exception.
from virtualization.errors import VirtualizationException
from virtualization.batching_log_notifier import BatchingLogNotifier

from rhnkickstart import common
from rhnkickstart.config import GUEST_KS_START_THRESHOLD, \
    GUEST_KS_END_THRESHOLD

# Import the relevant exceptions.
from rhnkickstart.virtualization_kickstart_exceptions import \
    DiskImageCreationException,                 \
    UnsupportedFeatureException,                \
    VirtLibNotFoundException,                   \
    VirtualizationKickstartException

###############################################################################
# Constants
###############################################################################
DEBUG = 0
DEBUG_MAC_ADDRESS = "73:57:73:57:73:57"
SYSLOG_PORT       = "22429"

XEN_INSTALL_IMAGE_DIR = "/var/lib/xen"
XEN_RUN_IMAGE_DIR     = "/var/lib/xen"
XEN_DISK_IMAGE_DIR    = "/var/lib/xen/images"

# Number of seconds between checks to the running domains list:
GUEST_KS_CHECK_INTERVAL = 10

##
# This is the xen guest creation XML.
#
XEN_CREATE_TEMPLATE = """
    <domain type='xen'>
        <name>%(name)s</name>
        <os>
            <type>linux</type>
            <kernel>%(install_kernel)s</kernel>
            <initrd>%(install_initrd)s</initrd>
            <root>/dev/xvd</root>
            <cmdline> ro root=/dev/xvd %(extra)s %(syslog)s </cmdline>
        </os>
        <memory>%(mem_kb)s</memory>
        <vcpu>%(vcpus)s</vcpu>
        <uuid>%(uuid)s</uuid>
        <on_reboot>destroy</on_reboot>
        <on_poweroff>destroy</on_poweroff>
        <on_crash>destroy</on_crash>
        <devices>
            <disk type='file'>
                <source file='%(disk)s'/>
                <target dev='xvda'/>
            </disk>
            <interface type='bridge'>
                <source bridge='xenbr0'/>
                <mac address='%(mac)s'/>
                <script path='/etc/xen/scripts/vif-bridge'/>
            </interface>
        </devices>
    </domain>
"""

###############################################################################
# Public interface
###############################################################################

def initiate_guest(name, mem_kb, vcpus, disk_gb, extra_append,
        log_notify_handler=None):

    files_to_cleanup = []

    # We'll wrap this up in a try block so that we can clean up should an
    # exception occur.
    try:
        # First, download the kickstart file.
        kickstart_config = common.download_kickstart_file(extra_append)

        # This hack sucks, but it works around a race condition dealing with
        # the tiny url generation on the server.  Basically, if we request
        # the download images too soon after receiving the ks config file, we
        # are served a 404.  We'll remove this hack when we figure out what the
        # server-side issue is.
        time.sleep(5)

        # Download the kernel and initrd images.
        (install_kernel_path, install_initrd_path) = \
            common.download_install_images(kickstart_config, "images/xen",
                XEN_INSTALL_IMAGE_DIR)
        files_to_cleanup.append(install_kernel_path)
        files_to_cleanup.append(install_initrd_path)

        # Create the disk image for the instance.
        disk_image_path = _create_disk_image(name, disk_gb)
        files_to_cleanup.append(disk_image_path)

        # Determine the type of disk image.
        disk_image_type = _determine_disk_image_type(disk_image_path)

        # Generate a UUID for this new instance.
        uuid = _generate_uuid()

        # Generate a MAC address for this new instance.
        if DEBUG:
            mac = DEBUG_MAC_ADDRESS
        else:
            mac = _generate_mac_address()

        # Connect to the hypervisor.
        connection = _connect_to_hypervisor()

        # Now we have enough information to actually create and install the
        # domain.
        domain = _begin_domain_installation( \
            connection,
            name                = name,
            install_kernel_path = install_kernel_path,
            install_initrd_path = install_initrd_path,
            extra_append        = extra_append,
            mem_kb              = mem_kb,
            vcpus               = vcpus,
            uuid                = uuid,
            disk_image_path     = disk_image_path,
            disk_image_type     = disk_image_type,
            mac                 = mac)

        # Wait for the domain's installation to complete.  We must do this so
        # that we can restart the domain with a runnable configuration.
        _wait_for_domain_installation_completion(connection, domain)

        _check_guest_mbr(disk_image_path)

        # Write out the configuration file.
        config_file_path = _create_boot_config_file( \
            name                = name,
            mem_kb              = mem_kb,
            vcpus               = vcpus,
            uuid                = uuid,
            disk_image_path     = disk_image_path,
            disk_image_type     = disk_image_type,
            mac                 = mac)
        files_to_cleanup.append(config_file_path)

        # Restart the domain with the new configuration.
        _boot_domain(uuid)

        # The domain is now started.  Finally, refresh the current
        # virtualization state on the server.

        # VCPUs get plugged in one at a time, querying the hypervisor state
        # too soon was resulting in 1 always being returned. Sleep here
        # allows the hypervisor to plug in the VCPUs and us to get the correct
        # value reported back in RHN:
        time.sleep(5)

        virt_support.refresh()

        # If we got here, we know everything went ok.  We'll only remove the
        # temporary installation kernel and initrd files.
        files_to_cleanup = []
        files_to_cleanup.append(install_kernel_path)
        files_to_cleanup.append(install_initrd_path)

    finally:
        # If something went wrong, the logic will bounce out here before
        # returning to the caller.  We'll use this opportunity to clean up
        # any files that we might have created so far.  It would be quite rude
        # to leave multi-GB sized files laying around.
        for file in files_to_cleanup:
            if os.path.exists(file):
                os.unlink(file)


###############################################################################
# Helper Functions
###############################################################################

def _determine_disk_image_type(disk_image_path):
    if stat.S_ISBLK(os.stat(disk_image_path)[stat.ST_MODE]):
        raise UnsupportedFeatureException, \
              "Instances backed by block devices unsupported. Path: '%s'" % \
                  disk_image_path
    else:
        return 'file'

def _generate_uuid():
    """Generate a random UUID and return it."""

    uuid_list = [ random.randint(0, 255) for _ in range(0, 16) ]
    return ("%02x" * 16) % tuple(uuid_list)

def _generate_mac_address():
    """Generate a random MAC address and return it."""
    mac_list = [ 0x00,
                 0x16,
                 0x3e,
                 random.randint(0x00, 0x7f),
                 random.randint(0x00, 0xff),
                 random.randint(0x00, 0xff) ]
    return ":".join(map(lambda x: "%02x" % x, mac_list))

def _create_disk_image(guest_name, img_size_gb, base_dir = XEN_DISK_IMAGE_DIR):
    """
    Create a disk image for the guest.  The path to the newly-constructed
    image file is returned.
    """
    # Attempt to create the base directory, if it does not yet exist.
    if not os.path.exists(base_dir):
        try:
            os.mkdir(base_dir)
        except Exception, e:
            raise DiskImageCreationException, \
                  "Could not create %s: %s" % (base_dir, str(e)), sys.exc_info()[2]

    # Construct the path of the disk image.
    image_path = os.path.join(base_dir, "%s.disk" % guest_name)

    # If the disk already exists, we will fail.
    if os.path.exists(image_path):
        raise DiskImageCreationException, \
              "Disk image %s already exists." % image_path, sys.exc_info()[2]

    # Attempt to create an image file and fill it with nulls.
    fd = None
    try:
        try:
            fd = os.open(image_path, os.O_WRONLY | os.O_CREAT)
            off = long(img_size_gb * 1024L * 1024L * 1024L)
            os.lseek(fd, off, 0)
            os.write(fd, '\x00')
        except Exception, e:
            raise DiskImageCreationException, \
                  "Error while creating image file %s of size %s GB: %s" % \
                      (image_path, str(img_size_gb), str(e)), sys.exc_info()[2]
    finally:
        if fd: os.close(fd)

    # Disk image was created successfully.  Return the path to it.
    return image_path

def _connect_to_hypervisor():
    """
    Connects to the hypervisor.
    """
    # First, attempt to import libvirt.  If we don't have that, we can't do
    # much else.
    try:
        import libvirt
    except ImportError, ie:
        raise VirtLibNotFoundException, \
              "Unable to locate libvirt: %s" % str(ie), sys.exc_info()[2]

    # Attempt to connect to the hypervisor.
    connection = None
    try:
        connection = libvirt.open(None)
    except Exception, e:
        raise VirtualizationKickstartException, \
              "Could not connect to hypervisor: %s" % str(e), sys.exc_info()[2]

    return connection

def _begin_domain_installation(connection,
                               name,
                               install_kernel_path,
                               install_initrd_path,
                               extra_append,
                               mem_kb,
                               vcpus,
                               uuid,
                               disk_image_path,
                               disk_image_type,
                               mac):
    """
    Creates and begins installation of the Xen instance.
    """

    syslog = 'syslog=%s:%s' % (socket.gethostname(), SYSLOG_PORT)

    if DEBUG:
        syslog  = ''

    create_params = { 'name'           : name,
                      'install_kernel' : install_kernel_path,
                      'install_initrd' : install_initrd_path,
                      'extra'          : extra_append,
                      'mem_kb'         : mem_kb,
                      'vcpus'          : vcpus,
                      'uuid'           : hyphenize_uuid(uuid),
                      'disk'           : disk_image_path,
                      'mac'            : mac,
                      'syslog'         : syslog}

    create_xml = XEN_CREATE_TEMPLATE % create_params

    # Now actually create the domain.
    domain = None
    try:
        domain = connection.createLinux(create_xml, 0)
    except Exception, e:
        raise VirtualizationKickstartException, \
              "Error occurred while attempting to create domain %s: %s" % \
                  (name, str(e)), sys.exc_info()[2]

    # Wait a bit for the instance to start and then ensure that the domain is
    # still around.  If it isn't we will assume that it crashed.
    time.sleep(5)
    try:
        connection.lookupByID(domain.ID())
    except Exception, e:
        raise VirtualizationKickstartException, \
              "Domain '%s' exited too quickly.  It probably crashed: %s" % \
                  (name, str(e)), sys.exc_info()[2]

    return domain

def _wait_for_domain_installation_completion(conn, domain):
    """
    Montor the list of running domain IDs. First we wait for the domain ID to
    appear in the list of running domains. At this time we assume the guest
    kickstart is underway.

    Next we monitor that list of running domain IDs until the one we're
    interested in is no longer present. At this time we assume the guest
    kickstart has terminated successfully.
    """

    # Wait for kickstart to start:
    waiting = 0
    while True:
        if waiting > GUEST_KS_START_THRESHOLD:
            raise VirtualizationKickstartException, \
                "Guest kickstart did not start within %s seconds" % \
                      GUEST_KS_START_THRESHOLD
            break

        if domain.ID() in conn.listDomainsID():
            break

        time.sleep(GUEST_KS_CHECK_INTERVAL)
        waiting = waiting + GUEST_KS_CHECK_INTERVAL

    # Now wait up to a maximum time for the guest to disappear. (i.e. complete)
    waiting = 0
    while True:
        if waiting > GUEST_KS_END_THRESHOLD:
            raise VirtualizationKickstartException, \
                "Guest kickstart did not end within %s seconds" % \
                      GUEST_KS_END_THRESHOLD
            break

        if domain.ID() not in conn.listDomainsID():
            break

        time.sleep(GUEST_KS_CHECK_INTERVAL)
        waiting = waiting + GUEST_KS_CHECK_INTERVAL

def _check_guest_mbr(diskPath):
    """
    A crude test for guest provisioning success, but it's the best we have
    right now.

    Checks the guests disk path for a master boot record that would seem to
    indicate success.

    This code was taken from the python-virtinst package in
    /usr/sbin/virt-install.
    """

    try:
        fd = os.open(diskPath, os.O_RDONLY)
        buf = os.read(fd, 512)
        os.close(fd)
        if len(buf) == 512 and \
                struct.unpack("H", buf[0x1fe: 0x200]) == (0xaa55,):
                return
        else:
            # This looks like a failed install, but it's not certain:
            raise VirtualizationKickstartException, \
                "Guest disk has no MBR, install may have failed: %s" % \
                      diskPath
    except Exception, e:
        raise VirtualizationKickstartException, \
            "Error checking for guest disk MBR, install may have failed: %s" % \
                  diskPath, sys.exc_info()[2]

def _create_boot_config_file(name,
                             mem_kb,
                             vcpus,
                             uuid,
                             disk_image_path,
                             disk_image_type,
                             mac):
    """
    Writes reboot-specific XML out to a config file in our directory.
    """

    if DEBUG:
        mac = DEBUG_MAC_ADDRESS

    # Now write the XML blob out to a file so it can be reused later.
    domain_dir = DomainDirectory()
    try:
        domain_dir.create_standard_config(uuid,
                                          name,
                                          mem_kb,
                                          vcpus,
                                          disk_image_path,
                                          mac)
    except Exception, e:
        raise VirtualizationKickstartException, \
              "Error occurred while attempting to store config file %s: %s" % \
                  (str(uuid), str(e)), sys.exc_info()[2]

    return domain_dir.get_config_path(uuid)

def _boot_domain(uuid):
    """
    Boots the domain for the first time after installation is complete.
    """
    try:
        domain_starter.start_domain(uuid)
    except VirtualizationException, ve:
        (type, value, stack_trace) = sys.exc_info()
        stack_trace_list = traceback.format_tb(stack_trace, None)
        stack_trace_str = string.join(stack_trace_list, '')
        raise VirtualizationKickstartException, \
              "Error occurred while rebooting domain '%s' (%s).  " \
              "Traceback: %s" % \
                  (uuid, str(ve), stack_trace_str), sys.exc_info()[2]

def syslog_listener(host, port, log_notify_handler):
    """
    syslog listener to grab the anaconda output
    """
    log_notifier = BatchingLogNotifier(log_notify_handler)
    log_notifier.start()
    # Caution the user
    log_notifier.add_log_message("RHN:: If your guest firewall is enabled, " \
                "some parts of the installation process might not be logged")

    # socket to listen to syslog
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    try:
        s.bind((host, int(port)))
    except socket.error:
        s.close()
        log_notifier.add_log_message("RHN:: Port %s already in use" % port)
        log_notifier.stop()
        return

    try:
        # receive installation log from syslog
        while 1:
            chunk = s.recv(1024)
            if not chunk:
                break
            chunk = chunk + " \n"
            log_notifier.add_log_message(chunk)
        s.close()
    finally:
        # Always make sure we stop the log notifier thread.
        log_notifier.stop()
    return

# Test routine
if __name__ == "__main__":
    initiate_guest("testing02", 268435, 1, 2, " ks=http://fjs-0-19.rhndev.redhat.com/kickstart/ks/org/1x4bb0dc58ff04188d508ee722265463c8/view_label/FC5%20kickstart%20profile%20-%20sat%20hosted")

