/**
 * Copyright (c) 2009--2017 Red Hat, Inc.
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

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.user.User;
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
import java.util.Map;

/**
 * SystemNoteEditAction
 * @version $Rev: 1 $
 */
public class SystemFailEventAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm form,
            HttpServletRequest request,
            HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        DynaActionForm daForm = (DynaActionForm)form;
        Long sid = context.getRequiredParam("sid");
        Long aid = context.getRequiredParam("aid");
        request.setAttribute("sid", sid);
        request.setAttribute("aid", aid);
        Map params = makeParamMap(request);
        if (isSubmitted(daForm)) {
            User user = context.getCurrentUser();
            String description = daForm.getString("description");
            ActionManager.failSystemAction(user, sid, aid, description);
            Action action = ActionFactory.lookupByUserAndId(context.getCurrentUser(), aid);
            createSuccessMessage(request, "message.failactionsuccess", action.getName());
            return getStrutsDelegate().forwardParams(mapping.findForward(RhnHelper
                    .CONFIRM_FORWARD), params);
        }
        return getStrutsDelegate().forwardParams(
                mapping.findForward(RhnHelper.DEFAULT_FORWARD), params);
    }

}
