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
package com.redhat.rhn.frontend.action.errata;

import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.errata.ErrataManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.actions.LookupDispatchAction;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * DeleteErratumAction
 * @version $Rev$
 */
public class DeleteErratumAction extends LookupDispatchAction {
    
    private StrutsDelegate getStrutsDelegate() {
        return StrutsDelegate.getInstance();
    }
    
    /**
     * This is the equivalent of the SetupAction
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
        
        RequestContext requestContext = new RequestContext(request);
        Errata errata = requestContext.lookupErratum();
        
        request.setAttribute("errata", errata);
        return getStrutsDelegate().forwardParam(mapping.findForward("default"),
                "eid", errata.getId().toString());
    }
    
    
    /**
     * This is the equivalent of the Action
     * Deletes an erratum
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward deleteErratum(ActionMapping mapping,
                                       ActionForm formIn,
                                       HttpServletRequest request,
                                       HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        
        Errata errata = requestContext.lookupErratum();
        ErrataManager.deleteErratum(requestContext.getLoggedInUser(), errata);
        ActionMessages msgs = new ActionMessages();
        msgs.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage("erratum.delete",
                errata.getAdvisoryName()));
        getStrutsDelegate().saveMessages(request, msgs);
        return mapping.findForward("deleted");
    }
    
    /**
     * {@inheritDoc}
     */
    protected Map getKeyMethodMap() {
        HashMap map = new HashMap();
        map.put("delete.jsp.delete", "deleteErratum");
        return map;
    }

}
