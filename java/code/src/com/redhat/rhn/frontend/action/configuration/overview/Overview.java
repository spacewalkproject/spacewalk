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
package com.redhat.rhn.frontend.action.configuration.overview;

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.acl.AclManager;
import com.redhat.rhn.manager.configuration.ConfigurationManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Overview Action for the Configuration top level.
 * @version $Rev$
 */
public class Overview extends RhnAction {

    /**
     * {@inheritDoc}
     */
    public final ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);

        User user = requestContext.getCurrentUser();

        ConfigurationManager manager = ConfigurationManager.getInstance();

        Map summary = manager.getOverviewSummary(user);
        request.setAttribute("summary", summary);
        request.setAttribute("is_admin", Boolean.valueOf(AclManager
                .hasAcl("user_role(org_admin)",
                    request, null)));
        request.setAttribute("recentFiles", manager.getRecentlyModifiedConfigFiles(user,
                new Integer(5))); //display five recent files.
        request.setAttribute("recentActions", manager.getRecentConfigDeployActions(user,
                new Integer(5))); //display five recent actions.

        return getStrutsDelegate().forwardParams(mapping.findForward(
                RhnHelper.DEFAULT_FORWARD), request.getParameterMap());
    }

}
