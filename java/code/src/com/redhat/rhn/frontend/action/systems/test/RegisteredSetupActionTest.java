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
package com.redhat.rhn.frontend.action.systems.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.server.test.ServerGroupTest;
import com.redhat.rhn.frontend.action.systems.RegisteredSetupAction;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

/**
 * RegisteredSetupActionTest
 * @version $Rev$
 */
public class RegisteredSetupActionTest extends RhnMockStrutsTestCase {

    public void setUp() throws Exception {
        super.setUp();
        setRequestPathInfo("/systems/Registered");
        user.getOrg().getEntitlements().add(OrgFactory.getEntitlementEnterprise());
        user.getOrg().addRole(RoleFactory.CHANNEL_ADMIN);
    }

    public void testExecute() throws Exception {
        Server server = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        ServerGroup group = ServerGroupTest
                .createTestServerGroup(user.getOrg(), null);
        SystemManager.addServerToServerGroup(server, group);
        ServerFactory.save(server);

        for (int j = 0; j < RegisteredSetupAction.OPTIONS.length; ++j) {
            request.addParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
            request.addParameter("threshold", RegisteredSetupAction.OPTIONS[j]);

            actionPerform();
            DataResult dr = (DataResult) request.getAttribute("pageList");
            assertNotNull(dr);
            assertFalse(dr.isEmpty());
        }
    }
}
