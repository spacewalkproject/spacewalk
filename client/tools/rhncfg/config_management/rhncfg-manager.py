#!/usr/bin/python
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

from config_common.rhn_main import BaseMain

class Main(BaseMain):
    modes = [
        'add',
        'create-channel',
        'diff',
        'diff-revisions',
        'download-channel',
        'get',
        'list',
        'list-channels',
        'remove',
        'remove-channel',
        'revisions',
        'update',
        'upload-channel',
    ]
    plugins_dir = 'config_management'
    config_section = 'rhncfg-manager'
    mode_prefix = 'rhncfg'

if __name__ == '__main__':
    try:
        sys.exit(Main().main() or 0)
    except KeyboardInterrupt:
        sys.stderr.write("user interrupted\n")
        sys.exit(0)

