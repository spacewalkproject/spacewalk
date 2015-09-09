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

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import com.redhat.rhn.common.db.ResetPasswordFactory;
import com.redhat.rhn.domain.common.ResetPassword;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.action.LoginAction;
import com.redhat.rhn.frontend.servlets.PxtSessionDelegateFactory;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.user.UserManager;

/**
 * ResetLinkAction, responds to /ResetLink?token=<hash>
 * Its job is to validate the token, log in the affected user, and redirect them to
 * the change-your-password-NOW page
 *
 * @version $Rev: $
 */
public class ResetLinkAction extends RhnAction {

    private static Logger log = Logger.getLogger(ResetLinkAction.class);

    private static final String INVALID = "invalid";
    private static final String VALID = "valid";

    protected ActionErrors findErrors(ResetPassword rp) {
        log.debug("findErrors : ["+(rp==null?"null":rp.toString())+"]");
        ActionErrors errors = new ActionErrors();
        if (rp == null) {
            log.debug("findErrors: no RP found");
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                       new ActionMessage("resetpassword.jsp.error.notoken"));
        } else if (!rp.isValid()) {
            log.debug("findErrors: invalid RP found");
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                       new ActionMessage("resetpassword.jsp.error.invalidtoken"));

        } else if (rp.isExpired()) {
            log.debug("findErrors: expired RP found");
            ResetPasswordFactory.invalidateToken(rp.getToken());
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                       new ActionMessage("resetpassword.jsp.error.expiredtoken"));
        }
        return errors;
    }

    /** {@inheritDoc} */
    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
                    HttpServletRequest request, HttpServletResponse response) {

        log.debug("ResetLinkAction");
        RequestContext requestContext = new RequestContext(request);
        String token = requestContext.getRequiredParamAsString("token");

        // Does token exist, and is it valid?
        ResetPassword rp = ResetPasswordFactory.lookupByToken(token);

        ActionErrors errs = findErrors(rp);
        if (!errs.isEmpty()) {
            addErrors(request, errs);
            return mapping.findForward(INVALID);
        }

        // We have a valid token - log in the associated user, send them along
        User u = UserFactory.lookupById(rp.getUserId());
        if (u.isDisabled()) {
            log.debug("findErrors: disabled user found");
            errs.add(ActionMessages.GLOBAL_MESSAGE,
                     new ActionMessage("resetpassword.jsp.error.disabled_user"));
            return mapping.findForward(INVALID);
        }

        // If we got this far, we can log in the user - next step is to let them
        // change their password

        // NOTE: following code taken from LoginHelper.successfulLogin().
        // Because that method relies on url_redirect already being set in
        // request, we can't just call it, alas. We have to set url_redirect
        // in order to go where we want, because the updateWebUserId() call
        // resets the web-session and we can't fwd anywhere after that.
        // Fun!

        // set last logged in
        u.setLastLoggedIn(new Date());
        UserManager.storeUser(u);

        // update session with actual user
        PxtSessionDelegateFactory.getInstance().newPxtSessionDelegate().
            updateWebUserId(request, response, u.getId());

        // Set up to redirect to the change-password destination
        String urlBounce = "/rhn/"+ mapping.findForward(VALID).getPath();
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

        log.debug("ResetLinkAction: user ["+u.getId()+"] is logged in");

        // Have to return NULL - updateWebUserId() has already redirected us,
        // and doing it again will make struts Very Angry
        return null;
    }

}
