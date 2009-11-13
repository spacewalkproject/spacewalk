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
# Package import process
#

import sys
from importLib import GenericPackageImport, IncompletePackage, Package, \
    Import, InvalidArchError, InvalidChannelError, \
    IncompatibleArchError
from server import taskomatic
from common import CFG

class ChannelPackageSubscription(GenericPackageImport):
    def __init__(self, batch, backend, caller=None, strict=0):
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

    def preprocess(self):
        # Processes the package batch to a form more suitable for database
        # operations
        for package in self.batch:
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
            #package['checksum_id'] = self.checksums[package['checksum']]
            self._postprocessPackage(package)
            if not CFG.ENABLE_NVREA:
                # nvrea disabled, skip md5sum
                nevrao = (
                    package['name_id'],
                    package['evr_id'],
                    package['package_arch_id'],
                    package['org_id'])
            else:
                # As nvrea is enabled uniquify based on md5sum
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
        self.backend.lookupPackages(self.batch)
        try:
            affected_channels = self.backend.subscribeToChannels(self.batch, 
                strict=self._strict_subscription)
        except:
            self.backend.rollback()
            raise
        self.compute_affected_channels(affected_channels)
        self.backend.update_newest_package_cache(caller=self.caller, 
            affected_channels=self.affected_channel_packages)
        # Now that channel is updated, schedule the repo generation
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

    def addFromPackageBatch(self, batch):
        # Initialize the batch with information from the other batch
        for package in batch:
            if not isinstance(package, Package):
                raise TypeError("Expected a Package instance")
            if package.ignored:
                # Skip it
                continue
            # Build an IncompletePackage
            dict = {
                'name'      : package.name,
                'epoch'     : package.evr[0],
                'version'   : package.evr[1],
                'release'   : package.evr[2],
                'arch'      : package.arch,
                'org_id'    : package.org_id,
            }
            channels = package.channels or []
            l = []
            for channel in channels:
                l.append({'label' : channel})
            dict['channels'] = l
            p = IncompletePackage()
            p.populate(dict)
            self.batch.append(p)

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

