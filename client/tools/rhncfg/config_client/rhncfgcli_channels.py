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
from config_common.rhn_rpc import rpclib

import handler_base

class Handler(handler_base.HandlerBase):
    def run(self):
        log_debug(2)
        r = self.repository

        config_channels = r.load_config_channels()
        if not config_channels:
            print "(no config channels associated with this system)"
            return
        print "Config channels:"
        templ = "%-32s%s"
        label = "Label"
        name = "Name"
        print templ % (label, name)
        print templ % ('-' * len(label), '-' * len(name))
        for c in config_channels:
            print templ % (c['label'], c['name'])
