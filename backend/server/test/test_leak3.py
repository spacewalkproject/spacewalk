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
import time
from DCOracle2 import connect

print os.getpid()
dbh = connect('rhnuser/rhnuser@webdev')
 # PGPORT_3:ORAFCE() #
h = dbh.prepare("select 1 from dual")

start = time.time()
i = 0
while 1:
    h.execute()
    if 0:
        print h.fetchone_dict()
    else:
        print i, "%.3f" % (time.time() - start)
    i = i + 1
    time.sleep(.01)
