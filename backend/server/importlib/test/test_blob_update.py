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
#
# Test for blob updates
#
# $Id$

"""
Test module for blob updates.
To create the table for this test run:

drop table test_blob_update;

create table test_blob_update 
    (id1 int not null, id2 int, val1 blob, val2 blob, nval int not null);
"""

import sys
from spacewalk.server import rhnSQL
from spacewalk.server.importlib.backendLib import Table, DBblob, DBint, TableUpdate, \
    TableInsert

def main():
    rhnSQL.initDB()

    blob_values1 = [
        # Regular update
        [ 1, 1,     'value 11', 'value 12', 1],
        [ 2, 1,     'value 21', 'value 22', 2 ],
        # Update with one of the primary keys being None
        [ 3, None,  'value 31', 'value 32', 3 ],
        [ 4, None,  'value 41', 'value 42', 4 ],
        # Test for writing an empty string into the blob
        [ 5, 5,     '',         'value 52', 5 ],
        # Test for writing a shorter string into the blob
        [ 6, 6,     'value 61', 'value 62', 6 ],
    ]
    newval1_1 = 'new value 11'
    newval1_2 = 'new value 12'
    newval3_1 = 'new value 31 ' * 1024
    newval3_2 = 'new value 32' * 2048
    newval5_1 = 'new value 51'
    newval5_2 = ''
    newval6_1 = 'v61'
    newval6_2 = 'v61'
    blob_values2 = blob_values1[:]
    for r in [0, 2, 4, 5]:
        # Copy the old values
        blob_values2[r] = blob_values1[r][:]
    blob_values2[0][2:5] = [newval1_1, newval1_2, 11]
    blob_values2[2][2:5] = [newval3_1, newval3_2, 2]
    blob_values2[4][2:5] = [newval5_1, newval5_2, 33]
    blob_values2[5][2:5] = [newval6_1, newval6_2, 4]

    test_blob_update = Table("test_blob_update", 
        fields = {
            'id1'   : DBint(),
            'id2'   : DBint(),
            'val1'  : DBblob(),
            'val2'  : DBblob(),
            'nval'  : DBint(),
        },
        # Setting the nullable column to be the first one, to force a specific codepath
        pk = ['id2', 'id1'],
        nullable = ['id2'],
    )
    
    fields = ['id1', 'id2', 'val1', 'val2', 'nval']
    setup(test_blob_update, blob_values1, fields)
    print "Insert test"
    verify(blob_values1)

    t = TableUpdate(test_blob_update, rhnSQL)

    rows = [0, 2, 4, 5]
    values = _build_update_hash(fields, blob_values2, rows)

    t.query(values)
    rhnSQL.commit()

    print "Updates test"
    verify(blob_values2)

def _build_update_hash(fields, blob_values, rows):
    values = {}
    for f in fields:
        values[f] = []
    for i in range(len(rows)):
        row = blob_values[rows[i]]
        for j in range(len(fields)):
            f = fields[j]
            values[f].append(row[j])

    return values
    

def setup(table, blob_values, fields):
    h = rhnSQL.prepare("delete from test_blob_update")
    h.execute()
    
    hash_values = {}
    for f in fields:
        hash_values[f] = []
    for i in range(len(blob_values)):
        for j in range(len(fields)):
            f = fields[j]
            h = hash_values[f]
            h.append(blob_values[i][j])
    t = TableInsert(table, rhnSQL)
    t.query(hash_values)
    rhnSQL.commit()

def verify(blob_values):
    q = """
        select val1, val2 from test_blob_update where id1 = :id1 and %s
    """
    for v in blob_values:
        i1 = v[0]
        i2 = v[1]
        v1 = v[2]
        v2 = v[3]
        hval = {'id1' : i1}
        if i2 is None:  
            s = "id2 is null"
        else:
            s = "id2 = :id2"
            hval['id2'] = i2
        h = rhnSQL.prepare(q % s)
        apply(h.execute, (), hval)
        row = h.fetchone_dict()
        val1 = row['val1']
        val2 = row['val2']

        val1_val = rhnSQL.read_lob(val1)
        val2_val = rhnSQL.read_lob(val2)
        assert v1 == val1_val, "Not equal: %s, %s" % (repr(v1), repr(val1_val))
        assert v2 == val2_val, "Not equal: %s, %s" % (repr(v2), repr(val2_val))
    print "Verification passes"

if __name__ == '__main__':
    sys.exit(main() or 0)
