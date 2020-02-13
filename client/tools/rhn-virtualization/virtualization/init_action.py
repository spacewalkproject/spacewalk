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

import sys
from virtualization import support

actions =   {
                'shutdown'  :   support.shutdown,
                'start'     :   support.start,
                'suspend'   :   support.suspend,
                'resume'    :   support.resume,
                'reboot'    :   support.reboot,
                'destroy'   :   support.destroy,
            }

action_type = sys.argv[1]
uuid = sys.argv[2]

if not action_type in list(actions.keys()):
    sys.stderr.write("Unknown action: %s \n" % action_type)
    sys.exit(1)

try:
    actions[action_type](uuid)
except Exception:
    e = sys.exc_info()[1]
    sys.stderr.write(str(e))
    sys.exit(1)

sys.exit(0)
