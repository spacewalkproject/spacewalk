/**
 * Copyright (c) 2013 SUSE LLC
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
package com.redhat.rhn.manager.kickstart.cobbler.test;

import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerPowerSettingsUpdateCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.ServerTestUtils;
import com.redhat.rhn.testing.TestUtils;

import org.cobbler.CobblerConnection;
import org.cobbler.SystemRecord;

/**
 * Tests Cobbler command to update power management settings for a system.
 */
public class CobblerPowerSettingsUpdateCommandTest extends BaseTestCaseWithUser {

    /**
     * Tests the execution of this Cobbler command.
     * @throws Exception if unforeseen problems arise
     */
    public void testStore() throws Exception {
        CobblerConnection connection = CobblerXMLRPCHelper.getConnection("test");
        Server server = ServerTestUtils.createTestSystem(user);

        // test creating a new cobbler system profile
        String expectedPowerType = TestUtils.randomString();
        String expectedPowerAddress = TestUtils.randomString();
        String expectedPowerUsername = TestUtils.randomString();
        String expectedPowerPassword = TestUtils.randomString();
        String expectedPowerId = TestUtils.randomString();

        assertNull(new CobblerPowerSettingsUpdateCommand(user, server, expectedPowerType,
            expectedPowerAddress, expectedPowerUsername, expectedPowerPassword,
            expectedPowerId).store());

        SystemRecord systemRecord = SystemRecord.lookupById(connection,
            server.getCobblerId());
        assertEquals(expectedPowerType, systemRecord.getPowerType());
        assertEquals(expectedPowerAddress, systemRecord.getPowerAddress());
        assertEquals(expectedPowerUsername, systemRecord.getPowerUsername());
        assertEquals(expectedPowerPassword, systemRecord.getPowerPassword());
        assertEquals(expectedPowerId, systemRecord.getPowerId());

        // test again reusing the existing cobbler system profile
        expectedPowerType = TestUtils.randomString();
        expectedPowerAddress = TestUtils.randomString();
        expectedPowerUsername = TestUtils.randomString();
        expectedPowerPassword = TestUtils.randomString();
        expectedPowerId = TestUtils.randomString();

        assertNull(new CobblerPowerSettingsUpdateCommand(user, server, expectedPowerType,
            expectedPowerAddress, expectedPowerUsername, expectedPowerPassword,
            expectedPowerId).store());

        SystemRecord newSystemRecord = SystemRecord.lookupById(connection,
            server.getCobblerId());
        assertEquals(expectedPowerType, newSystemRecord.getPowerType());
        assertEquals(expectedPowerAddress, newSystemRecord.getPowerAddress());
        assertEquals(expectedPowerUsername, newSystemRecord.getPowerUsername());
        assertEquals(expectedPowerPassword, newSystemRecord.getPowerPassword());
        assertEquals(expectedPowerId, newSystemRecord.getPowerId());
        assertEquals(systemRecord.getId(), newSystemRecord.getId());
    }
}
