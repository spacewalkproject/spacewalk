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
package com.redhat.rhn.frontend.struts;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * BaseListAction - basic base class you can extend to provide functionality for
 * generating a list with support for precondition checking, and setup for building
 * the pageList attribute on the Request.  Meant for lists without RhnSet selections.
 *
 * @version $Rev$
 */
public abstract class BaseListAction extends RhnListAction {

    // public static final String PAGE_LIST = "pageList";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        String errorKey = checkPreConditions(requestContext);
        if (errorKey != null) {
            ActionMessages msg = new ActionMessages();
            msg.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage(errorKey));
            strutsDelegate.saveMessages(request, msg);
            return strutsDelegate.forwardParams(mapping.findForward("preconditionfailed"),
                    request.getParameterMap());
        }
        else {
            User user = requestContext.getCurrentUser();
            PageControl pc = getNewPageControl(requestContext);
            processPageControl(pc);

            if (pc != null) {
                clampListBounds(pc, request, user);
            }
            DataResult dr = getDataResult(requestContext, pc);

            request.setAttribute(RequestContext.PAGE_LIST, dr);
            processRequestAttributes(requestContext);
            processForm(requestContext, formIn);
            return strutsDelegate.forwardParams(mapping.findForward("default"),
                    request.getParameterMap());
        }
    }

    /**
     * Method to get a new instance of a page control.
     * @param rctx RequestContext for this request
     * @return a PageControl if one is necessary
     */
    protected PageControl getNewPageControl(RequestContext rctx) {
        if (rctx.isRequestedExport()) {
            return null;
        }
        else {
            PageControl pc =  new PageControl();
            pc.setPageSize(rctx.getLoggedInUser().getPageSize());
            return pc;
        }
    }

    /**
     * Extension point to allow controlling the pagination such as
     * turning on filtering, alphabar, etc. Does nothing by default.
     * @param pc PageControl
     */
    protected void processPageControl(PageControl pc) {
        return;
    }


    /**
     * Add attributes to the request. Does nothing by default
     * @param rctx the context of the current request
     */
    protected void processRequestAttributes(RequestContext rctx) {
        return;
    }

    /**
     * Override if you want to check a precondition before executing this Action.
     * If the precondition fails and returns a NON-NULL return value this will
     * be used as a Resource key for an error message will forward the request
     * to the "error" ActionForward.
     * @param rctx the context of the current request
     *
     * @return String key for an error message.
     */
    protected String checkPreConditions(RequestContext rctx) {
        // By default we don't do anything.
        return null;
    }

    /**
     * Returns the list data used by the list
     * @param rctx Currently active RequestContext.
     * @param pc boundary values
     * @return List of ProbeSuites bounded by the values of the PageControl.
     */
    protected abstract DataResult getDataResult(RequestContext rctx, PageControl pc);

    /**
     * Process a form. Used for adding datepickers on confirm pages (for example).
     * By default, do nothing.
     * @param ctxt The request context
     * @param form struts ActionForm
     */
    protected void processForm(RequestContext ctxt, ActionForm form) {
        return; //default: nothing
    }



}
