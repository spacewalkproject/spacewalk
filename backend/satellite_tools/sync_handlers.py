#!/usr/bin/python
#
#
# Copyright (c) 2008--2009 Red Hat, Inc.
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


import types
import string

from server import rhnSQL
from server.importlib import channelImport, packageImport, errataImport, \
    kickstartImport, importLib
import diskImportLib
import xmlSource
import syncCache
import syncLib

DEFAULT_ORG = 1

class NoFreeEntitlementsError(Exception):
    "No free entitlements available to activate this satellite"

# Singleton-like
class BaseCollection:
    _shared_state = {}
    def __init__(self):
        self.__dict__ = self._shared_state
        if not self._shared_state.keys():
            self._items = []
            self._cache = None
            self._items_hash = {}
            self._init_fields()
            self._init_cache()

    def add_item(self, item):
        item_id = self._get_item_id(item)
        timestamp = self._get_item_timestamp(item)
        self._cache.cache_set(item_id, item, timestamp=timestamp)
        return self

    def get_item_timestamp(self, item_id):
        "Returns this item's timestamp"
        if not self._items_hash.has_key(item_id):
            raise KeyError("Item %s not found in collection" % item_id)
        return self._items_hash[item_id]

    def get_item(self, item_id, timestamp):
        "Retrieve an item from the collection"
        return self._cache.cache_get(item_id, timestamp=timestamp)

    def has_item(self, item_id, timestamp):
        """Return true if the item exists in the collection (with the
        specified timestamp"""
        return self._cache.cache_has_key(item_id, timestamp=timestamp)

    def _init_fields(self):
        return self

    def _init_cache(self):
        return self

    def _get_item_id(self, item):
        "Get the item ID out of an item. Override in subclasses"
        raise NotImplementedError

    def _get_item_timestamp(self, item):
        "Get the item timestamp out of an item. Override in subclasses"
        raise NotImplementedError

    def reset(self):
        """Reset the collection"""
        self._shared_state.clear()
        self.__init__()

# Singleton-like
class ChannelCollection:
    _shared_state = {}
    def __init__(self):
        self.__dict__ = self._shared_state
        if not self._shared_state.keys():
            self._channels = []
            self._parent_channels = {}
            self._channels_hash = {}
            self._cache = syncCache.ChannelCache()

    def add_channel(self, channel_object):
        """Stores a channel in the collection"""
        channel_label = channel_object['label']
        channel_last_modified = channel_object['last_modified']
        last_modified = _to_timestamp(channel_last_modified)
        self._cache.cache_set(channel_label, channel_object,
            timestamp=last_modified)
        t = (channel_label, last_modified)
        self._channels.append(t)
        channel_parent = channel_object.get('parent_channel')
        if channel_parent is not None:
            # Add this channel to the parent's list
            l = self._get_list_from_dict(self._parent_channels, channel_parent)
            l.append(t)
        else:
            # Create an empty list
            self._get_list_from_dict(self._parent_channels, channel_label)
        self._channels_hash[channel_label] = last_modified
        return self

    def _get_list_from_dict(self, diction, key):
        # Returns the dictionary's key if present (assumed to be a list), or
        # sets the value to an empty list and returns it
        if diction.has_key(key):
            l = diction[key]
        else:
            l = diction[key] = []
        return l

    def get_channel_labels(self):
        """Return the channel labels from this collection"""
        return map(lambda x: x[0], self._channels)

    def get_channels(self):
        """Return a list of (channel label, channel timestamp) from this
        collection"""
        return self._channels[:]

    def get_channel(self, channel_label, timestamp):
        """Return the channel with the specified label and timestamp from the
        collection"""
        return self._cache.cache_get(channel_label, timestamp=timestamp)

    def get_channel_timestamp(self, channel_label):
        """Returns the channel's timestamp"""
        if not self._channels_hash.has_key(channel_label):
            raise KeyError("Channel %s could not be found" % channel_label)
        return self._channels_hash[channel_label]

    def get_parent_channel_labels(self):
        """Return a list of channel labels for parent channels"""
        l = self._parent_channels.keys()
        l.sort()
        return l

    def get_child_channels(self, channel_label):
        """Return a list of (channel label, channel timestamp) for this parent
        channel"""
        if not self._parent_channels.has_key(channel_label):
            raise Exception, "Channel %s is not a parent" % channel_label
        return self._parent_channels[channel_label]

    def reset(self):
        """Reset the collection"""
        self._shared_state.clear()
        self.__init__()

