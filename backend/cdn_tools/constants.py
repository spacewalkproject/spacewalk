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

"""
Constant values for Satellite CDN sync.
"""


CDN_URL = "https://cdn.redhat.com"

# How are CDN SSL items named in rhnCryptoKey table.
CA_CERT_NAME = "CDN-CA-CERT"
CLIENT_CERT_PREFIX = "CDN-CLIENT-CERT-"
CLIENT_KEY_PREFIX = "CDN-CLIENT-KEY-"

CA_CERT_PATH = "/etc/rhsm/ca/redhat-uep.pem"

CHANNEL_DEFINITIONS_PATH = "/usr/share/rhn/cdn-sync/channels.json"
CHANNEL_FAMILY_MAPPING_PATH = "/usr/share/rhn/cdn-sync/families.json"
CHANNEL_DIST_MAPPING_PATH = "/usr/share/rhn/cdn-sync/dist_map.json"
PRODUCT_FAMILY_MAPPING_PATH = "/usr/share/rhn/cdn-sync/out-eng_products_to_families.json"
CONTENT_SOURCE_MAPPING_PATH = "/usr/share/rhn/cdn-sync/rhn_cdn_mappings.json"
