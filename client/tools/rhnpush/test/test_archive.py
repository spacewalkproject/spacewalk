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
import unittest
import zipfile

# test import
import archive

# globals ----------------------------------------------------------------

TEST_ARCHIVE = "/tmp/test_archive.zip"
TEST_DIR = "./test_archive/foo/bar"
TEST_FILE = "test_file"
TEST_FILE_PATH = os.path.join(TEST_DIR, TEST_FILE)

TEST_CONTENTS = """
ONE: foo
TWO: you
THREE: too
FOUR: foo

"""

# test case --------------------------------------------------------------

class ArchiveTest(unittest.TestCase):

    def setUp(self):
        if not os.path.isdir(TEST_DIR):
            os.makedirs(TEST_DIR)

        fd = open(TEST_FILE_PATH, 'w')
        fd.write(TEST_CONTENTS)
        fd.close()

        fzip = zipfile.ZipFile(TEST_ARCHIVE, 'w')
        fzip.write(TEST_FILE_PATH)
        fzip.close()

    def tearDown(self):
        if os.path.isfile(TEST_FILE_PATH):
            os.unlink(TEST_FILE_PATH)

        if os.path.isdir(TEST_DIR):
            os.removedirs(TEST_DIR)

        if os.path.isfile(TEST_ARCHIVE):
            os.unlink(TEST_ARCHIVE)

    # test methods -------------------------------------------------------

    def testInstantiation(self):
        "test the instantiation of an archive parser object"
        p = archive.get_archive_parser(TEST_ARCHIVE)
        assert isinstance(p, archive.ArchiveParser)

    def testFind(self):
        "test the ability of the parser to find a file in the archive"
        p = archive.get_archive_parser(TEST_ARCHIVE)
        assert p.contains(TEST_FILE)

    def testFindPath(self):
        "test the ability of the parser to find a subpath in the archive"
        p = archive.get_archive_parser(TEST_ARCHIVE)
        assert p.contains("foo/bar/" + TEST_FILE)

    def testRead(self):
        "test the ability of the parser to read a file in the archive"
        p = archive.get_archive_parser(TEST_ARCHIVE)
        contents = p.read(TEST_FILE)
        assert contents == TEST_CONTENTS

# run the tests ----------------------------------------------------------

if __name__ == "__main__":
    unittest.main()

