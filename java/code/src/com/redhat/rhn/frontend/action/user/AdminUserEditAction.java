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
package com.redhat.rhn.frontend.action.user;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.role.Role;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.system.ServerGroupManager;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * UserEditSubmitAction, edit action submit handler for user detail page
 * @version $Rev: 1196 $
 */
public class AdminUserEditAction extends UserEditActionHelper {
    
    private static Logger log = Logger.getLogger(AdminUserEditAction.class);
    private static final String ROLE_SETTING_PREFIX = "role_";
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        DynaActionForm form = (DynaActionForm)formIn;
                
        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        
        //We could be editing ourself, we could be editing another user...
        User targetUser = UserManager.lookupUser(requestContext.getLoggedInUser(), 
                                           requestContext.getParamAsLong("uid"));
        request.setAttribute(RhnHelper.TARGET_USER, targetUser);
        
        //Make sure we got a user, if not, we must have gotten a bad uid
        if (targetUser == null) {
            throw new BadParameterException("Invalid uid, targetUser not found");
        }
        User loggedInUser = requestContext.getLoggedInUser();
        
        //Update the users details with info entered on the form
        ActionErrors errors = updateDetails(targetUser, form);
        //If we have validation/form errors, return now and let the user fix those first
        if (!errors.isEmpty()) {
            return returnFailure(mapping, request, errors, targetUser.getId());
        }
        
        /*
         * Update PAM Authentication attribute
         * If we're a satellite that is configured to use pam and the loggedIn user is an
         * org_admin (and therefore the checkbox was displayed), we need to inspect the 
         * "usepam" field on the form and set the targetUser's pam auth attribute 
         * accordingly. (we don't want to set this field if it wasn't displayed or if the
         * user doesn't have access to set this attribute)
         */
        String pamAuthService = Config.get().getString(ConfigDefaults.WEB_PAM_AUTH_SERVICE);
        if (pamAuthService != null && 
                pamAuthService.trim().length() > 0 && 
                loggedInUser.hasRole(RoleFactory.ORG_ADMIN)) {
            if (form.get("usepam") != null && 
                    ((Boolean) form.get("usepam")).booleanValue()) {
                targetUser.setUsePamAuthentication(true);
            }
            else {
                targetUser.setUsePamAuthentication(false);
            }
        }
        
        //Create the user info updated success message
        createSuccessMessage(request, "message.userInfoUpdated", null); 
        
        //Now we need to update user roles. If we get errors here, return failure
        errors = updateRoles(request, targetUser, loggedInUser);
        if (!errors.isEmpty()) {
            return returnFailure(mapping, request, errors, targetUser.getId());
        }
        
        //Everything must have gone smoothly
        UserManager.storeUser(targetUser);

        ActionForward dest = mapping.findForward("success");
        /*
         * Does the user still have the roles needed to see /users/UserDetails.do?
         * Check here and make a decision so user doesn't go to a permission error page.
         */
        //If the logged in user is the same as the target user and we have removed the
        //target users org admin status, forward to noaccess instead
        if (loggedInUser.equals(targetUser) &&
            !targetUser.hasRole(RoleFactory.ORG_ADMIN)) {
            dest = mapping.findForward("noaccess");
        }
        
        return strutsDelegate.forwardParam(dest, "uid", String.valueOf(targetUser.getId()));
    }
    
    /**
     * Private helper method to save errors to the request and forward to the 
     * failure mapping
     */
    private ActionForward returnFailure(ActionMapping mapping, 
                                        HttpServletRequest request, 
                                        ActionErrors errors,
                                        Long uid) {
        addErrors(request, errors);
        return getStrutsDelegate().forwardParam(mapping.findForward("failure"), "uid",
                                      String.valueOf(uid));
    }
    
    /**
     * Private helper method to handle getting the new roles from the form and calling
     * UserManager.updateUserRolesFromRoleLabels().
     * @param form The form containing selectedRoles. selectedRoles are the new set of 
     *             roles to associate with the user.
     * @param targetUser The user who is having their roles updated.
     * @return Returns an ActionErrors object containing any errors that occurred while
     *         updating the users roles
     */
    private ActionErrors updateRoles(HttpServletRequest request,
                                        User targetUser,
                                        User loggedInUser) {
        log.debug(this.getClass().getName() + ".updateRoles()");
        
        Set<String> disabledRoles = extractDisabledRoles(request);
        
        ActionErrors errors = new ActionErrors();
        Org org = targetUser.getOrg();
        Set<Role> orgRoles = org.getRoles();
        
        // Build a set of the users current role labels to help determine what we need
        // to add and remove:
        Set<String> existingRoles = new HashSet<String>();
        for (Role r : targetUser.getRoles()) {
            existingRoles.add(r.getLabel());
        }
        
        // Look for an add/remove setting for each org role in the form:
        List<String> rolesToAdd = new LinkedList<String>();
        List<String> rolesToRemove = new LinkedList<String>();
        for (Role role : orgRoles) {
            
            if (disabledRoles.contains(role.getLabel())) {
                // Role was disabled when we built this form, so skip:
                continue;
            }
            
            String roleSetting = request.getParameter(ROLE_SETTING_PREFIX + 
                    role.getLabel());
            log.debug("   " + role.getName() + " / " + roleSetting);
            
            if (roleSetting != null && !existingRoles.contains(role.getLabel())) {
                // Must have been newly checked:
                rolesToAdd.add(role.getLabel());
            }
            else if (roleSetting == null && existingRoles.contains(role.getLabel())) {
                // Must have been newly unchecked:
                rolesToRemove.add(role.getLabel());
            }
        }

        try {
            UserManager.addRemoveUserRoles(targetUser, rolesToAdd, 
                    rolesToRemove);
            
            //if he is an org amin make sure he does NOT
            // have any subscribed Server Groups, because
            // by becoming an org admin he is automatically
            // subscribed to every group... and so his list 
            // will be empty.. 
            if (targetUser.hasRole(RoleFactory.ORG_ADMIN) && 
                    !targetUser.getAssociatedServerGroups().isEmpty()) {
                ServerGroupManager manager = ServerGroupManager.getInstance();
                Set admins = new HashSet();
                admins.add(targetUser);
                for (Iterator itr = targetUser.getAssociatedServerGroups().iterator(); 
                        itr.hasNext();) {
                    
                    ManagedServerGroup sg = (ManagedServerGroup) itr.next();
                    manager.dissociateAdmins(sg, admins, loggedInUser);
                    itr.remove();
                }
            }
        }
        catch (PermissionException pe) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("userdetails.jsp.error.lastorgadmin"));
        }

        return errors;
    }
    
    private Set<String> extractDisabledRoles(HttpServletRequest request) {
        String hiddenInput = request.getParameter("disabledRoles");
        Set<String> returnVal = new HashSet<String>(
                Arrays.asList(hiddenInput.split("\\|")));
        log.debug("Found disabled inputs: " + returnVal);
        return returnVal;
    }
}
