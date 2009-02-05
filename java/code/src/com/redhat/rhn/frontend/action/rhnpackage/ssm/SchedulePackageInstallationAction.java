/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import java.util.ArrayList;
import java.util.Date;
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
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.action.rhnpackage.PackageAction;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.SetLabels;
import com.redhat.rhn.frontend.dto.EssentialServerDto;
import com.redhat.rhn.frontend.dto.PackageListItem;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.frontend.struts.SessionSetHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.action.ActionManager;

/**
 * SSM action that handles prompting the user for when to install the package as well
 * as creating the action when the user confirms the creation.
 *
 * @version $Revision$
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
                return executePackageAction(actionMapping, actionForm, request, response);
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

    /**
     * Creates the package installation action.
     * <p/>
     * Note: this can probably be removed in place of the code in
     * BaseSystemPackagesConfirmAction. I rewrote most of the logic for now since I don't
     * yet have a good plan for refactoring that method to support multiple servers.
     *
     * @param mapping  struts mapping
     * @param formIn   struts form
     * @param request  HTTP request
     * @param response HTTP response
     * @return
     */
    private ActionForward executePackageAction(ActionMapping mapping,
                                               ActionForm formIn,
                                               HttpServletRequest request,
                                               HttpServletResponse response) {

        RequestContext context = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        User user = context.getLoggedInUser();

        // Load the package list
        String packagesDecl = request.getParameter("packagesDecl");

        Set<String> data = SessionSetHelper.lookupAndBind(request, packagesDecl);
        int numPackages = data.size();

        // Convert the package list to domain objects
        List<PackageListItem> packageListItems =
            new ArrayList<PackageListItem>(numPackages);
        for (String key : data) {
            packageListItems.add(PackageListItem.parse(key));
        }

        // Convert to list of maps
        List<Map<String, Long>> packageListData =
            PackageListItem.toKeyMaps(packageListItems);

       // Load the date selected by the user
        Date earliest = getStrutsDelegate().readDatePicker((DynaActionForm) formIn,
            "date", DatePicker.YEAR_RANGE_POSITIVE);

        // An action must be created for each server in the SSM
        // that subscribes to the channel.
        List<EssentialServerDto> servers = getResult(context);
        for (EssentialServerDto serverDto : servers) {

            Long sid = serverDto.getId();

            Server server = SystemManager.lookupByIdAndUser(sid, user);

            PackageAction packageAction =
                ActionManager.schedulePackageInstall(user, server,
                                                    packageListData, earliest);
        }

        // Remove the packages from session
        SessionSetHelper.obliterate(request, packagesDecl);

        ActionMessages msgs = new ActionMessages();

        // Check to determine to display single or plural confirmation message
        LocalizationService l10n = LocalizationService.getInstance();
        if (numPackages == 1) {
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage("ssm.package.install.message.packageinstall",
                                  l10n.formatNumber(numPackages)));
        }
        else {
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage("ssm.package.install.message.packageinstalls",
                                  l10n.formatNumber(numPackages)));
        }
        strutsDelegate.saveMessages(request, msgs);

        return mapping.findForward("confirm");
    }

}
