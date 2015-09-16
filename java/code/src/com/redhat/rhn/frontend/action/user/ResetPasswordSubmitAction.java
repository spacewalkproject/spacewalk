/**
 * Copyright (c) 2015 Red Hat, Inc.
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

import java.io.IOException;
import java.util.Date;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.db.ResetPasswordFactory;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.messaging.Mail;
import com.redhat.rhn.common.messaging.SmtpMail;
import com.redhat.rhn.domain.common.ResetPassword;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.action.LoginAction;
import com.redhat.rhn.frontend.servlets.PxtSessionDelegateFactory;
import com.redhat.rhn.manager.user.UserManager;

/**
 * ResetPasswordSubmitAction, responds to user pushing 'update' on the change-password
 * form
 *
 * @version $Rev: $
 */
public class ResetPasswordSubmitAction extends UserEditActionHelper {

    private static Logger log = Logger.getLogger(ResetPasswordSubmitAction.class);

    private static final String SUCCESS = "success";
    private static final String MISMATCH = "mismatch";
    private static final String BADPWD = "badpwd";
    private static final String INVALID = "invalid";

    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
                    HttpServletRequest request, HttpServletResponse response) {

        log.debug("ResetPasswordSubmitAction");
        DynaActionForm form = (DynaActionForm) formIn;
        Map<String, Object> params = makeParamMap(request);

        String token = (form.get("token") == null ? null : form.get("token").toString());
        ResetPassword rp = ResetPasswordFactory.lookupByToken(token);
        ActionErrors errors = ResetPasswordFactory.findErrors(rp);

        // If there are any token-failures - reject and leave
        if (!errors.isEmpty()) {
            log.debug("passwdchange: invalid token!");
            addErrors(request, errors);
            return getStrutsDelegate().forwardParams(mapping.findForward(INVALID), params);
        }

        // We have a valid token - log in the associated user, send them along
        User u = UserFactory.lookupById(rp.getUserId());
        if (u.isDisabled()) {
            log.debug("passwdchange: disabled user found");
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                     new ActionMessage("resetpassword.jsp.error.disabled_user"));
            addErrors(request, errors);
            return getStrutsDelegate().forwardParams(mapping.findForward(INVALID), params);
        }

        // Add an error in case of password mismatch and ignore remaining pwd rules -
        // if the pwds don't match, assume the user finger-fumbled, no sense in yelling
        // at them more
        String pw = (String) form.get("password");
        String conf = (String) form.get("passwordConfirm");
        if (!pw.equals(conf)) {
            errors.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                       "error.password_mismatch"));
            addErrors(request, errors);
            return getStrutsDelegate().forwardParams(mapping.findForward(MISMATCH), params);
        }

        // Validate the rest of the password rules
        validatePassword(errors, pw);
        if (!errors.isEmpty()) {
            addErrors(request, errors);
            return getStrutsDelegate().forwardParams(mapping.findForward(BADPWD), params);
        }

        // If we got this far, we can change the user - update pw and data
        updateUser(u, pw);

        // Send confirmation email
        String emailBody = setupEmailBody("email.reset.password",
                                          u.getEmail(), u.getLogin(),
                                          ConfigDefaults.get().getHostname());
        sendEmail(u.getEmail(),
                  "help.credentials.jsp.passwordreset.confirmation", emailBody);

        // invalidate any other tokens for them
        ResetPasswordFactory.invalidateUserTokens(u.getId());

        // Set up user to be logged in and sent to YourRhn
        loginAndRedirect(u, mapping, request, response);

        log.debug("ResetLinkAction: user [" + u.getId() + "] is now logged in");

        // Have to return NULL - updateWebUserId() has already redirected us,
        // and doing it again will make struts Very Angry
        return null;
    }

    private void loginAndRedirect(User u, ActionMapping mapping,
                    HttpServletRequest request, HttpServletResponse response) {
        // Store a "we did it" message
        ActionMessages msgs = new ActionMessages();
        msgs.add(ActionMessages.GLOBAL_MESSAGE,
                 new ActionMessage("message.userInfoUpdated"));
        getStrutsDelegate().saveMessages(request, msgs);

        // update session with actual user
        PxtSessionDelegateFactory.getInstance().newPxtSessionDelegate().
            updateWebUserId(request, response, u.getId());

        // NOTE: following code taken from LoginHelper.successfulLogin().
        // Because that method relies on url_redirect already being set in
        // request, we can't just call it, alas. We have to set url_redirect
        // in order to go where we want, because the updateWebUserId() call
        // resets the web-session and we can't fwd anywhere after that.
        // Fun!
        // Set up to redirect to the 'success' forward in the struts-cfg
        // (probably YourRhn)
        String urlBounce = "/rhn" + mapping.findForward(SUCCESS).getPath();
        String reqMethod = "GET";
        urlBounce = LoginAction.updateUrlBounce(urlBounce, reqMethod);
        try {
            if (urlBounce != null) {
                log.info("redirect: " + urlBounce);
                response.sendRedirect(urlBounce);
            }
        }
        catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void updateUser(User u, String pw) {
        u.setPassword(pw);
        u.setLastLoggedIn(new Date());
        UserManager.storeUser(u);
    }

    // See ForgotCredentials
    private void sendEmail(String recipient, String subjectKey, String body) {
        String subject = LocalizationService.getInstance().getMessage(subjectKey);
        Mail mail = new SmtpMail();
        mail.setHeader("X-RHN-Info", "Requested " + subject + " for " + recipient);
        mail.setRecipient(recipient);
        mail.setSubject(Config.get().getString("web.product_name") + " " + subject);
        mail.setBody(body);
        log.debug("Sending mail message:\n" + mail.toString());
        try {
            mail.send();
        }
        catch (Exception e) {
            log.error("Exception while sending email: ");
            log.error(e.getMessage(), e);
        }
    }

    private String setupEmailBody(String template, Object... args) {
        // Build email body from template
        LocalizationService ls = LocalizationService.getInstance();
        String body = ls.getMessage(template, args);
        return body;
    }

}
