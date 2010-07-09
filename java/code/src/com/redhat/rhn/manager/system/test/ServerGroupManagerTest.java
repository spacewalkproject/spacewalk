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
package com.redhat.rhn.manager.system.test;

import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.ServerGroupFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.system.ServerGroupManager;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Set;


/**
 * ServerGroupManagerTest
 * @version $Rev$
 */
public class ServerGroupManagerTest extends BaseTestCaseWithUser {
    private static final String NAME = "Foo1";
    private static final String DESCRIPTION = "Test Foo1";

    private ServerGroupManager manager;

    public void setUp() throws Exception {
        super.setUp();
        manager = ServerGroupManager.getInstance();
    }

    public void testCreate() {
        try {
            manager.create(user, NAME, DESCRIPTION);
            String msg = "Unprivileged user creates a servergroup." +
                            "Only a user with Sys Group Admin privilege " +
                            " should be able to create/remove a system group.";
            fail(msg);
        }
        catch (Exception e) {
            //Great... No privilege won't let you create a server group.
        }

        user.addRole(RoleFactory.SYSTEM_GROUP_ADMIN);
        ServerGroup sg = manager.create(user, NAME, DESCRIPTION);
        assertNotNull(sg);
        assertEquals(NAME, sg.getName());
        assertEquals(DESCRIPTION, sg.getDescription());
    }

    public void testAccess() throws Exception {
        user.addRole(RoleFactory.SYSTEM_GROUP_ADMIN);
        ManagedServerGroup sg = manager.create(user, NAME, DESCRIPTION);
        assertTrue(manager.canAccess(user, sg));

        User newUser = UserTestUtils.createUser("testDiffUser", user.getOrg().getId());
        assertFalse(manager.canAccess(newUser, sg));
        List admins = new ArrayList();
        admins.add(newUser);
        manager.associateAdmins(sg, admins, user);
        assertTrue(manager.canAccess(newUser, sg));

        manager.dissociateAdmins(sg, admins, user);
        assertFalse(manager.canAccess(newUser, sg));

        User orgAdmin = UserTestUtils.createUser("testDiffUser", user.getOrg().getId());
        orgAdmin.addRole(RoleFactory.ORG_ADMIN);
        assertTrue(manager.canAccess(orgAdmin, sg));
    }

    public void testRemove() throws Exception {
        user.addRole(RoleFactory.SYSTEM_GROUP_ADMIN);
        ManagedServerGroup sg = manager.create(user, NAME, DESCRIPTION);
        sg = (ManagedServerGroup) reload(sg);
        User newUser = UserTestUtils.createUser("testDiffUser",
                user.getOrg().getId());
        try {
            manager.remove(newUser, sg);
            fail("Permission error. Can't remove if you don't have access");
        }
        catch (Exception e) {
            //passed
        }

        List admins = new ArrayList();
        admins.add(newUser);
        manager.associateAdmins(sg, admins, user);
        try {
            manager.remove(newUser, sg);
            fail("Permission error. Can't remove if you are not Sys Group Admin");
        }
        catch (Exception e) {
            //passed
        }

        manager.dissociateAdmins(sg, admins, user);
        user.addRole(RoleFactory.SYSTEM_GROUP_ADMIN);
        try {
            manager.remove(newUser, sg);
            fail("Permission error. Can't remove if you don't have access");
        }
        catch (Exception e) {
            //passed
        }

        manager.remove(user, sg);
        try {
            manager.lookup(sg.getId(), user);
            fail("Group Not Found Exception not thrown");
        }
        catch (Exception e) {
            //Group Not FOund exception thrown
        }

    }

    public void testListNoAssociatedAdmins() throws Exception {
        user.addRole(RoleFactory.SYSTEM_GROUP_ADMIN);
        ServerGroup sg = manager.create(user, NAME, DESCRIPTION);
        TestUtils.flushAndEvict(sg);
        try {
            manager.listNoAdminGroups(user);
            fail("ORG ADmin permission needed for this!");
        }
        catch (Exception e) {
          //passed
        }
        user.addRole(RoleFactory.ORG_ADMIN);
        Collection groups = manager.listNoAdminGroups(user);

        int initSize = groups.size();
        ServerGroup sg1 = ServerGroupFactory.create(NAME + "ALPHA", DESCRIPTION,
                user.getOrg());
        TestUtils.flushAndEvict(sg1);

        Collection groups1 = manager.listNoAdminGroups(user);
        assertEquals(initSize + 1, groups1.size());
        groups.add(sg1);
        assertEquals(new HashSet(groups), new HashSet(groups1));

    }

    public void testAddRemoveAdmins() {
        user.addRole(RoleFactory.SYSTEM_GROUP_ADMIN);
        ManagedServerGroup sg = manager.create(user, NAME, DESCRIPTION);
        User newUser = UserTestUtils.
            createUser("testDiffUser", user.getOrg().getId());
        List admins = new ArrayList();
        admins.add(newUser);
        manager.associateAdmins(sg, admins, user);

        Set expected = new HashSet(admins);
        expected.add(user);
        assertEquals(expected, sg.getAssociatedAdminsFor(user));

        User orgAdmin = UserTestUtils.createUser("testDiffUser",
                user.getOrg().getId());
        orgAdmin.addRole(RoleFactory.ORG_ADMIN);
        List admins1 = new ArrayList();
        admins1.add(orgAdmin);
        manager.associateAdmins(sg, admins1, user);
        //even though we asked the
        //Manager to associate an org admin
        // we expect that sg.getAssociatedAdminsFor(user)
        // to give us only the  associated admins (No orgAdmin admins).
        assertEquals(expected, sg.getAssociatedAdminsFor(user));

        manager.dissociateAdmins(sg, admins, user);
        expected.removeAll(admins);
        assertEquals(expected, sg.getAssociatedAdminsFor(user));

        manager.dissociateAdmins(sg, admins1, user);
        assertEquals(expected, sg.getAssociatedAdminsFor(user));
    }
}
