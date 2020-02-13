/**
 * Copyright (c) 2009--2018 Red Hat, Inc.
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

import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.user.UserManager;

/**
 * OverviewAction
 */
public class OverviewAction extends RhnListAction {

    private static Logger log = Logger.getLogger(OverviewAction.class);

    // redirect_url can send us to the Java side and *nowhere else*
    private static final String[] ALLOWED_REDIRECTS = { "/rhn/" };

    //
    // Only follow redirects if they're "inside" the app (close open-redirecting)
    // Make sure to ignore anything after a <CR><LF> in the string (close header-injection)
    //
    private String getLegalReturnUrl(String proposedRedirect) {
        if (proposedRedirect == null) {
            return null;
        }

        for (String dest : ALLOWED_REDIRECTS) {
            if (proposedRedirect.startsWith(dest)) {
                // Punt if any control-characters found
                Matcher m = Pattern.compile("\\p{Cntrl}").matcher(proposedRedirect);
                boolean ctrlFound = m.find();
                return ctrlFound ? null : proposedRedirect;
            }
        }
        return null;
    }

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);

        User user = requestContext.getCurrentUser();

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
         *
         * TODO: Perl is gone. Half of the above comment is probably no longer
         * necessary. Come back some day and clean this...suboptimal bit of code.
         */
        String emptySet = request.getParameter("empty_set");
        String setLabel = request.getParameter("set_label");
        String returnUrl = getLegalReturnUrl(request.getParameter("return_url"));
        if (emptySet != null && emptySet.equals("true")) {
            //Set defaults if needed.
            if (setLabel == null) {
                setLabel = "system_list";
            }

            //empty the specified set
            RhnSetDecl.find(setLabel).clear(user);

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

        // If they specified systems or groups, use that and save it.
        // If showgroups is NOT specified (because we're actually coming here after
        // running one of the sub-page execute() calls below, who know nothing
        // of this contract...), then read the user's current setting from the
        // database.
        String showGroups = request.getParameter("showgroups");
        Boolean choseGroups = Boolean.FALSE;

        if (showGroups == null) {
            choseGroups = user.getShowSystemGroupList().equals("Y");
        }
        else {
            // "true" == Boolean.TRUE, null or anything-else == Boolean.FALSE
            choseGroups = new Boolean(showGroups);
            if (choseGroups) {
                user.setShowSystemGroupList("Y");
            }
            else {
                user.setShowSystemGroupList("N");
            }
            UserManager.storeUser(user);
        }

        request.setAttribute("groups", choseGroups.toString());

        // Two possible submit-actions depending on whether the user cares
        // about Systems, or SystemGroups.
        //
        // This is so weird :(
        ActionForward forward;
        try {
            request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
            if (!choseGroups) {
                SystemListSetupAction action = new SystemListSetupAction();
                action.setServlet(getServlet());
                forward = action.execute(mapping, formIn, request, response);
            }
            else {
                SystemGroupListSetupAction action = new SystemGroupListSetupAction();
                action.setServlet(getServlet());
                forward = action.execute(mapping, formIn, request, response);
            }
            return forward;
        }
        catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}

