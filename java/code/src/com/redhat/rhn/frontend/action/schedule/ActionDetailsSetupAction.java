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
package com.redhat.rhn.frontend.action.schedule;

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFormatter;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.action.ActionManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * UserPreferencesAction, edit action for user detail page
 * @version $Rev: 1226 $
 */
public class ActionDetailsSetupAction extends RhnAction {
 
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        
        Long aid = requestContext.getRequiredParam("aid");
        
        Action action = ActionManager.lookupAction(requestContext.getLoggedInUser(),
                aid);
        ActionFormatter af = action.getFormatter();        
        request.setAttribute("actionname", af.getName());
        request.setAttribute("actiontype", af.getActionType());
        request.setAttribute("scheduler", af.getScheduler());
        request.setAttribute("earliestaction", af.getEarliestDate());
        request.setAttribute("actionnotes", af.getNotes());

        return mapping.findForward("default");
    }
    
}
