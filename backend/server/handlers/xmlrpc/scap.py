#
# Copyright (c) 2013 Red Hat, Inc.
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

import os
import stat
from base64 import decodestring

from spacewalk.common.rhnException import rhnFault
from spacewalk.common.rhnConfig import CFG
from spacewalk.common.rhnLog import log_error, log_debug
from spacewalk.server import rhnSQL
from spacewalk.server.rhnHandler import rhnHandler
from spacewalk.server.rhnLib import get_action_path, get_actionfile_path

class Scap(rhnHandler):
    def __init__(self):
        rhnHandler.__init__(self)
        self.functions.append('upload_result')

    def upload_result(self, system_id, action_id, scap_file):
        self.auth_system(system_id)
        self._authorize_request(action_id)

        required_keys = ['filename', 'filecontent', 'content-encoding']
        for k in required_keys:
            if not scap_file.has_key(k):
                log_debug(1, self.server_id, "The scap file data is invalid or incomplete: %s" % scap_file)
                raise rhnFault(5101, "Missing or invalid key: %s" % k)

        return self._store_file(action_id, scap_file)

    def _store_file(self, action_id, scap_file):
        r_dir = get_action_path(self.server.server['org_id'], self.server_id, action_id)
        if not r_dir:
            log_debug(1, self.server_id, "Error composing SCAP action directory path")
            raise rhnFault(5102)
        r_file = get_actionfile_path(self.server.server['org_id'], self.server_id, action_id, scap_file['filename'])
        if not r_file:
            log_debug(1, self.server_id, "Error composing SCAP action file path")
            raise rhnFault(5103)

        if not scap_file['content-encoding'] == 'base64':
            log_debug(1, self.server_id, "Invalid content encoding: %s" % scap_file['content-encoding'])
            raise rhnFault(5104)

        # Create the file on filer
        filecontent = decodestring(scap_file['filecontent'])
        # TODO assert for the size of the file

        absolute_dir = os.path.join(CFG.MOUNT_POINT, r_dir)
        absolute_file = os.path.join(absolute_dir, scap_file['filename'])

        if not os.path.exists(absolute_dir):
            log_debug(1, self.server_id, "Creating action directory: %s" % absolute_dir)
            os.makedirs(absolute_dir)
            mode = stat.S_IRWXU | stat.S_IRWXG | stat.S_IROTH | stat.S_IXOTH
            os.chmod(absolute_dir, mode)
            os.chmod(os.path.dirname(os.path.normpath(absolute_dir)), mode)
        log_debug(1, self.server_id, "Creating file: %s" % absolute_file)
        f = open(absolute_file, 'w+')
        f.write(filecontent)
        return {'result': True,
               }

    def _authorize_request(self, action_id):
        # Make sure that database contains records in
        #     rhnServerAction and rhnActionScap
        # and not contains records in
        #     rhnXccdfTestResult
        # for given (system_id, action_id) pair
        h = rhnSQL.prepare(_query_authorize_request)
        h.execute(server_id=self.server_id, action_id=action_id)
        exists = h.fetchone()
        if len(exists) != 1:
            raise rhnFault(50, _("Invalid system_id/action_id pair."))

_query_authorize_request = rhnSQL.Statement("""
select 1
    from rhnServerAction rsa,
         rhnActionScap ras
    where rsa.server_id = :server_id
      and rsa.action_id = :action_id
      and rsa.action_id = ras.action_id
      and rsa.status in (0, 1)
      and not exists
      (
          select rxt.id
            from rhnXccdfTestresult rxt
           where rxt.server_id = rsa.server_id
             and rxt.action_scap_id = ras.id
      )
""")
