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


class Manifest(object):
    """Class containing relevant data from RHSM manifest."""

    INNER_ZIP_NAME = "consumer_export.zip"
    ENTITLEMENTS_PATH = "export/entitlements"

    def __init__(self, zip_path):
        self.all_entitlements = []
        # Open manifest from path
        try:
            top_zip = zipfile.ZipFile(zip_path, 'r')
            # Fetch inner zip file into memory
            try:
                inner_file = top_zip.open(self.INNER_ZIP_NAME)
                inner_file_data = cStringIO.StringIO(inner_file.read())
                # Open the inner zip file
                try:
                    inner_zip = zipfile.ZipFile(inner_file_data)
                    self._load_entitlements(inner_zip)
                finally:
                    inner_zip.close()
            finally:
                inner_file.close()
        finally:
            top_zip.close()

    def _load_entitlements(self, zip_file):
        files = zip_file.namelist()
        entitlements_files = []
        for f in files:
            if f.startswith(self.ENTITLEMENTS_PATH) and f.endswith(".json"):
                entitlements_files.append(f)

        if len(entitlements_files) >= 1:
            self.all_entitlements = []
            for entitlement_file in entitlements_files:
                try:
                    entitlements = zip_file.open(entitlement_file)
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
                    product_ids = []
                    provided_products = data['pool']['providedProducts']
                    for product in provided_products:
                        product_ids.append(product['productId'])

                    entitlement = Entitlement(product_ids, credentials)
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


class Entitlement(object):
    def __init__(self, product_ids, credentials):
        if product_ids and credentials:
            self.product_ids = product_ids
            self.credentials = credentials
        else:
            raise IncorrectEntitlementError()

    def get_product_ids(self):
        return self.product_ids

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


class IncorrectEntitlementError(Exception):
    pass


class IncorrectCredentialsError(Exception):
    pass


class IncorrectEntitlementsFileFormatError(Exception):
    pass
