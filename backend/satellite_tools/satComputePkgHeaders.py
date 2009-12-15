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
#
# From the _apache.py
# this is a dummy module that makes pychecker happy and provides
# the _apache module, whcih is normally provided by mod_python
# when a script runs under it

import sys
from optparse import OptionParser, Option

_path = "/usr/share/rhn"
if _path not in sys.path:
    sys.path.append(_path)


SERVER_RETURN = 0

def log_error(*args):
    pass

def make_table(*args):
    pass

def parse_qs(*args):
    pass
    
def parse_qsl(*args):
    pass

status = None
table = None
config_tree = None
server_root = None
mpm_query = None
exists_config_define=None

OK = 1

# End of _apache.py

sys.modules["_apache"] = sys.modules["__main__"]


from server import rhnSQL
from spacewalk.common import rhn_rpm

options_table = [
    Option("-v", "--verbose",       action="count", 
        help="Increase verbosity"),
    Option("-d", "--db",            action="store", 
        help="DB string to connect to"),
    Option("--commit",              action="store_true",
        help="Commit work"),
    Option("--backup-file",         action="store",
        help="Backup packages into this file"),
    Option("--prefix",              action="store",     default='/pub',
        help="Prefix to find files in"),
]

class Runner:
    def __init__(self):
        self.options = None
        self._channels_hash = None
        self._channel_packages = {}
        
    def main(self):
        parser = OptionParser(option_list=options_table)

        (self.options, args) = parser.parse_args()

        if not self.options.db:
            print "--db not specified"
            return 1

        rhnSQL.initDB(self.options.db)

        self._channels_hash = self._get_channels()

        package_ids = self._get_packages()
        if package_ids is None:
            return 1

        if self.options.backup_file:
            self._backup_packages(package_ids, self.options.backup_file)

        try:
            self._add_package_header_values(package_ids)
        except:
            rhnSQL.rollback()
            raise

        if self.options.commit:
            print "Commiting work"
            rhnSQL.commit()
        else:
            print "Rolling back"
            rhnSQL.rollback()


    def _get_packages(self):
        package_ids = {}

        h = rhnSQL.prepare(self._query_get_packages)
        for channel_id in self._channels_hash.values():
            h.execute(channel_id=channel_id)
            while 1:
                row = h.fetchone_dict()
                if not row:
                    break
                package_id = row['package_id']
                package_ids[package_id] = (row['path'], row['header_start'], row['header_end'])

        self._channel_packages = {}
        orphaned_packages = {}
        # Now, for each package, get the channels it's part of
        h = rhnSQL.prepare(self._query_get_channel_packages)
        for package_id in package_ids.keys():
            h.execute(package_id=package_id)
            while 1:
                row = h.fetchone_dict()
                if not row:
                    break
                channel_label = row['label']
                if self._channel_packages.has_key(package_id):
                    l = self._channel_packages[package_id]
                else:
                    l = self._channel_packages[package_id] = []
                l.append(channel_label)

                if not self._channels_hash.has_key(channel_label):
                    orphaned_packages[package_id] = None

        if orphaned_packages:
            print "Bailing out because of packages shared with other channels"
            for package_id in orphaned_packages.keys():
                channels = self._channel_packages[package_id]
                print package_id, channels
            return None

        return package_ids
            

    _query_get_channel_packages = rhnSQL.Statement("""
        select c.id, c.label
          from rhnChannel c,
               rhnChannelPackage cp
         where cp.package_id = :package_id
           and cp.channel_id = c.id
    """)

    _query_get_channels = rhnSQL.Statement("""
        select id, label from rhnChannel 
    """)
    def _get_channels(self):
        h = rhnSQL.prepare(self._query_get_channels)
        h.execute()

        ret = {}
        while 1:
            row = h.fetchone_dict()
            if not row:
                break
            ret[row['label']] = row['id']
        return ret

    _query_get_packages = rhnSQL.Statement("""
        select cp.package_id, p.path, p.header_start, p.header_end
          from rhnChannelPackage cp,
               rhnPackage p
         where cp.channel_id = :channel_id
           and cp.package_id = p.id
           and p.path is not null
           and p.header_start = -1
    """)

    _query_add_package_header_values = rhnSQL.Statement("""
        update rhnPackage 
           set header_start = :header_start,
               header_end = :header_end
         where id = :package_id
    """)

    def _add_package_header_values(self, package_ids):
        if not package_ids:
            return
        h = rhnSQL.prepare(self._query_add_package_header_values)
        for package_id, (path, header_start, header_end) in package_ids.items():
            try:
                p_file = file(self.options.prefix + "/" + path, 'r')
            except:
                print "Error opening file %s" % path
                continue

            try:
                (header_start, header_end) = rhn_rpm.get_header_byte_range(p_file);
            except Exception, e:
                print "Error reading header size from file %s: %s" % (path, e)

            try:
                h.execute(package_id=package_id, header_start=header_start, header_end=header_end)
            except rhnSQL.SQLError, e:
                pass

    def _backup_packages(self, package_ids, backup_file):
        f = open(backup_file, "w+")
        
        if not package_ids:
            return
        
        template = "update rhnPackage set header_start=%s and header_end=%s where id = %s;\n"
        for package_id, (path, header_start, header_end) in package_ids.items():
            s = template % (header_start, header_end, package_id)
            f.write(s)
        f.write("commit;\n")
        f.close()

if __name__ == '__main__':
    sys.exit(Runner().main() or 0)
