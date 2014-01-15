#!/usr/bin/python
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
#
# test case for bugzilla 127319
#
# Usage: ./xxx.py <server-name> <db>
#

import os
import sys

_topdir = os.path.dirname(sys.argv[0])
_basedir = os.path.abspath(_topdir + '/../..')
if _basedir not in sys.path:
    sys.path.append(_basedir)

import time
from rhn import rpclib
from spacewalk.server import rhnSQL, rhnServer, rhnCapability
from spacewalk.common.rhnConfig import ConfigParserError

def main():
    if len(sys.argv) == 1:
        server_name = 'xmlrpc.rhn.webdev.redhat.com'
    else:
        server_name = sys.argv[1]

    if len(sys.argv) <= 2:
        db_name = 'rhnuser/rhnuser@webdev'
    else:
        db_name = sys.argv[2]

    try:
        rhnSQL.initDB(db_name)
    except ConfigParserError:
        # database is not available when running in rpmbuild time
        print "Test skipped"
        return 0

    uri = "http://%s/XMLRPC" % (server_name, )
    s = rpclib.Server(uri)

    username = password = "test-username-%.3f" % time.time()
    email = "misa+%s@redhat.com" % username

    s.registration.reserve_user(username, password)
    s.registration.new_user(username, password, email)

    data = {
       'os_release'     : '9',
       'architecture'   : 'athlon-redhat-linux',
       'profile_name'   : 'Test profile for %s' % username,
       'username'       : username,
       'password'       : password,
    }
    systemid = s.registration.new_system(data)

    str_caps = [
        'this.is.bogus1(0)=0',
        'this.is.bogus2(1)=1',
        'this.is.bogus3(2)=2',
    ]
    for cap in str_caps:
        s.add_header('X-RHN-Client-Capability', cap)

    # Add some packages
    packages = [
        ['a', '1', '1', ''],
        ['b', '2', '2', ''],
        ['c', '3', '3', ''],
    ]
    s.registration.update_packages(systemid, packages)

    sobj = rhnServer.get(systemid)
    server_id = sobj.getid()
    print "Registered server", server_id

    return 0

if __name__ == '__main__':
    sys.exit(main() or 0)
