/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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

import com.redhat.rhn.common.util.MD5Crypt;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.Address;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.user.CreateUserCommand;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * UserEditSubmitAction, edit action submit handler for user detail page
 * @version $Rev: 1196 $
 */
public class CreateUserAction extends RhnAction {

    public static final String FAILURE = "failure";
    public static final String SUCCESS_INTO_ORG = "existorgsuccess";

    private ActionErrors populateCommand(DynaActionForm form, CreateUserCommand command) {
        ActionErrors errors = new ActionErrors();

        command.setEmail(form.getString("email"));
        command.setLogin(form.getString("login"));
        command.setPrefix(form.getString("prefix"));
        command.setFirstNames(form.getString("firstNames"));
        command.setLastName(form.getString("lastName"));

        //Should this user use pam authentication?
        if (form.get("usepam") != null && ((Boolean)form.get("usepam")).booleanValue()) {
            command.setUsePamAuthentication(true);
        }
        else {
            command.setUsePamAuthentication(false);
        }

        // Put any validationErrors into ActionErrors object
        ValidatorError[] validationErrors = command.validate();
        for (int i = 0; i < validationErrors.length; i++) {
            ValidatorError err = validationErrors[i];
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                       new ActionMessage(err.getKey(), err.getValues()));
        }

        Address addr = UserFactory.createAddress();
        fillOutAddress(form, addr);
        command.setAddress(addr);

        // Check passwords
        String passwd = (String)form.get(UserActionHelper.DESIRED_PASS);
        String passwdConfirm = (String)form.get(UserActionHelper.DESIRED_PASS_CONFIRM);

        if (passwd.equals(passwdConfirm)) {
            command.setPassword(passwd);
        }
        else {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                       new ActionMessage("error.password_mismatch"));
        }

        return errors;
    }

    private void fillOutAddress(DynaActionForm form, Address addr) {
        // Add address information to the user.
        addr.setAddress1((String)form.get("address1"));
        addr.setAddress2((String)form.get("address2"));
        addr.setCity((String)form.get("city"));
        addr.setState((String)form.get("state"));
        addr.setZip((String)form.get("zip"));
        addr.setCountry((String)form.get("country"));
        addr.setPhone(form.getString("phone"));
        addr.setFax(form.getString("fax"));
    }

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);

        DynaActionForm form = (DynaActionForm)formIn;

        /*
         * If the usepam checkbox has been checked, the password fields aren't required.
         * Since password is required in the db and since in all other cases it is required,
         * we'll trick the validation by doing all of the manipulation before validating
         * the form.
         *
         * Also, if the user for some reason does want to set a default password to stick
         * in the db (even though it won't be used), we'll just validate it like a regular
         * password and allow it.
         */
        if (form.get("usepam") != null && ((Boolean) form.get("usepam")).booleanValue()) {
            String hash = MD5Crypt.crypt("" + System.currentTimeMillis());
            if (form.get(UserActionHelper.DESIRED_PASS) == null ||
                    form.get(UserActionHelper.DESIRED_PASS).equals("")) {
                form.set(UserActionHelper.DESIRED_PASS, hash);
            }
            if (form.get(UserActionHelper.DESIRED_PASS_CONFIRM) == null ||
                    form.get(UserActionHelper.DESIRED_PASS_CONFIRM).equals("")) {
                form.set(UserActionHelper.DESIRED_PASS_CONFIRM, hash);
            }
        }

        // Validate the form
        ActionErrors verrors = RhnValidationHelper.validateDynaActionForm(this, form);
        if (!verrors.isEmpty()) {
            RhnValidationHelper.setFailedValidation(request);
            return returnError(mapping, request, verrors);
        }

        // Create the user and do some more validation
        CreateUserCommand command = getCommand();
        ActionErrors errors = populateCommand(form, command);
        if (!errors.isEmpty()) {
            return returnError(mapping, request, errors);
        }

        ActionMessages msgs = new ActionMessages();

        User user = createIntoOrg(requestContext, command,
                (String) form.get(UserActionHelper.DESIRED_PASS),
                msgs);
        User orgAdmin = requestContext.getCurrentUser();
        saveMessages(request, msgs);
        command.publishNewUserEvent(orgAdmin, orgAdmin.getOrg().getActiveOrgAdmins(),
                request.getServerName(),
                (String) form.get(UserActionHelper.DESIRED_PASS));

        user.setTimeZone(UserManager.getTimeZone(((Integer) form.get("timezone"))
            .intValue()));
        String preferredLocale = form.getString("preferredLocale");
        if (preferredLocale != null && preferredLocale.equals("none")) {
            preferredLocale = null;
        }
        user.setPreferredLocale(preferredLocale);
        user.setReadOnly(form.get("readonly") != null ? true : false);
        UserManager.storeUser(user);

        return getStrutsDelegate().forwardParam(mapping.findForward(SUCCESS_INTO_ORG),
                "uid", String.valueOf(user.getId()));
    }

    private User createIntoOrg(RequestContext requestContext,
                               CreateUserCommand command,
                               String password,
                               ActionMessages msgs) {

        User creator = requestContext.getCurrentUser();
        Org org = creator.getOrg();

        command.setOrg(org);
        command.setCompany(creator.getCompany());
        command.setMakeOrgAdmin(false);
        command.setMakeSatAdmin(false);
        command.storeNewUser();

        User newUser = command.getUser();

        msgs.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage("message.userCreatedIntoOrg",
                        StringEscapeUtils.escapeHtml(newUser.getLogin()),
                        newUser.getEmail()));


        return newUser;
    }

    private ActionForward returnError(ActionMapping mapping,
                                      HttpServletRequest request,
                                      ActionErrors errors) {
        addErrors(request, errors);
        return mapping.findForward(FAILURE);
    }

    protected CreateUserCommand getCommand() {
        return new CreateUserCommand();
    }
}
