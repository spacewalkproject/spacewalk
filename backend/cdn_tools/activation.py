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

import sys
import json

from spacewalk.satellite_tools import satCerts
from spacewalk.server import rhnSQL
from spacewalk.server.importlib.backendOracle import SQLBackend
from spacewalk.server.importlib.channelImport import ChannelFamilyImport
from spacewalk.server.importlib.importLib import ChannelFamily, ContentSource, ContentSourceSsl
from spacewalk.server.importlib.contentSourcesImport import ContentSourcesImport
from spacewalk.server.rhnServer.satellite_cert import SatelliteCert
from common import verify_mappings
import constants
from manifest import Manifest, ManifestValidationError


class Activation(object):
    """Class inserting channel families and SSL metadata into DB."""

    def __init__(self, manifest_path):
        rhnSQL.initDB()
        self.manifest = Manifest(manifest_path)
        self.sat5_cert = SatelliteCert()
        self.sat5_cert.load(self.manifest.get_satellite_certificate())

        verify_mappings()

        f = None
        # Channel families metadata
        try:
            f = open(constants.CHANNEL_FAMILY_MAPPING_PATH, 'r')
            self.families = json.load(f)
            f.close()
        except IOError:
            e = sys.exc_info()[1]
            print "Ignoring channel mappings: %s" % e
            self.families = {}
        finally:
            if f is not None:
                f.close()

        self.families_to_import = []

    @staticmethod
    def _remove_certificates():
        for description_prefix in (constants.CA_CERT_NAME,
                                   constants.CLIENT_CERT_PREFIX,
                                   constants.CLIENT_KEY_PREFIX):

            satCerts.delete_rhnCryptoKey_null_org(description_prefix)

    def _update_certificates(self):
        """Delete and insert certificates needed for syncing from CDN repositories."""

        # Remove all previously used certs/keys
        self._remove_certificates()

        # Read RHSM cert
        f = open(constants.CA_CERT_PATH, 'r')
        try:
            ca_cert = f.read()
        finally:
            if f is not None:
                f.close()

        if not satCerts.verify_certificate_dates(str(ca_cert)):
            print("WARNING: '%s' certificate is not valid." % constants.CA_CERT_PATH)
        # Insert RHSM cert and certs from manifest into DB
        satCerts.store_rhnCryptoKey(
            constants.CA_CERT_NAME, ca_cert, None)

        for entitlement in self.manifest.get_all_entitlements():
            creds = entitlement.get_credentials()
            cert_name = constants.CLIENT_CERT_PREFIX + creds.get_id()
            key_name = constants.CLIENT_KEY_PREFIX + creds.get_id()
            if not satCerts.verify_certificate_dates(str(creds.get_cert())):
                print("WARNING: '%s' certificate is not valid." % cert_name)
            satCerts.store_rhnCryptoKey(cert_name, creds.get_cert(), None)
            satCerts.store_rhnCryptoKey(key_name, creds.get_key(), None)

    def import_channel_families(self):
        """Insert channel family data into DB."""

        # Debug
        print("Channel families in cert: %d" % len(self.sat5_cert.channel_families)) # pylint: disable=E1101

        batch = []
        for cf in self.sat5_cert.channel_families: # pylint: disable=E1101
            label = cf.name
            try:
                family = self.families[label]
                family_object = ChannelFamily()
                for k in family.keys():
                    family_object[k] = family[k]
                family_object['label'] = label
                batch.append(family_object)
                self.families_to_import.append(label)
            except KeyError:
                print("ERROR: Channel family '%s' was not found in mapping" % label)

        # Perform import
        backend = SQLBackend()
        importer = ChannelFamilyImport(batch, backend)
        importer.run()

    @staticmethod
    def _remove_repositories():
        """This method removes repositories obtained from manifest"""
        hdel_repos = rhnSQL.prepare("""
            delete from rhnContentSource where
            label like :prefix || '%%'
            and org_id is null
        """)
        hdel_repos.execute(prefix=constants.MANIFEST_REPOSITORY_DB_PREFIX)
        rhnSQL.commit()

    def _update_repositories(self):
        """Setup SSL credential to access repositories
           We do this in 2 steps:
           1. Fetching provided repositories from manifest - URL contains variables to substitute
           2. Assigning one certificate/key set to each repository"""

        # First delete all repositories from previously used manifests
        self._remove_repositories()

        backend = SQLBackend()
        type_id = backend.lookupContentSourceType('yum')

        # Lookup CA cert
        ca_cert = satCerts.lookup_cert(constants.CA_CERT_NAME, None)
        ca_cert_id = int(ca_cert['id'])

        content_sources_batch = {}
        for entitlement in self.manifest.get_all_entitlements():
            # Lookup SSL certificates and keys
            creds = entitlement.get_credentials()
            client_cert = satCerts.lookup_cert(constants.CLIENT_CERT_PREFIX +
                                               creds.get_id(), None)
            client_key = satCerts.lookup_cert(constants.CLIENT_KEY_PREFIX +
                                              creds.get_id(), None)
            client_cert_id = int(client_cert['id'])
            client_key_id = int(client_key['id'])
            content_source_ssl = ContentSourceSsl()
            content_source_ssl['ssl_ca_cert_id'] = ca_cert_id
            content_source_ssl['ssl_client_cert_id'] = client_cert_id
            content_source_ssl['ssl_client_key_id'] = client_key_id
            # Loop provided products
            for product in entitlement.get_products():
                repositories = product.get_repositories()
                for repository in repositories:
                    if repository not in content_sources_batch:
                        content_source = ContentSource()
                        content_source['label'] = constants.MANIFEST_REPOSITORY_DB_PREFIX + repository
                        content_source['source_url'] = repositories[repository]
                        content_source['org_id'] = None
                        content_source['type_id'] = type_id
                        content_source['ssl-sets'] = [content_source_ssl]
                        content_sources_batch[repository] = content_source
                    # There may be more SSL certs to one repository, append it
                    elif content_source_ssl not in content_sources_batch[repository]['ssl-sets']:
                        content_sources_batch[repository]['ssl-sets'].append(content_source_ssl)

        importer = ContentSourcesImport(content_sources_batch.values(), backend)
        importer.run()

    def activate(self):
        if self.manifest.check_signature():
            print("Populating channel families...")
            self.import_channel_families()
            print("Updating certificates...")
            self._update_certificates()
            print("Updating manifest repositories...")
            self._update_repositories()
        else:
            raise ManifestValidationError("Manifest validation failed! Make sure the specified manifest is correct.")

    @staticmethod
    def deactivate():
        """Function to remove certificates and manifest repositories from DB"""
        rhnSQL.initDB()
        print("Removing certificates...")
        Activation._remove_certificates()
        print("Removing manifest repositories...")
        Activation._remove_repositories()