class ChannelContainer(xmlSource.ChannelContainer):

    def endItemCallback(self):
        xmlSource.ChannelContainer.endItemCallback(self)
        if not self.batch:
            return
        c = ChannelCollection()
        c.add_channel(self.batch[-1])
        del self.batch[:]

    def endContainerCallback(self):
        # Not much to do here...
        pass

def get_channel_handler():
    handler = xmlSource.SatelliteDispatchHandler()
    handler.set_container(ChannelContainer())
    return handler

def import_channels(channels, orgid=None):
    collection = ChannelCollection()
    batch = []
    import satCerts
    orgs = map(lambda a: a['id'], satCerts.get_all_orgs())
    for c in channels:
        try:
            timestamp = collection.get_channel_timestamp(c)
        except KeyError:
            raise Exception, "Could not find channel %s" % c
        c_obj = collection.get_channel(c, timestamp)
        if c_obj is None:
            raise Exception, "Channel not found in cache: %s" % c

        # Check to see if we're asked to sync to an orgid,
        # make sure the org from the export is not null org,
        # finally if the orgs differ so we might wanna use
        # requested org's channel-family.
        # TODO: Move these checks somewhere more appropriate
        if not orgid and c_obj['org_id'] is not None:
            #If the src org is not present default to org 1
            orgid = DEFAULT_ORG
        if orgid is not None and c_obj['org_id'] is not None and \
            c_obj['org_id'] != orgid:
            #Only set the channel family if its a custom channel
            c_obj['org_id'] = orgid
            for family in c_obj['families']:
                family['label'] = 'private-channel-family-' + \
                                           str(c_obj['org_id'])

        syncLib.log(6, "Syncing Channel %s to Org %s " % \
                       (c_obj['label'], c_obj['org_id']))
        batch.append(c_obj)

    importer = channelImport.ChannelImport(batch, diskImportLib.get_backend())
    # Don't commit just yet
    importer.will_commit = 0
    importer.run()

# Singleton-like
class ShortPackageCollection:
    _shared_state = {}
    def __init__(self):
        self.__dict__ = self._shared_state
        if not self._shared_state.keys():
            self._packages_hash = {}
            self._cache = None
            self._init_cache()

    def _init_cache(self):
        self._cache = syncCache.ShortPackageCache()

    def add_package(self, package):
        """Stores a package in the collection"""
        package_id = package['package_id']
        timestamp = package['last_modified']
        last_modified = _to_timestamp(timestamp)
        self._packages_hash[package_id] = last_modified
        self._cache.cache_set(package_id, package, timestamp=last_modified)

    def get_package_timestamp(self, package_id):
        """Returns the package's timestamp"""
        if not self._packages_hash.has_key(package_id):
            raise KeyError("Package %s could not be found" % package_id)
        return self._packages_hash[package_id]

    def get_package(self, package_id, timestamp):
        """Return the package with the specified id and timestamp from the
        collection"""
        return self._cache.cache_get(package_id, timestamp=timestamp)

    def has_package(self, package_id, timestamp):
        """Returns true if the package exists in the collection"""
        return self._cache.cache_has_key(package_id, timestamp=timestamp)

    def reset(self):
        """Reset the collection"""
        self._shared_state.clear()
        self.__init__()

