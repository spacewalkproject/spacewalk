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
package com.redhat.rhn.frontend.xmlrpc.user;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.conf.UserDefaults;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.util.MethodUtil;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.role.Role;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.ServerGroupFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.DeleteUserException;
import com.redhat.rhn.frontend.xmlrpc.InvalidServerGroupException;
import com.redhat.rhn.frontend.xmlrpc.LookupServerGroupException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchRoleException;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.frontend.xmlrpc.UserNeverLoggedInException;
import com.redhat.rhn.frontend.xmlrpc.UserNotUpdatedException;
import com.redhat.rhn.manager.SatManager;
import com.redhat.rhn.manager.system.ServerGroupManager;
import com.redhat.rhn.manager.user.CreateUserCommand;
import com.redhat.rhn.manager.user.DeleteSatAdminException;
import com.redhat.rhn.manager.user.UpdateUserCommand;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.commons.lang.BooleanUtils;
import org.apache.commons.lang.RandomStringUtils;
import org.apache.commons.lang.StringUtils;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * UserHandler
 * Corresponds to User.pm in old perl code.
 * @version $Rev$
 * @xmlrpc.namespace user
 * @xmlrpc.doc User namespace contains methods to access common user functions
 * available from the web user interface.
 */
public class UserHandler extends BaseHandler {

    /**
     * Contains a mapping of details key as submitted by the call to the
     * {@link #setDetails(String, String, Map)} to the internal key used in the command
     * and domain objects. This is a band-aid to make the external API read correctly
     * (first_name instead of first_names) without having to refactor the entire code
     * base to use the singular version (for instance, User still uses first_names and
     * will be a significant change to refactor that). For more information, see
     * bugzilla 469957. 
     */
    private static final Map<String, String> USER_EDITABLE_DETAILS =
        new HashMap<String, String>();
    static {
        USER_EDITABLE_DETAILS.put("first_name", "first_names");
        USER_EDITABLE_DETAILS.put("first_names", "first_names");
        USER_EDITABLE_DETAILS.put("last_name", "last_name");
        USER_EDITABLE_DETAILS.put("email", "email");
        USER_EDITABLE_DETAILS.put("prefix", "prefix");
        USER_EDITABLE_DETAILS.put("password", "password");
    }
    
    /**
     * Lists the users in the org.
     * @param sessionKey The sessionkey for the session containing the logged in user.
     * @return Returns a list of userids and logins
     * @throws FaultException A FaultException is thrown if the loggedInUser
     * doesn't have permissions to list the users in their org.
     * 
     * @xmlrpc.doc Returns a list of users in your organization.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype
     * #array()
     *     $UserSerializer
     * #array_end()
     */
    public List listUsers(String sessionKey) throws FaultException {
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        try {
            List users = UserManager.usersInOrg(loggedInUser);
            return users;
        }
        catch (PermissionException e) {
            throw new PermissionCheckFailureException();
        }
    }
    
    /**
     * Lists the roles for a user
     * @param sessionKey The sessionkey for the session containing the logged in user.
     * @param login The login for the user you want to get the roles for
     * @return Returns a list of roles for the user specified by login
     * @throws FaultException A FaultException is thrown if the user doesn't have access
     * to lookup the user corresponding to login or if the user does not exist.
     * 
     * @xmlrpc.doc Returns a list of the user's roles.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "login", "User's login name.")
     * @xmlrpc.returntype #array_single("string", "(role label)")
     */
    public Object[] listRoles(String sessionKey, String login) throws FaultException {
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        User target = XmlRpcUserHelper.getInstance().lookupTargetUser(loggedInUser, login);
        List roles = new ArrayList(); //List of role labels to return
        
        //Loop through the target users roles and stick the labels into the ArrayList
        Set roleObjects = target.getRoles();
        for (Iterator itr = roleObjects.iterator(); itr.hasNext();) {
            Role r = (Role) itr.next();
            roles.add(r.getLabel());
        }
        
        return roles.toArray();
    }

    /**
     * Lists all the roles that can be assign by this user.
     * @param sessionKey The session key for the session containing the logged in user.
     * @return Returns a list of assignable roles for user 
     * @throws FaultException A FaultException is thrown if the logged doesn't have access.
     * 
     * @xmlrpc.doc Returns a list of user roles that this user can assign to others.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype #array_single("string", "(role label)")
     */
    public Set<String> listAssignableRoles(String sessionKey) {
        // Get the logged in user
        User user = getLoggedInUser(sessionKey);
        return getAssignableRoles(user);
    }
    
