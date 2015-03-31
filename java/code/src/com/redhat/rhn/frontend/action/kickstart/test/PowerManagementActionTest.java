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
package com.redhat.rhn.frontend.action.kickstart.test;

import com.redhat.rhn.common.util.Asserts;
import com.redhat.rhn.domain.server.NetworkInterface;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerNetAddress4;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.action.kickstart.PowerManagementAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

import org.cobbler.CobblerConnection;
import org.cobbler.SystemRecord;
import org.cobbler.test.MockConnection;

import servletunit.HttpServletRequestSimulator;

import java.util.Map;

/**
 * Tests the Power Management action.
 */
public class PowerManagementActionTest extends RhnMockStrutsTestCase {

    // poor-man fixture
    /** Expected power management type. */
    public static final String EXPECTED_TYPE = "ipmilan";

    /** Expected power management address. */
    public static final String EXPECTED_ADDRESS = "192.123.23.21";

    /** Expected power management username. */
    public static final String EXPECTED_USERNAME = "power management test username";

    /** Expected power management password. */
    public static final String EXPECTED_PASSWORD = "power management test password";

    /** Expected power management ID. */
    public static final String EXPECTED_ID = "123";

    /** Alternative expected power management address. */
    public static final String EXPECTED_ADDRESS_2 = "192.123.23.22";

    /** Alternative expected power management address. */
    public static final String EXPECTED_USERNAME_2 = "power management test username 2";

    /** Alternative expected power management password. */
    public static final String EXPECTED_PASSWORD_2 = "power management test password 2";

    /** Alternative expected power management ID. */
    public static final String EXPECTED_ID_2 = "122";

    /**
     * Sets up action path and mocked Cobbler connection.
     * @throws Exception if something goes wrong
     */
    @Override
    public void setUp() throws Exception {
        super.setUp();
        MockConnection.clear();
        setRequestPathInfo("/systems/details/kickstart/PowerManagement");
    }

    /**
     * Tests that action returns correct default parameters for a system without
     * a profile.
     * @throws Exception if something goes wrong
     */
    @SuppressWarnings("unchecked")
    public void testExecuteNewSystemsDefault() throws Exception {

        Server server = ServerFactoryTest.createTestServer(user, true);
        NetworkInterface networkInterface = server.getNetworkInterfaces().iterator().next();
        networkInterface.setSa4(new ServerNetAddress4() {
            {
                setAddress(EXPECTED_ADDRESS);
            }
        });
        addRequestParameter(RequestContext.SID, server.getId().toString());
        actionPerform();

        Map<String, String> types = (Map<String, String>) request
            .getAttribute(PowerManagementAction.TYPES);
        Asserts.assertContains(types.values(), EXPECTED_TYPE);

        assertEquals(EXPECTED_TYPE, request.getAttribute(PowerManagementAction.POWER_TYPE));
        assertNull(request.getAttribute(PowerManagementAction.POWER_ADDRESS));
        assertNull(request.getAttribute(PowerManagementAction.POWER_USERNAME));
        assertNull(request.getAttribute(PowerManagementAction.POWER_PASSWORD));
        assertNull(request.getAttribute(PowerManagementAction.POWER_ID));
        verifyNoActionErrors();
        verifyNoActionMessages();
    }

    /**
     * Tests saving the configuration of a new system.
     * @throws Exception if something goes wrong
     */
    @SuppressWarnings("unchecked")
    public void testExecuteSaveNewSystem() throws Exception {
        Server server = ServerFactoryTest.createTestServer(user, true);

        addRequestParameter(RequestContext.SID, server.getId().toString());
        request.setMethod(HttpServletRequestSimulator.POST);
        addSubmitted();
        addDispatchCall("kickstart.powermanagement.jsp.save_only");
        request.addParameter(PowerManagementAction.POWER_TYPE, EXPECTED_TYPE);
        request.addParameter(PowerManagementAction.POWER_ADDRESS, EXPECTED_ADDRESS);
        request.addParameter(PowerManagementAction.POWER_USERNAME, EXPECTED_USERNAME);
        request.addParameter(PowerManagementAction.POWER_PASSWORD, EXPECTED_PASSWORD);
        request.addParameter(PowerManagementAction.POWER_ID, EXPECTED_ID);
        actionPerform();

        Map<String, String> types = (Map<String, String>) request
            .getAttribute(PowerManagementAction.TYPES);
        Asserts.assertContains(types.values(), EXPECTED_TYPE);

        assertEquals(EXPECTED_TYPE, request.getAttribute(PowerManagementAction.POWER_TYPE));
        assertEquals(EXPECTED_ADDRESS,
            request.getAttribute(PowerManagementAction.POWER_ADDRESS));
        assertEquals(EXPECTED_USERNAME,
            request.getAttribute(PowerManagementAction.POWER_USERNAME));
        assertEquals(EXPECTED_PASSWORD,
            request.getAttribute(PowerManagementAction.POWER_PASSWORD));
        assertEquals(EXPECTED_ID, request.getAttribute(PowerManagementAction.POWER_ID));
        verifyNoActionErrors();
        verifyActionMessage("kickstart.powermanagement.saved");

        CobblerConnection connection = CobblerXMLRPCHelper.getConnection(user);
        SystemRecord record = SystemRecord.lookupById(connection, server.getCobblerId());

        assertEquals(EXPECTED_TYPE, record.getPowerType());
        assertEquals(EXPECTED_ADDRESS, record.getPowerAddress());
        assertEquals(EXPECTED_USERNAME, record.getPowerUsername());
        assertEquals(EXPECTED_PASSWORD, record.getPowerPassword());
        assertEquals(EXPECTED_ID, record.getPowerId());
    }

