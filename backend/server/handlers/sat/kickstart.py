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
# Satellite only package downloading methods.

# system imports
import os
from rhn import rpclib

# common imports
from common import rhnFault, log_debug, log_error, CFG
from common.rhnTranslate import _

# server imports
from server import rhnSQL
from auth import Authentication

class Kickstart(Authentication):
    """Package fetcher for Spacewalk sync code.
    """
    def __init__(self):
        log_debug(3)
        Authentication.__init__(self)
        self.functions = [
            'get_ks_file',
        ]
        
    def get_ks_file(self, system_id, ks_label, relative_path):
        # Fetching a kickstart file
        log_debug(3)

        # Authenticate server 
        self.auth_system(system_id)

        h = rhnSQL.prepare("""
            select kst.id, kst.base_path, c.label channel_label
              from rhnKickstartableTree kst, rhnChannel c
             where kst.org_id is null
               and kst.label = :ks_label
               and kst.channel_id = c.id
        """)
        h.execute(ks_label=ks_label)
        row = h.fetchone_dict()
        if not row:
            raise rhnFault(2100, _("Kickstart tree %s not accessible") % 
                ks_label)

        channel_label = row['channel_label']

        self._auth_channel(channel_label)
        # All is good now

        ks_tree_id = row['id']
        ks_tree_base_path = row['base_path']

        # Try to get the file
        h = rhnSQL.prepare("""
            select 1
              from rhnKSTreeFile kstf
             where kstf.kstree_id = :ks_tree_id
               and kstf.relative_filename = :relative_path
        """)
        h.execute(ks_tree_id=ks_tree_id, relative_path=relative_path)
        row = h.fetchone_dict()
        if not row:
            raise rhnFault(2101, _("Kickstart file %s not found in tree %s") % 
                (relative_path, ks_label))

        path = os.path.normpath(os.path.join(CFG.MOUNT_POINT,
            ks_tree_base_path, relative_path))

        if not os.path.isfile(path):
            log_error("Unable to find kickstart file", path)
            raise rhnFault(2102, 
                _("Kickstart file %s (tree %s) not found on the disk") % (
                relative_path, ks_label))
            
        return rpclib.File(open(path, "r"))

