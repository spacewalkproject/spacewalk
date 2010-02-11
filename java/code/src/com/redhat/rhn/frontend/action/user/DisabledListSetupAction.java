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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * DisabledListSetupAction
 * @version $Rev$
 */
public class DisabledListSetupAction extends RhnAction {
    public static final String DISPATCH = "dispatch";
    public static final String LIST_NAME = "disabledUserList";
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        
        RequestContext context = new RequestContext(request);
        User user = context.getLoggedInUser();
        PageControl pc = setupPageControl(context);
     
        RhnSet set = getDecl().get(user);

        //if its not submitted
        // ==> this is the first visit to this page
        // clear the 'dirty set'
        if (!context.isSubmitted()) {
            set.clear();
            RhnSetManager.store(set);
        }
        RhnListSetHelper helper = new RhnListSetHelper(request);
        
        if (request.getParameter(DISPATCH) != null) {
            // if its one of the Dispatch actions handle it..            
            helper.updateSet(set, LIST_NAME);
            if (!set.isEmpty()) {
                return handleDispatchAction(mapping, context);
            }
            else {
                RhnHelper.handleEmptySelection(request);
            }
        }    
        
        DataResult dr = UserManager.disabledInOrg(user, pc);
        
        dr.setElaborationParams(Collections.EMPTY_MAP);
        // if its a list action update the set and the selections
        if (ListTagHelper.getListAction(LIST_NAME, request) != null) {
            helper.execute(set, LIST_NAME, dr);
        }    
        
        // if I have a previous set selections populate data using it       
        if (!set.isEmpty()) {
            helper.syncSelections(set, dr);
            ListTagHelper.setSelectedAmount(LIST_NAME, set.size(), request);            
        }
        
        request.setAttribute("pageList", dr);
        request.setAttribute("set", set);
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        
        ListTagHelper.bindSetDeclTo(LIST_NAME, getDecl(), request);
        TagHelper.bindElaboratorTo(LIST_NAME, dr.getElaborator(), request);
        
        return mapping.findForward("default");
    }
    
    
    /**
     * Handles a dispatch action
     * @param mapping the action mapping used for returning 'forward' url
     * @param context the request context
     * @return the forward url
     */
    private ActionForward  handleDispatchAction(ActionMapping mapping, 
                                                RequestContext context) {
        
        User user = context.getLoggedInUser();
        HttpServletRequest request = context.getRequest();
        RhnSet set =  getDecl().get(user);
        Map params = new HashMap();
       
        //if they chose no users, return to the same page with a message
        if (set.isEmpty()) {
            ActionMessages msg = new ActionMessages();
            msg.add(ActionMessages.GLOBAL_MESSAGE, 
                    new ActionMessage("reactivateusers.none"));
            params = makeParamMap(request);
            saveMessages(request, msg);
            return getStrutsDelegate().forwardParams(
                    mapping.findForward("default"), params);
        }
        
        //if they chose users, send them to the confirmation page
        return getStrutsDelegate().forwardParams(
                mapping.findForward("enable"), params);          
    }
    
    protected PageControl setupPageControl(RequestContext context) {
        User viewer = context.getLoggedInUser();
        PageControl pc = new PageControl();
        pc.setIndexData(true);
        pc.setFilterColumn("loginUc");
        pc.setFilter(true);
        // if the lower/upper params don't exist, set to 1/user defined
        // respectively
        String lowBound = context.processPagination();

        int lower = StringUtil.smartStringToInt(lowBound, 1);
        if (lower <= 1) {
            lower = 1;
        }
    
        pc.setStart(lower);
        pc.setPageSize(viewer.getPageSize());
        pc.setFilterData(context.getRequest().getParameter(RequestContext.FILTER_STRING));
        return pc;
    }
    
    /**
     * 
     * @return the set declaration used to this action.. 
     */
    protected RhnSetDecl getDecl() {
        return RhnSetDecl.USERS;
    }

}
