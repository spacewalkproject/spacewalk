# Copyright (c) 2016--2018 Red Hat, Inc.
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
import fnmatch
from datetime import datetime, timedelta

import constants
from spacewalk.common.rhnConfig import CFG, initCFG, PRODUCT_NAME
from spacewalk.common import rhnLog
from spacewalk.server import rhnSQL
from spacewalk.server.rhnChannel import channel_info
from spacewalk.server.importlib.backendOracle import SQLBackend
from spacewalk.server.importlib.contentSourcesImport import ContentSourcesImport
from spacewalk.server.importlib.channelImport import ChannelImport
from spacewalk.server.importlib.productNamesImport import ProductNamesImport
from spacewalk.server.importlib.importLib import Channel, ChannelFamily, \
    ProductName, DistChannelMap, ReleaseChannelMap
from spacewalk.satellite_tools import reposync
from spacewalk.satellite_tools import contentRemove
from spacewalk.satellite_tools.download import ThreadedDownloader, ProgressBarLogger
from spacewalk.satellite_tools.satCerts import get_certificate_info, verify_certificate_dates
from spacewalk.satellite_tools.syncLib import log, log2disk, log2, initEMAIL_LOG, log2email, log2background
from spacewalk.satellite_tools.repo_plugins import yum_src

from common import CustomChannelSyncError, CountingPackagesError, verify_mappings, human_readable_size
from repository import CdnRepositoryManager, CdnRepositoryNotFoundError


