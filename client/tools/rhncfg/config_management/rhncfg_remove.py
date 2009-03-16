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
from config_common import handler_base, utils, cfg_exceptions, repository
from config_common.rhn_log import log_debug, die

class Handler(handler_base.HandlerBase):
    _usage_options = "[options] file [ file ... ]"
    
    _options_table = handler_base.HandlerBase._options_table + [
        handler_base.HandlerBase._option_class(
            '-c', '--channel',      action="store",
             help="Remove files from this config channel",
         ),
        handler_base.HandlerBase._option_class(
            '-t', '--topdir',       action="store",
             help="Make all files relative to this string",
         ),
    ]

    def run(self):
        log_debug(2)
        r = self.repository

        if len(self.args) == 0:
            die(0, "No files supplied (use --help for help)")

        channel = self.options.channel

        if not channel:
            die(6, "Config channel not specified")

        r = self.repository
        if not r.config_channel_exists(channel):
            die(6, "Error: config channel %s does not exist" % channel)

        files = map(utils.normalize_path, self.args)

        files_to_remove = []
        if self.options.topdir:
            if not os.path.isdir(self.options.topdir):
                die(8, "--topdir specified, but `%s' not a directory" %
                    self.options.topdir)
            for f in files:
                if not utils.startswith(f, self.options.topdir):
                    die(8, "--topdir %s specified, but file `%s' doesn't comply"
                        % (self.options.topdir, f))
                files_to_remove.append((f, f[len(self.options.topdir):]))
        else:
            for f in files:
                files_to_remove.append((f, f))

        print "Removing from config channel %s" % channel
        for (local_file, remote_file) in files_to_remove:
            try:
                r.remove_file(channel, remote_file)
            except repository.rpclib.Fault, e:
                if e.faultCode == -4011:
                    print "%s does not exist" % remote_file
                    continue
                raise e
            else:
                print "%s removed" % remote_file
