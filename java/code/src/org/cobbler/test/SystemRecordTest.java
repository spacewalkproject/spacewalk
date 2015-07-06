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

package org.cobbler.test;

import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

import org.cobbler.CobblerConnection;
import org.cobbler.Distro;
import org.cobbler.Image;
import org.cobbler.Profile;
import org.cobbler.SystemRecord;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Tests SystemRecord.
 */
public class SystemRecordTest extends BaseTestCaseWithUser {

    /** The connection. */
    private CobblerConnection connection;

    /** The system. */
    private SystemRecord system;

    /**
     * Sets up a connection and system.
     * @throws Exception in case anything goes wrong
     */
    @SuppressWarnings("rawtypes")
    public void setUp() throws Exception {
        super.setUp();
        connection = CobblerXMLRPCHelper.getConnection(user.getLogin());
        Distro distro = new Distro.Builder()
                .setName("test-distro")
                .setKernel("kernel")
                .setInitrd("initrd")
                .setKsmeta(new HashMap<>())
                .setBreed("redhat")
                .setOsVersion("rhel6")
                .setArch("x86_64")
                .build(connection);
        Profile profile = Profile.create(connection, "test-profile", distro);
        system = SystemRecord.create(connection, "test-system", profile);
    }

    /**
     * Test power on.
     */
    public void testPowerOn() {
        assertTrue(system.powerOn());
    }

    /**
     * Test power off.
     */
    public void testPowerOff() {
        assertTrue(system.powerOff());
    }

    /**
     * Test reboot.
     */
    public void testReboot() {
        assertTrue(system.reboot());
    }

    /**
     * Test status retrieval.
     */
    public void testGetPowerStatus() {
        assertTrue(system.getPowerStatus());
    }

    /**
     * Test setter and getter for power type.
     */
    public void testSetGetPowerType() {
        String expected = TestUtils.randomString();
        system.setPowerType(expected);
        assertEquals(expected, system.getPowerType());
        assertSystemKeyEquals(expected, SystemRecord.POWER_TYPE);
    }

    /**
     * Test setter and getter for power address.
     */
    public void testSetGetPowerAddress() {
        String expected = TestUtils.randomString();
        system.setPowerAddress(expected);
        assertEquals(expected, system.getPowerAddress());
        assertSystemKeyEquals(expected, SystemRecord.POWER_ADDRESS);
    }

    /**
     * Test setter and getter for power username.
     */
    public void testSetGetPowerUsername() {
        String expected = TestUtils.randomString();
        system.setPowerUsername(expected);
        assertEquals(expected, system.getPowerUsername());
        assertSystemKeyEquals(expected, SystemRecord.POWER_USERNAME);
    }

    /**
     * Test setter and getter for power password.
     */
    public void testSetGetPowerPassword() {
        String expected = TestUtils.randomString();
        system.setPowerPassword(expected);
        assertEquals(expected, system.getPowerPassword());
        assertSystemKeyEquals(expected, SystemRecord.POWER_PASSWORD);
    }

    /**
     * Test setter and getter for power id.
     */
    public void testSetGetPowerId() {
        String expected = TestUtils.randomString();
        system.setPowerId(expected);
        assertEquals(expected, system.getPowerId());
        assertSystemKeyEquals(expected, SystemRecord.POWER_ID);
    }

    /**
     * Test setter and getter for the associated image.
     */
    public void testSetGetImage() {
        Image expected = Image.create(connection, "test", Image.TYPE_ISO, "dummy.file");
        system.setImage(expected);
        assertEquals(expected, system.getImage());
        assertSystemKeyEquals(expected.getName(), SystemRecord.IMAGE);

        expected = Image.create(connection, "test_two", Image.TYPE_ISO, "dummy.file");
        system.setImage(expected.getName());
        assertEquals(expected, system.getImage());
        assertSystemKeyEquals(expected.getName(), SystemRecord.IMAGE);
    }

    /**
     * Check in MockConnection that the current system has a certain value
     * corresponding to a key
     * @param expected the expected value for key
     * @param key the key
     */
    @SuppressWarnings("unchecked")
    private void assertSystemKeyEquals(String expected, String key) {
        HashMap<String, Object> criteria = new HashMap<String, Object>();
        criteria.put("uid", system.getId());
        List<Map<String, Object>> result = (List<Map<String, Object>>) connection
            .invokeMethod("find_system", criteria);
        assertEquals(expected, result.get(0).get(key));
    }
}
