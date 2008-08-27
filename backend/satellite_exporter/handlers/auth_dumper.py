#!/usr/bin/python
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
Authenticated dumper
"""

from common import log_debug, rhnFault, rhnFlags
from server import rhnSQL
from server.rhnHandler import rhnHandler

from satellite_exporter import constants
from satellite_exporter.exporter import dumper

class AuthenticatedDumper(rhnHandler, dumper.XML_Dumper):
    def __init__(self, req):
        rhnHandler.__init__(self)
        dumper.XML_Dumper.__init__(self, req)
        # Don't check for abuse
        self.check_for_abuse = 0

        self.functions = [
            'arches',
            'arches_extra',
            'channel_families',
            'channels',
            'channel_packages_short',
            'packages_short',
            'packages',
            'source_packages',
            'errata',
            'blacklist_obsoletes',
            'kickstartable_trees',
            'product_names',
        ]
        self.client_version = \
                float(rhnFlags.get('X-RHN-Satellite-XML-Dump-Version'))
        self.system_id = None
        self._channel_family_query = """
            select channel_family_id, quantity
              from rhnSatelliteChannelFamily
             where server_id = :server_id
            union
            select pcf.channel_family_id, to_number(null) quantity
              from rhnPublicChannelFamily pcf
        """

    def auth_system(self, system_id):
        log_debug(3)
        rhnHandler.auth_system(self, system_id)
        if not self.server.checkSatEntitlement():
            raise rhnFault(3006)
        if not self.server.validateSatCert():
            raise rhnFault(3006, "Satellite Cert expired")

    # XML-RPC exposed functions
    def blacklist_obsoletes(self, system_id):
        self.auth_system(system_id)
        return self.dump_blacklist_obsoletes()

    def arches(self, system_id):
        self.auth_system(system_id)
        self._get_satellite_server_groups(self.server_id)

        return self.dump_arches(rpm_arch_type_only=0)

    def arches_extra(self, system_id):
        self.auth_system(system_id)
        self._get_satellite_server_groups(self.server_id)
        # If older sats filter out virt stuff from export
        if self.client_version < constants.VIRT_SUPPORTED_VERSION:
            return self.dump_server_group_type_server_arches(
                    rpm_arch_type_only=0, virt_filter=1)
        else:
            return self.dump_server_group_type_server_arches(
                    rpm_arch_type_only=0, virt_filter=0)

    def channel_families(self, system_id):
        self.auth_system(system_id)
        if self.client_version < constants.VIRT_SUPPORTED_VERSION:
            return self.dump_channel_families(virt_filter=1)
        else:
            return self.dump_channel_families()

    def channels(self, system_id, channel_labels=[]):
        self.auth_system(system_id)
        return self.dump_channels(channel_labels=channel_labels)

    def channel_packages_short(self, system_id, channel_label, last_modified):
        self.auth_system(system_id)
        return self.dump_channel_packages_short(channel_label, last_modified)

    def packages_short(self, system_id, packages):
        self.auth_system(system_id)
        return self.dump_packages_short(packages)

    def packages(self, system_id, packages):
        self.auth_system(system_id)
        return self.dump_packages(packages)

    def source_packages(self, system_id, packages):
        self.auth_system(system_id)
        return self.dump_source_packages(packages)

    def errata(self, system_id, errata):
        self.auth_system(system_id)
        return self.dump_errata(errata)

    def kickstartable_trees(self, system_id, kickstart_labels=[]):
        self.auth_system(system_id)
        return self.dump_kickstartable_trees(kickstart_labels=kickstart_labels)

    def product_names(self, system_id):
        self.auth_system(system_id)
        return self.dump_product_names()

    # Overriding some functions from the base class
    def get_channel_families_statement(self):
        log_debug(3, self.server_id)
        statement = dumper.XML_Dumper.get_channel_families_statement(self)
        statement.add_params(server_id=self.server_id)
        return statement

    def get_channels_statement(self):
        log_debug(3, self.server_id)
        statement = dumper.XML_Dumper.get_channels_statement(self)
        statement.add_params(server_id=self.server_id)
        return statement

    def get_packages_statement(self):
        log_debug(3, self.server_id)
        statement = dumper.XML_Dumper.get_packages_statement(self)
        statement.add_params(server_id=self.server_id)
        return statement

    def get_source_packages_statement(self):
        log_debug(3, self.server_id)
        statement = dumper.XML_Dumper.get_source_packages_statement(self)
        statement.add_params(server_id=self.server_id)
        return statement

    def get_errata_statement(self):
        log_debug(3, self.server_id)
        statement = dumper.XML_Dumper.get_errata_statement(self)
        statement.add_params(server_id=self.server_id)
        return statement

    _query_get_sat_server_groups = """
        select sgt.label server_group_label
          from rhnSatelliteServerGroup ssg, rhnServerGroupType sgt
         where ssg.server_id = :server_id
           and ssg.server_group_type = sgt.id
           and (ssg.max_members is null or ssg.max_members > 0)
           %s
    """

    # XXX noone seems to use the results of this method
    def _get_satellite_server_groups(self, server_id):
        # Check satellites that are not smart enough to understand
        # virt stuff and skip exporting virt stuff
        virt_filter_sql = ""
        if self.client_version < constants.VIRT_SUPPORTED_VERSION:
            virt_filter_sql = """and sgt.label not like 'virt%'"""

        h = rhnSQL.prepare(self._query_get_sat_server_groups % virt_filter_sql)
        h.execute(server_id=server_id)
        return [x['server_group_label'] for x in h.fetchall_dict() or []]

rpcClasses = {
    'dump'  : AuthenticatedDumper,
}
