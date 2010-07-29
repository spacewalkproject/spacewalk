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

from config_common import utils
from config_common.rhn_log import log_debug, die

import handler_base

class Handler(handler_base.HandlerBase):
    def run(self):
        log_debug(2)
        r = self.repository

        files = r.list_files()

        if not files:
            die(1, "No managed files.")
            
        label = "Config Channel"
        maxlen = max(map(lambda s: len(s[0]), files))
        maxlen = max(maxlen, len(label)) + 2
        
        print "DoFoS %*s   %s" % (maxlen, label, "File")
        for file in files:
            # checking to see if the filetype is in the 'file' entry,
            # and if it is and that type is '1', it is a file
            if (len(file) < 3) or file[2] == 1:
                print "F %*s     %s" % (maxlen, file[0], file[1])
            elif file[2] == 2 : 
                # the filetype is a directory
                print "D %*s     %s" % (maxlen, file[0], file[1])
            else:
                print "S %*s     %s" % (maxlen, file[0], file[1])
