#
# Copyright (c) 2008--2012 Red Hat, Inc.
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

import sys
import os.path
from importLib import GenericPackageImport, IncompletePackage, \
    Import, InvalidArchError, InvalidChannelError, \
    IncompatibleArchError
from mpmSource import mpmBinaryPackage
from spacewalk.common import rhn_pkg
from spacewalk.common.rhnConfig import CFG
from spacewalk.server import taskomatic
from spacewalk.server.rhnServer import server_packages

class ChannelPackageSubscription(GenericPackageImport):
    def __init__(self, batch, backend, caller=None, strict=0, repogen=True):
        # If strict, the set of packages that was passed in will be the only
        # one in the channels - everything else will be unlinked
        GenericPackageImport.__init__(self, batch, backend)
        self.affected_channels = []
        # A hash keyed on the channel id, and with tuples
        # (added_packages, removed_packages) as values (packages are package
        # ids)
        self.affected_channel_packages = {}
        if not caller:
            self.caller = "backend.(unknown)"
        else:
            self.caller = caller
        self._strict_subscription = strict
        self.repogen = repogen

    def preprocess(self):
        # Processes the package batch to a form more suitable for database
        # operations
        for package in self.batch:
            # if package object doesn't have multiple checksums (like satellite-sync objects)
            #   then let's fake it
            if not package.has_key('checksums'):
                package['checksums'] = {package['checksum_type']: package['checksum']}
            if not isinstance(package, IncompletePackage):
                raise TypeError("Expected an IncompletePackage instance, "
                    "got %s" % package.__class__.__name__)
            self._processPackage(package)

    def fix(self):
        # Look up arches and channels
        self.backend.lookupPackageArches(self.package_arches)
        self.backend.lookupChannels(self.channels)
        # Initialize self.channel_package_arch_compat
        self.channel_package_arch_compat = {}
        for channel, channel_row in self.channels.items():
            if not channel_row:
                # Unsupported channel
                continue
            self.channel_package_arch_compat[channel_row['channel_arch_id']] = None
        self.backend.lookupChannelPackageArchCompat(self.channel_package_arch_compat)
        self.backend.lookupPackageNames(self.names)
        self.backend.lookupEVRs(self.evrs)
        self.backend.lookupChecksums(self.checksums)

        # Fix the package information up, and uniquify the packages too
        uniqdict = {}
        for package in self.batch:
            if package.ignored:
                continue
            self._postprocessPackageNEVRA(package)
            if not CFG.ENABLE_NVREA:
                # nvrea disabled, skip checksum
                nevrao = (
                    package['name_id'],
                    package['evr_id'],
                    package['package_arch_id'],
                    package['org_id'])
            else:
                # As nvrea is enabled uniquify based on checksum
                nevrao = (
                    package['name_id'],
                    package['evr_id'],
                    package['package_arch_id'],
                    package['org_id'],
                    package['checksum_id'])

            if not uniqdict.has_key(nevrao):
                # Uniquify the channel names
                package['channels'] = {}
                # Initialize the channels
                # This is a handy way of checking arch compatibility for this
                # package with its channels
                self.__copyChannels(package, package)
                uniqdict[nevrao] = package
            else:
                # Package is found twice in the same batch
                # Are the packages the same?
                self._comparePackages(package, uniqdict[nevrao])
                # Invalidate it
                package.ignored = 1
                firstpackage = uniqdict[nevrao]
                # Copy any new channels
                self.__copyChannels(package, firstpackage)
                # Knowing the id of the referenced package
                package.first_package = firstpackage

    def _comparePackages(self, package1, package2):
        # XXX This should probably do a deep compare of the two packages
        pass

    def submit(self):
        self.backend.lookupPackages(self.batch, self.checksums)
        try:
            affected_channels = self.backend.subscribeToChannels(self.batch,
                strict=self._strict_subscription)
        except:
            self.backend.rollback()
            raise
        self.compute_affected_channels(affected_channels)

        if len(self.batch) < 10:
            # update small batch per package
            name_ids = [pkg['name_id'] for pkg in self.batch]
        else:
            # update bigger batch at once
            name_ids = []
        self.backend.update_newest_package_cache(caller=self.caller,
            affected_channels=self.affected_channel_packages, name_ids=name_ids)
        # Now that channel is updated, schedule the repo generation
        if self.repogen:
            taskomatic.add_to_repodata_queue_for_channel_package_subscription(
                self.affected_channels, self.batch, self.caller)
        self.backend.commit()

    def compute_affected_channels(self, affected_channels):
        # Fill the list of affected channels
        self.affected_channel_packages.clear()
        self.affected_channel_packages.update(affected_channels)
        for channel_label, channel_row in self.channels.items():
            channel_id = channel_row['id']
            if affected_channels.has_key(channel_id):
                affected_channels[channel_id] = channel_label
        self.affected_channels = affected_channels.values()

    def _processPackage(self, package):
        GenericPackageImport._processPackage(self, package)

        # Process channels
        channels = []
        channelHash = {}
        for channel in package['channels']:
            channelName = channel['label']
            if not channelHash.has_key(channelName):
                channels.append(channelName)
                channelHash[channelName] = None
            self.channels[channelName] = None
        # Replace the channel list with the uniquified list
        package.channels = channels

    # Copies the channels from one package to the other
    def __copyChannels(self, sourcePackage, destPackage):
        dpHash = destPackage['channels']
        for schannelName in sourcePackage.channels:
            # Check if the package is compatible with the channel
            channel = self.channels[schannelName]
            if not channel:
                # Unknown channel
                sourcePackage.ignored = 1
                raise InvalidChannelError(channel,
                    "Unsupported channel %s" % schannelName)
            # Check channel-package compatibility
            charch = channel['channel_arch_id']
            archCompat = self.channel_package_arch_compat[charch]
            if not archCompat:
                # Invalid architecture
                sourcePackage.ignored = 1
                raise InvalidArchError(charch,
                    "Invalid channel architecture %s" % charch)

            # Now check if the source package's arch is compatible with the
            # current channel
            if not archCompat.has_key(sourcePackage['package_arch_id']):
                sourcePackage.ignored = 1
                raise IncompatibleArchError(sourcePackage.arch, charch,
                    "Package arch %s incompatible with channel %s" %
                        (sourcePackage.arch, schannelName))

            dpHash[channel['id']] = schannelName

        destPackage.channels = dpHash.values()


