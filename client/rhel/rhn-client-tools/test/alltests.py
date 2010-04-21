#   rhn-client-tools - RHN support tools and libraries
#
#   Copyright (C) 2006 Red Hat, Inc.
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
#   02110-1301  USA

import unittest
import settestpath

import testByteRangeRpcServer
import testClientCaps
import testConfig
import testRhnChannel
import testRpcServer
import testRpmUtils
import testSSLSocketTimeout
import testTransactions
import testUp2dateAuth
import testUp2dateUtils
import haltreetests
### import testrhnregGui

from unittest import TestSuite

def suite():
    # Append all test suites here:
    return TestSuite((
        testByteRangeRpcServer.suite(),
        testClientCaps.suite(),
        testConfig.suite(),
        testRhnChannel.suite(),
        testRpcServer.suite(),
        testRpmUtils.suite(),
        testSSLSocketTimeout.suite(),
        testTransactions.suite(),
        testUp2dateAuth.suite(),
        testUp2dateUtils.suite(),
###        testrhnregGui.suite(),
        haltreetests.suite()
    ))

if __name__ == "__main__":
    unittest.main(defaultTest="suite")
