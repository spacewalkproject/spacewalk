/**
 * Copyright (c) 2014 Red Hat, Inc.
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

import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.events.UpdateErrataCacheEvent;
import com.redhat.rhn.frontend.servlets.PxtSessionDelegateFactory;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.commons.lang.time.StopWatch;
import org.apache.log4j.Logger;

import java.io.IOException;
import java.util.Date;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;


/**
 * LoginHelper
 * @version $Rev$
 */
public class LoginHelper {

    private static Logger log = Logger.getLogger(LoginHelper.class);

    /** static method shared by LoginAction and LoginSetupAction
     * @param request actual request
     * @param response actual reponse
     * @param user logged in user
     * @return returns true, if redirect
     */
    public static boolean successfulLogin(HttpServletRequest request,
            HttpServletResponse response, User user) {
        // set last logged in
        user.setLastLoggedIn(new Date());
        UserManager.storeUser(user);
        // update session with actual user
        PxtSessionDelegateFactory.getInstance().newPxtSessionDelegate().
            updateWebUserId(request, response, user.getId());

        LoginHelper.publishUpdateErrataCacheEvent(user.getOrg());
        // redirect, if url_bounce set
        HttpSession ws = request.getSession(false);
        if (ws != null) {
            String urlBounce = LoginAction.updateUrlBounce(
                    (String) ws.getAttribute("url_bounce"),
                    (String) ws.getAttribute("request_method"));
            try {
                if (urlBounce != null) {
                    log.info("redirect: " + urlBounce);
                    response.sendRedirect(urlBounce);
                    return true;
                }
            }
            catch (IOException e) {
                e.printStackTrace();
            }
        }
        return false;
    }

    /**
     * @param orgIn
     */
    private static void publishUpdateErrataCacheEvent(Org orgIn) {
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

}
