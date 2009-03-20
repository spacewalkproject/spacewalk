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

import string

from config_common import handler_base, cfg_exceptions
from config_common.rhn_log import log_debug, die

class Handler(handler_base.HandlerBase):
    _usage_options = "[options] file [ file ... ]"

    _options_table = handler_base.HandlerBase._options_table + [
        handler_base.HandlerBase._option_class(
            '-c', '--channel',      action="store",
             help="Use this config channel",
         ),
    ]
    def run(self):
        log_debug(2)
        r = self.repository

        channel = self.options.channel
        if not channel:
            die(6, "Config channel not specified")

        if not self.args:
            die(7, "No files specified")

        print "Analyzing files in config channel %s" % channel
        for f in self.args:
            if not r.has_file(channel, f):
                die(8, "Config channel %s does not contain file %s" % 
                    (channel, f))
            try:
                revisions = r.get_file_revisions(channel, f)
            except cfg_exceptions.RepositoryFileMissingError:
                print "%s: not in config channel" % f
                continue
            print "%s: %s" % (f, string.join(map(str, revisions)))
