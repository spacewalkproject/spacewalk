/**
 * Copyright (c) 2009--2011 Red Hat, Inc.
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

import java.util.regex.Pattern;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.conf.UserDefaults;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

/**
 * UserEditSubmitAction, edit action submit handler for user detail page
 * @version $Rev: 1196 $
 */
public abstract class UserEditActionHelper extends RhnAction {

    /**
     * This method handles the common tasks between SelfEditAction and AdminUserEditAction.
     * @param loggedInUser logged in user
     * @param targetUser The user to operate on
     * @param form The form we're grabbing the info from
     * @return Returns an ActionErrors object containing the errors (if any) that occurred.
     */
    public ActionErrors updateDetails(User loggedInUser, User targetUser,
            DynaActionForm form) {

        //get validation errors
        ActionErrors errors = RhnValidationHelper.validateDynaActionForm(this, form);

        //Add an error in case of password mismatch
        String pw = (String)form.get(UserActionHelper.DESIRED_PASS);
        String conf = (String)form.get(UserActionHelper.DESIRED_PASS_CONFIRM);
        if (!pw.equals(conf)) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("error.password_mismatch"));
        }

        //Make sure password is not empty
        if (!pw.isEmpty()) {
            // Validate the password
            if (pw.length() < UserDefaults.get().getMinPasswordLength()) {
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("error.minpassword",
                                UserDefaults.get().getMinPasswordLength()));
            }
            if (Pattern.compile("[\\t\\n]").matcher(pw).find()) {
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("error.invalidpasswordcharacters"));
            }
            if (pw.length() > UserDefaults.get().getMaxPasswordLength()) {
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("error.maxpassword",
                                targetUser.getPassword()));
            }

            //Set the password only if there are no errors at all
            if (errors.isEmpty()) {
                targetUser.setPassword(pw);
            }
        }

        //Only set the attributes if there are no errors.
        if (errors.isEmpty()) {
            targetUser.setFirstNames((String)form.get("firstNames"));
            targetUser.setLastName((String)form.get("lastName"));
            targetUser.setTitle((String)form.get("title"));
            String prefix = (String)form.get("prefix");
            targetUser.setPrefix(prefix.isEmpty() ? " " : prefix);
            // Update PAM Authentication attribute
            updatePamAttribute(loggedInUser, targetUser, form);
        }

        return errors;
    }

    /**
     * If pam is configured and the loggedInUser is an org_admin (and therefore
     * the checkbox was displayed), we need to inspect the "usepam" field on the
     * form and set the targetUser's pam auth attribute accordingly.
     * @param loggedInUser The user who is currently logged in
     * @param targetUser The user that will be updated
     * @param form The form containing the attribute value to use
     */
    protected void updatePamAttribute(User loggedInUser, User targetUser,
            DynaActionForm form) {
        String pamAuthService = Config.get().getString(ConfigDefaults.WEB_PAM_AUTH_SERVICE);
        if (pamAuthService != null && pamAuthService.trim().length() > 0 &&
                loggedInUser.hasRole(RoleFactory.ORG_ADMIN)) {
            if (form.get("usepam") != null &&
                    ((Boolean) form.get("usepam")).booleanValue()) {
                targetUser.setUsePamAuthentication(true);
            }
            else {
                targetUser.setUsePamAuthentication(false);
            }
        }
    }
}
