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
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.dto.SystemGroupOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * AssignedGroupsSetupAction, edit action for assigned groups page
 * @version $Rev: 1196 $
 */
public class AssignedGroupsSetupAction extends RhnListAction {

    private final String LIST_NAME = "groupList";
    
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
       
        LocalizationService ls =  LocalizationService.getInstance(); 
        RhnListSetHelper helper = new RhnListSetHelper(request);
        
        Long uid = requestContext.getRequiredParam("uid");
        User currentUser =  requestContext.getCurrentUser();
        User user = UserFactory.lookupById(currentUser, uid);
        DataResult dr = UserManager.getSystemGroups(user, null);
        
        RhnSet set =  getSetDecl().get(currentUser);
        if (!requestContext.isSubmitted()) {
            set.clear();
            RhnSetManager.store(set);
        }
        

        if (ListTagHelper.getListAction(LIST_NAME, request) != null) {
            helper.execute(set, LIST_NAME, dr);
            
        }     

     
        request.setAttribute(ListTagHelper.PARENT_URL, 
                request.getRequestURI());
        request.setAttribute("user", user);
        request.setAttribute("userIsOrgAdmin",
                new Boolean(user.hasRole(RoleFactory.ORG_ADMIN)));
       
        
       
        
        String submit = request.getParameter("submit");
        //If the default system groups were submitted
        if (submit != null && 
                submit.equals(ls.getMessage("assignedgroups.jsp.submitdefaults"))) {
            updateDefaults(mapping, formIn, request, response);
        }
        else if (submit != null &&  //else if the update permissions button was clicked
                    submit.equals(ls.getMessage("assignedgroups.jsp.submitpermissions"))) {
            updatePerm(mapping, formIn, request, response);
            dr = UserManager.getSystemGroups(user, null);
            ListTagHelper.setSelectedAmount(LIST_NAME, set.size(), request);  
        } //else nothing was selected (normal page view)
        else {
            helper.syncSelections(set, dr);
            set.clear();
            for (Iterator it = dr.iterator(); it.hasNext();) {
                SystemGroupOverview group = (SystemGroupOverview) it.next();
                if (group.isSelected()) {
                    RhnSetElement elem = new RhnSetElement(currentUser.getId(), 
                            RhnSetDecl.SYSTEM_GROUPS.getLabel(), group.getId().toString());
                    set.addElement(elem);
                }
            }
            RhnSetManager.store(set);
            ListTagHelper.setSelectedAmount(LIST_NAME, set.size(), request);         
        }
        

       
        
        //Bottom form
        DynaActionForm form = (DynaActionForm)formIn;
        List selDefaults = new ArrayList();
        List selGroups = new ArrayList();
        processList(dr, selGroups, selDefaults);
        form.set("selectedGroups", convert(selGroups));
        form.set("defaultGroups", getDefaultGroupStrings(user));
        request.setAttribute("availableGroups", selDefaults);
        request.setAttribute("targetuser", user);
        
        
        ListTagHelper.bindSetDeclTo(LIST_NAME, getSetDecl(), request);
        request.setAttribute("pageList", dr);

        return mapping.findForward("default");
    }
   
    /**
     * Goes through the DataResult and pulls out the values
     * which the User has permission to see.  The selGroups list
     * simply contains the ids, while the selDefaults has the
     * name of all the items in DataResult with the ones
     * the user has permission to see marked with a (*).
     * @param dr DataResult list to process.
     * @param selGroups Selected Groups.
     * @param selDefaults Selected Defaults.
     */
    private void processList(DataResult dr, List selGroups, List selDefaults) {
        for (Iterator itr = dr.iterator(); itr.hasNext();) {
            SystemGroupOverview item = (SystemGroupOverview)itr.next();
            
            String display = item.getName();
            

            if (item.isSelected()) {
                selGroups.add(item.getId().toString());
                display = " (*) " + display;
            }

            Map map = new HashMap();
            map.put("value", item.getId());
            map.put("display", display);
            selDefaults.add(map);
        }
    }
   
    /**
     * Converts a List of Strings into a String array.
     * @param list List to convert.
     * @return String[] from List.
     */
    private String[] convert(List list) {
        return (String[])list.toArray(new String[list.size()]);
    }
    
    /**
     * Get the String versions of the Default System Groups
     * @param user group strings to get from
     * @return array of strings 
     */
    private String[] getDefaultGroupStrings(User user) {
        // We need to be setting the defaultGroups stuff to a String[], but
        // we are getting a Set of Longs, so convert it and set it.
        Set groups = user.getDefaultSystemGroupIds();
        Set groupStrings = new HashSet();
        Iterator i = groups.iterator();
        while (i.hasNext()) {
            Object o = i.next();
            groupStrings.add(o.toString());
        }
        return (String[]) groupStrings.toArray(new String[0]);
    }


    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.SYSTEM_GROUPS;
    }

    
    /**
     * Updates the Default System Groups permissions for the specified user.
     * @param mapping Struts ActionMapping
     * @param formIn Form containing submitted data.
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     */
    public void updateDefaults(ActionMapping mapping,
                                        ActionForm formIn,
                                        HttpServletRequest request,
                                        HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        
        DynaActionForm form = (DynaActionForm)formIn;
        User user = UserManager.lookupUser(requestContext.getLoggedInUser(), 
                requestContext.getParamAsLong("uid"));
        if (user == null) {
            throw new BadParameterException("Invalid uid");
        }
        //request.setAttribute(RhnHelper.TARGET_USER, user);
        
        String[] groupArray = (String[])form.get("defaultGroups");
        
        Set groupSet = new HashSet();
        for (int i = 0; i < groupArray.length; i++) {
            groupSet.add(new Long(groupArray[i]));
        }
        user.setDefaultSystemGroupIds(groupSet);

        UserManager.storeUser(user);
        ActionMessages msgs = new ActionMessages();
        msgs.add(ActionMessages.GLOBAL_MESSAGE, 
             new ActionMessage("message.defaultSystemGroups",
                 StringEscapeUtils.escapeHtml(user.getLogin())));
        saveMessages(request, msgs);
    }
    
    
    
    
    
    /**
     * Updates the System Groups permissions for the specified user.
     * @param mapping Struts ActionMapping
     * @param formIn Form containing submitted data.
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     */
    public void updatePerm(ActionMapping mapping,
                                    ActionForm formIn,
                                    HttpServletRequest request,
                                    HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        User user = UserManager.lookupUser(requestContext.getLoggedInUser(), 
                requestContext.getParamAsLong("uid"));
        if (user == null) {
            throw new BadParameterException("Invalid uid");
        }
        //request.setAttribute(RhnHelper.TARGET_USER, user);
        
        RhnSet set =  getSetDecl().get(requestContext.getCurrentUser());
        
        //First remove the user from all groups
        DataResult dr = UserManager.getSystemGroups(user, null);
        for (Iterator it = dr.iterator(); it.hasNext();) {
           SystemGroupOverview map =  (SystemGroupOverview) it.next();
            UserManager.revokeServerGroupPermission(user, map.getId().longValue());
        }
        
        //Then add him to the ones selected.  Easiest way to do this.  
        for (Iterator it = set.getElements().iterator(); it.hasNext();) {
            RhnSetElement elem = (RhnSetElement) it.next();     
              UserManager.grantServerGroupPermission(user, elem.getElement());
        }

        ActionMessages msgs = new ActionMessages();
        msgs.add(ActionMessages.GLOBAL_MESSAGE, 
             new ActionMessage("message.perms_updated",
             StringEscapeUtils.escapeHtml(user.getLogin())));
        saveMessages(request, msgs);
    }

}
