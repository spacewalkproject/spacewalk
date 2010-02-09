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
package com.redhat.rhn.frontend.action.rhnpackage.ssm;

import java.util.Date;
import java.util.List;
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
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.SetLabels;
import com.redhat.rhn.frontend.events.SsmInstallPackagesEvent;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.frontend.struts.SessionSetHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * SSM action that handles prompting the user for when to install the package as well
 * as creating the action when the user confirms the creation.
 */
public class SchedulePackageInstallationAction extends RhnListAction implements Listable {

    private static final String DATA_SET = "pageList";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping actionMapping,
                                 ActionForm actionForm,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws Exception {

        RequestContext requestContext = new RequestContext(request);

        ListHelper helper = new ListHelper(this, request);
        helper.setDataSetName(DATA_SET);
        helper.execute();

        if (request.getParameter("dispatch") != null) {
            if (requestContext.wasDispatched("installconfirm.jsp.confirm")) {

                StrutsDelegate strutsDelegate = getStrutsDelegate();

                // Load data from the web components
                User user = requestContext.getLoggedInUser();
                Date earliest = getStrutsDelegate().readDatePicker(
                    (DynaActionForm) actionForm, "date", DatePicker.YEAR_RANGE_POSITIVE);
                Long cid = requestContext.getRequiredParam(RequestContext.CID);

                String packagesDecl = request.getParameter("packagesDecl");

                Set<String> data = SessionSetHelper.lookupAndBind(request, packagesDecl);

                // Remove the packages from session once we have the above handle on them
                SessionSetHelper.obliterate(request, packagesDecl);

                // Fire off the request on the message queue
                SsmInstallPackagesEvent event =
                    new SsmInstallPackagesEvent(user.getId(), earliest, data, cid);
                MessageQueue.publish(event);

                ActionMessages msgs = new ActionMessages();

                // Check to determine to display single or plural confirmation message
                int numPackages = data.size();
                LocalizationService l10n = LocalizationService.getInstance();
                msgs.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("ssm.package.install.message.packageinstalls"));
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

        return actionMapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /** {@inheritDoc} */
    public List getResult(RequestContext context) {
        Long cid = context.getRequiredParam(RequestContext.CID);
        User user = context.getLoggedInUser();

        DataResult dataResult =
            SystemManager.systemsSubscribedToChannelInSet(cid, user, SetLabels.SYSTEM_LIST);

        return dataResult;
    }

}