#        # FIXME: needs to be fixed for sha256
#        checksum = ('md5',package['md5sum'])
#        package['checksum'] = checksum
#        if not self.checksums.has_key(checksum):
#            self.checksums[checksum] = None
    
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
        self._update_last_modified = update_last_modified
        self.capabilities = {}
        self.groups = {}
        self.sourceRPMs = {}

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
        package['copyright'] = package['license']

        # Creates all the data structures needed to insert capabilities
        for tag in ('provides', 'requires', 'conflicts', 'obsoletes'):
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
            nv = (f['name'], '')
            del f['name']
            f['capability'] = nv
            if not self.capabilities.has_key(nv):
                self.capabilities[nv] = None
            fchecksum = ('md5', f['md5'])
            f['checksum'] = fchecksum
            if not self.checksums.has_key(fchecksum):
                self.checksums[fchecksum] = None

        # Uniquify changelog entries
        changelogs = {}
        for changelog in package['changelog']:
            key = (changelog['name'], changelog['time'], changelog['text']) 
            changelogs[key] = changelog
        
        changelogs = changelogs.values()
        # Sort the changelogs by time (descending), then name (ascending)
        changelogs.sort(lambda a, b: cmp(b['time'], a['time']) or 
            cmp(a['name'], b['name']))
        package['changelog'] = changelogs

        if 'solaris_patch_set' in package:
            if package.arch.startswith("sparc"):
                self.package_arches['sparc-solaris-patch'] = None
            else:
                self.package_arches['i386-solaris-patch'] = None

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
        self.backend.update_newest_package_cache(caller=self.caller, 
            affected_channels=self.affected_channel_packages)
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

            # solaris specific stuff
            if 'solaris_package' in package or \
               'solaris_patch' in package or \
               'solaris_patch_set' in package:
                self.__postprocessSolarisPackage(package)

    def __postprocessPackage(self, package):
        """ populate the columns foo_id with id numbers from appropriate hashes """
        package['package_group'] = self.groups[package['package_group']]
        source_rpm = package['source_rpm']
        if source_rpm is not None:
            source_rpm = self.sourceRPMs[source_rpm]
        else:
            source_rpm = ''
        package['source_rpm_id'] = source_rpm
        package['checksum_id'] = self.checksums[package['checksum']]

        # Postprocess the dependency information
        for tag in ('provides', 'requires', 'conflicts', 'obsoletes', 'files'):
            for entry in package[tag]:
                nv = entry['capability']
                entry['capability_id'] = self.capabilities[nv]
        fileList = package['files']
        for f in fileList:
            f['checksum_id'] = self.checksums[f['checksum']]

    def __postprocessSolarisPackage(self, package):
        # set solaris patch packages for a solaris patch
        if 'solaris_patch_packages' in package:
            self.__postprocessSolarisPatchPackages(package)

        # set solaris patch set memebers for a solaris patch set
        if 'solaris_patch_set_members' in package:
            self.__postprocessSolarisPatchSetMembers(package)

    def __postprocessSolarisPatchPackages(self, package):

        evrs = {}
        names = {}
        archs = {}
        checksums = {}

        for pkgDict, pkgInfoObj in package['solaris_patch_packages']:
                
            evr = []
            for field in ('epoch', 'version', 'release'):
                evr.append(pkgDict[field])
            evr = tuple(evr)

            pkgDict['evr'] = evr

            evrs[evr] = None
            checksums[pkgDict['checksum']] = None
            names[pkgDict['name']] = None
            archs[pkgDict['arch']] = None

        self.backend.lookupEVRs(evrs)
        self.backend.lookupChecksums(checksums)
        self.backend.lookupPackageNames(names)
        self.backend.lookupPackageArches(archs)

        nevras = {}

        for pkgDict, pkgInfoObj in package['solaris_patch_packages']:

            nevra = []
            
            nevra.append(names[pkgDict['name']])
            nevra.append(evrs[pkgDict['evr']])
            nevra.append(archs[pkgDict['arch']])

            nevra = tuple(nevra)
            pkgDict['nevra'] = nevra
            nevras[nevra] = None

        self.backend.lookupPackageNEVRAs(nevras)

        infoObjs = []

        for pkgDict, pkgInfoObj in package['solaris_patch_packages']:
            pkgInfoObj['package_nevra_id'] = nevras[pkgDict['nevra']]
            infoObjs.append(pkgInfoObj)

        package['solaris_patch_packages'] = infoObjs

    def __postprocessSolarisPatchSetMembers(self, package):

        evrs = {}
        checksums = {}
        names = {}

        for patchDict, patchObj in package['solaris_patch_set_members']:

            evr = [None,]
            evr.append(patchDict['version'])
            evr.append('1')
            evr = tuple(evr)

            patchDict['evr'] = evr

            evrs[evr] = None
            checksums[patchDict['checksum']] = None
            names[patchDict['name']] = None

        self.backend.lookupEVRs(evrs)
        self.backend.lookupChecksums(self.checksums)
        self.backend.lookupPackageNames(names)

        nevras = {}
        
        for patchDict, patchInfoObj in package['solaris_patch_set_members']:

            nevra = []
            
            nevra.append(names[patchDict['name']])
            nevra.append(evrs[patchDict['evr']])

            if package.arch.startswith('sparc'):
                nevra.append(self.package_arches['sparc-solaris-patch'])
            else:
                nevra.append(self.package_arches['i386-solaris-patch'])

            nevra = tuple(nevra)
            patchDict['nevra'] = nevra
            nevras[nevra] = None

        self.backend.lookupPackagesByNEVRA(nevras)

        infoObjs = []

        for patchDict, patchInfoObj in package['solaris_patch_set_members']:
	    if not nevras[patchDict['nevra']]:
	        # if patch doesn't exist,skip from the set
                continue
            patchInfoObj['patch_id'] = nevras[patchDict['nevra']]
            infoObjs.append(patchInfoObj)

        package['solaris_patch_set_members'] = infoObjs

    def _comparePackages(self, package1, package2):
        if package1['md5sum'] == package2['md5sum']:
            return
        # XXX Handle this better
        raise Exception("Different packages in the same batch")

    def _cleanup_object(self, object):
        ChannelPackageSubscription._cleanup_object(self, object)
        if object.ignored:
            object.id = object.first_package.id

class SourcePackageImport(Import):
    def __init__(self, batch, backend, caller=None, update_last_modified=0):
        Import.__init__(self, batch, backend)
        self._update_last_modified = update_last_modified
        self.sourceRPMs = {}
        self.groups = {}

    def preprocess(self):
        for package in self.batch:
            self._processPackage(package)

    def fix(self):
        self.backend.lookupSourceRPMs(self.sourceRPMs)
        self.backend.lookupPackageGroups(self.groups)
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
        if package1['md5sum'] == package2['md5sum']:
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

    def _cleanup_object(self, object):
        Import._cleanup_object(self, object)
        if object.ignored:
            object.id = object.first_package.id


def packageImporter(batch, backend, source=0, caller=None):
    if source:
        return SourcePackageImport(batch, backend, caller=caller)
    return PackageImport(batch, backend, caller=caller)

