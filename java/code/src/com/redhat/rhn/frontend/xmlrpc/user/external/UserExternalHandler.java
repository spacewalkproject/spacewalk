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
package com.redhat.rhn.frontend.xmlrpc.user.external;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import com.redhat.rhn.domain.common.SatConfigFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.usergroup.OrgUserExtGroup;
import com.redhat.rhn.domain.org.usergroup.UserExtGroup;
import com.redhat.rhn.domain.org.usergroup.UserGroupFactory;
import com.redhat.rhn.domain.role.Role;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.ServerGroupFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.ExternalGroupAlreadyExistsException;
import com.redhat.rhn.frontend.xmlrpc.InvalidRoleException;
import com.redhat.rhn.frontend.xmlrpc.InvalidServerGroupException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchExternalGroupToRoleMapException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchExternalGroupToServerGroupMapException;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import org.apache.commons.lang.BooleanUtils;
import org.apache.commons.lang.StringUtils;

/**
 * UserHandler
 * @version $Rev$
 * @xmlrpc.namespace user.external
 * @xmlrpc.doc If you are using IPA integration to allow authentication of users from
 * an external IPA server (rare) the users will still need to be created in the Satellite
 * database. Methods in this namespace allow you to configure some specifics of how this
 * happens, like what organization they are created in or what roles they will have.
 * These options can also be set in the web admin interface.
 */
public class UserExternalHandler extends BaseHandler {

    /**
     * Set the value of EXT_AUTH_KEEP_ROLES
     * @param loggedInUser The current user
     * @param keepRoles True if we should keep temporary roles between login sessions
     * @return 1 on success
     * @throws PermissionCheckFailureException if the user is not a Sat admin
     *
     * @xmlrpc.doc Set whether we should keeps roles assigned to users because of
     * their IPA groups even after they log in through a non-IPA method. Can only be
     * called by a satellite_admin.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("boolean", "keepRoles", "True if we should keep roles
     * after users log in through non-IPA method, false otherwise.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setKeepTemporaryRoles(User loggedInUser, Boolean keepRoles)
            throws PermissionCheckFailureException {
        // Make sure we're logged in and a Sat Admin
        ensureSatAdmin(loggedInUser);

        if (SatConfigFactory.getSatConfigBooleanValue(
                SatConfigFactory.EXT_AUTH_KEEP_ROLES) &&
                !BooleanUtils.toBoolean(keepRoles)) {
            // if the option was turned off, delete temporary roles
            // across the whole satellite
            UserGroupFactory.deleteTemporaryRoles();
        }
        // store the value
        SatConfigFactory.setSatConfigBooleanValue(SatConfigFactory.EXT_AUTH_KEEP_ROLES,
                keepRoles);

        return 1;
    }

    /**
     * Get the value of EXT_AUTH_KEEP_ROLES
     * @param loggedInUser The current user
     * @return True if we should keep roles
     * after users log in through non-IPA method, false otherwise.
     * @throws PermissionCheckFailureException if the user is not a Sat admin
     *
     * @xmlrpc.doc Get whether we should keeps roles assigned to users because of
     * their IPA groups even after they log in through a non-IPA method. Can only be
     * called by a satellite_admin.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype boolean - True if we should keep roles
     * after users log in through non-IPA method, false otherwise.
     */
    public boolean getKeepTemporaryRoles(User loggedInUser)
            throws PermissionCheckFailureException {
        // Make sure we're logged in and a Sat Admin
        ensureSatAdmin(loggedInUser);

        // get the value
        return SatConfigFactory
                .getSatConfigBooleanValue(SatConfigFactory.EXT_AUTH_KEEP_ROLES);
    }

    /**
     * Set the value of EXT_AUTH_USE_ORGUNIT
     * @param loggedInUser The current user
     * @param useOrgUnit True if we should keep pay attention to the Org Unit from IPA
     * @return 1 on success
     * @throws PermissionCheckFailureException if the user is not a Sat admin
     *
     * @xmlrpc.doc Set whether we place users into the organization that corresponds
     * to the "orgunit" set on the IPA server. The orgunit name must match exactly the
     * Satellite organization name. Can only be called by a satellite_admin.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("boolean", "useOrgUnit", "True if we should use the IPA
     * orgunit to determine which organization to create the user in, false otherwise.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setUseOrgUnit(User loggedInUser, Boolean useOrgUnit)
            throws PermissionCheckFailureException {
        // Make sure we're logged in and a Sat Admin
        ensureSatAdmin(loggedInUser);

        // store the value
        SatConfigFactory.setSatConfigBooleanValue(SatConfigFactory.EXT_AUTH_USE_ORGUNIT,
                useOrgUnit);

        return 1;
    }

    /**
     * Get the value of EXT_AUTH_USE_ORGUNIT
     * @param loggedInUser The current user
     * @return True if we should use org unit
     * @throws PermissionCheckFailureException if the user is not a Sat admin
     *
     * @xmlrpc.doc Get whether we place users into the organization that corresponds
     * to the "orgunit" set on the IPA server. The orgunit name must match exactly the
     * Satellite organization name. Can only be called by a satellite_admin.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype boolean - True if we should use the IPA
     * orgunit to determine which organization to create the user in, false otherwise.
     */
    public boolean getUseOrgUnit(User loggedInUser) throws PermissionCheckFailureException {
        // Make sure we're logged in and a Sat Admin
        ensureSatAdmin(loggedInUser);

        // get the value
        return SatConfigFactory
                .getSatConfigBooleanValue(SatConfigFactory.EXT_AUTH_USE_ORGUNIT);
    }