class ShortPackageContainer(xmlSource.IncompletePackageContainer):

    def endItemCallback(self):
        xmlSource.IncompletePackageContainer.endItemCallback(self)
        if not self.batch:
            return
        c = ShortPackageCollection()
        c.add_package(self.batch[-1])
        del self.batch[:]

    def endContainerCallback(self):
        # Not much to do here...
        pass

def get_short_package_handler():
    handler = xmlSource.SatelliteDispatchHandler()
    handler.set_container(ShortPackageContainer())
    return handler


class PackageCollection(ShortPackageCollection):
    _shared_state = {}

    def _init_cache(self):
        self._cache = syncCache.PackageCache()

    def get_package_timestamp(self, package_id):
        raise NotImplementedError

class PackageContainer(xmlSource.PackageContainer):

    def endItemCallback(self):
        xmlSource.PackageContainer.endItemCallback(self)
        if not self.batch:
            return
        c = PackageCollection()
        c.add_package(self.batch[-1])
        del self.batch[:]

    def endContainerCallback(self):
        # Not much to do here...
        pass

def get_package_handler():
    handler = xmlSource.SatelliteDispatchHandler()
    handler.set_container(PackageContainer())
    return handler


# Singleton-like
class SourcePackageCollection(ShortPackageCollection):
    _shared_state = {}

    def _init_cache(self):
        self._cache = syncCache.SourcePackageCache()

class SourcePackageContainer(xmlSource.SourcePackageContainer):
    def endItemCallback(self):
        xmlSource.SourcePackageContainer.endItemCallback(self)
        if not self.batch:
            return
        c = SourcePackageCollection()
        c.add_package(self.batch[-1])
        del self.batch[:]

    def endContainerCallback(self):
        # Not much to do here...
        pass

def get_source_package_handler():
    handler = xmlSource.SatelliteDispatchHandler()
    handler.set_container(SourcePackageContainer())
    return handler

# Singleton-like
class ErrataCollection:
    _shared_state = {}
    def __init__(self):
        self.__dict__ = self._shared_state
        if not self._shared_state.keys():
            self._errata_hash = {}
            self._cache = None
            self._init_cache()

    def _init_cache(self):
        self._cache = syncCache.ErratumCache()

    def add_erratum(self, erratum):
        """Stores an erratum in the collection"""
        erratum_id = erratum['erratum_id']
        timestamp = _to_timestamp(erratum['last_modified'])
        self._errata_hash[erratum_id] = timestamp
        self._cache.cache_set(erratum_id, erratum, timestamp=timestamp)

    def get_erratum_timestamp(self, erratum_id):
        """Returns the erratum's timestamp"""
        if not self._errata_hash.has_key(erratum_id):
            raise KeyError("Erratum %s could not be found" % erratum_id)
        return self._errata_hash[erratum_id]

    def get_erratum(self, erratum_id, timestamp):
        """Return the erratum with the specified id and timestamp from the
        collection. Note that timestamp can be None, in which case no timetamp
        matching is performed"""
        return self._cache.cache_get(erratum_id, timestamp=timestamp)

    def has_erratum(self, erratum_id, timestamp):
        """Returns true if the erratum exists in the collection"""
        return self._cache.cache_has_key(erratum_id, timestamp=timestamp)

    def reset(self):
        """Reset the collection"""
        self._shared_state.clear()
        self.__init__()

class ErrataContainer(xmlSource.ErrataContainer):

    def endItemCallback(self):
        xmlSource.ErrataContainer.endItemCallback(self)
        if not self.batch:
            return
        c = ErrataCollection()
        c.add_erratum(self.batch[-1])
        del self.batch[:]

    def endContainerCallback(self):
        # Not much to do here...
        pass

def get_errata_handler():
    handler = xmlSource.SatelliteDispatchHandler()
    handler.set_container(ErrataContainer())
    return handler


class KickstartableTreesCollection(BaseCollection):
    _shared_state = {}

    def _init_cache(self):
        self._cache = syncCache.KickstartableTreesCache()

    def _get_item_id(self, item):
        return item['label']

    def _get_item_timestamp(self, item):
        return None

