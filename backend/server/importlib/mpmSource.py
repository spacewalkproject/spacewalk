#!/usr/bin/python
#
# Copyright (c) 2008--2010 Red Hat, Inc.
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
from importLib import SolarisPatchInfo, \
                      SolarisPatchPackagesInfo, SolarisPatchSetInfo, \
                      SolarisPatchSetMember, SolarisPackageInfo

class mpmSolarisPatchInfo(SolarisPatchInfo):
    tagMap = {
        # DB field -> header field
        'package_id'    : None,
        'solaris_release':'solaris_rel',
        'sunos_release' : 'sunos_rel',
        'patch_type'    : 'patch_type',
        'readme'        : 'readme',
        'patchinfo'     : 'summary',
    }


class mpmSolarisPatchPackagesInfo(SolarisPatchPackagesInfo):
    tagMap = {
        'patch_id'      : None,
        'package_nevra_id': None,
    }


class mpmSolarisPatchSetInfo(SolarisPatchSetInfo):
    tagMap = {
        'package_id'    : None,
        'readme'        : 'readme',
        'set_date'      : 'date',
    }


class mpmSolarisPatchSetMember(SolarisPatchSetMember):
    tagMap = {
        'patch_id'      : None,
        'patch_set_id'  : None,
        'patch_order'   : None,
    }


class mpmSolarisPackageInfo(SolarisPackageInfo):
    tagMap = {
        'package_id'    : None,
        'category'      : 'package_group',
        'pkginfo'       : 'pkginfo',
        'pkgmap'        : 'pkgmap',
        'intonly'       : 'intonly',
    }


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
        
        # Solaris specific populations
        if header.get('package_type', "") == "solaris":
            group = header.get('package_group', "")
            self['header_start'] = self['header_end'] = 0

            if group == 'Patches':
                self._populate_solaris_patch_info(header)

            elif group == 'Patch Clusters':
                self._populate_solaris_patch_set_info(header)

            else: # it's a solaris package
                self._populate_solaris_package_info(header)

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

    def _populate_solaris_package_info(self, header):
        mapping = {
            'solaris_package': mpmSolarisPackageInfo,
        }
        for k, v in mapping.items():
            self._populate_solaris_tag(k, v, header)

    def _populate_solaris_patch_info(self, header):
        mapping = {
            'solaris_patch' : mpmSolarisPatchInfo,
        }
        for k, v in mapping.items():
            self._populate_solaris_tag(k, v, header)

        list_ = []

        for pkg in header.get('packages', []):
            # mpmSolarisPatchPackagesInfo contains only info from the db, so 
            # I'll store tuples so that the info from the db can be retrieved
            list_.append((pkg, mpmSolarisPatchPackagesInfo()))

        self['solaris_patch_packages'] = list_

    def _populate_solaris_patch_set_info(self, header):
        mapping = {
            'solaris_patch_set' : mpmSolarisPatchSetInfo,
        }
        for k, v in mapping.items():
            self._populate_solaris_tag(k, v, header)
            
        list_ = []

        patch_list = header.get('patches', [])
        for patch in patch_list:
            member = mpmSolarisPatchSetMember()
            member['patch_order'] = patch['patch_order']
            list_.append((patch, member))
            
        self['solaris_patch_set_members'] = list_


    def _populate_solaris_tag(self, tag, Class, header):

        list_ = self.get(tag, [])

        assert type(list_) == type([])

        obj = Class()

        dict = {}
        for k, v in obj.tagMap.items():
            dict[k] = header.get(v, None)

        obj.populate(dict)
        list_.append(obj)

        self[tag] = list_

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
