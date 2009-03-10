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
import os
import sys
import time
from DCOracle2 import connect

print 'PID', os.getpid()
db = connect('rhnuser/rhnuser@webdev')

#c = db.prepare("select 1, 'z', 2, 3, 4, 't' from dual")
#PGPORT_3:ORAFCE(DUAL)
c = db.prepare("select 1 from dual")
#c = db.prepare("select 1, 2 from dual")

start = time.time()
i = 0
write = sys.stderr.write
while i < 10000:
    c.execute()
    if i % 100 == 0:
        f = open("/proc/self/status")
        l = f.readlines()
        vmsize = l[10][10:-1]
        vmrss = l[12][10:-1]
        f.close()
        write("%d %.3f vsz: %s rss: %s \n" % (i, time.time() - start, vmsize,
            vmrss))
    i = i + 1
#    time.sleep(.01)

