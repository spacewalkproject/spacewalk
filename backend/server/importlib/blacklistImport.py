#!/usr/bin/python
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
# Blacklists import
#

from importLib import Import

class BlacklistObsoletesImport(Import):
    def __init__(self, batch, backend):
        Import.__init__(self, batch, backend)
        self.names = {}
        self.evrs = {}
        self.package_arches = {}
    
    def preprocess(self):
        for entry in self.batch:
            self.names[entry['name']] = None
            self.names[entry['ignored-name']] = None
            
            evr = self._make_evr(entry)
            entry['evr'] = evr
            self.evrs[evr] = None
            
            self.package_arches[entry['package-arch']] = None
    
    def fix(self):
        self.backend.lookupPackageNames(self.names)
        self.backend.lookupEVRs(self.evrs)
        self.backend.lookupPackageArches(self.package_arches)
        for entry in self.batch:
            entry['name_id'] = self.names[entry['name']]
            entry['evr_id'] = self.evrs[entry['evr']]
            entry['package_arch_id'] = self.package_arches[entry['package-arch']]
            entry['ignore_name_id'] = self.names[entry['ignored-name']]

    def submit(self):
        self.backend.processBlacklistObsoletes(self.batch)
        self.backend.commit()

    def _make_evr(self, entry):
        result = []
        for label in ['epoch', 'version', 'release']:
            val = entry[label]
            if val is None:
                val = ''
            result.append(val)
        return tuple(result)

if __name__ == '__main__':
    from server import rhnSQL
    rhnSQL.initDB('satuser/satuser@satdev')
    from importLib import BlacklistObsoletes
    batch = [
        BlacklistObsoletes().populate({
            'name'          : 'zebra',
            'epoch'         : '',
            'version'       : '0.91a',
            'release'       : '6',
            'package-arch'  : 'i386',
            'ignored-name'  : 'gated',
        }),
        BlacklistObsoletes().populate({
            'name'          : 'zebra',
            'epoch'         : '',
            'version'       : '0.91a',
            'release'       : '3',
            'package-arch'  : 'i386',
            'ignored-name'  : 'gated',
        }),
        BlacklistObsoletes().populate({
            'name'          : 'zebra',
            'epoch'         : '',
            'version'       : '0.91a',
            'release'       : '3',
            'package-arch'  : 'alpha',
            'ignored-name'  : 'gated',
        }),
        BlacklistObsoletes().populate({
            'name'          : 'gated',
            'epoch'         : '',
            'version'       : '3.6',
            'release'       : '10',
            'package-arch'  : 'i386',
            'ignored-name'  : 'zebra',
        }),
        BlacklistObsoletes().populate({
            'name'          : 'gated',
            'epoch'         : '',
            'version'       : '3.6',
            'release'       : '10',
            'package-arch'  : 'alpha',
            'ignored-name'  : 'zebra',
        }),
        BlacklistObsoletes().populate({
            'name'          : 'gated',
            'epoch'         : '',
            'version'       : '3.6',
            'release'       : '12',
            'package-arch'  : 'i386',
            'ignored-name'  : 'zebra',
        }),
    ]
    from backendOracle import OracleBackend
    ob = OracleBackend()
    importer = BlacklistObsoletesImport(batch, ob)
    importer.run()