    /**
     * Gets details for a given user. These details include first names, last name, email,
     * prefix, last login date, and created on date.
     * @param sessionKey The sessionkey for the session containing the logged in user.
     * @param login The login for the user you want the details for
     * @return Returns a Map containing the details for the given user.
     * @throws FaultException A FaultException is thrown if the user doesn't have access
     * to lookup the user corresponding to login or if the user does not exist.
     * 
     * @xmlrpc.doc Returns the details about a given user.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "login", "User's login name.")
     * @xmlrpc.returntype
     *   #struct("user details")
     *     #prop_desc("string", "first_names", "deprecated, use first_name")
     *     #prop("string", "first_name")
     *     #prop("string", "last_name")
     *     #prop("string", "email")
     *     #prop("int", "org_id")
     *     #prop("string", "prefix")
     *     #prop("string", "last_login_date")
     *     #prop("string", "created_date")
     *     #prop_desc("boolean", "enabled", "true if user is enabled, 
     *     false if the user is disabled")
     *   #struct_end()
     */
    public Map getDetails(String sessionKey, String login) throws FaultException {
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        User target = XmlRpcUserHelper.getInstance().lookupTargetUser(loggedInUser, login);
        LocalizationService ls = LocalizationService.getInstance();
        
        Map ret = new HashMap();
        ret.put("first_names", StringUtils.defaultString(target.getFirstNames()));
        ret.put("first_name", StringUtils.defaultString(target.getFirstNames()));
        ret.put("last_name",   StringUtils.defaultString(target.getLastName()));
        ret.put("email",       StringUtils.defaultString(target.getEmail()));
        ret.put("prefix",      StringUtils.defaultString(target.getPrefix()));
        
        //Last login date
        String lastLoggedIn = target.getLastLoggedIn() == null ? 
                                  "" : ls.formatDate(target.getLastLoggedIn());
        ret.put("last_login_date", lastLoggedIn);
        
        //Created date
        String created = target.getCreated() == null ?
                                  "" : ls.formatDate(target.getCreated());
        ret.put("created_date", created);
        ret.put("org_id", loggedInUser.getOrg().getId());
        
        if (target.isDisabled()) {
            ret.put("enabled", Boolean.FALSE);
        }
        else {
            ret.put("enabled", Boolean.TRUE);
        }

        return ret;
    }
    
    /**
     * Sets the details for a given user. Settable details include: first names,
     * last name, email, prefix, and password.
     * @param sessionKey The sessionkey for the session containing the logged in
     * user.
     * @param login The login for the user you want to edit
     * @param details A map containing the new details values
     * @return Returns 1 if edit was successful, an error is thrown otherwise
     * @throws FaultException A FaultException is thrown if the user doesn't
     * have access to lookup the user corresponding to login or if the user
     * does not exist.
     * 
     * @xmlrpc.doc Updates the details of a user.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "login", "User's login name.")
     * @xmlrpc.param
     *   #struct("user details")
     *     #prop_desc("string", "first_names", "deprecated, use first_name")
     *     #prop("string", "first_name")
     *     #prop("string", "last_name")
     *     #prop("string", "email")
     *     #prop("string", "prefix")
     *     #prop("string", "password")
     *   #struct_end()
     * @xmlrpc.returntype #return_int_success()
     */
    public int setDetails(String sessionKey, String login, Map details) 
        throws FaultException {

        validateMap(USER_EDITABLE_DETAILS.keySet(), details);

        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        
        // Lookup user handles the logic for making sure that the loggedInUser
        // has access to the login they are trying to edit.
        User target = XmlRpcUserHelper.getInstance().lookupTargetUser(
                loggedInUser, login);
        
        UpdateUserCommand uuc = new UpdateUserCommand(target);
        
        // Process each entry passed in by the user
        for (Object userKey : details.keySet()) {
            
            // Check to make sure we have an internal key mapping to prevent issues
            // if the user passes in cruft
            String internalKey = USER_EDITABLE_DETAILS.get(userKey);
            if (internalKey != null) {
                String newValue = StringUtils.defaultString((String) details.get(userKey));
                prepareAttributeUpdate(internalKey, uuc, newValue);
            }
        }

        try {
            uuc.updateUser();
        }
        catch (IllegalArgumentException iae) {
            throw new UserNotUpdatedException(iae.getMessage());
        }

        // If we made it here without an exception, then we are a.o.k.
        return 1;
    }

    /**
     * Handles the vagaries related to granting or revoking sat admin role
     * @param loggedInUser the logged in user
     * @param login the login of the user who needs to be granted/revoked sat admin role
     * @param grant true if granting the role to the login, false for revoking...
     * @return 1 if it success.. Ofcourse error on failure..
     */
    private int  modifySatAdminRole(User loggedInUser, String login, boolean grant) {
        ensureUserRole(loggedInUser, RoleFactory.SAT_ADMIN);
        SatManager manager = SatManager.getInstance();
        User user = UserFactory.lookupByLogin(login);
        if (grant) {
            manager.grantSatAdminRoleTo(user, loggedInUser);    
        }
        else {
            manager.revokeSatAdminRoleFrom(user, loggedInUser);       
        }
        UserManager.storeUser(user);
        return 1;
    }

