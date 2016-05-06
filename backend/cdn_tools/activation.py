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
import constants

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

    for creds in manifest.get_all_credentials():
        satCerts.store_rhnCryptoKey(
            constants.CLIENT_CERT_PREFIX + creds.get_id(), creds.get_cert(), None)
        satCerts.store_rhnCryptoKey(
            constants.CLIENT_KEY_PREFIX + creds.get_id(), creds.get_key(), None)

