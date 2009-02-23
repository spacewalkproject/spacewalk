/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.systems;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.systems.sdc.SdcHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ErrataSetupAction
 * @version $Rev$
 */
public class ErrataSetupAction extends RhnAction {
     
    public static final String DISPATCH = "dispatch";
    public static final String LIST_NAME = "errataList";
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getLoggedInUser();
        RhnListSetHelper helper = new RhnListSetHelper(request);
        Long sid = requestContext.getRequiredParam("sid");
        RhnSet set = getSetDecl(sid).get(user);  
        DataResult dr = SystemManager.relevantErrata(user, sid);
        
        if (request.getParameter(DISPATCH) != null) {
            // if its one of the Dispatch actions handle it..            
            helper.updateSet(set, LIST_NAME);
            if (!set.isEmpty()) {
                return applyErrata(mapping, formIn, request, response);
            }
            else {
                RhnHelper.handleEmptySelection(request);
            }
        }   
        
        if (ListTagHelper.getListAction(LIST_NAME, request) != null) {
            helper.execute(set, LIST_NAME, dr);
        } 
        else if (!requestContext.isSubmitted()) {
            set.clear();
            RhnSetManager.store(set);
        }
        
        // if I have a previous set selections populate data using it       
        if (!set.isEmpty()) {
            helper.syncSelections(set, dr);
            ListTagHelper.setSelectedAmount(LIST_NAME, set.size(), request);            
        }
        
        String showButton = "true";
        // Show the "Apply Errata" button only when unapplied errata exist:
        if (!SystemManager.hasUnscheduledErrata(user, sid)) {
           showButton = "false";
        }
        
        Map params =  new HashMap();   
        Set keys = request.getParameterMap().keySet();
        for (Iterator i = keys.iterator(); i.hasNext();) {
            String key = (String) i.next();
            params.put(key, request.getParameter(key));
        }
        
        ListTagHelper.bindSetDeclTo(LIST_NAME, getSetDecl(sid), request);
        TagHelper.bindElaboratorTo(LIST_NAME, dr.getElaborator(), request);
        
        Server server = SystemManager.lookupByIdAndUser(sid, user);
        SdcHelper.ssmCheck(request, server.getId(), user);
        request.setAttribute("showApplyErrata", showButton);
        request.setAttribute("pageList", dr);
        request.setAttribute("set", set);
        request.setAttribute("system", server);
        String parentURL = request.getRequestURI() + "?sid=" + sid;
        request.setAttribute(ListTagHelper.PARENT_URL, parentURL);
        
        return getStrutsDelegate().forwardParams(mapping.findForward("default"), params);
    }
    
    /**
     * Applies the selected errata
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward applyErrata(ActionMapping mapping,
                                     ActionForm formIn,
                                     HttpServletRequest request,
                                     HttpServletResponse response) {
      
        Map params = new HashMap();
        
        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        //if they chose errata, send them to the confirmation page
        Long sid = requestContext.getParamAsLong("sid");
        
        User user = requestContext.getLoggedInUser();
        RhnSet set = getSetDecl(sid).get(user);
        
        //if they chose no errata, return to the same page with a message
        if (set.isEmpty()) {
            ActionMessages msg = new ActionMessages();
            msg.add(ActionMessages.GLOBAL_MESSAGE, 
                    new ActionMessage("errata.applynone"));
            params = makeParamMap(formIn, request);
            strutsDelegate.saveMessages(request, msg);
            return strutsDelegate.forwardParams(mapping.findForward("default"), params);
        }
        
        if (sid != null) {
            params.put("sid", sid);
        }
          
        return strutsDelegate.forwardParams(mapping.findForward("confirm"), params);
    }
    
    /**
     * @return Returns RhnSetDecl.ERRATA
     */
    static RhnSetDecl getSetDecl(Long sid) {
        return RhnSetDecl.ERRATA.createCustom(sid);
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
        Long sid = new RequestContext(request).getParamAsLong("sid");
        if (sid != null) {
            params.put("sid", sid);
        }
        return params;
    }

}
