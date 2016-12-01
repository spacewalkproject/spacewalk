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
from spacewalk.common import rhnLog
from spacewalk.server import rhnSQL
from spacewalk.server.rhnChannel import ChannelNotFoundError
from spacewalk.server.importlib.backendOracle import SQLBackend
from spacewalk.server.importlib.contentSourcesImport import ContentSourcesImport
from spacewalk.server.importlib.channelImport import ChannelImport
from spacewalk.server.importlib.productNamesImport import ProductNamesImport
from spacewalk.server.importlib.importLib import Channel, ChannelFamily, \
    ProductName, DistChannelMap, ReleaseChannelMap
from spacewalk.satellite_tools import reposync
from spacewalk.satellite_tools import contentRemove
from spacewalk.satellite_tools.syncLib import log, log2disk, log2stderr
from spacewalk.satellite_tools.repo_plugins import yum_src

from common import CdnMappingsLoadError, verify_mappings
from repository import CdnRepositoryManager


class CdnSync(object):
    """Main class of CDN sync run."""

    log_path = '/var/log/rhn/cdnsync.log'

    def __init__(self, no_packages=False, no_errata=False, no_rpms=False, no_kickstarts=False,
                 log_level=None, mount_point=None, consider_full=False):

        self.cdn_repository_manager = CdnRepositoryManager(mount_point)
        self.no_packages = no_packages
        self.no_errata = no_errata
        self.no_rpms = no_rpms
        self.no_kickstarts = no_kickstarts
        if log_level is None:
            log_level = 0
        self.log_level = log_level

        if mount_point:
            self.mount_point = "file://" + mount_point
            self.consider_full = consider_full
        else:
            self.mount_point = CFG.CDN_ROOT
            self.consider_full = True

        CFG.set('DEBUG', log_level)
        rhnLog.initLOG(self.log_path, self.log_level)
        log2disk(0, "Command: %s" % str(sys.argv))

        rhnSQL.initDB()
        initCFG('server.satellite')

        verify_mappings()

        f = None
        # try block in try block - this is hack for python 2.4 compatibility
        # to support finally
        try:
            try:
                # Channel families mapping to channels
                f = open(constants.CHANNEL_FAMILY_MAPPING_PATH, 'r')
                self.families = json.load(f)
                f.close()

                # Channel metadata
                f = open(constants.CHANNEL_DEFINITIONS_PATH, 'r')
                self.channel_metadata = json.load(f)
                f.close()

                # Dist/Release channel mapping
                f = open(constants.CHANNEL_DIST_MAPPING_PATH, 'r')
                self.channel_dist_mapping = json.load(f)
                f.close()

                # Kickstart metadata
                f = open(constants.KICKSTART_DEFINITIONS_PATH, 'r')
                self.kickstart_metadata = json.load(f)
                f.close()
            except IOError:
                e = sys.exc_info()[1]
                raise CdnMappingsLoadError("Problem with loading file: %s" % e)
        finally:
            if f is not None:
                f.close()

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
        # Select channel families in DB
        h = rhnSQL.prepare("""
            select label from rhnChannelFamilyPermissions cfp inner join
                              rhnChannelFamily cf on cfp.channel_family_id = cf.id
            where cf.org_id is null
        """)
        h.execute()
        families = h.fetchall_dict() or []

        # collect all channel from available families
        all_channels = []
        channel_tree = {}
        # Not available parents of child channels
        not_available_channels = []
        for family in families:
            label = family['label']
            try:
                family = self.families[label]
            except KeyError:
                log2stderr(0, "ERROR: Unknown channel family: %s" % label)
                continue
            channels = [c for c in family['channels'] if c is not None]
            all_channels.extend(channels)

        # filter available channels
        all_channels = [x for x in all_channels if
                        self.cdn_repository_manager.check_channel_availability(x, self.no_kickstarts)]

        for base_channel in [x for x in all_channels if not self.channel_metadata[x]['parent_channel']]:
            channel_tree[base_channel] = []
        for child_channel in [x for x in all_channels if self.channel_metadata[x]['parent_channel']]:
            parent_channel = self.channel_metadata[child_channel]['parent_channel']
            # Parent not available, orphaned child channel
            if parent_channel not in channel_tree:
                channel_tree[parent_channel] = []
                not_available_channels.append(parent_channel)
            channel_tree[parent_channel].append(child_channel)

        return channel_tree, not_available_channels

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

            # Distribution/Release channel mapping available
            if label in self.channel_dist_mapping:
                dist_map = self.channel_dist_mapping[label]
                for item in dist_map:
                    if item['eus_release']:
                        r = ReleaseChannelMap()
                        r['product'] = item['os']
                        r['version'] = item['release']
                        r['release'] = item['eus_release']
                        r['channel_arch'] = item['channel_arch']
                        releases.append(r)
                    else:
                        d = DistChannelMap()
                        for k in item:
                            d[k] = item[k]
                        dists.append(d)

            channel_object['dists'] = dists
            channel_object['release'] = releases

            sources = self.cdn_repository_manager.get_content_sources_import_batch(label, backend)
            content_sources_batch.extend(sources)
            channel_object['content-sources'] = sources

            channels_batch.append(channel_object)

        importer = ContentSourcesImport(content_sources_batch, backend)
        importer.run()

        importer = ChannelImport(channels_batch, backend)
        importer.run()

    def _count_packages_in_repo(self, repo_source):
        repo_label = self.cdn_repository_manager.get_content_source_label(repo_source)
        keys = self.cdn_repository_manager.get_repository_crypto_keys(repo_source['relative_url'])
        repo_plugin = yum_src.ContentSource(self.mount_point + str(repo_source['relative_url']),
                                            str(repo_label), org=None)
        repo_plugin.set_ssl_options(str(keys['ca_cert']), str(keys['client_cert']), str(keys['client_key']))
        return repo_plugin.raw_list_packages()

    def _sync_channel(self, channel):
        excluded_urls = []
        kickstart_trees = []

        if channel in self.kickstart_metadata:
            kickstart_trees = self.kickstart_metadata[channel]

        if self.no_kickstarts:
            kickstart_repos = self.cdn_repository_manager.get_content_sources_kickstart(channel)
            excluded_urls.extend([x['relative_url'] for x in kickstart_repos])

        log(0, "======================================")
        log(0, "| Channel: %s" % channel)
        log(0, "======================================")
        log(0, "Sync of channel started.")
        log2disk(0, "Please check 'cdnsync/%s.log' for sync log of this channel." % channel, notimeYN=True)
        sync = reposync.RepoSync(channel,
                                 "yum",
                                 url=None,
                                 fail=True,
                                 filters=False,
                                 no_packages=self.no_packages,
                                 no_errata=self.no_errata,
                                 sync_kickstart=(not self.no_kickstarts),
                                 latest=False,
                                 metadata_only=self.no_rpms,
                                 excluded_urls=excluded_urls,
                                 strict=self.consider_full,
                                 log_dir="cdnsync",
                                 log_level=self.log_level)
        sync.set_ks_tree_type('rhn-managed')
        if kickstart_trees:
            # Assuming all trees have same install type
            sync.set_ks_install_type(kickstart_trees[0]['ks_install_type'])
        sync.set_urls_prefix(self.mount_point)
        return sync.sync(update_repodata=True)

    def sync(self, channels=None):
        # If no channels specified, sync already synced channels
        if not channels:
            channels = self.synced_channels

        # Check channel availability before doing anything
        not_available = []
        for channel in channels:
            if any(channel not in d for d in
                   [self.channel_metadata, self.channel_to_family]) or (
                       not self.cdn_repository_manager.check_channel_availability(channel, self.no_kickstarts)):
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
            # Switch back to cdnsync log
            rhnLog.initLOG(self.log_path, self.log_level)
            log2disk(0, "Sync of channel completed.")

        log(0, "Total time: %s" % str(total_time).split('.')[0])

    def count_packages(self):
        start_time = int(time.time())

        channel_tree, not_available_channels = self._list_available_channels()

        repo_list = []
        for base_channel in sorted(channel_tree):
            channel_list = channel_tree[base_channel]
            if base_channel not in not_available_channels:
                channel_list.append(base_channel)
            for channel in sorted(channel_list):
                repo_list.extend(self.cdn_repository_manager.get_content_sources(channel))

        log(0, "Number of repositories: %d" % len(repo_list))
        already_downloaded = 0
        print_progress_bar(already_downloaded, len(repo_list), prefix='Downloading repodata:',
                           suffix='Complete', bar_length=50)

        for base_channel in sorted(channel_tree):
            channel_list = channel_tree[base_channel]
            if base_channel not in not_available_channels:
                channel_list.append(base_channel)
            for channel in sorted(channel_list):
                sources = self.cdn_repository_manager.get_content_sources(channel)
                list_packages = []
                for source in sources:
                    list_packages.extend(self._count_packages_in_repo(source))
                    already_downloaded += 1
                    print_progress_bar(already_downloaded, len(repo_list), prefix='Downloading repodata:',
                                       suffix='Complete', bar_length=50)

                cdn_repodata_path = constants.CDN_REPODATA_ROOT + '/' + channel

                # create directory for repo data if it doesn't exist
                try:
                    os.makedirs(cdn_repodata_path)
                except OSError:
                    exc = sys.exc_info()[1]
                    if exc.errno == errno.EEXIST and os.path.isdir(cdn_repodata_path):
                        pass
                    else:
                        raise
                f_out = open(cdn_repodata_path + '/' + "packages_num", 'w')
                try:
                    f_out.write(str(len(set(list_packages))))
                finally:
                    if f_out is not None:
                        f_out.close()

        elapsed_time = int(time.time())
        log(0, "Elapsed time: %d seconds" % (elapsed_time - start_time))

    def print_channel_tree(self, repos=False):
        channel_tree, not_available_channels = self._list_available_channels()

        if not channel_tree:
            log2stderr(0, "No available channels were found. Is your %s activated for CDN?" % PRODUCT_NAME)
            return

        log(0, "p = previously imported/synced channel")
        log(0, ". = channel not yet imported/synced")
        log(0, "? = No CDN source provided to count number of packages")

        log(0, "Base channels:")
        available_base_channels = [x for x in sorted(channel_tree) if x not in not_available_channels]
        if not available_base_channels:
            log(0, "      NONE")
        for channel in available_base_channels:
            if channel in self.synced_channels:
                status = 'p'
            else:
                status = '.'

            sources = self.cdn_repository_manager.get_content_sources(channel)
            if sources:
                packages_number = '0'
            else:
                packages_number = '?'
            try:
                packages_number = open(constants.CDN_REPODATA_ROOT + '/' + channel + "/packages_num", 'r').read()
            # pylint: disable=W0703
            except Exception:
                pass

            log(0, "    %s %s %s" % (status, channel, packages_number))
            if repos:
                if sources:
                    for source in sources:
                        log(0, "        %s" % source['relative_url'])
                else:
                    log(0, "        No CDN source provided!")

        # print information about child channels
        for channel in sorted(channel_tree):
            # Print only if there are any child channels
            if len(channel_tree[channel]) > 0:
                log(0, "%s:" % channel)
                for child in sorted(channel_tree[channel]):
                    if child in self.synced_channels:
                        status = 'p'
                    else:
                        status = '.'
                    sources = self.cdn_repository_manager.get_content_sources(child)
                    if sources:
                        packages_number = '0'
                    else:
                        packages_number = '?'
                    try:
                        packages_number = open(constants.CDN_REPODATA_ROOT + '/' + child + "/packages_num", 'r').read()
                    # pylint: disable=W0703
                    except Exception:
                        pass

                    log(0, "    %s %s %s" % (status, child, packages_number))
                    if repos:
                        if sources:
                            for source in sources:
                                log(0, "        %s" % source['relative_url'])
                        else:
                            log(0, "        No CDN source provided!")

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
