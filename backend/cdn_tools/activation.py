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
from spacewalk.server.importlib.importLib import InvalidChannelFamilyError, ChannelFamily
from satellite_cert import SatelliteCert
import constants
import json

"""
Functions handling activation from RHSM manifest.
"""


def update_certificates(manifest):
    """Delete and insert certificates needed for syncing from CDN repositories."""

    # Read RHSM cert
    with open(constants.CA_CERT_PATH, 'r') as f:
        ca_cert = f.read()

    # Insert RHSM cert and certs from manifest into DB
    rhnSQL.initDB()
    satCerts.store_rhnCryptoKey(
        constants.CA_CERT_NAME, ca_cert, None)

    for entitlement in manifest.get_all_entitlements():
        creds = entitlement.get_credentials()
        satCerts.store_rhnCryptoKey(
            constants.CLIENT_CERT_PREFIX + creds.get_id(), creds.get_cert(), None)
        satCerts.store_rhnCryptoKey(
            constants.CLIENT_KEY_PREFIX + creds.get_id(), creds.get_key(), None)


def update_channel_families(manifest, cert_path):
    """Insert channel family data into DB"""

    # Satellite 5 certificate
    with open(cert_path, 'r') as f:
        cert_content = f.read()

    # Channel families metadata
    with open(constants.CHANNEL_FAMILY_MAPPING_PATH, 'r') as f:
        families = json.load(f)

    with open(constants.PRODUCT_FAMILY_MAPPING_PATH, 'r') as f:
        products = json.load(f)

    mapped_channel_families = []
    for entitlement in manifest.get_all_entitlements():
        for product_id in entitlement.get_product_ids():
            try:
                product = products[product_id]
                mapped_channel_families.extend(product['families'])
            # Some product cannot be mapped into channel families
            except KeyError:
                print("Cannot map product '%s' into channel families" % product_id)
                pass

    mapped_channel_families = set(mapped_channel_families)

    cert = SatelliteCert()
    cert.load(cert_content)

    # Debug
    print("Channel families mapped from products: %d" % len(mapped_channel_families))
    print("Channel families in cert: %d" % len(cert.channel_families))

    batch = []
    for cf in cert.channel_families:
        label = cf.name
        if label not in mapped_channel_families:
            print("Skipping channel family from certificate, not in the mapping: %s" % label)
            continue
        try:
            family = families[label]
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




