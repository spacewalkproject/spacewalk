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
import errno
import os
import sys
import time
import datetime

import constants
from spacewalk.common.rhnConfig import CFG, initCFG, PRODUCT_NAME
from spacewalk.server import rhnSQL
from spacewalk.server.rhnChannel import ChannelNotFoundError
from spacewalk.server.importlib.backendOracle import SQLBackend
from spacewalk.server.importlib.contentSourcesImport import ContentSourcesImport
from spacewalk.server.importlib.channelImport import ChannelImport
from spacewalk.server.importlib.productNamesImport import ProductNamesImport
from spacewalk.server.importlib.importLib import Channel, ChannelFamily, \
    ProductName, DistChannelMap, ContentSource
from spacewalk.satellite_tools import reposync
from spacewalk.satellite_tools import contentRemove
from spacewalk.satellite_tools.repo_plugins import yum_src


class CdnSync(object):
    """Main class of CDN sync run."""

    def __init__(self, no_packages=False, no_errata=False, no_rpms=False, no_kickstarts=False):

        self.no_packages = no_packages
        self.no_errata = no_errata
        self.no_rpms = no_rpms
        self.no_kickstarts = no_kickstarts

        rhnSQL.initDB()
        initCFG('server.satellite')

        try:
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

            # Channel to kickstart repositories mapping
            with open(constants.KICKSTART_SOURCE_MAPPING_PATH, 'r') as f:
                self.kickstart_source_mapping = json.load(f)
        except IOError:
            e = sys.exc_info()[1]
            # TODO: print only on bigger debug level
            print("ERROR: Problem with loading file: %s" % e)
            raise CdnMappingsLoadError()

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

        # Set SSL-keys for channel family
        self.family_keys = {}

    def _get_family_keys(self, family_label):
        if family_label not in self.family_keys:
            # get ssl keys from database
            ssl_query = rhnSQL.prepare("""
                                select k1.key as ca_cert, k2.key as client_cert, k3.key as client_key
                                from rhncontentssl join
                                     rhncryptokey k1 on rhncontentssl.ssl_ca_cert_id = k1.id left outer join
                                     rhncryptokey k2 on rhncontentssl.ssl_client_cert_id = k2.id left outer join
                                     rhncryptokey k3 on rhncontentssl.ssl_client_key_id = k3.id inner join
                                     rhnchannelfamily cf on rhncontentssl.channel_family_id = cf.id
                                where cf.label = :channel_family
                            """)
            ssl_query.execute(channel_family=family_label)
            keys = ssl_query.fetchone_dict()
            if 'client_key' not in keys or 'client_cert' not in keys or 'ca_cert' not in keys:
                raise Exception("Cannot get SSL keys for channel family %s" % family_label)
            else:
                self.family_keys[family_label] = keys

        return self.family_keys[family_label]

    def _list_available_channels(self):
        # Select from rhnContentSsl to filter cdn-activated channel families
        h = rhnSQL.prepare("""
            select label from rhnChannelFamilyPermissions cfp inner join
                              rhnChannelFamily cf on cfp.channel_family_id = cf.id inner join
                              rhnContentSsl cs on cf.id = cs.channel_family_id
            where cf.org_id is null
        """)
        h.execute()
        families = h.fetchall_dict() or []

        # collect all channel from available families
        all_channels = []
        base_channels = {}
        for family in families:
            label = family['label']
            family = self.families[label]
            channels = [c for c in family['channels'] if c is not None]
            all_channels.extend(channels)

        # fill base_channel
        for channel in all_channels:
            try:
                # Only base channels as key in dictionary
                if self.channel_metadata[channel]['parent_channel'] is None:
                    base_channels[channel] = [k for k in all_channels
                                              if self.channel_metadata[k]['parent_channel'] == channel]
            except KeyError:
                print("Channel %s not found in channel metadata" % channel)
                continue

        return base_channels

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
        sources = []
        type_id = backend.lookupContentSourceType('yum')
        if channel in self.content_source_mapping:
            sources.extend(self.content_source_mapping[channel])

        if channel in self.kickstart_source_mapping:
            sources.extend(self.kickstart_source_mapping[channel])

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
    def _count_packages_in_repo(repo_source, keys):
        repo_label = (repo_source.split(CFG.CDN_ROOT)[1])[1:].replace('/', '_')
        repo_plugin = yum_src.ContentSource(str(repo_source), str(repo_label))
        repo_plugin.set_ssl_options(str(keys['ca_cert']), str(keys['client_cert']), str(keys['client_key']))

        cdn_repodata_path = constants.CDN_REPODATA_ROOT + '/' +\
                            (repo_source.split(CFG.CDN_ROOT)[1])[1:].replace('/', '_')

        # create directory for repo data if it doesn't exist
        try:
            os.makedirs(cdn_repodata_path)
        except OSError as exc:
            if exc.errno == errno.EEXIST and os.path.isdir(cdn_repodata_path):
                pass
            else:
                raise

        with open(cdn_repodata_path + '/' + "packages_num", 'w') as f_out:
            f_out.write(str(repo_plugin.number_of_packages()))

    def _sync_channel(self, channel):
        excluded_urls = []
        sync_kickstart = True
        if self.no_kickstarts:
            if channel in self.kickstart_source_mapping:
                excluded_urls = [CFG.CDN_ROOT + s['relative_url'] for s in self.kickstart_source_mapping[channel]]
            sync_kickstart = False

        print "======================================"
        print "| Channel: %s" % channel
        print "======================================"
        sync = reposync.RepoSync(channel,
                                 "yum",
                                 url=None,
                                 fail=True,
                                 quiet=False,
                                 filters=False,
                                 no_packages=self.no_packages,
                                 no_errata=self.no_errata,
                                 sync_kickstart=sync_kickstart,
                                 latest=False,
                                 metadata_only=self.no_rpms,
                                 excluded_urls=excluded_urls,
                                 strict=1)
        sync.set_ks_tree_type('rhn-managed')
        return sync.sync()

    def sync(self, channels=None):
        # If no channels specified, sync already synced channels
        if not channels:
            channels = self.synced_channels

        # Check channel availability before doing anything
        not_available = []
        for channel in channels:
            if any(channel not in d for d in
                   [self.channel_metadata, self.channel_to_family,  self.content_source_mapping]):
                not_available.append(channel)

        if not_available:
            raise ChannelNotFoundError("  " + "\n  ".join(not_available))

        # Need to update channel metadata
        self._update_channels_metadata(channels)

        # Finally, sync channel content
        total_time = datetime.timedelta()
        for channel in channels:
            cur_time = self._sync_channel(channel)
            total_time += cur_time

        print("Total time: %s" % str(total_time).split('.')[0])

    def count_packages(self):
        start_time = int(time.time())

        backend = SQLBackend()
        base_channels = self._list_available_channels()

        repo_list = []
        for base_channel in sorted(base_channels):
            for child in sorted(base_channels[base_channel]):
                repo_list.extend(self._get_content_sources(child, backend))

        print("Number of repositories: %d" % len(repo_list))
        already_downloaded = 0
        print_progress_bar(already_downloaded, len(repo_list), prefix='Downloading repodata:',
                           suffix='Complete', bar_length=50)

        for base_channel in sorted(base_channels):
            for child in sorted(base_channels[base_channel]):
                family_label = self.channel_to_family[child]
                keys = self._get_family_keys(family_label)

                sources = self._get_content_sources(child, backend)
                for source in sources:
                    self._count_packages_in_repo(source['source_url'], keys)
                    already_downloaded += 1
                    print_progress_bar(already_downloaded, len(repo_list), prefix='Downloading repodata:',
                                       suffix='Complete', bar_length=50)
        elapsed_time = int(time.time())
        print("Elapsed time: %d seconds" % (elapsed_time - start_time))

    def print_channel_tree(self, repos=False):
        available_channel_tree = self._list_available_channels()
        backend = SQLBackend()

        if available_channel_tree:
            print("p = previously imported/synced channel")
            print(". = channel not yet imported/synced")
            print("? = No CDN source provided to count number of packages")

            print("Base channels:")
            for channel in sorted(available_channel_tree):
                status = 'p' if channel in self.synced_channels else '.'
                print("    %s %s" % (status, channel))
                if repos:
                    sources = self._get_content_sources(channel, backend)
                    if sources:
                        for source in sources:
                            print("        %s" % source['source_url'])
                    else:
                        print("        No CDN source provided!")
            for channel in sorted(available_channel_tree):
                # Print only if there are any child channels
                if len(available_channel_tree[channel]) > 0:
                    print("%s:" % channel)
                    for child in sorted(available_channel_tree[channel]):
                        status = 'p' if child in self.synced_channels else '.'
                        packages_number = '?'
                        sources = self._get_content_sources(child, backend)
                        if sources:
                            packages_number = 0
                            for source in sources:
                                pn_file = constants.CDN_REPODATA_ROOT + '/' + \
                                          (source['source_url'].split(CFG.CDN_ROOT)[1])[1:].replace('/', '_') + \
                                          "/packages_num"
                                try:
                                    packages_number += int(open(pn_file, 'r').read())
                                # pylint: disable=W0703
                                except Exception:
                                    pass

                        print("    %s %s %s" % (status, child, str(packages_number)))
                        if repos:

                            if sources:
                                for source in sources:
                                    print("        %s" % source['source_url'])
                            else:
                                print("        No CDN source provided!")
        else:
            print("No available channels were found. Is your %s activated for CDN?" % PRODUCT_NAME)

    @staticmethod
    def clear_cache():
        # Clear packages outside channels from DB and disk
        contentRemove.delete_outside_channels(None)


# from here http://stackoverflow.com/questions/3173320/text-progress-bar-in-the-console
# Print iterations progress
def print_progress_bar(iteration, total, prefix='', suffix='', decimals=2, bar_length=100):
    """
    Call in a loop to create terminal progress bar
    @params:
        iteration   - Required  : current iteration (Int)
        total       - Required  : total iterations (Int)
        prefix      - Optional  : prefix string (Str)
        suffix      - Optional  : suffix string (Str)
        decimals    - Optional  : number of decimals in percent complete (Int)
        bar_length   - Optional  : character length of bar (Int)
    """
    filled_length = int(round(bar_length * iteration / float(total)))
    percents = round(100.00 * (iteration / float(total)), decimals)
    bar_char = '#' * filled_length + '-' * (bar_length - filled_length)
    sys.stdout.write('\r%s |%s| %s%s %s' % (prefix, bar_char, percents, '%', suffix))
    sys.stdout.flush()
    if iteration == total:
        sys.stdout.write('\n')
        sys.stdout.flush()


class CdnMappingsLoadError(Exception):
    pass
