/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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

import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.server.EntitlementServerGroup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.ServerGroupType;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.server.test.ServerGroupTest;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.action.systems.entitlements.SystemEntitlementsSubmitAction;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.testing.RhnPostMockStrutsTestCase;
import com.redhat.rhn.testing.ServerTestUtils;

import java.util.Date;
import java.util.Iterator;

/**
 * SystemEntitlementsSubmitActionTest
 */
public class SystemEntitlementsSubmitActionTest extends RhnPostMockStrutsTestCase {

    private static final String MANAGEMENT =
                                   "system_entitlements.setToManagementEntitled";
    private static final String UNENTITLED =
                                    "system_entitlements.unentitle";

    /**
     * {@inheritDoc}
     */
    public void setUp() throws Exception {
        super.setUp();
        setRequestPathInfo("/systems/SystemEntitlementsSubmit");
    }

    /**
     * @param server
     */
    private void dispatch(String key, Server server) {
        addRequestParameter("items_on_page", (String)null);
        addSelectedItem(server.getId());
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        addDispatchCall(key);
        actionPerform();
    }

    private String success(String str) {
        return str + ".success";
    }

    private String failure(String str) {
        return str + ".failure";
    }

    /**
     * @throws Exception on server init failure
     */
    public void testManagementWithUnentitledSystems() throws Exception {
        testWithUnentitledSystem(EntitlementManager.MANAGEMENT,
                                   SystemEntitlementsSubmitAction.KEY_MANAGEMENT_ENTITLED,
                                   success(MANAGEMENT)
                                   );
    }

    /**
     * @throws Exception on server init failure
     */
    private void testWithUnentitledSystem(Entitlement ent,
                                            String dispatchKey,
                                            String msg) throws Exception {

        Server server = ServerFactoryTest.createTestServer(user, true,
                            ServerConstants.getServerGroupTypeEnterpriseEntitled());

        ServerFactory.save(server);
        OrgFactory.save(user.getOrg());
        UserFactory.save(user);
        SystemManager.removeAllServerEntitlements(server.getId());
        assertFalse(SystemManager.hasEntitlement(server.getId(), ent));

        /*
        * this should Succeed because the org only has groups of both types
        * Management & Update and both have available subscriptions > 0..
        */
        dispatch(dispatchKey, server);
        assertTrue(SystemManager.hasEntitlement(server.getId(), ent));
        verifyActionMessage(msg);

    }

    private boolean orgHasGroupType(ServerGroupType type) {
        return findGroupOfType(type) != null;
    }

    private EntitlementServerGroup  findGroupOfType(ServerGroupType type) {
        for (Iterator<EntitlementServerGroup> itr = user.getOrg().getEntitledServerGroups()
                .iterator(); itr.hasNext();) {
            EntitlementServerGroup grp = itr.next();
            if (type.equals(grp.getGroupType())) {
                return grp;
            }
        }
        return null;
    }

    /**
     * @throws Exception on server init failure
     */
    public void testManagementOnly() throws Exception {
        Server server = ServerFactoryTest.createTestServer(user, true,
                            ServerConstants.getServerGroupTypeEnterpriseEntitled());
        /*
         * this should Succeed because the org only has groups type = Update
         *  that has available subscriptions > 0..
         */
        dispatch(SystemEntitlementsSubmitAction.KEY_MANAGEMENT_ENTITLED, server);
        assertTrue(SystemManager.hasEntitlement(server.getId(),
                                                    EntitlementManager.MANAGEMENT));
        verifyActionMessage(success(MANAGEMENT));
    }

