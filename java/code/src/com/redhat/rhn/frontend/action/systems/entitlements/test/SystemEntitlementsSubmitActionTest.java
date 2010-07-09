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
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.ServerGroupTestUtils;
import com.redhat.rhn.testing.ServerTestUtils;
import com.redhat.rhn.testing.TestUtils;

import java.util.Iterator;

/**
 *
 * SystemEntitlementSubmitActionToast
 * @version $Rev$
 */
public class SystemEntitlementsSubmitActionTest extends RhnMockStrutsTestCase {

    private static final String UPDATE =
                                    "system_entitlements.setToUpdateEntitled";
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

        if (EntitlementManager.UPDATE.equals(ent) &&
                !orgHasGroupType(ServerConstants.
                                    getServerGroupTypeUpdateEntitled())) {
            // add type update to the server now
            ServerGroupTest.createTestServerGroup(
                              user.getOrg(),
                              ServerConstants.getServerGroupTypeUpdateEntitled());
        }

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


    /**
     * @throws Exception on server init failure
     */
    public void testUpdateWithNoUpdatableGroups() throws Exception {


        if (orgHasGroupType(ServerConstants.
                                getServerGroupTypeUpdateEntitled())) {

            // well if its the satellite then our tests will
            // depend on what servergrup types were listed in the
            // satellite certificate.
            // so this test will make sense only if the
            // satellite does NOT have Update Entitled Cert..

            return;
        }

        Server server = ServerFactoryTest.createTestServer(user, true,
                            ServerConstants.getServerGroupTypeEnterpriseEntitled());

        assertFalse(user.getOrg().getEntitledServerGroups().
                contains(ServerConstants.getServerGroupTypeUpdateEntitled()));
        dispatch(SystemEntitlementsSubmitAction.KEY_UPDATE_ENTITLED, server);

        /*
         * this should fail because the org only has groups of type
         * Management .. No groups of type Update.
         */
        assertFalse(SystemManager.hasEntitlement(server.getId(),
                                                    EntitlementManager.UPDATE));
        verifyActionMessage(failure(UPDATE));

    }

    private boolean orgHasGroupType(ServerGroupType type) {
        return findGroupOfType(type) != null;
    }

    private EntitlementServerGroup  findGroupOfType(ServerGroupType type) {
        for (Iterator itr = user.getOrg().getEntitledServerGroups().iterator();
                                                        itr.hasNext();) {
            EntitlementServerGroup grp = (EntitlementServerGroup) itr.next();
            if (type.equals(grp.getGroupType())) {
                return grp;
            }
        }
        return null;
    }


