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
#
# Package uploading functions.
# Package info checking routines.
#

from spacewalk.common import RPC_Base, log_debug
from spacewalk.server.handlers.app.packages import Packages as APP_Packages

class Packages(APP_Packages):
    def __init__(self):
        log_debug(3)
        RPC_Base.__init__(self)        
        self.functions.append('uploadPackageInfo')
        self.functions.append('uploadSourcePackageInfo')
        self.functions.append('listChannel')
        self.functions.append('listMissingSourcePackages')


