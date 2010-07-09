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
package com.redhat.rhn.frontend.action.renderers;

import com.redhat.rhn.domain.user.Pane;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * This class helps to debug the your rhn page.
 * YourRhnClipsRenderer
 * @version $Rev$
 */
public class YourRhnClipsRenderer extends RhnAction {
    /**
     * ${@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) throws Exception {

        RequestContext context = new RequestContext(request);
        User user = context.getLoggedInUser();
        PageControl pc = new PageControl();
        pc.setStart(1);
        pc.setPageSize(5);
        BaseFragmentRenderer renderer = null;
        String key = request.getParameter("key");
        if (StringUtils.isBlank(key)) {
            return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
        }
        if (key.equals(Pane.TASKS)) {
            renderer = new TasksRenderer();
        }
        else if (key.equals(Pane.CRITICAL_PROBES)) {
            renderer = new CriticalProbesRenderer();
        }
        else if (key.equals(Pane.CRITICAL_SYSTEMS)) {
            renderer = new CriticalSystemsRenderer();
        }
        else if (key.equals(Pane.INACTIVE_SYSTEMS)) {
            renderer = new InactiveSystemsRenderer();
        }
        else if (key.equals(Pane.LATEST_ERRATA)) {
            renderer = new LatestErrataRenderer();
        }
        else if (key.equals(Pane.PENDING_ACTIONS)) {
            renderer = new PendingActionsRenderer();
        }
        else if (key.equals(Pane.RECENTLY_REGISTERED_SYSTEMS)) {
            renderer = new RecentSystemsRenderer();
        }
        else if (key.equals(Pane.SYSTEM_GROUPS)) {
            renderer = new SystemGroupsRenderer();
        }
        else if (key.equals(Pane.WARNING_PROBES)) {
            renderer = new WarningProbesRenderer();
        }
        else if (key.equals(Pane.TASKS)) {
            renderer = new TasksRenderer();
        }

        if (renderer != null) {
            request.setAttribute("pageUrl", renderer.getPageUrl());
            renderer.render(user, pc, request);
        }

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }
}
