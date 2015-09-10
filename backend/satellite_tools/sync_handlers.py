#
# Copyright (c) 2008--2015 Red Hat, Inc.
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
import sys

from spacewalk.server.importlib import channelImport, packageImport, errataImport, \
    kickstartImport
import diskImportLib
import xmlSource
import string  # pylint: disable=W0402
import syncCache
import syncLib

DEFAULT_ORG = 1

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

    def add_item(self, channel_object):
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

    @staticmethod
    def _get_list_from_dict(diction, key):
        # Returns the dictionary's key if present (assumed to be a list), or
        # sets the value to an empty list and returns it
        if diction.has_key(key):
            l = diction[key]
        else:
            l = diction[key] = []
        return l

    def get_channel_labels(self):
        """Return the channel labels from this collection"""
        return [x[0] for x in self._channels]

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

# pylint: disable=W0232


class SyncHandlerContainer:
    collection = object

    # this class has no __init__ for the purpose
    # it's used in multiple inheritance mode and inherited classes should
    # use __init__ from the other base class

    def endItemCallback(self):
        # reference to xmlSource superclass we redefines
        xml_superclass = self.__class__.__bases__[1]
        xml_superclass.endItemCallback(self)
        # pylint: disable=E1101
        if not self.batch:
            return
        c = self.collection()
        c.add_item(self.batch[-1])
        del self.batch[:]

    def endContainerCallback(self):
        # Not much to do here...
        pass


def get_sync_handler(container):
    handler = xmlSource.SatelliteDispatchHandler()
    handler.set_container(container)
    return handler


class ChannelContainer(SyncHandlerContainer, xmlSource.ChannelContainer):
    collection = ChannelCollection


def get_channel_handler():
    return get_sync_handler(ChannelContainer())


def import_channels(channels, orgid=None, master=None):
    collection = ChannelCollection()
    batch = []
    org_map = None
    my_backend = diskImportLib.get_backend()
    if master:
        org_map = my_backend.lookupOrgMap(master)['master-id-to-local-id']
    for c in channels:
        try:
            timestamp = collection.get_channel_timestamp(c)
        except KeyError:
            raise Exception, "Could not find channel %s" % c, sys.exc_info()[2]
        c_obj = collection.get_channel(c, timestamp)
        if c_obj is None:
            raise Exception, "Channel not found in cache: %s" % c

        # Check to see if we're asked to sync to an orgid,
        # make sure the org from the export is not null org,
        # finally if the orgs differ so we might wanna use
        # requested org's channel-family.
        # TODO: Move these checks somewhere more appropriate
        if not orgid and c_obj['org_id'] is not None:
            # If the src org is not present default to org 1
            orgid = DEFAULT_ORG
        if orgid is not None and c_obj['org_id'] is not None and \
                c_obj['org_id'] != orgid:
            # If we know the master this is coming from and the master org
            # has been mapped to a local org, transform org_id to the local
            # org_id. Otherwise just put it in the default org.
            if (org_map and c_obj['org_id'] in org_map.keys()
                    and org_map[c_obj['org_id']]):
                c_obj['org_id'] = org_map[c_obj['org_id']]
            else:
                c_obj['org_id'] = orgid
                if c_obj.has_key('trust_list'):
                    del(c_obj['trust_list'])
            for family in c_obj['families']:
                family['label'] = 'private-channel-family-' + \
                    str(c_obj['org_id'])
        # If there's a trust list on the channel, transform the org ids to
        # the local ones
        if c_obj.has_key('trust_list') and c_obj['trust_list']:
            trusts = []
            for trust in c_obj['trust_list']:
                if org_map.has_key(trust['org_trust_id']):
                    trust['org_trust_id'] = org_map[trust['org_trust_id']]
                    trusts.append(trust)
            c_obj['trust_list'] = trusts

        syncLib.log(6, "Syncing Channel %s to Org %s " % (c_obj['label'], c_obj['org_id']))
        batch.append(c_obj)

    importer = channelImport.ChannelImport(batch, my_backend)
    # Don't commit just yet
    importer.will_commit = 0
    importer.run()
    return importer

