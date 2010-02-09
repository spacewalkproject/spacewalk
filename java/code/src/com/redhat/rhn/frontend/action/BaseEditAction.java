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
package com.redhat.rhn.frontend.action;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.PersistOperation;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * BaseEditAction
 * @version $Rev$
 */
public abstract class BaseEditAction extends RhnAction {

    public static final String REFRESH = "refreshForm";
    
    /** {@inheritDoc} */
    public final ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {
    
        DynaActionForm form = (DynaActionForm) formIn;
        ActionForward retval = mapping.findForward("default");
        PersistOperation opr = getCommand(new RequestContext(request));
        RequestContext rctx = new RequestContext(request);

        processRequestAttributes(rctx, opr);
        
        boolean refreshForm = isRefresh(rctx);
        if (!refreshForm && isSubmitted(form)) {
            ActionErrors errors = RhnValidationHelper.validateDynaActionForm(
                    this, form);
            if (!errors.isEmpty()) {
                getStrutsDelegate().saveMessages(request, errors);
            } 
            else {
                ValidatorError verrors = processCommandSetters(opr, form);
                
                if (verrors == null) {
                    verrors = opr.store();
                }
                
                if (verrors != null) {
                    ActionErrors storeErrors = 
                        RhnValidationHelper.validatorErrorToActionErrors(verrors);
                    getStrutsDelegate().saveMessages(request, storeErrors);
                } 
                else {
                    createSuccessMessage(request, getSuccessKey(), null);
                    retval = mapping.findForward("success");
                }
            }
        } 
        else if (!refreshForm) {
            processFormValues(opr, form);
        }
        return retval;
    }
    
    /** 
     * Check if the form is to be refreshed.
     * @param form to check
     * @return True if the form should be refreshed, false otherwise.
     */
    private boolean isRefresh(RequestContext rctx) {
        String refresh = rctx.getParam(REFRESH, false);
        if (refresh != null && refresh.equals("true")) {
            return true;
        }
        return false;
    }

    protected abstract String getSuccessKey();

    protected abstract PersistOperation getCommand(RequestContext ctx);

    /**
     * Add attributes to the request.  
     * @param rctx the context of the current request
     */
    protected abstract void processRequestAttributes(RequestContext rctx, 
            PersistOperation opr);
    
    
    /**
     * Call the setters on the PersistOperation in order to setup the
     * object for storage.  This is used on the submit type of request.
     * @param opr to process setters on.
     * @param form web form containing values
     * @return TODO
     */
    protected abstract ValidatorError processCommandSetters(PersistOperation opr, 
            DynaActionForm form);
    
    
    /**
     * Set the values on the form.  This is used during *non* submit requests.
     * @param opr operation to run
     * @param form web form containing values
     */
    protected abstract void processFormValues(PersistOperation opr, 
            DynaActionForm form);
 
}
