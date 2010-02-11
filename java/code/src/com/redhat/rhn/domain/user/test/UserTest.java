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

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.util.MD5Crypt;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.role.Role;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.Address;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.ServerTestUtils;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Date;
import java.util.Set;

/** JUnit test case for the User
 *  class.
 */
public class UserTest extends RhnBaseTestCase {


    /**
     * {@inheritDoc}
     */
    protected void setUp() throws Exception {
        TestUtils.disableLocalizationLogging();
        super.setUp();
    }

    /**
     * {@inheritDoc}
     */
    protected void tearDown() throws Exception {
        TestUtils.enableLocalizationLogging();
        super.tearDown();
    }

    /**
     *  Test to make sure that we can set the login on a newly created
     *  user.
    */
    public void testSetLogin() {
        User usr = UserFactory.createUser();
        usr.setLogin("testLogin");
        assertEquals("testLogin", usr.getLogin());
    }

    /**
    * Test to make sure that the authenticate method
    * functions properly.  If this test fails it could be
    * because the password changed.
    */
    public void testAuthenticateTrue() throws Exception {
        User usr = UserTestUtils.findNewUser("testUser", "testOrg");
        // relies on UserTestUtils.createUser setting password to "password"
        assertTrue(usr.authenticate("password"));
    }

    /**
    * Test to make sure if the wrong password is passed
    * in that we actually fail the authenticate method
    */
    public void testAuthenticateFail() throws Exception {
        User usr = UserTestUtils.findNewUser("testUser", "testOrg");
        assertFalse(usr.authenticate("this should fail"));
    }

    /**
    * We are having a problem when you lookup a user, then an org, and then
    * a user again.  The second user is using the ORG tables array, which
    * is bad, test that so that it doesn't happen again.
    */
    public void testLookupSameUserTwice() throws Exception {
        User usr = UserTestUtils.findNewUser("testUser", "testOrg");
        Long userId = usr.getId();
        usr.getOrg();
        usr = null;
        usr = UserFactory.lookupById(userId);
    }

    /**
    * Check to make sure we can add an Address to a User.
    */
    public void testAddAddress() throws Exception {
        User usr = UserTestUtils.findNewUser("testUser", "testOrg");
        Address addr = UserTestUtils.createTestAddress(usr);
        UserFactory.save(usr);
        assertTrue(addr.getId().longValue() != 0);
    }


    public void testBeanMethods() {
        User usr = UserTestUtils.findNewUser("testUser", "testOrg");
        String foo = "foo";
        Date now = new Date();

        usr.setLogin(foo);
        assertEquals(foo, usr.getLogin());

        //usr.setOrgId(id);
        assertNotNull(usr.getOrg());

        usr.setPassword(foo);
        boolean encrypt = Config.get().getBoolean(ConfigDefaults.WEB_ENCRYPTED_PASSWORDS);
        if (encrypt) {
            assertEquals(MD5Crypt.crypt("foo", usr.getPassword()), usr.getPassword());
        }
        else {
            assertEquals(foo, usr.getPassword());
        }

        assertTrue(usr.authenticate(foo));
        assertFalse(usr.authenticate("notvalid"));

        assertNotNull(usr.getOrg());

        usr.setCreated(now);
        assertEquals(now, usr.getCreated());

        usr.setModified(now);
        assertEquals(now, usr.getModified());

        usr.setPrefix(foo);
        assertEquals(foo, usr.getPrefix());

        usr.setFirstNames(foo);
        assertEquals(foo, usr.getFirstNames());

        usr.setLastName(foo);
        assertEquals(foo, usr.getLastName());

        usr.setCompany(foo);
        assertEquals(foo, usr.getCompany());

        usr.setTitle(foo);
        assertEquals(foo, usr.getTitle());

        usr.setPhone(foo);
        assertEquals(foo, usr.getPhone());

        usr.setFax(foo);
        assertEquals(foo, usr.getFax());

        usr.setEmail(foo);
        assertEquals(foo, usr.getEmail());

        usr.setPageSize(50);
        assertEquals(50, usr.getPageSize());

        usr.setTimeZone(UserFactory.getTimeZone("America/Los_Angeles"));
        assertTrue(usr.getTimeZone().equals(UserFactory
                .getTimeZone("America/Los_Angeles")));
        assertTrue(usr.getTimeZone().getOlsonName().equals("America/Los_Angeles"));

        usr.setUsePamAuthentication(false);
        assertEquals(false, usr.getUsePamAuthentication());

        usr.setShowSystemGroupList(foo);
        assertEquals(foo, usr.getShowSystemGroupList());

        usr.setLastLoggedIn(now);
        assertEquals(now, usr.getLastLoggedIn());

    }

