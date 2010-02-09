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

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * A base class for performing common list actions for
 * those struts actions that must extend LookupDispatchAction,
 * but do not manage a RhnSet.
 * 
 * Example: a confirm page.
 * 
 * @see com.redhat.rhn.frontend.action.common.RhnSetAction
 * @version $Rev$
 */
public abstract class RhnListDispatchAction extends RhnLookupDispatchAction {

    /**
     * {@inheritDoc}
     */
    protected Map getKeyMethodMap() {
        HashMap map = new HashMap();
        map.put(RequestContext.FILTER_KEY, "filter");
        processMethodKeys(map);
        return map;
    }
    
    /**
     * Setup the filter parameter on the request.
     *
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward filter(ActionMapping mapping,
                                     ActionForm formIn,
                                     HttpServletRequest request,
                                     HttpServletResponse response) {
        Map params = new HashMap();
        //Put the filter string as a parameter
        params.put(RequestContext.FILTER_STRING,
                request.getParameter(RequestContext.FILTER_STRING));
        //get any other important parameters, but skip pagination
        processParamMap(formIn, request, params);
        String forward = getForwardName(request);
        return getStrutsDelegate().forwardParams(mapping.findForward(forward), params);
    }
    
    /**
     * Default action to execute if dispatch parameter is missing
     * or isn't in map
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward unspecified(ActionMapping mapping,
                                     ActionForm formIn,
                                     HttpServletRequest request,
                                     HttpServletResponse response) {
        Map params = makeParamMap(formIn, request);
        String filter = request.getParameter(RequestContext.FILTER_STRING);
        if (filter != null) {
            params.put(RequestContext.FILTER_STRING, filter);
        }
        String forward = getForwardName(request);
        return getStrutsDelegate().forwardParams(mapping.findForward(forward), params);
    }
    
    /**
     * Makes a parameter map containing request params that need to
     * be forwarded on to the success mapping.
     * @param request HttpServletRequest containing request vars
     * @return Returns Map of parameters
     * TODO: was private
     */
    protected Map makeParamMap(ActionForm form, HttpServletRequest request) {

        RequestContext rctx = new RequestContext(request);
        Map params = rctx.makeParamMapWithPagination();
        processParamMap(form, request, params);

        return params;
    }
    
    /**
     * Here is a way for subclasses to serve multiple possible forwards.
     * @param request The request object containing possibly needed parameters.
     * @return default unless overridden by subclass.
     */
    protected String getForwardName(HttpServletRequest request) {
        return RhnHelper.DEFAULT_FORWARD;
    }
    
    /**
     * Add a success message to the request with 1 parameter:
     *
     * Your System55 has been updated
     *
     * where System55 is the value placed in param1.  param1
     *
     * @param req to add the message to
     * @param msgKey resource key to lookup
     * @param param1 String value to fill in for the first parameter.
     *               (param1 is HTML escaped as well)
     */
    protected void createSuccessMessage(HttpServletRequest req, String msgKey,
            String param1) {
        ActionMessages msg = new ActionMessages();
        Object[] args = new Object[1];
        args[0] = StringEscapeUtils.escapeHtml(param1);
        msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(msgKey, args));
        getStrutsDelegate().saveMessages(req, msg);
    }
    
    protected abstract void processParamMap(ActionForm form,
            HttpServletRequest request, Map params);
    
    /**
     * This method is used to add additional buttons to a list display. It is
     * called from getKeyMethodMap. Simply add your resource bundle name as the
     * key to the given map, and the method name as the value. For example,
     * if you have a resource bundle key of "failed.jsp.rescheduleActions" and
     * a method in your Struts action called "rescheduleAll" the result should
     * look as follows:
     * 
     * <code>
     *    map.put("failed.jsp.rescheduleActions", "rescheduleAll");
     * </code>
     * 
     * If there are no additional actions then simply return.
     * @param map Mapping between method and button names.
     */
    protected abstract void processMethodKeys(Map map);
}
