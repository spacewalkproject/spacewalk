#!/usr/bin/python

#
# Copyright (c) 2008--2009 Red Hat, Inc.
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

""" 
Pure unit tests for the Spacewalk backend Python code. 

These tests should require no network or disk access and run on just about
any system.
"""

import sys
import unittest

sys.path.insert(0, '../')
sys.path.insert(0, './suites')
sys.path.insert(0, '../../client/rhel/rhnlib')

from server import rhnSQL

# Import all test modules here:
import rhnsqltests



def suite():
    # Append all test suites here:
    return unittest.TestSuite((
        rhnsqltests.suite(),
   ))

if __name__ == "__main__":
    try:
        import testoob
        testoob.main(defaultTest="suite")
    except ImportError:
        print "These tests would run prettier if you install testoob. :)"
        unittest.main(defaultTest="suite")
