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
package com.redhat.rhn.manager.system.test;

import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.manager.system.VirtualizationActionCommand;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

import java.util.Date;

/**
 * VirtualizationActionCommandTest
 * @version $Rev$
 */
public class VirtualizationActionCommandTest extends BaseTestCaseWithUser {
    public void testLookupActionLabel() throws Exception {

        assertEquals(ActionFactory.TYPE_VIRTUALIZATION_START,
                     VirtualizationActionCommand.lookupActionType("stopped", "start"));
        assertNull(VirtualizationActionCommand.lookupActionType("stopped", "stop"));
        assertEquals(ActionFactory.TYPE_VIRTUALIZATION_START,
                     VirtualizationActionCommand.lookupActionType("crashed", "start"));
        assertEquals(ActionFactory.TYPE_VIRTUALIZATION_RESUME,
                     VirtualizationActionCommand.lookupActionType("paused", "start"));
        assertEquals(ActionFactory.TYPE_VIRTUALIZATION_REBOOT,
                     VirtualizationActionCommand.lookupActionType("running", "restart"));
        assertEquals(ActionFactory.TYPE_VIRTUALIZATION_SUSPEND,
                VirtualizationActionCommand.lookupActionType("running", "suspend"));
    }

    public void testScheduleCommandSimple() throws Exception {

        this.user.addRole(RoleFactory.ORG_ADMIN);

        Server server = ServerFactoryTest.createTestServer(this.user, true,
                            ServerConstants.getServerGroupTypeEnterpriseEntitled());

        VirtualizationActionCommand testCommand =
            new VirtualizationActionCommand(this.user,
                                            new Date(),
                                            VirtualizationActionCommand.lookupActionType(
                                              "stopped", "start"),
                                            server,
                                            "AAAAAAAAAAAAAAAA",
                                            null);

        testCommand.store();
    }
}
