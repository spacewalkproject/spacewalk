/**
 * Copyright (c) 2009--2010 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public License,
 * version 2 (GPLv2). There is NO WARRANTY for this software, express or
 * implied, including the implied warranties of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
 * along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 *
 * Red Hat trademarks are not licensed under GPLv2. No permission is
 * granted to use or replicate Red Hat trademarks that are incorporated
 * in this software or its documentation.
 */
package com.redhat.rhn.manager.kickstart.test;

import com.redhat.rhn.domain.kickstart.KickstartCommand;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.manager.kickstart.KickstartLocaleCommand;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

/**
 * KickstartLocaleCommandTest - test for KickstartDetailsCommand
 * @version $Rev$
 */
public class KickstartLocaleCommandTest extends BaseTestCaseWithUser {

    public void testKickstartLocaleCommand() throws Exception {
        KickstartData k = KickstartDataTest.createKickstartWithOptions(user.getOrg());

        KickstartLocaleCommand cmd = new KickstartLocaleCommand(k.getId(), user);
        String tz = cmd.getTimezone();

        assertEquals("", tz);
        cmd.setTimezone("America/New_York");

        cmd.store();
        flushAndEvict(cmd.getKickstartData());

        String tz2 = cmd.getTimezone();
        assertEquals("America/New_York", tz2);
    }

    public void testKickstartLocaleCommandWithUtc() throws Exception {
        KickstartData k = KickstartDataTest.createKickstartWithOptions(user.getOrg());

        KickstartLocaleCommand cmd = new KickstartLocaleCommand(k.getId(), user);

        // set timezone command to --utc America/New_York
        cmd.setTimezone("America/New_York");
        cmd.useUtc();

        cmd.store();
        flushAndEvict(cmd.getKickstartData());

        // the timezone should be America/New_York
        String tz2 = cmd.getTimezone();
        assertEquals("America/New_York", tz2);

        // the timezone command with all args should be --utc America/New_York
        KickstartCommand timezoneCommand = cmd.getKickstartData().getCommand("timezone");
        String args = timezoneCommand.getArguments();
        assertEquals("--utc America/New_York", args);

        assertTrue(cmd.getKickstartData().isUsingUtc().booleanValue());

        // Run useUtc() again, to be sure we don't
        // do something like: --utc --utc America/New_York
        cmd.useUtc();
        cmd.store();
        flushAndEvict(cmd.getKickstartData());

        timezoneCommand = cmd.getKickstartData().getCommand("timezone");
        args = timezoneCommand.getArguments();
        assertEquals("--utc America/New_York", args);

        cmd.doNotUseUtc();
        cmd.store();
        flushAndEvict(cmd.getKickstartData());

        assertFalse(cmd.getKickstartData().isUsingUtc().booleanValue());
    }
}
