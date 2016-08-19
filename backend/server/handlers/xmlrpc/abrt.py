#
# Copyright (c) 2012--2016 Red Hat, Inc.
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
import stat

from spacewalk.common.rhnException import rhnFault
from spacewalk.common.rhnConfig import CFG
from spacewalk.common.rhnLib import parseRPMName
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
       count,
       storage_path)
values (
       sequence_nextval('rhn_server_crash_id_seq'),
       :server_id,
       :crash,
       :path,
       :crash_count,
       :storage_path)
""")

_query_update_pkg_data1 = rhnSQL.Statement("""
update rhnServerCrash
   set package_name_id = lookup_package_name(:pkg_name),
       package_evr_id = lookup_evr(:pkg_epoch, :pkg_version, :pkg_release)
 where id = :crash_id
""")

_query_update_pkg_data2 = rhnSQL.Statement("""
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
  from rhnOrgConfiguration
 where org_id = :org_id
"""

_query_set_crashfile_upload_flag = """
update rhnServerCrashFile
   set is_uploaded = 'Y'
 where id = (
       select scf.id as id
         from rhnServerCrashFile scf,
              rhnServerCrash sc
        where scf.crash_id = sc.id and
              scf.crash_id = :crash_id and
              sc.server_id = :server_id and
              scf.filename = :filename and
              scf.path = :path and
              scf.filesize = :filesize
       )
"""

_query_get_crash_reporting_settings = """
select crash_reporting_enabled
  from rhnOrgConfiguration
 where org_id = :org_id
"""

_query_get_crashfile_upload_settings = """
select crashfile_upload_enabled
  from rhnOrgConfiguration
 where org_id = :org_id
