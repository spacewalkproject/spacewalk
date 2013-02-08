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
from spacewalk.server import rhnSQL

from spacewalk.satellite_tools.exporter import xmlWriter, exportLib

rhnSQL.initDB()

writer = xmlWriter.XMLWriter(skip_xml_decl=1)

r=0

e = exportLib.SatelliteDumper(writer,
        exportLib.ChannelArchesDumper(writer, rpm_arch_type_only=r),
        exportLib.PackageArchesDumper(writer, rpm_arch_type_only=r),
        exportLib.ServerArchesDumper(writer, rpm_arch_type_only=r),
        exportLib.CPUArchesDumper(writer),
        exportLib.ServerPackageArchCompatDumper(writer, rpm_arch_type_only=r),
        exportLib.ServerChannelArchCompatDumper(writer, rpm_arch_type_only=r),
        exportLib.ChannelPackageArchCompatDumper(writer, rpm_arch_type_only=r),
)
e.dump()
