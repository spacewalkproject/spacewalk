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
package com.redhat.rhn.manager.user;

import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.security.user.StateChangeException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.role.Role;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.Address;
import com.redhat.rhn.domain.user.RhnTimeZone;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.domain.user.UserServerPreference;
import com.redhat.rhn.frontend.dto.SystemGroupOverview;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.dto.SystemSearchResult;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.taglibs.list.decorators.PageSizeDecorator;
import com.redhat.rhn.manager.BaseManager;
import com.redhat.rhn.manager.SatManager;

import org.apache.commons.lang.BooleanUtils;
import org.apache.log4j.Logger;

import java.sql.Types;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.security.auth.login.LoginException;

/**
 * UserManager - the singleton class used to provide Business Operations
 * on Users where those operations interact with other top tier Business Objects.
 *
 * Operations that require the User make changes to
 * @version $Rev: 903 $
 */
public class UserManager extends BaseManager {
    
    private static Logger log = Logger.getLogger(UserManager.class);
    private static final String ORG_ADMIN_LABEL = "org_admin";

    private UserManager() {
    }

    /**
     * Returns a list of roles that are assignable by a given user
     * i.e. the list of roles that the passed in user can assign
     * @param user the user for whom the check is being done
     * @return the list of roles assignable by this user.
     */
    public static Set<Role> listRolesAssignableBy(User user) {
        Set <Role> assignable = new LinkedHashSet<Role>();
        if (user.hasRole(RoleFactory.SAT_ADMIN)) {
            assignable.add(RoleFactory.SAT_ADMIN);
        }
        if (user.hasRole(RoleFactory.ORG_ADMIN)) {
            assignable.add(RoleFactory.ORG_ADMIN);
            assignable.addAll(UserFactory.IMPLIEDROLES);
        }
        return assignable;
    }
    /**
     * Verifies that a given org has access to a given package.
     * @param org The org in question
     * @param packageId The id of the package in question
     * @return Returns true if the org has access to the package, false otherwise.
     */
    public static boolean verifyPackageAccess(Org org, Long packageId) {
        SelectMode m = ModeFactory.getMode("Package_queries", "package_available_to_user");
        Map params = new HashMap();
        params.put("pid", packageId);
        params.put("org_id", org.getId());
        DataResult dr = m.execute(params);

        /*
         * Ok... this query will result in returning a single row containing '1' if the
         * org has access to this channel. If the org *does not* have access to the given
         * package (org the package doesn't exist), nothing will be returned from the query
         * and we will end up with an empty DataResult object.
         */
        return (!dr.isEmpty());
    }

    /**
     * Verifies that the passed in user has admin over the passed in channel.
     * @param user The user to check.
     * @param channel The channel to check.
     * @return Returns true if the user has admin access to this channel, false otherwise.
     */
    public static boolean verifyChannelAdmin(User user, Channel channel) {
       return verifyChannelRole(user, channel, "manage");
    }
    
    /**
     * Verifies that the passed in user has subscribe access to passed in channel.
     * @param user The user to check.
     * @param channel The channel to check.
     * @return Returns true if the user has subscribe access to this channel, 
     *     false otherwise.
     */
    public static boolean verifyChannelSubscribable(User user, Channel channel) {
        return verifyChannelRole(user, channel, "subscribe");
    }       
    
    private static boolean verifyChannelRole(User user, Channel channel, String role) {
        CallableMode m = ModeFactory.getCallableMode(
                "Channel_queries", "verify_channel_role");

        Map inParams = new HashMap();
        inParams.put("cid", channel.getId());
        inParams.put("user_id", user.getId());
        inParams.put("role", role);

        Map outParams = new HashMap();
        outParams.put("result", new Integer(Types.NUMERIC));
        outParams.put("reason", new Integer(Types.VARCHAR));
        Map result = m.execute(inParams, outParams);

        boolean accessible = BooleanUtils.toBoolean(
                ((Long)result.get("result")).intValue());

        return accessible;
    }
    

 
    
    
    /**
     * Enables a user.
     * @param enabledBy The user doing the enabling
     * @param userToEnable The user to enable
     */
    public static void enableUser(User enabledBy, User userToEnable) {
        //Make sure both users are in the same org
        if (!userToEnable.getOrg().equals(enabledBy.getOrg())) {
            throw new StateChangeException("userenable.error.sameorg");
        }

        //Make sure user we're trying to enable is disabled
        if (!userToEnable.isDisabled()) {
            return;
        }

        //Make sure enabledBy is an OrgAdmin
        if (!enabledBy.hasRole(RoleFactory.ORG_ADMIN)) {
            throw new StateChangeException("userenable.error.orgadmin");
        }

        //If we make it here everything must be ok
        UserFactory.getInstance().enable(userToEnable, enabledBy);
    }