class PackageImport(ChannelPackageSubscription):
    def __init__(self, batch, backend, caller=None, update_last_modified=0):
        ChannelPackageSubscription.__init__(self, batch, backend,
            caller=caller)
        self.ignoreUploaded = 1
        self._update_last_modified = update_last_modified
        self.capabilities = {}
        self.groups = {}
        self.sourceRPMs = {}
        self.changelog_data = {}

    def _processPackage(self, package):
        ChannelPackageSubscription._processPackage(self, package)

        # Process package groups
        group = package['package_group']
        if not self.groups.has_key(group):
            self.groups[group] = None
        sourceRPM = package['source_rpm']
        if sourceRPM is not None and not self.sourceRPMs.has_key(sourceRPM):
            self.sourceRPMs[sourceRPM] = None
        # Change copyright to license
        # XXX
        package['copyright'] = self._fix_encoding(package['license'])

        for tag in ('recommends', 'suggests', 'supplements', 'enhances', 'breaks', 'predepends'):
            if not package.has_key(tag) or type(package[tag]) != type([]):
                # older spacewalk server do not export weak deps.
                # lets create an empty list
                package[tag] = []

        # Creates all the data structures needed to insert capabilities
        for tag in ('provides', 'requires', 'conflicts', 'obsoletes', 'recommends', 'suggests', 'supplements', 'enhances', 'breaks', 'predepends'):
            depList = package[tag]
            if type(depList) != type([]):
                sys.stderr.write("!!! packageImport.PackageImport._processPackage: "
                                 "erronous depList for '%s', converting to []\n"%tag)
                depList = []
            for dep in depList:
                nv = []
                for f in ('name', 'version'):
                    nv.append(dep[f])
                    del dep[f]
                nv = tuple(nv)
                dep['capability'] = nv
                if not self.capabilities.has_key(nv):
                    self.capabilities[nv] = None
        # Process files too
        fileList = package['files']
        for f in fileList:
            filename = self._fix_encoding(f['name'])
            nv = (filename, '')
            del f['name']
            f['capability'] = nv
            if not self.capabilities.has_key(nv):
                self.capabilities[nv] = None
            fchecksumTuple = (f['checksum_type'], f['checksum'])
            if not self.checksums.has_key(fchecksumTuple):
                self.checksums[fchecksumTuple] = None

        # Uniquify changelog entries
        unique_package_changelog_hash = {}
        unique_package_changelog = []
        for changelog in package['changelog']:
            key = (changelog['name'], changelog['time'], changelog['text'])
            if not unique_package_changelog_hash.has_key(key):
                self.changelog_data[key] = None
                unique_package_changelog.append(changelog)
                unique_package_changelog_hash[key] = 1
        package['changelog'] = unique_package_changelog

        # fix encoding issues in package summary and description
        package['description'] = self._fix_encoding(package['description'])
        package['summary'] = self._fix_encoding(package['summary'])

    def fix(self):
        # If capabilities are available, process them
        if self.capabilities:
            try:
                self.backend.processCapabilities(self.capabilities)
            except:
                # Oops
                self.backend.rollback()
                raise
            # Since this is the bulk of the work, commit
            self.backend.commit()

        self.backend.processChangeLog(self.changelog_data)

        ChannelPackageSubscription.fix(self)

        self.backend.lookupSourceRPMs(self.sourceRPMs)
        self.backend.lookupPackageGroups(self.groups)
        # Postprocess the gathered information
        self.__postprocess()

    def submit(self):
        upload_force = self.uploadForce
        if not upload_force and self._update_last_modified:
            # # Force it just a little bit - kind of hacky
            upload_force = 0.5
        try:
            self.backend.processPackages(self.batch,
                uploadForce=upload_force,
                forceVerify=self.forceVerify,
                ignoreUploaded=self.ignoreUploaded,
                transactional=self.transactional)
            self._import_signatures()
        except:
            # Oops
            self.backend.rollback()
            raise
        self.backend.commit()
        if not self._update_last_modified:
            # Go though the list of objects and clear out the ones that have a
            # force of 0.5
            for p in self.batch:
                if p.diff and p.diff.level == 0.5:
                    # Ignore this difference completely
                    p.diff = None
                    # Leave p.diff_result in place

    def subscribeToChannels(self):
        affected_channels = self.backend.subscribeToChannels(self.batch)
        # Fill the list of affected channels
        self.compute_affected_channels(affected_channels)

        name_ids = [pkg['name_id'] for pkg in self.batch]
        self.backend.update_newest_package_cache(caller=self.caller,
            affected_channels=self.affected_channel_packages, name_ids=name_ids)
        taskomatic.add_to_repodata_queue_for_channel_package_subscription(
                self.affected_channels, self.batch, self.caller)
        self.backend.commit()

    def __postprocess(self):
        # Gather the IDs we've found

        for package in self.batch:
            if package.ignored:
                # Skip it
                continue
            # Only deal with packages
            self.__postprocessPackage(package)

    def __postprocessPackage(self, package):
        """ populate the columns foo_id with id numbers from appropriate hashes """
        package['package_group'] = self.groups[package['package_group']]
        source_rpm = package['source_rpm']
        if source_rpm is not None:
            source_rpm = self.sourceRPMs[source_rpm]
        else:
            source_rpm = ''
        package['source_rpm_id'] = source_rpm
        package['checksum_id'] = self.checksums[(package['checksum_type'], package['checksum'])]

        # Postprocess the dependency information
        for tag in ('provides', 'requires', 'conflicts', 'obsoletes', 'files', 'recommends', 'suggests', 'supplements', 'enhances', 'breaks', 'predepends'):
            for entry in package[tag]:
                nv = entry['capability']
                entry['capability_id'] = self.capabilities[nv]
        for c in package['changelog']:
            c['changelog_data_id'] = self.changelog_data[(c['name'], c['time'], c['text'])]
        fileList = package['files']
        for f in fileList:
            f['checksum_id'] = self.checksums[(f['checksum_type'], f['checksum'])]

    def _comparePackages(self, package1, package2):
        if (package1['checksum_type'] == package2['checksum_type']
            and package1['checksum'] == package2['checksum']):
            return
        # XXX Handle this better
        raise Exception("Different packages in the same batch")

    def _cleanup_object(self, object):
        ChannelPackageSubscription._cleanup_object(self, object)
        if object.ignored:
            object.id = object.first_package.id

    def _import_signatures(self):
       for package in self.batch:
           # skip missing files and mpm packages
           if package['path'] and not isinstance(package, mpmBinaryPackage):
               full_path = os.path.join(CFG.MOUNT_POINT, package['path'])
               if os.path.exists(full_path):
                   header = rhn_pkg.get_package_header(filename=full_path)
                   server_packages.processPackageKeyAssociations(header,
                                   package['checksum_type'], package['checksum'])

    def _fix_encoding(self, text):
        if text is None:
            return None
        try:
            return text.decode('utf8')
        except UnicodeDecodeError:
            return text.decode('iso8859-1')


