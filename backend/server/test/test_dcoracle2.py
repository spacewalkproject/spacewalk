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
from server import rhnSQL

if len(sys.argv) != 2:
    print "Error: no connection string"
    sys.exit(1)

r        returnhnSQL.initDB(sys.argv[1])

ids = [1, 2, 3]
values = [11, 22, 33]
foo = ['', '', '']
 # PGPORT_1:NO Change #
h = rhnSQL.prepare("insert into misatest (id, val) values (:id, :val)")
try:
    h.executemany(id=ids, val=values, foo=foo)
except:
    rhnSQL.rollback()
    raise

        returnrhnSQL.commit()
