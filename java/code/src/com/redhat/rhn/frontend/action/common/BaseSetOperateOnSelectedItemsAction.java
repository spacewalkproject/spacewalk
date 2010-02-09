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
package com.redhat.rhn.frontend.action.common;

import com.redhat.rhn.common.util.MethodUtil;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.Iterator;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * BaseSetOperateOnSelectedItemsAction - extension of RhnSetAction
 * that provides a framework for performing a specified business
 * operation on the currently selected items in the list.
 *  
 * @version $Rev: 51639 $
 */
public abstract class BaseSetOperateOnSelectedItemsAction extends RhnSetAction {
    
    private static final String DEFAULT_CALLBACK = "operateOnElement";
    
    /**
     * Execute some operation on the set of selected items.  Forwards
     * to the "default"
     * NOTE:  Must define StringResource for failure and success messages:
     * getSetName() + ".success" for providing a parameterized
     * getSetName() + ".failure" for providing a parameterized
     * message to the UI that would say "2 ServerProbe Suite(s) deleted."
     * 
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @param callbackMethodName Name of the call back method.
     * @return The ActionForward to go to next.
     */
    public ActionForward operateOnSelectedSet(ActionMapping mapping,
                                       ActionForm formIn,
                                       HttpServletRequest request,
                                       HttpServletResponse response,
                                       String callbackMethodName) {
        RhnSet set = updateSet(request);
        
        //if they chose no probe suites, return to the same page with a message
        if (set.isEmpty()) {
            return handleEmptySelection(mapping, formIn, request);
        }

        Map params = makeParamMap(formIn, request);
        RequestContext rctx = new RequestContext(request);
        User user = rctx.getLoggedInUser();
        
        StrutsDelegate strutsDelegate = getStrutsDelegate();

        int successCount = 0;
        int failureCount = 0;
        for (Iterator i = set.getElements().iterator(); i.hasNext();) {
            RhnSetElement element = (RhnSetElement) i.next();
            boolean success = callMethod(callbackMethodName,
                                         new Object[] {formIn, 
                                                       request,
                                                       element,
                                                       user});
            if (success) {
                successCount++;
            }
            else {
                failureCount++;
            }
            
            i.remove();
            
        }            

        RhnSetManager.store(set);

        ActionMessages msg = new ActionMessages();
        processMessage(msg, callbackMethodName, successCount, failureCount);
        strutsDelegate.saveMessages(request, msg);
        
        String forward = getForwardName(request);
        return strutsDelegate.forwardParams(mapping.findForward(forward), params);
    }




    /**
     * This method is to be called when the rhnsetis empty
     * i.e no checked boxes were selected...
     * This method basically sets up the error message
     * and returns the correct action forward.
     * @param mapping ActionMapping
     * @param request ServletRequest
     * @return The ActionForward to go to next.
     */
    protected ActionForward handleEmptySelection(ActionMapping mapping,
                                                 ActionForm formIn,
                                                 HttpServletRequest request) {
        
        StrutsDelegate strutsDelegate = getStrutsDelegate();        
        
        Map params = makeParamMap(formIn, request);
        ActionMessages msg = new ActionMessages();
        msg.add(ActionMessages.GLOBAL_MESSAGE, getEmptySelectionMessage());
        strutsDelegate.saveMessages(request, msg);
        
        String forward = getForwardName(request);
        return strutsDelegate.forwardParams(mapping.findForward(forward), params);
    }
    
    /**
     * 
     * @return default empty selection message 
     */
    protected ActionMessage getEmptySelectionMessage() {
        return new ActionMessage("emptyselectionerror");
    }

    /**
     * 
     * Raises an error message saying javascript is required 
     * to process this page
     * @param mapping struts ActionMapping
     * @param formIn struts ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return An action forward to the default page with the error message
     */
    public ActionForward handleNoScript(ActionMapping mapping,
                            ActionForm formIn,
                            HttpServletRequest request,
                            HttpServletResponse response) {
        StrutsDelegate strutsDelegate = getStrutsDelegate();        
        ActionMessages msg = new ActionMessages();
        msg.add(ActionMessages.GLOBAL_MESSAGE, getNoScriptMessage());
        strutsDelegate.saveMessages(request, msg);        
        
        Map params = makeParamMap(formIn, request);
        String forward = getForwardName(request);
        return strutsDelegate.forwardParams(mapping.findForward(forward), params);
    }    

    /**
     * 
     * @return default no java script message  
     */
    protected ActionMessage getNoScriptMessage() {
        return new ActionMessage("nocripterror");
    }

    private boolean callMethod(String methodName, Object[] args) {
        Boolean success = (Boolean) MethodUtil.callMethod(this, methodName, args);
        return success.booleanValue();
    }
    
    
    /**
     * This basically adds all the action messages
     * that will be used for validation errors
     * or status messages
     * @param msgs container of the messages
     * @param methodName name of the caller method  which is used as a key
     * @param successCount the number of successful actions
     * @param failureCount the number of failures.
     */
    protected void processMessage(ActionMessages msgs,
                                  String methodName,
                                  long successCount,
                                  long failureCount) {
        
        addToMessage(msgs, methodName, true, successCount);
        addToMessage(msgs, methodName, false, failureCount);

    }


    protected void addToMessage(ActionMessages msg, 
                                String methodName, 
                                boolean b,
                                long count) {
        if (count > 0) {
            Object[] args = new Object[]{String.valueOf(count)};
            addToMessage(msg, methodName, b, args);
        }
       
    }




    protected void addToMessage(ActionMessages msg, 
                                String methodName, 
                                boolean success,
                                Object[] args) {
        
        String key = getSetDecl().getLabel(); 
        if (!DEFAULT_CALLBACK.equals(methodName)) {
            key = getSetDecl().getLabel() + "." + methodName;
        }    
        
        if (success) {
            key += ".success";
        }
        else {
            key += ".failure";
        }
        ActionMessage temp =  new ActionMessage(key, args);
        msg.add(ActionMessages.GLOBAL_MESSAGE, temp);
        
    }    
    
    
    
    
    /**
     * Execute some operation on the set of selected items.  Forwards
     * to the "default"
     * NOTE:  Must define StringResource for failure and success messages:
     * getSetName() + ".success" for providing a parameterized
     * message to the UI that would say "2 ServerProbe Suite(s) deleted."
     * 
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward operateOnSelectedSet(ActionMapping mapping,
                                       ActionForm formIn,
                                       HttpServletRequest request,
                                       HttpServletResponse response) {
        
        return operateOnSelectedSet(mapping,
                                        formIn,
                                        request,
                                        response,
                                        DEFAULT_CALLBACK);
    }
    
    /** 
     * Here we go to the subclass to actually operate on the element
     * @param elementIn we want to fetch the ID from
     * @param userIn who is performing the operation
     */
    protected Boolean operateOnElement(ActionForm form, 
                                        HttpServletRequest request, 
                                        RhnSetElement elementIn, 
                                        User userIn) {
        //NO-OP: this method is to be overridden by the sub-class
        // if 
        /*
         * operateOnSelectedSet(ActionMapping mapping,
                                       ActionForm formIn,
                                       HttpServletRequest request,
                                       HttpServletResponse response)
             is called...
         */
        return Boolean.TRUE;
    }
    
}