class KickstartableTreesContainer(xmlSource.KickstartableTreesContainer):

    def endItemCallback(self):
        xmlSource.KickstartableTreesContainer.endItemCallback(self)
        if not self.batch:
            return
        c = KickstartableTreesCollection()
        c.add_item(self.batch[-1])
        del self.batch[:]

    def endContainerCallback(self):
        # Not much to do here...
        pass

def get_kickstarts_handler():
    handler = xmlSource.SatelliteDispatchHandler()
    handler.set_container(KickstartableTreesContainer())
    return handler

def import_packages(batch):
    importer = packageImport.PackageImport(batch, diskImportLib.get_backend())
    importer.setUploadForce(4)
    importer.setIgnoreUploaded(1)
    importer.run()
    importer.status()
    return importer

def link_channel_packages(batch, strict=1):
    importer = packageImport.ChannelPackageSubscription(batch,
        diskImportLib.get_backend(),
        caller="satsync.linkPackagesToChannels", strict=strict)
    importer.run()
    importer.status()
    return importer

def import_errata(batch):
    importer = errataImport.ErrataImport(batch, diskImportLib.get_backend())
    importer.ignoreMissing = 1
    importer.run()
    importer.status()
    return importer

def import_kickstarts(batch):
    importer = kickstartImport.KickstartableTreeImport(batch,
        diskImportLib.get_backend())
    importer.run()
    importer.status()
    return importer

def _to_timestamp(t):
    if isinstance(t, types.IntType):
        # Already an int
        return t
    # last_modified is YYYY-MM-DD HH24:MI:SS
    # The cache expects YYYYMMDDHH24MISS as format; so just drop the
    # spaces, dashes and columns
    last_modified = string.translate(t, string.maketrans("", ""), ' -:')
    return last_modified

# Generic container handler
class ContainerHandler:

    """generate and set container XML handlers"""

    def __init__(self):
        self.handler = xmlSource.SatelliteDispatchHandler()
        # arch containers
        self.setServerArchContainer()
        self.setPackageArchContainer()
        self.setChannelArchContainer()
        self.setCPUArchContainer()
        self.setServerPackageArchContainer()
        self.setServerChannelArchContainer()
        self.setServerGroupServerArchContainer()
        self.setChannelPackageArchContainer()
        # all other containers
        self.setChannelFamilyContainer()
        self.setBlacklistObsoletesContainer()
	self.setProductNamesContainer()

    def __del__(self):
        self.handler.close() # kill the circular reference.

    def close(self):
        self.handler.close() # kill the circular reference.

    def clear(self):
        self.handler.clear() # clear the batch

    # basic functionality:
    def process(self, stream):
        self.handler.process(stream)

    def reset(self):
        self.handler.reset()

    def getHandler(self):
        return self.handler

    # set arch containers:
    def setServerArchContainer(self):
        self.handler.set_container(diskImportLib.ServerArchContainer())
    def setPackageArchContainer(self):
        self.handler.set_container(diskImportLib.PackageArchContainer())
    def setChannelArchContainer(self):
        self.handler.set_container(diskImportLib.ChannelArchContainer())
    def setCPUArchContainer(self):
        self.handler.set_container(diskImportLib.CPUArchContainer())
    def setServerPackageArchContainer(self):
        self.handler.set_container(diskImportLib.ServerPackageArchCompatContainer())
    def setServerChannelArchContainer(self):
        self.handler.set_container(diskImportLib.ServerChannelArchCompatContainer())
    def setServerGroupServerArchContainer(self):
        self.handler.set_container(diskImportLib.ServerGroupServerArchCompatContainer())
    def setChannelPackageArchContainer(self):
        self.handler.set_container(ChannelPackageArchCompatContainer())
    # set all other containers:
    def setChannelFamilyContainer(self):
        self.handler.set_container(ChannelFamilyContainer())
    def setBlacklistObsoletesContainer(self):
        self.handler.set_container(diskImportLib.BlacklistObsoletesContainer())
    def setProductNamesContainer(self):
        self.handler.set_container(diskImportLib.ProductNamesContainer())

