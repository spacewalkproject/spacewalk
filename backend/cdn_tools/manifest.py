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

import cStringIO
import json
import zipfile
import os
from M2Crypto import X509

import constants


class Manifest(object):
    """Class containing relevant data from RHSM manifest."""

    SIGNATURE_NAME = "signature"
    INNER_ZIP_NAME = "consumer_export.zip"
    ENTITLEMENTS_PATH = "export/entitlements"
    CERTIFICATE_PATH = "export/extensions"
    PRODUCTS_PATH = "export/products"

    def __init__(self, zip_path):
        self.all_entitlements = []
        self.manifest_repos = {}
        self.sat5_certificate = None
        # Signature and signed data
        self.signature = None
        self.data = None
        # Open manifest from path
        top_zip = None
        inner_zip = None
        inner_file = None
        try:
            top_zip = zipfile.ZipFile(zip_path, 'r')
            # Fetch inner zip file into memory
            try:
                # inner_file = top_zip.open(zip_path.split('.zip')[0] + '/' + self.INNER_ZIP_NAME)
                inner_file = top_zip.open(self.INNER_ZIP_NAME)
                self.data = inner_file.read()
                inner_file_data = cStringIO.StringIO(self.data)
                signature_file = top_zip.open(self.SIGNATURE_NAME)
                self.signature = signature_file.read()
                # Open the inner zip file
                try:
                    inner_zip = zipfile.ZipFile(inner_file_data)
                    self._load_entitlements(inner_zip)
                    self._extract_certificate(inner_zip)
                finally:
                    if inner_zip is not None:
                        inner_zip.close()
            finally:
                if inner_file is not None:
                    inner_file.close()
        finally:
            if top_zip is not None:
                top_zip.close()

    def _extract_certificate(self, zip_file):
        files = zip_file.namelist()
        certificates_names = []
        for f in files:
            if f.startswith(self.CERTIFICATE_PATH) and f.endswith(".xml"):
                certificates_names.append(f)
        if len(certificates_names) >= 1:
            # take only first file
            cert_file = zip_file.open(certificates_names[0])  # take only first file
            self.sat5_certificate = cert_file.read().strip()
            cert_file.close()
        else:
            raise MissingSatelliteCertificateError("Satellite Certificate was not found in manifest.")

    def _fill_product_repositories(self, zip_file, product):
        product_file = zip_file.open(self.PRODUCTS_PATH + '/' + str(product.get_id()) + '.json')
        product_data = json.load(product_file)
        product_file.close()
        try:
            for content in product_data['productContent']:
                content = content['content']
                product.add_repository(content['label'], content['contentUrl'])
        except KeyError:
            print("ERROR: Cannot access required field in product '%s'" % product.get_id())
            raise

    def _load_entitlements(self, zip_file):
        files = zip_file.namelist()
        entitlements_files = []
        for f in files:
            if f.startswith(self.ENTITLEMENTS_PATH) and f.endswith(".json"):
                entitlements_files.append(f)

        if len(entitlements_files) >= 1:
            self.all_entitlements = []
            for entitlement_file in entitlements_files:
                entitlements = zip_file.open(entitlement_file)
                # try block in try block - this is hack for python 2.4 compatibility
                # to support finally
                try:
                    try:
                        data = json.load(entitlements)

                        # Extract credentials
                        certs = data['certificates']
                        if len(certs) != 1:
                            raise IncorrectEntitlementsFileFormatError(
                                "ERROR: Single certificate in entitlements file is expected, found: %d"
                                % len(certs))
                        cert = certs[0]
                        credentials = Credentials(data['id'], cert['cert'], cert['key'])

                        # Extract product IDs
                        products = []
                        provided_products = data['pool']['providedProducts']
                        for provided_product in provided_products:
                            product = Product(provided_product['productId'])
                            self._fill_product_repositories(zip_file, product)
                            products.append(product)

                        # Skip entitlements not providing any products
                        if products:
                            entitlement = Entitlement(products, credentials)
                            self.all_entitlements.append(entitlement)
                    except KeyError:
                        print("ERROR: Cannot access required field in file '%s'" % entitlement_file)
                        raise
                finally:
                    entitlements.close()
        else:
            raise IncorrectEntitlementsFileFormatError(
                "ERROR: There has to be at least one entitlements file")

    def get_all_entitlements(self):
        return self.all_entitlements

    def get_satellite_certificate(self):
        return self.sat5_certificate

    def check_signature(self):
        if self.signature and self.data:
            certs = os.listdir(constants.CANDLEPIN_CA_CERT_DIR)
            # At least one certificate has to match
            for cert_name in certs:
                cert_file = None
                try:
                    cert_file = open(constants.CANDLEPIN_CA_CERT_DIR + '/' + cert_name, 'r')
                    cert = X509.load_cert_string(cert_file.read())
                except (IOError, X509.X509Error):
                    continue
                finally:
                    if cert_file is not None:
                        cert_file.close()
                pubkey = cert.get_pubkey()
                pubkey.reset_context(md='sha256')
                pubkey.verify_init()

                pubkey.verify_update(self.data)
                if pubkey.verify_final(self.signature):
                    return True
        return False


class Entitlement(object):
    def __init__(self, products, credentials):
        if products and credentials:
            self.products = products
            self.credentials = credentials
        else:
            raise IncorrectEntitlementError()

    def get_products(self):
        return self.products

    def get_credentials(self):
        return self.credentials


class Credentials(object):
    def __init__(self, identifier, cert, key):
        if identifier:
            self.id = identifier
        else:
            raise IncorrectCredentialsError(
                "ERROR: ID of credentials has to be defined"
            )

        if cert and key:
            self.cert = cert
            self.key = key
        else:
            raise IncorrectCredentialsError(
                "ERROR: Trying to create object with cert = %s and key = %s"
                % (cert, key)
            )

    def get_id(self):
        return self.id

    def get_cert(self):
        return self.cert

    def get_key(self):
        return self.key


class Product(object):
    def __init__(self, identifier):
        try:
            self.id = int(identifier)
        except ValueError:
            raise IncorrectProductError(
                "ERROR: Invalid product id: %s" % identifier
            )
        self.repositories = {}

    def get_id(self):
        return self.id

    def get_repositories(self):
        return self.repositories

    def add_repository(self, label, url):
        self.repositories[label] = url


class IncorrectProductError(Exception):
    pass


class IncorrectEntitlementError(Exception):
    pass


class IncorrectCredentialsError(Exception):
    pass


class IncorrectEntitlementsFileFormatError(Exception):
    pass


class MissingSatelliteCertificateError(Exception):
    pass


class ManifestValidationError(Exception):
    pass
