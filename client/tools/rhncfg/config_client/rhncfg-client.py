#!/usr/bin/python
#
# Copyright (c) 2008--2012 Red Hat, Inc.
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

RHNROOT = '/usr/share/rhn'
import sys, os
if RHNROOT not in sys.path:
    sys.path.append(RHNROOT)

from config_common.rhn_main import BaseMain

class Main(BaseMain):
    modes = ['diff', 'get', 'list', 'elist', 'channels', 'verify']
    repository_class_name = 'ClientRepository'
    plugins_dir = 'config_client'
    config_section = 'rhncfg-client'
    mode_prefix = 'rhncfgcli'


if __name__ == '__main__':
    # quick check to see if you are a super-user.
    if os.getuid() != 0:
        sys.stderr.write("ERROR: must be root to execute!" + "\n")
        sys.exit(1)
    try:
        sys.exit(Main().main() or 0)
    except KeyboardInterrupt:
        sys.stderr.write("user interrupted\n")
        sys.exit(0)

