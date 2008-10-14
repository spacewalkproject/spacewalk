package com.redhat.rhn.frontend.action;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;

/**
 * Abstract POST action class that provides for setup->confirm->commit
 * lifecycle.  This should probably be added as a <i>real</i> class and
 * promoted for general use as I suspect that many other pages using the rhn
 * list tag need to work the same way.
 * @version $Rev$
 */
public abstract class DispatchedAction extends RhnAction {
    
    /**
     * ${@inheritDoc}
     */
    public ActionForward execute(
            ActionMapping mapping, 
            ActionForm form,
            HttpServletRequest request, 
            HttpServletResponse response) throws Exception {
        
        RequestContext context = new RequestContext(request);
        
        if (context.hasParam(RequestContext.DISPATCH)) {
            return commitAction(mapping, form, request, response);
        }
        
        if (context.hasParam(RequestContext.CONFIRM)) {
            return confirmAction(mapping, form, request, response);
        }

        return setupAction(mapping, form, request, response, context.isSubmitted());
    }
    
    /**
     * Called to setup the page for display.
     * @param mapping An action mapping.
     * @param form The associated form.
     * @param request The requst.
     * @param response The respoinse.
     * @param submitted The submitted (GET|POST) flag.
     * @return The action forward.
     * @throws Exception
     */
    protected abstract ActionForward setupAction(
            ActionMapping mapping, 
            ActionForm form,
            HttpServletRequest request, 
            HttpServletResponse response,
            boolean submitted) throws Exception;
    
    /**
     * Called when a page form has been submitted and requires confirmation.
     * @param mapping An action mapping.
     * @param form The associated form.
     * @param request The requst.
     * @param response The respoinse.
     * @return The action forward.
     * @throws Exception
     */
    protected ActionForward confirmAction(
            ActionMapping mapping, 
            ActionForm form,
            HttpServletRequest request, 
            HttpServletResponse response) throws Exception
    {
        throw new Exception("confirmAction called but not overridden");
    }
    
    /**
     * Called when a page form has been submitted and confirmed.
     * Applies page submit to the system.
     * @param mapping An action mapping.
     * @param form The associated form.
     * @param request The requst.
     * @param response The respoinse.
     * @return The action forward.
     * @throws Exception
     */
    protected ActionForward commitAction(
            ActionMapping mapping, 
            ActionForm form,
            HttpServletRequest request, 
            HttpServletResponse response) throws Exception
    {
        throw new Exception("commitAction called but not overridden");
    }
}
