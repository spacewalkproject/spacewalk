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
# Arch import process
#

from importLib import Import

class ArchImport(Import):
    backend_method = ''

    def submit(self):
        meth = getattr(self.backend, self.backend_method)
        meth(self.batch)
        self.backend.commit()

class CPUArchImport(ArchImport):
    backend_method = 'processCPUArches'

class TypedArchImport(ArchImport):
    def preprocess(self):
        self.arch_types = {}
        for item in self.batch:
            arch_type_label = item['arch-type-label']
            arch_type_name = item['arch-type-name']
            self.arch_types[arch_type_label] = arch_type_name

    def fix(self):
        self.backend.lookupArchTypes(self.arch_types)
        for item in self.batch:
            item['arch_type_id'] = self.arch_types[item['arch-type-label']]

class ChannelArchImport(TypedArchImport):
    backend_method = 'processChannelArches'

class PackageArchImport(TypedArchImport):
    backend_method = 'processPackageArches'

class ServerArchImport(TypedArchImport):
    backend_method = 'processServerArches'

class BaseArchCompatImport(Import):
    # Things that have to be overridden in subclasses
    arches1_lookup_method_name = ''
    arches2_lookup_method_name = ''
    arches1_name = ''
    arches2_name = ''
    arches1_field_name = ''
    arches2_field_name = ''
    submit_method_name = ''
    def __init__(self, batch, backend):
        Import.__init__(self, batch, backend)
        self.arches1 = {}
        self.arches2 = {}

    def preprocess(self):
        # Build the hashes keyed on the label
        for entry in self.batch:
            self.arches1[entry[self.arches1_name]] = None
            self.arches2[entry[self.arches2_name]] = None

    def fix(self):
        # Look up the arches
        getattr(self.backend, self.arches1_lookup_method_name)(self.arches1)
        getattr(self.backend, self.arches2_lookup_method_name)(self.arches2)
        self._postprocess()

    def _postprocess(self):
        for entry in self.batch:
            arch1_name = entry[self.arches1_name]
            val = self.arches1.get(arch1_name)
            if not val:
                raise ValueError("Unsupported arch %s" % arch1_name)
            entry[self.arches1_field_name] = val
            
            arch2_name = entry[self.arches2_name]
            val = self.arches2.get(arch2_name)
            if not val:
                raise ValueError("Unsupported arch %s" % arch2_name)
            entry[self.arches2_field_name] = val

    def submit(self):
        getattr(self.backend, self.submit_method_name)(self.batch)
        self.backend.processVirtSubLevel(self.batch)
        self.backend.processSGTVirtSubLevel(self.batch)
        self.backend.commit()

class ServerPackageArchCompatImport(BaseArchCompatImport):
    arches1_lookup_method_name = 'lookupServerArches'
    arches2_lookup_method_name = 'lookupPackageArches'
    arches1_name = 'server-arch'
    arches2_name = 'package-arch'
    arches1_field_name = 'server_arch_id'
    arches2_field_name = 'package_arch_id'
    submit_method_name = 'processServerPackageArchCompatMap'

class ServerChannelArchCompatImport(BaseArchCompatImport):
    arches1_lookup_method_name = 'lookupServerArches'
    arches2_lookup_method_name = 'lookupChannelArches'
    arches1_name = 'server-arch'
    arches2_name = 'channel-arch'
    arches1_field_name = 'server_arch_id'
    arches2_field_name = 'channel_arch_id'
    submit_method_name = 'processServerChannelArchCompatMap'

class ChannelPackageArchCompatImport(BaseArchCompatImport):
    arches1_lookup_method_name = 'lookupChannelArches'
    arches2_lookup_method_name = 'lookupPackageArches'
    arches1_name = 'channel-arch'
    arches2_name = 'package-arch'
    arches1_field_name = 'channel_arch_id'
    arches2_field_name = 'package_arch_id'
    submit_method_name = 'processChannelPackageArchCompatMap'


class ServerGroupServerArchCompatImport(BaseArchCompatImport):
    arches1_lookup_method_name = 'lookupServerArches'
    arches2_lookup_method_name = 'lookupServerGroupTypes'
    arches1_name = 'server-arch'
    arches2_name = 'server-group-type'
    arches1_field_name = 'server_arch_id'
    arches2_field_name = 'server_group_type'
    submit_method_name = 'processServerGroupServerArchCompatMap'
    virt_sub_level     = 'virt_sub_level' 
    
