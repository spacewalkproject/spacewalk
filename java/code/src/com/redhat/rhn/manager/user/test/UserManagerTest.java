/**
 * Copyright (c) 2009 Red Hat, Inc.
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

package com.redhat.rhn.manager.user.test;

import com.redhat.rhn.common.ObjectCreateWrapperException;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.security.user.StateChangeException;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.SetCleanup;
import com.redhat.rhn.domain.role.Role;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.RhnTimeZone;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.domain.user.UserServerPreference;
import com.redhat.rhn.domain.user.UserServerPreferenceId;
import com.redhat.rhn.frontend.dto.SystemSearchResult;
import com.redhat.rhn.frontend.dto.UserOverview;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.user.UserManager;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestStatics;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/** JUnit test case for the User
 *  class.
 */
public class UserManagerTest extends RhnBaseTestCase {

    public void testListRolesAssignable() throws Exception {
        User user = UserTestUtils.findNewUser();
        assertTrue(UserManager.listRolesAssignableBy(user).isEmpty());
        user.addRole(RoleFactory.ORG_ADMIN);
        UserManager.storeUser(user);
        assertTrue(UserManager.listRolesAssignableBy(user).
                                contains(RoleFactory.CONFIG_ADMIN));
        assertFalse(UserManager.listRolesAssignableBy(user).
                contains(RoleFactory.SAT_ADMIN));
        
        User sat = UserTestUtils.createSatAdminInOrgOne();
        assertTrue(UserManager.listRolesAssignableBy(sat).
                contains(RoleFactory.SAT_ADMIN));


    }
    
    public void testVerifyPackageAccess() throws Exception {
        User user = UserTestUtils.findNewUser("testuser", "testorg");
        Package pkg = PackageTest.createTestPackage(user.getOrg());
        assertTrue(UserManager.verifyPackageAccess(user.getOrg(), pkg.getId()));
        
        // Since we have only one org on a sat, all custom created packages will be 
        // available to all users in that org.
        return; 
    }
    
    public void testLookup() {
        User admin = UserTestUtils.findNewUser("testUser", "testOrg");
        admin.addRole(RoleFactory.ORG_ADMIN);
        
        User regular = UserTestUtils.createUser("testUser2", admin.getOrg().getId());
        regular.removeRole(RoleFactory.ORG_ADMIN);
        
        assertTrue(admin.hasRole(RoleFactory.ORG_ADMIN));
        assertTrue(!regular.hasRole(RoleFactory.ORG_ADMIN));
        
        // make sure admin can lookup regular by id and by login
        User test = UserManager.lookupUser(admin, regular.getId());
        assertNotNull(test);
        assertEquals(regular.getLogin(), test.getLogin());
        
        test = UserManager.lookupUser(admin, regular.getLogin());
        assertNotNull(test);
        assertEquals(regular.getLogin(), test.getLogin());
        
        // make sure regular user can't lookup users
        try {
            test = UserManager.lookupUser(regular, admin.getId());
            fail();
        }
        catch (PermissionException e) {
            //success
        }
        
        try {
            test = UserManager.lookupUser(regular, admin.getLogin());
            fail();
        }
        catch (PermissionException e) {
            //success
        }
        
        test = UserManager.lookupUser(regular, regular.getLogin());
        assertNotNull(test);
        assertEquals(regular.getLogin(), test.getLogin());
        
        test = UserManager.lookupUser(regular, regular.getId());
        assertNotNull(test);
        assertEquals(regular.getLogin(), test.getLogin());
    }
    
