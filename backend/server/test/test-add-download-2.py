#!/usr/bin/python
#
# Copyright (c) 2008--2010 Red Hat, Inc.
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
from spacewalk.common.rhnConfig import initCFG
from spacewalk.server import rhnFileDownload, rhnSQL

def main():
    if len(sys.argv) < 2:
        print "Usage: %s <db-connect-string>" % sys.argv[0]
        return 1

    db_connect_string = sys.argv[1]

    initCFG("server.redhat-xmlrpc")
    rhnSQL.initDB(db_connect_string)

    test_1()

def gen_entries():
    channel = 'redhat-rhn-satellite-4.0-as-i386-4'
    path_template = "a/b/c/d/test-%s.iso"
    category = "Test Category %5.3f - %s" % (time.time(), os.getpid())
    name_template = "Test Download %s"
    entries = []
    for i in range(10):
        entries.append({
            'name'      : name_template % i,
            'path'      : path_template % i,
            'channel'   : channel,
            'file_size' : 123400 + i,
            'md5sum'    : 'foo-manchoo-%03d' % i,
            'category'  : category,
            'ordering'  : 100 + i,
            'download_type' : 'iso',
        })
    return entries

def _delete_entries(prefix, entries):
    l = []
    for e in entries:
        l.append((e['category'], e['channel'], e['path']))
    return rhnFileDownload.delete_files_from_categories(prefix, l)

def test_1():
    try:
        _test_1()
    except:
        rhnSQL.rollback()
        raise

    rhnSQL.commit()
    
def _test_1():
    entries = gen_entries()

    category = entries[0]['category']

    prefix = ""

    missing = _delete_entries(prefix, entries)

    rhnFileDownload.add_downloads(entries, prefix, check_existing_files=0)
    avail = get_downloads(category)
    assert(len(entries) == len(avail))

    disable_category_downloads(category)
    
    avail = get_downloads(category)
    assert(len(entries) == len(avail))

    rhnFileDownload.add_downloads(entries, prefix, check_existing_files=0)

    avail = get_downloads(category)
    assert(len(entries) == len(avail))

    missing = _delete_entries(prefix, entries)
    avail = get_downloads(category)
    assert(len(avail) == 0)

def get_downloads(category):
    h = rhnSQL.prepare("""
        select d.id, dt.label download_type
        from rhnDownloads d, rhnDownloadType dt
        where d.category = :category
        and d.download_type = dt.id
    """)
    h.execute(category=category)
    return [ (r[0][1], r[1][1]) for r in h.fetchall_tuple() or [] ]

def disable_category_downloads(category):
    h = rhnSQL.prepare("""
        update rhnDownloads
        set download_type = (
            select id from rhnDownloadType where label ='disabled' )
        where category = :category
    """)
    h.execute(category=category)

if __name__ == '__main__':
    sys.exit(main() or 0)
