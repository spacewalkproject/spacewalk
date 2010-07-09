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

import com.redhat.rhn.common.db.datasource.DataResult;

import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.SetCleanup;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.PackageListItem;

import com.redhat.rhn.frontend.events.SsmRemovePackagesEvent;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.frontend.struts.SessionSetHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.log4j.Logger;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.Date;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Handles the display and capture of scheduling package removals for systems in the SSM.
 *
 */
public class SchedulePackageRemoveAction extends RhnListAction implements Listable {

    private static final String DATA_SET = "pageList";
    private static Logger log = Logger.getLogger(SchedulePackageRemoveAction.class);

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

        // Prepopulate the date picker
        DynaActionForm dynaForm = (DynaActionForm) actionForm;
        DatePicker picker = getStrutsDelegate().prepopulateDatePicker(request, dynaForm,
            "date", DatePicker.YEAR_RANGE_POSITIVE);

        request.setAttribute("date", picker);

        return actionMapping.findForward(RhnHelper.DEFAULT_FORWARD);

    }

    /** {@inheritDoc} */
    public List getResult(RequestContext context) {
        return getResult(context, false);

    }

    /**
     * Provide the data result
     * @param context The request context
     * @param shorten whether to return a DataResult with the full ealborator
     *          or a shortened much faster ones
     * @return the List
     */
    public List getResult(RequestContext context, boolean shorten) {
        HttpServletRequest request = context.getRequest();
        User user = context.getLoggedInUser();

        // Stuff packages into an RhnSet to be used in the query
        String packagesDecl = (String) request.getAttribute("packagesDecl");
        if (packagesDecl != null) {
            Set<String> data = SessionSetHelper.lookupAndBind(request, packagesDecl);

            RhnSet packageSet = RhnSetManager.createSet(user.getId(),
                RhnSetDecl.SSM_REMOVE_PACKAGES_LIST.getLabel(), SetCleanup.NOOP);

            for (String idCombo : data) {
                PackageListItem item = PackageListItem.parse(idCombo);
                packageSet.addElement(item.getIdOne(), item.getIdTwo(), item.getIdThree());
            }

            RhnSetManager.store(packageSet);
        }

        DataResult results = SystemManager.ssmSystemPackagesToRemove(user,
            RhnSetDecl.SSM_REMOVE_PACKAGES_LIST.getLabel(), shorten);

        TagHelper.bindElaboratorTo("groupList", results.getElaborator(), request);

        return results;
    }

    /**
     * Creates the package removal action.
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
        // Load the date selected by the user
        Date earliest = getStrutsDelegate().readDatePicker((DynaActionForm) formIn,
            "date", DatePicker.YEAR_RANGE_POSITIVE);

        // Parse through all of the results
        DataResult result = (DataResult) getResult(context, true);
        result.elaborate();

        log.debug("Publishing schedule package remove event to message queue.");
        SsmRemovePackagesEvent event = new SsmRemovePackagesEvent(user.getId(), earliest,
                result);
        MessageQueue.publish(event);

        log.debug("Clearing set.");
        // Remove the packages from session and the DB
        SessionSetHelper.obliterate(request, request.getParameter("packagesDecl"));

        log.debug("Deleting set.");
        RhnSetManager.deleteByLabel(user.getId(),
            RhnSetDecl.SSM_REMOVE_PACKAGES_LIST.getLabel());

        ActionMessages msgs = new ActionMessages();

        // Check to determine to display single or plural confirmation message
        msgs.add(ActionMessages.GLOBAL_MESSAGE,
            new ActionMessage("ssm.package.remove.message.packageremovals"));
        strutsDelegate.saveMessages(request, msgs);

        return mapping.findForward("confirm");
    }

}