    /**
     * @throws Exception on server init failure
     */
    public void testManagementWithNoManagementGroups() throws Exception {
        if (orgHasGroupType(ServerConstants.
                        getServerGroupTypeEnterpriseEntitled())) {
            // well if its the satellite then our tests will
            // depend on what servergrup types were listed in the
            // satellite certificate.
            // so this test will make sense only if the
            // satellite does NOT have Management Entitled Cert..
            return;
        }

        Server server = ServerFactoryTest.createTestServer(user, true,
                            ServerConstants.getServerGroupTypeUpdateEntitled());

        dispatch(SystemEntitlementsSubmitAction.KEY_MANAGEMENT_ENTITLED, server);

        /*
         * this should fail because the org only has groups of type
         * Management .. No groups of type Update.
         */
        assertFalse(SystemManager.hasEntitlement(server.getId(),
                                                    EntitlementManager.MANAGEMENT));
        verifyActionMessage(failure(MANAGEMENT));

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

        Server server = ServerFactoryTest.createTestServer(user, true,
                        ServerConstants.getServerGroupTypeUpdateEntitled());

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
    public void testUpdateOnGroupsWithExhaustedSlots() throws Exception {
        testExhaustedSlots(ServerConstants.getServerGroupTypeEnterpriseEntitled(),
                            ServerConstants.getServerGroupTypeUpdateEntitled(),
                            SystemEntitlementsSubmitAction.KEY_UPDATE_ENTITLED,
                            EntitlementManager.UPDATE,
                            failure(UPDATE));
    }

    /**
     *
     * @throws Exception on server init failure
     */
    public void testManagementOnGroupsWithExhaustedSlots() throws Exception {
        testExhaustedSlots(ServerConstants.getServerGroupTypeUpdateEntitled(),
                            ServerConstants.getServerGroupTypeEnterpriseEntitled(),
                            SystemEntitlementsSubmitAction.KEY_MANAGEMENT_ENTITLED,
                            EntitlementManager.MANAGEMENT,
                            failure(MANAGEMENT));
    }

    /**
     *
     * @throws Exception on server init failure
     */
    private void testExhaustedSlots(ServerGroupType initType,
                                        ServerGroupType addOnType,
                                        String dispatchKey,
                                        Entitlement ent,
                                        String failMsg
                                        ) throws Exception {
        final Server server1 = ServerFactoryTest.createTestServer(user, true, initType);
        final Server server2 = ServerFactoryTest.createTestServer(user, true, initType);

        // add type update to the server now
        EntitlementServerGroup addOn = ServerGroupTestUtils.createEntitled(user.getOrg(),
                                                                          addOnType);
        addOn.setMaxMembers(new Long(addOn.getCurrentMembers().longValue() + 1));
        TestUtils.saveAndFlush(addOn);

        String [] selectedItems = {server1.getId().toString(),
                                                server2.getId().toString()};

        addRequestParameter("items_on_page", (String)null);
        addRequestParameter("items_selected", selectedItems);
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        addDispatchCall(dispatchKey);
        actionPerform();

        /*
         * this should fail on server2 even though the org has groups of both types
         * because the org becasue Max Members = 1 but
         *  we are trying to add 2 systems to updategroup.
         */
        verifyActionMessage(failMsg);

        boolean a = SystemManager.hasEntitlement(server1.getId(), ent);

        boolean b = SystemManager.hasEntitlement(server2.getId(), ent);

        // Either the the first server1 got updated successfully &
        // second one didn't
        // or vice versa
        assertTrue((a && !b)  || (!a && b));
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
    public void testAddProvisioningForUpdate() throws Exception {
        testAddOnForUpdate("provisioning_entitled",
                            "provisioning",
                            EntitlementManager.PROVISIONING,
                           ServerConstants.getServerGroupTypeProvisioningEntitled());
    }

    /**
     *
     * @throws Exception on server init failure
     */
    public void testAddVirtForManagement() throws Exception {
        testAddOnVirt(EntitlementManager.VIRTUALIZATION_ENTITLED,
                EntitlementManager.VIRTUALIZATION.getLabel(),
                EntitlementManager.VIRTUALIZATION,
                ServerConstants.getServerGroupTypeVirtualizationEntitled());
    }

    /**
     *
     * @throws Exception on server init failure
     */
    public void testAddVirtPlatformForManagement() throws Exception {
        testAddOnVirt(EntitlementManager.VIRTUALIZATION_PLATFORM_ENTITLED,
                EntitlementManager.VIRTUALIZATION_PLATFORM.getLabel(),
                EntitlementManager.VIRTUALIZATION_PLATFORM,
                ServerConstants.getServerGroupTypeVirtualizationPlatformEntitled());
    }

    /**
     *
     * @throws Exception on server init failure
     */
    public void testAddProvisioningForManagement() throws Exception {
        testAddOnForManagement("provisioning_entitled",
                "provisioning",
                EntitlementManager.PROVISIONING,
               ServerConstants.getServerGroupTypeProvisioningEntitled());
    }

    /**
     *
     * @throws Exception on server init failure
     */
    public void testRemoveProvisioningForManagement() throws Exception {

        testRemoveAddOnForManagement("provisioning_entitled",
                "provisioning",
                EntitlementManager.PROVISIONING,
               ServerConstants.getServerGroupTypeProvisioningEntitled());
    }


    /**
     *
     * @throws Exception on server init failure
     */
    public void testAddMonitoringForUpdate() throws Exception {
        testAddOnForUpdate("monitoring_entitled",
            "monitoring",
            EntitlementManager.MONITORING,
            ServerConstants.getServerGroupTypeMonitoringEntitled());
    }

    /**
     *
     * @throws Exception on server init failure
     */
    public void testAddMonitoringForManagement() throws Exception {
        testAddOnForManagement("monitoring_entitled",
            "monitoring",
            EntitlementManager.MONITORING,
            ServerConstants.getServerGroupTypeMonitoringEntitled());
    }

    /**
     *
     * @throws Exception on server init failure
     */
    public void testRemoveMonitoringForManagement() throws Exception {
        testRemoveAddOnForManagement("monitoring_entitled",
                "monitoring",
                EntitlementManager.MONITORING,
               ServerConstants.getServerGroupTypeMonitoringEntitled());

    }

    /**
     *
     * @throws Exception on server init failure
     */
    private void testAddOnForUpdate(String selectKey,
                                    String msgSubKey,
                                    Entitlement ent,
                                    ServerGroupType groupType
                                    ) throws Exception {
        Server server = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeUpdateEntitled());
        ServerGroupTest.createTestServerGroup(user.getOrg(), groupType);
        addRequestParameter("addOnEntitlement", selectKey);
        dispatch(SystemEntitlementsSubmitAction.KEY_ADD_ENTITLED, server);
        verifyActionMessage("system_entitlements." + msgSubKey + ".noManagement");

        assertFalse(SystemManager.hasEntitlement(server.getId(), ent));
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
                                            String msgSubKey,
                                            Entitlement ent,
                                            ServerGroupType groupType
                                            )  throws Exception {

        Server server = null;
        if (EntitlementManager.VIRTUALIZATION_PLATFORM.equals(ent)) {
            server = ServerTestUtils.createVirtPlatformHostWithGuest(user);
        }
        else {
            server = ServerTestUtils.createVirtHostWithGuests(user, 1);
        }


        SystemManager.removeServerEntitlement(server.getId(),
                EntitlementManager.VIRTUALIZATION);
        SystemManager.removeServerEntitlement(server.getId(),
                EntitlementManager.VIRTUALIZATION_PLATFORM);
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
