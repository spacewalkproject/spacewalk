#
# Copyright (c) 2012 Red Hat, Inc.
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

import base64
import os

from spacewalk.common.rhnException import rhnFault
from spacewalk.common.rhnConfig import CFG
from spacewalk.common.rhnLog import log_debug
from spacewalk.server import rhnSQL
from spacewalk.server.rhnHandler import rhnHandler
from spacewalk.server.rhnLib import get_crash_path, get_crashfile_path

_query_get_crash = rhnSQL.Statement("""
select id
  from rhnServerCrash
 where server_id = :server_id and
       crash = :crash
""")

_query_create_crash = rhnSQL.Statement("""
insert into rhnServerCrash (
       id,
       server_id,
       crash,
       path,
       count)
values (
       sequence_nextval('rhn_server_crash_id_seq'),
       :server_id,
       :crash,
       :path,
       :crash_count)
""")

_query_update_pkg_data = rhnSQL.Statement("""
update rhnServerCrash
   set package_name_id = lookup_package_name(:pkg_name),
       package_evr_id = lookup_evr(:pkg_epoch, :pkg_version, :pkg_release),
       package_arch_id = lookup_package_arch(:pkg_arch)
 where id = :crash_id
""")

_query_update_watched_items = """
update rhnServerCrash
   set %s = :filecontent
 where id = :crash_id
"""

_query_update_crash_count = """
update rhnServerCrash
   set count = :crash_count
 where server_id = :server_id and
       crash = :crash
"""

_query_get_crashfile_sizelimit = """
select crash_file_sizelimit
  from web_customer
 where id = :org_id
"""

