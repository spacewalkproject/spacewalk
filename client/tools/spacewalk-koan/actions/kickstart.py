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

rhnpath="/usr/share/rhn"
if rhnpath not in sys.path:
    sys.path.append(rhnpath)

from spacewalkkoan import spacewalkkoan
from up2date_client import up2dateLog

__rhnexport__ = [
    'initiate',
]

def initiate(kickstart_host, base, extra_append, static_device="", system_record="", preserve_files=[]):
    log = up2dateLog.initLog() 
    log.log_me("initiating spacewalkkoan kickstart")
    return spacewalkkoan.initiate(kickstart_host, base, extra_append=extra_append,
        static_device=static_device, system_record=system_record, preserve_files=preserve_files)
