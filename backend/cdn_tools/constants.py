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

"""
Constant values for Satellite CDN sync.
"""

# How are CDN SSL items named in rhnCryptoKey table.
CA_CERT_NAME = "CDN-CA-CERT"
CLIENT_CERT_PREFIX = "CDN-CLIENT-CERT-"
CLIENT_KEY_PREFIX = "CDN-CLIENT-KEY-"
# Repository URL contains variables, from manifest
MANIFEST_REPOSITORY_DB_PREFIX = "manifest_"

CA_CERT_PATH = "/etc/rhsm/ca/redhat-uep.pem"
CANDLEPIN_CA_CERT_DIR = "/etc/rhn/candlepin-certs"

MAPPINGS_RPM_NAME = "cdn-sync-mappings"
CHANNEL_DEFINITIONS_PATH = "/usr/share/rhn/cdn-sync/channels.json"
CHANNEL_FAMILY_MAPPING_PATH = "/usr/share/rhn/cdn-sync/families.json"
CHANNEL_DIST_MAPPING_PATH = "/usr/share/rhn/cdn-sync/dist_map.json"
CONTENT_SOURCE_MAPPING_PATH = "/usr/share/rhn/cdn-sync/rhn_cdn_mappings.json"
KICKSTART_DEFINITIONS_PATH = "/usr/share/rhn/cdn-sync/kickstart.json"
KICKSTART_SOURCE_MAPPING_PATH = "/usr/share/rhn/cdn-sync/kickstart_cdn_mappings.json"

CDN_REPODATA_ROOT = "/var/cache/rhn/cdnsync"
PACKAGE_STAGE_DIRECTORY = "/var/satellite/redhat/NULL/stage"