    /**
     * Returns all roles that are assignable to a given user 
     * @return all the role labels that are assignable to a user.
     */
    private Set<String> getAssignableRoles(User user) {
        Set <String> assignableRoles = new LinkedHashSet<String>();
        for (Role r : UserManager.listRolesAssignableBy(user)) {
            assignableRoles.add(r.getLabel());
        }        
        return assignableRoles;
    }
    
    /**
     * Validates that the select roles is among the ones we support.
     * @param role the role that user wanted to be assigned
     * @param user the logged in user who wants to assign the given role.
     */
    private void validateRoleInputs(String role, User user) {
        Set <String> assignableRoles = getAssignableRoles(user);
        if (!assignableRoles.contains(role)) {
            String msg = "Role with the label [%s] cannot be " +
                          "assigned/revoked from the user." +
                         " Possible Roles assignable/revokable by this user %s";
            
            throw new NoSuchRoleException(String.format(msg, role, 
                                                    assignableRoles.toString()));
        }        
    }
    
    /**
     * Adds a role to the given user
     * @param sessionKey The sessionkey for the session containing the logged in user.
     * @param login The login for the user you would like to add the role to
     * @param role The role you would like to give the user
     * @return Returns 1 if successful (exception otherwise)
     * @throws FaultException A FaultException is thrown if the user doesn't have access
     * to lookup the user corresponding to login or if the user does not exist.
     * 
     * @xmlrpc.doc Adds a role to a user.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "login", "User login name to update.")
     * @xmlrpc.param #param_desc("string", "role", "Role label to add.  Can be any of: 
     * satellite_admin, org_admin, channel_admin, config_admin, system_group_admin, 
     * activation_key_admin, or monitoring_admin.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int addRole(String sessionKey, String login, String role) throws FaultException {
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        validateRoleInputs(role, loggedInUser);
        if (RoleFactory.SAT_ADMIN.getLabel().equals(role)) {
            return modifySatAdminRole(loggedInUser, login, true);
        }
        User target = XmlRpcUserHelper.getInstance().lookupTargetUser(loggedInUser, login);
        // Retrieve the role object corresponding to the role label passed in and
        // add to user
        Role r = RoleFactory.lookupByLabel(role);
        target.addRole(r);
        UserManager.storeUser(target);
        return 1;
    }

    
    /**
     * Removes a role from the given user
     * @param sessionKey The sessionkey for the session containing the logged in user.
     * @param login The login for the user you would like to remove the role from
     * @param role The role you would like to remove from the user
     * @return Returns 1 if successful (exception otherwise)
     * @throws FaultException A FaultException is thrown if the user doesn't have access
     * to lookup the user corresponding to login or if the user does not exist.
     * 
     * @xmlrpc.doc Remove a role from a user.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "login", "User login name to update.")
     * @xmlrpc.param #param_desc("string", "role", "Role label to remove.  Can be any of: 
     * satellite_admin, org_admin, channel_admin, config_admin, system_group_admin, 
     * activation_key_admin, or monitoring_admin.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int removeRole(String sessionKey, String login, String role) 
        throws FaultException {
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        validateRoleInputs(role, loggedInUser);
        
        if (RoleFactory.SAT_ADMIN.getLabel().equals(role)) {
            return modifySatAdminRole(loggedInUser, login, false);
        }
        
        ensureOrgAdmin(loggedInUser);
        User target = XmlRpcUserHelper.getInstance().lookupTargetUser(loggedInUser, login);
                
        /*
         * Perform some error checking here... we need to make sure that this
         * isn't the last org_admin in the org trying to remove org_admin 
         * status from himself.
         */
        if (role.equals(RoleFactory.ORG_ADMIN.getLabel()) &&
            target.hasRole(RoleFactory.ORG_ADMIN) &&
            target.getOrg().numActiveOrgAdmins() <= 1) {
                throw new PermissionCheckFailureException();
        }
        
        // Retrieve the role object corresponding to the role label passed in and
        // remove from user
        Role r = RoleFactory.lookupByLabel(role);
        target.removeRole(r);
        
