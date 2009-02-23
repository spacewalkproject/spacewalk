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
package com.redhat.rhn.frontend.action.schedule;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ActionsAction
 * @version $Rev$
 */
public abstract class ScheduledActionAction extends RhnSetAction {
    
    /**
     * Archives the actions.
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward archiveAction(ActionMapping mapping,
                                       ActionForm formIn,
                                       HttpServletRequest request,
                                       HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        
        User user = requestContext.getLoggedInUser();
        //Update the set first and get the size so we know 
        //how many actions we have archived.
        int numActions = updateSet(request).size();

        //Archive the actions
        ActionManager.archiveActions(user, getSetDecl().getLabel());
        
        //Remove the actions from the users set
        getSetDecl().clear(user);
        Map params = makeParamMap(formIn, request);
        
        ActionMessages msgs = new ActionMessages();
        /**
         * If there was only one action archived, display the "action" archived
         * message, else display the "actions" archived message.
         */
        if (numActions == 1) {
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                     new ActionMessage("message.actionArchived", 
                             LocalizationService.getInstance()
                                                .formatNumber(new Integer(numActions))));
        }
        else {
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                     new ActionMessage("message.actionsArchived", 
                             LocalizationService.getInstance()
                                                .formatNumber(new Integer(numActions))));
        }
        strutsDelegate.saveMessages(request, msgs);
        
        return strutsDelegate.forwardParams(mapping.findForward("default"), params);
    }
    
    /**
     * Cancels the actions.
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward cancelActions(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        
        User user = requestContext.getLoggedInUser();
        // Update the set first and get the size so we know 
        // how many actions we have archived:
        int numActions = updateSet(request).size();

        // Cancel the actions:
        Iterator it = RhnSetManager.findByLabel(user.getId(), 
                getSetDecl().getLabel(), null).getElements().iterator();
        List actionsToCancel = new LinkedList();
        while (it.hasNext()) {
            RhnSetElement actionIdElement = (RhnSetElement)it.next();
            actionsToCancel.add(actionIdElement.getElement());
        }
        
        ActionManager.removeActions(actionsToCancel);
        // Remove the actions from the users set:
        getSetDecl().clear(user);
        Map params = makeParamMap(formIn, request);
        
        ActionMessages msgs = new ActionMessages();
        // If there was only one action cancelled, display the "action" cancelled
        // message, else display the "actions" archived message.
        if (numActions == 1) {
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                     new ActionMessage("message.actionCancelled", 
                             LocalizationService.getInstance()
                                                .formatNumber(new Integer(numActions))));
        }
        else {
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                     new ActionMessage("message.actionsCancelled", 
                             LocalizationService.getInstance()
                                                .formatNumber(new Integer(numActions))));
        }
        strutsDelegate.saveMessages(request, msgs);
        
        return strutsDelegate.forwardParams(mapping.findForward("default"), params);
    }
    
    /**
     * Cancels the actions.
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward cancelActionsConfirm(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RhnSet set = updateSet(request);
        Map params = makeParamMap(formIn, request);
        
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        
        // If no actions were selected, return to the page with a message.
        if (set.isEmpty()) {
            ActionMessages msg = new ActionMessages();
            msg.add(ActionMessages.GLOBAL_MESSAGE, 
                    new ActionMessage("actions.none"));
            strutsDelegate.saveMessages(request, msg);
        }
        
        return strutsDelegate.forwardParams(mapping.findForward("delete"), params);
    }
    
    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put("actions.jsp.archiveactions", "archiveAction");
        map.put("actions.jsp.cancelactions", "cancelActionsConfirm");
        map.put("actions.jsp.confirmcancelactions", "cancelActions");
    }
}
