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
# Kickstart a system using koan.
#

import traceback
import string
import sys

from koan.app import Koan

def initiate(kickstart_host, profile_name, base, extra_append, static_device=None, preserve_files=[]):

    error_messages = {}
    success = 0
    
    try:
        k = Koan()
        k.list_items          = False
        k.server              = kickstart_host
        k.is_virt             = False
        k.is_replace          = True
        k.is_display          = False
        k.profile             = profile_name
        k.system              = None
        k.image               = None
        k.live_cd             = None
        k.virt_path           = None
        k.virt_type           = None
        k.virt_bridge         = None
        k.no_gfx              = True
        k.add_reinstall_entry = None
        k.kopts_override      = None
        k.run()

    except Exception, e:
        (xa, xb, tb) = sys.exc_info()
        try:
            getattr(e,"from_koan")
            error_messages['from_koan'] = str(e)[1:-1]
            print str(e)[1:-1] # nice exception, no traceback needed
        except:
            print xa
            print xb
            print string.join(traceback.format_list(traceback.extract_tb(tb)))
            error_messages['koan'] = string.join(traceback.format_list(traceback.extract_tb(tb)))
        return (1, "Kickstart failed. Koan error.", error_messages)

    
    return (0, "Kickstart initiate succeeded", error_messages)
