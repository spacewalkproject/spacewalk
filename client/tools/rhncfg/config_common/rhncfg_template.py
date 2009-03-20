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

_config_libs_path = '/var/www/rhns'
import sys
if _config_libs_path not in sys.path:
    sys.path.append(_config_libs_path)

from config_libs import templated_document

class ClientTemplatedDocument(templated_document.TemplatedDocument):
    def set_functions(self):
        self.functions.clear()
        self.functions.update({
            'hostname'      : self.get_hostname,
        })

    def get_hostname(self):
        import socket
        return socket.gethostname()

    def call(self, fname, params, defval):
        if not self.functions.has_key(fname):
            if defval:
                return defval
            raise ValueError, "Cannot expand macro %s" % fname
        f = self.functions[fname]
        if params is None:
            params = ()
        return str(apply(f, params))

