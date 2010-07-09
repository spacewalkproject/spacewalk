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

package com.redhat.rhn.frontend.struts;

import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.events.TraceBackEvent;
import com.redhat.rhn.manager.acl.AclManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.RequestProcessor;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * RhnRequestProcessor a custom Struts RequestProcessor that
 * intercepts all of our code struts requests
 *
 * @version $Rev$
 */

public class RhnRequestProcessor extends RequestProcessor {

    protected void processPopulate(HttpServletRequest request, HttpServletResponse response,
            ActionForm form, ActionMapping mapping) throws ServletException {
        super.processPopulate(request, response, form, mapping);
        if (form instanceof ScrubbingDynaActionForm) {
            ((ScrubbingDynaActionForm) form).scrub();
        }
    }

    /**
     * code run before each request for struts.  performs rhn
     * initialization, such as populating Request scope objects based
     * on session.  eventually will be where we cleanse formvars as well.
     * @param request ServletRequest to process.
     * @param response ServletResponse to create.
     * @throws IOException thrown if an error occurs reading the stream.
     * @throws ServletException thrown if an error occurs in the Servlet.
     */
    public void process(HttpServletRequest request, HttpServletResponse response)
        throws IOException, ServletException {

        try {
            //Get the mapping so we can see if whether or not we need to process acls
            String path = processPath(request, response);
            ActionMapping originalMapping = (ActionMapping)
                    moduleConfig.findActionConfig(path);
            if (originalMapping != null && originalMapping instanceof RhnActionMapping) {
                //we need to process a list of acls
                RhnActionMapping mapping = (RhnActionMapping) originalMapping;
                if (!AclManager.hasAcl(mapping.getAcls(), request, mapping.getMixins())) {
                    //an acl evaluated to false
                    PermissionException e = new PermissionException("Missing Acl");
                    request.setAttribute("error", e);
                    //forward to permissions error page
                    doForward("/errors/Permission.do", request, response);
                    //exit method
                    return;
                }
            }
            //now that we're done with rhn stuff, call RequestProcessor.process()
            super.process(request, response);
        }
        catch (IOException se) {
            sendErrorEmail(request, se);
            throw se;
        }
        catch (ServletException se) {
            fixCause(se);
            sendErrorEmail(request, se);
            throw se;
        }
        catch (RuntimeException re) {
            if (re.getCause() == null) {
                sendErrorEmail(request, re);
            }
            else {
                sendErrorEmail(request, re.getCause());
            }
            throw re;
        }
    }

    private void fixCause(ServletException e) {
        // ServletException has a rootCause that is separate from
        // Throwable.cause. Try and set Throwable.cause to ServletException.rootCause
        // for the chain of exceptions starting with e.rootCause
        do {
            Throwable cause = e.getRootCause();
            if (cause != null && e.getCause() == null) {
                e.initCause(cause);
            }
            if (cause instanceof ServletException) {
                e = (ServletException) cause;
            }
            else {
                e = null;
            }
        } while (e != null);
    }

    // Send an error email when an Action generates an Exception
    private void sendErrorEmail(HttpServletRequest request, Throwable e) {
        TraceBackEvent evt = new TraceBackEvent();
        RequestContext requestContext = new RequestContext(request);
        User usr = requestContext.getLoggedInUser();
        evt.setUser(usr);
        evt.setRequest(request);
        evt.setException(e);
        MessageQueue.publish(evt);
    }

}
