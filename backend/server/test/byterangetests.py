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
import unittest

import common.byterange

class ByteRangeTests(unittest.TestCase):

    def testEmptyRange(self):
        try:
            server.byterange.parse_byteranges("")
            self.fail()
        except server.byterange.InvalidByteRangeException:
            # Expected result
            pass

    def testNoRangeGroups(self):
        try:
            server.byterange.parse_byteranges("bytes=")
            self.fail()
        except server.byterange.InvalidByteRangeException:
            # Expected result
            pass

    def testNegativeStart(self):
        try:
            server.byterange.parse_byteranges("bytes=-1-30")
            self.fail()
        except server.byterange.InvalidByteRangeException:
            pass

    def testStartAfterEnd(self):
        try:
            server.byterange.parse_byteranges("bytes=12-3")
            self.fail()
        except server.byterange.InvalidByteRangeException:
            pass

    def testNoStartOrEnd(self):
        try:
            server.byterange.parse_byteranges("bytes=-")
            self.fail()
        except server.byterange.InvalidByteRangeException:
            pass

    def testNoStartInvalidEnd(self):
        try:
            server.byterange.parse_byteranges("bytes=-0")
            self.fail()
        except server.byterange.InvalidByteRangeException:
            pass

    def testBadCharactersInRange(self):
        try:
            server.byterange.parse_byteranges("bytes=2-CB")
            self.fail()
        except server.byterange.InvalidByteRangeException:
            pass


    def testGoodRange(self):
        start, end = server.byterange.parse_byteranges("bytes=0-4")
        self.assertEquals(0, start)
        self.assertEquals(5, end)

    def testStartByteToEnd(self):
        start, end = server.byterange.parse_byteranges("bytes=12-")
        self.assertEquals(12, start)
        self.assertEquals(None, end)

    def testSuffixRange(self):
        start, end = server.byterange.parse_byteranges("bytes=-30")
        self.assertEquals(-30, start)
        self.assertEquals(None, end)

    def testMultipleRanges(self):
        try:
            server.byterange.parse_byteranges("bytes=1-3,9-12")
            self.fail()
        except server.byterange.UnsatisfyableByteRangeException:
            pass

    def testStartWithFileSize(self):
        start, end = server.byterange.parse_byteranges("bytes=23-", 50)
        self.assertEquals(23, start)
        self.assertEquals(50, end)

    def testSuffixWithFileSize(self):
        start, end = server.byterange.parse_byteranges("bytes=-40", 50)
        self.assertEquals(10, start)
        self.assertEquals(50, end)

    def testStartPastFileSize(self):
        try:
            server.byterange.parse_byteranges("bytes=50-60", 50)
            self.fail()
        except server.byterange.UnsatisfyableByteRangeException:
            pass

    def testSuffixLargerThanFileSize(self):
        try:
            server.byterange.parse_byteranges("bytes=-80", 79)
            self.fail()
        except server.byterange.UnsatisfyableByteRangeException:
            pass
unittest.main()