    public void testUserDisableEnable() {
        //Create test users
        User org1admin = UserTestUtils.createUser("orgAdmin1", 
                                            UserTestUtils.createOrg("UMTOrg1"));
        org1admin.addRole(RoleFactory.ORG_ADMIN);
        UserManager.storeUser(org1admin);
        
        User org1admin2 = UserTestUtils.createUser("orgAdmin2", 
                                                  org1admin.getOrg().getId());
        org1admin2.addRole(RoleFactory.ORG_ADMIN);
        UserManager.storeUser(org1admin2);

        User org1normal = UserTestUtils.createUser("normaluser1", 
                                                    org1admin.getOrg().getId());
        User org1normal2 = UserTestUtils.createUser("normaluser2", 
                                                    org1admin.getOrg().getId());
        
        User org2admin = UserTestUtils.createUser("orgAdmin2",
                                             UserTestUtils.createOrg("UMTOrg2"));
        org2admin.addRole(RoleFactory.ORG_ADMIN);
        UserManager.storeUser(org2admin);
                
        try {
            UserManager.disableUser(org1normal2, org1normal);
            fail("Normal user was allowed to disable an org admin");
        }
        catch (StateChangeException e) {
            assertEquals("userdisable.error.otheruser", e.getMessage());
        }
        
        //Can't disable other org admins
        try {
            UserManager.disableUser(org1admin2, org1admin);
            fail("Org admin was allowed to disable another org admin");
        }
        catch (StateChangeException e) {
            assertEquals("userdisable.error.orgadmin", e.getMessage());
        }
        
        //Make sure valid disables work
        //admin -> normal user
        UserManager.disableUser(org1admin, org1normal);
        assertTrue(org1normal.isDisabled());
        //admin -> self
        UserManager.disableUser(org1admin, org1admin);
        
        
        //Normal users can only disable themselves
        //Normal users can only disable themselves
        assertTrue(org1admin.isDisabled());
        //normal user -> self
        UserManager.disableUser(org1normal2, org1normal2);
        assertTrue(org1normal2.isDisabled());
        
        //Try to disable a user who is already disabled.
        // changing test for changed requirement.  Disabling a user
        // that was already disabled is a noop.  Not an error condition.
        try {
            UserManager.disableUser(org1admin2, org1normal);
            assertTrue(true);
        }
        catch (StateChangeException e) {
            fail("Org Admin disallowed to disable an already disabled user");
        }
        
        //Add a new user to org2
        User org2normal = UserTestUtils.createUser("normaluser2",
                                                   org2admin.getOrg().getId());

        //Can't enable a user who isn't disabled
        try {
            UserManager.enableUser(org2admin, org2normal);
        }
        catch (StateChangeException e) {
            fail("Enabling an enabled user failed.  Should've passed silently");
        }
        
        
        //Enable org1normal2 for next test
        UserManager.enableUser(org1admin2, org1normal2);
        assertFalse(org1normal2.isDisabled());
        
        //Normal users can't enable users
        try {
            UserManager.enableUser(org1normal2, org1normal);
            fail("Normal user was allowed to enable a user");
        }
        catch (StateChangeException e) {
            assertEquals("userenable.error.orgadmin", e.getMessage());
        }
        
        //Make sure valid enables work
        //admin -> normal user
        UserManager.enableUser(org1admin2, org1normal);
        assertFalse(org1normal.isDisabled());
    }
    
    /**
    * Test to ensure functionality of translating
    * usergroup ids to Roles
     * @throws Exception 
    */
    public void aTestUpdateUserRolesFromRoleLabels() throws Exception {
        User usr = UserTestUtils.findNewUser("testUser", "testOrg");
        ServerFactoryTest.createTestServer(usr);

        Org o1 = usr.getOrg();
        Set<Role> oRoles = o1.getRoles();
        List<String> roleLabels = new LinkedList<String>();
        // We know that all newly created Orgs have the ORG_ADMIN
        // so if we add all the UserGroup IDs to the list then 
        // the User should have the ORG_ADMIN assigned to it.
        for (Role role : oRoles) {
            roleLabels.add(role.getLabel());
        }
        UserManager.addRemoveUserRoles(usr, roleLabels, new LinkedList<String>());
        UserManager.storeUser(usr);

        UserTestUtils.assertOrgAdmin(usr);
        
        // Make sure we can take roles away from ourselves:
        int numRoles = usr.getRoles().size();
        List<String> removeRoles = new LinkedList<String>();
        removeRoles.add(RoleFactory.ORG_ADMIN.getLabel());
        UserManager.addRemoveUserRoles(usr, new LinkedList<String>(), 
                removeRoles);
        UserManager.storeUser(usr);
        assertTrue((numRoles - 1) == usr.getRoles().size());
        
        // Test that taking away org admin properly removes
        // permissions for the user (bz156752). Note that calling
        // UserManager.storeUser is absolutely vital for this to work
        UserTestUtils.assertNotOrgAdmin(usr);
    }
    
