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

from server import rhnSQL
import unittest
from TestServer import TestServer

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
        self.sysid = self.myserver.getSystemId()
        self.sd2 = self.up2date.solveDependencies_v2    #returns arch info
        self.sd4 = self.up2date.solveDependencies_v4    #returns arch info, has better filtering

    def tearDown(self):
        rhnSQL.rollback()

    def testGetArchSd2( self ):
        ret = self.sd2( self.sysid, [self.filename] )
        assert len( ret[self.filename][0] ) == 5

    def testGetArchSd4( self ):
        ret = self.sd4( self.sysid, [self.filename] )
        assert len( ret[self.filename][0] ) == 5

    def testArchTypeSd2( self ):
        ret = self.sd2( self.sysid, [self.filename] )
        assert type( ret[self.filename][0][4] ) == type('a')

    def testArchTypeSd4( self ):
        ret = self.sd4( self.sysid, [self.filename] )
        assert type( ret[self.filename][0][4] ) == type('a')

    def testArchValueSd2( self ):
        ret = self.sd2( self.sysid, [self.filename] )
        assert ret[self.filename][0][4] == 'i386'

    def testArchValueSd4( self ):
        ret = self.sd4( self.sysid, [self.filename] )
        assert ret[self.filename][0][4] == 'i386'

    def testAllTrueSd4( self ):
        ret = self.sd4( self.sysid, [self.filename], all = 1 )
        assert len( ret[self.filename]) > 1

    def testAllFalseSd4( self ):
        ret = self.sd4( self.sysid, [self.filename], all = 0 )
        assert len( ret[self.filename] ) == 1

if __name__ == "__main__":
    unittest.main()
