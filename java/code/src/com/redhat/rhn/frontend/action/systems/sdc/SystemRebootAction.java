/**
 * Copyright (c) 2014 SUSE
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

import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.ActionChainHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.action.ActionChainManager;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.Date;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * SystemRebootAction handles the interaction of the system reboot.
 */
public class SystemRebootAction extends RhnAction {
    /** Success forward name. */
    private static final String CONFIRM_FORWARD = "confirm";

    /** {@inheritDoc} */
    @Override
    @SuppressWarnings("unchecked")
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
        HttpServletRequest request, HttpServletResponse response) {

        DynaActionForm form = (DynaActionForm) formIn;
        RequestContext context = new RequestContext(request);
        User user = context.getCurrentUser();
        Map<String, Object> params = makeParamMap(request);
        String forward = RhnHelper.DEFAULT_FORWARD;

        Long sid = context.getRequiredParam(RequestContext.SID);
        Server server = SystemManager.lookupByIdAndUser(sid, user);

        if (isSubmitted(form)) {
            Date earliest = getStrutsDelegate().readDatePicker(form, "date",
                DatePicker.YEAR_RANGE_POSITIVE);
            ActionChain actionChain = ActionChainHelper.readActionChain(form, user);
            Action action = ActionChainManager.scheduleRebootAction(user, server, earliest,
                actionChain);
            ActionFactory.save(action);

            if (actionChain == null) {
                String[] messageParams = new String[3];
                messageParams[0] = server.getName();
                messageParams[1] = earliest.toString();
                messageParams[2] = action.getId().toString();
                createMessage(request, "system.reboot.scheduled", messageParams);
            }
            else {
                String[] messageParams = new String[2];
                messageParams[0] = actionChain.getId().toString();
                messageParams[1] = actionChain.getLabel();
                createMessage(request, "message.addedtoactionchain", messageParams);
            }

            // goes to sdc/overview.jsp
            params.put(RequestContext.SID, sid);
            forward = CONFIRM_FORWARD;
        }

        DatePicker picker = getStrutsDelegate().prepopulateDatePicker(request, form,
            "date", DatePicker.YEAR_RANGE_POSITIVE);
        request.setAttribute("date", picker);
        ActionChainHelper.prepopulateActionChains(request);

        request.setAttribute(RequestContext.SID, sid);
        request.setAttribute("system", server);

        SdcHelper.ssmCheck(request, server.getId(), user);

        return getStrutsDelegate().forwardParams(mapping.findForward(forward), params);
    }
}
