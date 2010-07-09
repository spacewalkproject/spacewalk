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
package com.redhat.rhn.frontend.action.user;

import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.ListDisplayTag;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.LookupDispatchAction;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * UserListAction
 * @version $Rev$
 */
public class UserListAction extends LookupDispatchAction {

    private StrutsDelegate getStrutsDelegate() {
        return StrutsDelegate.getInstance();
    }

    /** {@inheritDoc} */
    public ActionForward unspecified(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        Map params = makeParamMap(request);
        return getStrutsDelegate().forwardParams(mapping.findForward("default"), params);
    }

    /**
     * Setup the filter parameter on the request.
     *
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequesT
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward filter(ActionMapping mapping,
                                     ActionForm formIn,
                                     HttpServletRequest request,
                                     HttpServletResponse response) {
        Map params = makeParamMap(request);
        params.put(RequestContext.FILTER_STRING,
                request.getParameter(RequestContext.FILTER_STRING));
        return getStrutsDelegate().forwardParams(mapping.findForward("default"), params);
    }


    /**
     * {@inheritDoc}
     */
    protected Map getKeyMethodMap() {
        HashMap map = new HashMap();
        map.put(RequestContext.FILTER_KEY, "filter");
        return map;
    }

    /**
     * Makes a parameter map containing request params that need to
     * be forwarded on to the success mapping.
     * @param request HttpServletRequest containing request vars
     * @return Returns Map of parameters
     */
    private Map makeParamMap(HttpServletRequest request) {

        Map params = new RequestContext(request).makeParamMapWithPagination();

        return params;
    }

    /**
     * {@inheritDoc}
     */
    protected String getMethodName(ActionMapping mapping,
                                        ActionForm form,
                                        HttpServletRequest request,
                                        HttpServletResponse response,
                                        String parameter) throws Exception {
        String retval =  super.getMethodName(mapping, form, request, response, parameter);
        // If dispatch wasn't found, let's try filter.dispatch
        if (retval == null && parameter.equals(RequestContext.DISPATCH)) {
            parameter = ListDisplayTag.FILTER_DISPATCH;
            retval = super.getMethodName(mapping, form, request, response, parameter);
        }
        return retval;
    }
}
