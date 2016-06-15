# Copyright (c) 2016 Red Hat, Inc.
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

import json

import constants
from spacewalk.common.rhnConfig import CFG, initCFG
from spacewalk.server import rhnSQL
from spacewalk.server.importlib.backendOracle import SQLBackend
from spacewalk.server.importlib.contentSourcesImport import ContentSourcesImport
from spacewalk.server.importlib.channelImport import ChannelImport
from spacewalk.server.importlib.productNamesImport import ProductNamesImport
from spacewalk.server.importlib.importLib import Channel, ChannelFamily, \
    ProductName, DistChannelMap, ContentSource
from spacewalk.satellite_tools import reposync
from spacewalk.satellite_tools import contentRemove


class CdnSync(object):
    """Main class of CDN sync run."""

    def __init__(self):
        rhnSQL.initDB()
        initCFG('server.satellite')

        # Channel families mapping to channels
        with open(constants.CHANNEL_FAMILY_MAPPING_PATH, 'r') as f:
            self.families = json.load(f)

        # Channel metadata
        with open(constants.CHANNEL_DEFINITIONS_PATH, 'r') as f:
            self.channel_metadata = json.load(f)

        # Dist/Release channel mapping
        with open(constants.CHANNEL_DIST_MAPPING_PATH, 'r') as f:
            self.channel_dist_mapping = json.load(f)

        # Channel to repositories mapping
        with open(constants.CONTENT_SOURCE_MAPPING_PATH, 'r') as f:
            self.content_source_mapping = json.load(f)

        # Map channels to their channel family
        self.channel_to_family = {}
        for family in self.families:
            for channel in self.families[family]['channels']:
                self.channel_to_family[channel] = family

        # Set already synced channels
        h = rhnSQL.prepare("""
            select label from rhnChannel where org_id is null
        """)
        h.execute()
        channels = h.fetchall_dict() or []
        self.synced_channels = [ch['label'] for ch in channels]

    def _list_available_channels(self):
        h = rhnSQL.prepare("""
            select label from rhnChannelFamilyPermissions cfp inner join
                              rhnChannelFamily cf on cfp.channel_family_id = cf.id
            where cf.org_id is null
        """)
        h.execute()
        families = h.fetchall_dict() or []
        channels = {}
        for family in families:
            label = family['label']
            family = self.families[label]
            for channel_label in family['channels']:
                try:
                    # Only base channels as key in dictionary
                    if self.channel_metadata[channel_label]['parent_channel'] is None:
                        channels[channel_label] = [k for k in self.channel_metadata
                                                   if self.channel_metadata[k]['parent_channel'] == channel_label]
                except KeyError:
                    print("Channel %s not found in channel metadata" % channel_label)
                    continue

        return channels

    def print_channel_tree(self):
        available_channel_tree = self._list_available_channels()

        print("p = previously imported/synced channel")
        print(". = channel not yet imported/synced")

        print("Base channels:")
        for channel in sorted(available_channel_tree):
            status = 'p' if channel in self.synced_channels else '.'
            print("    %s %s" % (status, channel))

        for channel in sorted(available_channel_tree):
            # Print only if there are any child channels
            if len(available_channel_tree[channel]) > 0:
                print("%s:" % channel)
                for child in sorted(available_channel_tree[channel]):
                    status = 'p' if child in self.synced_channels else '.'
                    print("    %s %s" % (status, child))

    def _update_product_names(self, channels):
        backend = SQLBackend()
        batch = []

        for label in channels:
            channel = self.channel_metadata[label]
            if channel['product_label'] and channel['product_name']:
                product_name = ProductName()
                product_name['label'] = channel['product_label']
                product_name['name'] = channel['product_name']
                batch.append(product_name)

        importer = ProductNamesImport(batch, backend)
        importer.run()

    def _get_content_sources(self, channel, backend):
        batch = []
        type_id = backend.lookupContentSourceType('yum')
        sources = self.content_source_mapping[channel]
        for source in sources:
            if not source['pulp_content_category'] == "source":
                content_source = ContentSource()
                content_source['label'] = source['pulp_repo_label_v2']
                content_source['source_url'] = CFG.CDN_ROOT + source['relative_url']
                content_source['org_id'] = None
                content_source['type_id'] = type_id
                batch.append(content_source)
        return batch

    def _update_channels_metadata(self, channels):

        # First populate rhnProductName table
        self._update_product_names(channels)

        backend = SQLBackend()
        channels_batch = []
        content_sources_batch = []

        for label in channels:
            channel = self.channel_metadata[label]
            channel_object = Channel()
            for k in channel.keys():
                channel_object[k] = channel[k]

            family_object = ChannelFamily()
            family_object['label'] = self.channel_to_family[label]

            channel_object['families'] = [family_object]
            channel_object['label'] = label
            channel_object['basedir'] = '/'

            # Backend expects product_label named as product_name
            # To have correct value in rhnChannelProduct and reference
            # to rhnProductName in rhnChannel
            channel_object['product_name'] = channel['product_label']

            dists = []
            releases = []
            try:
                dist_map = self.channel_dist_mapping[label]
                for item in dist_map:
                    d = DistChannelMap()
                    for k in item:
                        d[k] = item[k]
                    d['channel'] = label
                    dists.append(d)
            except KeyError:
                pass

            channel_object['dists'] = dists
            channel_object['release'] = releases

            sources = self._get_content_sources(label, backend)
            content_sources_batch.extend(sources)
            channel_object['content-sources'] = sources

            channels_batch.append(channel_object)

        importer = ContentSourcesImport(content_sources_batch, backend)
        importer.run()

        importer = ChannelImport(channels_batch, backend)
        importer.run()

    @staticmethod
    def _sync_channel(channel, no_errata=False):
        print "======================================"
        print "| Channel: %s" % channel
        print "======================================"
        sync = reposync.RepoSync(channel,
                                 "yum",
                                 url=None,
                                 fail=True,
                                 quiet=False,
                                 filters=False,
                                 no_errata=no_errata,
                                 sync_kickstart=True,
                                 latest=False,
                                 strict=1)
        sync.sync()

    def sync(self, channels=None, no_packages=False, no_errata=False):
        # If no channels specified, sync already synced channels
        if channels is None:
            channels = self.synced_channels

        # Need to update channel metadata
        self._update_channels_metadata(channels)

        # Not going to sync anything
        if no_packages:
            return

        # Finally, sync channel content
        for channel in channels:
            self._sync_channel(channel, no_errata=no_errata)

    @staticmethod
    def clear_cache():
        # Clear packages outside channels from DB and disk
        contentRemove.delete_outside_channels(None)
