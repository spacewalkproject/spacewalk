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
     * @param targetUser The user to operate on
     * @param form The form we're grabbing the info from
     * @return Returns an ActionErrors object containing the errors (if any) that occurred.
     */
    public ActionErrors updateDetails(User targetUser, DynaActionForm form) {

        //get validation errors
        ActionErrors errors = RhnValidationHelper.validateDynaActionForm(this, form);

        //Make sure password and passwordConfirm are equal
        if (!UserActionHelper.PLACEHOLDER_PASSWORD.equals(
                form.get(UserActionHelper.DESIRED_PASS))) {
            String pw = (String)form.get(UserActionHelper.DESIRED_PASS);
            String conf = (String)form.get(UserActionHelper.DESIRED_PASS_CONFIRM);
            if (pw.equals(conf)) {
                targetUser.setPassword(pw);
            }
            else {
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                           new ActionMessage("error.password_mismatch"));
            }
        }

        //Only set the attributes if there are no errors.
        if (errors.isEmpty()) {
            targetUser.setFirstNames((String)form.get("firstNames"));
            targetUser.setLastName((String)form.get("lastName"));
            targetUser.setTitle((String)form.get("title"));
            targetUser.setPrefix((String)form.get("prefix"));
        }

        return errors;
    }
}