"""


class Abrt(rhnHandler):

    def __init__(self):
        rhnHandler.__init__(self)
        self.functions.append('create_crash')
        self.functions.append('update_crash_count')
        self.functions.append('upload_crash_file')
        self.functions.append('is_crashfile_upload_enabled')
        self.functions.append('get_crashfile_uploadlimit')

        self.watched_items = ['analyzer',
                              'architecture',
                              'cmdline',
                              'component',
                              'count',
                              'executable',
                              'kernel',
                              'reason',
                              'username',
                              'uuid']

    def _get_crash_id(self, server_id, crash):
        h = rhnSQL.prepare(_query_get_crash)
        h.execute(server_id=self.server_id, crash=crash)
        r = h.fetchall_dict()

        if (r is None):
            return None
        else:
            return r[0]['id']

    def _create_or_update_crash_file(self, server_id, crash_id, filename, path, filesize):
        insert_call = rhnSQL.Function("insert_crash_file", rhnSQL.types.NUMBER())
        return insert_call(crash_id, filename, path, filesize)

    def _update_package_data(self, crash_id, pkg_data):
        log_debug(1, "_update_package_data: %s, %s" % (crash_id, pkg_data))
        # Older versions of abrt used to store the package info in a single 'package' file
        if pkg_data and 'package' in pkg_data:
            (n, e, v, r) = parseRPMName(pkg_data['package'])
            if not all((n, e, v, r)):
                return 0

            h = rhnSQL.prepare(_query_update_pkg_data1)
            r = h.execute(
                crash_id=crash_id,
                pkg_name=n,
                pkg_epoch=e,
                pkg_version=v,
                pkg_release=r)
            rhnSQL.commit()

            return r

        for item in ['pkg_name', 'pkg_epoch', 'pkg_version', 'pkg_release', 'pkg_arch']:
            if not (item in pkg_data and pkg_data[item]):
                return 0

        h = rhnSQL.prepare(_query_update_pkg_data2)
        r = h.execute(
            crash_id=crash_id,
            pkg_name=pkg_data['pkg_name'],
            pkg_epoch=pkg_data['pkg_epoch'],
            pkg_version=pkg_data['pkg_version'],
            pkg_release=pkg_data['pkg_release'],
            pkg_arch=pkg_data['pkg_arch'])
        rhnSQL.commit()

        return r

    def _get_crashfile_sizelimit(self):
        h = rhnSQL.prepare(_query_get_crashfile_sizelimit)
        h.execute(org_id=self.server.server['org_id'])
        return h.fetchall_dict()[0]['crash_file_sizelimit']

    def _set_crashfile_upload_flag(self, server_id, crash_id, filename, path, filesize):
        h = rhnSQL.prepare(_query_set_crashfile_upload_flag)
        r = h.execute(
            server_id=server_id,
            crash_id=crash_id,
            filename=filename,
            path=path,
            filesize=filesize)
        rhnSQL.commit()

        return r

    def _is_crash_reporting_enabled(self, org_id):
        h = rhnSQL.prepare(_query_get_crash_reporting_settings)
        h.execute(org_id=org_id)
        r = h.fetchall_dict()

        if (r[0]['crash_reporting_enabled'] == 'Y'):
            return True
        else:
            return False

    def _is_crashfile_uploading_enabled(self, org_id):
        h = rhnSQL.prepare(_query_get_crashfile_upload_settings)
        h.execute(org_id=org_id)
        r = h.fetchall_dict()

        if (r[0]['crashfile_upload_enabled'] == 'Y'):
            return True
        else:
            return False

    def _check_crash_reporting_setting(self):
        if not self._is_crash_reporting_enabled(self.server.server['org_id']):
            log_debug(1, "Crash reporting is disabled for this server's organization.")
            raise rhnFault(5006)

    def create_crash(self, system_id, crash_data, pkg_data):
        self.auth_system(system_id)
        log_debug(1, self.server_id, crash_data, pkg_data)

        self._check_crash_reporting_setting()

        if not ('crash' in crash_data and 'path' in crash_data) or \
           not (crash_data['crash'] and crash_data['path']):
            log_debug(1, self.server_id, "The crash information is invalid or incomplete: %s" % str(crash_data))
            raise rhnFault(5000)

        server_org_id = self.server.server['org_id']
        server_crash_dir = get_crash_path(str(server_org_id), str(self.server_id), crash_data['crash'])
        if not server_crash_dir:
            log_debug(1, self.server_id, "Error composing crash directory path")
            raise rhnFault(5002)

        crash_id = self._get_crash_id(self.server_id, crash_data['crash'])
        log_debug(1, "crash_id: %s" % crash_id)

        if (crash_id is None):
            if 'count' not in crash_data:
                crash_data['count'] = 1

            h = rhnSQL.prepare(_query_create_crash)
            h.execute(
                server_id=self.server_id,
                crash=crash_data['crash'],
                path=crash_data['path'],
                crash_count=crash_data['count'],
                storage_path=server_crash_dir)
            rhnSQL.commit()
            self._update_package_data(self._get_crash_id(self.server_id, crash_data['crash']), pkg_data)
            return 1
        else:
            return 0

    def upload_crash_file(self, system_id, crash, crash_file):
        self.auth_system(system_id)
        self._check_crash_reporting_setting()

        required_keys = ['filename', 'path', 'filesize', 'filecontent', 'content-encoding']
        for k in required_keys:
            if k not in crash_file:
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
        self._create_or_update_crash_file(self.server_id, crash_id, crash_file['filename'],
                                          crash_file['path'], crash_file['filesize'])
        rhnSQL.commit()

        # Create the file on filer
        if not self._is_crashfile_uploading_enabled(server_org_id):
            return 1
        filecontent = base64.decodestring(crash_file['filecontent'])
        claimed_filesize = crash_file['filesize']
        filesize = len(filecontent)
        sizelimit = self._get_crashfile_sizelimit()
        if (claimed_filesize > sizelimit or filesize > sizelimit) and sizelimit != 0:
            if filesize == 0:
                filesize = claimed_filesize
            log_debug(1, "The file [%s] size (%s bytes) is more than allowed (%s bytes), skipping."
                      % (crash_file['path'], filesize, sizelimit))
            return 0
        absolute_dir = os.path.join(CFG.MOUNT_POINT, server_crash_dir)
        absolute_file = os.path.join(absolute_dir, crash_file['filename'])

        if not os.path.exists(absolute_dir):
            log_debug(1, self.server_id, "Creating crash directory: %s" % absolute_dir)
            os.makedirs(absolute_dir)
            mode = stat.S_IRWXU | stat.S_IRWXG | stat.S_IROTH | stat.S_IXOTH
            os.chmod(absolute_dir, mode)
            os.chmod(os.path.dirname(os.path.normpath(absolute_dir)), mode)

        log_debug(1, self.server_id, "Creating crash file: %s" % absolute_file)
        f = open(absolute_file, 'w+')
        f.write(filecontent)
        f.close()

        self._set_crashfile_upload_flag(self.server_id, crash_id, crash_file['filename'],
                                        crash_file['path'], crash_file['filesize'])

        if crash_file['filename'] in self.watched_items:
            # 'username' contains an extra '\n' at the end
            if crash_file['filename'] == 'username':
                filecontent = filecontent.strip()
            st = rhnSQL.Statement(_query_update_watched_items % crash_file['filename'])
            h = rhnSQL.prepare(st)
            h.execute(filecontent=filecontent, crash_id=crash_id)
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
            crash_count=crash_count,
            server_id=self.server_id,
            crash=crash)
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

    def is_crashfile_upload_enabled(self, system_id):
        self.auth_system(system_id)
        return self._is_crashfile_uploading_enabled(self.server.server['org_id'])

    def get_crashfile_uploadlimit(self, system_id):
        self.auth_system(system_id)
        return self._get_crashfile_sizelimit()