    public void testUsersInOrg() {
        int numTotal = 1;
        int numDisabled = 0;
        int numActive = 1;
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        PageControl pc = new PageControl();
        pc.setStart(1);
        pc.setPageSize(5);
        
        numTotal = UserManager.usersInOrg(user, pc).getTotalSize();
        numDisabled = UserManager.disabledInOrg(user, pc).getTotalSize();
        numActive = UserManager.activeInOrg(user, pc).getTotalSize();

        //make sure usersInOrg and usersInOrgAsMap return the same number
        int uio1 = UserManager.usersInOrg(user, pc).getTotalSize();
        int uio2 = UserManager.usersInOrg(user, pc, Map.class).getTotalSize();
        assertEquals(uio1, uio2);
        
        try {
            UserManager.usersInOrg(user, pc, Set.class);
            fail();
        }
        catch (ObjectCreateWrapperException e) {
            //success
        }
        
        User peon = UserTestUtils.createUser("testBob", user.getOrg().getId());
        
        DataResult users = UserManager.usersInOrg(user, pc);
        assertNotNull(users);
        assertEquals(numTotal + 1, users.getTotalSize());
        
        users = UserManager.activeInOrg(user, pc);
        assertNotNull(users);
        assertEquals(numActive + 1, users.getTotalSize());
        
        users = UserManager.disabledInOrg(user, pc);
        assertNotNull(users);
        assertEquals(numDisabled, users.getTotalSize());
        
        UserFactory.getInstance().disable(peon, user);
        
        users = UserManager.usersInOrg(user, pc);
        assertNotNull(users);
        assertEquals(numTotal + 1, users.getTotalSize());
        
        users = UserManager.activeInOrg(user, pc);
        assertNotNull(users);
        assertEquals(numActive, users.getTotalSize());
        
        users = UserManager.disabledInOrg(user, pc);
        assertNotNull(users);
        assertEquals(numDisabled + 1, users.getTotalSize());
    }
    
    
    public void testLookupUserOrgBoundaries() {
        User usr1 = UserTestUtils.findNewUser("testUser", "testOrg1", true);
        User usr2 = UserTestUtils.findNewUser("testUser", "testOrg2");
        User usr3 = UserTestUtils.createUser("testUser123", usr1.getOrg().getId());
        try {
            UserManager.lookupUser(usr1, usr2.getLogin());
            String msg = "User1 of Org Id = %s should" +
                            "not be able to access Usr2  of Org Id= %s";
            fail(String.format(msg, 
                    usr1.getOrg().getId(), usr2.getOrg().getId()));
        }
        catch (LookupException e) {
            //Success
        }
        assertEquals(usr3, UserManager.lookupUser(usr1, usr3.getLogin()));
        
    }
    public void testStoreUser() {
        User usr = UserTestUtils.findNewUser("testUser", "testOrg");
        Long id = usr.getId();
        usr.setEmail("something@changed.redhat.com");
        UserManager.storeUser(usr);
        User u2 = UserFactory.lookupById(id);
        assertEquals(u2.getEmail(), "something@changed.redhat.com");
    }
    
    public void testGetSystemGroups() {
        User usr = UserTestUtils.findNewUser("testUser", "testOrg");
        PageControl pc = new PageControl();
        pc.setIndexData(false);
        pc.setFilterColumn("name");
        pc.setStart(1);
        assertNotNull(UserManager.getSystemGroups(usr, pc));
    }
    
    public void testGetTimeZoneId() {
        RhnTimeZone tz = UserManager.getTimeZone(UserManager
                .getTimeZone("Indian/Maldives").getTimeZoneId());
        assertTrue(UserManager.getTimeZone("Indian/Maldives").equals(tz));
        assertTrue(tz.getOlsonName().equals("Indian/Maldives"));
        
        RhnTimeZone tz2 = UserManager.getTimeZone(-23);
        assertNull(tz2);
    }
    
    public void testGetTimeZoneOlson() {
        RhnTimeZone tz = UserManager.getTimeZone("America/New_York");
        assertNotNull(tz);
        assertTrue(tz.getOlsonName().equals("America/New_York"));
        
        RhnTimeZone tz2 = UserManager.getTimeZone("foo");
        assertNull(tz2);
    }
    
