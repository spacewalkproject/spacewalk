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
package com.redhat.rhn.frontend.action.multiorg;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.util.MD5Crypt;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.frontend.action.user.UserActionHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.org.CreateOrgCommand;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * OrgCreateAction - Action to create an org.
 * @version $Rev: 119601 $
 */
public class OrgCreateAction extends RhnAction {


    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        ActionForward retval = mapping.findForward("default");
        DynaActionForm dynaForm = (DynaActionForm) formIn;

        /*
         * If we are a sat and we have setup pam authentication already, display the
         * checkbox and instructions
         */
        String pamAuthService = Config.get().getString(ConfigDefaults.WEB_PAM_AUTH_SERVICE);
        if (pamAuthService != null && pamAuthService.trim().length() > 0) {
            request.setAttribute("displaypamcheckbox", "true");
        }

        request.setAttribute("availablePrefixes", UserActionHelper.getPrefixes());
        if (isSubmitted(dynaForm)) {
        /*
         * If the usepam checkbox has been checked, the password fields aren't required.
         * Since password is required in the db and since in all other cases it is req,
         * we'll trick the validation by doing all of the manipulation before validating
         * the form.
         *
         * Also, if the user for some reason does want to set a default password to stick
         * in the db (even though it won't be used), we'll just validate it like a regular
         * password and allow it.
         */
            if (dynaForm.get("usepam") != null &&
                    ((Boolean) dynaForm.get("usepam")).booleanValue()) {
                String hash = MD5Crypt.crypt("" + System.currentTimeMillis());
                if (dynaForm.get(UserActionHelper.DESIRED_PASS) == null ||
                        dynaForm.get(UserActionHelper.DESIRED_PASS).equals("")) {
                    dynaForm.set(UserActionHelper.DESIRED_PASS, hash);
                }
                if (dynaForm.get(UserActionHelper.DESIRED_PASS_CONFIRM) == null ||
                        dynaForm.get(UserActionHelper.DESIRED_PASS_CONFIRM).equals("")) {
                    dynaForm.set(UserActionHelper.DESIRED_PASS_CONFIRM, hash);
                }
            }

            ActionErrors errors = RhnValidationHelper.validateDynaActionForm(
                    this, dynaForm);

            if (!errors.isEmpty()) {
                getStrutsDelegate().saveMessages(request, errors);
            }
            else {
                String name = dynaForm.getString("orgName");
                String email = dynaForm.getString("email");
                String login = dynaForm.getString("login");
                String pass = dynaForm.getString("desiredpassword");
                String passConfirm = dynaForm.getString("desiredpasswordConfirm");
                String fname = dynaForm.getString("firstNames");
                String lname = dynaForm.getString("lastName");
                String prefix = dynaForm.getString("prefix");

                if (!pass.equals(passConfirm)) {
                    addMessage(request, "error.password_mismatch");
                }
                else {
                    CreateOrgCommand cmd = new CreateOrgCommand(name, login, pass, email);

                    //Should this user use pam authentication?
                    if (dynaForm.get("usepam") != null &&
                            ((Boolean)dynaForm.get("usepam")).booleanValue()) {
                        cmd.setUsePam(true);
                    }
                    else {
                        cmd.setUsePam(false);
                    }

                    cmd.setFirstName(fname);
                    cmd.setLastName(lname);
                    cmd.setPrefix(prefix);
                    ValidatorError[] verrors = cmd.store();
                    if (verrors != null) {
                        ActionErrors ae =
                            RhnValidationHelper.validatorErrorToActionErrors(verrors);
                        getStrutsDelegate().saveMessages(request, ae);
                    }
                    else {
                        createSuccessMessage(request, "org.create.success",
                                cmd.getNewOrg().getName());
                        retval = getStrutsDelegate().
                                 forwardParam(mapping.findForward("success"),
                                 RequestContext.ORG_ID, cmd.getNewOrg().getId().toString());
                    }
                }
            }
        }
        return retval;
    }
}
