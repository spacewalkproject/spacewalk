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

        for entitlement in self.manifest.get_all_entitlements():
            for product_id in entitlement.get_product_ids():
                try:
                    product = self.products[product_id]
                    self.families_to_import.extend(product['families'])
                # Some product cannot be mapped into channel families
                except KeyError:
                    print("Cannot map product '%s' into channel families" % product_id)
                    pass

        self.families_to_import = set(self.families_to_import)

        # Debug
        print("Channel families mapped from products: %d" % len(self.families_to_import))
        print("Channel families in cert: %d" % len(self.sat5_cert.channel_families))

        batch = []
        for cf in self.sat5_cert.channel_families:
            label = cf.name
            if label not in self.families_to_import:
                print("Skipping channel family from certificate, not in the mapping: %s" % label)
                continue
            try:
                family = self.families[label]
                family_object = ChannelFamily()
                for k in family.keys():
                    family_object[k] = family[k]
                family_object['label'] = label
                batch.append(family_object)
            except KeyError:
                print("ERROR: Channel family '%s' was not found in mapping" % label)
                raise

        # Perform import
        backend = SQLBackend()
        importer = ChannelFamilyImport(batch, backend)
        importer.run()
        backend.commit()

    def run(self):
        print("Updating certificates...")
        self._update_certificates()
        print("Updating channel families...")
        self._update_channel_families()
