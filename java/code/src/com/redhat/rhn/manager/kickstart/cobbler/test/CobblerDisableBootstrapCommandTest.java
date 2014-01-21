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

import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerDisableBootstrapCommand;
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

/**
 * Tests Cobbler default PXE configuration for bare-metal server registration.
 */
public class CobblerDisableBootstrapCommandTest extends BaseTestCaseWithUser {

    /**
     * Tests the execution of this Cobbler command.
     * @throws Exception if unforeseen problems arise
     */
    public void testStore() throws Exception {
        CobblerConnection connection = CobblerXMLRPCHelper.getConnection("test");

        new CobblerEnableBootstrapCommand(user).store();

        CobblerDisableBootstrapCommand command = new CobblerDisableBootstrapCommand(user);
        command.store();

        HashMap<String, Object> criteria = new HashMap<String, Object>();
        criteria.put("name", Distro.BOOTSTRAP_NAME);
        List<Map<String, Object>> distro = CobblerDisableBootstrapCommandTest.invoke(
            connection, "find_distro", criteria);
        assertEquals(0, distro.size());

        criteria.put("name", Profile.BOOTSTRAP_NAME);
        List<Map<String, Object>> profile = CobblerDisableBootstrapCommandTest.invoke(
            connection, "find_profile", criteria);
        assertEquals(0, profile.size());

        criteria.put("name", SystemRecord.BOOTSTRAP_NAME);
        List<Map<String, Object>> system = CobblerDisableBootstrapCommandTest.invoke(
            connection, "find_system", criteria);
        assertEquals(0, system.size());

        List<ActivationKey> activationKeys = ActivationKeyManager.getInstance()
                .findBootstrap();
        assertEquals(0, activationKeys.size());
    }

    /**
     * Executes a Cobbler "find" command.
     * @param connection connection to Cobbler
     * @param command the find command itself
     * @param criteria search criteria
     * @return the result
     */
    @SuppressWarnings("unchecked")
    public static List<Map<String, Object>> invoke(CobblerConnection connection,
        String command, HashMap<String, Object> criteria) {
        return (List<Map<String, Object>>) connection.invokeMethod(command, criteria);
    }
}
