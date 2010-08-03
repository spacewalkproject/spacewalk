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

import os

from config_common import handler_base, utils, cfg_exceptions
from config_common.rhn_log import log_debug, die

class Handler(handler_base.HandlerBase):
    _usage_options = "(-t|--topdir=)<top-level-directory> [options] config_channel [ config_channel ... ]"

    _options_table = handler_base.HandlerBase._options_table + [
        handler_base.HandlerBase._option_class(
            '-t', '--topdir',       action="store",
             help="Directory all the file paths are relative to. This option must be set.",
         ),
    ]

    def run(self):
        log_debug(2)
        r = self.repository
        
        if not self.args:
            die(6, "No config channels specified")
        
        topdir = self.options.topdir
        if not topdir:
            die(7, "--topdir not specified")
            
        if not os.path.isdir(topdir):
            die(8, "--topdir specified, but `%s' not a directory" %
                topdir)
            
        for ns in self.args:
            if not r.config_channel_exists(ns):
                die(6, "Error: config channel %s does not exist" % ns)

            for file_path in r.list_files(ns):
                #5/11/05 wregglej - 157066 dirs_created now gets returned by get_file_info.
                (temp_file, info, dirs_created) = r.get_file_info(ns, file_path)
                dest_file = utils.join_path(topdir, ns, file_path)
                print "Deploying %s -> %s" % (file_path, dest_file)
                utils.copyfile_p(temp_file, dest_file)
                if info['filetype'] != 'symlink':
                    utils.set_file_info(dest_file, info)
