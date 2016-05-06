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
                    self._load_certificates(inner_zip)
                finally:
                    inner_zip.close()
            finally:
                inner_file.close()
        finally:
            top_zip.close()

    def _load_certificates(self, zip_file):
        files = zip_file.namelist()
        entitlements_files = []
        for f in files:
            if f.startswith(self.ENTITLEMENTS_PATH) and f.endswith(".json"):
                entitlements_files.append(f)

        if len(entitlements_files) >= 1:
            self.all_credentials = []
            for entitlement_file in entitlements_files:
                try:
                    entitlements = zip_file.open(entitlement_file)
                    data = json.load(entitlements)
                    certs = data['certificates']
                    if len(certs) != 1:
                        raise EntitlementsSearchError(
                            "ERROR: Single certificate in entitlements file is expected, found: %d"
                            % len(certs))
                    cert = certs[0]

                    creds = Credentials(data['id'], cert['cert'], cert['key'])
                    self.all_credentials.append(creds)
                finally:
                    entitlements.close()
        else:
            raise EntitlementsSearchError(
                "ERROR: There has to be at least one entitlements file")

    def get_all_credentials(self):
        return self.all_credentials


class Credentials(object):
    def __init__(self, identifier, cert, key):
        if id:
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


class IncorrectCredentialsError(Exception):
    pass


class EntitlementsSearchError(Exception):
    pass
