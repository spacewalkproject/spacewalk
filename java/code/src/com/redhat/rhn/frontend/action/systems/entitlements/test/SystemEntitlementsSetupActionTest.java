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

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.EntitlementServerGroup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.ServerGroupFactory;
import com.redhat.rhn.domain.server.ServerGroupType;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.server.test.ServerGroupTest;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.action.systems.entitlements.SystemEntitlementsSetupAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Iterator;

/**
 * 
 * SystemEntitlementsSetupActionToast
 * @version $Rev$
 */
public class SystemEntitlementsSetupActionTest extends RhnMockStrutsTestCase {
    /**
     * {@inheritDoc}
     */
    public void setUp() throws Exception {
        super.setUp();
        
        setRequestPathInfo("/systems/SystemEntitlements");
        UserTestUtils.addManagement(user.getOrg());
        UserTestUtils.addMonitoring(user.getOrg());
    }
    /**
     * 
     * @throws Exception exception if test fails
     */
    public void tesUpdateEntitledUser() throws Exception {
        //create a user with Update  Only-> Org entitlement
        ServerFactoryTest.createTestServer(user);
        executeTests();
        assertNotNull(request.getAttribute(
                SystemEntitlementsSetupAction.SHOW_UPDATE_ASPECTS));        
        assertNull(request.getAttribute(SystemEntitlementsSetupAction.SHOW_NO_SYSTEMS));
        assertNotNull(request.getAttribute(SystemEntitlementsSetupAction.SHOW_COMMANDS));
        assertNull(request.getAttribute(SystemEntitlementsSetupAction.SHOW_MONITORING));
        
        assertNull(request.getAttribute(SystemEntitlementsSetupAction.SHOW_ADDON_ASPECTS));
        assertNull(request.getAttribute(SystemEntitlementsSetupAction.ADDON_ENTITLEMENTS));
        assertNull(request.getAttribute(
                            SystemEntitlementsSetupAction.SHOW_MANAGEMENT_ASPECTS));
        assertNotNull(request.getAttribute(
                             SystemEntitlementsSetupAction.PROVISION_COUNTS_MESSAGE));
        assertNotNull(request.getAttribute(
                        SystemEntitlementsSetupAction.UPDATE_COUNTS_MESSAGE));
        assertNotNull(request.getAttribute(
                SystemEntitlementsSetupAction.MANAGEMENT_COUNTS_MESSAGE));
        testZeroSlots(SystemEntitlementsSetupAction.SHOW_UPDATE_ASPECTS,
                ServerConstants.getServerGroupTypeUpdateEntitled());        
    }
    
    public void testUpdatePlusVirt() throws Exception {
        
        ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeUpdateEntitled());
        
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
        user.getOrg().getEntitlements().add(OrgFactory.getEntitlementEnterprise());
        Server server = ServerFactoryTest.createTestServer(user, true,
                        ServerConstants.getServerGroupTypeEnterpriseEntitled());

        UserFactory.save(user);
        OrgFactory.save(user.getOrg());        
        
        executeTests();
        assertNotNull(request.getAttribute(
                                SystemEntitlementsSetupAction.SHOW_MANAGEMENT_ASPECTS));
        assertNotNull(request.getAttribute(
                SystemEntitlementsSetupAction.MANAGEMENT_COUNTS_MESSAGE));
        
        assertNotNull(request.getAttribute(
                SystemEntitlementsSetupAction.SHOW_ADDON_ASPECTS));
        assertNotNull(request.getAttribute(
                SystemEntitlementsSetupAction.ADDON_ENTITLEMENTS));            

        assertNotNull(request.getAttribute(SystemEntitlementsSetupAction.SHOW_COMMANDS));

        //add provisioning and test again...
        user.getOrg().getEntitlements().add(OrgFactory.getEntitlementProvisioning());
        
        ServerGroup provisioning = ServerGroupTest.createTestServerGroup(user.getOrg(),
                 ServerConstants.getServerGroupTypeProvisioningEntitled());
         SystemManager.addServerToServerGroup(server, provisioning);
         UserFactory.save(user);
         OrgFactory.save(user.getOrg());         
         ServerFactory.save(server);
         executeTests();
         assertNotNull(request.getAttribute(
                             SystemEntitlementsSetupAction.SHOW_ADDON_ASPECTS));
         assertNotNull(request.getAttribute(
                             SystemEntitlementsSetupAction.ADDON_ENTITLEMENTS));

         testZeroSlots(SystemEntitlementsSetupAction.SHOW_MANAGEMENT_ASPECTS,
                         ServerConstants.getServerGroupTypeEnterpriseEntitled());         
    }
    /**
     * Tests the case where there are zero slots available  
     * for a give servergroup type. In ttaht case we want the
     * button set by the param name hidden. 
     * @param server server object
     * @param buttonName name of the button to be hidden
     * @param testGroupType the group type who's available subscriptions = 0
     */
    private void testZeroSlots(String buttonName, 
                                ServerGroupType testGroupType) throws Exception {
        
        // Testing to make sure the Management Entitled Button does not show up
         // if the number of subscription slots = 0
        EntitlementServerGroup group = ServerGroupFactory.lookupEntitled
                                                (user.getOrg(), testGroupType);
        group.setMaxMembers(group.getCurrentMembers());
        ServerGroupFactory.save(group);
        request.removeAttribute(buttonName);
        executeTests();
        assertNull(request.getAttribute(buttonName));
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
        
    private void setupMonitoring() {
        user.addRole(RoleFactory.MONITORING_ADMIN);
        user.addRole(RoleFactory.ORG_ADMIN);
        user.getOrg().getEntitlements().add(
            OrgFactory.lookupEntitlementByLabel("rhn_monitor"));
        Config.get().setBoolean(ConfigDefaults.WEB_IS_MONITORING_BACKEND, "1");
    }
    
   
    /**
     * 
     * @throws Exception throws exception if createServerTest fails
     */
    public void testMonitoring() throws Exception {
        Server server = ServerFactoryTest.createTestServer(user);
        final ServerGroup provisioning = ServerGroupTest.createTestServerGroup(
                                user.getOrg(), 
                                ServerConstants.getServerGroupTypeProvisioningEntitled());
        ServerFactory.save(server);
        
        SystemManager.addServerToServerGroup(server, provisioning);        
        setupMonitoring();
        executeTests();
        assertNotNull(request.getAttribute(
            SystemEntitlementsSetupAction.SHOW_MONITORING));
        assertNotNull(request.getAttribute(
            SystemEntitlementsSetupAction.MONITORING_COUNTS_MESSAGE));            
    }

    /**
     * 
     * @throws Exception exception if test fails
     */
    public void testEntitlementCountMessage() throws Exception {
        user.getOrg().getEntitlements().add(OrgFactory.getEntitlementEnterprise());
        
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
        
        assertTrue(message.indexOf(String.valueOf(eGrp.getMaxMembers())) > 0);
        assertTrue(message.indexOf(String.valueOf(eGrp.getCurrentMembers())) > 0);
    }
}
