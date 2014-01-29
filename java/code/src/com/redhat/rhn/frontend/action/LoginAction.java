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
package com.redhat.rhn.frontend.action;

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.satellite.CertificateManager;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import javax.security.auth.login.LoginException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * LoginAction
 * @version $Rev$
 */
public class LoginAction extends RhnAction {

    private static Logger log = Logger.getLogger(LoginAction.class);
    public static final String DEFAULT_URL_BOUNCE = "/rhn/YourRhn.do";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm form, HttpServletRequest request,
            HttpServletResponse response) {

        CertificateManager cm = CertificateManager.getInstance();
        if (cm.isSatelliteCertInRestrictedPeriod()) {
            createErrorMessageWithMultipleArgs(request, "satellite.expired.restricted",
                   cm.getDayProgressInRestrictedPeriod());
        }
        else if (cm.isSatelliteCertExpired()) {
            addMessage(request, "satellite.expired");
            request.setAttribute(LoginSetupAction.HAS_EXPIRED, Boolean.TRUE);
            return mapping.findForward("failure");
        }

        ActionForward ret = null;
        DynaActionForm f = (DynaActionForm)form;

        // Validate the form
        ActionErrors errors = RhnValidationHelper.validateDynaActionForm(this, f);
        if (!errors.isEmpty()) {
            performGracePeriodCheck(request);
            addErrors(request, errors);
            return mapping.findForward("failure");
        }

        ActionMessages messages = new ActionMessages();
        User user = LoginHelper.checkExternalAuthentication(request, messages, errors);
        // save stores msgs into the session (works for redirect)
        saveMessages(request, messages);
        addErrors(request, errors);
        errors.clear();

        if (user == null) {
            user = loginUser((String) f.get("username"), (String) f.get("password"),
                    request, response, errors);
        }

        if (errors.isEmpty()) {
            LoginHelper.successfulLogin(request, response, user);
        }
        else {
            performGracePeriodCheck(request);
            addErrors(request, errors);
            ret = mapping.findForward("failure");
        }

        return ret;
    }

    /**
     * update url_bounce
     * @param urlBounce url_bounce
     * @param requestMethod request method
     * @return updated url_bounce
     */
    public static String updateUrlBounce(String urlBounce, String requestMethod) {
        if (StringUtils.isBlank(urlBounce)) {
            urlBounce = DEFAULT_URL_BOUNCE;
        }
        else {
            String urlBounceTrimmed = urlBounce.trim();
            if (urlBounceTrimmed.equals("/rhn/") ||
                    urlBounceTrimmed.endsWith("Logout.do") ||
                    !urlBounceTrimmed.startsWith("/")) {
                urlBounce = DEFAULT_URL_BOUNCE;
            }
        }
        if (requestMethod != null && requestMethod.equals("POST")) {
            urlBounce = DEFAULT_URL_BOUNCE;
        }
        return urlBounce;
    }

    /**
     * Log a user into the site and create the user's session.
     * @param username User's login name.
     * @param password User's unencrypted password.
     * @param request HttpServletRequest for this action.
     * @param response HttpServletResponse for this action.
     * @return Any action error messages that may have occurred.
     */
    private User loginUser(String username,
                                   String password,
                                   HttpServletRequest request,
                                   HttpServletResponse response,
                                   ActionErrors e) {

        User user = null;

        try {
            user = UserManager.loginUser(username, password);
        }
        catch (LoginException ex) {
            e.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage(ex.getMessage()));
        }

        return user;
    }

    private void performGracePeriodCheck(HttpServletRequest request) {
        CertificateManager man = CertificateManager.getInstance();
        if (man.isSatelliteCertInGracePeriod()) {
                long daysUntilExpiration = man.getDaysLeftBeforeCertExpiration();
                createSuccessMessage(request,
                                     "satellite.graceperiod",
                                     new Long(daysUntilExpiration).toString());
            }
    }

}
