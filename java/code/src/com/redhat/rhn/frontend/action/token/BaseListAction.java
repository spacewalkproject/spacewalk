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

package com.redhat.rhn.frontend.action.token;

import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListSessionSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * @author paji
 * BaseListAction
 * @version $Rev$
 */
public abstract class BaseListAction extends RhnAction implements Listable {
    private static final String LIST_NAME = "list";
    private static final String DATA_SET = "all";
    private static final String DESCRIPTION = "description";
    /**
     *  the dataset name
     * @return dataset name
     */
    public String getDataSetName() {
        return DATA_SET;
    }

    /**
     * Returns list name
     * @return the list name
     */
    public String getListName() {
        return LIST_NAME;
    } 
    
    /**
     * Adds activation key info
     * @param request the servlet request.
     */
    public static void setup(HttpServletRequest request) {
        RequestContext context = new RequestContext(request);
        ActivationKey ak = context.lookupAndBindActivationKey();
        request.setAttribute(DESCRIPTION, ak.getNote());
    }

    protected Map getParamsMap(HttpServletRequest request) {
        RequestContext context = new RequestContext(request);
        Map params = new HashMap();
        params.put(RequestContext.TOKEN_ID, 
                    context.getRequiredParam(RequestContext.TOKEN_ID));
        return params;
    }
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        setup(request);
        ListSessionSetHelper helper = new ListSessionSetHelper(this, 
                                        request, getParamsMap(request));
        processHelper(helper);
        helper.execute();
        if (helper.isDispatched()) {
            ActionForward forward = 
                    handleDispatch(helper, mapping, formIn, request, response);
            processPostSubmit(helper);
            return forward;
        }
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    protected  ActionForward handleDispatch(
            ListSessionSetHelper helper, 
            ActionMapping mapping,
            ActionForm formIn, HttpServletRequest request,
            HttpServletResponse response) {
        
        return null;
    }
    
    protected void processHelper(ListSessionSetHelper helper) {
        helper.setDataSetName(getDataSetName());
        helper.setListName(getListName());
    }
    
    protected void processPostSubmit(ListSessionSetHelper helper) {
        helper.destroy();
    }    
}
