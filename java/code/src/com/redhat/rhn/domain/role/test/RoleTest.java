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

package com.redhat.rhn.domain.role.test;

import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.role.Role;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Set;

/** JUnit test case for the User
 *  class.
 */
public class RoleTest extends RhnBaseTestCase {

    /**
    * Test to see if we can modify the collection of roles.
    * We don't support modification of the Collection
    * of roles so we want to make sure an exception is
    * thrown if the collection is attempted to be modified.
    */
    public void testAttemptChangeUserRoles() throws Exception {
        User usr = UserTestUtils.findNewUser("testUser", "testOrg");
        boolean failed = false;
        Set roles = usr.getRoles();
        try {
            roles.remove(RoleFactory.ORG_ADMIN);
        }
        catch (UnsupportedOperationException uoe) {
            // we want it to fail
            failed = true;
        }
        assertTrue(failed);
    }

    /**
    * Test to see if we can add a role to a user
    */
    public void testUserAddRole() {
        User usr = UserTestUtils.findNewUser("testUser", "testOrg");
        Org o1 = usr.getOrg();
        o1.addRole(RoleFactory.CHANNEL_ADMIN);
        o1 = OrgFactory.save(o1);
        assertFalse(usr.hasRole(RoleFactory.CHANNEL_ADMIN));
        usr.addRole(RoleFactory.CHANNEL_ADMIN);
        assertTrue(usr.hasRole(RoleFactory.CHANNEL_ADMIN));

        UserFactory.save(usr);
        User usr2 = UserFactory.lookupById(usr.getId());
        assertTrue(usr2.hasRole(RoleFactory.CHANNEL_ADMIN));
    }

    /**
    * Test to make sure you can't add a Role to a User who's Org
    * doesn't have that Role.
    */
    public void testUserAddRoleNotInOrg() {
        User usr = UserFactory.createUser();
        Org org = OrgFactory.createOrg();
        usr.setOrg(org);
        assertFalse(usr.hasRole(RoleFactory.CHANNEL_ADMIN));
        boolean failed = false;
        try {
            usr.addRole(RoleFactory.CHANNEL_ADMIN);
        }
        catch (IllegalArgumentException iae) {
            failed = true;
        }
        assertTrue(failed);
    }

    /**
    * Test to see if we can add a role to a user
    */
    public void testUserRemoveRole() {
        // Create a new user, add ORG_ADMIN to their roles
        User usr = UserTestUtils.findNewUser("testUser", "testOrg");
        usr.addRole(RoleFactory.ORG_ADMIN);
        UserFactory.save(usr);
        usr.removeRole(RoleFactory.ORG_ADMIN);
        UserFactory.save(usr);
        User usr2 = UserFactory.lookupById(usr.getId());
        assertFalse(usr2.hasRole(RoleFactory.ORG_ADMIN));
    }


    /**
    * We need to make sure that the implied roles are added when a user
    * is an org admin.
    */
    public void testOrgAdminRole() throws Exception {
        User usr = UserTestUtils.findNewUser("testUser", "testOrg");
        Org o1 = usr.getOrg();
        // Add the CHANNEL_ADMIN role to the Org
        o1.addRole(RoleFactory.CHANNEL_ADMIN);
        o1 = OrgFactory.save(o1);
        usr.addRole(RoleFactory.ORG_ADMIN);
        UserFactory.save(usr);
        // Now check to see if the user gets the implied CHANNEL_ADMIN role
        User usr2 = UserFactory.lookupById(usr.getId());
        assertTrue(usr2.hasRole(RoleFactory.CHANNEL_ADMIN));
    }

    /**
    *  Test to make sure we can add Roles to Orgs
    */
    public void testOrgAddRole() throws Exception {
        User usr = UserTestUtils.findNewUser("testUser", "testOrg");
        Org o1 = usr.getOrg();
        // Add the CHANNEL_ADMIN role to the Org
        o1.addRole(RoleFactory.CHANNEL_ADMIN);
        o1 = OrgFactory.save(o1);
        Org o2 = OrgFactory.lookupById(o1.getId());
        // Now check to see if the user gets the implied CHANNEL_ADMIN role
        assertTrue(o2.hasRole(RoleFactory.CHANNEL_ADMIN));
    }


    /**
    * Test to make sure that we support the ability for
    * a user to have no roles
    */
    public void testUserWithNoRoles() throws Exception {
        User usr = UserTestUtils.findNewUser("testUser", "testOrg");
        assertTrue(usr.getRoles().size() == 0);
    }

    /**
    * Test the RoleFactory's lookupByLabel() method
    */
    public void testFindByLabel() throws Exception {
        Role role = RoleFactory.lookupByLabel(RoleFactory.ORG_ADMIN.getLabel());
        assertEquals(RoleFactory.ORG_ADMIN.getLabel(), role.getLabel());
        assertEquals("Organization Administrator", role.getName());
    }


    /**
    * Test the RoleFactory's testFindById() method
    */
    public void testFindById() throws Exception {
        Role r2 = RoleFactory.lookupById(RoleFactory.ORG_ADMIN.getId());
        assertEquals(r2.getLabel(), RoleFactory.ORG_ADMIN.getLabel());
        assertEquals(r2.getName(), "Organization Administrator");
    }


    /**
    * Test to make sure RoleFactory can support looking for
    * roles that don't exist
    */
    public void testFindNonExistentRole() throws Exception {
        assertNull(RoleFactory.lookupByLabel("somerolethatdoesntexist"));
    }

    /**
     * Tests for hibernate caching... doesn't make sense to
     * run these every time, so I'll leave them commented out
     */
    /*
    public void testCache1() throws Exception {
        System.out.println("******************");
        System.out.println("*** testCache1 ***");
        System.out.println("******************");
        System.out.println("\nLOAD ALL BY LABEL");
        Role r = RoleFactory.ORG_ADMIN;
        System.out.println("r.getLabel() = " + r.getLabel());

        System.out.println("\nCREATE NEW ROLE");
        Role r2 = new RoleImpl();
        r2.setLabel("Test Label");
        System.out.println("r2.getLabel() " + r2.getLabel());
    }

    public void testCache2() throws Exception {
        System.out.println("******************");
        System.out.println("*** testCache2 ***");
        System.out.println("******************");

        System.out.println("Should already be loaded...");
        Role r = RoleFactory.ORG_ADMIN;
        System.out.println("r.getLabel() = " + r.getLabel());

    }
    */
}