    public void testGetTimeZoneDefault() {
        RhnTimeZone tz = UserManager.getDefaultTimeZone();
        assertNotNull(tz);
        assertTrue(tz.getOlsonName().equals("America/New_York"));
    }
    
    public void testLookupTimeZoneAll() {
        List lst = UserManager.lookupAllTimeZones();
        assertTrue(lst.size() > 30);
        assertTrue(lst.get(0) instanceof RhnTimeZone);
        assertTrue(lst.get(5) instanceof RhnTimeZone);
        assertTrue(lst.get(34) instanceof RhnTimeZone);

        assertTrue(((RhnTimeZone)lst.get(4)).equals(UserManager
                .getTimeZone("America/Phoenix")));
        assertTrue(((RhnTimeZone)lst.get(4)).getOlsonName().equals("America/Phoenix"));
    }

   public void testUsersInSet() throws Exception {
       User user = UserTestUtils.findNewUser("testUser", "testOrg");
       RhnSet set = RhnSetManager.createSet(user.getId(), "test_user_list", 
               SetCleanup.NOOP);
       
       for (int i = 0; i < 5; i++) {
           User usr = UserTestUtils.createUser("testBob", user.getOrg().getId());
           set.addElement(usr.getId());
       }
       
       RhnSetManager.store(set);
       PageControl pc = new PageControl();
       pc.setStart(1);
       pc.setPageSize(10);
       DataResult dr = UserManager.usersInSet(user, "test_user_list", pc);
       
       assertEquals(5, dr.size());
       assertTrue(dr.iterator().hasNext());
       assertTrue(dr.iterator().next() instanceof UserOverview);
       UserOverview m = (UserOverview)(dr.iterator().next());
       assertNotNull(m.getUserLogin());
   }
   
   public void testLookupServerPreferenceValue() throws Exception {
       User user = UserTestUtils.findNewUser(TestStatics.TESTUSER, 
               TestStatics.TESTORG);
       
       Server s = ServerFactoryTest.createTestServer(user, true,
               ServerConstants.getServerGroupTypeEnterpriseEntitled());
       
       
       assertTrue(UserManager.lookupUserServerPreferenceValue(user, 
                                                              s,
                                                              UserServerPreferenceId
                                                              .RECEIVE_NOTIFICATIONS));

       UserServerPreferenceId id = new UserServerPreferenceId(user, 
                                       s, 
                                       UserServerPreferenceId
                                       .RECEIVE_NOTIFICATIONS);
       
       UserServerPreference usp = new UserServerPreference();
       usp.setId(id);
       usp.setValue("0");
       
       TestUtils.saveAndFlush(usp);
       
       assertFalse(UserManager.lookupUserServerPreferenceValue(user,
                                                               s,
                                                               UserServerPreferenceId
                                                               .RECEIVE_NOTIFICATIONS));
   }

   public void testVisibleSystemsAsDtoFromList() throws Exception {
       User user = UserTestUtils.findNewUser(TestStatics.TESTUSER,
               TestStatics.TESTORG);

       Server s = ServerFactoryTest.createTestServer(user, true,
               ServerConstants.getServerGroupTypeEnterpriseEntitled());
       List<Long> ids = new ArrayList<Long>();
       ids.add(s.getId());
       List<SystemSearchResult> dr =
           UserManager.visibleSystemsAsDtoFromList(user, ids);
       assertTrue(dr.size() >= 1);
   }

   public void testSystemSearchResults() throws Exception {
       User user = UserTestUtils.findNewUser(TestStatics.TESTUSER,
               TestStatics.TESTORG);

       Server s = ServerFactoryTest.createTestServer(user, true,
               ServerConstants.getServerGroupTypeEnterpriseEntitled());
       s.setDescription("Test Description Value");
       List<Long> ids = new ArrayList<Long>();
       ids.add(s.getId());
       DataResult<SystemSearchResult> dr =
           UserManager.visibleSystemsAsDtoFromList(user, ids);
       assertTrue(dr.size() >= 1);
       dr.elaborate(Collections.EMPTY_MAP);
       SystemSearchResult sr = dr.get(0);
       System.err.println("sr.getDescription() = " + sr.getDescription());
       System.err.println("sr.getHostname() = " + sr.getHostname());
       assertTrue(sr.getDescription() != null);
       //assertTrue(sr.getHostname() != null);
   }
}
