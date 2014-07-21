#
# Copyright (c) 2008--2013 Red Hat, Inc.
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

import handler_base
from config_common.deploy import deploy_files

class Handler(handler_base.TopdirHandlerBase):
    _usage_options = handler_base.HandlerBase._usage_options + " [ files ... ]"
    def run(self):
        deploy_files(self.options.topdir,
                     self.repository,
                     self.get_valid_files(),
                     self.options.exclude)



