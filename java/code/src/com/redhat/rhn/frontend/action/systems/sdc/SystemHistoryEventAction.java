/**
 * Copyright (c) 2014--2015 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.systems.sdc;

import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.ActionFormatter;
import com.redhat.rhn.domain.action.server.ServerAction;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerHistoryEvent;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.action.ActionManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * SystemHistoryEventAction - page for displaying details about system events
 * @version $Rev: 1226 $
 */
public class SystemHistoryEventAction extends RhnAction {

    /** {@inheritDoc} */
    @Override
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        Server server = requestContext.lookupAndBindServer();
        Long aid = requestContext.getRequiredParam("aid");

        request.setAttribute("aid", aid);
        request.setAttribute("referrerLink", "History.do");
        request.setAttribute("linkLabel", "system.event.return");
        request.setAttribute("headerLabel", "system.event.header");

        Action action;
        ServerAction serverAction;
        try {
            action = ActionManager.lookupAction(requestContext.getCurrentUser(), aid);
            serverAction = ActionFactory.getServerActionForServerAndAction(server, action);
        }
        catch (LookupException e) {
            ServerHistoryEvent event = ActionFactory.lookupHistoryEventById(aid);
            request.setAttribute("actiontype", event.getSummary());
            request.setAttribute("earliestaction", event.getCreated());
            request.setAttribute("actionnotes", event.getDetails());
            request.setAttribute("failed", false);
            return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
        }
        ActionFormatter af = action.getFormatter();
        request.setAttribute("actionname", af.getName());
        request.setAttribute("actiontype", af.getActionType());
        request.setAttribute("scheduler", af.getScheduler());
        request.setAttribute("earliestaction", af.getEarliestDate());
        request.setAttribute("actionnotes", af.getDetails(server,
                requestContext.getCurrentUser()));
        request.setAttribute("failed",
                serverAction.getStatus().equals(ActionFactory.STATUS_FAILED));
        if (!serverAction.getStatus().equals(ActionFactory.STATUS_COMPLETED) &&
                !serverAction.getStatus().equals(ActionFactory.STATUS_FAILED)) {
            request.setAttribute("referrerLink", "Pending.do");
            request.setAttribute("linkLabel", "system.event.pendingReturn");
            request.setAttribute("headerLabel", "system.event.pendingHeader");
        }
        if (isSubmitted((DynaActionForm)formIn)) {
            createSuccessMessage(request, "system.event.rescheduled", action.getName());
            ActionFactory.rescheduleSingleServerAction(action, 5L, server.getId());
            return mapping.findForward("continue");
        }

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

}

