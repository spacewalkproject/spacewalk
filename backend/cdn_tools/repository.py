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

import os
import sys
import json

from spacewalk.server import rhnSQL
from spacewalk.server.importlib.backendOracle import SQLBackend
from spacewalk.server.importlib.contentSourcesImport import ContentSourcesImport
from spacewalk.satellite_tools.satCerts import verify_certificate_dates
from spacewalk.satellite_tools.syncLib import log, log2
from spacewalk.server.importlib.importLib import ContentSource, ContentSourceSsl

import constants


class CdnRepositoryManager(object):
    """Class managing CDN repositories, connected channels etc."""

    def __init__(self, local_mount_point=None, client_cert_id=None):
        rhnSQL.initDB()
        self.local_mount_point = local_mount_point
        self.repository_tree = CdnRepositoryTree()
        self._populate_repository_tree(client_cert_id=client_cert_id)
        self.excluded_urls = []

        f = None
        try:
            try:
                # Channel to repositories mapping
                f = open(constants.CONTENT_SOURCE_MAPPING_PATH, 'r')
                self.content_source_mapping = json.load(f)
                f.close()

                # Channel to kickstart repositories mapping
                f = open(constants.KICKSTART_SOURCE_MAPPING_PATH, 'r')
                self.kickstart_source_mapping = json.load(f)
                f.close()

                # Kickstart metadata
                f = open(constants.KICKSTART_DEFINITIONS_PATH, 'r')
                self.kickstart_metadata = json.load(f)
                f.close()
            except IOError:
                e = sys.exc_info()[1]
                log(1, "Ignoring channel mappings: %s" % e)
                self.content_source_mapping = {}
                self.kickstart_source_mapping = {}
                self.kickstart_metadata = {}
        finally:
            if f is not None:
                f.close()

        self.__init_repository_to_channels_mapping()

    # Map repositories to channels
    def __init_repository_to_channels_mapping(self):
        self.repository_to_channels = {}
        for channel in self.content_source_mapping:
            for source in self.content_source_mapping[channel]:
                relative_url = source['relative_url']
                if relative_url in self.repository_to_channels:
                    self.repository_to_channels[relative_url].append(channel)
                else:
                    self.repository_to_channels[relative_url] = [channel]

        for channel in self.kickstart_metadata:
            for tree in self.kickstart_metadata[channel]:
                tree_label = tree['ks_tree_label']
                if tree_label in self.kickstart_source_mapping:
                    relative_url = self.kickstart_source_mapping[tree_label][0]['relative_url']
                    if relative_url in self.repository_to_channels:
                        self.repository_to_channels[relative_url].append(channel)
                    else:
                        self.repository_to_channels[relative_url] = [channel]

    def _populate_repository_tree(self, client_cert_id=None):
        sql = """
            select cs.label, cs.source_url, csssl.ssl_ca_cert_id,
                   csssl.ssl_client_cert_id, csssl.ssl_client_key_id
            from rhnContentSource cs inner join
                 rhnContentSourceSsl csssl on cs.id = csssl.content_source_id
            where cs.org_id is null
              and cs.label like :prefix || '%%'
        """
        # Create repository tree containing only repositories provided from single client certificate
        if client_cert_id:
            sql += " and csssl.ssl_client_cert_id = :client_cert_id"
        query = rhnSQL.prepare(sql)
        query.execute(prefix=constants.MANIFEST_REPOSITORY_DB_PREFIX, client_cert_id=client_cert_id)
        rows = query.fetchall_dict() or []
        cdn_repositories = {}
        # Loop all rows from DB
        for row in rows:
            label = row['label']
            if label in cdn_repositories:
                cdn_repository = cdn_repositories[label]
            else:
                cdn_repository = CdnRepository(label, row['source_url'])
                cdn_repositories[label] = cdn_repository

            # Append SSL cert, key set to repository
            ssl_set = CdnRepositorySsl(row['ssl_ca_cert_id'], row['ssl_client_cert_id'], row['ssl_client_key_id'])
            cdn_repository.add_ssl_set(ssl_set)

        # Add populated repository to tree
        for cdn_repository in cdn_repositories.values():
            self.repository_tree.add_repository(cdn_repository)

    def get_content_sources_regular(self, channel_label, source=False):
        if channel_label in self.content_source_mapping:
            return [x for x in self.content_source_mapping[channel_label]
                    if source or x['pulp_content_category'] != "source"]
        else:
            return []

    def get_content_sources_kickstart(self, channel_label):
        repositories = []
        if channel_label in self.kickstart_metadata:
            for tree in self.kickstart_metadata[channel_label]:
                tree_label = tree['ks_tree_label']
                if tree_label in self.kickstart_source_mapping:
                    # One tree comes from one repo, one repo for each tree is in the mapping,
                    # in future there may be multiple repos for one tree and we will need to select
                    # correct repo
                    repository = self.kickstart_source_mapping[tree_label][0]
                    repository['ks_tree_label'] = tree_label
                    repositories.append(repository)
                else:
                    log2(1, 1, "WARNING: Can't find repository for kickstart tree in mappings: %s"
                         % tree_label, stream=sys.stderr)
        return repositories

    def get_content_sources(self, channel_label, source=False):
        sources = self.get_content_sources_regular(channel_label, source=source)
        kickstart_sources = self.get_content_sources_kickstart(channel_label)
        return sources + sorted(kickstart_sources)

    def check_channel_availability(self, channel_label, no_kickstarts=False):
        """Checks if all repositories for channel are available."""
        if no_kickstarts:
            sources = self.get_content_sources_regular(channel_label)
        else:
            sources = self.get_content_sources(channel_label)

        # No content, no channel
        if not sources:
            return False

        for source in sources:
            if not self.check_repository_availability(source['relative_url'], channel_label=channel_label):
                if source.get('ks_tree_label', None):
                    # don't fail if kickstart is missing, just warn (bz1626797)
                    log2(0, 0, "WARNING: kickstart tree '%s' is unavailable" % source['ks_tree_label'],
                         stream=sys.stderr)
                    self.excluded_urls.append(source['relative_url'])
                else:
                    return False
        return True

    def check_repository_availability(self, relative_url, channel_label=None):
        try:
            crypto_keys = self.get_repository_crypto_keys(relative_url)
        except CdnRepositoryNotFoundError:
            log2(1, 1, "ERROR: No SSL certificates were found for repository '%s'" % relative_url, stream=sys.stderr)
            return False

        # Check SSL certificates
        if not crypto_keys:
            if channel_label:
                log2(1, 1, "ERROR: No valid SSL certificates were found for repository '%s'"
                           " required for channel '%s'." % (relative_url, channel_label), stream=sys.stderr)
            else:
                log2(1, 1, "ERROR: No valid SSL certificates were found for repository '%s'." % relative_url,
                     stream=sys.stderr)
            return False

        # Try to look for repomd file
        if self.local_mount_point and not os.path.isfile(os.path.join(
                self.local_mount_point, relative_url[1:], "repodata/repomd.xml")):
            return False

        return True

    def get_content_sources_import_batch(self, channel_label, backend, repos=None):
        batch = []

        # No custom repos specified, look into channel mappings
        if not repos:
            sources = self.get_content_sources(channel_label)
            for source in sources:
                if 'ks_tree_label' in source:
                    content_source = self._create_content_source_obj(source['ks_tree_label'],
                                                                     source['relative_url'], backend)
                else:
                    content_source = self._create_content_source_obj(source['pulp_repo_label_v2'],
                                                                     source['relative_url'], backend)
                batch.append(content_source)
        # We want to sync not-mapped repositories
        else:
            for index, repo in enumerate(repos):
                repo_label = "%s-%d" % (channel_label, index)
                content_source = self._create_content_source_obj(repo_label, repo, backend)
                batch.append(content_source)

        return batch

    def _create_content_source_obj(self, label, source_url, backend):
        type_id = backend.lookupContentSourceType('yum')
        content_source = ContentSource()
        content_source['label'] = label
        content_source['source_url'] = source_url
        content_source['org_id'] = None
        content_source['type_id'] = type_id
        content_source['ssl-sets'] = []
        repository = self.repository_tree.find_repository(source_url)
        for ssl_set in repository.get_ssl_sets():
            content_source_ssl = ContentSourceSsl()
            content_source_ssl['ssl_ca_cert_id'] = ssl_set.get_ca_cert()
            content_source_ssl['ssl_client_cert_id'] = ssl_set.get_client_cert()
            content_source_ssl['ssl_client_key_id'] = ssl_set.get_client_key()
            content_source['ssl-sets'].append(content_source_ssl)
        return content_source

    def get_repository_crypto_keys(self, url):
        repo = self.repository_tree.find_repository(url)
        crypto_keys = []
        for ssl_set in repo.get_ssl_sets():
            keys = ssl_set.get_crypto_keys(check_dates=True)
            if keys:
                crypto_keys.append(keys)
        return crypto_keys

    def assign_repositories_to_channel(self, channel_label, delete_repos=None, add_repos=None):
        backend = SQLBackend()
        self.unlink_all_repos(channel_label, custom_only=True)
        repos = self.list_associated_repos(channel_label)
        changed = 0
        if delete_repos:
            for to_delete in delete_repos:
                if to_delete in repos:
                    repos.remove(to_delete)
                    log(0, "Removing repository '%s' from channel." % to_delete)
                    changed += 1
                else:
                    log2(0, 0, "WARNING: Repository '%s' is not attached to channel." % to_delete, stream=sys.stderr)
        if add_repos:
            for to_add in add_repos:
                if to_add not in repos:
                    repos.append(to_add)
                    log(0, "Attaching repository '%s' to channel." % to_add)
                    changed += 1
                else:
                    log2(0, 0, "WARNING: Repository '%s' is already attached to channel." % to_add, stream=sys.stderr)

        # If there are any repositories intended to be attached to channel
        if repos:
            content_sources_batch = self.get_content_sources_import_batch(
                channel_label, backend, repos=sorted(repos))
            for content_source in content_sources_batch:
                content_source['channels'] = [channel_label]
                importer = ContentSourcesImport(content_sources_batch, backend)
                importer.run()
        else:
            # Make sure everything is unlinked
            self.unlink_all_repos(channel_label)
        return changed

    @staticmethod
    def unlink_all_repos(channel_label, custom_only=False):
        sql = """
            delete from rhnChannelContentSource ccs
            where ccs.channel_id = (select id from rhnChannel where label = :label)
        """
        if custom_only:
            sql += """
                and ccs.source_id in (select id from rhnContentSource where id = ccs.source_id and org_id is not null)
            """
        h = rhnSQL.prepare(sql)
        h.execute(label=channel_label)
        rhnSQL.commit()

    @staticmethod
    def list_associated_repos(channel_label):
        h = rhnSQL.prepare("""
                select cs.source_url
                from rhnChannel c inner join
                     rhnChannelContentSource ccs on c.id = ccs.channel_id inner join
                     rhnContentSource cs on ccs.source_id = cs.id
                where c.label = :label
                  and cs.org_id is null
            """)
        h.execute(label=channel_label)
        paths = [r['source_url'] for r in h.fetchall_dict() or []]
        return paths

    @staticmethod
    def list_provided_repos(crypto_key_id):
        h = rhnSQL.prepare("""
                select cs.source_url
                from rhnContentSource cs inner join
                     rhnContentSourceSsl csssl on cs.id = csssl.content_source_id
                where cs.label like :prefix || '%%'
                  and csssl.ssl_client_cert_id = :client_cert_id
            """)
        h.execute(prefix=constants.MANIFEST_REPOSITORY_DB_PREFIX, client_cert_id=crypto_key_id)
        paths = [r['source_url'] for r in h.fetchall_dict() or []]
        return paths

    @staticmethod
    def cleanup_orphaned_repos():
        h = rhnSQL.prepare("""
            delete from rhnContentSource cs
            where cs.org_id is null
              and cs.label not like :prefix || '%%'
              and not exists (select channel_id from rhnChannelContentSource where source_id = cs.id)
        """)
        h.execute(prefix=constants.MANIFEST_REPOSITORY_DB_PREFIX)
        rhnSQL.commit()

    @staticmethod
    def get_content_source_label(source):
        if 'pulp_repo_label_v2' in source:
            return source['pulp_repo_label_v2']
        elif 'ks_tree_label' in source:
            return source['ks_tree_label']
        else:
            raise InvalidContentSourceType()

    def list_channels_containing_repository(self, relative_path):
        if relative_path in self.repository_to_channels:
            return self.repository_to_channels[relative_path]
        else:
            return []


