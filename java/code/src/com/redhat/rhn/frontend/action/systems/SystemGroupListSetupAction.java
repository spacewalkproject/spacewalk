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
package com.redhat.rhn.frontend.action.systems;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * SystemGroupListSetupAction
 * @version $Rev$
 */
public class SystemGroupListSetupAction extends RhnAction {
    private static final Logger LOG = Logger.getLogger(SystemGroupListSetupAction.class);
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        User user =  requestContext.getLoggedInUser();


        DataResult result = SystemManager.groupList(user, null);        
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        request.setAttribute("pageList", result);
        ListTagHelper.bindSetDeclTo("groupList", getSetDecl(), request);
        TagHelper.bindElaboratorTo("groupList", result.getElaborator(), request);
        
        RhnSet set =  getSetDecl().get(user);
        if (!requestContext.isSubmitted()) {
            set.clear();
            RhnSetManager.store(set);
        }
        
        RhnListSetHelper helper = new RhnListSetHelper(request);
        if (ListTagHelper.getListAction("groupList", request) != null) {
            helper.execute(set, "groupList", result);
        }
        else {
            
            if (request.getParameter("union") != null) {
                helper.updateSet(set, "groupList");
                return union(mapping, formIn, request, response, set);
            }
            else if (request.getParameter("intersection") != null) {
                helper.updateSet(set, "groupList");
                return intersection(mapping, formIn, request, response, set);
            }
        }
        
        if (!set.isEmpty()) {
            helper.syncSelections(set, result);
            ListTagHelper.setSelectedAmount("result", set.size(), request);            
        }
       
        return mapping.findForward("default");
    }
    
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.SYSTEM_GROUPS;
    }
    
    /**
     * Sends the user to the SSM with a system set representing the intersection
     * of their chosen group set
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @param groupSet the set of groups to intersect
     * @return the ActionForward that uses the intersection of the 
     *         chosen groups in the SSM 
     */
    public ActionForward intersection(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response, RhnSet groupSet) {
        
        User user = new RequestContext(request).getLoggedInUser();
        RhnSet systemSet = RhnSetDecl.SYSTEMS.create(user);
        
        if (groupSet.isEmpty()) {
            ActionMessages msg = new ActionMessages();
            msg.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("systemgroups.none"));
            getStrutsDelegate().saveMessages(request, msg);
            return mapping.findForward("default");
        }
        
        Iterator groups = groupSet.getElements().iterator();
        List firstList = new ArrayList();
        List secondList = new ArrayList();
        
        //for the first group, add all the systems to firstList
        Long sgid = ((RhnSetElement)groups.next()).getElement();
        Iterator systems = SystemManager.systemsInGroup(sgid, null).iterator();
        while (systems.hasNext()) {
            Long id = new Long(((SystemOverview)systems.next()).getId().longValue());
            firstList.add(id);
        }
        
        //for every subsequent group, remove systems that aren't in the intersection
        while (groups.hasNext()) { //for every group
            Long groupId = ((RhnSetElement)groups.next()).getElement();
            Iterator systemList = SystemManager.systemsInGroup(groupId, null).iterator();
            
            while (systemList.hasNext()) { //for every system in each group
                Long id = new Long(((SystemOverview)systemList.next()).getId()
                                                              .longValue());
                secondList.add(id);
            }
            
            firstList = listIntersection(firstList, secondList);
        }
        
        //add all the systems to the set
        Iterator i = firstList.iterator();
        while (i.hasNext()) {
            systemSet.addElement((Long)i.next());
        }
        RhnSetManager.store(systemSet);
        
        /*
         * Until SSM stuff is done in java, we have to redirect because struts
         * doesn't easily go outside of the /rhn context
         * TODO: make this an ActionForward
         */
        try {
            response.sendRedirect("/network/systems/ssm/system_list.pxt");
        } 
        catch (IOException exc) {
            // This really shouldn't happen, but just in case, log and
            // return.
            LOG.error("IOException when trying to redirect to " +
                    "/network/systems/ssm/system_list.pxt", exc);
        }
        
        return null;
    }
    
    
    private List listIntersection(List one, List two) {
        
        List retval = new ArrayList();
        Iterator i = one.iterator();
        
        while (i.hasNext()) {
            Long next = (Long)i.next();
            if (two.contains(next)) {
                retval.add(next);
            }
        }
        
        return retval;
    }
    
    /**
     * Sends the user to the SSM with a system set representing the union
     * of their chosen group set
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @param groupSet the set of groups to union
     * @return the ActionForward that uses the union of the 
     *         chosen groups in the SSM 
     */
    public ActionForward union(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response, RhnSet groupSet) {
        User user = new RequestContext(request).getLoggedInUser();
        RhnSet systemSet = RhnSetDecl.SYSTEMS.create(user);
      
        if (groupSet.isEmpty()) {
            ActionMessages msg = new ActionMessages();
            msg.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("systemgroups.none"));
            getStrutsDelegate().saveMessages(request, msg);
            return mapping.findForward("default");
        }
        
        Iterator groups = groupSet.getElements().iterator();
        while (groups.hasNext()) { //for every group
            Long sgid = ((RhnSetElement)groups.next()).getElement();
            Iterator systems = SystemManager.systemsInGroup(sgid, null).iterator();
            
            while (systems.hasNext()) { //for every system in a group
                Long id = new Long(((SystemOverview)systems.next()).getId().longValue());
                if (!systemSet.contains(id)) {
                    systemSet.addElement(id);
                }    
            }
        }
        
        RhnSetManager.store(systemSet);
        
        /*
         * Until SSM stuff is done in java, we have to redirect because struts
         * doesn't easily go outside of the /rhn context
         * TODO: make this an ActionForward
         */
        try {
            response.sendRedirect("/network/systems/ssm/system_list.pxt");
        } 
        catch (IOException exc) {
            // This really shouldn't happen, but just in case, log and
            // return.
            LOG.error("IOException when trying to redirect to " +
                    "/network/systems/ssm/system_list.pxt", exc);
        }
        
        return null;
    }
}
