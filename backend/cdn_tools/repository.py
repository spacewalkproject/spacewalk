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

import os
import sys
import json

from spacewalk.server import rhnSQL
from spacewalk.satellite_tools.satCerts import verify_certificate_dates
from spacewalk.satellite_tools.syncLib import log
from spacewalk.server.importlib.importLib import ContentSource, ContentSourceSsl

import constants
from common import CdnMappingsLoadError


class CdnRepositoryManager(object):
    """Class managing CDN repositories, connected channels etc."""

    def __init__(self, local_mount_point=None, client_cert_id=None):
        rhnSQL.initDB()
        self.local_mount_point = local_mount_point
        self.repository_tree = CdnRepositoryTree()
        self._populate_repository_tree(client_cert_id=client_cert_id)

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
                raise CdnMappingsLoadError("Problem with loading file: %s" % e)
        finally:
            if f is not None:
                f.close()

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
                    log(1, "WARN: Kickstart tree not available: %s" % tree_label)
        return repositories

    def get_content_sources(self, channel_label, source=False):
        sources = self.get_content_sources_regular(channel_label, source=source)
        kickstart_sources = self.get_content_sources_kickstart(channel_label)
        return sources + kickstart_sources

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
            try:
                crypto_keys = self.get_repository_crypto_keys(source['relative_url'])
            except CdnRepositoryNotFoundError:
                return False

            # Check SSL certificates
            if not crypto_keys:
                log(0, "ERROR: No valid SSL certificates were found for repository '%s'"
                       " required for channel '%s'."
                    % (source['relative_url'], channel_label))
                return False

            # Try to look for repomd file
            if self.local_mount_point and not os.path.isfile(os.path.join(
                    self.local_mount_point, source['relative_url'][1:], "repodata/repomd.xml")):
                return False

        return True

    def get_content_sources_import_batch(self, channel_label, backend):
        batch = []
        type_id = backend.lookupContentSourceType('yum')

        sources = self.get_content_sources(channel_label)

        for source in sources:
            content_source = ContentSource()
            if 'ks_tree_label' in source:
                content_source['label'] = source['ks_tree_label']
            else:
                content_source['label'] = source['pulp_repo_label_v2']
            content_source['source_url'] = source['relative_url']
            content_source['org_id'] = None
            content_source['type_id'] = type_id
            content_source['ssl-sets'] = []
            repository = self.repository_tree.find_repository(source['relative_url'])
            for ssl_set in repository.get_ssl_sets():
                content_source_ssl = ContentSourceSsl()
                content_source_ssl['ssl_ca_cert_id'] = ssl_set.get_ca_cert()
                content_source_ssl['ssl_client_cert_id'] = ssl_set.get_client_cert()
                content_source_ssl['ssl_client_key_id'] = ssl_set.get_client_key()
                content_source['ssl-sets'].append(content_source_ssl)
            batch.append(content_source)

        return batch

    def get_repository_crypto_keys(self, url):
        repo = self.repository_tree.find_repository(url)
        crypto_keys = []
        for ssl_set in repo.get_ssl_sets():
            keys = ssl_set.get_crypto_keys(check_dates=True)
            if keys:
                crypto_keys.append(keys)
        return crypto_keys


    @staticmethod
    def get_content_source_label(source):
        if 'pulp_repo_label_v2' in source:
            return source['pulp_repo_label_v2']
        elif 'ks_tree_label' in source:
            return source['ks_tree_label']
        else:
            raise InvalidContentSourceType()


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
        if not keys:
            return node
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

    def find_repository(self, url):
        """Finds matching repository in tree.
           url is relative CDN url - e.g. /content/dist/rhel/server/6/6Server/x86_64/os"""

        path = [x for x in url.split('/') if x]
        node = self.root
        try:
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
            select description, key from rhnCryptoKey where id = :id
        """)
        keys = {}
        ssl_query.execute(id=self.ca_cert)
        row = ssl_query.fetchone_dict()
        keys['ca_cert'] = (str(row['description']), str(row['key']))
        ssl_query.execute(id=self.client_cert)
        row = ssl_query.fetchone_dict()
        keys['client_cert'] = (str(row['description']), str(row['key']))
        ssl_query.execute(id=self.client_key)
        row = ssl_query.fetchone_dict()
        keys['client_key'] = (str(row['description']), str(row['key']))

        # Check if SSL certificates are usable
        if check_dates:
            failed = 0
            for key in (keys['ca_cert'], keys['client_cert']):
                if not verify_certificate_dates(key[1]):
                    log(1, "WARN: Problem with dates in certificate '%s'. "
                           "Please check validity of this certificate." % key[0])
                    failed += 1
            if failed:
                return {}
        return keys
