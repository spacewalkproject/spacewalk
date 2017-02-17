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
from datetime import datetime, timedelta

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
from spacewalk.satellite_tools.satCerts import get_certificate_info, verify_certificate_dates
from spacewalk.satellite_tools.syncLib import log, log2disk, log2
from spacewalk.satellite_tools.repo_plugins import yum_src, ThreadedDownloader, ProgressBarLogger

from common import CdnMappingsLoadError, verify_mappings, human_readable_size
from repository import CdnRepositoryManager, CdnRepositoryNotFoundError


class CdnSync(object):
    """Main class of CDN sync run."""

    log_path = '/var/log/rhn/cdnsync.log'

    def __init__(self, no_packages=False, no_errata=False, no_rpms=False, no_kickstarts=False,
                 log_level=None, mount_point=None, consider_full=False, force_kickstarts=False):

        self.cdn_repository_manager = CdnRepositoryManager(mount_point)
        self.no_packages = no_packages
        self.no_errata = no_errata
        self.no_rpms = no_rpms
        if self.no_packages and self.no_rpms:
            log(0, "Parameter --no-rpms has no effect.")
        self.no_kickstarts = no_kickstarts
        self.force_kickstarts = force_kickstarts
        if self.no_kickstarts and self.force_kickstarts:
            log(0, "Parameter --force-kickstarts has no effect.")
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
                log2(0, 1, "ERROR: Unknown channel family: %s" % label, stream=sys.stderr)
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

            # Set default channel access to private
            channel_object['channel_access'] = 'private'

            channels_batch.append(channel_object)

        importer = ContentSourcesImport(content_sources_batch, backend)
        importer.run()

        importer = ChannelImport(channels_batch, backend)
        importer.run()

    def _create_yum_repo(self, repo_source):
        repo_label = self.cdn_repository_manager.get_content_source_label(repo_source)
        repo_plugin = yum_src.ContentSource(self.mount_point + str(repo_source['relative_url']),
                                            str(repo_label), org=None, no_mirrors=True)
        try:
            keys = self.cdn_repository_manager.get_repository_crypto_keys(repo_source['relative_url'])
        except CdnRepositoryNotFoundError:
            return repo_plugin
        if len(keys) >= 1:
            repo_plugin.set_ssl_options(str(keys[0]['ca_cert'][1]), str(keys[0]['client_cert'][1]),
                                        str(keys[0]['client_key'][1]))
        else:
            log2(0, 1, "ERROR: No valid SSL certificates were found for repository '%s'."
                 % repo_source['relative_url'], stream=sys.stderr)
        return repo_plugin

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
                                 fail=False,
                                 filters=False,
                                 no_packages=self.no_packages,
                                 no_errata=self.no_errata,
                                 sync_kickstart=(not self.no_kickstarts),
                                 force_kickstart=self.force_kickstarts,
                                 latest=False,
                                 metadata_only=self.no_rpms,
                                 excluded_urls=excluded_urls,
                                 strict=self.consider_full,
                                 log_dir="cdnsync",
                                 log_level=self.log_level,
                                 check_ssl_dates=True)
        sync.set_ks_tree_type('rhn-managed')
        if kickstart_trees:
            # Assuming all trees have same install type
            sync.set_ks_install_type(kickstart_trees[0]['ks_install_type'])
        sync.set_urls_prefix(self.mount_point)
        return sync.sync()

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
        error_messages = []
        total_time = timedelta()
        for channel in channels:
            cur_time, failed_packages = self._sync_channel(channel)
            if failed_packages < 0:
                error_messages.append("Problems occurred during syncing channel %s. Please check "
                                      "/var/log/rhn/cdnsync/%s.log for the details\n" % (channel, channel))
            if failed_packages > 0:
                error_messages.append("%d packages in channel %s failed to sync. Please check "
                                      "/var/log/rhn/cdnsync/%s.log for the details\n" % (failed_packages, channel,
                                                                                         channel))
            total_time += cur_time
            # Switch back to cdnsync log
            rhnLog.initLOG(self.log_path, self.log_level)
            log2disk(0, "Sync of channel completed.")
        log(0, "Total time: %s" % str(total_time).split('.')[0])
        return error_messages

    def count_packages(self, channels=None):
        start_time = datetime.now()
        channel_tree, not_available_channels = self._list_available_channels()

        # Collect all channels
        channel_list = []
        for base_channel in channel_tree:
            channel_list.extend(channel_tree[base_channel])
            if base_channel not in not_available_channels:
                channel_list.append(base_channel)

        # Only some channels specified by parameter
        if channels:
            channel_list = [c for c in channel_list if c in channels]

        log(0, "Number of channels: %d" % len(channel_list))

        # Prepare repositories
        repo_tree = {}
        repository_count = 0
        for channel in channel_list:
            sources = self.cdn_repository_manager.get_content_sources(channel)
            repository_count += len(sources)
            repo_tree[channel] = sources
        log(0, "Number of repositories: %d" % repository_count)

        downloader = ThreadedDownloader()
        for channel in repo_tree:
            for source in repo_tree[channel]:
                yum_repo = self._create_yum_repo(source)
                params = {}
                yum_repo.set_download_parameters(params, "repodata/repomd.xml",
                                                 os.path.join(yum_repo.repo.basecachedir,
                                                              yum_repo.name, "repomd.xml.new"))
                downloader.add(params)

        progress_bar = ProgressBarLogger("Downloading repomd:  ", repository_count)
        downloader.set_log_obj(progress_bar)
        # Overwrite existing files
        downloader.set_force(True)
        log2disk(0, "Downloading repomd started.")
        downloader.run()
        log2disk(0, "Downloading repomd finished.")

        progress_bar = ProgressBarLogger("Comparing repomd:    ", len(repo_tree))
        to_download_count = 0
        repo_tree_to_update = {}
        log2disk(0, "Comparing repomd started.")
        for channel in repo_tree:
            cdn_repodata_path = os.path.join(constants.CDN_REPODATA_ROOT, channel)
            packages_num_path = os.path.join(cdn_repodata_path, "packages_num")
            packages_size_path = os.path.join(cdn_repodata_path, "packages_size")

            sources = repo_tree[channel]
            yum_repos = [self._create_yum_repo(source) for source in sources]

            # packages_num file exists and all cached repomd files are up to date => skip
            if os.path.isfile(packages_num_path) and os.path.isfile(packages_size_path) and all(
                    [x.repomd_up_to_date() for x in yum_repos]):
                progress_bar.log(True, None)
                continue

            update_channel = False
            for yum_repo in yum_repos:
                # use new repomd
                new_repomd = os.path.join(yum_repo.repo.basecachedir, yum_repo.name, "repomd.xml.new")
                if os.path.isfile(new_repomd):
                    update_channel = True
                    os.rename(new_repomd,
                              os.path.join(yum_repo.repo.basecachedir, yum_repo.name, "repomd.xml"))
                else:
                    # it wasn't downloaded
                    continue

                for path, checksum_pair in yum_repo.get_metadata_paths():
                    params = {}
                    yum_repo.set_download_parameters(params, path,
                                                     os.path.join(yum_repo.repo.basecachedir, yum_repo.name,
                                                                  os.path.basename(path)),
                                                     checksum_type=checksum_pair[0], checksum_value=checksum_pair[1])
                    downloader.add(params)
                    to_download_count += 1

            # If there is at least one repo with new repomd, pass through this channel
            if update_channel:
                repo_tree_to_update[channel] = sources

            progress_bar.log(True, None)
        log2disk(0, "Comparing repomd finished.")

        progress_bar = ProgressBarLogger("Downloading metadata:", to_download_count)
        downloader.set_log_obj(progress_bar)
        downloader.set_force(False)
        log2disk(0, "Downloading metadata started.")
        downloader.run()
        log2disk(0, "Downloading metadata finished.")

        progress_bar = ProgressBarLogger("Counting packages:   ", len(repo_tree_to_update))
        log2disk(0, "Counting packages started.")
        for channel in repo_tree_to_update:
            cdn_repodata_path = os.path.join(constants.CDN_REPODATA_ROOT, channel)
            packages_num_path = os.path.join(cdn_repodata_path, "packages_num")
            packages_size_path = os.path.join(cdn_repodata_path, "packages_size")

            sources = repo_tree_to_update[channel]
            yum_repos = [self._create_yum_repo(source) for source in sources]

            packages = {}
            for yum_repo in yum_repos:
                for pkg in yum_repo.raw_list_packages():
                    nvrea = str(pkg)
                    packages[nvrea] = pkg.packagesize

            # create directory for repo data if it doesn't exist
            try:
                os.makedirs(cdn_repodata_path)
            except OSError:
                exc = sys.exc_info()[1]
                if exc.errno == errno.EEXIST and os.path.isdir(cdn_repodata_path):
                    pass
                else:
                    raise
            f_num_out = open(packages_num_path, 'w')
            f_size_out = open(packages_size_path, 'w')
            try:
                f_num_out.write(str(len(packages)))
                f_size_out.write(str(sum(packages.values())))
            finally:
                if f_num_out is not None:
                    f_num_out.close()
                if f_size_out is not None:
                    f_size_out.close()
            # Delete cache to save space
            for yum_repo in yum_repos:
                yum_repo.clear_cache(keep_repomd=True)
            progress_bar.log(True, None)
        log2disk(0, "Counting packages finished.")

        end_time = datetime.now()
        log(0, "Total time: %s" % str(end_time - start_time).split('.')[0])

    def print_channel_tree(self, repos=False):
        channel_tree, not_available_channels = self._list_available_channels()

        if not channel_tree:
            log2(0, 0, "No available channels were found. Is your %s activated for CDN?"
                 % PRODUCT_NAME, stream=sys.stderr)
            return

        log(0, "p = previously imported/synced channel")
        log(0, ". = channel not yet imported/synced")
        log(0, "? = package count not available (try to run cdn-sync --count-packages)")

        log(0, "Base channels:")
        available_base_channels = [x for x in sorted(channel_tree) if x not in not_available_channels]
        if not available_base_channels:
            log(0, "      NONE")

        longest_label = len(max(available_base_channels + [i for l in channel_tree.values() for i in l], key=len or ""))
        for channel in available_base_channels:
            if channel in self.synced_channels:
                status = 'p'
            else:
                status = '.'

            try:
                packages_number = open(constants.CDN_REPODATA_ROOT + '/' + channel + "/packages_num", 'r').read()
            # pylint: disable=W0703
            except Exception:
                packages_number = '?'

            try:
                packages_size = open(constants.CDN_REPODATA_ROOT + '/' + channel + "/packages_size", 'r').read()
                packages_size = human_readable_size(int(packages_size))
            # pylint: disable=W0703
            except Exception:
                packages_size = '?B'

            packages_size = "(%s)" % packages_size
            space = " "
            offset = longest_label - len(channel)
            space += " " * offset

            log(0, "    %s %s%s%6s packages %9s" % (status, channel, space, packages_number, packages_size))
            sources = self.cdn_repository_manager.get_content_sources(channel)
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

                    try:
                        packages_number = open(constants.CDN_REPODATA_ROOT + '/' + child + "/packages_num", 'r').read()
                    # pylint: disable=W0703
                    except Exception:
                        packages_number = '?'

                    try:
                        packages_size = open(constants.CDN_REPODATA_ROOT + '/' + child + "/packages_size", 'r').read()
                        packages_size = human_readable_size(int(packages_size))
                    # pylint: disable=W0703
                    except Exception:
                        packages_size = '?B'

                    packages_size = "(%s)" % packages_size
                    space = " "
                    offset = longest_label - len(child)
                    space += " " * offset

                    log(0, "    %s %s%s%6s packages %9s" % (status, child, space, packages_number, packages_size))
                    if repos:
                        sources = self.cdn_repository_manager.get_content_sources(child)
                        if sources:
                            for source in sources:
                                log(0, "        %s" % source['relative_url'])
                        else:
                            log(0, "        No CDN source provided!")

    @staticmethod
    def clear_cache():
        # Clear packages outside channels from DB and disk
        contentRemove.delete_outside_channels(None)
        if os.path.isdir(constants.PACKAGE_STAGE_DIRECTORY):
            log(0, "Cleaning package stage directory.")
            for pkg in os.listdir(constants.PACKAGE_STAGE_DIRECTORY):
                os.unlink(os.path.join(constants.PACKAGE_STAGE_DIRECTORY, pkg))

    def print_cdn_certificates_info(self):
        h = rhnSQL.prepare("""
            SELECT ck.id, ck.description, ck.key
            FROM rhnCryptoKeyType ckt,
                 rhnCryptoKey ck
            WHERE ckt.label = 'SSL'
              AND ckt.id = ck.crypto_key_type_id
              AND ck.description LIKE 'CDN_%'
              AND ck.org_id is NULL
            ORDER BY ck.description
        """)
        h.execute()
        keys = h.fetchall_dict() or []
        if not keys:
            log2(0, 0, "No SSL certificates were found. Is your %s activated for CDN?"
                 % PRODUCT_NAME, stream=sys.stderr)
            return

        for key in keys:
            log(0, "======================================")
            log(0, "| Certificate/Key: %s" % key['description'])
            log(0, "======================================")
            if constants.CA_CERT_NAME == key['description'] or constants.CLIENT_CERT_PREFIX in key['description']:
                if not verify_certificate_dates(str(key['key'])):
                    log(0, "WARNING: This certificate is not valid.")
                cn, serial_number, not_before, not_after = get_certificate_info(str(key['key']))
                log(0, "Common name:   %s" % str(cn))
                log(0, "Serial number: %s" % str(serial_number))
                log(0, "Valid from:    %s" % str(not_before))
                log(0, "Valid to:      %s" % str(not_after))
            if constants.CLIENT_CERT_PREFIX in key['description']:
                manager = CdnRepositoryManager(client_cert_id=int(key['id']))
                self.cdn_repository_manager = manager
                log(0, "Provided channels (*), assigned repositories (>):")
                channel_tree, not_available_channels = self._list_available_channels()
                if not channel_tree:
                    log(0, "    NONE")
                for base_channel in sorted(channel_tree):
                    if base_channel not in not_available_channels:
                        log(0, "    * %s" % base_channel)
                        sources = self.cdn_repository_manager.get_content_sources(base_channel)
                        sources = [source['relative_url'] for source in sources]
                        for source in sorted(sources):
                            log(0, "        > %s" % source)
                    elif channel_tree[base_channel]:
                        log(0, "    * %s (base channel not provided)" % base_channel)
                    for child_channel in sorted(channel_tree[base_channel]):
                        log(0, "        * %s" % child_channel)
                        sources = self.cdn_repository_manager.get_content_sources(child_channel)
                        sources = [source['relative_url'] for source in sources]
                        for source in sorted(sources):
                            log(0, "            > %s" % source)
            log(0, "")
