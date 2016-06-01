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
from spacewalk.server import rhnSQL
from spacewalk.server.importlib.backendOracle import SQLBackend
from spacewalk.server.importlib.channelImport import ChannelImport
from spacewalk.server.importlib.productNamesImport import ProductNamesImport
from spacewalk.server.importlib.importLib import Channel, ChannelFamily, ProductName


class CdnSync(object):
    """Main class of CDN sync run."""

    def __init__(self):
        rhnSQL.initDB()
        # Channel families mapping to channels
        with open(constants.CHANNEL_FAMILY_MAPPING_PATH, 'r') as f:
            self.families = json.load(f)

        # Map channels to their channel family
        self.channel_to_family = {}
        for family in self.families:
            for channel in self.families[family]['channels']:
                self.channel_to_family[channel] = family

        # Channel metadata
        with open(constants.CHANNEL_DEFINITIONS_PATH, 'r') as f:
            self.channel_metadata = json.load(f)

    def _list_synced_channels(self):
        h = rhnSQL.prepare("""
            select label from rhnChannel where org_id is null
        """)
        h.execute()
        channels = h.fetchall_dict() or []
        channels = [ch['label'] for ch in channels]
        return channels

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
        synced_channels = self._list_synced_channels()

        print("p = previously imported/synced channel")
        print(". = channel not yet imported/synced")

        print("Base channels:")
        for channel in sorted(available_channel_tree):
            status = 'p' if channel in synced_channels else '.'
            print("    %s %s" % (status, channel))

        for channel in sorted(available_channel_tree):
            # Print only if there are any child channels
            if len(available_channel_tree[channel]) > 0:
                print("%s:" % channel)
                for child in sorted(available_channel_tree[channel]):
                    status = 'p' if channel in synced_channels else '.'
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

    def _update_channels_metadata(self, channels):

        # First populate rhnProductName table
        self._update_product_names(channels)

        backend = SQLBackend()
        batch = []

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

            batch.append(channel_object)

        importer = ChannelImport(batch, backend)
        importer.run()

    def _sync_channel(self, channel):
        pass

    def sync(self, channels=None):
        synced_channels = self._list_synced_channels()
        # If no channels specified, sync already synced channels
        if channels is None:
            channels = synced_channels

        # Need to update channel metadata
        self._update_channels_metadata(channels)

        # Finally, sync channel content
        for channel in channels:
            self._sync_channel(channel)
