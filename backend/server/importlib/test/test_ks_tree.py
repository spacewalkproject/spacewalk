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

from server import rhnSQL
from server.importlib.importLib import KickstartableTree, KickstartFile
from server.importlib.kickstartImport import KickstartableTreeImport
from server.importlib.backendOracle import OracleBackend

ks_trees = [
    KickstartableTree().populate({
        'channel'       : 'redhat-linux-i386-8.0',
        'base_path'     : 'foo/bar/baz',
        'label'         : 'redhat-linux-i386-8.0',
        'boot_image'    : 'ks-rh',
        'files'         : [
            KickstartFile().populate({
                'relative_path' : 'foo/foo1',
                'checksum_type' : 'md5',
                'checksum'      : 'axbycz',
                'last_modified' : '2003-10-11 12:13:14',
                'file_size'     : 12345,
            }),
            KickstartFile().populate({
                'relative_path' : 'foo/foo4',
                'checksum_type' : 'md5',
                'checksum'      : 'axbycz',
                'last_modified' : '2003-10-11 12:13:14',
                'file_size'     : 123456,
            }),
            KickstartFile().populate({
                'relative_path' : 'foo/foo3',
                'checksum_type' : 'md5',
                'checksum'      : 'axbycz',
                'last_modified' : '2003-10-11 12:13:14',
                'file_size'     : 1234567,
            }),
        ],
    }),
]

rhnSQL.initDB("rhnuser/rhnuser@webdev")

backend = OracleBackend()
backend.init()

ki = KickstartableTreeImport(ks_trees, backend)
ki.run()
