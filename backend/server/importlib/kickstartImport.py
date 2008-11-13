#!/usr/bin/env python
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
# Package import process
#
import os.path
from importLib import KickstartableTree, Import
from common import CFG
import cobbler.api
from satellite_tools.syncLib import log
class KickstartableTreeImport(Import):
    def __init__(self, batch, backend):
        Import.__init__(self, batch, backend)

        self.channels = {}

        self.kstree_types = {}
        self.ks_install_types = {}

    def preprocess(self):
        # Processes the batch to a form more suitable for database
        # operations
        for ent in self.batch:
            if not isinstance(ent, KickstartableTree):
                raise TypeError("Expected a KickstartableTree instance")

            channel_label = ent['channel']
            self.channels[channel_label] = None

            # If the ks type and install type are missing, populate them
            kstree_type_label = ent['kstree_type_label']
            kstree_type_name = ent['kstree_type_name']
            self.kstree_types[kstree_type_label] = kstree_type_name
            
            ks_install_label = ent['install_type_label']
            ks_install_name = ent['install_type_name']
            self.ks_install_types[ks_install_label] = ks_install_name

    def fix(self):
        self.backend.lookup_kstree_types(self.kstree_types)
        self.backend.lookup_ks_install_types(self.ks_install_types)
        self.backend.lookupChannels(self.channels)

        for ent in self.batch:
            if ent.ignored:
                continue
            channel_label = ent['channel']
            channel = self.channels[channel_label]
            if channel is None:
                raise Exception("Channel %s not imported" % channel_label)
            ent['channel_id'] = channel['id']
            # Now fix the other ids
            kstree_type_label = ent['kstree_type_label']
            ks_install_label = ent['install_type_label']
            ent['kstree_type'] = self.kstree_types[kstree_type_label]
            ent['install_type'] = self.ks_install_types[ks_install_label]

    def submit(self):
        self.backend.processKickstartTrees(self.batch)
        self._add_to_cobbler()
        self.backend.commit()

    def _add_to_cobbler (self):
        log(1, "Updating Cobbler Repository")
        api = cobbler.api.BootAPI()
        for ks_tree in self.batch:
            distro = api.find_distro(ks_tree['label'])
            full_path = os.path.join(CFG.MOUNT_POINT,ks_tree['base_path'])
            kernel = os.path.join(full_path, "images/pxeboot/vmlinuz")
            initrd = os.path.join(full_path, "images/pxeboot/initrd.img")
            if not distro:
                distro = api.new_distro()
                distro.set_name(ks_tree['label'])
                distro.set_kernel(kernel)
                distro.set_initrd(initrd)
                api.add_distro(distro, True)
            else:
                change = False
                if distro.kernel != kernel:
                    log(1, "Warning the kernel location  for distro '%s' was updated from %s to %s" % (distro.name, distro.kernel, kernel))
                    distro.set_kernel(kernel)
                    change = True
                if distro.initrd != initrd:
                    log(1, "Warning theinitrd image for distro '%s' was updated from %s to %s" % (distro.name, 
                                                                                                        distro.initrd, initrd))
                    distro.set_initrd(initrd)
                    change = True
                if change:
                    api.add_distro(distro, False)
                    
        log(1, "Update Complete")
