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

import binascii
import os
import string

try:
    import libvirt
except ImportError:
    # There might not be a libvirt; we won't die here so that other modules
    # who import us can exit gracefully.
    libvirt = None

from virtualization.domain_config import DomainConfig
from virtualization.errors        import VirtualizationException
from virtualization.util          import dehyphenize_uuid, \
                                         hyphenize_uuid,   \
                                         is_host_uuid

###############################################################################
# Constants
###############################################################################

CONFIG_DIR = '/etc/sysconfig/rhn/virt'
STANDARD_CONFIG_TEMPLATE = """
    <domain type='xen'>
        <name>%(name)s</name>
        <bootloader>/usr/bin/pygrub</bootloader>
        <memory>%(mem_kb)s</memory>
        <vcpu>%(vcpus)s</vcpu>
        <uuid>%(uuid)s</uuid>
        <on_reboot>restart</on_reboot>
        <on_poweroff>destroy</on_poweroff>
        <on_crash>preserve</on_crash>
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
# Classes
###############################################################################

class DomainDirectory:

    def __init__(self):
        self.__path = CONFIG_DIR
        self.conn = libvirt.open(None)
        if not self.conn:
            raise VirtualizationException, \
                  "Failed to open connection to hypervisor."

    def get_config_path(self, uuid):
        cfg_filename = "%s.xml" % uuid
        cfg_pathname = os.path.join(self.__path, cfg_filename)
        return cfg_pathname

    def is_known_config(self, uuid):
        """
        Returns true if a config for the given uuid is saved in the directory.
        """
        path = self.get_config_path(uuid)
        return os.path.exists(path)

    def load_config(self, uuid):
        """
        This function loads a domain's configuration by its UUID.  A 
        DomainConfig object is returned.
        """
        return DomainConfig(self.__path, uuid)

    def create_standard_config(self, uuid, name, mem_kb, vcpus, disk, mac):
        # First, populate the XML with the appropriate values.
        boot_params = { 'name'       : name,
                        'mem_kb'     : mem_kb,
                        'vcpus'      : vcpus,
                        'uuid'       : hyphenize_uuid(uuid),
                        'disk'       : disk,
                        'mac'        : mac }

        xml = STANDARD_CONFIG_TEMPLATE % boot_params

        self.__write_xml_file(uuid, xml)

    def save_unknown_domain_configs(self, domain_uuids):
        """
        This function saves the configuration for any domains whose UUIDs are
        passed in the domain_uuids list.  If the UUID is already known, it is
        skipped.
        """
        
        for uuid in domain_uuids:

            # If we already have a config for this uuid, skip it.  Also, don't
            # try to figure out a config for a host UUID.
            if not is_host_uuid(uuid) and not self.is_known_config(uuid):

                # The UUID is a formatted string.  Turn it back into a number, 
                # since that's what libvirt wants.
                dehyphenized_uuid = dehyphenize_uuid(uuid)
                uuid_as_num = binascii.unhexlify(dehyphenized_uuid)
    
                # Lookup the domain by its uuid.
                try:
                    domain = self.conn.lookupByUUID(uuid_as_num)
                except libvirt.libvirtError, lve:
                    raise VirtualizationException, \
                          "Failed to obtain handle to domain %s: %s" % \
                              (uuid, repr(lve))

                # Now grab the XML description of the configuration.
                xml = domain.XMLDesc(0)

                # Write the xml out to a file so that we can load it into our
                # abstract DomainConfig object and manipulate it easily.
                cfg_file_path = self.__write_xml_file(uuid, xml)
                new_config = DomainConfig(self.__path, uuid)

                # Don't record the config this time if the domain is 
                # installing; we don't want to restart the domain later and
                # make it re-install itself.
                if not new_config.isInstallerConfig():

                    # Now we'll reformat the configuration object so that it's
                    # valid the next time this domain runs..
                    self.__fixup_config_for_restart(new_config)
    
                    # The config is now prepared.  Save it and move on to the 
                    # next uuid.
                    new_config.save()

                else:
                    # Remove the config file we just wrote.
                    os.unlink(cfg_file_path)

    def __fixup_config_for_restart(self, config):
        """
        This function edits the given configuration so that it can be used in
        subsequent calls to libvirt's createLinux call.  Specifically, the
        following modifications are made:

            - Remove the "id" attribute from the <domain> tag.  The "id" is
              whatever the hypervisor wants to assign to it, so we should not
              try to assign it explicitly.

            - Determine whether the config contains an <os> section.  
                - If it does, check whether the kernel and the initrd files 
                  it refers to actually exist on disk. 
                    - If so, do nothing.
                    - If not, remove the entire <os> section and insert a
                      <bootloader> section if one does not yet exist.  These
                      files might not exist if the instance was started by xm 
                      using a bootloader such as pygrub, which makes temporary 
                      copies of the kernel & initrd and then removes them after
                      starting the instance.
                - If it does not, ensure there is a <bootloader> section or
                  add one if needed.
        """
        # Remove the domain ID from the XML.  This is a runtime value that 
        # should not be assigned statically.
        if config.hasConfigItem(DomainConfig.DOMAIN_ID):
            config.removeConfigItem(DomainConfig.DOMAIN_ID)

        if self.conn.getType() == 'QEMU':
            # Dont worry about bootloader if its kvm
            return

        boot_images_exist = 0

        if config.hasConfigItem(DomainConfig.KERNEL_PATH) and \
           config.hasConfigItem(DomainConfig.RAMDISK_PATH):

            kernel_path = config.getConfigItem(DomainConfig.KERNEL_PATH)
            ramdisk_path = config.getConfigItem(DomainConfig.KERNEL_PATH)

            if os.path.exists(kernel_path) and os.path.exists(ramdisk_path):
                boot_images_exist = 1

        # If we've determined that the referenced boot images do not exist,
        # remove the OS section and insert a bootloader piece.
        if not boot_images_exist:
            if config.hasConfigItem(DomainConfig.OS):
                config.removeConfigItem(DomainConfig.OS)

            if not config.hasConfigItem(DomainConfig.BOOTLOADER):
                config.setConfigItem(DomainConfig.BOOTLOADER, "/usr/bin/pygrub")

            
    def __write_xml_file(self, uuid, xml):
        cfg_pathname = self.get_config_path(uuid)
        cfg_file = open(cfg_pathname, "w")
        cfg_file.write(string.strip(xml))
        cfg_file.close()

        return cfg_pathname
