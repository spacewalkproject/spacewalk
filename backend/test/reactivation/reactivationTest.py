#!/usr/bin/python
#
# Copyright (c) 2008--2013 Red Hat, Inc.
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

# PyUnit test for bug 122534
# https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=122534

# This test assumes the following:
#     1. The machine this test is running on has a working rhn perl stack
#        (per docs/setup-dev-box.txt, steps 1-24), and has up2date properly
#        installed.
#     2. The machine this test is running on is registered to rhn thru
#        the database indicated with the DB variable below and has
#        a provisioning entitlement
#     3. USERNAME and SYSTEMID variables below are set correctly
#     4. RHNREGURL is set to the appropriate url of the box we're testing,
#        and that that box is also pointed to the same db as set in the DB
#        variable
# This test uses the following util programs (assumed to be in the
# same location of this test script, defined with UTIL_DIR)
#     1. get_profile_name
#     2. get_reactivation_key
#     2. set_profile_name

import unittest
import os
import string
import getpass
import sys


# Bad. These should be read from central location and not hard coded
DB = "webdev"
USERNAME = "hasuf"
SYSTEMID = 1004541262
NEWPROFILENAMESUFFIX = "_SOMESUFFIX"
RHNREGURL = "http://dhcp59-101.rdu.redhat.com/XMLRPC"
UTIL_DIR = "./"  # location of helper perl scripts

DEBUG = 1


class ReactivationTest(unittest.TestCase):

    def setUp(self):
        # make sure we're root
        self.__assertRoot()

    def testProfileNameSticksAfterReactivation(self):
        """ Makes sure that upon reactivation, the profile name of a system \
            doesn't change.
            Follows these steps:
                1. saves original profile name
                2. adds a suffix to original profile name
                3. gets a reactivation key
                4. registers box (with rhnreg_ks)
                5. asserts that the profile name is same from step 2.
                6. resets profile name to saved name from step 1.
        """
        # save off the original name
        self.debug("Getting original name...")
        origProfileName = self.runGetProfileName()
        self.debugln("done")

        # set new profile name
        newname = "%s%s" % (origProfileName, NEWPROFILENAMESUFFIX)
        self.runSetProfileName(newname)
        newnameVerify = self.runGetProfileName()
        self.debugln("Name before reactivation: %s" % newnameVerify)
        self.assertEquals(newname, newnameVerify)

        # get a re-activation key
        self.debug("Getting reactivation key...")
        key = self.runGetReactivationKey()
        self.debugln("done")

        # re-register using the re-activation key
        # the retrieved name should be the same as newname
        try:
            self.debug("Re-registering...")
            self.runReactivation(key)
            self.debugln("done")

            postRegName = self.runGetProfileName()
            self.debugln("Name after reactivation: %s" % postRegName)
            self.assertEquals(newname, postRegName)

            # if we get here, we're basically good

        finally:
            # change it back to old name
            self.debug("Resetting name...")
            self.runSetProfileName(origProfileName)
            origNameVerify = self.runGetProfileName()
            self.assertEquals(origProfileName, origNameVerify)
            self.debugln("done")

    def runSetProfileName(self, newname):
        prog = "set_profile_name"
        cmd = "%s%s %s %s %s" % (UTIL_DIR, prog, DB, SYSTEMID, newname)
        return self.__runSimpleProg(cmd)

    def runGetProfileName(self):
        prog = "get_profile_name"
        cmd = "%s%s %s %s" % (UTIL_DIR, prog, DB, SYSTEMID)
        return self.__runSimpleProg(cmd)

    def runGetReactivationKey(self):
        prog = "get_reactivation_key"
        cmd = "%s%s %s %s %s" % (UTIL_DIR, prog, DB, SYSTEMID, USERNAME)
        return self.__runSimpleProg(cmd)

    def runReactivation(self, regkey):
        prog = "rhnreg_ks"
        cmd = "/usr/sbin/%s --force --activationkey=%s --serverUrl=%s" % \
            (prog, regkey, RHNREGURL)
        return self.__runSimpleProg(cmd)

    def __runSimpleProg(self, cmd):
        """ runs a program that returns a one-line response """
        cmdout = os.popen('%s' % cmd)
        lines = ""
        line = cmdout.readline()
        while line:
            lines = lines + line
            line = cmdout.readline()

        retcode = cmdout.close()
        self.assertEquals(None, retcode, "Problem running %s: %s" %
                          (cmd, lines))

        return string.strip(lines)

    def __assertRoot(self):
        user = getpass.getuser()
        self.assertEquals("root", user, "Must run tests as root")

    def debug(self, str):
        if DEBUG:
            sys.stdout.write(str)
            sys.stdout.flush()

    def debugln(self, str):
        if DEBUG:
            sys.stdout.write(str + '\n')

if __name__ == "__main__":
    unittest.main()
