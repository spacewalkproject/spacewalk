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
package com.redhat.rhn.frontend.action.monitoring.notification;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.monitoring.ModifyMethodCommand;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.ArrayList;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * BaseMethodEditAction - Action for creating a notification method. 
 * @version $Rev: 1 $
 */
public abstract class BaseMethodEditAction extends RhnAction {

    /**
     * Logger for this class
     */
    private static Logger logger = Logger
            .getLogger(BaseMethodEditAction.class);


    public static final String METHOD = "method";
    public static final String NAME = "name";
    public static final String EMAIL = "email";
    public static final String TYPE = "type";
    public static final String METHOD_TYPES = "method_types";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        if (logger.isDebugEnabled()) {
            logger.debug("execute(ActionMapping mapping=" + mapping + 
                    ", ActionForm formIn=" + formIn + 
                    ", HttpServletRequest request=" + request +
                    ", HttpServletResponse response=" + response + ") - start");
        }
        
        DynaActionForm form = (DynaActionForm) formIn;
        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        ModifyMethodCommand cmd = createCommand(requestContext);
        request.setAttribute(METHOD, cmd.getMethod());
        request.setAttribute(RhnHelper.TARGET_USER, cmd.getUser());
        request.setAttribute(METHOD_TYPES, makeMethodTypes());
        
        if (isSubmitted(form)) {
            ActionErrors errors = RhnValidationHelper.validateDynaActionForm(
                    this, form);
            if (!errors.isEmpty()) {
                strutsDelegate.saveMessages(request, errors);
             }
            else {
                processType(cmd, form);
                cmd.setMethodName(form.getString(NAME));
                cmd.setEmail(form.getString(EMAIL));
                User cu = requestContext.getCurrentUser();
                ValidatorError e = cmd.storeMethod(cu);
                if (e == null) {
                    createSuccessMessage(request, "method.createsuccess", 
                            cmd.getMethod().getMethodName());
                    ActionForward returnActionForward = mapping
                            .findForward("success");
                    if (logger.isDebugEnabled()) {
                        logger.debug("execute(ActionMapping, ActionForm, " +
                                "HttpServletRequest, HttpServletResponse)" +
                                " - end - return value=" + returnActionForward);
                    }
                    return returnActionForward;
                } 
                else {
                    ValidatorError[] verrors = new ValidatorError[1];
                    verrors[0] = e;
                    errors.add(RhnValidationHelper.validatorErrorToActionErrors(verrors));
                    strutsDelegate.saveMessages(request, errors);
                }
            }
        }
        

        ActionForward returnActionForward = strutsDelegate.forwardParams(mapping
                .findForward("default"), request.getParameterMap());
        if (logger.isDebugEnabled()) {
            logger.debug("execute(ActionMapping, ActionForm, HttpServletRequest, " +
                            "HttpServletResponse) - end - return value=" + 
                            returnActionForward);
        }
        return returnActionForward;
    }
    
    private Object makeMethodTypes() {
        if (logger.isDebugEnabled()) {
            logger.debug("makeMethodTypes() - start");
        }

        ArrayList result = new ArrayList();
        result.add(lv("method-form.jspf.email",
                "Email"));
        result.add(lv("method-form.jspf.pager",
                "Pager"));
        result.add(lv("method-form.jspf.snmp",
                "SNMP"));
        
        localize(result);

        if (logger.isDebugEnabled()) {
            logger.debug("makeMethodTypes() - end - return value=" + result);
        }
        return result;
    }

    private void processType(ModifyMethodCommand cmd, DynaActionForm form) {
        if (logger.isDebugEnabled()) {
            logger.debug("processType(ModifyMethodCommand cmd=" + cmd +
                    ", DynaActionForm form=" + form + ") - start");
        }

        String selectedType = form.getString(TYPE);
        cmd.updateMethodType(selectedType);

        if (logger.isDebugEnabled()) {
            logger.debug("processType(ModifyMethodCommand, " +
                    "DynaActionForm) - end");
        }
    }
    
    /**
     * Subclass implements method for creating the ModifyMethodCommand
     * @param rctx RequestContext used to fetch information.
     * @return created ModifyMethodCommand
     */
    protected abstract ModifyMethodCommand createCommand(RequestContext rctx);

}
