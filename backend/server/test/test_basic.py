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

rhnSQL.initDB("rhnuser/rhnuser@webdev")

def main():
    print test_fetchone()
    print test_fetchone_tuple()
    print test_fetchone_dict()
    assert(test_fetchone() == (1.0, ))
    assert(test_fetchone_tuple() == (('1', 1), ))
    assert(test_fetchone_dict() == {'1' : 1})

def test_fetchone():
    s = rhnSQL.prepare("select 1 from dual")
    s.execute()
    return s.fetchone()

def test_fetchone_tuple():
    s = rhnSQL.prepare("select 1 from dual")
    s.execute()
    return s.fetchone_tuple()

def test_fetchone_dict():
    s = rhnSQL.prepare("select 1 from dual")
    s.execute()
    return s.fetchone_dict()

if __name__ == '__main__':
    sys.exit(main() or 0)