class CdnRepositoryTree(object):
    """Class representing activated CDN repositories in tree structure.
       Leafs contains CdnRepository instances.
       Allows us to match direct CDN URLs without variables (coming from mapping)
       to CDN URLs with variables (coming from manifest and having SSL keys/certs assigned)"""

    VARIABLES = ['$releasever', '$basearch']

    def __init__(self):
        self.root = {}

    def add_repository(self, repository):
        """Add new CdnRepository to tree."""

        url = repository.get_url()
        path = [x for x in url.split('/') if x]
        node = self.root
        for part in path[:-1]:
            if part not in node:
                node[part] = {}
            node = node[part]
        # Save repository into leaf
        node[path[-1]] = repository

    def _browse_node(self, node, keys):
        """Recursive function going through tree."""
        # Return leaf
        is_leaf = not isinstance(node, dict)
        if is_leaf and not keys:
            return node
        elif (is_leaf and keys) or (not is_leaf and not keys):
            raise CdnRepositoryNotFoundError()
        step = keys[0]
        to_check = [x for x in node.keys() if x in self.VARIABLES or x == step]
        # Remove first step in path, create new list
        next_keys = keys[1:]

        # Check all available paths
        for key in to_check:
            try:
                # Try to get next node and run this function recursively
                next_node = node[key]
                return self._browse_node(next_node, next_keys)
            # From here
            except KeyError:
                pass
            # From recurrent call
            except CdnRepositoryNotFoundError:
                pass

        raise CdnRepositoryNotFoundError()

    @staticmethod
    def normalize_url(url):
        """Splits repository URL, removes redundant characters and returns list with directory names."""
        path = []
        for part in url.split('/'):
            if part == '..':
                if path:
                    del path[-1]
                else:
                    # Can't go upper in directory structure, keep it in path
                    path.append(part)
            elif part and part != '.':
                path.append(part)

        return path

    def find_repository(self, url):
        """Finds matching repository in tree.
           url is relative CDN url - e.g. /content/dist/rhel/server/6/6Server/x86_64/os"""
        node = self.root
        try:
            path = self.normalize_url(url)
            found = self._browse_node(node, path)
        except CdnRepositoryNotFoundError:
            raise CdnRepositoryNotFoundError("ERROR: Repository '%s' was not found." % url)

        return found


