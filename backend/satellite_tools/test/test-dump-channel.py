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
import sys
import StringIO
from spacewalk.server import rhnSQL
from spacewalk.satellite_tools import xmlSource
from spacewalk.satellite_tools.exporter import xmlWriter, exportLib

rhnSQL.initDB()

s = StringIO.StringIO()
writer = xmlWriter.XMLWriter(stream=s)

channels = ['redhat-advanced-server-i386']

class ChannelsDumper(exportLib.ChannelsDumper):
    _query_list_channels = rhnSQL.Statement("""
        select c.id, c.label, ca.label channel_arch, c.basedir, c.name,
               c.summary, c.description,
               TO_CHAR(c.last_modified, 'YYYYMMDDHH24MISS') last_modified,
               pc.label parent_channel
          from rhnChannel c left outer join rhnChannel pc on c.parent_channel = pc.id,
               rhnChannelArch ca
         where c.label = :channel
           and c.channel_arch_id = ca.id
    """)

    def set_iterator(self):
        h = rhnSQL.prepare(self._query_list_channels)
        h.execute(channel = self._channels[0])
        return h

e = exportLib.SatelliteDumper(writer,
        ChannelsDumper(writer, channels=channels),
)
e.dump()

print s.getvalue()
sys.exit(0)

cont = xmlSource.ChannelContainer()
handler = xmlSource.SatelliteDispatchHandler()
handler.set_container(cont)

s.seek(0, 0)
handler.process(s)

channel = cont.batch[0]
print channel['errata_timestamps']
print channel['source_packages']