class Abrt(rhnHandler):
    def __init__(self):
        rhnHandler.__init__(self)
        self.functions.append('create_crash')
        self.functions.append('update_crash_count')
        self.functions.append('upload_crash_file')

        self.watched_items = ['analyzer',
                              'architecture',
                              'cmdline',
                              'component',
                              'count',
                              'executable',
                              'kernel',
                              'reason',
                              'username']

    def _get_crash_id(self, server_id, crash):
        h = rhnSQL.prepare(_query_get_crash)
        h.execute(server_id = self.server_id, crash = crash)
        r = h.fetchall_dict()

        if (r is None):
            return None
        else:
            return r[0]['id']

    def _create_or_update_crash_file(self, server_id, crash_id, filename, path, filesize):
        insert_call = rhnSQL.Function("insert_crash_file", rhnSQL.types.NUMBER())
        return insert_call(crash_id, filename, path, filesize)

    def _update_package_data(self, crash_id, pkg_data):
        for item in ['pkg_name', 'pkg_epoch', 'pkg_version', 'pkg_release', 'pkg_arch']:
            if not (pkg_data.has_key(item) and pkg_data[item]):
                return 0

        log_debug(1, "_update_package_data: %s, %s" % (crash_id, pkg_data))
        h = rhnSQL.prepare(_query_update_pkg_data)
        r = h.execute(
            crash_id = crash_id,
            pkg_name = pkg_data['pkg_name'],
            pkg_epoch = pkg_data['pkg_epoch'],
            pkg_version = pkg_data['pkg_version'],
            pkg_release = pkg_data['pkg_release'],
            pkg_arch = pkg_data['pkg_arch'])
        rhnSQL.commit()

        return r

    def _get_crashfile_sizelimit(self):
        h = rhnSQL.prepare(_query_get_crashfile_sizelimit)
        h.execute(org_id = self.server.server['org_id'])
        return h.fetchall_dict()[0]['crash_file_sizelimit']

    def create_crash(self, system_id, crash_data, pkg_data):
        self.auth_system(system_id)
        log_debug(1, self.server_id, crash_data, pkg_data)

        if not (crash_data.has_key('crash') and crash_data.has_key('path')) or \
           not (crash_data['crash'] and crash_data['path']):
            log_debug(1, self.server_id, "The crash information is invalid or incomplete: %s" % str(crash_data))
            raise rhnFault(5000)

        crash_id = self._get_crash_id(self.server_id, crash_data['crash'])
        log_debug(1, "crash_id: %s" % crash_id)

        if (crash_id is None):
            if not crash_data.has_key('count'):
                crash_data['count'] = 1

            h = rhnSQL.prepare(_query_create_crash)
            h.execute(
                server_id = self.server_id,
                crash = crash_data['crash'],
                path = crash_data['path'],
                crash_count = crash_data['count'])
            rhnSQL.commit()
            self._update_package_data(self._get_crash_id(self.server_id, crash_data['crash']), pkg_data)
            return 1
        else:
            return 0

    def upload_crash_file(self, system_id, crash, crash_file):
        self.auth_system(system_id)

        required_keys = ['filename', 'path', 'filesize', 'filecontent', 'content-encoding']
        for k in required_keys:
            if not (crash_file.has_key(k)):
                log_debug(1, self.server_id, "The crash file data is invalid or incomplete: %s" % crash_file)
                raise rhnFault(5001, "Missing or invalid key: %s" % k)

        log_debug(1, self.server_id, crash, crash_file['filename'])

        server_org_id = self.server.server['org_id']
        server_crash_dir = get_crash_path(str(server_org_id), str(self.server_id), crash)
        if not server_crash_dir:
            log_debug(1, self.server_id, "Error composing crash directory path")
            raise rhnFault(5002)

        server_filename = get_crashfile_path(str(server_org_id),
                                             str(self.server_id),
                                             crash,
                                             crash_file['filename'])
        if not server_filename:
            log_debug(1, self.server_id, "Error composing crash file path")
            raise rhnFault(5003)

        if not crash_file['content-encoding'] == 'base64':
            log_debug(1, self.server_id, "Invalid content encoding: %s" % crash_file['content-encoding'])
            raise rhnFault(5004, "Invalid content encodig: %s" % crash_file['content-encoding'])

        crash_id = self._get_crash_id(self.server_id, crash)
        if not crash_id:
            log_debug(1, self.server_id, "No record for crash: %s" % crash)
            raise rhnFault(5005, "Invalid crash name: %s" % crash)

        # Create or update the crash file record in DB
        self._create_or_update_crash_file(self.server_id, crash_id, crash_file['filename'], \
                                          crash_file['path'], crash_file['filesize'])
        rhnSQL.commit()

        # Create the file on filer
        filecontent = base64.decodestring(crash_file['filecontent'])
        filesize = len(filecontent)
        sizelimit = self._get_crashfile_sizelimit()
        if filesize > sizelimit and sizelimit != 0:
            log_debug(1, "The file [%s] size (%s bytes) is more than allowed (%s bytes), skipping." \
                % (crash_file['path'], filesize, sizelimit))
            return 0
        absolute_dir = os.path.join(CFG.MOUNT_POINT, server_crash_dir)
        absolute_file = os.path.join(absolute_dir, crash_file['filename'])

        if not os.path.exists(absolute_dir):
            log_debug(1, self.server_id, "Creating crash directory: %s" % absolute_dir)
            os.makedirs(absolute_dir)

        log_debug(1, self.server_id, "Creating crash file: %s" % absolute_file)
        f = open(absolute_file, 'w+')
        f.write(filecontent)
        f.close()

        if crash_file['filename'] in self.watched_items:
            st = rhnSQL.Statement(_query_update_watched_items % crash_file['filename'])
            h = rhnSQL.prepare(st)
            h.execute(filecontent = filecontent, crash_id = crash_id)
            rhnSQL.commit()

        return 1

    def update_crash_count(self, system_id, crash, crash_count):
        self.auth_system(system_id)

        log_debug(1, self.server_id, "Updating crash count for %s to %s" % (crash, crash_count))

        server_org_id = self.server.server['org_id']
        server_crash_dir = get_crash_path(str(server_org_id), str(self.server_id), crash)
        if not server_crash_dir:
            log_debug(1, self.server_id, "Error composing crash directory path")
            raise rhnFault(5002)

        h = rhnSQL.prepare(_query_update_crash_count)
        r = h.execute(
            crash_count = crash_count,
            server_id = self.server_id,
            crash = crash)
        rhnSQL.commit()

        if r == 0:
            log_debug(1, self.server_id, "No record for crash: %s" % crash)
            raise rhnFault(5005, "Invalid crash name: %s" % crash)

        absolute_dir = os.path.join(CFG.MOUNT_POINT, server_crash_dir)
        absolute_file = os.path.join(absolute_dir, 'count')

        log_debug(1, self.server_id, "Updating crash count file: %s" % absolute_file)
        f = open(absolute_file, 'w+')
        f.write(crash_count)
        f.close()

        return 1
