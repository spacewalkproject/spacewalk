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
import string
import cx_Oracle

if len(sys.argv) == 1:
    print "Usage: %s <connection_string>" % sys.argv[0]
    sys.exit(0)

def mem_usage():
    f = open("/proc/self/status")
    dict = {}
    while 1:
        line = f.readline()
        if not line:
            break
        arr = map(string.strip, string.split(line, ':', 1))
        if len(arr) == 1:
            continue
        dict[arr[0]] = arr[1]
    return dict['Name'], dict['VmSize'], dict['VmRSS'], dict['VmData']

def _line_value(line):
    arr = string.split(line, ':', 1)
    if len(arr) == 1:
        return None
    return string.strip(arr[1])

dbh = cx_Oracle.Connection(sys.argv[1])
h = dbh.cursor()
 # PGPORT_3:ORAFCE #
h.execute('select 1 from dual')
for i in range(10000):
    d = h.description
    if not (i % 100):
        print mem_usage()
