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
package com.redhat.rhn.frontend.action.rhnpackage.profile;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.SessionSetHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.manager.profile.ProfileManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * CompareSystemSetupAction
 * @version $Rev$
 */
public class CompareSystemSetupAction extends RhnAction {

    private static final String LIST_NAME = "compareList";
    public static final String DATA_SET = "pageList";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        processRequestAttributes(requestContext);
        
        Long sid = requestContext.getRequiredParam(RequestContext.SID);
        Long sid1 = requestContext.getRequiredParam(RequestContext.SID1);
        Set sessionSet = SessionSetHelper.lookupAndBind(request, getDecl(sid));

        //if its not submitted
        // ==> this is the first visit to this page
        // clear the 'dirty set'
        if (!requestContext.isSubmitted()) {
            sessionSet.clear();
        }        

        SessionSetHelper helper = new SessionSetHelper(request);
        
        if (request.getParameter("dispatch") != null) {
            // if its one of the Dispatch actions handle it..            
            helper.updateSet(sessionSet, LIST_NAME);
            if (!sessionSet.isEmpty()) {
                return handleDispatchAction(mapping, requestContext);
            }
            else {
                RhnHelper.handleEmptySelection(request);
                Map params = new HashMap();
                params.put(RequestContext.SID, sid.toString());
                params.put(RequestContext.SID1, sid1.toString());
                return getStrutsDelegate().forwardParams(
                        mapping.findForward("error"), params);
            }
        }   
        DataResult dataSet = getDataResult(requestContext);
        // if its a list action update the set and the selections
        if (ListTagHelper.getListAction(LIST_NAME, request) != null) {
            helper.execute(sessionSet, LIST_NAME, dataSet);
        }        

        // if I have a previous set selections populate data using it       
        if (!sessionSet.isEmpty()) {
            helper.syncSelections(sessionSet, dataSet);
            ListTagHelper.setSelectedAmount(LIST_NAME, sessionSet.size(), request);
        }
        
        request.setAttribute(ListTagHelper.PARENT_URL, 
                request.getRequestURI() + "?sid=" + sid + "&sid_1=" + sid1);  
        
        request.setAttribute(DATA_SET, dataSet);
        
        ListTagHelper.bindSetDeclTo(LIST_NAME, getDecl(sid), request);
        TagHelper.bindElaboratorTo(LIST_NAME, dataSet.getElaborator(), request);
        
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    private ActionForward handleDispatchAction(ActionMapping mapping,
            RequestContext context) {

        Long sid = context.getRequiredParam(RequestContext.SID);
        Long sid1 = context.getRequiredParam(RequestContext.SID1);

        Map params = new HashMap();
        params.put(RequestContext.SID, sid.toString());
        params.put(RequestContext.SID1, sid1.toString());
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        return strutsDelegate.forwardParams(mapping.findForward("submit"), params);
    }

    /**
     * Basically returns the declaration used to store the set of keys..
     * @param sid the server Id
     * @return the declaration.
     */
    public String getDecl(Long sid) {
        return getClass().getName() + sid.toString();
    }

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(RequestContext requestContext) {
        
        Long sid = requestContext.getRequiredParam(RequestContext.SID);
        Long sid1 = requestContext.getRequiredParam(RequestContext.SID1);
        
        DataResult dr = ProfileManager.compareServerToServer(sid,
                sid1, requestContext.getCurrentUser().getOrg().getId(), null);
        
        return dr;
    }

    /**
     * {@inheritDoc}
     */
    protected void processRequestAttributes(RequestContext requestContext) {
        
        Long sid1 = requestContext.getRequiredParam(RequestContext.SID1);
        
        requestContext.lookupAndBindServer();
        
        Server server1 = SystemManager.lookupByIdAndUser(sid1,
                requestContext.getCurrentUser());
        
        requestContext.getRequest().setAttribute("systemname", server1.getName());
    }
}
