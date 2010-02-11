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
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Iterator;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * BaseSystemsAction
 * @version $Rev: 107809 $
 */
public abstract class BaseSystemsAction extends RhnListAction {
    public static final String SHOW_NO_SYSTEMS = "showNoSystems"; 
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        
        User user = requestContext.getCurrentUser();
        DataResult result = getDataResult(user, null, formIn);

        if (result.isEmpty()) {
            request.setAttribute(SHOW_NO_SYSTEMS, Boolean.TRUE);
        }

        RhnSet set =  getSetDecl().get(user);

        
        RhnListSetHelper helper = new RhnListSetHelper(request);
        if (ListTagHelper.getListAction("systemList", request) != null) {
            helper.execute(set, "systemList", result);
        }
        
        if (!set.isEmpty()) {
            helper.syncSelections(set, result);
            ListTagHelper.setSelectedAmount("systemList", set.size(), request);            
        }
       
        
        request.setAttribute("pageList", result);
        ListTagHelper.bindSetDeclTo("systemList", getSetDecl(), request);
        
        request.setAttribute("pageList", result);
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        
        TagHelper.bindElaboratorTo("systemList", result.getElaborator(), request);

        return mapping.findForward("default");
    }
    /** 
     * Retrives the set declation item
     * where the contents of the page control
     * are to be set.
     * @return set declation item
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.SYSTEMS;
    }
    
    /**
     * Sets the status and entitlementLevel variables of each System Overview
     * @param dr The list of System Overviews
     * @param user The user viewing the System List
     */
    public void setStatusDisplay(DataResult dr, User user) {
        
        Iterator i = dr.iterator();
        
        while (i.hasNext()) {
            SystemOverview next = (SystemOverview) i.next();
            SystemListHelper.setSystemStatusDisplay(user, next);
        }
        
    }
    
    protected abstract DataResult getDataResult(User user, 
                                                PageControl pc, 
                                                ActionForm formIn);
}

