/**
 * Copyright (c) 2009--2015 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.help;

import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

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
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.messaging.Mail;
import com.redhat.rhn.common.messaging.SmtpMail;
import com.redhat.rhn.domain.common.ResetPassword;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;


/**
 * ForgotCredentialsAction
 * @version $Rev$
 */
public class ForgotCredentialsAction extends RhnAction {
    private static Logger log = Logger.getLogger(ForgotCredentialsAction.class);

    private static final long PASSWORD_REQUEST_TIMEOUT = 60;
    private static final long LOGINS_REQUEST_TIMEOUT = 300;

    /** {@inheritDoc} */
    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request, HttpServletResponse response) {

        DynaActionForm form = (DynaActionForm)formIn;

        if (!isSubmitted(form)) {
            return getStrutsDelegate().forwardParams(
                    mapping.findForward(RhnHelper.DEFAULT_FORWARD),
                    request.getParameterMap());
        }

        ActionMessages msgs = new ActionMessages();
        ActionErrors errors = new ActionErrors();

        RequestContext ctx = new RequestContext(request);
        Map forwardParams = makeParamMap(request);
        // For saving previous request times
        HttpSession session = request.getSession();

        String email = form.getString("email");
        String login = form.getString("username");

        if (ctx.hasParam("password_button")) {
            newPassword(login, email, errors, msgs, session);
        }
        else if (ctx.hasParam("login_button")) {
            lookupLogins(email, errors, msgs, session);
        }

        if (!errors.isEmpty()) {
            addErrors(request, errors);
            return getStrutsDelegate().forwardParams(
                    mapping.findForward(RhnHelper.DEFAULT_FORWARD),
                    forwardParams);
        }

        saveMessages(request, msgs);
        return getStrutsDelegate().forwardParams(
                mapping.findForward("success"),
                forwardParams);
    }

    private void newPassword(String login, String email,
            ActionErrors errors, ActionMessages msgs, HttpSession session) {

        // Check if time elapsed from last request
        if (!hasTimeElapsed(session, "password", login, PASSWORD_REQUEST_TIMEOUT)) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("help.credentials.rerequest",
                            PASSWORD_REQUEST_TIMEOUT));
            return;
        }

        try {
            User foundUser = UserFactory.lookupByLogin(login);
            // Check if email and login agrees
            if (foundUser.getEmail().toUpperCase().equals(
                    email.toUpperCase())) {
                ResetPassword rp = ResetPasswordFactory.createNewEntryFor(foundUser);
                String link = ResetPasswordFactory.generateLink(rp);

                String emailBody = setupEmailBody("email.forgotten.password",
                        email, link, login);
                sendEmail(email, LocalizationService.getInstance().
                        getMessage("help.credentials.jsp.passwordreset"), emailBody);

                // Save time and login to session
                saveRequestTime(session, "password", login);

                msgs.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("help.credentials.passwordsent", email));
            }
            else {
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("help.credentials.invalidemail"));
            }
        }
        catch (LookupException e) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("help.credentials.invalidlogin"));
        }
    }

    private void lookupLogins(String email,
            ActionErrors errors, ActionMessages msgs, HttpSession session) {

        // Check if time elapsed from last request
        if (!hasTimeElapsed(session, "logins", email, LOGINS_REQUEST_TIMEOUT)) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("help.credentials.rerequest",
                            LOGINS_REQUEST_TIMEOUT));
            return;
        }

        List<User> users = UserFactory.lookupByEmail(email);

        if (!users.isEmpty()) {
            StringBuilder logins = new StringBuilder();

            for (User usr : users) {
                logins.append(usr.getLogin() + "\n");
            }

            String emailBody = setupEmailBody("email.forgotten.logins",
                    email, logins.toString(), ConfigDefaults.get().getHostname());
            sendEmail(email, LocalizationService.getInstance().
                    getMessage("help.credentials.jsp.logininfo"), emailBody);

            // Save time and email to session
            saveRequestTime(session, "logins", email);

            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("help.credentials.loginssent", email));
        }
        else {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("help.credentials.nologins"));
        }
    }

    private void sendEmail(String recipient,
            String subject, String body) {

        Mail mail = new SmtpMail();
        mail.setHeader("X-RHN-Info",
                "Requested " + subject + " for " + recipient);
        mail.setRecipient(recipient);
        mail.setSubject(Config.get().getString("web.product_name") +
                " " + subject);
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

    /**
     * Get template, enter args there and return result.
     * @param template name of template
     * @param args args to be in template
     * @return complete body, args in template
     */
    private String setupEmailBody(String template, Object... args) {
        // Build email body from template
        LocalizationService ls = LocalizationService.getInstance();
        String body = ls.getMessage(template, args);
        return body;
    }

    /**
     * Method for simple checking if time from last request has elapsed.
     * Like it was in old perl page.
     * @param session http session
     * @param type string to name record in session
     * @param user identification of last request author
     * @param timeout time in seconds
     * @return if time has elapsed
     */
    private boolean hasTimeElapsed(HttpSession session, String type,
            String user, long timeout) {

        // Save time and request author/login
        Long prevRequest = (Long) session.getAttribute(
                "previous_" + type + "_request");
        String prevRequestUser = (String) session.getAttribute(
                "previous_" + type + "_request_user");
        Long now = new Date().getTime();

        // Time has not elapsed for last user
        if (prevRequest != null &&
                ((now - prevRequest) < timeout * 1000) &&
                (user.toUpperCase().equals(prevRequestUser))) {
            log.debug("Unsuccesful try to request email for " + user);
            return false;
        }

        return true;
    }

    /**
     * Actualize record of time and user in session.
     * @param session http session
     * @param type string to name record in session
     * @param user identification of last request author
     */
    private void saveRequestTime(HttpSession session, String type,
            String user) {

        session.setAttribute("previous_" + type + "_request",
                new Date().getTime());
        session.setAttribute("previous_" + type + "_request_user",
                user.toUpperCase());
    }
}
