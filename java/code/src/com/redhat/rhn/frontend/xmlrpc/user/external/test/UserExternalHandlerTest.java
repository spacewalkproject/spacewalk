/**
 * Copyright (c) 2014 Red Hat, Inc.
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
package com.redhat.rhn.frontend.xmlrpc.user.external.test;

import com.redhat.rhn.domain.org.usergroup.OrgUserExtGroup;
import com.redhat.rhn.domain.org.usergroup.UserExtGroup;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.xmlrpc.ExternalGroupAlreadyExistsException;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.frontend.xmlrpc.systemgroup.ServerGroupHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.frontend.xmlrpc.user.external.UserExternalHandler;
import com.redhat.rhn.testing.TestUtils;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class UserExternalHandlerTest extends BaseHandlerTestCase {

    private UserExternalHandler handler = new UserExternalHandler();
    private static List<String> roles = Arrays.asList(RoleFactory.SYSTEM_GROUP_ADMIN
            .getLabel());

    public void testExternalGroupToRoleMap() {
        String name = "My External Group Name" + TestUtils.randomString();
        //admin should be able to call list users, regular should not
        UserExtGroup result =
                handler.createExternalGroupToRoleMap(satAdmin, name, roles);
        assertNotNull(result);

        //make sure we get a permission exception if a regular user tries to get the user
        //list.
        try {
            result =
                    handler.createExternalGroupToRoleMap(regular,
                            "another group" + TestUtils.randomString(), roles);
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }

        //can't add the same group twice
        try {
            result = handler.createExternalGroupToRoleMap(satAdmin, name, roles);
            fail();
        }
        catch (ExternalGroupAlreadyExistsException e) {
            //success
        }

        //make sure at least this group is in the list
        List<UserExtGroup> groups = handler.listExternalGroupToRoleMaps(satAdmin);
        Set<String> names = new HashSet<String>();
        for (UserExtGroup g : groups) {
            names.add(g.getLabel());
        }
        assertTrue(names.contains(name));

        //regular user can't update
        try {
            handler.setExternalGroupRoles(regular, name, roles);
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }

        //set org_admin, make sure we get all implied roles. implicitly testing get.
        handler.setExternalGroupRoles(satAdmin, name,
                Arrays.asList(RoleFactory.ORG_ADMIN.getLabel()));
        UserExtGroup group = handler.getExternalGroupToRoleMap(satAdmin, name);
        assertEquals(UserFactory.IMPLIEDROLES.size() + 1, group.getRoles().size());

        //if we set just two roles all others should be deleted
        handler.setExternalGroupRoles(satAdmin, name, roles);
        group = handler.getExternalGroupToRoleMap(satAdmin, name);
        assertTrue(group.getRoles().size() == 2);

        //regular user can't delete
        int success = -1;
        try {
            success = handler.deleteExternalGroupToRoleMap(regular, name);
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }

        success = handler.deleteExternalGroupToRoleMap(satAdmin, name);
        assertTrue(success == 1);
    }

    public void testExternalGroupToServerGroupMap() {
        String name = "My External Group Name" + TestUtils.randomString();
        String systemGroupName = "my-system-group-name" + TestUtils.randomString();
        String desc = TestUtils.randomString();
        ServerGroupHandler sghandler = new ServerGroupHandler();
        sghandler.create(admin, systemGroupName, desc);

        //admin should be able to call list users, regular should not
        OrgUserExtGroup result =
                handler.createExternalGroupToSystemGroupMap(admin, name,
                        Arrays.asList(systemGroupName));

        //make sure we get a permission exception if a regular user tries to get the user
        //list.
        try {
            result =
                    handler.createExternalGroupToSystemGroupMap(regular,
                            "another group" + TestUtils.randomString(),
                            Arrays.asList(systemGroupName));
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }

        //can't add the same group twice
        try {
            result =
                    handler.createExternalGroupToSystemGroupMap(admin, name,
                            Arrays.asList(systemGroupName));
            fail();
        }
        catch (ExternalGroupAlreadyExistsException e) {
            //success
        }

        //make sure at least this group is in the list
        List<OrgUserExtGroup> groups = handler.listExternalGroupToSystemGroupMaps(admin);
        Set<String> names = new HashSet<String>();
        for (OrgUserExtGroup g : groups) {
            names.add(g.getLabel());
        }
        assertTrue(names.contains(name));

        //regular user can't update
        try {
            handler.setExternalGroupSystemGroups(regular, name,
                    Arrays.asList(systemGroupName));
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }

        //set sysgroup, implicitly testing get.
        handler.setExternalGroupSystemGroups(admin, name,
                Arrays.asList(systemGroupName));
        OrgUserExtGroup group = handler.getExternalGroupToSystemGroupMap(admin, name);
        assertEquals(1, group.getServerGroups().size());
        assertTrue(group.getServerGroupsName().contains(systemGroupName));

        //regular user can't delete
        int success = -1;
        try {
            success = handler.deleteExternalGroupToSystemGroupMap(regular, name);
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }

        success = handler.deleteExternalGroupToSystemGroupMap(admin, name);
        assertTrue(success == 1);

        sghandler.delete(admin, systemGroupName);
    }

    public void testDefaultOrg() {
        int currentDefault = handler.getDefaultOrg(satAdmin);
        handler.setDefaultOrg(satAdmin, 0);
        assertTrue(0 == handler.getDefaultOrg(satAdmin));

        handler.setDefaultOrg(satAdmin, 1);
        assertTrue(1 == handler.getDefaultOrg(satAdmin));

        handler.setDefaultOrg(satAdmin, currentDefault);
    }

    public void testKeepRoles() {
        boolean currentKeepRoles = handler.getKeepTemporaryRoles(satAdmin);
        handler.setKeepTemporaryRoles(satAdmin, !currentKeepRoles);
        assertTrue(!currentKeepRoles == handler.getKeepTemporaryRoles(satAdmin));
        handler.setKeepTemporaryRoles(satAdmin, currentKeepRoles);
    }

    public void testUseOrgUnit() {
        boolean currentUseOrgUnit = handler.getUseOrgUnit(satAdmin);
        handler.setUseOrgUnit(satAdmin, !currentUseOrgUnit);
        assertTrue(!currentUseOrgUnit == handler.getUseOrgUnit(satAdmin));
        handler.setUseOrgUnit(satAdmin, currentUseOrgUnit);
    }
}
