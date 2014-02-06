/**
 * Copyright (c) 2009--2013 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.rhnpackage.ssm;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.SetLabels;
import com.redhat.rhn.frontend.events.SsmInstallPackagesEvent;
import com.redhat.rhn.frontend.struts.ActionChainHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.frontend.struts.SessionSetHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * SSM action that handles prompting the user for when to install the package as well as
 * creating the action when the user confirms the creation.
 */
public class SchedulePackageInstallationAction extends RhnListAction implements Listable {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping actionMapping,
                                 ActionForm actionForm,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws Exception {

        DynaActionForm f = (DynaActionForm) actionForm;
        RequestContext requestContext = new RequestContext(request);

        Map params = new HashMap();
        params.put(RequestContext.CID, requestContext.getRequiredParam(RequestContext.CID));
        params.put(RequestContext.MODE,
                requestContext.getRequiredParamAsString(RequestContext.MODE));

        ListHelper lHelp = new ListHelper(this, request);
        lHelp.setDataSetName(RequestContext.PAGE_LIST);
        lHelp.execute();

        StrutsDelegate strutsDelegate = getStrutsDelegate();

        if (request.getParameter(RequestContext.DISPATCH) != null) {

            String packagesDecl = request.getParameter("packagesDecl");

            if (requestContext.wasDispatched("installconfirm.jsp.confirm")) {
                // Load data from the web components
                User user = requestContext.getCurrentUser();
                Date earliest = getStrutsDelegate()
                        .readDatePicker((DynaActionForm) actionForm, "date",
                                DatePicker.YEAR_RANGE_POSITIVE);
                ActionChain actionChain = ActionChainHelper.readActionChain(f, user);
                Long cid = requestContext.getRequiredParam(RequestContext.CID);
                Set<String> data = SessionSetHelper.lookupAndBind(request, packagesDecl);
                // Remove the packages from session once we have the above handle on
                // them
                SessionSetHelper.obliterate(request, packagesDecl);

                // Fire off the request on the message queue
                SsmInstallPackagesEvent event = new SsmInstallPackagesEvent(user.getId(),
                        earliest, actionChain, data, cid);
                MessageQueue.publish(event);

                ActionMessages msgs = new ActionMessages();

                msgs.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                        "ssm.package.install.message.packageinstalls"));
                strutsDelegate.saveMessages(request, msgs);
                return actionMapping.findForward("confirm");
            }
        }

        // Determine number of packages for summary text to user
        String packagesDecl = (String) request.getAttribute("packagesDecl");
        Set<String> data = SessionSetHelper.lookupAndBind(request, packagesDecl);
        request.setAttribute("numSystems", data.size());

        // Prepopulate the date picker
        DynaActionForm dynaForm = (DynaActionForm) actionForm;
        DatePicker picker = getStrutsDelegate().prepopulateDatePicker(request, dynaForm,
                "date", DatePicker.YEAR_RANGE_POSITIVE);
        request.setAttribute("date", picker);

        // Pre-populate the Action Chain selector
        ActionChainHelper.prepopulateActionChains(request);

        return strutsDelegate.forwardParams(
                actionMapping.findForward(RhnHelper.DEFAULT_FORWARD), params);
    }

    /** {@inheritDoc} */
    public List getResult(RequestContext context) {
        Long cid = context.getRequiredParam(RequestContext.CID);
        User user = context.getCurrentUser();

        DataResult dataResult = SystemManager.systemsSubscribedToChannelInSet(cid, user,
                SetLabels.SYSTEM_LIST);

        return dataResult;
    }

}
