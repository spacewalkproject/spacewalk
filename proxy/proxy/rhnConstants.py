#!/usr/bin/python
#
# Copyright (c) 2008 Red Hat, Inc.
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
##
# rhnDefines.py - Constants used throughout the Red Hat Proxy.
#-----------------------------------------------------------------------------
#

"""Constants used by the Red Hat Proxy"""

# HTTP Headers

HEADER_ACTUAL_URI      = 'X-RHN-ActualURI'
HEADER_EFFECTIVE_URI   = 'X-RHN-EffectiveURI'
HEADER_CHECKSUM        = 'X-RHN-Checksum'
HEADER_LOCATION        = 'Location'
HEADER_CONTENT_LENGTH  = 'Content-Length'
HEADER_RHN_REDIRECT    = 'X-RHN-Redirect'
HEADER_RHN_ORIG_LOC    = 'X-RHN-OriginalLocation'

# HTTP Schemes

SCHEME_HTTP            = 'http'
SCHEME_HTTPS           = 'https'

# These help us match URIs when kickstarting through a Proxy.

URI_PREFIX_KS          = '/ty/'
URI_PREFIX_KS_CHECKSUM = '/ty-cksm/'

# Component Constants

COMPONENT_BROKER       = 'proxy.broker'
COMPONENT_REDIRECT     = 'proxy.redirect'