    /**
     * Tests reading the configuration of a system that has already been
     * configured.
     * @throws Exception if something goes wrong
     */
    @SuppressWarnings("unchecked")
    public void testExecuteReadSavedSystem() throws Exception {
        Server server = ServerFactoryTest.createTestServer(user, true);

        addRequestParameter(RequestContext.SID, server.getId().toString());
        request.setMethod(HttpServletRequestSimulator.POST);
        addSubmitted();
        addDispatchCall("kickstart.powermanagement.jsp.save_only");
        request.addParameter(PowerManagementAction.POWER_TYPE, EXPECTED_TYPE);
        request.addParameter(PowerManagementAction.POWER_ADDRESS, EXPECTED_ADDRESS);
        request.addParameter(PowerManagementAction.POWER_USERNAME, EXPECTED_USERNAME);
        request.addParameter(PowerManagementAction.POWER_PASSWORD, EXPECTED_PASSWORD);
        request.addParameter(PowerManagementAction.POWER_ID, EXPECTED_ID);
        actionPerform();

        clearRequestParameters();
        addRequestParameter(RequestContext.SID, server.getId().toString());
        request.setMethod(HttpServletRequestSimulator.GET);
        actionPerform();

        Map<String, String> types = (Map<String, String>) request
            .getAttribute(PowerManagementAction.TYPES);
        Asserts.assertContains(types.values(), EXPECTED_TYPE);

        assertEquals(EXPECTED_TYPE, request.getAttribute(PowerManagementAction.POWER_TYPE));
        assertEquals(EXPECTED_ADDRESS,
            request.getAttribute(PowerManagementAction.POWER_ADDRESS));
        assertEquals(EXPECTED_USERNAME,
            request.getAttribute(PowerManagementAction.POWER_USERNAME));
        assertEquals(EXPECTED_PASSWORD,
            request.getAttribute(PowerManagementAction.POWER_PASSWORD));
        assertEquals(EXPECTED_ID, request.getAttribute(PowerManagementAction.POWER_ID));
        verifyNoActionErrors();
    }

    /**
     * Tests overwriting the configuration of an existing system.
     * @throws Exception if something goes wrong
     */
    public void testExecuteOverwriteExistingSystem() throws Exception {
        Server server = ServerFactoryTest.createTestServer(user, true);

        addRequestParameter(RequestContext.SID, server.getId().toString());
        request.setMethod(HttpServletRequestSimulator.POST);
        addSubmitted();
        addDispatchCall("kickstart.powermanagement.jsp.save_only");
        request.addParameter(PowerManagementAction.POWER_TYPE, EXPECTED_TYPE);
        request.addParameter(PowerManagementAction.POWER_ADDRESS, EXPECTED_ADDRESS);
        request.addParameter(PowerManagementAction.POWER_USERNAME, EXPECTED_USERNAME);
        request.addParameter(PowerManagementAction.POWER_PASSWORD, EXPECTED_PASSWORD);
        request.addParameter(PowerManagementAction.POWER_ID, EXPECTED_ID);
        actionPerform();

        request.addParameter(PowerManagementAction.POWER_TYPE, EXPECTED_TYPE);
        request.addParameter(PowerManagementAction.POWER_ADDRESS, EXPECTED_ADDRESS_2);
        request.addParameter(PowerManagementAction.POWER_USERNAME, EXPECTED_USERNAME_2);
        request.addParameter(PowerManagementAction.POWER_PASSWORD, EXPECTED_PASSWORD_2);
        request.addParameter(PowerManagementAction.POWER_ID, EXPECTED_ID_2);
        actionPerform();

        assertEquals(EXPECTED_ADDRESS_2,
            request.getAttribute(PowerManagementAction.POWER_ADDRESS));
        assertEquals(EXPECTED_USERNAME_2,
            request.getAttribute(PowerManagementAction.POWER_USERNAME));
        assertEquals(EXPECTED_PASSWORD_2,
            request.getAttribute(PowerManagementAction.POWER_PASSWORD));
        assertEquals(EXPECTED_ID_2, request.getAttribute(PowerManagementAction.POWER_ID));

        CobblerConnection connection = CobblerXMLRPCHelper.getConnection(user);
        SystemRecord record = SystemRecord.lookupById(connection, server.getCobblerId());

        assertEquals(EXPECTED_ADDRESS_2, record.getPowerAddress());
        assertEquals(EXPECTED_USERNAME_2, record.getPowerUsername());
        assertEquals(EXPECTED_PASSWORD_2, record.getPowerPassword());
        assertEquals(EXPECTED_ID_2, record.getPowerId());
        verifyNoActionErrors();
    }

