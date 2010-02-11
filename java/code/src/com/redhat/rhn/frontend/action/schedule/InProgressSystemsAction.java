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
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
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
 * InProgressSystemsAction
 * @version $Rev$
 */
public class InProgressSystemsAction extends RhnSetAction {
    
    /** 
     * Removes unscheduleaction set from server actions.
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward unscheduleAction(ActionMapping mapping,
                                          ActionForm formIn,
                                          HttpServletRequest request,
                                          HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();

        User user = requestContext.getLoggedInUser();
        Long aid = requestContext.getParamAsLong("aid");
        Action action = ActionManager.lookupAction(user, aid);
        /*
         * First we need to update the list. This is allows any changes to
         * the set made on the current page to work correctly without having
         * the user press the update list button.
         */
        int numSystems = updateSet(request).size();
        ActionMessages msgs = new ActionMessages();
        Map params = makeParamMap(formIn, request);
        
        if (numSystems == 0) {
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("systems.none"));
            strutsDelegate.saveMessages(request, msgs);
            return strutsDelegate.forwardParams(mapping.findForward("default"), params);
        }
        
        
        ActionFactory.removeActionForSystemSet(aid, "unscheduleaction", user);
        
        /**
         * If we've unscheduled the action for more than one system, send the pluralized
         * version of the message.
         */
        if (numSystems == 1) {
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                     new ActionMessage("message.unscheduled.system",
                             action.getFormatter().getName(),
                             LocalizationService.getInstance()
                                                .formatNumber(new Integer(numSystems))));
        }
        else {
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                     new ActionMessage("message.unscheduled.systems", 
                             action.getFormatter().getName(),
                             LocalizationService.getInstance()
                                                .formatNumber(new Integer(numSystems))));
        }
        strutsDelegate.saveMessages(request, msgs);
        
        //clear set
        RhnSetDecl.ACTIONS_UNSCHEDULE.clear(user);
        
        /*
         * See how many remaining systems are in progress for this action. If > 0, return
         * to the default mapping, otherwise, go to the pending actions page.
         */
        int remainingSystems = ActionManager.inProgressSystems(user, action, null).size();
        if (remainingSystems > 0) {
            return strutsDelegate.forwardParams(mapping.findForward("default"), params);
        }
        else {
            return mapping.findForward("noSystemsLeft");
        }
    }

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User user, 
                                       ActionForm formIn, 
                                       HttpServletRequest request) {
        RequestContext requestContext = new RequestContext(request);
        Long aid = requestContext.getParamAsLong("aid");
        Action action = ActionManager.lookupAction(user, aid);
        //Get an "unelaborated" DataResult containing all of the 
        //user's visible systems
        return ActionManager.inProgressSystems(user, action, null);
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put("actions.jsp.unscheduleaction", "unscheduleAction");
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
        return RhnSetDecl.ACTIONS_UNSCHEDULE;
    }
}
