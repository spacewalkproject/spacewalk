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

package com.redhat.rhn.domain.user.test;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.Address;
import com.redhat.rhn.domain.user.RhnTimeZone;
import com.redhat.rhn.domain.user.State;
import com.redhat.rhn.domain.user.StateChange;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.domain.user.UserServerPreference;
import com.redhat.rhn.domain.user.UserServerPreferenceId;
import com.redhat.rhn.manager.user.UserManager;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestStatics;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.hibernate.Session;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/** JUnit test case for the User
 *  class.
 * @version $Rev$
 */

public class UserFactoryTest extends RhnBaseTestCase {
    private UserFactory factory;
    
    public void setUp() {
        factory = UserFactory.getInstance();
    }
    public void testStateChanges() throws Exception {

        User orgAdmin = UserTestUtils.createUser("UFTOrgAdmin",
                                            UserTestUtils.createOrg("UFTTestOrg"));
        User normalUser = UserTestUtils.createUser("UFTNormalUser",
                                            orgAdmin.getOrg().getId());

        //disable the normal user
        factory.disable(normalUser, orgAdmin);

        /*
         * We have to sleep here for a second since enabling/disabling a user within
         * the same second causes db problems.
         */
        Thread.sleep(1000);

        assertTrue(normalUser.getStateChanges().size() == 1);
        assertTrue(normalUser.isDisabled());

        //make sure our state change was set correctly
        StateChange change = (StateChange) normalUser.getStateChanges().toArray()[0];
        assertTrue(change.getUser().equals(normalUser));
        assertTrue(change.getChangedBy().equals(orgAdmin));
        assertTrue(change.getState().equals(UserFactory.DISABLED));

        //enable the normal user
        factory.enable(normalUser, orgAdmin);

        assertTrue(normalUser.getStateChanges().size() == 2);
        assertFalse(normalUser.isDisabled());

        Long id = normalUser.getId();

        //Evict the user and look back up. This make sure our changes got saved
        //to the db.
        flushAndEvict(normalUser);

        User usr = UserFactory.lookupById(id);
        assertFalse(usr.isDisabled());
        assertTrue(usr.getStateChanges().size() == 2);
    }

    public void testStates() {
        State e = UserFactory.ENABLED;
        State d = UserFactory.DISABLED;

        assertNotNull(e);
        assertNotNull(d);
        assertEquals(e.getLabel(), "enabled");
        assertEquals(d.getLabel(), "disabled");
    }

    public void testCreateAddress() {
        Address addr = UserFactory.createAddress();
        assertNotNull(addr);
    }

    public void testLookupById() throws Exception {
        Long id = UserTestUtils.createUser("testUser", "testOrg");
        User usr = UserFactory.lookupById(id);
        assertNotNull(usr);
        assertNotNull(usr.getFirstNames());
    }

    public void testLookupByIds() throws Exception {
        List idList = new ArrayList();
        List userList = new ArrayList();
        Long firstId = UserTestUtils.createUser("testUserOne", "testOrgOne");
        Long secondId = UserTestUtils.createUser("testUserSecond", "testOrgSecond");
        idList.add(firstId);
        idList.add(secondId);
        userList = UserFactory.lookupByIds(idList);
        assertNotNull(userList);
        assertNotNull(((User)userList.get(1)).getFirstNames());
        assertContains(((User)userList.get(1)).getLogin(), "testUserSecond");
    }

    public void testLookupByLogin() throws Exception {
        Long id = UserTestUtils.createUser("testUser", "testOrg");
        User usr = UserFactory.lookupById(id);
        String createdLogin = usr.getLogin();
        assertNotNull(usr);
        User usrByLogin = UserFactory.lookupByLogin(usr.getLogin());
        assertNotNull(usrByLogin);
        assertNotNull(usrByLogin.getLogin());
        assertEquals(usrByLogin.getLogin(), createdLogin);
        assertNotNull(usrByLogin.getOrg());
    }

    public void testLookupNotExists() throws Exception {
        User usr = UserFactory.lookupById(new Long(-99999));
        assertNull(usr);
    }

    public void testEmailA() {
        Long id = UserTestUtils.createUser("testUser", "testOrg");
        User usr = UserFactory.lookupById(id);
        UserFactory.save(usr);
    }

    public void testGetTimeZoneOlson() {
        RhnTimeZone tz = UserFactory.getTimeZone("America/Los_Angeles");
        assertNotNull(tz);
        assertTrue(tz.getOlsonName().equals("America/Los_Angeles"));

        RhnTimeZone tz2 = UserFactory.getTimeZone("foo");
        assertNull(tz2);
    }

    public void testGetTimeZoneId() {
        RhnTimeZone tz = UserFactory.getTimeZone(UserFactory
                .getTimeZone("America/Los_Angeles").getTimeZoneId());
        assertTrue(UserFactory.getTimeZone("America/Los_Angeles").equals(tz));
        assertTrue(tz.getOlsonName().equals("America/Los_Angeles"));

        RhnTimeZone tz2 = UserFactory.getTimeZone(-23);
        assertNull(tz2);
    }

    public void testGetTimeZoneDefault() {
        RhnTimeZone tz = UserFactory.getDefaultTimeZone();
        assertNotNull(tz);
        assertTrue(tz.getOlsonName().equals("America/New_York"));
    }

    public void testTimeZoneLookupAll() {
        List tzList = UserFactory.lookupAllTimeZones();
        // Total seems to fluctuate, check for 30+:
        assertTrue(tzList.size() > 30);
        assertTrue(tzList.get(2) instanceof RhnTimeZone);
        assertTrue(((RhnTimeZone)tzList.get(0)).getOlsonName().equals("America/New_York"));
    }

