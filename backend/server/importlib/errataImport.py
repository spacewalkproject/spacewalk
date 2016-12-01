#
# Copyright (c) 2008--2016 Red Hat, Inc.
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
# Errata import process
#

from spacewalk.common.rhnException import rhnFault
from importLib import GenericPackageImport


class ErrataImport(GenericPackageImport):

    def __init__(self, batch, backend, queue_timeout=600):
        GenericPackageImport.__init__(self, batch, backend)
        # A composite key of the name, evr, arch plus org_id
        self.packages = {}
        self.ignoreMissing = 0
        self.cve = {}
        self.queue_timeout = queue_timeout
        self.file_types = {}

    def preprocess(self):
        # Processes the package batch to a form more suitable for database
        # operations

        # We use this to avoid having the same erratum pushed multiple times
        advisories = {}

        for errata in self.batch:
            advisory = errata['advisory_name']
            release = errata['advisory_rel']
            if advisory in advisories:
                if release < advisories[advisory]:
                    # Seen a newer one already
                    errata.ignored = 1
                    continue
            advisories[advisory] = release
            self._preprocessErratum(errata)
            self._preprocessErratumCVE(errata)
            self._preprocessErratumFiles(errata)
            self._preprocessErratumFileChannels(errata)

    def _preprocessErratum(self, errata):
        # Process packages
        for package in errata['packages']:
            self._processPackage(package)

        # Process channels
        channelHash = {}
        for channel in errata['channels']:
            channelName = channel['label']
            channelHash[channelName] = channel
            self.channels[channelName] = None
        # Replace the channel list with the unique one
        errata['channels'] = list(channelHash.values())

    def _preprocessErratumCVE(self, erratum):
        # Build the CVE dictionary
        # FIXME: this if decision is here to deal with missing cve data.
        #        fix later.
        if not erratum['cve']:
            erratum['cve'] = []
        for cve in erratum['cve']:
            self.cve[cve] = None

    def _preprocessErratumFiles(self, erratum):
        for f in (erratum['files'] or []):
            checksumTuple = (f['checksum_type'], f['checksum'])
            if checksumTuple not in self.checksums:
                self.checksums[checksumTuple] = None

            if f['file_type'] == 'RPM':
                package = f.get('pkgobj')
                if package:
                    self._processPackage(package)
                    nevrao = tuple(get_nevrao(package))
                    self.packages[nevrao] = package
            # Oval errata files need to be removed from the import for now.
            # This is to make sure non-oval capable satellites won't be importing
            # the oval data from an oval-enabled dump.
            elif f['file_type'] == 'OVAL':
                erratum['files'].remove(f)
            # elif f['file_type'] == 'SRPM':
            #    # XXX misa: do something here
            #    pass

    def _preprocessErratumFileChannels(self, erratum):
        for f in (erratum['files'] or []):
            for channel_name in (f.get('channel_list') or []):
                self.channels[channel_name] = None

    def fix(self):
        self.backend.lookupChannels(self.channels)
        self.backend.lookupErrataFileTypes(self.file_types)
        for erratum in self.batch:
            for ef in erratum['files']:
                eft = ef['file_type']
                if eft not in self.file_types:
                    raise Exception("Unknown file type %s" % eft)
                ef['type'] = self.file_types[eft]

        self._fixCVE()

        self.backend.lookupPackageNames(self.names)
        self.backend.lookupEVRs(self.evrs)
        self.backend.lookupChecksums(self.checksums)
        self.backend.lookupPackageArches(self.package_arches)

        for erratum in self.batch:
            if erratum.ignored:
                # Skip it
                continue
            self._fix_erratum_channels(erratum)
            self._fix_erratum_packages_lookup(erratum)
            self._fix_erratum_file_packages(erratum)
            # fix severity stuff
            self._fix_erratum_severity(erratum)
            # fix oval info to populate the relevant dbtables
            self._fix_erratum_oval_info(erratum)

        self.backend.lookupPackages(list(self.packages.values()), self.checksums, self.ignoreMissing)
        for erratum in self.batch:
            self._fix_erratum_packages(erratum)
            self._fix_erratum_file_channels(erratum)

    def _fixCVE(self):
        # Look up and insert the missing CVE's
        self.backend.processCVEs(self.cve)
        # Fix the CVE stuff
        for erratum in self.batch:
            if erratum.ignored:
                continue
            cves = []
            for cve in erratum['cve']:
                entry = {
                    'cve_id': self.cve[cve],
                }
                cves.append(entry)
            erratum['cve'] = cves

    def _fix_files(self):
        rpm_files = []
        srpm_files = []
        oval_files = []
        channel_files = []
        for erratum in self.batch:
            if erratum.ignored:
                continue
            for file in erratum['files']:
                file_type = file['file_type']
                file_id = file['id']
                package_id = file.get('package_id')
                if package_id is not None:
                    pkg = {
                        'errata_file_id': file_id,
                        'package_id': package_id,
                    }
                    if file_type == 'RPM':
                        rpm_files.append(pkg)
                    elif file_type == 'SRPM':
                        srpm_files.append(pkg)
                    elif file_type == 'OVAL':
                        pkg = {
                            'errata_id': file_id,
                            'filename': file['filename'],
                        }
                        oval_files.append(pkg)
                for channel_id in file['channels']:
                    channel_files.append({
                        'errata_file_id': file_id,
                        'channel_id': channel_id,
                    })
        self.backend._do_diff(rpm_files, 'rhnErrataFilePackage',
                              ['errata_file_id', 'package_id'], [])
        self.backend._do_diff(srpm_files, 'rhnErrataFilePackageSource',
                              ['errata_file_id', 'package_id'], [])
        self.backend._do_diff(channel_files, 'rhnErrataFileChannel',
                              ['errata_file_id', 'channel_id'], [])
        self.backend._do_diff(oval_files, 'rhnErrataFile',
                              ['errata_id', 'filename'], [])

    def submit(self):
        try:
            dml = self.backend.processErrata(self.batch)
            self.backend.update_channels_affected_by_errata(dml)
            self._fix_files()
            self.backend.queue_errata(self.batch, self.queue_timeout)
        except:
            self.backend.rollback()
            raise
        self.backend.commit()

    def _fix_erratum_channels(self, erratum):
        # Fix the erratum's channels
        channels = {}
        for ch in erratum['channels']:
            label = ch['label']
            channel = self.channels[label]
            if not channel:
                # Invalid channel
                if self.ignoreMissing:
                    # Ignore missing channel
                    continue
                # XXX Raising an exception here; it may be too harsh though
                erratum.ignored = 1
                raise Exception("XXX Invalid channel %s" % label)

            channels[channel['id']] = None

        erratum['channels'] = [{'channel_id': x} for x in channels.keys()]

    def _fix_erratum_packages_lookup(self, erratum):
        # To make the packages unique
        packageHash = {}
        for package in erratum['packages']:
            if package.ignored:
                # Skip it
                continue

            self._postprocessPackageNEVRA(package)

            # Check the uniqueness
            nevrao = tuple(get_nevrao(package))

            if nevrao in packageHash:
                # Been there already
                package.ignored = 1
                continue

            package['nevrao'] = nevrao

            # And put this package both in the local and in the global hash
            packageHash[nevrao] = package
            self.packages[nevrao] = package

        erratum['packages'] = packageHash

    def _fix_erratum_file_packages(self, erratum):
        for ef in erratum['files']:
            ef['checksum_id'] = self.checksums[(ef['checksum_type'], ef['checksum'])]
            if ef['file_type'] == 'RPM':
                package = ef.get('pkgobj')
                if not package:
                    continue
                self._postprocessPackageNEVRA(package)
            # XXX fix source rpms

    def _fix_erratum_packages(self, erratum):
        pkgs = []
        # This is a workaround; It would be much straightforward to use
        # 'package in erratum['packages'].values()' here. But for (to me) unknown
        # reason it sometimes has package.id == None which makes whole import fail.
        # And self.packages[nevrao].id contains always right value.
        for nevrao in erratum['packages'].keys():
            package = self.packages[nevrao]
            if package.ignored:
                # Ignore this package
                continue
            pkgs.append({'package_id': package.id})

        erratum['packages'] = pkgs

        for ef in (erratum['files'] or []):
            if ef['file_type'] == 'RPM':
                package = ef.get('pkgobj')
                if package:
                    ef['package_id'] = package.id

    def _fix_erratum_file_channels(self, erratum):
        for f in (erratum['files'] or []):
            channels = []
            for c in (f.get('channel_list') or []):
                if not self.channels[c]:
                    # Unsupported channel
                    # XXX misa: should we gripe loudly?
                    continue
                channels.append(self.channels[c]['id'])
            f['channels'] = channels

    def _fix_erratum_severity(self, erratum):
        """sets the severity-id to insert into rhnErrata
        """
        # Re-check for severity, it could be a RHBA or RHEA
        # If RHBA/RHEA severity is irrelevant and posibly
        # not included or it could not be hosted
        if 'security_impact' in erratum:
            erratum['severity_id'] = self.backend.lookupErrataSeverityId(erratum)

    def _fix_erratum_oval_info(self, erratum):
        """
        manipulate oval package info to populate in the
        appropriate fields in the db tables.

        """
        import os

        if 'oval_info' not in erratum:
            return

        for oval_file in erratum['oval_info']:
            if has_suffix(oval_file['filename'], '.xml'):
                eft = oval_file['file_type'] = 'OVAL'
                if eft not in self.file_types:
                    raise Exception("Unknown file type %s" % eft)
                oval_file['type'] = self.file_types[eft]

            # XXX: stubs incase we need to associate them to channels/packages
            oval_file['channel_list'] = []
            oval_file['channels'] = []
            oval_file['package_id'] = None

            if not os.path.isfile(oval_file['filename']):
                # Don't bother to copy the package
                raise rhnFault(47,
                               "Oval file %s not found on the server. " % oval_file['filename'],
                               explain=0)

            # add the oval info into the files field to get
            # populated into db
            erratum['files'].append(oval_file)


def get_nevrao(package):
    return list(map(lambda x, d=package: d[x],
               ['name', 'epoch', 'version', 'release', 'arch', 'org_id', 'checksum_type', 'checksum']))


def has_suffix(s, suffix):
    return s[-len(suffix):] == suffix