    /**
     * Tests powering on a system.
     * @throws Exception if something goes wrong
     */
    public void testPowerOn() throws Exception {
        Server server = ServerFactoryTest.createTestServer(user, true);

        addRequestParameter(RequestContext.SID, server.getId().toString());
        request.setMethod(HttpServletRequestSimulator.POST);
        addSubmitted();
        addDispatchCall("kickstart.powermanagement.jsp.power_on");
        request.addParameter(PowerManagementAction.POWER_TYPE, EXPECTED_TYPE);
        request.addParameter(PowerManagementAction.POWER_ADDRESS, EXPECTED_ADDRESS);
        request.addParameter(PowerManagementAction.POWER_USERNAME, EXPECTED_USERNAME);
        request.addParameter(PowerManagementAction.POWER_PASSWORD, EXPECTED_PASSWORD);
        request.addParameter(PowerManagementAction.POWER_ID, EXPECTED_ID);
        actionPerform();

        verifyNoActionErrors();
        assertEquals("power_system on " + server.getCobblerId(),
            MockConnection.getLatestPowerCommand());
    }

    /**
     * Tests powering off a system.
     * @throws Exception if something goes wrong
     */
    public void testPowerOff() throws Exception {
        Server server = ServerFactoryTest.createTestServer(user, true);

        addRequestParameter(RequestContext.SID, server.getId().toString());
        request.setMethod(HttpServletRequestSimulator.POST);
        addSubmitted();
        addDispatchCall("kickstart.powermanagement.jsp.power_off");
        request.addParameter(PowerManagementAction.POWER_TYPE, EXPECTED_TYPE);
        request.addParameter(PowerManagementAction.POWER_ADDRESS, EXPECTED_ADDRESS);
        request.addParameter(PowerManagementAction.POWER_USERNAME, EXPECTED_USERNAME);
        request.addParameter(PowerManagementAction.POWER_PASSWORD, EXPECTED_PASSWORD);
        request.addParameter(PowerManagementAction.POWER_ID, EXPECTED_ID);
        actionPerform();

        verifyNoActionErrors();
        assertEquals("power_system off " + server.getCobblerId(),
            MockConnection.getLatestPowerCommand());
    }

    /**
     * Tests powering off and on a system.
     * @throws Exception if something goes wrong
     */
    public void testReboot() throws Exception {
        Server server = ServerFactoryTest.createTestServer(user, true);

        addRequestParameter(RequestContext.SID, server.getId().toString());
        request.setMethod(HttpServletRequestSimulator.POST);
        addSubmitted();
        addDispatchCall("kickstart.powermanagement.jsp.reboot");
        request.addParameter(PowerManagementAction.POWER_TYPE, EXPECTED_TYPE);
        request.addParameter(PowerManagementAction.POWER_ADDRESS, EXPECTED_ADDRESS);
        request.addParameter(PowerManagementAction.POWER_USERNAME, EXPECTED_USERNAME);
        request.addParameter(PowerManagementAction.POWER_PASSWORD, EXPECTED_PASSWORD);
        request.addParameter(PowerManagementAction.POWER_ID, EXPECTED_ID);
        actionPerform();

        verifyNoActionErrors();
        assertEquals("power_system reboot " + server.getCobblerId(),
            MockConnection.getLatestPowerCommand());
    }

    /**
     * Tests retrieving the status of a system.
     * @throws Exception if something goes wrong
     */
    public void testGetStatus() throws Exception {
        Server server = ServerFactoryTest.createTestServer(user, true);

        addRequestParameter(RequestContext.SID, server.getId().toString());
        request.setMethod(HttpServletRequestSimulator.POST);
        addSubmitted();
        addDispatchCall("kickstart.powermanagement.jsp.get_status");
        request.addParameter(PowerManagementAction.POWER_TYPE, EXPECTED_TYPE);
        request.addParameter(PowerManagementAction.POWER_ADDRESS, EXPECTED_ADDRESS);
        request.addParameter(PowerManagementAction.POWER_USERNAME, EXPECTED_USERNAME);
        request.addParameter(PowerManagementAction.POWER_PASSWORD, EXPECTED_PASSWORD);
        request.addParameter(PowerManagementAction.POWER_ID, EXPECTED_ID);
        actionPerform();

        verifyNoActionErrors();
        assertEquals(true, request.getAttribute(PowerManagementAction.POWER_STATUS_ON));
        assertEquals("power_system status " + server.getCobblerId(),
            MockConnection.getLatestPowerCommand());
    }
}