# Singleton-like


class ShortPackageCollection:
    _shared_state = {}

    def __init__(self):
        self.__dict__ = self._shared_state
        if not self._shared_state.keys():
            self._cache = None
            self._init_cache()

    def _init_cache(self):
        self._cache = syncCache.ShortPackageCache()

    def add_item(self, package):
        """Stores a package in the collection"""
        self._cache.cache_set(package['package_id'], package)

    def get_package(self, package_id):
        """Return the package with the specified id from the collection"""
        return self._cache.cache_get(package_id)

    def has_package(self, package_id):
        """Returns true if the package exists in the collection"""
        return self._cache.cache_has_key(package_id)

    def reset(self):
        """Reset the collection"""
        self._shared_state.clear()
        self.__init__()


class ShortPackageContainer(SyncHandlerContainer, xmlSource.IncompletePackageContainer):
    collection = ShortPackageCollection


def get_short_package_handler():
    return get_sync_handler(ShortPackageContainer())


class PackageCollection(ShortPackageCollection):
    _shared_state = {}

    def _init_cache(self):
        self._cache = syncCache.PackageCache()

    def get_package_timestamp(self, package_id):
        raise NotImplementedError


class PackageContainer(SyncHandlerContainer, xmlSource.PackageContainer):
    collection = PackageCollection


def get_package_handler():
    return get_sync_handler(PackageContainer())


# Singleton-like
class SourcePackageCollection(ShortPackageCollection):
    _shared_state = {}

    def _init_cache(self):
        self._cache = syncCache.SourcePackageCache()


class SourcePackageContainer(SyncHandlerContainer, xmlSource.SourcePackageContainer):
    collection = SourcePackageCollection


def get_source_package_handler():
    return get_sync_handler(SourcePackageContainer())

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

    def add_item(self, erratum):
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


class ErrataContainer(SyncHandlerContainer, xmlSource.ErrataContainer):
    collection = ErrataCollection


def get_errata_handler():
    return get_sync_handler(ErrataContainer())


class KickstartableTreesCollection(BaseCollection):
    _shared_state = {}

    def _init_cache(self):
        self._cache = syncCache.KickstartableTreesCache()

    def _get_item_id(self, item):
        return item['label']

    def _get_item_timestamp(self, item):
        return None


class KickstartableTreesContainer(SyncHandlerContainer, xmlSource.KickstartableTreesContainer):
    collection = KickstartableTreesCollection


def get_kickstarts_handler():
    return get_sync_handler(KickstartableTreesContainer())


def import_packages(batch, sources=0):
    importer = packageImport.PackageImport(batch, diskImportLib.get_backend(), sources)
    importer.setUploadForce(4)
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
    # python 2.4 can't handle t.translate(None, ' -:')
    last_modified = t.translate(string.maketrans("", ""), ' -:')
    return last_modified

# Generic container handler


class ContainerHandler:

    """generate and set container XML handlers"""

    def __init__(self, master_label, create_orgs=False):
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
        self.setProductNamesContainer()
        self.setOrgContainer(master_label, create_orgs)

    def __del__(self):
        self.handler.close()  # kill the circular reference.

    def close(self):
        self.handler.close()  # kill the circular reference.

    def clear(self):
        self.handler.clear()  # clear the batch

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

    def setProductNamesContainer(self):
        self.handler.set_container(diskImportLib.ProductNamesContainer())

    def setOrgContainer(self, master_label, create_orgs):
        # pylint: disable=E1101,E1103
        self.handler.set_container(diskImportLib.OrgContainer())
        self.handler.get_container('rhn-orgs').set_master_and_create_org_args(
            master_label, create_orgs)

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
