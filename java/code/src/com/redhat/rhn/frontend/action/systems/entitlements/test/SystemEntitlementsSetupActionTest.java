/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.systems.entitlements.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.server.EntitlementServerGroup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.action.systems.entitlements.SystemEntitlementsSetupAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Iterator;

/**
 * SystemEntitlementsSetupActionTest
 */
public class SystemEntitlementsSetupActionTest extends RhnMockStrutsTestCase {
    /**
     * {@inheritDoc}
     */
    public void setUp() throws Exception {
        super.setUp();

        setRequestPathInfo("/systems/SystemEntitlements");
        UserTestUtils.addManagement(user.getOrg());
        UserTestUtils.addVirtualization(user.getOrg());
    }
    /**
     *
     * @throws Exception exception if test fails
     */
    public void tesUpdateEntitledUser() throws Exception {
        ServerFactoryTest.createTestServer(user);
        executeTests();

        assertNull(request.getAttribute(SystemEntitlementsSetupAction.SHOW_NO_SYSTEMS));
        assertNotNull(request.getAttribute(SystemEntitlementsSetupAction.SHOW_COMMANDS));

        assertNull(request.getAttribute(SystemEntitlementsSetupAction.ADDON_ENTITLEMENTS));
        assertNotNull(request.getAttribute(
                SystemEntitlementsSetupAction.MANAGEMENT_COUNTS_MESSAGE));
    }

    public void testAddVirtualization() throws Exception {
        ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());

        UserTestUtils.addVirtualization(user.getOrg());
        executeTests();
        assertNotNull(request.getAttribute(
                SystemEntitlementsSetupAction.ADDON_ENTITLEMENTS));
        assertNotNull(request.getAttribute(
                SystemEntitlementsSetupAction.VIRTUALIZATION_COUNTS_MESSAGE));
    }

    /**
     *
     * @throws Exception exception if test fails
     */
    public void testManagementEntitledUser() throws Exception {
        Server server = ServerFactoryTest.createTestServer(user, true,
                        ServerConstants.getServerGroupTypeEnterpriseEntitled());

        UserFactory.save(user);
        OrgFactory.save(user.getOrg());


        executeTests();
        assertNotNull(request.getAttribute(
                            SystemEntitlementsSetupAction.ADDON_ENTITLEMENTS));
    }

    /**
     *
     *
     */
    public void testNoEntitlements() {
        actionPerform();
        DataResult dr = (DataResult) request.getAttribute(RequestContext.PAGE_LIST);
        assertTrue(dr.size() == 0);
        assertNull(request.getAttribute(SystemEntitlementsSetupAction.SHOW_COMMANDS));
        assertNotNull(request.getAttribute(SystemEntitlementsSetupAction.SHOW_NO_SYSTEMS));
    }

    private void executeTests() {
        actionPerform();
        DataResult dr = (DataResult) request.getAttribute(RequestContext.PAGE_LIST);
        assertNotNull(dr);
        assertTrue(dr.size() > 0);
    }

    /**
     *
     * @throws Exception exception if test fails
     */
    public void testEntitlementCountMessage() throws Exception {
        Server server = ServerFactoryTest.createTestServer(user, true,
                        ServerConstants.getServerGroupTypeEnterpriseEntitled());
        assertTrue(server.getEntitlements().size() > 0);

        EntitlementServerGroup eGrp = null;
        for (Iterator itr = server.getEntitledGroups().iterator(); itr.hasNext();) {
            EntitlementServerGroup sg = (EntitlementServerGroup)itr.next();
            if (sg.getGroupType().equals(
                    ServerConstants.getServerGroupTypeEnterpriseEntitled())) {
                eGrp = sg;
                break;
            }
        }

        executeTests();
        String message = (String)request.getAttribute(
                SystemEntitlementsSetupAction.MANAGEMENT_COUNTS_MESSAGE);

        assertTrue(message.contains(String.valueOf(eGrp.getCurrentMembers())));
    }
}