    /**
     * Set the value of EXT_AUTH_DEFAULT_ORGID
     * @param loggedInUser The current user
     * @param defaultOrg the orgId that we want to use as the default org
     * @return 1 on success
     * @throws PermissionCheckFailureException if the user is not a Sat admin
     *
     * @xmlrpc.doc Set the default org that users should be added in if orgunit from
     * IPA server isn't found or is disabled. Can only be called by a satellite_admin.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("int", "defaultOrg", "Id of the organization to set
     * as the default org. 0 if there should not be a default organization.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setDefaultOrg(User loggedInUser, Integer defaultOrg)
            throws PermissionCheckFailureException {
        // Make sure we're logged in and a Sat Admin
        ensureSatAdmin(loggedInUser);

        if (defaultOrg != 0) {
            verifyOrgExists(defaultOrg);
            SatConfigFactory.setSatConfigValue(SatConfigFactory.EXT_AUTH_DEFAULT_ORGID,
                    defaultOrg.toString());
        }
        else {
            SatConfigFactory.setSatConfigValue(SatConfigFactory.EXT_AUTH_DEFAULT_ORGID, "");
        }

        return 1;
    }

    /**
     * Get the value of EXT_AUTH_DEFAULT_ORGID
     * @param loggedInUser The current user
     * @return orgId of the default org
     * @throws PermissionCheckFailureException if the user is not a Sat admin
     *
     * @xmlrpc.doc Get the default org that users should be added in if orgunit from
     * IPA server isn't found or is disabled. Can only be called by a satellite_admin.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype int - Id of the default organization. 0 if there is no default.
     */
    public int getDefaultOrg(User loggedInUser) throws PermissionCheckFailureException {
        // Make sure we're logged in and a Sat Admin
        ensureSatAdmin(loggedInUser);

        // get the value
        String org = SatConfigFactory.getSatConfigValue(
                SatConfigFactory.EXT_AUTH_DEFAULT_ORGID);
        if (org == null || StringUtils.isEmpty(org)) {
            return 0;
        }
        return Integer.parseInt(org);
    }

    /**
     * Create a new external user group
     * @param loggedInUser The current user
     * @param name The name of the new group
     * @param roles List of roles to set for this group
     * @return the newly created group
     * @throws PermissionCheckFailureException if the user is not a Sat admin
     *
     * @xmlrpc.doc Externally authenticated users may be members of external groups. You
     * can use these groups to assign additional roles to the users when they log in.
     * Can only be called by a satellite_admin.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "name", "Name of the external group. Must be
     * unique.")
     * @xmlrpc.param #array_single("string", "role - Can be any of:
     * satellite_admin, org_admin (implies all other roles except for satellite_admin),
     * channel_admin, config_admin, system_group_admin, or
     * activation_key_admin.")
     * @xmlrpc.returntype $UserExtGroupSerializer
     */
    public UserExtGroup createExternalGroupToRoleMap(User loggedInUser, String name,
            List<String> roles) {
        // Make sure we're logged in and a Sat Admin
        ensureSatAdmin(loggedInUser);

        if (UserGroupFactory.lookupExtGroupByLabel(name) != null) {
            throw new ExternalGroupAlreadyExistsException(name);
        }

        Set<Role> myRoles = new HashSet<Role>();
        for (String role : roles) {
            Role myRole = RoleFactory.lookupByLabel(role);
            if (myRole == null) {
                throw new InvalidRoleException(role);
            }
            myRoles.add(myRole);
        }

        removeImpliedRoles(myRoles);
        UserExtGroup group = new UserExtGroup();
        group.setLabel(name);
        group.setRoles(myRoles);
        UserGroupFactory.save(group);
        addImpliedRoles(group.getRoles());
        return group;
    }