class CdnSync(object):
    """Main class of CDN sync run."""

    log_path = '/var/log/rhn/cdnsync.log'

    def __init__(self, no_packages=False, no_errata=False, no_rpms=False, no_kickstarts=False,
                 log_level=None, mount_point=None, consider_full=False, force_kickstarts=False,
                 force_all_errata=False, email=False, import_batch_size=None):

        if log_level is None:
            log_level = 0
        self.log_level = log_level
        CFG.set('DEBUG', log_level)
        self.email = email
        if self.email:
            initEMAIL_LOG()
        rhnLog.initLOG(self.log_path, self.log_level)
        log2disk(0, "Command: %s" % str(sys.argv))

        rhnSQL.initDB()
        initCFG('server.satellite')

        self.cdn_repository_manager = CdnRepositoryManager(mount_point)
        self.no_packages = no_packages
        self.no_errata = no_errata
        self.no_rpms = no_rpms
        if self.no_packages and self.no_rpms:
            log(0, "Parameter --no-rpms has no effect.")
        self.no_kickstarts = no_kickstarts
        self.force_all_errata = force_all_errata
        self.force_kickstarts = force_kickstarts
        if self.no_kickstarts and self.force_kickstarts:
            log(0, "Parameter --force-kickstarts has no effect.")

        if mount_point:
            self.mount_point = "file://" + mount_point
            self.consider_full = consider_full
        else:
            self.mount_point = CFG.CDN_ROOT
            self.consider_full = True

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
                log(1, "Ignoring channel mappings: %s" % e)
                self.families = {}
                self.channel_metadata = {}
                self.channel_dist_mapping = {}
                self.kickstart_metadata = {}
        finally:
            if f is not None:
                f.close()

        # Map channels to their channel family
        self.channel_to_family = {}
        for family in self.families:
            for channel in self.families[family]['channels']:
                self.channel_to_family[channel] = family

        # Set already synced channels, entitled null-org channels and custom channels with associated
        # CDN repositories
        h = rhnSQL.prepare("""
            select distinct c.label, c.org_id
            from rhnChannelFamilyPermissions cfp inner join
                 rhnChannelFamily cf on cfp.channel_family_id = cf.id inner join
                 rhnChannelFamilyMembers cfm on cf.id = cfm.channel_family_id inner join
                 rhnChannel c on cfm.channel_id = c.id
            where c.org_id is null
              or (c.org_id is not null and 
                  exists (
                          select cs.id
                          from rhnContentSource cs inner join
                               rhnChannelContentSource ccs on ccs.source_id = cs.id
                          where ccs.channel_id = c.id
                            and cs.org_id is null
                         )
                 )
            order by c.org_id nulls first, label
        """)
        h.execute()
        channels = h.fetchall_dict() or []
        self.synced_channels = {}
        for channel in channels:
            # Custom channel repositories not available, don't mark as synced
            if channel['org_id']:
                repos = self.cdn_repository_manager.list_associated_repos(channel['label'])
                if not all([self.cdn_repository_manager.check_repository_availability(r) for r in repos]):
                    continue
            self.synced_channels[channel['label']] = channel['org_id']

        # Select available channel families from DB
        h = rhnSQL.prepare("""
            select distinct label
            from rhnChannelFamilyPermissions cfp inner join
                 rhnChannelFamily cf on cfp.channel_family_id = cf.id
            where cf.org_id is null
        """)
        h.execute()
        families = h.fetchall_dict() or []
        self.entitled_families = [f['label'] for f in families]
        self.import_batch_size = import_batch_size

    def _tree_available_channels(self):
        # collect all channel from available families
        all_channels = []
        channel_tree = {}
        # Not available parents of child channels
        not_available_channels = []
        for label in self.entitled_families:
            try:
                family = self.families[label]
            except KeyError:
                log2(2, 2, "WARNING: Can't find channel family in mappings: %s" % label, stream=sys.stderr)
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

    def _list_available_channels(self):
        channel_tree, not_available_channels = self._tree_available_channels()
        # Collect all channels
        channel_list = []
        for base_channel in channel_tree:
            channel_list.extend(channel_tree[base_channel])
            if base_channel not in not_available_channels:
                channel_list.append(base_channel)
        return channel_list

    def _can_add_repos(self, db_channel, repos):
        # Adding custom repositories to custom channel, need to check:
        # 1. Repositories availability - if there are SSL certificates for them
        # 2. Channel is custom
        # 3. Repositories are not already associated with any channels in mapping files
        if not db_channel or not db_channel['org_id']:
            log2(0, 0, "ERROR: Channel doesn't exist or is not custom.", stream=sys.stderr)
            return False
        # Repositories can't be part of any channel from mappings
        channels = []
        for repo in repos:
            channels.extend(self.cdn_repository_manager.list_channels_containing_repository(repo))
        if channels:
            log2(0, 0, "ERROR: Specified repositories can't be synced because they are part of following channels: %s" %
                 ", ".join(channels), stream=sys.stderr)
            return False
        # Check availability of repositories
        not_available = []
        for repo in repos:
            if not self.cdn_repository_manager.check_repository_availability(repo):
                not_available.append(repo)
        if not_available:
            log2(0, 0, "ERROR: Following repositories are not available: %s" % ", ".join(not_available),
                 stream=sys.stderr)
            return False
        return True

    def _is_channel_available(self, label):
        # Checking channel availability, it means either:
        # 1. Trying to sync custom channel - in this case, it has to have already associated CDN repositories,
        #    it's ensured by query populating synced_channels variable
        # 2. Trying to sync channel from mappings - it may not exists so we check requirements from mapping files
        db_channel = channel_info(label)
        if db_channel and db_channel['org_id']:
            # Custom channel doesn't have any null-org repositories assigned
            if label not in self.synced_channels:
                log2(0, 0, "ERROR: Custom channel '%s' doesn't contain any CDN repositories." % label,
                     stream=sys.stderr)
                return False
        else:
            if label not in self.channel_metadata:
                log2(1, 1, "WARNING: Channel '%s' not found in channel metadata mapping." % label, stream=sys.stderr)
                return False
            elif label not in self.channel_to_family:
                log2(0, 0, "ERROR: Channel '%s' not found in channel family mapping." % label, stream=sys.stderr)
                return False
            family = self.channel_to_family[label]
            if family not in self.entitled_families:
                log2(0, 0, "ERROR: Channel family '%s' containing channel '%s' is not entitled." % (family, label),
                     stream=sys.stderr)
                return False
            elif not self.cdn_repository_manager.check_channel_availability(label, self.no_kickstarts):
                log2(0, 0, "ERROR: Channel '%s' repositories are not available." % label, stream=sys.stderr)
                return False
        return True

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
        try:
            keys = self.cdn_repository_manager.get_repository_crypto_keys(repo_source['relative_url'])
        except CdnRepositoryNotFoundError:
            keys = []
            log2(1, 1, "WARNING: Repository '%s' was not found." % repo_source['relative_url'], stream=sys.stderr)
        if keys:
            (ca_cert_file, client_cert_file, client_key_file) = reposync.write_ssl_set_cache(
                keys[0]['ca_cert'], keys[0]['client_cert'], keys[0]['client_key'])
        else:
            (ca_cert_file, client_cert_file, client_key_file) = (None, None, None)
            log2(1, 1, "WARNING: No valid SSL certificates were found for repository '%s'."
                 % repo_source['relative_url'], stream=sys.stderr)
        return yum_src.ContentSource(self.mount_point + str(repo_source['relative_url']),
                                     str(repo_label), org=None, no_mirrors=True,
                                     ca_cert_file=ca_cert_file, client_cert_file=client_cert_file,
                                     client_key_file=client_key_file)

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

        # Print note if channel is already EOL
        if self._is_channel_eol(channel):
            log(0, "NOTE: This channel reached end-of-life on %s." %
                datetime.strptime(self.channel_metadata[channel]['eol'], "%Y-%m-%d %H:%M:%S").strftime("%Y-%m-%d"))

        log(0, "Sync of channel started.")
        log2disk(0, "Please check 'cdnsync/%s.log' for sync log of this channel." % channel, notimeYN=True)
        sync = reposync.RepoSync(channel,
                                 repo_type="yum",
                                 url=None,
                                 fail=False,
                                 filters=False,
                                 no_packages=self.no_packages,
                                 no_errata=self.no_errata,
                                 sync_kickstart=(not self.no_kickstarts),
                                 force_all_errata=self.force_all_errata,
                                 force_kickstart=self.force_kickstarts,
                                 latest=False,
                                 metadata_only=self.no_rpms,
                                 excluded_urls=excluded_urls,
                                 strict=self.consider_full,
                                 log_dir="cdnsync",
                                 log_level=self.log_level,
                                 check_ssl_dates=True,
                                 force_null_org_content=True)
        sync.set_ks_tree_type('rhn-managed')
        if self.import_batch_size:
            sync.set_import_batch_size(self.import_batch_size)
        if kickstart_trees:
            # Assuming all trees have same install type
            sync.set_ks_install_type(kickstart_trees[0]['ks_install_type'])
        sync.set_urls_prefix(self.mount_point)
        return sync.sync()

    def sync(self, channels=None):
        # If no channels specified, sync already synced channels
        if not channels:
            channels = set(self.synced_channels)

        # Check channel availability before doing anything
        not_available = set()
        available = set()
        all_channel_list = None
        for channel in channels:
            # Try to expand wildcards in channel labels
            if '*' in channel or '?' in channel or '[' in channel:
                if all_channel_list is None:
                    all_channel_list = self._list_available_channels() + [c for c in self.synced_channels
                                                                          if self.synced_channels[c]]
                expanded = fnmatch.filter(all_channel_list, channel)
                log(2, "Expanding channel '%s' to: %s" % (channel, ", ".join(expanded)))
                if expanded:
                    for expanded_channel in expanded:
                        if not self._is_channel_available(expanded_channel):
                            not_available.add(expanded_channel)
                        else:
                            available.add(expanded_channel)
                else:
                    not_available.add(channel)
            elif not self._is_channel_available(channel):
                not_available.add(channel)
            else:
                available.add(channel)

        channels = available

        error_messages = []

        # if we have not_available channels log the error immediately
        if not_available:
            msg = "ERROR: these channels either do not exist or are not available for synchronization:\n  " + \
                  "\n  ".join(not_available)
            error_messages.append(msg)

        # BZ 1434913 - let user know if system is not activated if no available channels
        if not available:
            error_messages.extend(self._msg_array_if_not_activated())

        # Need to update channel metadata
        self._update_channels_metadata([ch for ch in channels if ch in self.channel_metadata])
        # Make sure custom channels are properly connected with repos
        for channel in channels:
            if channel in self.synced_channels and self.synced_channels[channel]:
                self.cdn_repository_manager.assign_repositories_to_channel(channel)

        reposync.clear_ssl_cache()

        # Finally, sync channel content
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

    def setup_repos_and_sync(self, channels=None, add_repos=None, delete_repos=None):
        # Fix format of relative url
        if add_repos:
            repos = set()
            for repo in add_repos:
                repo = repo.replace(CFG.CDN_ROOT, '')
                repo_dirs = self.cdn_repository_manager.repository_tree.normalize_url(repo)
                repo = os.path.join('/', '/'.join(repo_dirs))
                repos.add(repo)
            add_repos = list(repos)
        if delete_repos:
            repos = set()
            for repo in delete_repos:
                repo = repo.replace(CFG.CDN_ROOT, '')
                repo_dirs = self.cdn_repository_manager.repository_tree.normalize_url(repo)
                repo = os.path.join('/', '/'.join(repo_dirs))
                repos.add(repo)
            delete_repos = list(repos)
        # We need single custom channel
        if not channels or len(channels) > 1:
            raise CustomChannelSyncError("Single custom channel needed.")
        channel = list(channels)[0]
        db_channel = channel_info(channel)
        if add_repos and not self._can_add_repos(db_channel, add_repos):
            raise CustomChannelSyncError("Unable to attach requested repositories to this channel.")
        # Add custom repositories to custom channel
        changed = self.cdn_repository_manager.assign_repositories_to_channel(channel, delete_repos=delete_repos,
                                                                             add_repos=add_repos)
        # Add to synced channels and sync if there are any changed repos
        if changed and channel not in self.synced_channels:
            self.synced_channels[channel] = db_channel['org_id']
        return self.sync(channels=channels)

    def count_packages(self, channels=None):
        start_time = datetime.now()
        reposync.clear_ssl_cache()
        # Both entitled channels and custom channels with null-org repositories.
        channel_list = self._list_available_channels()
        if not channel_list:
            error_messages = self._msg_array_if_not_activated()
            if error_messages:
                log(0, "\n".join(error_messages))
                sys.exit(1)
        channel_list.extend([c for c in self.synced_channels if self.synced_channels[c]])

        # Only some channels specified by parameter
        if channels:
            new_channel_list = []
            for channel in channels:
                new_channel_list.extend(fnmatch.filter(channel_list, channel))
            channel_list = list(set(new_channel_list))

        log(0, "Number of channels: %d" % len(channel_list))

        # Prepare repositories
        repo_tree = {}
        repository_count = 0
        for channel in channel_list:
            sources = self.cdn_repository_manager.get_content_sources(channel)
            # Custom channel
            if not sources:
                repos = self.cdn_repository_manager.list_associated_repos(channel)
                sources = []
                for index, repo in enumerate(sorted(repos)):
                    repo_label = "%s-%d" % (channel, index)
                    sources.append({'relative_url': repo, 'pulp_repo_label_v2': repo_label})
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
        log2background(0, "Downloading repomd started.")
        downloader.run()
        log2background(0, "Downloading repomd finished.")

        progress_bar = ProgressBarLogger("Comparing repomd:    ", len(repo_tree))
        to_download_count = 0
        repo_tree_to_update = {}
        log2background(0, "Comparing repomd started.")

        is_missing_repomd = False
        for channel in repo_tree:
            cdn_repodata_path = os.path.join(constants.CDN_REPODATA_ROOT, channel)
            packages_num_path = os.path.join(cdn_repodata_path, "packages_num")
            packages_size_path = os.path.join(cdn_repodata_path, "packages_size")

            sources = repo_tree[channel]
            yum_repos = [self._create_yum_repo(source) for source in sources]

            # check all repomd files were downloaded
            for yum_repo in yum_repos:
                new_repomd = os.path.join(yum_repo.repo.basecachedir, yum_repo.name, "repomd.xml.new")
                if not os.path.isfile(new_repomd):
                    is_missing_repomd = True

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
        log2background(0, "Comparing repomd finished.")

        progress_bar = ProgressBarLogger("Downloading metadata:", to_download_count)
        downloader.set_log_obj(progress_bar)
        downloader.set_force(False)
        log2background(0, "Downloading metadata started.")
        downloader.run()
        log2background(0, "Downloading metadata finished.")

        progress_bar = ProgressBarLogger("Counting packages:   ", len(repo_tree_to_update))
        log2background(0, "Counting packages started.")
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
        log2background(0, "Counting packages finished.")

        end_time = datetime.now()
        log(0, "Total time: %s" % str(end_time - start_time).split('.')[0])
        if is_missing_repomd:
            raise CountingPackagesError("Cannot download some repomd.xml files. "
                                        "Please, check /var/log/rhn/cdnsync.log for details")

    def _channel_line_format(self, channel, longest_label):
        if self._is_channel_eol(channel):
            eol_status = "EOL"
        else:
            eol_status = ""
        if channel in self.synced_channels:
            sync_status = 'p'
        else:
            sync_status = '.'
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

        return "%3s %s %s%s%6s packages %9s" % (eol_status, sync_status, channel, space,
                                                packages_number, packages_size)

    def _is_channel_eol(self, channel):
        if channel in self.channel_metadata:
            if 'eol' in self.channel_metadata[channel] and self.channel_metadata[channel]['eol']:
                if datetime.now() > datetime.strptime(self.channel_metadata[channel]['eol'], "%Y-%m-%d %H:%M:%S"):
                    return True
        return False

    def _print_unmapped_channels(self):
        unmapped_channels = [ch for ch in self.synced_channels if not self.synced_channels[ch]
                             and ch not in self.channel_metadata]
        if unmapped_channels:
            log(0, "Previously synced channels not available to update from CDN:")
            for channel in sorted(unmapped_channels):
                log(0, "    p %s" % channel)

    def print_channel_tree(self, repos=False):
        channel_tree, not_available_channels = self._tree_available_channels()

        if not channel_tree:
            error_messages = self._msg_array_if_not_activated()
            if not error_messages:
                log(0, "WARNING: No available channels from channel mappings were found. "
                       "Is %s package installed?" % constants.MAPPINGS_RPM_NAME)
            else:
                log(0, "\n".join(error_messages))
                sys.exit(1)

        available_base_channels = [x for x in sorted(channel_tree) if x not in not_available_channels]
        custom_cdn_channels = [ch for ch in self.synced_channels if self.synced_channels[ch]]
        longest_label = len(max(available_base_channels + custom_cdn_channels +
                                [i for l in channel_tree.values() for i in l] + [""], key=len))

        log(0, "p = previously imported/synced channel")
        log(0, ". = channel not yet imported/synced")
        log(0, "? = package count not available (try to run cdn-sync --count-packages)")
        log(0, "EOL = channel reached end-of-life")

        log(0, "Entitled base channels:")
        if not available_base_channels:
            log(0, "      NONE")
        for channel in available_base_channels:
            log(0, "%s" % self._channel_line_format(channel, longest_label))
            if repos:
                sources = self.cdn_repository_manager.get_content_sources(channel)
                paths = [s['relative_url'] for s in sources]
                for path in sorted(paths):
                    log(0, "        %s" % path)

        log(0, "Entitled child channels:")
        if not (any([channel_tree[ch] for ch in channel_tree])):
            log(0, "      NONE")
        # print information about child channels
        for channel in sorted(channel_tree):
            # Print only if there are any child channels
            if channel_tree[channel]:
                log(0, "%s:" % channel)
                for child in sorted(channel_tree[channel]):
                    log(0, "%s" % self._channel_line_format(child, longest_label))
                    if repos:
                        sources = self.cdn_repository_manager.get_content_sources(child)
                        paths = [s['relative_url'] for s in sources]
                        for path in sorted(paths):
                            log(0, "        %s" % path)

        # Not-null org_id channels
        log(0, "Custom channels syncing from CDN:")
        if not custom_cdn_channels:
            log(0, "      NONE")
        for channel in sorted(custom_cdn_channels):
            log(0, "%s" % self._channel_line_format(channel, longest_label))
            if repos:
                paths = self.cdn_repository_manager.list_associated_repos(channel)
                for path in sorted(paths):
                    log(0, "        %s" % path)

        # Previously synced null-org channels not available in cdn-sync-mappings
        self._print_unmapped_channels()

    def clear_cache(self):
        # Clear packages outside channels from DB and disk
        log(0, "Cleaning imported packages outside channels.")
        contentRemove.delete_outside_channels(None)
        if os.path.isdir(constants.PACKAGE_STAGE_DIRECTORY):
            log(0, "Cleaning package stage directory.")
            for pkg in os.listdir(constants.PACKAGE_STAGE_DIRECTORY):
                os.unlink(os.path.join(constants.PACKAGE_STAGE_DIRECTORY, pkg))
        log(0, "Cleaning orphaned CDN repositories in DB.")
        self.cdn_repository_manager.cleanup_orphaned_repos()

    @staticmethod
    def _get_cdn_certificate_keys_and_certs():
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
        return h.fetchall_dict() or []

    def print_cdn_certificates_info(self, repos=False):
        keys = self._get_cdn_certificate_keys_and_certs()
        if not keys:
            log2(0, 0, "No SSL certificates were found. Is your %s activated for CDN?"
                 % PRODUCT_NAME, stream=sys.stderr)
            sys.exit(1)

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
                log(0, "Provided channels:")
                channel_tree, not_available_channels = self._tree_available_channels()
                if not channel_tree:
                    log(0, "    NONE")
                for base_channel in sorted(channel_tree):
                    if base_channel not in not_available_channels:
                        log(0, "    * %s" % base_channel)
                    elif channel_tree[base_channel]:
                        log(0, "    * %s (only child channels provided)" % base_channel)
                    for child_channel in sorted(channel_tree[base_channel]):
                        log(0, "        * %s" % child_channel)
                if repos:
                    log(0, "Provided repositories:")
                    provided_repos = self.cdn_repository_manager.list_provided_repos(key['id'])
                    for repo in sorted(provided_repos):
                        log(0, "    %s" % repo)
            log(0, "")

    def print_eol_channel_list(self):
        available_channels = self._list_available_channels()

        # Filter only channels with EOL date defined
        eol_channels = {}
        for channel in available_channels:
            if 'eol' in self.channel_metadata[channel] and self.channel_metadata[channel]['eol']:
                eol_channels[channel] = datetime.strptime(self.channel_metadata[channel]['eol'], "%Y-%m-%d %H:%M:%S")

        if eol_channels:
            longest_label = len(max(eol_channels, key=len))
        else:
            longest_label = 0

        already_eol_channels = []
        notyet_eol_channels = []

        # Split into 2 channel groups based on current date
        for channel in eol_channels:
            if datetime.now() > eol_channels[channel]:
                already_eol_channels.append(channel)
            else:
                notyet_eol_channels.append(channel)

        # Print these channel groups, sorted by date
        def print_channel_line(ch):
            if ch in self.synced_channels:
                sync_status = 'p'
            else:
                sync_status = '.'
            space = " "
            offset = longest_label - len(ch)
            space += " " * offset
            log(0, "    %s %s%s%s" % (sync_status, channel, space, eol_channels[channel].strftime("%Y-%m-%d")))

        log(0, "p = previously imported/synced channel")
        log(0, ". = channel not yet imported/synced")
        log(0, "Channels reached end-of-life already:")
        if not already_eol_channels:
            log(0, "      NONE")
        for channel in sorted(already_eol_channels, key=lambda channel: eol_channels[channel]):
            print_channel_line(channel)
        log(0, "Channels not reached end-of-life yet:")
        if not notyet_eol_channels:
            log(0, "      NONE")
        for channel in sorted(notyet_eol_channels, key=lambda channel: eol_channels[channel]):
            print_channel_line(channel)

        # Previously synced null-org channels not available in cdn-sync-mappings
        self._print_unmapped_channels()

    def _msg_array_if_not_activated(self):
        error_messages = []
        keys = self._get_cdn_certificate_keys_and_certs()
        if not keys:
            error_messages.append("ERROR: Your %s is not activated for CDN\n"
                                  "(to see details about currently used SSL certificates for accessing CDN:"
                                  " /usr/bin/cdn-sync --cdn-certs)" % PRODUCT_NAME)
        else:
            found_valid_key = False
            for key in keys:
                if not found_valid_key:
                    if (constants.CA_CERT_NAME == key['description']
                            or constants.CLIENT_CERT_PREFIX in key['description']):
                        if verify_certificate_dates(str(key['key'])):
                            found_valid_key = True
            if not found_valid_key:
                error_messages.append("ERROR: Your %s has no valid SSL certificates for accessing CDN\n"
                                      "(to see details about currently used SSL certificates for accessing CDN:"
                                      " /usr/bin/cdn-sync --cdn-certs)" % PRODUCT_NAME)
        return error_messages

    # Append additional messages and send email
    def send_email(self, additional_messages):
        if self.email:
            if additional_messages:
                log2email(0, '\n'.join(additional_messages), cleanYN=1, notimeYN=1)
            reposync.send_mail(sync_type="CDN")
