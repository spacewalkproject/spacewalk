/**
 * Copyright (c) 2008 Red Hat, Inc.
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
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.frontend.dto.ErrataOverview;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.common.util.DatePicker;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.util.HashMap;
import java.util.Map;
import java.util.Collections;

/**
 * ErrataConfirmSetupAction
 * @version $Rev$
 */
public class ErrataConfirmSetupAction extends RhnListAction {
    public static final String DISPATCH = "dispatch";
    public static final String LIST_NAME = "errataConfirmList";
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getLoggedInUser();
        RhnListSetHelper helper = new RhnListSetHelper(request);
        RhnSet set = getSetDecl().get(user);
        
        if (request.getParameter(DISPATCH) != null) {
            // if its one of the Dispatch actions handle it..            
            helper.updateSet(set, LIST_NAME);
            if (!set.isEmpty()) {
                return confirmErrata(mapping, formIn, request, response);
            }
            else {
                RhnHelper.handleEmptySelection(request);
            }
        }
        
        Long sid = requestContext.getRequiredParam("sid");
        //This all parameter, if there, says to ignore rhnset, just retrieve everything
        String all = request.getParameter("all");

        PageControl pc = new PageControl();
        clampListBounds(pc, request, user);
        pc.setPageSize(set.size());
        
        Server server = SystemManager.lookupByIdAndUser(sid, user);
        DataResult dr;

        if (all != null && all.equals("true")) {
            dr = SystemManager.unscheduledErrata(user, sid, pc);
            helper.selectAll(set, LIST_NAME, dr);
            request.setAttribute("all", "&all=true");
        }
        else {
            dr = SystemManager.errataInSet(user, "errata_list", pc);
        }
        dr.setElaborationParams(Collections.EMPTY_MAP);
        
        if (ListTagHelper.getListAction(LIST_NAME, request) != null) {
            helper.execute(set, LIST_NAME, dr);
            helper.updateSet(set, LIST_NAME);
        }
        
        // if I have a previous set selections populate data using it       
        if (!set.isEmpty()) {
            helper.syncSelections(set, dr);
            ListTagHelper.setSelectedAmount(LIST_NAME, set.size(), request);            
        }
        
        ListTagHelper.bindSetDeclTo(LIST_NAME, getSetDecl(), request);
        TagHelper.bindElaboratorTo(LIST_NAME, dr.getElaborator(), request);
        
        //Setup the datepicker widget
        DatePicker picker = getStrutsDelegate().prepopulateDatePicker(request,
                (DynaActionForm)formIn, "date", DatePicker.YEAR_RANGE_POSITIVE);
        
        request.setAttribute("date", picker);
        
        request.setAttribute("pageList", dr);
        request.setAttribute("system", server);
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        
        return getStrutsDelegate().forwardParams(mapping.findForward("default"),
                                       request.getParameterMap());
    }
    
    
    /**
     * Action to execute if confirm button is clicked
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward confirmErrata(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        DynaActionForm form = (DynaActionForm) formIn;
        
        User user = requestContext.getLoggedInUser();
        Long sid = requestContext.getRequiredParam("sid");
            
        // Ignore rhnset and retrieve everything if "all" parameter is present:
        String all = request.getParameter("all");
        Map hparams = new HashMap();
        
        Server server = SystemManager.lookupByIdAndUser(sid, user);
        DataResult errata;
        if (all != null && all.equals("true")) {
            errata = SystemManager.unscheduledErrata(user, sid, null);
        }
        else {
            errata = SystemManager.errataInSet(user, RhnSetDecl.ERRATA.getLabel(), null);
        }
        
        if (server != null && !errata.isEmpty()) {
             for (int i = 0; i < errata.size(); i++) {
                 Action update = ActionManager.createErrataAction(user, ErrataManager
                         .lookupErrata(new Long(((ErrataOverview)errata.get(i))
                         .getId().longValue()), user));
                 ActionManager.addServerToAction(server.getId(), update);
                 update.setEarliestAction(getStrutsDelegate().readDatePicker(form, "date",
                         DatePicker.YEAR_RANGE_POSITIVE));
                 ActionManager.storeAction(update);
             }
             
             ActionMessages msg = new ActionMessages(); 
             Object[] args = new Object[3];
             args[0] = new Long(errata.size());
             args[1] = server.getName();
             args[2] = server.getId().toString();
             
             StringBuffer messageKey = new StringBuffer("errata.schedule");
             if (errata.size() != 1) {
                 messageKey = messageKey.append(".plural");
             }
             
             msg.add(ActionMessages.GLOBAL_MESSAGE, 
                     new ActionMessage(messageKey.toString(), args));
             strutsDelegate.saveMessages(request, msg);
             hparams.put("sid", sid);
                        
             RhnSetDecl.ERRATA.clear(user);
             return strutsDelegate.forwardParams(mapping.findForward("confirmed"), hparams);
        }
        /*
         * Everything is not ok.
         * TODO: Error page or some other shout-to-user-venue
         * What happens if a few ServerActions fail to be scheduled? 
         */
        Map params = makeParamMap(request);
        return strutsDelegate.forwardParams(mapping.findForward("default"), params);
    }
    
    /**
     * Get the RhnSet 'Decl' for the action
     * @return The set decleration
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.ERRATA;
    }
    

    /**
     * Makes a parameter map containing request params that need to
     * be forwarded on to the success mapping.
     * @param request HttpServletRequest containing request vars
     * @return Returns Map of parameters
     */
    protected Map makeParamMap(HttpServletRequest request) {
        RequestContext requestContext = new RequestContext(request);
        
        Map params = requestContext.makeParamMapWithPagination();
        Long sid = requestContext.getRequiredParam("sid");
        String all = request.getParameter("all");
        
        if (sid != null) {
            params.put("sid", sid);
        }
        if (all != null) {
            params.put("all", all);
        }
        
        return params;
    }
    
}