    /**
     * Disables userToDisable.
     * @param disabledBy The user doing the disabling
     * @param userToDisable The user to disable
     */
    public static void disableUser(User disabledBy, User userToDisable) {
        //Are both users in same org?
        if (!userToDisable.getOrg().equals(disabledBy.getOrg())) {
            throw new StateChangeException("userdisable.error.sameorg");
        }

        //Make sure user we're trying to disable is currently enabled
        if (userToDisable.isDisabled()) {
            return;
        }

        if (userToDisable.hasRole(RoleFactory.ORG_ADMIN) &&
            userToDisable.getOrg().numActiveOrgAdmins() < 2) {

            // Is user is the last active orgadmin in org on a satellite?
            // bugzilla: 173542 removed org admin restriction for hosted.
            throw new StateChangeException("userdisable.error.onlyuser");
        }

        //If not deleting self, make sure userToDisable is a normal user and
        //disabledBy is an org admin
        if (!userToDisable.equals(disabledBy)) {
            //Normal users can't disable other users
            if (!disabledBy.hasRole(RoleFactory.ORG_ADMIN)) {
                throw new StateChangeException("userdisable.error.otheruser");
            }

            //Can't disable other org admins
            if (userToDisable.hasRole(RoleFactory.ORG_ADMIN)) {
                throw new StateChangeException("userdisable.error.orgadmin");
            }
        }

        //If we get here things must be ok :)
        UserFactory.getInstance().disable(userToDisable, disabledBy);
    }

    /**
     * Revokes permission from the given User to the ServerGroup whose id is sgid.
     * @param usr User who no longer needs permission
     * @param sgid ServerGroup ID
     */
    public static void revokeServerGroupPermission(final User usr,
            final long sgid) {
        SelectMode sm = ModeFactory.getMode("User_queries",
                "check_server_group_permissions_for_revoke");
        CallableMode m = ModeFactory.getCallableMode("User_queries",
                "remove_server_group_permissions");

        Map params = new HashMap();
        params.put("user_id", usr.getId());
        params.put("server_group_id", new Long(sgid));

        DataResult dr = sm.execute(params);
        for (Iterator itr = dr.iterator(); itr.hasNext();) {
            Map row = (Map)itr.next();
            long uid = ((Long)row.get("user_id")).longValue();
            if (uid == usr.getId().longValue()) {
                m.execute(params, new HashMap());
            }
        }
    }

    /**
     * Grants the given User permission to the ServerGroup whose id is sgid.
     * @param usr User who needs permission
     * @param sgid ServerGroup ID
     */
    public static void grantServerGroupPermission(final User usr,
            final long sgid) {
        SelectMode sm = ModeFactory.getMode("User_queries",
                "check_server_group_permissions");
        CallableMode m = ModeFactory.getCallableMode("User_queries",
                "set_server_group_permissions");

        Map params = new HashMap();
        params.put("user_id", usr.getId());
        params.put("server_group_id", new Long(sgid));

        DataResult dr = sm.execute(params);
        if (dr.size() > 0) {
            m.execute(params, new HashMap());
        }
    }

