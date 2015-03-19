#
# Copyright (c) 2008--2015 Red Hat, Inc.
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
import unittest
from spacewalk.server import rhnDependency


class MakeEvrTestCase(unittest.TestCase):

    def setUp(self):
        self.make_evr = rhnDependency.make_evr

    def testEvr1(self):
        ret = self.make_evr('100:testcase1-0-0')
        assert ret['epoch'] == '100' and ret['name'] == 'testcase1' and ret['version'] == '0' and ret['release'] == '0'

    def testEvr2(self):
        ret = self.make_evr('testcase1-0-0:100')
        assert ret['epoch'] == '100' and ret['name'] == 'testcase1' and ret['version'] == '0' and ret['release'] == '0'

    def testEvr3(self):
        ret = self.make_evr('testcase1-0-0')
        assert ret['epoch'] is None and ret['name'] == 'testcase1' and ret['version'] == '0' and ret['release'] == '0'

    def testEvr4(self):
        ret = self.make_evr('100000000000000000:a.b.c.d.e.f.g.h.i.j.k.l-m.n.o.p.q.r.s.t.u.v-w.x.y.z')
        assert ret['epoch'] == '100000000000000000' and\
            ret['name'] == 'a.b.c.d.e.f.g.h.i.j.k.l' and\
            ret['version'] == 'm.n.o.p.q.r.s.t.u.v' and\
            ret['release'] == 'w.x.y.z'

    def testEvr5(self):
        ret = self.make_evr('Bbbb.a111-cccC-qwerty:500')
        assert ret['epoch'] == '500' and\
            ret['name'] == 'Bbbb.a111' and\
            ret['version'] == 'cccC' and\
            ret['release'] == 'qwerty'

if __name__ == "__main__":
    unittest.main()
