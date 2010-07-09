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
package com.redhat.rhn.frontend.action.errata;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.SetLabels;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListDispatchAction;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.errata.ErrataManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ErrataConfirmAction
 * @version $Rev$
 */
public class ErrataConfirmAction extends RhnListDispatchAction {

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put("confirm.jsp.confirm", "confirmErrata");
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm form, HttpServletRequest request,
            Map params) {
        RequestContext requestContext = new RequestContext(request);
        Long eid = requestContext.getParamAsLong("eid");

        if (eid != null) {
            params.put("eid", eid);
        }

        //remember the values of the date picker.
        getStrutsDelegate().rememberDatePicker(params, (DynaActionForm)form, "date",
                DatePicker.YEAR_RANGE_POSITIVE);
    }

    /**
     * Action to execute if confirm button is clicked
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward confirmErrata(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();

        User user = requestContext.getLoggedInUser();
        DynaActionForm form = (DynaActionForm) formIn;

        Errata currentErrata = requestContext.lookupErratum();
        DataResult systems = ErrataManager.relevantSystemsInSet(user,
                SetLabels.AFFECTED_SYSTEMS_LIST, currentErrata.getId(), null);

        if (currentErrata != null && !systems.isEmpty()) {
             Action update = ActionManager.createErrataAction(user, currentErrata);
             for (int i = 0; i < systems.size(); i++) {
                 ActionManager.addServerToAction(new Long(((SystemOverview)systems.get(i))
                         .getId().longValue()), update);
             }

             update.setEarliestAction(getStrutsDelegate().readDatePicker(form, "date",
                     DatePicker.YEAR_RANGE_POSITIVE));

             ActionManager.storeAction(update);

             ActionMessages msg = new ActionMessages();
             Object[] args = new Object[3];
             args[0] = currentErrata.getAdvisoryName();
             args[1] = new Long(systems.size());
             args[2] = currentErrata.getId().toString();
             StringBuffer messageKey = new StringBuffer("errataconfirm.schedule");
             if (systems.size() != 1) {
                 messageKey = messageKey.append(".plural");
             }

             msg.add(ActionMessages.GLOBAL_MESSAGE,
                     new ActionMessage(messageKey.toString(), args));
             strutsDelegate.saveMessages(request, msg);
             return mapping.findForward("confirmed");
        }

        // Something went wrong! Notify user:
        ActionMessages msg = new ActionMessages();
        msg.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage("errataconfirm.nosystems"));
        strutsDelegate.saveMessages(request, msg);
        Map params = makeParamMap(formIn, request);
        return strutsDelegate.forwardParams(mapping.findForward("default"), params);
    }

}