#
# more containers
#
# NOTE: we use *most* the Arch Containers from diskImportLib.py
#       this one is used simply to print out the arches.

class ChannelPackageArchCompatContainer(diskImportLib.ChannelPackageArchCompatContainer):

    arches = {}
    def endItemCallback(self):
        diskImportLib.ChannelPackageArchCompatContainer.endItemCallback(self)
        if not self.batch:
            return
        self.arches[self.batch[-1]['package-arch']] = 1

    def endContainerCallback(self):
        arches = self.arches.keys()
        arches.sort()
        if arches:
            for arch in arches:
                syncLib.log(6, '   parsed arch: %s' % (arch))
        diskImportLib.ChannelPackageArchCompatContainer.endContainerCallback(self)


class ChannelFamilyContainer(xmlSource.ChannelFamilyContainer):
    def endItemCallback(self):
        xmlSource.ChannelFamilyContainer.endItemCallback(self)
        if not self.batch:
            return
        syncLib.log(2, '   parsing family: %s' % (self.batch[-1]['name']))

    def endContainerCallback(self):
        batch = self.batch
        # use the copy only; don't want a persistent self.batch
        self.batch = []

        importer = channelImport.ChannelFamilyImport(batch,
            diskImportLib.get_backend())
        importer.run()

def populate_channel_family_permissions(cert):
    # Find channel families that we have imported
    current_cfs = _fetch_existing_channel_families()
    
    # Put the channel families coming from the cert into a hash
    # Add rh-public with unlimited subscriptions
    # Filter channel families that do not exist locally (this is possible with
    # channel dumps, where not all channel families have been dumped and
    # available for the satellite to import)

    # XXX hardcoding rh-public bad bad bad - but we committed to have
    # rh-public the only implied channel family. If we ever have to have a
    # different public channel family, it will have to be in the cert
    cert_chfam_hash = {}

    # Bugs 171160, 183365: We can't assume that the satellite already knows
    # about rh-public (it may not yet know about any channels).
    if current_cfs.has_key("rh-public"):
	cert_chfam_hash["rh-public"] = None

    for cf in cert.channel_families:
        if not current_cfs.has_key(cf.name):
            # Ignoring unavailable channel family at this point,
            # we'll create it at sync time.
            continue

        quant = cf.quantity
        if quant is not None:
            quant = int(quant)
        cert_chfam_hash[cf.name] = quant

    # Generate the channel family permissions data structure
    cfps = {}
    curr_cfps = {}
    for cfp in _fetch_channel_family_permissions():
        cf_name = cfp['channel_family']

        # org_id is the org_id which is given permission
        org_id = cfp['org_id']

        # Initially populate cf info with old limits from db
        cfps[(cf_name, org_id)] = cfp['max_members']
	curr_cfps[(cf_name, org_id)] = cfp['current_members']

    # Now set max_members based on the cert's max_members
    for cf_name, max_members in cert_chfam_hash.items():
        # Make the channel families with null max_members public
        if max_members is None:
            org_id = None
        else:
	    # default the org to 1 for channel families from cert
            org_id = 1

        cf_name = cf_name.encode('utf-8')
        try:
	    old_max_members = cfps[(cf_name, org_id)]
        except KeyError:
	    # New channel family, populate the db from cert
            cfps[(cf_name, org_id)] = max_members
            old_max_members = None

	if old_max_members and max_members < old_max_members:
	    # The cert count is low, set the db with new values
            cfps[(cf_name, org_id)] = max_members
   
    sum_max_values = compute_sum_max_members(cfps)
    for (cf_name, org_id), max_members in cfps.items():
        if org_id == 1:
	    if cert_chfam_hash.has_key(cf_name):
                cert_max_value = cert_chfam_hash[cf_name] or 0
            else:
	        # remove entitlements on extra slots 
                cfps[(cf_name, org_id)] = None
                continue
            if not max_members: 
	        max_members = 0
            if cert_max_value >= sum_max_values[cf_name]:
                cfps[(cf_name, 1)] = max_members + \
		                  (cert_max_value - sum_max_values[cf_name])
            else:
	        # lowering entitlements 
	        purge_count = sum_max_values[cf_name] - cert_max_value
	        cfps[(cf_name, 1)] = max_members - purge_count

    # Cleanup left out suborgs
    for (cf_name, org_id), max_members in cfps.items():
        if cfps.has_key((cf_name, 1)) and cfps[(cf_name, 1)] == None: #is None:
            cfps[(cf_name, org_id)] = None

    batch = []
    for (cf_name, org_id), max_members in cfps.items():
        cfperm = importLib.ChannelFamilyPermissions()
        batch.append(cfperm.populate({
            'channel_family'    : cf_name,
            'org_id'            : org_id,
            'max_members'       : max_members,
        }))
   
    importer = channelImport.ChannelFamilyPermissionsImport(batch,
        diskImportLib.get_backend())
    importer.will_commit = 0
    importer.run()

