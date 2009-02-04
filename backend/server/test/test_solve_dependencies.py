#!/usr/bin/python
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

from server import rhnDependency, rhnSQL
import unittest
from TestServer import TestServer
import rpm

def make_nvre_dict( epoch, version, release ):
    return {
        'epoch'     :   epoch,
        'version'   :   version,    
        'release'   :   release
    }


class SolveDependenciesTestCase(unittest.TestCase):
    #this class assumes that:
    # mozilla-1.3.1-0.dag.rhel3.i386.rpm
    # mozilla-1.5-2.rhfc1.dag.i386.rpm
    # mozilla-1.6-0.rhfc1.dag.i386.rpm
    # mozilla-1.7.1-1.1.el3.test.i386.rpm
    # are all available in self.directory.


    def setUp(self):
        self.directory = '/home/devel/wregglej/testrpms'
        self.filename = 'libcaps.so'
        self.arch = 'i386'
        self.myserver = TestServer()
        self.serv_id = self.myserver.getServerId()
        self.myserver.upload_packages(self.directory)
        self.up2date = self.myserver.getUp2date()
        self.solve_deps_arch = rhnDependency.solve_dependencies_arch
        self.solve_deps_with_limits = rhnDependency.solve_dependencies_with_limits
        self.up2date = self.myserver.getUp2date() 


    def tearDown(self):
        rhnSQL.rollback()

    def testReturnType(self):
        assert type( self.solve_deps_arch( self.serv_id, [], 2 ) ) == type({})

    def testKeyType(self):
        assert type( self.solve_deps_arch( self.serv_id, [self.filename], 2 ).keys()[0] ) == type('a')
    
    def testValueType(self):
        assert type( self.solve_deps_arch( self.serv_id, [self.filename], 2 )[self.filename] ) == type([])

    def testNestedValueType(self):
        assert type( self.solve_deps_arch( self.serv_id, [self.filename], 2)[self.filename][0]) == type([]) 

    def testNestedValueLength(self):
        assert len( self.solve_deps_arch( self.serv_id, [self.filename], 2 )[self.filename][0] ) > 0
    
    def testNestedValueLength2(self):
        assert len( self.solve_deps_arch( self.serv_id, [self.filename], 2)[self.filename][0] ) == 5

    def testNestedValueType0(self):
        assert type( self.solve_deps_arch( self.serv_id, [self.filename], 2)[self.filename][0][0] ) == type('a')

    def testNestedValueType1(self):
        assert type( self.solve_deps_arch( self.serv_id, [self.filename], 2)[self.filename][0][1] ) == type('a')

    def testNestedValueType2(self):
        assert type( self.solve_deps_arch( self.serv_id, [self.filename], 2)[self.filename][0][2] ) == type('a')
    
    def testNestedValueType3(self):
        assert type( self.solve_deps_arch( self.serv_id, [self.filename], 2)[self.filename][0][3] ) == type('a')

    def testNestedValueType4(self):
        assert type( self.solve_deps_arch( self.serv_id, [self.filename], 2)[self.filename][0][4] ) == type('a')

    def testVerifyArch(self):
        assert self.solve_deps_arch( self.serv_id, [self.filename], 2 )[self.filename][0][4] == self.arch 

    def testReturnTypeLimit(self):
        assert type( self.solve_deps_with_limits( self.serv_id, [], 2 ) ) == type({})

    def testKeyTypeLimit(self):
        assert type( self.solve_deps_with_limits( self.serv_id, [self.filename], 2 ).keys()[0] ) == type('a')
    
    def testValueTypeLimit(self):
        assert type( self.solve_deps_with_limits( self.serv_id, [self.filename], 2 )[self.filename] ) == type([])

    def testNestedValueTypeLimit(self):
        assert type( self.solve_deps_with_limits( self.serv_id, [self.filename], 2)[self.filename][0]) == type([]) 

    def testNestedValueLengthLimit(self):
        assert len( self.solve_deps_with_limits( self.serv_id, [self.filename], 2 )[self.filename][0] ) > 0
    
    def testNestedValueLengthLimit2(self):
        assert len( self.solve_deps_with_limits( self.serv_id, [self.filename], 2)[self.filename][0] ) == 5

    def testNestedValueTypeLimit0(self):
        assert type( self.solve_deps_with_limits( self.serv_id, [self.filename], 2)[self.filename][0][0] ) == type('a')

    def testNestedValueTypeLimit1(self):
        assert type( self.solve_deps_with_limits( self.serv_id, [self.filename], 2)[self.filename][0][1] ) == type('a')

    def testNestedValueTypeLimit2(self):
        assert type( self.solve_deps_with_limits( self.serv_id, [self.filename], 2)[self.filename][0][2] ) == type('a')
    
    def testNestedValueTypeLimit3(self):
        assert type( self.solve_deps_with_limits( self.serv_id, [self.filename], 2)[self.filename][0][3] ) == type('a')

    def testNestedValueTypeLimit4(self):
        assert type( self.solve_deps_with_limits( self.serv_id, [self.filename], 2)[self.filename][0][4] ) == type('a')

    def testVerifyArchLimit(self):
        assert self.solve_deps_with_limits( self.serv_id, [self.filename], 2 )[self.filename][0][4] == self.arch 


    def testAllReturn(self):
        pack = self.solve_deps_with_limits( self.serv_id,\
                                            [self.filename],\
                                            2,\
                                            all = 1 )
        if not pack is None:
            assert 1
        else:
            assert 0

    def testAllReturn1( self ):
        pack = self.solve_deps_with_limits( self.serv_id,\
                                            [self.filename],\
                                            2,\
                                            all = 1 )
        exp_ret = ['mozilla', '1.3.1','0.dag.rhel3','34','i386']
        if exp_ret in pack[self.filename]:
            assert 1
        else:
            assert 0
    
    def testAllReturn2( self ):
        pack = self.solve_deps_with_limits( self.serv_id,\
                                            [self.filename],\
                                            2,\
                                            all = 1 )
        exp_ret = ['mozilla','1.7.1','1.1.el3.dag','37', 'i386']
        if exp_ret in pack[self.filename]:
            assert 1
        else:
            assert 0

    def testAllReturn3( self ):
        pack = self.solve_deps_with_limits( self.serv_id,\
                                            [self.filename],\
                                            2,\
                                            all = 1 )
        exp_ret = ['mozilla', '1.5', '2.rhfc1.dag', '38', 'i386']
        if exp_ret in pack[self.filename]:
            assert 1
        else:
            assert 0       

    def testAllReturn4( self ):
        pack = self.solve_deps_with_limits( self.serv_id,\
                                            [self.filename],\
                                            2,\
                                            all = 1 )
        exp_ret = ['mozilla','1.6','0.rhfc1.dag','38', 'i386']
        if exp_ret in pack[self.filename]:
            assert 1
        else:
            assert 0        

    def testNotAllReturn( self ):
        pack = self.solve_deps_with_limits( self.serv_id,\
                                            [self.filename],\
                                            2 )
                 
        exp_ret = ['mozilla','1.6','0.rhfc1.dag','38', 'i386']
        if exp_ret in pack[self.filename]:
            assert 1
        else:
            assert 0        

    def testMakeEvr( self ):
        nlimitstr = '38:mozilla-1.5-2.rhfc1.dag'
        nlimit = rhnDependency.make_evr( nlimitstr )
        assert nlimit['epoch'] == '38' and\
               nlimit['name'] == 'mozilla' and\
               nlimit['version'] == '1.5' and\
               nlimit['release'] == '2.rhfc1.dag'

    def testMakeEvr1( self ):
        nlimitstr = 'mozilla-1.5-2.rhfc1.dag:38'
        nlimit = rhnDependency.make_evr( nlimitstr )
        assert nlimit['epoch'] == '38' and\
               nlimit['name'] == 'mozilla' and\
               nlimit['version'] == '1.5' and\
               nlimit['release'] == '2.rhfc1.dag'
        
    def testMakeEvr2( self ):
        nlimitstr = 'mozilla-1.5-2.rhfc1.dag'
        nlimit = rhnDependency.make_evr( nlimitstr )
        assert nlimit['epoch'] == None and\
               nlimit['name'] == 'mozilla' and\
               nlimit['version'] == '1.5' and\
               nlimit['release'] == '2.rhfc1.dag'


    def testEvrFilterE( self):
        nlimitstr = '38:mozilla-1.5-2.rhfc1.dag'
        nlimit = rhnDependency.make_evr( nlimitstr )
        pack = self.solve_deps_with_limits( self.serv_id,\
                                            [self.filename],\
                                            2,\
                                            limit_operator = '==',\
                                            limit = nlimitstr )
        assert pack[self.filename][0][1] == nlimit['version'] and\
               pack[self.filename][0][2] == nlimit['release'] and\
               pack[self.filename][0][3] == nlimit['epoch']

    def testEvrFilterGT( self):
        nlimitstr = '38:mozilla-1.5-2.rhfc1.dag'
        nlimit = rhnDependency.make_evr( nlimitstr )
        pack = self.solve_deps_with_limits( self.serv_id,\
                                            [self.filename],\
                                            2,\
                                            limit_operator = '>',\
                                            limit = nlimitstr )
        assert rpm.labelCompare( ( pack[self.filename][0][3], pack[self.filename][0][1], pack[self.filename][0][2] ),\
                                 ( nlimit['epoch'], nlimit['version'], nlimit['release']) ) == 1

    def testEvrFilterGTE( self):
        nlimitstr = '38:mozilla-1.5-2.rhfc1.dag'
        nlimit = rhnDependency.make_evr( nlimitstr )
        pack = self.solve_deps_with_limits( self.serv_id,\
                                            [self.filename],\
                                            2,\
                                            limit_operator = '>=',\
                                            limit = nlimitstr )
        ret = rpm.labelCompare( ( pack[self.filename][0][3], pack[self.filename][0][1], pack[self.filename][0][2] ),\
                                ( nlimit['epoch'], nlimit['version'], nlimit['release']) )
        assert ret == 1 or ret == 0

    def testEvrFilterLT( self ):
        nlimitstr = '38:mozilla-1.5-2.rhfc1.dag'
        nlimit = rhnDependency.make_evr( nlimitstr )
        pack = self.solve_deps_with_limits( self.serv_id,\
                                            [self.filename],\
                                            2,\
                                            limit_operator = '<',\
                                            limit = nlimitstr )
        ret = rpm.labelCompare( ( pack[self.filename][0][3], pack[self.filename][0][1], pack[self.filename][0][2] ),\
                                 ( nlimit['epoch'], nlimit['version'], nlimit['release']) )
        assert ret == -1

    def testEvrFilterLTE( self ):
        nlimitstr = '38:mozilla-1.5-2.rhfc1.dag'
        nlimit = rhnDependency.make_evr( nlimitstr )
        pack = self.solve_deps_with_limits( self.serv_id,\
                                            [self.filename],\
                                            2,\
                                            limit_operator = '<=',\
                                            limit = nlimitstr )
        ret = rpm.labelCompare( ( pack[self.filename][0][3], pack[self.filename][0][1], pack[self.filename][0][2] ),\
                                 ( nlimit['epoch'], nlimit['version'], nlimit['release']) )
        assert ret == -1 or ret == 0

    def testUp2dateObj( self ):
        pack = self.up2date.solveDependencies( self.myserver.getSystemId(), [self.filename] )
        if not pack is None:
            assert 1
        else:
            assert 0

    def testUp2dateObjReturnLength( self ):
        pack = self.up2date.solveDependencies_arch( self.myserver.getSystemId(), [self.filename] )
        assert len(pack[self.filename][0]) == 5

    def testUp2dateObjArchReturnType( self ):
        pack = self.up2date.solveDependencies_arch( self.myserver.getSystemId(), [self.filename] )
        assert pack[ self.filename ][0][4] == 'i386'

    def testUp2dateFilterEq( self ):
        nlimitstr = '38:mozilla-1.5-2.rhfc1.dag'
        nlimit = rhnDependency.make_evr( nlimitstr )
        pack = self.up2date.solveDependencies_with_limits( self.myserver.getSystemId(),\
                                                           [self.filename],\
                                                           2,\
                                                           limit_operator = '==',\
                                                           limit = nlimitstr )
        ret = rpm.labelCompare( ( pack[self.filename][0][3], pack[self.filename][0][1], pack[self.filename][0][2] ),\
                                 ( nlimit['epoch'], nlimit['version'], nlimit['release']) )
        
        assert ret == 0

    def testUp2dateFilterGT( self ):
        nlimitstr = '35:mozilla-0-0'
        nlimit = rhnDependency.make_evr( nlimitstr )
        pack = self.up2date.solveDependencies_with_limits( self.myserver.getSystemId(),\
                                                           [self.filename],\
                                                           2,\
                                                           limit_operator = '>',\
                                                           limit = nlimitstr )
        ret = rpm.labelCompare( ( pack[self.filename][0][3], pack[self.filename][0][1], pack[self.filename][0][2] ),\
                                 ( nlimit['epoch'], nlimit['version'], nlimit['release']) )
        assert ret == 1

    def testUp2dateFilterGTE( self ):
        nlimitstr = '35:mozilla-1-1'
        nlimit = rhnDependency.make_evr( nlimitstr )
        pack = self.up2date.solveDependencies_with_limits( self.myserver.getSystemId(),\
                                                           [self.filename],\
                                                           2,\
                                                           limit_operator = '>',\
                                                           limit = nlimitstr )
        ret = rpm.labelCompare( ( pack[self.filename][0][3], pack[self.filename][0][1], pack[self.filename][0][2] ),\
                                 ( nlimit['epoch'], nlimit['version'], nlimit['release']) )
        assert ret == 1 or ret == 0

    def testUp2dateFilterLT( self ):
        nlimitstr = '35:mozilla-1-1'
        nlimit = rhnDependency.make_evr( nlimitstr )
        pack = self.up2date.solveDependencies_with_limits( self.myserver.getSystemId(),\
                                                           [self.filename],\
                                                           2,\
                                                           limit_operator = '<',\
                                                           limit = nlimitstr )
        ret = rpm.labelCompare( ( pack[self.filename][0][3], pack[self.filename][0][1], pack[self.filename][0][2] ),\
                                 ( nlimit['epoch'], nlimit['version'], nlimit['release']) )
        assert ret == -1

    def testUp2dateFilterLTE( self ):
        nlimitstr = '35:mozilla-1-1'
        nlimit = rhnDependency.make_evr( nlimitstr )
        pack = self.up2date.solveDependencies_with_limits( self.myserver.getSystemId(),\
                                                           [self.filename],\
                                                           2,\
                                                           limit_operator = '<=',\
                                                           limit = nlimitstr )
        ret = rpm.labelCompare( ( pack[self.filename][0][3], pack[self.filename][0][1], pack[self.filename][0][2] ),\
                                 ( nlimit['epoch'], nlimit['version'], nlimit['release']) )
        assert ret == -1 or ret == 0

    def testUp2dateFilterEq1( self ):
        nlimitstr = '38:mozilla-1.5-2.rhfc1.dag'
        nlimit = rhnDependency.make_evr( nlimitstr )
        pack = self.up2date.solveDependencies_with_limits( self.myserver.getSystemId(),\
                                                           [self.filename],\
                                                           2,\
                                                           limit_operator = '==',\
                                                           limit = nlimitstr )
        ret = rpm.labelCompare( ( pack[self.filename][0][3], pack[self.filename][0][1], pack[self.filename][0][2] ),\
                                 ( nlimit['epoch'], nlimit['version'], nlimit['release']) )
        
        assert ret == 0

    def testUp2dateFilterGT1( self ):
        nlimitstr = 'mozilla-0-0:35'
        nlimit = rhnDependency.make_evr( nlimitstr )
        pack = self.up2date.solveDependencies_with_limits( self.myserver.getSystemId(),\
                                                           [self.filename],\
                                                           2,\
                                                           limit_operator = '>',\
                                                           limit = nlimitstr )
        ret = rpm.labelCompare( ( pack[self.filename][0][3], pack[self.filename][0][1], pack[self.filename][0][2] ),\
                                 ( nlimit['epoch'], nlimit['version'], nlimit['release']) )
        assert ret == 1

    def testUp2dateFilterGTE1( self ):
        nlimitstr = 'mozilla-1-1:35'
        nlimit = rhnDependency.make_evr( nlimitstr )
        pack = self.up2date.solveDependencies_with_limits( self.myserver.getSystemId(),\
                                                           [self.filename],\
                                                           2,\
                                                           limit_operator = '>',\
                                                           limit = nlimitstr )
        ret = rpm.labelCompare( ( pack[self.filename][0][3], pack[self.filename][0][1], pack[self.filename][0][2] ),\
                                 ( nlimit['epoch'], nlimit['version'], nlimit['release']) )
        assert ret == 1 or ret == 0

    def testUp2dateFilterLT1( self ):
        nlimitstr = 'mozilla-1-1:35'
        nlimit = rhnDependency.make_evr( nlimitstr )
        pack = self.up2date.solveDependencies_with_limits( self.myserver.getSystemId(),\
                                                           [self.filename],\
                                                           2,\
                                                           limit_operator = '<',\
                                                           limit = nlimitstr )
        ret = rpm.labelCompare( ( pack[self.filename][0][3], pack[self.filename][0][1], pack[self.filename][0][2] ),\
                                 ( nlimit['epoch'], nlimit['version'], nlimit['release']) )
        assert ret == -1

    def testUp2dateFilterLTE1( self ):
        nlimitstr = 'mozilla-1-1:35'
        nlimit = rhnDependency.make_evr( nlimitstr )
        pack = self.up2date.solveDependencies_with_limits( self.myserver.getSystemId(),\
                                                           [self.filename],\
                                                           2,\
                                                           limit_operator = '<=',\
                                                           limit = nlimitstr )
        ret = rpm.labelCompare( ( pack[self.filename][0][3], pack[self.filename][0][1], pack[self.filename][0][2] ),\
                                 ( nlimit['epoch'], nlimit['version'], nlimit['release']) )
        assert ret == -1 or ret == 0
    

if __name__ == "__main__":
    unittest.main()

    rhnSQL.rollback()
