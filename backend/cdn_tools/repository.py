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
from spacewalk.satellite_tools.syncLib import log
from spacewalk.server.importlib.importLib import ContentSource

import constants
from common import CdnMappingsLoadError


class CdnRepositoryManager(object):
    """Class managing CDN repositories, connected channels etc."""

    def __init__(self, local_mount_point=None):
        rhnSQL.initDB()
        self.local_mount_point = local_mount_point
        self.repository_tree = CdnRepositoryTree()
        self._populate_repository_tree()

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

    def _populate_repository_tree(self):
        query = rhnSQL.prepare("""
            select cs.label, cs.source_url, cs.ssl_ca_cert_id, cs.ssl_client_cert_id, cs.ssl_client_key_id
            from rhnContentSource cs
            where cs.org_id is null
              and cs.label like :prefix || '%%'
        """)
        query.execute(prefix=constants.MANIFEST_REPOSITORY_DB_PREFIX)
        rows = query.fetchall_dict() or []
        for row in rows:
            repository = CdnRepository(row['label'], row['source_url'],
                                       row['ssl_ca_cert_id'], row['ssl_client_cert_id'], row['ssl_client_key_id'])
            self.repository_tree.add_repository(repository)

    def get_content_sources_regular(self, channel_label, source=False):
        if channel_label in self.content_source_mapping:
            return [x for x in self.content_source_mapping[channel_label]
                    if source or x['pulp_content_category'] != "source"]
        else:
            return []

    def get_content_sources_kickstart(self, channel_label):
        if channel_label in self.kickstart_metadata:
            for tree in self.kickstart_metadata[channel_label]:
                tree_label = tree['ks_tree_label']
                if tree_label in self.kickstart_source_mapping:
                    return self.kickstart_source_mapping[tree_label]
                else:
                    log(1, "WARN: Kickstart tree not available: %s" % tree_label)
        return []

    def get_content_sources(self, channel_label, source=False):
        sources = self.get_content_sources_regular(channel_label, source=source)
        kickstart_sources = self.get_content_sources_kickstart(channel_label)
        return sources + kickstart_sources

    def check_channel_availability(self, channel_label):
        """Checks if all repositories for channel are available."""
        sources = self.get_content_sources(channel_label)

        # No content, no channel
        if not sources:
            return False

        for source in sources:
            try:
                self.repository_tree.find_repository(source['relative_url'])
            except CdnRepositoryNotFoundError:
                return False

            # Try to look for repomd file
            if self.local_mount_point and not os.path.isfile(os.path.join(
                    self.local_mount_point, source['relative_url'][1:], "repodata/repomd.xml")):
                return False

        return True

    def get_content_sources_import_batch(self, channel_label, backend):
        batch = []
        type_id = backend.lookupContentSourceType('yum')

        sources = self.get_content_sources_regular(channel_label)

        for source in sources:
            content_source = ContentSource()
            content_source['label'] = source['pulp_repo_label_v2']
            content_source['source_url'] = source['relative_url']
            content_source['org_id'] = None
            content_source['type_id'] = type_id
            repository = self.repository_tree.find_repository(source['relative_url'])
            content_source['ssl_ca_cert_id'] = repository.get_ca_cert()
            content_source['ssl_client_cert_id'] = repository.get_client_cert()
            content_source['ssl_client_key_id'] = repository.get_client_key()
            batch.append(content_source)

        kickstart_sources = self.get_content_sources_kickstart(channel_label)
        if kickstart_sources:
            # One tree comes from one repo, one repo for each tree is in the mapping,
            # in future there may be multiple repos for one tree and we will need to select
            # correct repo
            ks_source = kickstart_sources[0]
            content_source = ContentSource()
            tree_label = self.kickstart_metadata[channel_label][0]['ks_tree_label']
            content_source['label'] = tree_label
            content_source['source_url'] = ks_source['relative_url']
            content_source['org_id'] = None
            content_source['type_id'] = type_id
            repository = self.repository_tree.find_repository(ks_source['relative_url'])
            content_source['ssl_ca_cert_id'] = repository.get_ca_cert()
            content_source['ssl_client_cert_id'] = repository.get_client_cert()
            content_source['ssl_client_key_id'] = repository.get_client_key()
            batch.append(content_source)

        return batch

    def get_repository_crypto_keys(self, url):
        try:
            repo = self.repository_tree.find_repository(url)
            return repo.get_crypto_keys()
        except CdnRepositoryNotFoundError:
            return {}


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


class CdnRepository(object):
    """Class representing CDN repository with SSL credentials to access it."""

    def __init__(self, label, url, ca_cert, client_cert, client_key):
        self.label = label
        self.url = url
        self.ca_cert = int(ca_cert)
        self.client_cert = int(client_cert)
        self.client_key = int(client_key)

    def get_label(self):
        return self.label

    def get_url(self):
        return self.url

    def get_ca_cert(self):
        return self.ca_cert

    def get_client_cert(self):
        return self.client_cert

    def get_client_key(self):
        return self.client_key

    def get_crypto_keys(self):
        ssl_query = rhnSQL.prepare("""
            select key from rhnCryptoKey where id = :id
        """)
        keys = {}
        ssl_query.execute(id=self.ca_cert)
        keys['ca_cert'] = ssl_query.fetchone_dict()['key']
        ssl_query.execute(id=self.client_cert)
        keys['client_cert'] = ssl_query.fetchone_dict()['key']
        ssl_query.execute(id=self.client_key)
        keys['client_key'] = ssl_query.fetchone_dict()['key']
        return keys
