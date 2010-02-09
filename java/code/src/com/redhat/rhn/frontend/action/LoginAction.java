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
package com.redhat.rhn.frontend.action;

import com.redhat.rhn.common.db.ConstraintViolationException;
import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.events.UpdateErrataCacheEvent;
import com.redhat.rhn.frontend.servlets.PxtSessionDelegate;
import com.redhat.rhn.frontend.servlets.PxtSessionDelegateFactory;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.satellite.CertificateManager;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.commons.lang.time.StopWatch;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.io.IOException;

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
    
    // It is OK to maintain a PxtSessionDelegate instance because PxtSessionDelegate
    // objects do not maintain client state.
    private PxtSessionDelegate pxtDelegate;
    
    /**
     * Initialize the action.
     */
    public LoginAction() {
        PxtSessionDelegateFactory pxtDelegateFactory = 
            PxtSessionDelegateFactory.getInstance();
        
        pxtDelegate = pxtDelegateFactory.newPxtSessionDelegate();
    }
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm form, HttpServletRequest request,
            HttpServletResponse response) {
        
        if (CertificateManager.getInstance().isSatelliteCertExpired()) {
            addMessage(request, "satellite.expired");
            request.setAttribute(LoginSetupAction.HAS_EXPIRED, new Boolean(true));
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
        String username = (String) f.get("username");
        String password = (String) f.get("password");
        String urlBounce = (String) f.get("url_bounce");
        
        ActionErrors e = new ActionErrors();
        User user = loginUser(username, password, request, response, e);
        RequestContext ctx = new RequestContext(request);

        if (e.isEmpty()) {
            if (urlBounce == null || urlBounce.trim().equals("")) {
                if (log.isDebugEnabled()) {
                    log.debug("2 - url bounce is empty using [" + DEFAULT_URL_BOUNCE + "]");
                }
                urlBounce = DEFAULT_URL_BOUNCE;
            }
            if (urlBounce.trim().endsWith("Logout.do")) {
                if (log.isDebugEnabled()) {
                    log.debug(" - handling special case of url_bounce=Logout.do");
                }
                urlBounce = DEFAULT_URL_BOUNCE;
            }
            if (user != null) {
                try {
                    publishUpdateErrataCacheEvent(user.getOrg());
                }
                catch (ConstraintViolationException ex) {
                    log.error(ex);
                    User loggedInUser = ctx.getLoggedInUser();
                    if (loggedInUser != null) {
                        request.setAttribute("loggedInUser", loggedInUser.getLogin());
                    }
                    ret = mapping.findForward("error");
                    return ret;
                }

            }
            
            if (log.isDebugEnabled()) {
                log.debug("5 - redirecting to [" + urlBounce + "]");
            }
            if (user != null) {
                pxtDelegate.updateWebUserId(request, response, user.getId());
                
                try {
                    response.sendRedirect(urlBounce);
                    return null;
                }
                catch (IOException ioe) {
                    throw new RuntimeException(
                            "Exception while trying to redirect: " + ioe);
                }
            }
        }
        else {
            if (log.isDebugEnabled()) {
                log.debug("6 - forwarding to failure");
            }
            
            performGracePeriodCheck(request);
            
            addErrors(request, e);
            request.setAttribute("url_bounce", urlBounce);
            ret = mapping.findForward("failure");
        }
        if (log.isDebugEnabled()) {
            log.debug("7 - returning");
        }
        return ret;
    }

    /**
     * @param orgIn
     */
    private void publishUpdateErrataCacheEvent(Org orgIn) {
        StopWatch sw = new StopWatch();
        if (log.isDebugEnabled()) {
            log.debug("Updating errata cache");
            sw.start();
        }
        
        UpdateErrataCacheEvent uece = new 
            UpdateErrataCacheEvent(UpdateErrataCacheEvent.TYPE_ORG);
        uece.setOrgId(orgIn.getId());
        MessageQueue.publish(uece);
        
        if (log.isDebugEnabled()) {
            sw.stop();
            log.debug("Finished Updating errata cache. Took [" +
                    sw.getTime() + "]");
        }
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