    /**
     *
     * @throws Exception on server init failure
     */
    public void testUpdateToManagement() throws Exception {

        Server server = ServerFactoryTest.createUnentitledTestServer(user, true,
                ServerFactoryTest.TYPE_SERVER_NORMAL, new Date());

        if (!orgHasGroupType(ServerConstants.
                getServerGroupTypeEnterpriseEntitled())) {
            ServerGroupTest.createTestServerGroup(
                       user.getOrg(),
                       ServerConstants.getServerGroupTypeEnterpriseEntitled());
        }

         /*
          * this should Succeed because the org only has groups of both types
          * Management & Update and both have available subscriptions > 0..
          */
         dispatch(SystemEntitlementsSubmitAction.KEY_MANAGEMENT_ENTITLED, server);
         assertTrue(SystemManager.hasEntitlement(server.getId(),
                                                     EntitlementManager.MANAGEMENT));
         verifyActionMessage(success(MANAGEMENT));
    }

    /**
     *
     * @throws Exception on server init failure
     */
    public void testUnentitleForManagement() throws Exception {
        Server server1 = ServerFactoryTest.createTestServer(user, true,
                            ServerConstants.getServerGroupTypeEnterpriseEntitled());

        assertTrue(SystemManager.hasEntitlement(server1.getId(),
                                                  EntitlementManager.MANAGEMENT));



        dispatch(SystemEntitlementsSubmitAction.KEY_UNENTITLED, server1);
        verifyActionMessage(success(UNENTITLED));
        assertFalse(SystemManager.hasEntitlement(server1.getId(),
                                                EntitlementManager.MANAGEMENT));
    }

    /**
     *
     * @throws Exception on server init failure
     */
    public void testAddVirtForManagement() throws Exception {
        testAddOnVirt(EntitlementManager.VIRTUALIZATION_ENTITLED,
                EntitlementManager.VIRTUALIZATION,
                ServerConstants.getServerGroupTypeVirtualizationEntitled());
    }

    /**
     *
     * @throws Exception on server init failure
     */
    private void testAddOnForManagement(String selectKey,
                                            String msgSubKey,
                                            Entitlement ent,
                                            ServerGroupType groupType
                                            )  throws Exception {
        Server server = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        ServerGroupTest.createTestServerGroup(user.getOrg(), groupType);

        addRequestParameter("addOnEntitlement", selectKey);
        dispatch(SystemEntitlementsSubmitAction.KEY_ADD_ENTITLED, server);
        verifyActionMessage("system_entitlements." + msgSubKey + ".success");
        assertTrue(SystemManager.hasEntitlement(server.getId(), ent));
    }

    /**
     *
     * @throws Exception on server init failure
     */
    private void testAddOnVirt(String selectKey,
                                            Entitlement ent,
                                            ServerGroupType groupType
                                            )  throws Exception {

        Server server = ServerTestUtils.createVirtHostWithGuests(user, 1);

        SystemManager.removeServerEntitlement(server.getId(),
                EntitlementManager.VIRTUALIZATION);
        ServerGroupTest.createTestServerGroup(user.getOrg(),
                groupType);

        addRequestParameter("addOnEntitlement", selectKey);
        dispatch(SystemEntitlementsSubmitAction.KEY_ADD_ENTITLED, server);

        String[] messageNames = {"system_entitlements." +
                ent.getLabel() + ".success",
                "system_entitlements.virtualization.success_note"};

        verifyActionMessages(messageNames);
        assertTrue("Doesn't have: " + ent,
                SystemManager.hasEntitlement(server.getId(), ent));

    }

    /**
     *
     * @throws Exception on server init failure
     */
    private Server testRemoveAddOnForManagement(String selectKey,
                                                String msgSubKey,
                                                Entitlement ent,
                                                ServerGroupType groupType
                                                ) throws Exception {
        Server server = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        ServerGroupTest.createTestServerGroup(user.getOrg(), groupType);

        assertTrue(SystemManager.hasEntitlement(server.getId(),
                                        EntitlementManager.MANAGEMENT));
        SystemManager.entitleServer(server, ent);

        addRequestParameter("addOnEntitlement", selectKey);
        dispatch(SystemEntitlementsSubmitAction.KEY_REMOVE_ENTITLED, server);
        verifyActionMessage("system_entitlements." + msgSubKey + ".removed.success");
        assertFalse(SystemManager.hasEntitlement(server.getId(), ent));
        return server;
    }
}
