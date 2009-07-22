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

import commands
import libvirt
import os
import os.path
import re
import sys

from virtualization.domain_directory import DomainDirectory
from virtualization.domain_config    import DomainConfig, DomainConfigError
from virtualization.errors           import VirtualizationException

###############################################################################
# Constants
###############################################################################

PYGRUB = "/usr/bin/pygrub"

###############################################################################
# Public Interface
###############################################################################

def start_domain(uuid):
    """
    Boots the domain for the first time after installation is complete.
    """
    # Load the configuration file for this UUID.
    domain = DomainDirectory()
    config = domain.load_config(uuid)

    # Connect to the hypervisor.
    connection = libvirt.open(None)

    # We will attempt to determine if the domain is configured to use a 
    # bootloader.  If not, we'll have to explicitly use the kernel and initrd 
    # data provided in the config to start the domain.
    try:
        config.getConfigItem(DomainConfig.BOOTLOADER)
    except DomainConfigError, dce:
        # No bootloader tag present.  Use pygrub to extract the kernel from
        # the disk image if its Xen. For fully virt we dont have pygrub, it
        # directly emulates the BIOS loading the first sector of the boot disk.
        if connection.getType() == 'Xen':
            # This uses pygrub which comes only with xen 
            _prepare_guest_kernel_and_ramdisk(config)

    # Now, we'll restart the instance, this time using the re-create XML.
    try:
        domain = connection.createLinux(config.toXML(), 0)
    except Exception, e:
        raise VirtualizationException, \
              "Error occurred while attempting to recreate domain %s: %s" % \
                  (uuid, str(e))

###############################################################################
# Helper Methods
###############################################################################

def _prepare_guest_kernel_and_ramdisk(config):
    """
    Use PyGrub to extract the kernel and ramdisk from the given disk image.
    """ 

    disk_image = config.getConfigItem(DomainConfig.DISK_IMAGE_PATH)

    # Use pygrub to extract the initrd and the kernel from the disk image.
    (status, output) = \
        commands.getstatusoutput("%s -q %s" % (PYGRUB, disk_image))
    if status != 0:
        raise VirtualizationException, \
            "Error occured while executing '%s' (status=%d). Output=%s" % \
                (PYGRUB, status, output)

    # Now analyze the output and extract the names of the new kernel and initrd
    # images from it.
    (pygrub_kernel_path, pygrub_initrd_path) = \
        _extract_image_paths_from_pygrub_output(output)

    # Rename the extracted images to the names we are pointing to in the
    # configuration file.
    runtime_kernel_path = config.getConfigItem(DomainConfig.KERNEL_PATH)
    runtime_initrd_path = config.getConfigItem(DomainConfig.RAMDISK_PATH)

    try:
        os.rename(pygrub_kernel_path, runtime_kernel_path)
        os.rename(pygrub_initrd_path, runtime_initrd_path)
    except OSError, oe:
        raise VirtualizationException, \
              "Error occurred while renaming runtime image paths: %s" % str(oe)


def _extract_image_paths_from_pygrub_output(output):
    """
    Searches for the paths of the kernel and initrd files in the output of
    pygrub.  If not found, a VirtualizationException is raised.  Otherwise,
    the (kernel_path, initrd_path) tuple is returned.
    """
    match = re.search("^linux \(kernel (\S+)\)\(ramdisk (\S+)\)",
                      output,
                      re.MULTILINE)
    if match is None or len(match.groups()) != 2:
        raise VirtualizationException, \
              "Could not locate kernel and initrd in pygrub output: %s" % \
                  output

    kernel_path = match.group(1)
    initrd_path = match.group(2)

    return (kernel_path, initrd_path)

if __name__ == "__main__":
    print "result=", start_domain(sys.argv[1])
