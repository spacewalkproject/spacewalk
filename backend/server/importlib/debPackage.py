#
# Copyright (c) 2010--2016 Red Hat, Inc.
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
import time
from importLib import Channel
from backendLib import gmtime, localtime
from spacewalk.common.usix import IntType, UnicodeType
from spacewalk.common.stringutils import to_string


class debBinaryPackage(headerSource.rpmBinaryPackage):

    def __init__(self, header, size, checksum_type, checksum, path=None, org_id=None,
                 channels=[]):

        headerSource.rpmBinaryPackage.__init__(self)

        self.tagMap = headerSource.rpmBinaryPackage.tagMap.copy()
        self.tagMap.update({
            'multi_arch': 'Multi-Arch',
        })

        # Remove already-mapped tags
        self._already_mapped = [
            'rpm_version', 'payload_size', 'payload_format',
            'package_group', 'build_time', 'build_host'
        ]

        for t in self._already_mapped:
            if t in self.tagMap:
                del self.tagMap[t]

        # XXX is seems to me that this is the place that 'source_rpm' is getting
        # set
        for f in self.keys():
            field = f
            if f in self.tagMap:
                field = self.tagMap[f]
                if not field:
                    # Unsupported
                    continue

            # get the db field value from the header
            val = header[field]
            if f == 'build_time':
                if val is not None and isinstance(val, IntType):
                    # A UNIX timestamp
                    val = localtime(val)
            elif val:
                # Convert to strings
                if isinstance(val, UnicodeType):
                    val = to_string(val)
                else:
                    val = str(val)
            elif val == []:
                val = None
            self[f] = val

        self['repo_type'] = 'deb'
        self['package_size'] = size
        self['checksum_type'] = checksum_type
        self['checksum'] = checksum
        self['path'] = path
        self['org_id'] = org_id
        self['header_start'] = None
        self['header_end'] = None
        self['last_modified'] = localtime(time.time())
        if self['sigmd5']:
            self['sigchecksum_type'] = 'md5'
            self['sigchecksum'] = self['sigmd5']
        del(self['sigmd5'])

        # Fix some of the information up
        vendor = self['vendor']
        if vendor is None:
            self['vendor'] = 'Debian'
        payloadFormat = self['payload_format']
        if payloadFormat is None:
            self['payload_format'] = 'ar'
        if self['payload_size'] is None:
            self['payload_size'] = 0

        # Populate file information
        self._populateFiles(header)
        # Populate dependency information
        self._populateDependencyInformation(header)
        # Populate changelogs
        self._populateChangeLog(header)
        # Channels
        self._populateChannels(channels)

        self['source_rpm'] = None

        group = self.get('package_group', '')
        if group == '' or group is None:
            self['package_group'] = 'NoGroup'

    def _populateFiles(self, header):
        files = []
        # for f in header.get('files', []):
        #    fc = headerSource.rpmFile()
        #    fc.populate(f)
        #    files.append(fc)
        self['files'] = files

    def _populateDependencyInformation(self, header):
        mapping = {
            'provides': headerSource.rpmProvides,
            'requires': headerSource.rpmRequires,
            'conflicts': headerSource.rpmConflicts,
            'obsoletes': headerSource.rpmObsoletes,
            'suggests': headerSource.rpmSuggests,
            'recommends': headerSource.rpmRecommends,
            'breaks': headerSource.rpmBreaks,
            'predepends': headerSource.rpmPredepends,
        }
        for k, dclass in mapping.items():
            l = []
            values = header[k]
            if values is not None:
                val = values.split(', ')  # split packages
                i = 0
                for v in val:
                    relation = 0
                    version = ''
                    if '|' in v:
                        # TODO: store alternative-package-names semantically someday
                        name = v + '_' + str(i)
                    else:
                        nv = v.split('(')
                        name = nv[0] + '_' + str(i)
                        if (len(nv) > 1):
                            version = nv[1].rstrip(')')
                            if version:
                                while version.startswith(("<", ">", "=")):
                                    if version.startswith("<"):
                                        relation |= 2
                                    if version.startswith(">"):
                                        relation |= 4
                                    if version.startswith("="):
                                        relation |= 8
                                    version = version[1:]
                    hash = {'name': name, 'version': version, 'flags': relation}
                    finst = dclass()
                    finst.populate(hash)
                    l.append(finst)
                    i += 1
            self[k] = l

    def _populateChangeLog(self, header):
        l = []
        # for cinfo in header.get('changelog', []):
        #    cinst = headerSource.rpmChangeLog()
        #    cinst.populate(cinfo)
        #    l.append(cinst)
        self['changelog'] = l

    def _populateChannels(self, channels):
        l = []
        for channel in channels:
            dict = {'label': channel}
            obj = Channel()
            obj.populate(dict)
            l.append(obj)
        self['channels'] = l
