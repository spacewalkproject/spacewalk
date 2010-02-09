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
package com.redhat.rhn.frontend.xmlrpc.system.test;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.xmlrpc.ServerGroupAccessChangeException;
import com.redhat.rhn.frontend.xmlrpc.ServerNotInGroupException;
import com.redhat.rhn.frontend.xmlrpc.systemgroup.ServerGroupHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.frontend.xmlrpc.test.XmlRpcTestUtils;
import com.redhat.rhn.manager.system.ServerGroupManager;
import com.redhat.rhn.testing.ServerGroupTestUtils;
import com.redhat.rhn.testing.ServerTestUtils;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.List;


/**
 * ServerGroupHandlerTest
 * @version $Rev$
 */
public class ServerGroupHandlerTest extends BaseHandlerTestCase {
    private ServerGroupHandler handler = new ServerGroupHandler();
    private ServerGroupManager manager = ServerGroupManager.getInstance();
    private static final String NAME = "HAHAHA" + TestUtils.randomString();
    private static final String DESCRIPTION =  TestUtils.randomString();

    public void testCreate() {
        ServerGroup group = handler.create(adminKey, NAME, DESCRIPTION);
        assertNotNull(manager.lookup(NAME, admin));
        
        try {
            handler.create(adminKey, NAME, DESCRIPTION);
            fail("Duplicate key didn't raise an exception");
        }
        catch (Exception e) {
            //duplicate check successful.
        }
        regular.removeRole(RoleFactory.SYSTEM_GROUP_ADMIN);
        try {
           
            handler.create(regularKey, NAME + "F", DESCRIPTION + "F");
            fail("Regular user allowed to create server groups");
        }
        catch (Exception e) {
            //Cool only sys admins can create.
        }
    }
    
    public void testUpdate() {

        ServerGroup group = handler.create(adminKey, NAME, DESCRIPTION);
        assertNotNull(manager.lookup(NAME, admin));
        regular.addRole(RoleFactory.SYSTEM_GROUP_ADMIN);
        String newDescription = DESCRIPTION + TestUtils.randomString();
        try {
            handler.update(regularKey, NAME, newDescription);
            fail("Can't access .. Should throw access / permission exception");
        }
        catch (Exception e) {
            //access check successful.
        }
        group = handler.update(adminKey, NAME, newDescription);
        assertEquals(group.getDescription(), newDescription);
    }
    
    public void testListAdministrators() {
        regular.addRole(RoleFactory.SYSTEM_GROUP_ADMIN);
        ServerGroup group = handler.create(regularKey, NAME, DESCRIPTION);
        List admins = handler.listAdministrators(regularKey, group.getName());
        assertTrue(admins.contains(regular));
        assertTrue(admins.contains(admin));
        //now test on permissions
        regular.removeRole(RoleFactory.SYSTEM_GROUP_ADMIN);
        try {
            admins = handler.listAdministrators(regularKey, group.getName());
            fail("Should throw access / permission exception" +
                                " for regular is not a sys admin");
        }
        catch (Exception e) {
          //access check successful.
        }
    }
    
    public void testAddRemoveAdmins() {
        ServerGroup group = handler.create(adminKey, NAME, DESCRIPTION);
        assertNotNull(manager.lookup(NAME, admin));
        User newbie = UserTestUtils.createUser("Hahaha", admin.getOrg().getId());
        
        List logins = new ArrayList();
        logins.add(newbie.getLogin());
        

        try {
            handler.addOrRemoveAdmins(regularKey, group.getName(), logins, true);
            fail("Regular user allowed to create server groups");
        }
        catch (Exception e) {
            //Cool only sys admins can create.
        }        

        handler.addOrRemoveAdmins(adminKey, group.getName(),        
                Arrays.asList(new String []{regular.getLogin()}), true);

        regular.addRole(RoleFactory.SYSTEM_GROUP_ADMIN);
        handler.addOrRemoveAdmins(regularKey, group.getName(), logins, true);
        List admins = handler.listAdministrators(regularKey, group.getName());
        assertTrue(admins.contains(newbie));
        
        handler.addOrRemoveAdmins(regularKey, group.getName(), logins, false);
        assertFalse(manager.canAccess(newbie, group));
        admins = handler.listAdministrators(adminKey, group.getName());        
        assertFalse(admins.contains(newbie));

        // verify that neither an org or sat admin may have their
        // group access changed
        User orgAdmin = UserTestUtils.findNewUser("orgAdmin", "newOrg", true);
        assertTrue(orgAdmin.hasRole(RoleFactory.ORG_ADMIN));
        assertFalse(orgAdmin.hasRole(RoleFactory.SAT_ADMIN));
        UserFactory.save(orgAdmin);

        addOrRemoveAnAdmin(group, orgAdmin, true);
        addOrRemoveAnAdmin(group, orgAdmin, false);

        User satAdmin = UserTestUtils.findNewUser("satAdmin", "newOrg", false);
        satAdmin.addRole(RoleFactory.SAT_ADMIN);
        assertTrue(satAdmin.hasRole(RoleFactory.SAT_ADMIN));
        assertFalse(satAdmin.hasRole(RoleFactory.ORG_ADMIN));

        addOrRemoveAnAdmin(group, satAdmin, true);
        addOrRemoveAnAdmin(group, satAdmin, false);
    }

