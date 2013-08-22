/**
 * Copyright (c) 2013 SUSE
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

package com.redhat.rhn.frontend.action.ssm;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.events.SsmSystemRebootEvent;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;


/**
 * Reboot Systems in the SSM miscellaneous actions.
 *
 * @author Bo Maryniuk <bo@suse.de>
 */
public class RebootSystemAction
        extends RhnListAction
        implements Listable {

    @Override
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm actionForm,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        List result = this.getResult(context);
        DynaActionForm form = (DynaActionForm) actionForm;
        RhnSet set = RhnSetDecl.SSM_SYSTEMS_REBOOT.get(context.getCurrentUser());
        RhnListSetHelper helper = new RhnListSetHelper(request);
        String forwardPageId = RhnHelper.DEFAULT_FORWARD;
        ActionMessages actionMessages = new ActionMessages();
        ActionErrors actionErrors = new ActionErrors();

        if (ListTagHelper.getListAction("systemList", request) != null) {
            helper.execute(set, "systemList", result);
        }

        if (!set.isEmpty()) {
            helper.syncSelections(set, result);
            ListTagHelper.setSelectedAmount("systemList", set.size(), request);
        }

        request.setAttribute(RequestContext.PAGE_LIST, result);
        ListTagHelper.bindSetDeclTo("systemList",
                                    RhnSetDecl.SSM_SYSTEMS_REBOOT,
                                    request);
        request.setAttribute(RequestContext.PAGE_LIST, result);
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        TagHelper.bindElaboratorTo("systemList",
                                   ((DataResult) result).getElaborator(),
                                   request);

        if ((request.getParameter("dispatch") != null) &&
            (context.wasDispatched("installconfirm.jsp.confirm"))) {
            List<Long> serverIdsToReboot = new ArrayList<Long>();
            Iterator<Long> sysIds = set.getElementValues().iterator();
            while (sysIds.hasNext()) {
                serverIdsToReboot.add(sysIds.next());
            }

            if (!serverIdsToReboot.isEmpty()) {
                // Make an event
                MessageQueue.publish(new SsmSystemRebootEvent(
                        context.getLoggedInUser().getId(),
                        this.getStrutsDelegate().readDatePicker(form,
                                                            "date",
                                                            DatePicker.YEAR_RANGE_POSITIVE),
                        serverIdsToReboot));
                actionMessages.add(
                        ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("ssm.misc.reboot.message.success.default"));

                // Clear the selection from the form
                set.clear();
                RhnSetDecl.SSM_SYSTEMS_REBOOT.clear(context.getLoggedInUser());

                forwardPageId = "confirm";
            }
            else {
                actionErrors.add(
                        ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("ssm.misc.reboot.message.error.noselect"));
            }
        }

        request.setAttribute("date", this.getStrutsDelegate().prepopulateDatePicker(
                request, form, "date", DatePicker.YEAR_RANGE_POSITIVE));

        this.getStrutsDelegate().saveMessages(request, actionMessages);
        this.getStrutsDelegate().saveMessages(request, actionErrors);

        return mapping.findForward(forwardPageId);
    }


    /**
     * Get the dataset result.
     *
     * @param context Request context.
     * @return List of SystemOverview objects.
     */
    public List getResult(RequestContext context) {
        List<SystemOverview> systems = SystemManager.inSet(context.getCurrentUser(),
                                                           RhnSetDecl.SYSTEMS.getLabel());
        for (Iterator<SystemOverview> itr = systems.iterator(); itr.hasNext();) {
            itr.next().setSelectable(1);
        }

        return systems;
    }
}
