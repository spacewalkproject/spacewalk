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
import com.redhat.rhn.domain.org.usergroup.UserExtGroup;
import com.redhat.rhn.domain.org.usergroup.UserGroupFactory;
import com.redhat.rhn.domain.role.Role;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.ExternalGroupAlreadyExistsException;
import com.redhat.rhn.frontend.xmlrpc.InvalidRoleException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchExternalGroupException;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.frontend.xmlrpc.org.OrgHandler;

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
     * @param sessionKey The sessionkey for the session containing the logged in user.
     * @param keepRoles True if we should keep temporary roles between login sessions
     * @return 1 on success
     * @throws PermissionCheckFailureException if the user is not a Sat admin
     *
     * @xmlrpc.doc Set whether we should keeps roles assigned to users because of
     * their IPA groups even after they log in through a non-IPA method.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("boolean", "keepRoles", "True if we should keep roles
     * after users log in through non-IPA method, false otherwise.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setKeepTemporaryRoles(String sessionKey, Boolean keepRoles)
            throws PermissionCheckFailureException {
        // Make sure we're logged in and a Sat Admin
        ensureSatAdmin(getLoggedInUser(sessionKey));

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
     * @param sessionKey The sessionkey for the session containing the logged in user.
     * @return True if we should keep roles
     * after users log in through non-IPA method, false otherwise.
     * @throws PermissionCheckFailureException if the user is not a Sat admin
     *
     * @xmlrpc.doc Get whether we should keeps roles assigned to users because of
     * their IPA groups even after they log in through a non-IPA method.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype boolean - True if we should keep roles
     * after users log in through non-IPA method, false otherwise.
     */
    public boolean getKeepTemporaryRoles(String sessionKey)
            throws PermissionCheckFailureException {
        // Make sure we're logged in and a Sat Admin
        ensureSatAdmin(getLoggedInUser(sessionKey));

        // get the value
        return SatConfigFactory
                .getSatConfigBooleanValue(SatConfigFactory.EXT_AUTH_KEEP_ROLES);
    }

    /**
     * Set the value of EXT_AUTH_USE_ORGUNIT
     * @param sessionKey The sessionkey for the session containing the logged in user.
     * @param useOrgUnit True if we should keep pay attention to the Org Unit from IPA
     * @return 1 on success
     * @throws PermissionCheckFailureException if the user is not a Sat admin
     *
     * @xmlrpc.doc Set whether we place users into the organization that corresponds
     * to the "orgunit" set on the IPA server. The orgunit name must match exactly the
     * Satellite organization name.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("boolean", "useOrgUnit", "True if we should use the IPA
     * orgunit to determine which organization to create the user in, false otherwise.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setUseOrgUnit(String sessionKey, Boolean useOrgUnit)
            throws PermissionCheckFailureException {
        // Make sure we're logged in and a Sat Admin
        ensureSatAdmin(getLoggedInUser(sessionKey));

        // store the value
        SatConfigFactory.setSatConfigBooleanValue(SatConfigFactory.EXT_AUTH_USE_ORGUNIT,
                useOrgUnit);

        return 1;
    }

    /**
     * Get the value of EXT_AUTH_USE_ORGUNIT
     * @param sessionKey The sessionkey for the session containing the logged in user.
     * @return True if we should use org unit
     * @throws PermissionCheckFailureException if the user is not a Sat admin
     *
     * @xmlrpc.doc Get whether we place users into the organization that corresponds
     * to the "orgunit" set on the IPA server. The orgunit name must match exactly the
     * Satellite organization name.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype boolean - True if we should use the IPA
     * orgunit to determine which organization to create the user in, false otherwise.
     */
    public boolean getUseOrgUnit(String sessionKey) throws PermissionCheckFailureException {
        // Make sure we're logged in and a Sat Admin
        ensureSatAdmin(getLoggedInUser(sessionKey));

        // get the value
        return SatConfigFactory
                .getSatConfigBooleanValue(SatConfigFactory.EXT_AUTH_USE_ORGUNIT);
    }

    /**
     * Set the value of EXT_AUTH_DEFAULT_ORGID
     * @param sessionKey The sessionkey for the session containing the logged in user.
     * @param defaultOrg the orgId that we want to use as the default org
     * @return 1 on success
     * @throws PermissionCheckFailureException if the user is not a Sat admin
     *
     * @xmlrpc.doc Set the default org that users should be added in if orgunit from
     * IPA server isn't found or is disabled.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("int", "defaultOrg", "Id of the organization to set
     * as the default org. 0 if there should not be a default organization.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setDefaultOrg(String sessionKey, Integer defaultOrg)
            throws PermissionCheckFailureException {
        // Make sure we're logged in and a Sat Admin
        ensureSatAdmin(getLoggedInUser(sessionKey));

        if (defaultOrg != 0) {
            OrgHandler.verifyOrgExists(defaultOrg);
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
     * @param sessionKey The sessionkey for the session containing the logged in user.
     * @return orgId of the default org
     * @throws PermissionCheckFailureException if the user is not a Sat admin
     *
     * @xmlrpc.doc Get the default org that users should be added in if orgunit from
     * IPA server isn't found or is disabled.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype int - Id of the default organization. 0 if there is no default.
     */
    public int getDefaultOrg(String sessionKey) throws PermissionCheckFailureException {
        // Make sure we're logged in and a Sat Admin
        ensureSatAdmin(getLoggedInUser(sessionKey));

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
     * @param sessionKey The sessionkey for the session containing the logged in user.
     * @param name The name of the new group
     * @param roles List of roles to set for this group
     * @return the newly created group
     * @throws PermissionCheckFailureException if the user is not a Sat admin
     *
     * @xmlrpc.doc Externally authenticated users may be members of external groups. You
     * can use these groups to assign additional roles to the users when the log in.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "name", "Name of the new group. Must be unique
     * and match the name of the externally defined group.")
     * @xmlrpc.param #prop_array("roles - Can be any of:
     * satellite_admin, org_admin (implies all other roles except for satellite_admin),
     * channel_admin, config_admin, system_group_admin,
     * activation_key_admin, or monitoring_admin.", "string", "role")
     * @xmlrpc.returntype $UserExtGroupSerializer
     */
    public UserExtGroup createExternalGroup(String sessionKey, String name,
            List<String> roles) {
        // Make sure we're logged in and a Sat Admin
        ensureSatAdmin(getLoggedInUser(sessionKey));

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
        return group;
    }

    /**
     * Get a external user group
     * @param sessionKey The sessionkey for the session containing the logged in user.
     * @param name The name of the group
     * @return the  group
     * @throws PermissionCheckFailureException if the user is not a Sat admin
     *
     * @xmlrpc.doc Get a representation of the role mapping for an external group.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "name", "Name of the group.")
     * @xmlrpc.returntype $UserExtGroupSerializer
     */
    public UserExtGroup getExternalGroup(String sessionKey, String name) {
        // Make sure we're logged in and a Sat Admin
        ensureSatAdmin(getLoggedInUser(sessionKey));

        UserExtGroup group = UserGroupFactory.lookupExtGroupByLabel(name);
        if (group == null) {
            throw new NoSuchExternalGroupException(name);
        }

        return group;
    }

    /**
     * update a external user group
     * @param sessionKey The sessionkey for the session containing the logged in user.
     * @param name The name of the group
     * @param roles the roles to set
     * @return 1 if successful, error otherwise
     * @throws PermissionCheckFailureException if the user is not a Sat admin
     *
     * @xmlrpc.doc Update the roles for an external group. Replace previously set roles
     * with the ones passed in here.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "name", "Name of the group.")
     * @xmlrpc.param #prop_array("roles - Can be any of:
     * satellite_admin, org_admin (implies all other roles except for satellite_admin),
     * channel_admin, config_admin, system_group_admin,
     * activation_key_admin, or monitoring_admin.", "string", "role")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setExternalGroupRoles(String sessionKey, String name, List<String> roles) {
        // Make sure we're logged in and a Sat Admin
        ensureSatAdmin(getLoggedInUser(sessionKey));

        UserExtGroup group = UserGroupFactory.lookupExtGroupByLabel(name);
        if (group == null) {
            throw new NoSuchExternalGroupException(name);
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
     * @param sessionKey The sessionkey for the session containing the logged in user.
     * @param name The name of the group
     * @return 1 if successful, error otherwise
     * @throws PermissionCheckFailureException if the user is not a Sat admin
     *
     * @xmlrpc.doc Delete the entry for an external group.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "name", "Name of the group.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int deleteExternalGroup(String sessionKey, String name) {
        // Make sure we're logged in and a Sat Admin
        ensureSatAdmin(getLoggedInUser(sessionKey));

        UserExtGroup group = UserGroupFactory.lookupExtGroupByLabel(name);
        if (group == null) {
            throw new NoSuchExternalGroupException(name);
        }

        UserGroupFactory.delete(group);
        return 1;
    }

    /**
     * delete an external user group
     * @param sessionKey The sessionkey for the session containing the logged in user.
     * @return the external groups
     * @throws PermissionCheckFailureException if the user is not a Sat admin
     *
     * @xmlrpc.doc List all known external groups.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype
     * #array()
     *     $UserExtGroupSerializer
     * #array_end()
     */
    public List<UserExtGroup> listExternalGroups(String sessionKey) {
        // Make sure we're logged in and a Sat Admin
        User user = getLoggedInUser(sessionKey);
        ensureSatAdmin(user);

        return UserGroupFactory.listExtAuthGroups(user);
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
    public static void addImpliedRoles(Set<Role> roles) {
        if (roles.contains(RoleFactory.ORG_ADMIN)) {
            roles.addAll(UserFactory.IMPLIEDROLES);
        }
    }
}
