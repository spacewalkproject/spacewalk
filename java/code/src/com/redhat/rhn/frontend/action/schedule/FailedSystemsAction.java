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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * FailedSystemsAction
 * @version $Rev$
 */
public class FailedSystemsAction extends RhnSetAction {

    
    /**
     * Resechedules the action whose id is found in the aid formvar.
     * @param mapping actionmapping
     * @param formIn form containing input
     * @param request HTTP request
     * @param response HTTP response
     * @return the confirmation page.
     */
    public ActionForward rescheduleActions(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        
        Long aid = requestContext.getParamAsLong("aid");
        Action action = ActionManager.lookupAction(requestContext.getLoggedInUser(), 
                                                   aid);
        updateSet(request);        
        ActionManager.rescheduleAction(action, true);
        
        ActionMessages msgs = new ActionMessages();
        
        msgs.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage("message.actionrescheduled",
                        action.getActionType().getName()));
        getStrutsDelegate().saveMessages(request, msgs);        
        
        return getStrutsDelegate().forwardParam(
                mapping.findForward("scheduled"), "aid", String.valueOf(aid));
    }
    
    /** {@inheritDoc} */
    protected DataResult getDataResult(User user, ActionForm form, 
            HttpServletRequest request) {
        RequestContext requestContext = new RequestContext(request);
        Long aid = requestContext.getParamAsLong("aid");
        Action action = ActionManager.lookupAction(user, aid);
        //Get an "unelaborated" DataResult containing all of the 
        //user's visible systems
        return ActionManager.failedSystems(user, action, null);
    }    
    
    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put("failedsystems.jsp.rescheduleactions", "rescheduleActions");
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm formIn, 
                                   HttpServletRequest request, 
                                   Map params) {
        RequestContext requestContext = new RequestContext(request);
        params.put("aid", requestContext.getParamAsLong("aid"));
    }

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.SYSTEMS_FAILED;
    }    
}
