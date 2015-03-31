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

package com.redhat.rhn.frontend.events.test;

import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.frontend.action.ssm.test.PowerManagementConfigurationActionTest;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.events.SsmPowerManagementAction;
import com.redhat.rhn.frontend.events.SsmPowerManagementEvent;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerPowerCommand.Operation;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerPowerSettingsUpdateCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerSystemCreateCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

import org.cobbler.CobblerConnection;
import org.cobbler.SystemRecord;
import org.cobbler.test.MockConnection;

import java.util.LinkedList;
import java.util.List;

/**
 * Tests SsmPowerManagementAction.
 */
public class SsmPowerManagementActionTest extends BaseTestCaseWithUser {

    private CobblerConnection connection;
    private List<Server> servers;
    private List<SystemOverview> systemOverviews;

    /**
     * Sets up a request.
     * @throws Exception if things go wrong
     * @see com.redhat.rhn.testing.RhnMockStrutsTestCase#setUp()
     */
    @Override
    public void setUp() throws Exception {
        super.setUp();
        connection = CobblerXMLRPCHelper.getConnection(user.getLogin());
        servers = PowerManagementConfigurationActionTest
            .setUpTestProvisionableSsmServers(user);
        systemOverviews = new LinkedList<SystemOverview>();
        for (Server server : servers) {
            SystemOverview systemOverview = new SystemOverview();
            systemOverview.setId(server.getId());
            systemOverviews.add(systemOverview);

            assertNull(new CobblerPowerSettingsUpdateCommand(user, server, "ipmi",
                "192.168.0.1", "user", "password", null).store());
        }
    }

    /**
     * Tests action execution.
     * @throws Exception if things go wrong
     */
    public void testAction() throws Exception {
        SsmPowerManagementAction action = new SsmPowerManagementAction();
        action.execute(new SsmPowerManagementEvent(user.getId(), systemOverviews,
            Operation.PowerOn));

        for (Server server : servers) {
            String cobblerName = CobblerSystemCreateCommand
                .getCobblerSystemRecordName(server);
            SystemRecord systemRecord = SystemRecord.lookupByName(connection, cobblerName);
            assertContains(MockConnection.getPowerCommands(), "power_system on " +
                systemRecord.getId());
        }
    }
}
