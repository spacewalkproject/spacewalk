#
# Copyright (c) 2008--2016 Red Hat, Inc.
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


def mem_usage():
    f = open("/proc/self/status")
    dict = {}
    while 1:
        line = f.readline()
        if not line:
            break
        arr = list(map(string.strip, string.split(line, ':', 1)))
        if len(arr) == 1:
            continue
        dict[arr[0]] = arr[1]
    return dict['Name'], dict['VmSize'], dict['VmRSS'], dict['VmData']