        UserManager.storeUser(target);
        return 1;
    }
    
    /**
     * Creates a new user
     * @param sessionKey The sessionKey for the session containing the logged in user
     * @param desiredLogin The login for the new user
     * @param desiredPassword The password for the new user
     * @param firstName The first name of the new user
     * @param lastName The last name of the new user
     * @param email The email address for the new user
     * @return Returns 1 if successful (exception otherwise)
     * @throws FaultException A FaultException is thrown if the loggedInUser doesn't have
     * permissions to create new users in thier org.
     * 
     * @xmlrpc.doc Create a new user.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "desiredLogin", "Desired login name, will fail if
     * already in use.")
     * @xmlrpc.param #param("string", "desiredPassword")
     * @xmlrpc.param #param("string", "firstName")
     * @xmlrpc.param #param("string", "lastName")
     * @xmlrpc.param #param_desc("string", "email", "User's e-mail address.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int create(String sessionKey, String desiredLogin, String desiredPassword, 
                   String firstName, String lastName, String email) throws FaultException {

        // If we didn't get a value for pamAuth, default to no
        return create(sessionKey, desiredLogin, desiredPassword, firstName, lastName,
                      email, new Integer(0));
    }

    /**
     * Creates a new user
     * @param sessionKey The sessionKey for hte session containing the logged in user
     * @param desiredLogin The login for the new user
     * @param desiredPassword The password for the new user
     * @param firstName The first name of the new user
     * @param lastName The last name of the new user
     * @param email The email address for the new user
     * @param usePamAuth Should this user authenticate via PAM?
     * @return Returns 1 if successful (exception otherwise)
     * @throws FaultException A FaultException is thrown if the loggedInUser doesn't have
     * permissions to create new users in thier org.
     * 
     * @xmlrpc.doc Create a new user.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "desiredLogin", "Desired login name, 
     * will fail if already in use.")
     * @xmlrpc.param #param("string", "desiredPassword")
     * @xmlrpc.param #param("string", "firstName")
     * @xmlrpc.param #param("string", "lastName")
     * @xmlrpc.param #param_desc("string", "email", "User's e-mail address.")
     * @xmlrpc.param #param_desc("int", "usePamAuth", "1 if you wish to use PAM 
     * authentication for this user, 0 otherwise.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int create(String sessionKey, String desiredLogin, String desiredPassword,
                      String firstName, String lastName, String email, Integer usePamAuth) 
                      throws FaultException {
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        //Logged in user must be an org admin and we must be on a sat to do this.
        ensureOrgAdmin(loggedInUser);
        ensurePasswordOrPamAuth(usePamAuth, desiredPassword);

        boolean pamAuth = BooleanUtils.toBoolean(
                usePamAuth, new Integer(1), new Integer(0));
            
        if (pamAuth) {
            desiredPassword = getDefaultPasswordForPamAuth();
        }
        
        CreateUserCommand command = new CreateUserCommand();
        command.setUsePamAuthentication(pamAuth);
        command.setLogin(desiredLogin);
        command.setPassword(desiredPassword);
        command.setFirstNames(firstName);
        command.setLastName(lastName);
        command.setEmail(email);
        command.setOrg(loggedInUser.getOrg());
        command.setCompany(loggedInUser.getCompany());
                                                                            
        //Validate the user to be
        ValidatorError[] errors = command.validate();
        if (errors.length > 0) {
            StringBuffer errorString = new StringBuffer();
            LocalizationService ls = LocalizationService.getInstance();
            //Build a sane error message here
            for (int i = 0; i < errors.length; i++) {
                ValidatorError err = errors[i];
                errorString.append(ls.getMessage(err.getKey(), err.getValues()));
                if (i != errors.length - 1) {
                    errorString.append(" :: ");
                }
            }
            //Throw a BadParameterException with our message string
            throw new BadParameterException(errorString.toString());
        }

        command.storeNewUser();
        return 1;
    }
    
    /**
     * Deletes a user
     * @param sessionKey The sessionKey for the session containing the logged in user.
     * @param login The login for the user you would like to delete
     * @return Returns 1 if successful (exception otherwise)
     * @throws FaultException A FaultException is thrown if the user doesn't have access
     * to lookup the user corresponding to login or if the user does not exist.
     * 
     * @xmlrpc.doc Delete a user.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "login", "User login name to delete.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int delete(String sessionKey, String login) throws FaultException {
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        ensureOrgAdmin(loggedInUser);
        User target = XmlRpcUserHelper.getInstance().lookupTargetUser(loggedInUser, login);

        try {
            UserManager.deleteUser(loggedInUser, target.getId());
        }
        catch (DeleteSatAdminException e) {
            throw new DeleteUserException("user.cannot.delete.last.sat.admin");
        }
        
        return 1;
    }
    
    /**
     * Disable a user
     * @param sessionKey The sessionKey for the session containing the logged in user.
     * @param login The login for the user you would like to disable
     * @return Returns 1 if successful (exception otherwise)
     * @throws FaultException A FaultException is thrown if the user doesn't have access
     * to lookup the user corresponding to login or if the user does not exist.
     * 
     * @xmlrpc.doc Disable a user.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "login", "User login name to disable.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int disable(String sessionKey, String login) throws FaultException {
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        ensureOrgAdmin(loggedInUser);
        
        User target = XmlRpcUserHelper.getInstance().lookupTargetUser(loggedInUser, login);
        UserManager.disableUser(loggedInUser, target);
        
        return 1;
    }
    
    /**
     * Enable a user
     * @param sessionKey The sessionKey for the session containing the logged in user
     * @param login The login for the user you would like to enable
     * @return Returns 1 if successful (exception otherwise)
     * @throws FaultException A FaultException is thrown if the user doesn't have access
     * to lookup the user corresponding to login or if the user does not exist.
     * 
     * @xmlrpc.doc Enable a user.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "login", "User login name to enable.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int enable(String sessionKey, String login) throws FaultException {
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        ensureOrgAdmin(loggedInUser);
        
        User target = XmlRpcUserHelper.getInstance().lookupTargetUser(loggedInUser, login);
        UserManager.enableUser(loggedInUser, target);
        
        return 1;
    }
    
    /**
     * Toggles whether or not a user users pamAuthentication or the basic RHN db auth.
     * @param sessionKey The sessionkey for the session containing the logged in user.
     * @param login The login for the user you would like to change
     * @param val The value you would like to set this to (1 = true, 0 = false)
     * @return Returns 1 if successful (exception otherwise)
     * @throws FaultException A FaultException is thrown if the user doesn't have access
     * to lookup the user corresponding to login or if the user does not exist.
     * 
     * @xmlrpc.doc Toggles whether or not a user uses PAM authentication or 
     * basic RHN authentication.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "login", "User's login name.")
     * @xmlrpc.param #param("int", "pam_value")
     *   #options()
     *     #item("1 to enable PAM authentication")
     *     #item("0 to disable.")
     *   #options_end()
     * @xmlrpc.returntype #return_int_success()
     */
    public int usePamAuthentication(String sessionKey, String login, Integer val) 
        throws FaultException {
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        // Only org admins can use this method.
        ensureOrgAdmin(loggedInUser);
        User target = XmlRpcUserHelper.getInstance().lookupTargetUser(loggedInUser, login);

        if (val.equals(new Integer(1))) {
            target.setUsePamAuthentication(true);
        }
        else {
            target.setUsePamAuthentication(false);
        }
        
        UserManager.storeUser(target);
        
        return 1;
    }
    
   
    private void ensurePasswordOrPamAuth(Integer usePamAuth, String password)
        throws FaultException {
        if (!BooleanUtils.toBoolean(usePamAuth, new Integer(1), new Integer(0)) &&
                StringUtils.isEmpty(password)) {
            throw new FaultException(-501, "passwordRequiredOrUsePam", 
                    "Password is required if not using PAM authentication");
        }
    }
    
    private String getDefaultPasswordForPamAuth() {
        // taken from line 169 of CreateUserAction
        // this is utter crap.  We don't require a password when
        // we set use pam authentication, yet the password field
        // in the database is NOT NULL.  So we have to create this
        // stupid HACK!  Actually this is beyond HACK.
        return RandomStringUtils.random(UserDefaults.get().getMinPasswordLength());
        
    }
    
    private void prepareAttributeUpdate(String attrName, UpdateUserCommand cmd, 
            String value) {
        String methodName = StringUtil.beanify("set_" + attrName);
        Object[] params = {value};
        MethodUtil.callMethod(cmd, methodName, params);
    }
    
    /**
     * Add ServerGroup to the list of Default System groups. The ServerGroup
     * <strong>MUST</strong> exist otherwise a IllegalArgumentException is
     * thrown.
     * @param sessionKey The sessionKey for the session containing the logged
     * in user.
     * @param login The login for the user whose Default ServerGroup list will
     * be affected.
     * @param name name of ServerGroup.
     * @return Returns 1 if successful (exception otherwise)
     * 
     * @xmlrpc.doc Add system group to user's list of default system groups.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "login", "User's login name.")
     * @xmlrpc.param #param("string", "serverGroupName")
     * @xmlrpc.returntype #return_int_success()
     */
    public int addDefaultSystemGroup(String sessionKey, String login, String name) {
        List<String> ids = new LinkedList<String>();
        ids.add(name);
        return addDefaultSystemGroups(sessionKey, login, ids);
    }

    /**
     * Add ServerGroups to the list of Default System groups. The ServerGroups
     * <strong>MUST</strong> exist otherwise a IllegalArgumentException is
     * thrown.
     * @param sessionKey The sessionKey for the session containing the logged
     * in user.
     * @param login The login for the user whose Default ServerGroup list will
     * be affected.
     * @param sgNames names of ServerGroups.
     * @return Returns 1 if successful (exception otherwise)
     * 
     * @xmlrpc.doc Add system groups to user's list of default system groups.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "login", "User's login name.")
     * @xmlrpc.param #array_single("string", "serverGroupName")
     * @xmlrpc.returntype #return_int_success()
     */
    public int addDefaultSystemGroups(String sessionKey, String login, List sgNames) {

        
        User loggedInUser = getLoggedInUser(sessionKey);
        User target = XmlRpcUserHelper.getInstance().lookupTargetUser(
                loggedInUser, login);
        
        if (sgNames == null || sgNames.size() < 1) {
            throw new IllegalArgumentException("no servergroup names supplied");
        }
        
        List groups = ServerGroupFactory.listManagedGroups(target.getOrg());
        
        Map groupMap = new HashMap();       
        
        // sigh.  After looking through all of the apache collections package
        // I couldn't find anything that would create a map from a list using
        // a property from the object in the list as the key. This is where
        // python would be useful.
        for (Iterator itr = groups.iterator(); itr.hasNext();) {
            ServerGroup sg = (ServerGroup) itr.next();
            groupMap.put(sg.getName(), sg);
        }
        
        // Doing full check of all supplied names, if one is bad 
        // throw an exception, prior to altering the DefaultSystemGroup Set.
        for (Iterator itr = sgNames.iterator(); itr.hasNext();) {
            String name = (String)itr.next();
            ServerGroup sg = (ServerGroup) groupMap.get(name);
            if (sg == null) {
                throw new LookupServerGroupException(name);
            }
        }
        
        // now for the real reason we're in this method.
        Set defaults = target.getDefaultSystemGroupIds();
        for (Iterator itr = sgNames.iterator(); itr.hasNext();) {
            ServerGroup sg = (ServerGroup) groupMap.get((String)itr.next());
            if (sg != null) {
                // not a simple add to the groups.  Needs to call
                // UserManager as DataSource is being used.
                defaults.add(sg.getId());
            }
        }
        
        UserManager.setDefaultSystemGroupIds(target, defaults);
        UserManager.storeUser(target);
        
        return 1;
    }
    
    /**
     * Remove ServerGroup from the list of Default System groups. The
     * ServerGroup <strong>MUST</strong> exist otherwise a
     * IllegalArgumentException is thrown.
     * @param sessionKey The sessionKey for the session containing the logged
     * in user.
     * @param login The login for the user whose Default ServerGroup list will
     * be affected.
     * @param sgName Name of ServerGroup.
     * @return Returns 1 if successful (exception otherwise)
     * 
     * @xmlrpc.doc Remove a system group from user's list of default system groups.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "login", "User's login name.")
     * @xmlrpc.param #param("string", "serverGroupName")
     * @xmlrpc.returntype #return_int_success()
     */
    public int removeDefaultSystemGroup(String sessionKey, String login, String sgName) {
        List<String> names = new LinkedList<String>();
        names.add(sgName);
        return removeDefaultSystemGroups(sessionKey, login, names);
    }
    
    /**
     * Remove ServerGroups from the list of Default System groups. The
     * ServerGroups <strong>MUST</strong> exist otherwise a
     * IllegalArgumentException is thrown.
     * @param sessionKey The sessionKey for the session containing the logged
     * in user.
     * @param login The login for the user whose Default ServerGroup list will
     * be affected.
     * @param sgNames Names of ServerGroups.
     * @return Returns 1 if successful (exception otherwise)
     * 
     * @xmlrpc.doc Remove system groups from a user's list of default system groups.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "login", "User's login name.")
     * @xmlrpc.param #array_single("string", "serverGroupName")
     * @xmlrpc.returntype #return_int_success()
     */
    public int removeDefaultSystemGroups(String sessionKey, String login, List sgNames) {

        
        User loggedInUser = getLoggedInUser(sessionKey);        
        User target = XmlRpcUserHelper.getInstance().lookupTargetUser(
                loggedInUser, login);
        
        if (sgNames == null || sgNames.size() < 1) {
            throw new IllegalArgumentException("no servergroup names supplied");
        }
        
        List groups = ServerGroupFactory.listManagedGroups(target.getOrg());
        Map groupMap = new HashMap();

        // sigh.  After looking through all of the apache collections package
        // I couldn't find anything that would create a map from a list using
        // a property from the object in the list as the key. This is where
        // python would be useful.
        for (Iterator itr = groups.iterator(); itr.hasNext();) {
            ServerGroup sg = (ServerGroup) itr.next();
            groupMap.put(sg.getName(), sg);
        }
        
        // Doing full check of all supplied names, if one is bad 
        // throw an exception, prior to altering the DefaultSystemGroup Set.
        for (Iterator itr = sgNames.iterator(); itr.hasNext();) {
            String name = (String)itr.next();
            ServerGroup sg = (ServerGroup) groupMap.get(name);
            if (sg == null) {
                throw new LookupServerGroupException(name);
            }
        }
        
        // now for the real reason we're in this method.
        Set defaults = target.getDefaultSystemGroupIds();
        for (Iterator itr = sgNames.iterator(); itr.hasNext();) {
            ServerGroup sg = (ServerGroup) groupMap.get((String) itr.next());
            if (sg != null) {
                // not a simple remove to the groups.  Needs to call
                // UserManager as DataSource is being used.
                defaults.remove(sg.getId());
            }
        }
        
        UserManager.setDefaultSystemGroupIds(target, defaults);
        UserManager.storeUser(target);
        
        return 1;
    }
    
    /**
     * Returns default system groups for the given login.
     * @param sessionKey The sessionKey for the session containing the logged
     * in user.
     * @param login The login for the user whose Default ServerGroup list is
     * sought.
     * @return default system groups for the given login
     * 
     * @xmlrpc.doc Returns a user's list of default system groups.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "login", "User's login name.")
     * @xmlrpc.returntype
     *   #array()
     *     #struct("system group")
     *       #prop("int", "id")
     *       #prop("string", "name")
     *       #prop("string", "description")
     *       #prop("int", "system_count")
     *       #prop_desc("int", "org_id", "Organization ID for this system group.")
     *     #struct_end()
     *   #array_end()
     */
    public Object[] listDefaultSystemGroups(String sessionKey, String login) {
        User loggedInUser = getLoggedInUser(sessionKey);
        User target = XmlRpcUserHelper.getInstance().lookupTargetUser(
                loggedInUser, login);
        Set<Long> ids =  target.getDefaultSystemGroupIds();
        
        
        List <ServerGroup> sgs = new ArrayList(ids.size());
        for (Long id : ids) {
            sgs.add(ServerGroupFactory.lookupByIdAndOrg(id, target.getOrg()));
        }
        return sgs.toArray();
    }

    /**
     * Returns the ServerGroups that the user can administer.
     * @param sessionKey The sessionKey for the session containing the logged
     * in user.
     * @param login The login for the user whose ServerGroups are sought.
     * @return the ServerGroups that the user can administer.
     * @throws FaultException A FaultException is thrown if the user doesn't
     * have access to lookup the user corresponding to login or if the user
     * does not exist.
     * 
     * @xmlrpc.doc Returns the system groups that a user can administer.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "login", "User's login name.")
     * @xmlrpc.returntype
     *   #array()
     *     #struct("system group")
     *       #prop("int", "id")
     *       #prop("string", "name")
     *       #prop("string", "description")
     *       #prop("int", "system_count")
     *       #prop_desc("int", "org_id", "Organization ID for this system group.")
     *     #struct_end()
     *   #array_end()
     */
    public Object[] listAssignedSystemGroups(String sessionKey, String login)
        throws FaultException {

        User loggedInUser = getLoggedInUser(sessionKey);
        User target = XmlRpcUserHelper.getInstance().lookupTargetUser(
                    loggedInUser, login);
        List groups = ServerGroupFactory.listAdministeredServerGroups(target);
        return groups.toArray();
    }
    
    /**
     * Returns the last logged in time of the given user.
     * @param sessionKey The sessionKey for the session containing the logged
     * in user.
     * @param login The login of the user.
     * @return last logged in time
     * @throws UserNeverLoggedInException if the given user has never logged in.
     * 
     * @xmlrpc.doc Returns the time user last logged in.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "login", "User's login name.")
     * @xmlrpc.returntype dateTime.iso8601
     */
    public Date getLoggedInTime(String sessionKey, String login)
        throws UserNeverLoggedInException {

        User loggedInUser = getLoggedInUser(sessionKey);
        User target = XmlRpcUserHelper.getInstance().lookupTargetUser(
                    loggedInUser, login);
        Date d = target.getLastLoggedIn();
        if (d != null) {
            return d;
        }
        else {
            throw new UserNeverLoggedInException();
        }
    }

    
    
    /**
     * remove system group association from a user
     * @param sessionKey The sessionKey
     * @param login the user's login that we want to remove the association from 
     * @param systemGroupNames list of system group names to remove
     * @param setDefault if true the default group will be removed from the users's 
     *      group defaults
     * @return 1 on success
     * 
     * @xmlrpc.doc Remove system groups from a user's list of assigned system groups.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "login", "User's login name.")
     * @xmlrpc.param #array_single("string", "serverGroupName")
     * @xmlrpc.param #param_desc("boolean", "setDefault", "Should system groups also be 
     * removed from the user's list of default system groups.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int removeAssignedSystemGroups(String sessionKey, 
            String login, List<String> systemGroupNames, Boolean setDefault) {
        User loggedInUser = getLoggedInUser(sessionKey);
        ensureUserRole(loggedInUser, RoleFactory.ORG_ADMIN);
        
        if (setDefault) {
            removeDefaultSystemGroups(sessionKey, login, systemGroupNames); 
         }
        
        User user = UserManager.lookupUser(loggedInUser, login);
        ServerGroupManager manager = ServerGroupManager.getInstance();        
        
        // Iterate once to lookup the server groups and avoid removing some when
        // an exception will only be thrown later:
        List<ManagedServerGroup> groups = new LinkedList<ManagedServerGroup>();
        for (String name : systemGroupNames) {
            ManagedServerGroup sg = null;
            try {
                sg = manager.lookup(name, user);
            }
            catch (LookupException e) {
                throw new InvalidServerGroupException();
            }
            groups.add(sg);
        }

        for (ManagedServerGroup sg : groups) {
            UserManager.revokeServerGroupPermission(user, sg.getId().longValue());
        }

        return 1;
    }
    
    /**
     * remove system group association from a user
     * @param sessionKey The sessionKey
     * @param login the user's login that we want to remove the association from 
     * @param systemGroupName  system group name to remove
     * @param setDefault if true the default group will be removed from the users's 
     *      group defaults
     * @return 1 on success
     * 
     * @xmlrpc.doc Remove system group from the user's list of assigned system groups.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "login", "User's login name.")
     * @xmlrpc.param #param("string", "serverGroupName")
     * @xmlrpc.param #param_desc("boolean", "setDefault", "Should system group also 
     * be removed from the user's list of default system groups.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int removeAssignedSystemGroup(String sessionKey, 
            String login, String systemGroupName, Boolean setDefault) {
            List groups = new ArrayList();
            groups.add(systemGroupName);
            return removeAssignedSystemGroups(sessionKey, login, groups, setDefault);
    }
    
    

    /**
     * Add to the user's list of assigned system groups.
     *
     * @param sessionKey User's session key.
     * @param login User to modify.
     * @param sgName Server group Name.
     * @param setDefault True to also add group to the user's default system groups.
     * @return Returns 1 if successful (exception thrown otherwise)
     * 
     * @xmlrpc.doc Add system group to user's list of assigned system groups.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "login", "User's login name.")
     * @xmlrpc.param #param("string", "serverGroupName")
     * @xmlrpc.param #param_desc("boolean", "setDefault", "Should system group also be 
     * added to user's list of default system groups.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int addAssignedSystemGroup(String sessionKey, String login, String sgName,
            Boolean setDefault) {
        List<String> names = new LinkedList<String>();
        names.add(sgName);
        return addAssignedSystemGroups(sessionKey, login, names, setDefault);
    }

    /**
     * Add to the user's list of assigned system groups.
     *
     * @param sessionKey User's session key.
     * @param login User to modify.
     * @param sgNames List of server group Names.
     * @param setDefault True to also add groups to the user's default system groups.
     * @return Returns 1 if successful (exception thrown otherwise)
     * 
     * @xmlrpc.doc Add system groups to user's list of assigned system groups.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "login", "User's login name.")
     * @xmlrpc.param #array_single("string", "serverGroupName")
     * @xmlrpc.param #param_desc("boolean", "setDefault", "Should system groups also be 
     * added to user's list of default system groups.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int addAssignedSystemGroups(String sessionKey, String login, List sgNames,
            Boolean setDefault) {
        
        User loggedInUser = getLoggedInUser(sessionKey);
        User targetUser = XmlRpcUserHelper.getInstance().lookupTargetUser(
                loggedInUser, login);

        if (sgNames == null || sgNames.size() < 1) {
            throw new IllegalArgumentException("no servergroup names supplied");
        }
        

        // Iterate once just to make sure all the server groups exist. Done to
        // prevent adding a bunch of valid groups and then throwing an exception
        // when coming across one that doesn't exist.
        List<ManagedServerGroup> groups = new LinkedList<ManagedServerGroup>();
        for (Iterator it = sgNames.iterator(); it.hasNext();) {
            String serverGroupName =  (String)it.next();

            // Make sure the server group exists:
            ServerGroupManager manager = ServerGroupManager.getInstance();
            ManagedServerGroup group;
            try {
                group = manager.lookup(serverGroupName, loggedInUser);
            }
            catch (LookupException e) {
                throw new InvalidServerGroupException();
            }
            groups.add(group);
        }

        // Now do the actual add:
        for (ManagedServerGroup group : groups) {
            UserManager.grantServerGroupPermission(targetUser, group.getId());
        }

        // Follow up with a call to addDefaultSystemGroups if setDefault is true:
        if (setDefault.booleanValue()) {
            addDefaultSystemGroups(sessionKey, login, sgNames);
        }

        return 1;
    }
}