    public void testSystemGroupMethods() {
        User usr = UserTestUtils.findNewUser("testUser", "testOrg");
        assertEquals(0, usr.getDefaultSystemGroupIds().size());
        // We currently don't have a way in the Java code to
        // add SystemGroups, we can only update pre-existing ones
        // so for now this test can only see if it correctly can
        // call these methods vs creating new SysGroups and adding
        // them to the set.
        usr.setDefaultSystemGroupIds(usr.getDefaultSystemGroupIds());
        assertNotNull(usr.getDefaultSystemGroupIds());
    }

    /*
     * XXX This test will fail on Spacewalk until the schema is fixed.
     * This method should _ONLY_ be called by UserManager.findMailableAddress
     * however, which knows to create the address if it doesn't already exist.
     * The problem on Spacewalk is that the hosted db has a trigger to create
     * the EmaillAddress row, but satellite doesn't have the trigger, meaning
     * that the row is never created.
    public void testEmailAddress() {
        User usr = UserTestUtils.findNewUser("testUser", "testOrg");
        Set e = usr.getEmailAddresses();
        assertNotNull(e);
        assertEquals(1, e.size());
        int i = 0;
        for (Iterator itr = e.iterator(); itr.hasNext();) {
            i++;
            EmailAddress addr = (EmailAddress)itr.next();
            assertEquals("redhatJavaTest@redhat.com", addr.getAddress());
        }
        // make sure we didn't loop more than once.
        assertEquals(1, i);
    }
    */

    public void testGetRoles() {
        User user = UserFactory.createUser();
        Org org = OrgFactory.createOrg();

        user.setOrg(org);

        for (int i = 0; i < 4; i++) {
            Role role = RoleFactory.createRole();
            role.setLabel("Role" + i);
            role.setName("Role " + i);

            org.addRole(role);
            user.addRole(role);
        }

        Set roles = user.getRoles();
        assertEquals(4, roles.size());
    }

    /**
     * Check that PAM authentication does something. The main point of this
     * test is to force a roundtrip through the JNI code for PAM; authentication
     * will fail since most local systems won't have a testUser/password account.
     * Writing a successful test for PAM is near impossible, since it requires
     * a boatload of setup that needs root access
     * @see #testAuthenticateTrue
     */
    public void testPamAuthenticationFails() {
        String oldValue = Config.get().setString("web.pam_auth_service", "login");
        try {
            User usr = UserTestUtils.findNewUser("testUser", "testOrg");
            usr.setUsePamAuthentication(true);
            // This fails, though it succeeds in testAUthenticateTrue, giving
            // us some confidence that a different auth mechanism was indeed
            // being used
            assertTrue(!usr.authenticate("password"));
        }
        finally {
            Config.get().setString("web.pam_auth_service", oldValue);
        }
    }

    public void testServerPerms() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Server server = ServerTestUtils.createTestSystem(user);

        assertEquals(1, user.getServers().size());
        assertTrue(user.getServers().contains(server));
        user.removeServer(server);

        user = UserFactory.lookupById(user.getId());
        assertEquals(0, user.getServers().size());
    }
}
