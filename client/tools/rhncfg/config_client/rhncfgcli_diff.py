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

import sys
import os
import os.path
from config_common import utils
from config_common.rhn_log import log_debug

import handler_base

class Handler(handler_base.HandlerBase):
    _usage_options = handler_base.HandlerBase._usage_options + " [ files ... ]"
    def _process_file(self, *args):
        src, dst= args [:2]
        type = args[3]
        # label for diff output.  this lets 'patch -R' properly apply
        # a patch to update to known version and have proper lsdiff
        # output.  also gets rid of /tmp/@blah in diff output.        
        label = dst
    
        if type == 'directory':
            #dst is a directory, so just tell the user we're skipping the entry
            print "Entry \'%s\' is a directory, skipping" % dst
        elif type == 'symlink':
            #dst is a symlink, so just tell the user we're skipping the entry
            srclink = os.path.abspath(os.readlink(src))
            destlink = os.path.abspath(os.readlink(dst))
            if srclink == destlink:
                print "No change between the symbolic links '%s' " % dst
            else:
                print "Symbolic link targets are different."
                print "Channel: '%s' -> '%s'   System: '%s' -> '%s' " % (dst,srclink, dst, destlink) 
                
    	else:
            # if file isn't present, compare to /dev/null so we see the
            # whole thing in the diff        
            if not os.access(dst, os.R_OK):
            	dst = "/dev/null"
    
    	     # Test -L and -u options to diff
            diffcmd = "/usr/bin/diff -L %s -u" % (label,)
            dst = '"' + dst + '"'
            pipe = os.popen("%s %s %s 2>/dev/null" % (diffcmd, src, dst))
            pipe.read()  # Read the output so GNU diff is happy
            ret = pipe.close()
            if ret == None: ret = 0
            ret = ret/256  # Return code in upper byte
            if ret == 2:  # error in diff call
                diffcmd = "/usr/bin/diff -c"
    
            pipe = os.popen("%s %s %s" % (diffcmd, src, dst))
            sys.stdout.write(pipe.read())
