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
import os

import handler_base
from config_common.file_utils import diff

class Handler(handler_base.HandlerBase):
    _usage_options = handler_base.HandlerBase._usage_options + " [ files ... ]"
    def _process_file(self, *args):
        src, dst= args [:2]
        type = args[3]
    
        if type == 'symlink':
            #dst is a symlink, so just tell the user we're skipping the entry
            srclink = os.path.abspath(os.readlink(src))
            destlink = os.path.abspath(os.readlink(dst))
            if srclink != destlink:
                print "Symbolic links differ. Channel: '%s' -> '%s'   System: '%s' -> '%s' " % (dst,srclink, dst, destlink) 
    	elif type == 'file':
            sys.stdout.write(''.join(diff(src, dst, srcname=dst, dstname=dst)))
