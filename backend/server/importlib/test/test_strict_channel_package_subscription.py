#
# Copyright (c) 2008--2011 Red Hat, Inc.
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

# Script to test channel package snapshot invalidation
# Related to the testing of bug #162996

# To set things up:
# - create custom channel mibanescu-test2 (need to be logged in as mibanescu,
# otherwise change the org_id
# - subscribe a system to it
# - use rhnpush to upload a bunch of packages, including useless-1.0.0-2 and 3
# - snapshot the system 
#     exec rhn_server.snapshot_server(1004505404, 'some_reason')
# - select snapshot_id from rhnSnapshotChannel where channel_id = XXX
# - select server_id, reason, invalid from rhnsnapshot where id = 236527
#   invalid should be null
# run this script
#   invalid should become non-null (2 in my tests)

import sys

from spacewalk.server import rhnSQL
from spacewalk.server.importlib import importLib, packageImport, backendOracle

def main():
    rhnSQL.initDB()

    channel = { 'label' : 'mibanescu-test2' }

    orgid = 1198839
    package_template = {
        'name'      : 'useless',
        'version'   : '1.0.0',
        'arch'      : 'noarch',
        'org_id'    : orgid,
    }
        
    batch = []
    p = importLib.IncompletePackage()
    p.populate(package_template)
    p['release'] = '2'
    p['channels'] = [channel]
    batch.append(p)
    
    p = importLib.IncompletePackage()
    p.populate(package_template)
    p['release'] = '3'
    p['channels'] = [channel]
    batch.append(p)

    backend = backendOracle.OracleBackend()
    cps = packageImport.ChannelPackageSubscription(batch, backend,
        caller="misa.testing", strict=1)
    cps.run()
    print cps.affected_channel_packages

if __name__ == '__main__':
    sys.exit(main() or 0)