    public void testCommitUser() throws Exception {

        Long id = UserTestUtils.createUser("testUser", "testOrg");
        User usr = UserFactory.lookupById(id);
        usr.setFirstNames("UserFactoryTest.testCommitUser.change " +
                    TestUtils.randomString());
        UserFactory.save(usr);
        flushAndEvict(usr);

        // Now lets manually test to see if the user got updated
        Connection c = null;
        ResultSet rs = null;
        PreparedStatement ps = null;
        Session session = null;
        String rawValue = null;
        try {
            session = HibernateFactory.getSession();
            c = session.connection();
            assertNotNull(c);
            ps = c.prepareStatement(
                "SELECT FIRST_NAMES FROM WEB_USER_PERSONAL_INFO" +
                "  WHERE WEB_USER_ID = " + id);
            rs = ps.executeQuery();
            rs.next();
            rawValue = rs.getString("FIRST_NAMES");
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            rs.close();
            ps.close();
        }

        usr = UserFactory.lookupById(id);
        assertEquals(usr.getFirstNames(), rawValue);
    }


    public void testLookupMultiple() throws Exception {
        int len = 3;
        String[] logins = new String[len];
        for (int i = 0; i < len; i++) {
            Long id = UserTestUtils.createUser("testUser", "testOrg");
            User usr = UserFactory.lookupById(id);
            logins[i] = usr.getLogin();
        }

        for (int i = 0; i < len; i++) {
            User usr = UserFactory.lookupByLogin(logins[i]);
            assertTrue(usr.getLogin().equals(logins[i]));
        }
    }

    public void testCreateNewUser() {
        /* This specifically DOESN'T use UserTestUtils.createUser(), because
         * I am testing how commitNewUser works.
         */

        String orgName = "userFactoryTestOrg ";
        String userName = "userFactoryTestUser " + TestUtils.randomString();

        Long orgId = UserTestUtils.createOrg(orgName);

        User usr = UserFactory.createUser();
        usr.setLogin(userName);
        usr.setPassword("password");
        usr.setFirstNames("userName");
        usr.setLastName("userName");
        String prefix = (String) LocalizationService.getInstance().
                            availablePrefixes().toArray()[0];
        usr.setPrefix(prefix);

        usr.setEmail("redhatJavaTest@redhat.com");

        Address addr1 = UserFactory.createAddress();
        addr1.setAddress1("444 Castro");
        addr1.setAddress2("#1");
        addr1.setCity("Mountain View");
        addr1.setZip("94043");
        addr1.setCountry("US");
        addr1.setPhone("650-555-1212");
        addr1.setFax("650-555-1212");

        usr = UserFactory.saveNewUser(usr, addr1, orgId);

        assertTrue(usr.getId().longValue() > 0);

        assertNotNull(usr.getOrg());

        assertNotNull(usr.getEnterpriseUser().getAddress());
        Address dbAddr = usr.getEnterpriseUser().getAddress();
        assertTrue(dbAddr.getId().intValue() > 0);
        assertEquals("444 Castro", dbAddr.getAddress1());
    }
    
    public void testUserServerPreferenceLookup() throws Exception {
        User user = UserTestUtils.findNewUser(TestStatics.TESTUSER, 
                                              TestStatics.TESTORG);
        
        Server s = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        
        UserServerPreferenceId id = new UserServerPreferenceId(user, 
                                                               s, 
                                                               UserServerPreferenceId
                                                               .RECEIVE_NOTIFICATIONS);
        
        UserServerPreference usp = new UserServerPreference();
        usp.setId(id);
        usp.setValue("0");
        TestUtils.saveAndFlush(usp);
        
        usp = null;
        usp = factory.lookupServerPreferenceByUserServerAndName(user, s, 
                                      UserServerPreferenceId.RECEIVE_NOTIFICATIONS);
        
        assertNotNull(usp);
        assertEquals(usp.getValue(), "0");
        
    }
    
    public void testSetUserServerPreferenceTrue() throws Exception {
        User user = UserTestUtils.findNewUser(TestStatics.TESTUSER,
                                              TestStatics.TESTORG);
        
        Server s = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        
        UserFactory.getInstance().setUserServerPreferenceValue(user, 
                                                 s, 
                                                 UserServerPreferenceId
                                                 .RECEIVE_NOTIFICATIONS,
                                                 false);
      
        assertFalse(UserManager.lookupUserServerPreferenceValue(user, 
                                                                s, 
                                                                UserServerPreferenceId
                                                                .RECEIVE_NOTIFICATIONS));
        
        factory.setUserServerPreferenceValue(user, 
                                                 s, 
                                                 UserServerPreferenceId
                                                 .RECEIVE_NOTIFICATIONS,
                                                 true);
        
        assertTrue(UserManager.lookupUserServerPreferenceValue(user, 
                                                               s, 
                                                               UserServerPreferenceId
                                                               .RECEIVE_NOTIFICATIONS));
        
    }

    public void testSatelliteHasUsers() {
        assertTrue(UserFactory.satelliteHasUsers());
    }

    public void testFindAllOrgAdmins() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg", true);
        User user2 = UserTestUtils.findNewUser("testUser2", "testOrg", true);

        Org o = user.getOrg();

        List<User> orgAdmins = UserFactory.getInstance().findAllOrgAdmins(o);
        assertEquals(1, orgAdmins.size());
        assertTrue(orgAdmins.contains(user));
    }
}
