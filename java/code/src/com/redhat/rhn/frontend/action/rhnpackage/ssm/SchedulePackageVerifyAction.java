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
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.SetCleanup;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.PackageListItem;
import com.redhat.rhn.frontend.events.SsmVerifyPackagesEvent;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.SessionSetHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * Handles the display and capturing of scheduling package verifications for systems in
 * the SSM.
 */
public class SchedulePackageVerifyAction extends RhnAction implements Listable {

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

                RequestContext context = new RequestContext(request);
                StrutsDelegate strutsDelegate = getStrutsDelegate();
                User user = context.getLoggedInUser();

                // Load the date selected by the user
                Date earliest = getStrutsDelegate().readDatePicker(
                    (DynaActionForm) actionForm, "date", DatePicker.YEAR_RANGE_POSITIVE);

                // Parse through all of the results
                DataResult result = (DataResult) getResult(context);
                result.elaborate();

                int numPackages = result.size();

                // Remove the packages from session and the DB
                SessionSetHelper.obliterate(request, request.getParameter("packagesDecl"));

                RhnSetManager.deleteByLabel(user.getId(),
                    RhnSetDecl.SSM_VERIFY_PACKAGES_LIST.getLabel());

                SsmVerifyPackagesEvent event =
                    new SsmVerifyPackagesEvent(user.getId(), earliest, result);
                MessageQueue.publish(event);

                // Check to determine to display single or plural confirmation message
                ActionMessages msgs = new ActionMessages();
                LocalizationService l10n = LocalizationService.getInstance();
                msgs.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("ssm.package.verify.message.packageverifications"));
                strutsDelegate.saveMessages(request, msgs);

                return actionMapping.findForward("confirm");
            }
        }

        // Prepopulate the date picker
        DynaActionForm dynaForm = (DynaActionForm) actionForm;
        DatePicker picker = getStrutsDelegate().prepopulateDatePicker(request, dynaForm,
            "date", DatePicker.YEAR_RANGE_POSITIVE);

        request.setAttribute("date", picker);

        return actionMapping.findForward(RhnHelper.DEFAULT_FORWARD);

    }

    /** {@inheritDoc} */
    public List getResult(RequestContext context) {

        HttpServletRequest request = context.getRequest();
        User user = context.getLoggedInUser();

        // Stuff packages into an RhnSet to be used in the query
        String packagesDecl = (String) request.getAttribute("packagesDecl");
        if (packagesDecl != null) {
            Set<String> data = SessionSetHelper.lookupAndBind(request, packagesDecl);

            RhnSet packageSet = RhnSetManager.createSet(user.getId(),
                RhnSetDecl.SSM_VERIFY_PACKAGES_LIST.getLabel(), SetCleanup.NOOP);

            for (String idCombo : data) {
                PackageListItem item = PackageListItem.parse(idCombo);
                packageSet.addElement(item.getIdOne(), item.getIdTwo(), item.getIdThree());
            }

            RhnSetManager.store(packageSet);
        }

        DataResult results = SystemManager.ssmSystemPackagesToRemove(user,
            RhnSetDecl.SSM_VERIFY_PACKAGES_LIST.getLabel(), false);

        TagHelper.bindElaboratorTo("groupList", results.getElaborator(), request);

        return results;
    }

}