def compute_sum_max_members(cfps):
    cf_max_members = {}
    for (cf_name, org_id), max_members in cfps.items():
        if not max_members:
            max_members = 0
        if cf_max_members.has_key(cf_name):
            cf_max_members[cf_name] = cf_max_members[cf_name] + max_members
        else:
            cf_max_members[cf_name] = max_members
    return cf_max_members

_query_fetch_existing_channel_families = rhnSQL.Statement("""
    select label
     from rhnChannelFamily cf
""")
def _fetch_existing_channel_families():
    h = rhnSQL.prepare(_query_fetch_existing_channel_families)
    h.execute()

    cfs = {}
    while 1:
        row = h.fetchone_dict()
        if not row:
            break

        cfs[row['label']] = 1

    return cfs


_query_fetch_channel_family_permissions = rhnSQL.Statement("""
    select cf.label as channel_family, cfp.org_id,
           cfp.max_members, cfp.current_members, cf.org_id as owner_org_id
      from rhnChannelFamilyPermissions cfp, rhnChannelFamily cf
     where cfp.channel_family_id = cf.id
""")
def _fetch_channel_family_permissions():
    # rhnChannelFamilyPermissions is a view, but it should be safe to use
    # it for a simple join
    h = rhnSQL.prepare(_query_fetch_channel_family_permissions)
    h.execute()

    return h.fetchall_dict() or []


_query_purge_extra_channel_families_1 = rhnSQL.Statement("""
    delete from rhnPrivateChannelFamily cfp
     where max_members = 0
       and not exists (
        select 1 from rhnChannelFamilyMembers
         where channel_family_id = cfp.channel_family_id
       )
""")


_query_purge_private_channel_families = rhnSQL.Statement("""
    delete from rhnChannelFamily
        where org_id is null
          and label like '%private%'
""")

def purge_extra_channel_families():
    # Get rid of the extra channel families
    try:
	# Purge all unused private channel families with null org
        h = rhnSQL.prepare(_query_purge_private_channel_families)
        h.execute()
    except rhnSQL.SQLError, e:
        # Log it and move on - maybe we missed a FK; no reason to break the
        # sync completely for this.
        syncLib.log(-1, str(e))


_query_update_family_counts = rhnSQL.Statement("""
    declare
        cursor ch_fam_cursor is
            select cf.id channel_family_id, wc.id org_id
              from rhnChannelFamily cf, web_customer wc;
    begin
        for row in ch_fam_cursor loop
            rhn_channel.update_family_counts(row.channel_family_id,
                row.org_id);
        end loop;
    end;
""")
def update_channel_family_counts():
    h = rhnSQL.prepare(_query_update_family_counts)
    h.execute()
    rhnSQL.commit()


