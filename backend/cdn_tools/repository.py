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

from spacewalk.server import rhnSQL
import constants


class CdnRepositoryManager(object):
    """Class managing CDN repositories, connected channels etc."""

    def __init__(self):
        self.repository_tree = CdnRepositoryTree()
        self._populate_repository_tree()

    def _populate_repository_tree(self):
        rhnSQL.initDB()
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
        self.ca_cert = ca_cert
        self.client_cert = client_cert
        self.client_key = client_key

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
