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

from config_common import handler_base, cfg_exceptions
from config_common.rhn_log import log_debug, die

class Handler(handler_base.HandlerBase):
    _usage_options = "config_channel [ config_channel ... ]"
    def run(self):
        log_debug(2)
        r = self.repository

        if len(self.args) == 0:
            die(5, "No config channels specified")

        for config_channel in self.args:
            print "Removing config channel %s" % config_channel
            try:
                r.remove_config_channel(config_channel)
            except cfg_exceptions.ConfigChannelNotInRepo:
                die("Config channel %s does not exist" % config_channel)
            except cfg_exceptions.ConfigChannelNotEmptyError:
                die("Could not remove non-empty config channel %s" % 
                    config_channel)
            print "Config channel %s removed" % config_channel
