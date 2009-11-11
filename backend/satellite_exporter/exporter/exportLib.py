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

from satellite_tools.exporter import exportLib

from server import rhnSQL


#class _PackageDumper(BaseRowDumper):
#    tag_name = 'rhn-package'
#
#    def set_attributes(self):
#        attrs = ["name", "version", "release", "package_arch",
#            "package_group", "rpm_version", "package_size", "payload_size",
#            "build_host", "source_rpm", "md5sum", "payload_format",
#            "compat", "cookie", "org_id"]
#        attrdict = {
#            'id'            : "rhn-package-%s" % self._row['id'],
#            'epoch'         : self._row['epoch'] or "",
#            'build-time'    : _dbtime2timestamp(self._row['build_time']),
#            'last-modified' : _dbtime2timestamp(self._row['last_modified']),
#        }
#        for attr in attrs:
#            attrdict[attr.replace('_', '-')] = self._row[attr]
#        return attrdict
#