class SourcePackageImport(Import):
    def __init__(self, batch, backend, caller=None, update_last_modified=0):
        Import.__init__(self, batch, backend)
        self._update_last_modified = update_last_modified
        self.ignoreUploaded = 1
        self.sourceRPMs = {}
        self.groups = {}
        self.checksums = {}

    def preprocess(self):
        for package in self.batch:
            self._processPackage(package)

    def fix(self):
        self.backend.lookupSourceRPMs(self.sourceRPMs)
        self.backend.lookupPackageGroups(self.groups)
        self.backend.lookupChecksums(self.checksums)
        self.__postprocess()
        # Uniquify the packages
        uniqdict = {}
        for package in self.batch:
            # Unique key
            key = (package['org_id'], package['source_rpm_id'])
            if not uniqdict.has_key(key):
                uniqdict[key] = package
                continue
            else:
                self._comparePackages(package, uniqdict[key])
                # And invalidate it
                package.ignored = 1
                package.first_package = uniqdict[key]

    def submit(self):
        upload_force = self.uploadForce
        if not upload_force and self._update_last_modified:
            # # Force it just a little bit - kind of hacky
            upload_force = 0.5
        try:
            self.backend.processSourcePackages(self.batch,
                uploadForce=upload_force,
                forceVerify=self.forceVerify,
                ignoreUploaded=self.ignoreUploaded,
                transactional=self.transactional)
        except:
            # Oops
            self.backend.rollback()
            raise
        self.backend.commit()
        if not self._update_last_modified:
            # Go though the list of objects and clear out the ones that have a
            # force of 0.5
            for p in self.batch:
                if p.diff and p.diff.level == 0.5:
                    # Ignore this difference completely
                    p.diff = None
                    # Leave p.diff_result in place


    def _comparePackages(self, package1, package2):
        if (package1['checksum_type'] == package2['checksum_type']
            and package1['checksum'] == package2['checksum']):
            return
        # XXX Handle this better
        raise Exception("Different packages in the same batch")

    def _processPackage(self, package):
        Import._processPackage(self, package)
        # Fix the arch
        package.arch = 'src'
        package.source_rpm = package['source_rpm']
        sourceRPM = package['source_rpm']
        if not sourceRPM:
            # Should not happen
            raise Exception("Source RPM %s does not exist")
        self.sourceRPMs[sourceRPM] = None
        self.groups[package['package_group']] = None

        checksumTuple = (package['checksum_type'], package['checksum'])
        if checksumTuple not in self.checksums:
            self.checksums[checksumTuple] = None

        sigchecksumTuple = (package['sigchecksum_type'], package['sigchecksum'])
        if sigchecksumTuple not in self.checksums:
            self.checksums[sigchecksumTuple] = None

    def __postprocess(self):
        # Gather the IDs we've found

        for package in self.batch:
            if package.ignored:
                # Skip it
                continue
            # Only deal with packages
            self.__postprocessPackage(package)

    def __postprocessPackage(self, package):
        # Set the ids
        package['package_group'] = self.groups[package['package_group']]
        package['source_rpm_id'] = self.sourceRPMs[package['source_rpm']]
        package['checksum_id'] = self.checksums[(package['checksum_type'],
                                                 package['checksum'])]
        package['sigchecksum_id'] = self.checksums[(package['sigchecksum_type'],
                                                    package['sigchecksum'])]

    def _cleanup_object(self, object):
        Import._cleanup_object(self, object)
        if object.ignored:
            object.id = object.first_package.id


def packageImporter(batch, backend, source=0, caller=None):
    if source:
        return SourcePackageImport(batch, backend, caller=caller)
    return PackageImport(batch, backend, caller=caller)

