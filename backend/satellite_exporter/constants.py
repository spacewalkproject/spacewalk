# Copyright (C) 2008 Red Hat, Inc.
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
Constant values (protocol versions, etc) for satellite sync/exporter.
"""

PROTOCOL_VERSION = 3.5

# Support for checksums other then md5
SHA256_SUPPORTED_VERSION = 3.5

# Support for redirects to CDN (Akamai)
REDIRECTS_SUPPORTED_VERSION = 3.4

# Support for supplying comps.xml files (package groups)
COMPS_SUPPORTED_VERSION = 3.3

# Support for update model details (rhn510+)
EUS_SUPPORTED_VERSION = 3.2

# Support for virt details (rhn500+)
VIRT_SUPPORTED_VERSION = 3.1

# Historical log
# * Version 2.2 2004-03-02
#    arch types introduced in all the arch dumps
# * Version 2.3 2004-09-13
#    added short package dumps per channel
# * Version 3.0 2005-01-13
#    required major version change for channel family merging (#136525)