    /**
     * Get a external user group
     * @param loggedInUser The current user
     * @param name The name of the group
     * @return the  group
     * @throws PermissionCheckFailureException if the user is not a Sat admin
     *
     * @xmlrpc.doc Get a representation of the role mapping for an external group.
     * Can only be called by a satellite_admin.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "name", "Name of the external group.")
     * @xmlrpc.returntype $UserExtGroupSerializer
     */
    public UserExtGroup getExternalGroupToRoleMap(User loggedInUser, String name) {
        // Make sure we're logged in and a Sat Admin
        ensureSatAdmin(loggedInUser);

        UserExtGroup group = UserGroupFactory.lookupExtGroupByLabel(name);
        if (group == null) {
            throw new NoSuchExternalGroupToRoleMapException(name);
        }
        addImpliedRoles(group.getRoles());

        return group;
    }

    /**
     * update a external user group
     * @param loggedInUser The current user
     * @param name The name of the group
     * @param roles the roles to set
     * @return 1 if successful, error otherwise
     *
     * @xmlrpc.doc Update the roles for an external group. Replace previously set roles
     * with the ones passed in here. Can only be called by a satellite_admin.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "name", "Name of the external group.")
     * @xmlrpc.param #array_single("string", "role - Can be any of:
     * satellite_admin, org_admin (implies all other roles except for satellite_admin),
     * channel_admin, config_admin, system_group_admin, or
     * activation_key_admin.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setExternalGroupRoles(User loggedInUser, String name, List<String> roles) {
        // Make sure we're logged in and a Sat Admin
        ensureSatAdmin(loggedInUser);

        UserExtGroup group = UserGroupFactory.lookupExtGroupByLabel(name);
        if (group == null) {
            throw new NoSuchExternalGroupToRoleMapException(name);
        }

        Set<Role> myRoles = new HashSet<Role>();
        for (String role : roles) {
            Role myRole = RoleFactory.lookupByLabel(role);
            if (myRole == null) {
                throw new InvalidRoleException(role);
            }
            myRoles.add(myRole);
        }

        removeImpliedRoles(myRoles);
        group.setRoles(myRoles);
        UserGroupFactory.save(group);

        return 1;
    }

    /**
     * delete an external user group
     * @param loggedInUser The current user
     * @param name The name of the group
     * @return 1 if successful, error otherwise
     * @throws PermissionCheckFailureException if the user is not a Sat admin
     *
     * @xmlrpc.doc Delete the role map for an external group. Can only be called
     * by a satellite_admin.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "name", "Name of the external group.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int deleteExternalGroupToRoleMap(User loggedInUser, String name) {
        // Make sure we're logged in and a Sat Admin
        ensureSatAdmin(loggedInUser);

        UserExtGroup group = UserGroupFactory.lookupExtGroupByLabel(name);
        if (group == null) {
            throw new NoSuchExternalGroupToRoleMapException(name);
        }

        UserGroupFactory.delete(group);
        return 1;
    }

    /**
     * delete an external user group
     * @param loggedInUser The current user
     * @return the external groups
     * @throws PermissionCheckFailureException if the user is not a Sat admin
     *
     * @xmlrpc.doc List role mappings for all known external groups. Can only be called
     * by a satellite_admin.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype
     * #array()
     *     $UserExtGroupSerializer
     * #array_end()
     */
    public List<UserExtGroup> listExternalGroupToRoleMaps(User loggedInUser) {
        // Make sure we're logged in and a Sat Admin
        ensureSatAdmin(loggedInUser);

        List<UserExtGroup> groups = UserGroupFactory.listExtAuthGroups(loggedInUser);
        for (UserExtGroup group : groups) {
            addImpliedRoles(group.getRoles());
        }
        return UserGroupFactory.listExtAuthGroups(loggedInUser);
    }

    // remove all the implied roles if we're adding org_admin (for storing to db)
    private void removeImpliedRoles(Set<Role> roles) {
        if (roles.contains(RoleFactory.ORG_ADMIN)) {
            roles.removeAll(UserFactory.IMPLIEDROLES);
        }
    }

    /**
     * add in the implied roles for org_admin (for displaying to user)
     * @param roles The roles the current group has
     */
    private void addImpliedRoles(Set<Role> roles) {
        if (roles.contains(RoleFactory.ORG_ADMIN)) {
            roles.addAll(UserFactory.IMPLIEDROLES);
        }
    }

