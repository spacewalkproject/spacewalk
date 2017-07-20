# Copyright (c) 2016--2017 Red Hat, Inc.
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

import cStringIO
import json
import zipfile
import os
from M2Crypto import X509

from spacewalk.satellite_tools.syncLib import log2
from spacewalk.server.rhnServer.satellite_cert import SatelliteCert

import constants


class Manifest(object):
    """Class containing relevant data from RHSM manifest."""

    SIGNATURE_NAME = "signature"
    INNER_ZIP_NAME = "consumer_export.zip"
    ENTITLEMENTS_PATH = "export/entitlements"
    CERTIFICATE_PATH = "export/extensions"
    PRODUCTS_PATH = "export/products"
    CONSUMER_INFO = "export/consumer.json"
    META_INFO = "export/meta.json"
    UPSTREAM_CONSUMER_PATH = "export/upstream_consumer"

    def __init__(self, zip_path):
        self.all_entitlements = []
        self.manifest_repos = {}
        self.sat5_certificate = None
        self.satellite_version = None
        self.consumer_credentials = None
        self.uuid = None
        self.name = None
        self.ownerid = None
        self.api_url = None
        self.web_url = None
        self.created = None
        # Signature and signed data
        self.signature = None
        self.data = None
        # Open manifest from path
        top_zip = None
        inner_zip = None
        inner_file = None

        # normalize path
        zip_path = os.path.abspath(os.path.expanduser(zip_path))
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
                    self._extract_consumer_info(inner_zip)
                    self._load_entitlements(inner_zip)
                    self._extract_certificate(inner_zip)
                    self._extract_meta_info(inner_zip)
                    self._extract_consumer_credentials(inner_zip)
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
            # Save version too
            sat5_cert = SatelliteCert()
            sat5_cert.load(self.sat5_certificate)
            self.satellite_version = getattr(sat5_cert, 'satellite-version')
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
            log2(0, 0, "ERROR: Cannot access required field in product '%s'" % product.get_id(), stream=sys.stderr)
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
                                "Single certificate in entitlements file '%s' is expected, found: %d"
                                % (entitlement_file, len(certs)))
                        cert = certs[0]
                        credentials = Credentials(data['id'], cert['cert'], cert['key'])

                        # Extract product IDs
                        products = []
                        provided_products = data['pool']['providedProducts'] or []
                        derived_provided_products = data['pool']['derivedProvidedProducts'] or []
                        product_ids = [provided_product['productId'] for provided_product
                                       in provided_products + derived_provided_products]
                        for product_id in set(product_ids):
                            product = Product(product_id)
                            self._fill_product_repositories(zip_file, product)
                            products.append(product)

                        # Skip entitlements not providing any products
                        if products:
                            entitlement = Entitlement(products, credentials)
                            self.all_entitlements.append(entitlement)
                    except KeyError:
                        log2(0, 0, "ERROR: Cannot access required field in file '%s'" % entitlement_file,
                             stream=sys.stderr)
                        raise
                finally:
                    entitlements.close()
        else:
            refer_url = "%s%s" % (self.web_url, self.uuid)
            if not refer_url.startswith("http"):
                refer_url = "https://" + refer_url
            raise IncorrectEntitlementsFileFormatError(
                "No subscriptions were found in manifest.\n\nPlease refer to %s for setting up subscriptions."
                % refer_url)

    def _extract_consumer_info(self, zip_file):
        files = zip_file.namelist()
        found = False
        for f in files:
            if f == self.CONSUMER_INFO:
                found = True
                break
        if found:
            consumer_info = zip_file.open(self.CONSUMER_INFO)
            try:
                try:
                    data = json.load(consumer_info)
                    self.uuid = data['uuid']
                    self.name = data['name']
                    self.ownerid = data['owner']['key']
                    self.api_url = data['urlApi']
                    self.web_url = data['urlWeb']
                except KeyError:
                    log2(0, 0, "ERROR: Cannot access required field in file '%s'" % self.CONSUMER_INFO,
                         stream=sys.stderr)
                    raise
            finally:
                consumer_info.close()
        else:
            raise MissingConsumerInfoError()

    def _extract_meta_info(self, zip_file):
        files = zip_file.namelist()
        found = False
        for f in files:
            if f == self.META_INFO:
                found = True
                break
        if found:
            meta_info = zip_file.open(self.META_INFO)
            try:
                try:
                    data = json.load(meta_info)
                    self.created = data['created']
                except KeyError:
                    log2(0, 0, "ERROR: Cannot access required field in file '%s'" % self.META_INFO, stream=sys.stderr)
                    raise
            finally:
                meta_info.close()
        else:
            raise MissingMetaInfoError()

    def _extract_consumer_credentials(self, zip_file):
        files = zip_file.namelist()
        consumer_credentials = []
        for f in files:
            if f.startswith(self.UPSTREAM_CONSUMER_PATH) and f.endswith(".json"):
                consumer_credentials.append(f)

        if len(consumer_credentials) == 1:
            upstream_consumer = zip_file.open(consumer_credentials[0])
            try:
                try:
                    data = json.load(upstream_consumer)
                    self.consumer_credentials = Credentials(data['id'], data['cert'], data['key'])
                except KeyError:
                    log2(0, 0, "ERROR: Cannot access required field in file '%s'" % consumer_credentials[0],
                         stream=sys.stderr)
                    raise
            finally:
                upstream_consumer.close()
        else:
            raise IncorrectCredentialsError(
                "ERROR: Single upstream consumer certificate expected, found %d." % len(consumer_credentials))

    def get_all_entitlements(self):
        return self.all_entitlements

    def get_satellite_certificate(self):
        return self.sat5_certificate

    def get_satellite_version(self):
        return self.satellite_version

    def get_consumer_credentials(self):
        return self.consumer_credentials

    def get_name(self):
        return self.name

    def get_uuid(self):
        return self.uuid

    def get_ownerid(self):
        return self.ownerid

    def get_api_url(self):
        return self.api_url

    def get_created(self):
        return self.created

    def check_signature(self):
        if self.signature and self.data:
            certs = os.listdir(constants.CANDLEPIN_CA_CERT_DIR)
            # At least one certificate has to match
            for cert_name in certs:
                cert_file = None
                try:
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


class MissingConsumerInfoError(Exception):
    pass


class MissingMetaInfoError(Exception):
    pass
