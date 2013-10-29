/**
 * Copyright (c) 2013 SUSE
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

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.server.ServerGroupType;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.token.ActivationKeyFactory;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerEnableBootstrapCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;
import com.redhat.rhn.manager.token.ActivationKeyManager;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

import org.cobbler.CobblerConnection;
import org.cobbler.Distro;
import org.cobbler.Profile;
import org.cobbler.SystemRecord;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Tests Cobbler default PXE configuration for bare-metal server registration.
 * @version $Rev$
 */
public class CobblerEnableBootstrapCommandTest extends BaseTestCaseWithUser {

    /**
     * Tests the execution of this Cobbler command.
     * @throws Exception if unforeseen problems arise
     */
    public void testStore() throws Exception {
        // create a pre-existing system, profile and distro to test they have
        // been replaced
        CobblerConnection connection = CobblerXMLRPCHelper.getConnection("test");
        Distro distro = Distro.create(connection, Distro.BOOTSTRAP_NAME, "test-kernel",
            "test-initrd", new HashMap<Object, Object>());
        Profile profile = Profile.create(connection, Profile.BOOTSTRAP_NAME, distro);
        SystemRecord system = SystemRecord.create(connection, SystemRecord.BOOTSTRAP_NAME,
            profile);

        // create pre-existing activation key
        ActivationKey previousActivationKey = ActivationKeyFactory.createNewKey(user, null,
            "test-key", "For bootstrap use", 0L, null, false);
        previousActivationKey.setBootstrap("Y");

        // check that all above actually exists
        HashMap<String, Object> criteria = new HashMap<String, Object>();
        criteria.put("uid", system.getId());
        List<Map<String, Object>> previousSystem = CobblerDisableBootstrapCommandTest
            .invoke(connection, "find_system", criteria);
        assertEquals(1, previousSystem.size());

        criteria.put("uid", profile.getId());
        List<Map<String, Object>> previousProfile = CobblerDisableBootstrapCommandTest
            .invoke(connection, "find_profile", criteria);
        assertEquals(1, previousProfile.size());

        criteria.put("uid", distro.getId());
        List<Map<String, Object>> previousDistro = CobblerDisableBootstrapCommandTest
            .invoke(connection, "find_distro", criteria);
        assertEquals(1, previousDistro.size());

        List<ActivationKey> previousActivationKeys = ActivationKeyManager.getInstance()
                .findBootstrap();
        assertEquals(1, previousActivationKeys.size());

        CobblerEnableBootstrapCommand command = new CobblerEnableBootstrapCommand(user,
            true);
        assertNull(command.store());

        // check previous records have been deleted
        criteria.put("uid", system.getId());
        previousSystem = CobblerDisableBootstrapCommandTest.invoke(connection,
            "find_system", criteria);
        assertEquals(0, previousSystem.size());

        criteria.put("uid", profile.getId());
        previousProfile = CobblerDisableBootstrapCommandTest.invoke(connection,
            "find_profile", criteria);
        assertEquals(0, previousProfile.size());

        criteria.put("uid", distro.getId());
        previousDistro = CobblerDisableBootstrapCommandTest.invoke(connection,
            "find_distro", criteria);
        assertEquals(0, previousDistro.size());

        // check new records have been added
        ConfigDefaults config = ConfigDefaults.get();
        criteria.clear();

        criteria.put("name", Distro.BOOTSTRAP_NAME);
        Map<String, Object> newDistro = CobblerDisableBootstrapCommandTest.invoke(
            connection, "find_distro", criteria).get(0);
        assertEquals(config.getCobblerBootstrapKernel(), newDistro.get("kernel"));
        assertEquals(config.getCobblerBootstrapInitrd(), newDistro.get("initrd"));
        assertEquals(config.getCobblerBootstrapBreed(), newDistro.get("breed"));
        assertEquals(config.getCobblerBootstrapArch(), newDistro.get("arch"));

        criteria.put("name", Profile.BOOTSTRAP_NAME);
        Map<String, Object> newProfile = CobblerDisableBootstrapCommandTest.invoke(
            connection, "find_profile", criteria).get(0);
        assertEquals(Distro.BOOTSTRAP_NAME, newProfile.get("distro"));
        Map<String, Object> expectedOptions = new HashMap<String, Object>();
        String activationKeyToken = user.getOrg().getId() + "-" +
            ActivationKey.BOOTSTRAP_TOKEN;
        expectedOptions.put("spacewalk_hostname", config.getHostname());
        expectedOptions.put("spacewalk_activationkey", activationKeyToken);
        expectedOptions.put("ROOTFS_FSCK", "0");
        assertEquals(expectedOptions, newProfile.get("kopts"));

        criteria.put("name", SystemRecord.BOOTSTRAP_NAME);
        Map<String, Object> newSystem = CobblerDisableBootstrapCommandTest.invoke(
            connection, "find_system", criteria).get(0);
        assertEquals(Profile.BOOTSTRAP_NAME, newSystem.get("profile"));

        List<ActivationKey> activationKeys = ActivationKeyManager.getInstance()
                .findBootstrap();
        assertEquals(1, activationKeys.size());
        ActivationKey activationKey = activationKeys.get(0);
        assertEquals(activationKeyToken, activationKey.getKey());
        assertNotNull(activationKey.getToken());
        assertNull(activationKey.getUsageLimit());
        assertFalse(activationKey.getDeployConfigs());
        Set<ServerGroupType> entitlements = activationKey.getToken().getEntitlements();
        assertEquals(1, entitlements.size());
        assertEquals("bootstrap_entitled", entitlements.iterator().next().getLabel());
    }
}