    /**
     * Create a new external user group
     * @param loggedInUser The current user
     * @param name The name of the new group
     * @param groupNames List of system groups to set for this group
     * @return the newly created group
     *
     * @xmlrpc.doc Externally authenticated users may be members of external groups. You
     * can use these groups to give access to server groups to the users when they log in.
     * Can only be called by an org_admin.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "name", "Name of the external group. Must be
     * unique.")
     * @xmlrpc.param #array_single("string", "groupName - The names of the server
     * groups to grant access to.")
     * @xmlrpc.returntype $OrgUserExtGroupSerializer
     */
    public OrgUserExtGroup createExternalGroupToSystemGroupMap(User loggedInUser,
            String name, List<String> groupNames) {
        ensureOrgAdmin(loggedInUser);
        Org org = loggedInUser.getOrg();

        OrgUserExtGroup group = UserGroupFactory.lookupOrgExtGroupByLabelAndOrg(name, org);
        if (group != null) {
            throw new ExternalGroupAlreadyExistsException(name);
        }

        Set<ServerGroup> sgs = new HashSet<ServerGroup>();
        for (String sg : groupNames) {
            ServerGroup myGroup = ServerGroupFactory.lookupByNameAndOrg(sg, org);
            if (myGroup == null) {
                throw new InvalidServerGroupException(sg);
            }
            sgs.add(myGroup);
        }

        group = new OrgUserExtGroup(org);
        group.setLabel(name);
        group.setServerGroups(sgs);
        UserGroupFactory.save(group);
        return group;
    }

    /**
     * Get a external user group
     * @param loggedInUser The current user
     * @param name The name of the group
     * @return the  group
     *
     * @xmlrpc.doc Get a representation of the server group mapping for an external
     * group. Can only be called by an org_admin.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "name", "Name of the external group.")
     * @xmlrpc.returntype $OrgUserExtGroupSerializer
     */
    public OrgUserExtGroup getExternalGroupToSystemGroupMap(User loggedInUser,
            String name) {
        ensureOrgAdmin(loggedInUser);

        return UserGroupFactory.lookupOrgExtGroupByLabelAndOrg(name, loggedInUser.getOrg());
    }

    /**
     * update a external user group
     * @param loggedInUser The current user
     * @param name The name of the group
     * @param groupNames the groups to set
     * @return 1 if successful, error otherwise
     *
     * @xmlrpc.doc Update the server groups for an external group. Replace previously set
     * server groups with the ones passed in here. Can only be called by an org_admin.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "name", "Name of the external group.")
     * @xmlrpc.param #array_single("string", "groupName - The names of the
     * server groups to grant access to.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setExternalGroupSystemGroups(User loggedInUser, String name,
            List<String> groupNames) {
        ensureOrgAdmin(loggedInUser);
        Org org = loggedInUser.getOrg();

        OrgUserExtGroup group = UserGroupFactory.lookupOrgExtGroupByLabelAndOrg(name, org);
        if (group == null) {
            throw new NoSuchExternalGroupToServerGroupMapException(name);
        }

        Set<ServerGroup> sgs = new HashSet<ServerGroup>();
        for (String sg : groupNames) {
            ServerGroup myGroup = ServerGroupFactory.lookupByNameAndOrg(sg, org);
            if (myGroup == null) {
                throw new InvalidServerGroupException(sg);
            }
            sgs.add(myGroup);
        }

        group.setServerGroups(sgs);
        UserGroupFactory.save(group);
        return 1;
    }

    /**
     * delete an external user group
     * @param loggedInUser The current user
     * @param name The name of the group
     * @return 1 if successful, error otherwise
     *
     * @xmlrpc.doc Delete the server group map for an external group. Can only be called
     * by an org_admin.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "name", "Name of the external group.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int deleteExternalGroupToSystemGroupMap(User loggedInUser, String name) {
        ensureOrgAdmin(loggedInUser);
        Org org = loggedInUser.getOrg();

        OrgUserExtGroup group = UserGroupFactory.lookupOrgExtGroupByLabelAndOrg(name, org);
        if (group == null) {
            throw new NoSuchExternalGroupToServerGroupMapException(name);
        }

        UserGroupFactory.delete(group);
        return 1;
    }

    /**
     * delete an external user group
     * @param loggedInUser The current user
     * @return the external groups
     * @throws PermissionCheckFailureException if the user is not an Org admin
     *
     * @xmlrpc.doc List server group mappings for all known external groups. Can only be
     * called by an org_admin.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype
     * #array()
     *     $OrgUserExtGroupSerializer
     * #array_end()
     */
    public List<OrgUserExtGroup> listExternalGroupToSystemGroupMaps(User loggedInUser) {
        ensureOrgAdmin(loggedInUser);

        return UserGroupFactory.listExtAuthOrgGroups(loggedInUser);
    }

}