    /**
    * Add and remove the specified roles from the user.
    * 
    * @param usr The User who's Roles you want to update
    * @param rolesToAdd List of role labels to add.
    * @param rolesToRemove List of role labels to remove.
    */
    public static void addRemoveUserRoles(User usr, List<String> rolesToAdd,
            List<String> rolesToRemove) {
        
        log.debug("UserManager.updateUserRolesFromRoleLabels()");
        
        // Make sure last org admin isn't trying to remove his own org admin role:
        if (rolesToRemove.contains(ORG_ADMIN_LABEL)) {
            if (usr.getOrg().numActiveOrgAdmins() <= 1) {
                LocalizationService ls = LocalizationService.getInstance();
                PermissionException pex = new PermissionException("Last org admin");
                pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.removerole"));
                pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.removerole",
                        ls.getMessage(ORG_ADMIN_LABEL)));
                throw pex;
            }
        }

        for (String removeLabel : rolesToRemove) {
            Role removeMe = RoleFactory.lookupByLabel(removeLabel);
            log.debug("Removing role: " + removeMe.getName());
            usr.removeRole(removeMe);
        }
        
        for (String addLabel : rolesToAdd) {
            Role r = RoleFactory.lookupByLabel(addLabel);
            log.debug("Adding role: " + r.getName());
            usr.addRole(r);
        }
    }

    /**
     * Create brand new personal user using the information found in the
     * User object.
     * @param user Filled out user to create.
     * @param org Org to associate with the user.
     * @param addr Address to associate with the user.
     * @return User Freshly created user.
     */
    public static User createUser(User user, Org org, Address addr) {
        /*
         * Ok, this is a bloody ugly hack, but since the pl/sql used by
         * UserFactory.saveNewUser() is shared and the use pam authentication seems to be
         * the only thing affected by it, we are going to work around it here.
         *
         * The Create_New_User function in the db creates an entry in rhnUserInfo with the
         * default values. This means that anything stored in User.personalInfo gets
         * reset. We need to be able to update the use_pam_authentication column in this
         * table, so save the value, save the user, then set the attribute back to what it
         * was before we called UserManager.createUser(). This will ensure that what was
         * selected on the form is what gets stored with the user (since hibernate will
         * then be taking care of the db values).
         *
         * We really need to a) divorce ourselves from www and oracle apps b) get rid of the
         * application/business logic stored in pl/sql functions in the db and c) clean up
         * the dirty hacks like this that are throughout our code. We shouldn't have to work
         * around the db in our code.
         */
        boolean usePam = user.getUsePamAuthentication(); //save what we got from the form
        org = OrgFactory.save(org);

        user = UserFactory.saveNewUser(user, addr, org.getId());

        user.setUsePamAuthentication(usePam); //set it back

        //Set default page size also :)
        user.setPageSize(PageSizeDecorator.getDefaultPageSize());
        storeUser(user); //save the user via hibernate

        return user;
    }

    /**
     * Get the set of default system groups for this user
     * @param usr User for which to get the default system groups.
     * @return groupSet Set of default system groups IDs for the user.
     */
    public static Set getDefaultSystemGroupIds(User usr) {
        SelectMode prefixMode = ModeFactory.getMode("User_queries",
                                                    "default_system_groups");

        Map params = new HashMap();
        params.put("user_id", usr.getId());
        DataResult dr = prefixMode.execute(params);

        Set groupSet = new HashSet();
        Iterator i = dr.iterator();
        while (i.hasNext()) {
            Map row = (Map)i.next();
            groupSet.add((Long)row.get("system_group_id"));
        }
        return groupSet;
    }

    /**
     * Set the defaultSystemGroups for the specified User.  This method first
     * deletes all current groups and then adds all of the specified groups.
     * The assumption is that we never add a lot of default system groups at
     * one time, so it is cheaper to just delete and re-add than to compute
     * the difference and commit just the changes.
     * @param usr User for which to set the default groups.
     * @param groups Set of groups to associate with the user.
     */
    public static void setDefaultSystemGroupIds(final User usr, final Set groups) {
        WriteMode m = ModeFactory.getWriteMode("User_queries",
                "delete_all_system_groups_for_user");
        Map params = new HashMap();
        params.put("user_id", usr.getId());
        m.executeUpdate(params);

        m = ModeFactory.getWriteMode("User_queries", "set_system_group");
        Iterator i = groups.iterator();
        while (i.hasNext()) {
            Long sgid = (Long)i.next();
            params.put("sgid", sgid);
            m.executeUpdate(params);
        }
    }


    /**
     * Login the user with the given username and password.
     * @param username User's login name
     * @param password User's unencrypted password.
     * @return Returns the user if login is successful, or null othewise.
     * @throws LoginException if login fails.  The message is a string resource key.
     */
    public static User loginUser(String username, String password) throws LoginException {
        try {
            User user = UserFactory.lookupByLogin(username);
            if (!user.authenticate(password)) {
                throw new LoginException("error.invalid_login");
            }
            else if (user.isDisabled()) {
                throw new LoginException("account.disabled");
            }
            else {
                user.setLastLoggedIn(new Date());
                // need to disable OAI_SYNC during login
                storeUser(user);
                return user;
            }
        }
        catch (LookupException le) {
            throw new LoginException("error.invalid_login");
        }
    }

    /**
     * Updates the Users to the database
     * @param user User to store.
     */
    public static void storeUser(User user) {
        UserFactory.save(user);
    }

    
    /**
     * Deletes a User
     * @param loggedInUser The user doing the deleting
     * @param targetUid The id for the user we're deleting
     */
    public static void deleteUser(User loggedInUser, Long targetUid) {
        if (!loggedInUser.hasRole(RoleFactory.ORG_ADMIN)) {
            //Throw an exception with a nice error message so the user
            //knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex =
                new PermissionException("Deleting a user requires an Org Admin.");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.deleteuser"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.deleteuser"));
            throw pex;
        }

        // Do not allow deletion of the last Satellite Administrator:
        User toDelete = UserFactory.lookupById(loggedInUser, targetUid);
        if (toDelete.hasRole(RoleFactory.SAT_ADMIN)) {
            if (SatManager.getActiveSatAdmins().size() == 1) {
                log.warn("Cannot delete the last Satellite Administrator");
                throw new DeleteSatAdminException(toDelete);
            }
        }

        CallableMode m = ModeFactory.getCallableMode("User_queries",
                "delete_user");
        Map inParams = new HashMap();
        Map outParams = new HashMap();
        inParams.put("user_id", targetUid);
        m.execute(inParams, outParams);
    }

    /**
     * Retrieve the specified user, assuming that the User making the request
     * has the required permissions.
     * @param user The user making the lookup request.
     * @param uid The id of the user to lookup.
     * @return the specified user.
     * @throws com.redhat.rhn.common.hibernate.LookupException if the User
     * can't be looked up.
     */
    public static User lookupUser(User user, Long uid) {
        User returnedUser = null;
        if (uid == null) {
            return null;
        }

        if (user.getId().equals(uid)) {
            return user;
        }
        LocalizationService ls = LocalizationService.getInstance();

        if (!user.hasRole(RoleFactory.ORG_ADMIN)) {
            //Throw an exception with a nice error message so the user
            //knows what went wrong.
            
            PermissionException pex =
                new PermissionException("Lookup user requires Org Admin");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.lookupuser"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.lookupuser"));
            throw pex;
        }

        returnedUser = UserFactory.lookupById(user, uid);
        return returnedUser;
    }

    /**
     * Retrieve the specified user, assuming that the User making the request
     * has the required permissions.
     * @param user The user making the lookup request
     * @param login The login of the user to lookup.
     * @return the specified user.
     */
    public static User lookupUser(User user, String login) {
        User returnedUser = null;
        if (login == null) {
            return null;
        }

        if (user.getLogin().equals(login)) {
            return user;
        }
        
        LocalizationService ls = LocalizationService.getInstance();

        if (!user.hasRole(RoleFactory.ORG_ADMIN)) {
            //Throw an exception with a nice error message so the user
            //knows what went wrong.
            PermissionException pex =
                new PermissionException("Lookup user requires Org Admin");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.lookupuser"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.lookupuser"));
            throw pex;
        }

        returnedUser = UserFactory.lookupByLogin(user, login);
        return returnedUser;
    }

    /**
     * Retrieve the list of all users in the specified user's org.
     * @param user The user who's org to search for users.
     * @return A list of users.
     */
    public static List<User> usersInOrg(User user) {
        if (!user.hasRole(RoleFactory.ORG_ADMIN)) {
            //Throw an exception with a nice error message so the user
            //knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException("User must be an" +
                    " Org Admin to access the user list");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.userlist"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.userlist"));
            throw pex;
        }
        return UserFactory.getInstance().findAllUsers(user.getOrg());
    }

    /**
     * Retrieve the list of all users in the specified user's org. Returns DataResult
     * containing the default objects specified in User_queries.xml
     * @param user The user who's org to search for users.
     * @param pc The details of which results to return.
     * @return A DataResult containing the specified number of users.
     */
    public static DataResult usersInOrg(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("User_queries", "users_in_org");
        return getUsersInOrg(user, pc, m);
    }
    
    /**
     * Retrieve the list of all users in the specified user's org. Returns DataResult
     * containing Map objects.
     * @param user The user who's org to search for users.
     * @param pc The details of which results to return.
     * @param clazz The class you want the returned DataResult to contain.
     * @return A DataResult containing the specified number of users.
     */
    public static DataResult usersInOrg(User user, PageControl pc, Class clazz) {
        SelectMode m = ModeFactory.getMode("User_queries", "users_in_org", clazz);
        return getUsersInOrg(user, pc, m);
    }

    /**
     * Helper method for usersInOrg* methods
     * @param user The user who's org to search for users.
     * @param pc The details of which results to return.
     * @param m The select mode.
     * @return A list containing the specified number of users.
     */
    private static DataResult getUsersInOrg(User user, PageControl pc, SelectMode m) {
        if (!user.hasRole(RoleFactory.ORG_ADMIN)) {
            //Throw an exception with a nice error message so the user
            //knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException("User must be an" +
                    " Org Admin to access the user list");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.userlist"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.userlist"));
            throw pex;
        }
        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        return makeDataResult(params, new HashMap(), pc, m);
    }

    /**
     * Retrieve the list of all active users in the specified user's org
     * @param user The user who's org to search for users.
     * @param pc The details of which results to return.
     * @return A list containing the specified number of users.
     */
    public static DataResult activeInOrg(User user, PageControl pc) {
        if (!user.hasRole(RoleFactory.ORG_ADMIN)) {
            //Throw an exception with a nice error message so the user
            //knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException("User must be an" +
                    " Org Admin to access the user list");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.userlist"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.userlist"));
            throw pex;
        }
        SelectMode m = ModeFactory.getMode("User_queries", "active_in_org");
        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        return  makeDataResult(params, new HashMap(), pc, m);
    }

    /**
     * Retrieve the list of all active users in the specified user's org
     * @param user The user who's org to search for users.
     * @return A list containing the specified number of users.
     */
    public static DataResult activeInOrg2(User user) {
        if (!user.hasRole(RoleFactory.ORG_ADMIN)) {
            //Throw an exception with a nice error message so the user
            //knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException("User must be an" +
                    " Org Admin to access the user list");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.userlist"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.userlist"));
            throw pex;
        }
        SelectMode m = ModeFactory.getMode("User_queries", "active_in_org");
        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        DataResult dr = m.execute(params);
        dr.elaborate(Collections.EMPTY_MAP);
        return dr;
    }

    /**
     * Retrieve the list of all disabled users in the specified user's org
     * @param user The user who's org to search for users.
     * @param pc The details of which results to return.
     * @return A list containing the specified number of users.
     */
    public static DataResult disabledInOrg(User user, PageControl pc) {
        if (!user.hasRole(RoleFactory.ORG_ADMIN)) {
            //Throw an exception with a nice error message so the user
            //knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException("User must be an" +
                    " Org Admin to access the user list");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.userlist"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.userlist"));
            throw pex;
        }
        SelectMode m = ModeFactory.getMode("User_queries", "disabled_in_org");
        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        return makeDataResult(params, new HashMap(), pc, m);
    }

    /**
     * Retrieve the list of Channels the user can subscribe to
     * @param user The user who's channels to search for.
     * @param pc The details of which results to return.
     * @return A list containing the specified number of channels.
     */
    public static DataResult channelSubscriptions(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("Channel_queries",
                                           "user_subscribe_perms");
        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());
        return makeDataResult(params, new HashMap(), pc, m);
    }

    /**
     * Retrieve the list of Channels the user can manage
     * @param user The user who's channels to search for.
     * @param pc The details of which results to return.
     * @return A list containing the specified number of channels.
     */
    public static DataResult channelManagement(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "user_manage_perms");
        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());
        return makeDataResult(params, new HashMap(), pc, m);
    }

    /**
     * Retrieve the list of systems visible to a particular user
     * @param user The user in question
     * @param pc The details of which results to return
     * @return A list containing the visible systems for the user
     */
    public static DataResult visibleSystems(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("System_queries", "visible_to_uid");
        Map params = new HashMap();
        params.put("formvar_uid", user.getId());
        if (pc != null) {
            return makeDataResult(params, params, pc, m);
        }
        DataResult dr = m.execute(params);
        dr.setTotalSize(dr.size());
        return dr;
    }

    /**
     * Generic visibleSystems that returns all systems visible to a
     * particular user.
     * @param user The user in question
     * @return A list containing the visible systems for the user
     */
    public static DataResult visibleSystems(User user) {
        return visibleSystems(user, null);
    }

    /**
     * Returns visible Systems as a SystemOverview Object
     * @param user the user we want
     * @return list of systems
     */
    public static List<SystemOverview> visibleSystemsAsDto(User user) {
        SelectMode m = ModeFactory.getMode("System_queries", "visible_to_user");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        DataResult<SystemOverview>  list = m.execute(params);
        list.elaborate();
        return list;
    }
    
    /**
     * Returns visible Systems as a SystemSearchResult Object
     * @param user the user we want
     * @param ids the list of desired system ids
     * @return DataResult of systems
     */
    public static DataResult<SystemSearchResult> visibleSystemsAsDtoFromList(User user,
            List<Long> ids) {

        SelectMode m = ModeFactory.getMode("System_queries",
            "visible_to_user_from_sysid_list");
        DataResult<SystemSearchResult> dr = null;
        
        int batchSize = 500;
        for (int batch = 0; batch < ids.size(); batch = batch + batchSize) {
            int toIndex = batch + batchSize;
            if (toIndex > ids.size()) {
                toIndex = ids.size();
            }
            Map params = new HashMap();
            params.put("user_id", user.getId());
            DataResult partial = m.execute(params, ids.subList(batch, toIndex));
            partial.setElaborationParams(Collections.EMPTY_MAP);
            if (dr == null) {
                dr = partial;
            }
            else {
                dr.addAll(partial);
            }
        }
        return dr;
    }

    /**
     * Returns visible System as a DataResult<SystemSearchResult> Object
     * @param user the user we want
     * @param id the system id to flesh out
     * @return DataResult
     */
    public static DataResult visibleSystemAsDtoFromId(User user,
            Long id) {

        SelectMode m = ModeFactory.getMode("System_queries",
                "visible_to_user_from_sysid");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("sysid", id);
        DataResult system = m.execute(params);
        system.elaborate();
        return system;
    }
    
    /**
     * Gets a list of systems visible to a user as maps
     * @param user The user in question
     * @return Returns a DataResult containing the results from
     * System_queries.xmlrpc_visible_to_user.
     */
    public static DataResult visibleSystemsAsMaps(User user) {
        SelectMode m = ModeFactory.getMode("System_queries", "xmlrpc_visible_to_user");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        return m.execute(params);
    }

    /**
     * Returns the users in the given set
     * @param user The user
     * @param label The name of the set
     * @param pc Page Control
     * @return completed DataResult
     */
    public static DataResult usersInSet(User user, String label, PageControl pc) {
        SelectMode m = ModeFactory.getMode("User_queries", "in_set");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("set_label", label);
        return makeDataResult(params, new HashMap(), pc, m);
    }

    /**
     * Returns the System Groups associated with the given User
     * bounded by the values of the PageControl.
     * @param user User whose SystemGroups are sought.
     * @param pc Bounding PageControl
     * @return The DataResult of the SystemGroups.
     */
    public static DataResult getSystemGroups(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("SystemGroup_queries",
                                           "user_permissions", SystemGroupOverview.class);
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        DataResult dr = m.execute(params);
        dr.setTotalSize(dr.size());
        if (pc != null && dr.size() > 0) {            
                dr = (DataResult)dr.subList(pc.getStart() - 1, pc.getEnd());
                dr.elaborate(new HashMap());
        }
        return dr;
    }

    /**
     * Gets a timezone object based on id
     * @param id timezone id number
     * @return the timezone requested
     */
    public static RhnTimeZone getTimeZone(int id) {
        return UserFactory.getTimeZone(id);
    }

    /**
     * Gets a timezone object based on olson name
     * @param olsonName timezone olson name
     * @return the timezone requested
     */
    public static RhnTimeZone getTimeZone(String olsonName) {
        return UserFactory.getTimeZone(olsonName);
    }

    /**
     * Gets the default timezone object
     * @return the default timezone object
     */
    public static RhnTimeZone getDefaultTimeZone() {
        return UserFactory.getDefaultTimeZone();
    }

    /**
     * Gets all timezone objects in the appropriate order
     * @return a list of ordered timezones
     */
    public static List lookupAllTimeZones() {
        return UserFactory.lookupAllTimeZones();
    }

    /**
     * Removes channel permissions from a user or nothing if they already have
     * no channel permissions.
     * @param user The user for which the perm is changing
     * @param cid The channel identifier
     * @param role The role the user is losing for this channel.
     */
    public static void removeChannelPerm(User user, Long cid, String role) {
        user.getOrg().removeChannelPermissions(user.getId(), cid, role);
    }

    /**
     * Adds channel permissions from a user.
     * Does nothing if the channel cannot be viewed by this user's org
     * @param user The user for which the perm is changing
     * @param cid The channel identifier
     * @param role The role the user is gaining for this channel.
     */
    public static void addChannelPerm(User user, Long cid, String role) {
        //first figure out if this channel is visible by the user's org
        boolean permittedAction = false;
        Iterator channels = user.getOrg().getAccessibleChannels().iterator();
        while (!permittedAction && channels.hasNext()) {
            if (((Channel)channels.next()).getId().equals(cid)) {
                permittedAction = true;
            }
        }

        //now perform the action
        if (permittedAction) {
            user.getOrg().resetChannelPermissions(user.getId(), cid, role);
        }
    }
    /**
     * Method to determine whether a satellite has any users. Returns
     * true if satellite has one or more users, false otherwise.  Also
     * returns false if this method is called on a hosted installation.
     * @return true if satellite has one or more users, false otherwise.
     */
    public static boolean satelliteHasUsers() {
        return UserFactory.satelliteHasUsers();
    }

    /**
     * Returns the responsible user (the first orgadmin in the org)
     * @param org Org to search
     * @param r Org_admin role
     * @see com.redhat.rhn.domain.role.RoleFactory#ORG_ADMIN
     * @return User with the login and id populated.
     */
    public static User findResponsibleUser(Org org, Role r) {
        return UserFactory.findResponsibleUser(org.getId(), r);
    }
    
    /**
     * Looks up the value of a user's server preference.
     * @param user user to lookup the preference
     * @param server server that the preference corresponds to
     * @param preferenceName the name of the preference
     * @see com.redhat.rhn.domain.user.UserServerPreferenceId
     * @return true if no value is present, false if the value is present and equal to 0
     * otherwise
     */
    public static boolean lookupUserServerPreferenceValue(User user,
                                                          Server server,
                                                          String preferenceName) {
        UserFactory factory = UserFactory.getInstance(); 
        UserServerPreference pref = factory. 
                                        lookupServerPreferenceByUserServerAndName(user, 
                                                                     server, 
                                                                     preferenceName);
        
        if (pref == null) {
            return true;
        }
        else {
            return !pref.getValue().equals("0");
        }
    }
    
    /**
     * Sets a UserServerPreference to true or false
     * @param user User whose preference will be set
     * @param server Server we are setting the perference on
     * @param preferenceName the name of the preference
     * @see com.redhat.rhn.domain.user.UserServerPreferenceId
     * @param value true if the preference should be true, false otherwise
     */
    public static void setUserServerPreferenceValue(User user,
                                                    Server server,
                                                    String preferenceName,
                                                    boolean value) {
        UserFactory.getInstance().
                setUserServerPreferenceValue(user, server, preferenceName, value);
    }
}
