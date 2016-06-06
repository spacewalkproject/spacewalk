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

from spacewalk.satellite_tools import satCerts
from spacewalk.server import rhnSQL
from spacewalk.server.importlib.backendOracle import SQLBackend
from spacewalk.server.importlib.channelImport import ChannelFamilyImport
from spacewalk.server.importlib.importLib import ChannelFamily
from satellite_cert import SatelliteCert
import constants
from manifest import Manifest
import json

"""
Functions handling activation from RHSM manifest.
"""


class Activation(object):
    """Class inserting channel families and SSL metadata into DB."""

    def __init__(self, manifest_path, cert_path):
        rhnSQL.initDB()
        self.manifest = Manifest(manifest_path)

        # Satellite 5 certificate
        with open(cert_path, 'r') as f:
            self.sat5_cert = SatelliteCert()
            content = f.read()
            self.sat5_cert.load(content)

        # Channel families metadata
        with open(constants.CHANNEL_FAMILY_MAPPING_PATH, 'r') as f:
            self.families = json.load(f)

        with open(constants.PRODUCT_FAMILY_MAPPING_PATH, 'r') as f:
            self.products = json.load(f)

        self.families_to_import = []

    def _update_certificates(self):
        """Delete and insert certificates needed for syncing from CDN repositories."""

        # Read RHSM cert
        with open(constants.CA_CERT_PATH, 'r') as f:
            ca_cert = f.read()

        # Insert RHSM cert and certs from manifest into DB
        satCerts.store_rhnCryptoKey(
            constants.CA_CERT_NAME, ca_cert, None)

        for entitlement in self.manifest.get_all_entitlements():
            creds = entitlement.get_credentials()
            satCerts.store_rhnCryptoKey(
                constants.CLIENT_CERT_PREFIX + creds.get_id(), creds.get_cert(), None)
            satCerts.store_rhnCryptoKey(
                constants.CLIENT_KEY_PREFIX + creds.get_id(), creds.get_key(), None)

    def _update_channel_families(self):
        """Insert channel family data into DB"""

        families_in_mapping = []
        for entitlement in self.manifest.get_all_entitlements():
            for product_id in entitlement.get_product_ids():
                try:
                    product = self.products[product_id]
                    families_in_mapping.extend(product['families'])
                # Some product cannot be mapped into channel families
                except KeyError:
                    print("Cannot map product '%s' into channel families" % product_id)
                    pass

        families_in_mapping = set(families_in_mapping)

        # Debug
        print("Channel families mapped from products: %d" % len(self.families_to_import))
        print("Channel families in cert: %d" % len(self.sat5_cert.channel_families))

        batch = []
        for cf in self.sat5_cert.channel_families:
            label = cf.name
            if label not in families_in_mapping:
                print("Skipping channel family from certificate, not in the mapping: %s" % label)
                continue
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
                raise

        # Perform import
        backend = SQLBackend()
        importer = ChannelFamilyImport(batch, backend)
        importer.run()

    def _update_families_ssl(self):
        """Link channel families with certificates inserted in _update_certificates method"""
        family_ids = {}
        for family in self.families_to_import:
            family_ids[family] = None

        # Populate with IDs
        backend = SQLBackend()
        backend.lookupChannelFamilies(family_ids)

        # Lookup CA cert
        ca_cert = satCerts.lookup_cert(constants.CA_CERT_NAME, None)
        ca_cert_id = int(ca_cert['id'])

        # Queries for updating relation between channel families and certificates
        hdel = rhnSQL.prepare("""
            delete from rhnContentSsl where
            channel_family_id = :cfid
        """)
        hins = rhnSQL.prepare("""
            insert into rhnContentSsl
            (channel_family_id, ssl_ca_cert_id, ssl_client_cert_id, ssl_client_key_id)
            values (:cfid, :ca_cert_id, :client_cert_id, :client_key_id)
        """)

        for entitlement in self.manifest.get_all_entitlements():
            creds = entitlement.get_credentials()
            client_cert = satCerts.lookup_cert(constants.CLIENT_CERT_PREFIX +
                                               creds.get_id(), None)
            client_key = satCerts.lookup_cert(constants.CLIENT_KEY_PREFIX +
                                              creds.get_id(), None)
            client_cert_id = int(client_cert['id'])
            client_key_id = int(client_key['id'])
            family_ids_to_link = []
            for product_id in entitlement.get_product_ids():
                try:
                    product = self.products[product_id]
                    for family in product['families']:
                        if family in family_ids:
                            family_ids_to_link.append(family_ids[family])
                except KeyError:
                    print("Cannot map product '%s' into channel families" % product_id)
                    pass
            family_ids_to_link = set(family_ids_to_link)

            for cfid in family_ids_to_link:
                hdel.execute(cfid=cfid)
                hins.execute(cfid=cfid, ca_cert_id=ca_cert_id,
                             client_cert_id=client_cert_id, client_key_id=client_key_id)

        rhnSQL.commit()

    def run(self):
        print("Updating certificates...")
        self._update_certificates()
        print("Updating channel families...")
        self._update_channel_families()
        print("Updating certificates for channel families...")
        self._update_families_ssl()