    private void addOrRemoveAnAdmin(ServerGroup group, User user, boolean add) {
        List<String> logins = new ArrayList<String>();
        logins.add(user.getLogin());

        try {
            handler.addOrRemoveAdmins(adminKey, group.getName(), logins, false);
            if (user.hasRole(RoleFactory.SAT_ADMIN)) {
                fail("Allowed changing admin access for a satellite admin.  add=" + add);
            }
            else if (user.hasRole(RoleFactory.ORG_ADMIN)) {
                fail("Allowed changing admin access for an org admin.  add=" + add);
            }
        }
        catch (ServerGroupAccessChangeException e) {
            //Cool cannot change access permissions for an sat/org admin.
        }
    }
    
    public void testListGroupsWithNoAssociatedAdmins() {
        ServerGroup group = handler.create(adminKey, NAME, DESCRIPTION);
        ServerGroup group1 = handler.create(adminKey, NAME + "1",
                                                    DESCRIPTION + "1");
        ServerGroup group2 = handler.create(adminKey, NAME + "2",
                                                    DESCRIPTION + "2");
        List groups = handler.listGroupsWithNoAssociatedAdmins(adminKey);
        assertTrue(groups.contains(group));
        assertTrue(groups.contains(group1));
        assertTrue(groups.contains(group2));

        List logins = new ArrayList();
        logins.add(regular.getLogin());
        handler.addOrRemoveAdmins(adminKey, group1.getName(), logins, true);
        assertTrue(manager.canAccess(regular, group1));
        groups = handler.listGroupsWithNoAssociatedAdmins(adminKey);
        assertFalse(groups.contains(group1));
        
        assertTrue(groups.contains(group));
        assertTrue(groups.contains(group2));
    }
    
    public void testDelete() {
        ServerGroup group = handler.create(adminKey, NAME, DESCRIPTION);
        handler.delete(adminKey, NAME);
        try {
            manager.lookup(NAME, admin);
            fail("Should throw a lookup exception");
        }
        catch (Exception e) {
            //exception succesfully thrown.
        }
    }

    public void testAddRemoveSystems() throws Exception {
        ServerGroup group = handler.create(adminKey, NAME, DESCRIPTION);
        assertNotNull(manager.lookup(NAME, admin));

        User unpriv = UserTestUtils.createUser("Unpriv", admin.getOrg().getId());
        String unprivKey = XmlRpcTestUtils.getSessionKey(unpriv);
        List logins = new ArrayList();
        logins.add(regular.getLogin());
        logins.add(unpriv.getLogin());
        
        handler.addOrRemoveAdmins(adminKey, group.getName(), logins, true);
        regular.addRole(RoleFactory.SYSTEM_GROUP_ADMIN);
        
        Server server1 = ServerFactoryTest.createTestServer(regular, true);
        Server server2 = ServerFactoryTest.createTestServer(regular, true);
        Server server3 = ServerFactoryTest.createTestServer(regular, true);

        handler.addOrRemoveSystems(regularKey, group.getName(),        
                Arrays.asList(new Integer []{
                            new Integer(server3.getId().intValue())}), new Boolean(true));

        List systems = new ArrayList();
        systems.add(server1.getId());
        systems.add(server2.getId());
        systems.add(server3.getId());
        handler.addOrRemoveSystems(regularKey, group.getName(), systems, new Boolean(true));
        
        
        List actual = handler.listSystems(unprivKey, group.getName());
        assertTrue(actual.contains(server1));
        
        handler.addOrRemoveSystems(regularKey, group.getName(), systems, 
                new Boolean(false));
        
        actual = handler.listSystems(regularKey, group.getName());        
        assertFalse(actual.contains(server1));
    }    

