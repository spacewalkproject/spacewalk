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

from config_common import handler_base, utils, cfg_exceptions
from config_common.rhn_log import log_debug, die

class Handler(handler_base.HandlerBase):
    _usage_options = "[options] file"
    _options_table = [
        handler_base.HandlerBase._option_class(
            '-c', '--channel',    action="append",
             help="Use this config channel",
         ),
        handler_base.HandlerBase._option_class(
            '-r', '--revision',     action="append",
             help="Use this revision",
         ),
    ]
    def run(self):
        log_debug(2)
        r = self.repository

        if len(self.args) != 1:
            die(3, "One file needs to be specified")

        path = self.args[0]

        channel_dst = None
        ns_count = len(self.options.channel or [])
        if ns_count == 0:
            die(3, "At least one config channel has to be specified")

        channel_src = self.options.channel[0]
        if ns_count > 2:
            die(3, "At most two config channels can be specified")

        if not r.config_channel_exists(channel_src):
            die(4, "Source config channel %s does not exist" % channel_src)

        if ns_count == 2:
            channel_dst = self.options.channel[1]

            if not r.config_channel_exists(channel_dst):
                die(4, "Config channel %s does not exist" % channel_dst)

        revision_dst = None
        rev_count = len(self.options.revision or [])
        if rev_count == 0:
            die(3, "At least one revision has to be specified")

        revision_src = self.options.revision[0]
        if rev_count > 2:
            die(3, "At most two revisions can be specified")

        if rev_count == 2:
            revision_dst = self.options.revision[1]

        try:
            result = r.diff_file_revisions(path, channel_src,
                revision_src, channel_dst, revision_dst)
        except cfg_exceptions.RepositoryFileMissingError, e:
            die(2, e[0])
        except cfg_exceptions.BinaryFileDiffError, e:
            die(3, e[0])
        
        sys.stdout.write(result)
