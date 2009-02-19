#!/usr/bin/python
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
import os.path

from config_common import handler_base, utils
from config_common.rhn_log import log_debug

class HandlerBase(handler_base.HandlerBase):
    def get_dest_file(self, file):
        target_dir = os.sep
        return utils.normalize_path(target_dir + os.sep + file)

    # Returns a list of valid files
    def get_valid_files(self):
        files_hash = {}
        for file in self.repository.list_files():
            files_hash[file[1]] = None

        if not self.args:
            # No file specified; use all of them
            files = files_hash.keys()
            files.sort()
            return files

        files = []
        for file in self.args:
            #5/9/05 wregglej - 151197 make sure that trailing /'s aren't passed through for directories.
            if os.path.isdir(file):
                if file[-1] == "/":
                    file = file[0:-1]

            if not files_hash.has_key(file):
                print "Not found on server: %s" % file
                continue
            files.append(file)
        files.sort()
        return files

    # Main function to be run
    def run(self):
        log_debug(2)
        for file in self.get_valid_files():
            (src, file_info, dirs_created) = self.repository.get_file_info(file)

            ftype = file_info.get('filetype')

            if not src:
                continue

            dst = self.get_dest_file(file)

            self._process_file(src, dst, file, ftype, file_info)

    # To be overridden with specific actions in subclasses
    def _process_file(self, *args):
        pass

class TopdirHandlerBase(HandlerBase):
    _options_table = [
        HandlerBase._option_class(
            '--topdir',     action="store",
            help="Make all file operations relative to this directory.",
        ),
        HandlerBase._option_class(
            '--exclude',    action="append",
            help="Excludes a file from being deployed with 'get'. May be used multiple times.",
        ),
    ]

    def get_dest_file(self, file):
        target_dir = self.options.topdir or os.sep
        return utils.normalize_path(target_dir + os.sep + file)
