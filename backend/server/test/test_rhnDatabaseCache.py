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
from spacewalk.common import initLOG
from spacewalk.server import rhnSQL, rhnDatabaseCache

if __name__ == '__main__':
    initLOG("stderr", 4)
    #connect_string = "misa01/misa01@misa01"
    connect_string = "rhnuser/rhnuser@webdev"
    #connect_string = "rhnuser/rhnuser@webqa"
    #rhnDatabaseCache.initDB(connect_string)
    rhnSQL.initDB(connect_string)

    key = 'xml-packages/27/rhn-package-78527.xml-alt'
    ts = 1056359720.0
    #key = 'xml-packages/27/rhn-package-78527.xml' 
    if 1:
        if 1:
            data = rhnDatabaseCache.get(key, compressed=1, raw=1, modified=ts)
        else:
            data = rhnDatabaseCache.get(key, compressed=1, raw=1)
        if data is not None:
            print len(data)
        sys.exit(1)
    if 1:
        content = open("test/rhn-package-78527.xml").read() * 6
        if 1:
            rhnDatabaseCache.set(key, content, compressed=1, raw=1, modified=ts)
        else:
            rhnDatabaseCache.set(key, content, compressed=1, raw=1)
        sys.exit(1)

    #ts = None
    compressed = 1
    print "Original timestamp:", ts
    print "Has_key ts", rhnDatabaseCache.has_key('b', ts)
    if ts:
        print "Has_key ts-1", rhnDatabaseCache.has_key('b', ts-1)
    if 0:
        #val = '0123456789' * 5000
        #val = open("/tmp/ggg.fff").read()
        #val = '0123456789' * 1024 * 100 * 48
        val = '0123456789' * 1024 * 100 * 30
        rhnDatabaseCache.set('b', val, raw=1, modified=ts,
            compressed=compressed)
    else:
        v = rhnDatabaseCache.get('b', raw=1, compressed=compressed, 
            modified=ts)
        if v is None:
            print None
        else:
            print len(v)
    if 0:
        rhnDatabaseCache.delete('b')

