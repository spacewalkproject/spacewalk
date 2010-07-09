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
package com.redhat.rhn.frontend.action.systems;

import com.redhat.rhn.domain.rhnset.SetCleanup;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.manager.acl.AclManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.io.IOException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * OverviewAction
 * @version $Rev$
 */
public class OverviewAction extends RhnListAction {

    private static Logger log = Logger.getLogger(OverviewAction.class);

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);

        User user = requestContext.getLoggedInUser();

        /*
         * TODO: This code is for the clear button on the right end of the header.
         * I think that that button should be a button rather than a link, but right
         * now it is a link.  In the perl code, there are three url parameters that
         * indicate whether we should be showing this page or whether we are simply
         * clearing a set and going back to where we were.  On the java side, we only
         * use the empty_set parameter and just use defaults for the other two.  The
         * todo is this: we should stop using this page as a passthrough, decide
         * whether we like how the clear button works, and determine if we should stop
         * using simply defaults on the java side.
         */
        String emptySet = request.getParameter("empty_set");
        String setLabel = request.getParameter("set_label");
        String returnUrl = request.getParameter("return_url");
        if (emptySet != null && emptySet.equals("true")) {
            //Set defaults if needed.
            if (setLabel == null) {
                setLabel = "system_list";
            }

            //empty the specified set
            RhnSetDecl.findOrCreate(setLabel, SetCleanup.NOOP).clear(user);

            if (returnUrl == null) {
                return mapping.findForward("YourRhn");
            }

            //now send a redirect to the specified return url.
            try {
                response.sendRedirect(returnUrl);
            }
            catch (IOException exc) {
                log.error("IOException when trying to redirect to " +
                        returnUrl, exc);
            }
            return null;
        }

        //There is no purpose to system overview if you don't have system groups
        //so don't show it to people who can't
        if (!AclManager.hasAcl("org_entitlement(sw_mgr_enterprise)", request, null)) {
            return mapping.findForward("noentitlement");
        }


        //If they specified systems or groups, use that and save it.
        String showGroups = request.getParameter("showgroups");
        if (showGroups != null) {
            if (showGroups.equals("true")) {
                user.setShowSystemGroupList("Y");
            }
            else if (showGroups.equals("false")) {
                user.setShowSystemGroupList("N");
            }
            UserManager.storeUser(user);
        }

        //Get the user preference from the database (groups or systems)
        Boolean groups = new Boolean(user.getShowSystemGroupList()
                .equals("Y"));
        request.setAttribute("groups", groups.toString());

        ActionForward forward;

        //These are the submit actions.  Does hurt to call them every time
        //because they both have unspecified methods.
        try {
            if (!groups.booleanValue()) {
                SystemListAction action = new SystemListAction();
                action.setServlet(getServlet());
                forward = action.execute(mapping, formIn, request, response);
            }
            else {
                SystemGroupListSetupAction action = new SystemGroupListSetupAction();
                action.setServlet(getServlet());
                forward = action.execute(mapping, formIn, request, response);
            }
        }
        catch (Exception e) {
            throw new RuntimeException(e);
        }

        //This is for the actions in SystemGroupListAction
        //SystemGroupListAction currently redirects to a perl page for its
        //two real actions.  To avoid the IllegalStateException we need to
        //refrain from redirecting and forwarding.
        if (forward == null || mapping.findForward("default").equals(forward)) {
            return forward;
        }

        //These are the setup actions
        if (!groups.booleanValue()) {
            new SystemListSetupAction().execute(mapping, formIn, request, response);
        }
        else {
            new SystemGroupListSetupAction().execute(mapping, formIn, request, response);
        }

        return mapping.findForward("default");
    }
}

