#
# Copyright (c) 2008--2010 Red Hat, Inc.
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
#
#   Domain Classes for generating repository metadata from RHN info.
#

class Channel:

    """ A pure data object representing an RHN Channel. """
    
    def __init__(self, channel_id):
        self.id = channel_id

        self.label = None
        self.name = None
        self.checksum_type = None

        self.num_packages = 0
        self.packages = []
        self.errata = []
        self.updateinfo = None
        self.comps = None


class Package:

    """ A pure data object representing an RHN Package. """
    
    def __init__(self, package_id):
        self.id = package_id

        self.name = None
        self.version = None
        self.release = None
        self.epoch = 0
        self.arch = None

        self.checksum = None
        self.checksum_type = None
        self.summary = None
        self.description = None
        self.vendor = None
        self.build_time = None
        self.package_size = None
        self.payload_size = None
        self.header_start = None
        self.header_end = None
        self.package_group = None
        self.build_host = None
        self.copyright = None
        self.filename = None
        self.source_rpm = None

        self.files = []

        self.provides = []
        self.requires = []
        self.conflicts = []
        self.obsoletes = []

        self.changelog = []


class Erratum:
    
    """ An object representing a single update to a channel. """

    def __init__(self, erratum_id):
        self.id = erratum_id
        self.readable_id = None
        self.title = None
        self.advisory_type = None
        self.version = None

        self.issued = None
        self.updated = None

        self.synopsis = None
        self.description = None

        self.bz_references = []
        self.cve_references = []

        # We don't want to pickle a single package multiple times,
        # So here's a list to store the ids and we can swap out the
        # Actual objects when its time to pickle. This should be replaced
        # With something that keeps the concepts seperate.
        self.package_ids = []
        self.packages = []

class Comps:

    def __init__(self, comps_id, filename):
        self.id = comps_id
        self.filename = filename