    public void testRemoveNonExistentServer() throws Exception {
        ServerGroup group = handler.create(adminKey, NAME, DESCRIPTION);
        List<Long> systems = new ArrayList<Long>();
        Server server1 = ServerFactoryTest.createTestServer(admin, true);
        systems.add(server1.getId());
        try {
            handler.addOrRemoveSystems(adminKey, group.getName(), systems, 
                    new Boolean(false));
            fail();
        }
        catch (ServerNotInGroupException e) {
            // expected
        }
    }
    
    public void testListAllGroups() throws Exception {
        int preSize = handler.listAllGroups(adminKey).size();
        
        ManagedServerGroup group = ServerGroupTestUtils.createManaged(admin);
        List groups = handler.listAllGroups(adminKey);
        assertTrue(groups.contains(group));
        assertEquals(1, groups.size() - preSize);
    }
    
    public void testGetDetailsById() throws Exception {
        ManagedServerGroup group = ServerGroupTestUtils.createManaged(admin);
        ServerGroup sg = handler.getDetails(adminKey, 
                new Integer(group.getId().intValue()));
        assertEquals(sg, group);
    }
    
    public void testGetDetailsByName() throws Exception {
        ManagedServerGroup group = ServerGroupTestUtils.createManaged(admin);
        ServerGroup sg = handler.getDetails(adminKey, group.getName());
        assertEquals(sg, group);
        
    }
    
    public void testGetDetailsByUnknownId() throws Exception {
        boolean exceptCaught = false;
        int badValue = -80;
        try {
            ServerGroup sg = handler.getDetails(adminKey, new Integer(badValue));
        }
        catch (FaultException e) {
            exceptCaught = true;
        }
        assertTrue(exceptCaught);
    }
    
    public void testGetDetailsByUnknownName() throws Exception {
        boolean exceptCaught = false;
        String badName = new String("intentionalBadName123456789");
        try {
            ServerGroup sg = handler.getDetails(adminKey, badName);
        }
        catch (FaultException e) {
            exceptCaught = true;
        }
        assertTrue(exceptCaught);
    }
    
    
    public void testListInactiveServersInGroup() throws Exception {
        ManagedServerGroup group = ServerGroupTestUtils.createManaged(admin);
        Server server = ServerTestUtils.createTestSystem(admin);
        Server server2 = ServerTestUtils.createTestSystem(admin);
        
        List  test = new ArrayList();
        test.add(server);
        test.add(server2);
        ServerGroupManager.getInstance().addServers(group, test, admin);
       
        
        Calendar cal = Calendar.getInstance();
        cal.add(cal.HOUR, -442);
        server.getServerInfo().setCheckin(cal.getTime());
        TestUtils.saveAndFlush(server);
        TestUtils.saveAndFlush(group);

        List list = handler.listInactiveSystemsInGroup(adminKey, group.getName(), 1);
        assertEquals(1, list.size());
        assertEquals(server.getId().toString(), list.get(0).toString());
    }
    
    public void testListActiveServersInGroup() throws Exception {
        ManagedServerGroup group = ServerGroupTestUtils.createManaged(admin);
        Server server = ServerTestUtils.createTestSystem(admin);
        Server server2 = ServerTestUtils.createTestSystem(admin);
        
        List  test = new ArrayList();
        test.add(server);
        test.add(server2);
        
        Calendar cal = Calendar.getInstance();
        cal.add(cal.HOUR, -442);
        server2.getServerInfo().setCheckin(cal.getTime());
        
        ServerGroupManager.getInstance().addServers(group, test, admin);
       
        TestUtils.saveAndFlush(server);
        TestUtils.saveAndFlush(group);
              
        List list = handler.listActiveSystemsInGroup(adminKey, group.getName());
        
        assertEquals(1, list.size());
        assertEquals(server.getId().toString(), list.get(0).toString());
    }
    
    
}
