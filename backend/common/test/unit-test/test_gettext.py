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
# $Id$

import os
import sys
import unittest

# Make paths absolute
if sys.argv[0] == "/":
    topdir = sys.argv[0]
else:
    topdir = "%s/%s" % (os.getcwd(), sys.argv[0])
topdir = os.path.abspath(os.path.dirname(topdir + "/../../../../.."))

if topdir not in sys.path:
    sys.path.append(topdir)

from spacewalk.common import rhnTranslate

class Tests(unittest.TestCase):
    # pylint: disable=R0904
    
    @staticmethod
    def _setup(lang):
        domain = "unit-test"
        localedir = "%s/common/test/unit-test/translations" % topdir
        rhnTranslate.cat.set(domain=domain, localedir=localedir)
        rhnTranslate.cat.setlangs(lang)

    def _test(self, lang, s, target):
        self._setup(lang)
        ss = rhnTranslate._(s)
        self.assertEqual(ss, target)

    def test_setlangs_en(self):
        "Tests setting the language to en"
        lang = "en"
        self._setup(lang)
        langs = rhnTranslate.cat.getlangs()
        self.failUnless(langs[0] == lang)
        
    def test_setlangs_ro(self):
        "Tests setting the language to ro"
        lang = "ro"
        self._setup(lang)
        langs = rhnTranslate.cat.getlangs()
        self.failUnless(langs[0] == lang)
        
    def test_setlangs_go(self):
        """Tests setting the language to go (does not exist)"""
        lang = "go"
        self._setup(lang)
        langs = rhnTranslate.cat.getlangs()
        if hasattr(sys, "version_info"):
            # On python 1.5.2 we don't really get an idea what the language
            # is, so it's ok to check for the first component
            self.failIf(langs[0] == lang, "Language is %s" % langs[0])
        else:
            self.failUnless(langs[0] == lang, "Language is %s" % langs[0])

    def test_en_1(self):
        "Tests plain English messages"
        lang = 'en'
        s = "Good day"
        target = s
        self._test(lang, s, target)

    def test_en_2(self):
        "Tests plain English messages"
        lang = 'en'
        s = "How do you do?"
        target = s
        self._test(lang, s, target)

    def test_en_3(self):
        "Tests plain English messages"
        lang = 'en'
        s = "What should I do now?"
        target = s
        self._test(lang, s, target)

    def test_en_missing_1(self):
        "Tests plain English messages that are not in the translation files"
        lang = 'en'
        s = "This string doesn't exist in the translation"
        target = s
        self._test(lang, s, target)

    def test_ro_1(self):
        "Tests plain English messages translated to Romanian"
        lang = 'ro'
        s = "Good day"
        target = "Buna ziua"
        self._test(lang, s, target)

    def test_ro_2(self):
        "Tests plain English messages translated to Romanian"
        lang = 'ro'
        s = "How do you do?"
        target = "Ce mai faceti?"
        self._test(lang, s, target)

    def test_ro_3(self):
        "Tests plain English messages translated to Romanian"
        lang = 'ro'
        s = "What should I do now?"
        target = "Ce sa fac acum?"
        self._test(lang, s, target)

    def test_ro_missing_1(self):
        "Tests plain English messages that are not in the translation files (ro)"
        lang = 'ro'
        s = "This string doesn't exist in the translation"
        target = s
        self._test(lang, s, target)
    
    def test_go_1(self):
        "Tests plain English messages translated in the mythical go language"
        lang = 'en'
        s = "Good day"
        target = s
        self._test(lang, s, target)

    def test_go_2(self):
        "Tests plain English messages translated in the mythical go language"
        lang = 'en'
        s = "How do you do?"
        target = s
        self._test(lang, s, target)

    def test_go_3(self):
        "Tests plain English messages translated in the mythical go language"
        lang = 'en'
        s = "What should I do now?"
        target = s
        self._test(lang, s, target)

    def test_go_missing_1(self):
        "Tests plain English messages that are not in the translation files (go)"
        lang = 'en'
        s = "This string doesn't exist in the translation"
        target = s
        self._test(lang, s, target)


if __name__ == '__main__':
    sys.exit(unittest.main() or 0)

