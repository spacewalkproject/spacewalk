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
# Converts headers to the intermediate format
#

import headerSource
import debPackage


class mpmBinaryPackage(headerSource.rpmBinaryPackage):

    tagMap = headerSource.rpmBinaryPackage.tagMap.copy()

    # Remove already-mapped tags
    _already_mapped = [
        'rpm_version', 'payload_size', 'payload_format',
        'package_group', 'build_time', 'build_host'
    ]
    for t in _already_mapped:
        if tagMap.has_key(t):
            del tagMap[t]

    def populate(self, header, size, checksum_type, checksum, path=None, org_id=None,
            channels=[]):

        # call to base class method
        headerSource.rpmBinaryPackage.populate(self, header, size, checksum_type, checksum, path,
            org_id, channels)

        srpm = self.get('source_rpm', '')
        if srpm == '':
            self['source_rpm'] = None

        group = self.get('package_group', '')
        if group == '':
            self['package_group'] = 'NoGroup'

        return self

    def _populateFiles(self, header):
        files = []
        for f in header.get('files', []):
            fc = headerSource.rpmFile()
            fc.populate(f)
            files.append(fc)
        self['files'] = files

    def _populateDependencyInformation(self, header):
        mapping = {
            'provides'  : headerSource.rpmProvides,
            'requires'  : headerSource.rpmRequires,
            'conflicts' : headerSource.rpmConflicts,
            'obsoletes' : headerSource.rpmObsoletes,
            'recommends': headerSource.rpmRecommends,
            'supplements': headerSource.rpmSupplements,
            'enhances'  : headerSource.rpmEnhances,
            'suggests'  : headerSource.rpmSuggests,
        }

        for k, dclass in mapping.items():
            unique_deps = []
            l = []
            for dinfo in header.get(k, []):
                hash = dinfo
                if not len(hash['name']):
                    continue
                dep_nv = (hash['name'], hash['version'], hash['flags'])
                if dep_nv not in unique_deps:
                    unique_deps.append(dep_nv)
                    finst = dclass()
                    finst.populate(dinfo)
                    l.append(finst)
                else:
                    continue
            self[k] = l

    def _populateChangeLog(self, header):
        l = []
        for cinfo in header.get('changelog', []):
            cinst = headerSource.rpmChangeLog()
            cinst.populate(cinfo)
            l.append(cinst)
        self['changelog'] = l

# top-level package object creation --------------------------------------

def create_package(header, size, checksum_type, checksum, relpath, org_id, header_start=None,
    header_end=None, channels=[]):
    if header.packaging == 'rpm':
        return headerSource.createPackage(header, size=size,
            checksum_type=checksum_type, checksum=checksum,
            relpath=relpath, org_id=org_id, header_start=header_start,
            header_end=header_end, channels=channels)
    if header.packaging == 'deb':
        return debPackage.debBinaryPackage(header, size=size, checksum_type=checksum_type, checksum=checksum, path=relpath,
            org_id=org_id, channels=channels)
    if header.is_source:
        raise NotImplementedError()
    p = mpmBinaryPackage()
    p.populate(header, size=size, checksum_type=checksum_type, checksum=checksum, path=relpath,
        org_id=org_id, channels=channels)
    return p