class CdnRepositoryNotFoundError(Exception):
    pass


class InvalidContentSourceType(Exception):
    pass


class CdnRepository(object):
    """Class representing CDN repository."""

    def __init__(self, label, url):
        self.label = label
        self.url = url
        self.ssl_sets = []

    # CdnRepositorySsl instance
    def add_ssl_set(self, ssl_set):
        self.ssl_sets.append(ssl_set)

    def get_ssl_sets(self):
        return self.ssl_sets

    def get_label(self):
        return self.label

    def get_url(self):
        return self.url


class CdnRepositorySsl(object):
    """Class representing single SSL certificate, key set for single CDN repository"""

    def __init__(self, ca_cert, client_cert, client_key):
        self.ca_cert = int(ca_cert)
        self.client_cert = int(client_cert)
        self.client_key = int(client_key)

    def get_ca_cert(self):
        return self.ca_cert

    def get_client_cert(self):
        return self.client_cert

    def get_client_key(self):
        return self.client_key

    def get_crypto_keys(self, check_dates=False):
        ssl_query = rhnSQL.prepare("""
            select description, key, org_id from rhnCryptoKey where id = :id
        """)
        keys = {}
        ssl_query.execute(id=self.ca_cert)
        row = ssl_query.fetchone_dict()
        keys['ca_cert'] = (str(row['description']), str(row['key']), row['org_id'])
        ssl_query.execute(id=self.client_cert)
        row = ssl_query.fetchone_dict()
        keys['client_cert'] = (str(row['description']), str(row['key']), row['org_id'])
        ssl_query.execute(id=self.client_key)
        row = ssl_query.fetchone_dict()
        keys['client_key'] = (str(row['description']), str(row['key']), row['org_id'])

        # Check if SSL certificates are usable
        if check_dates:
            failed = 0
            for key in (keys['ca_cert'], keys['client_cert']):
                if not verify_certificate_dates(key[1]):
                    log(1, "WARNING: Problem with dates in certificate '%s'. "
                           "Please check validity of this certificate." % key[0])
                    failed += 1
            if failed:
                return {}
        return keys
