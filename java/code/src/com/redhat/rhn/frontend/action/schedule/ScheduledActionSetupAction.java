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
package com.redhat.rhn.frontend.action.schedule;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ActionsSetupAction
 * @version $Rev$
 */
public abstract class ScheduledActionSetupAction extends RhnListAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getLoggedInUser();                
        PageControl pc = new PageControl();
        pc.setFilterColumn("earliest");

        clampListBounds(pc, request, user);

        DataResult dr = getDataResult(user, pc);

        RhnSet set = getSetDecl().get(user);
        
        request.setAttribute("pageList", dr);
        request.setAttribute("user", user);
        request.setAttribute("set", set);

        return mapping.findForward("default");
    }
    
    /**
     * Method that returns the name/label for the particular
     * scheduled action we are working on.
     * @return Returns the name.
     */
    public final String getListName() { return "foo"; }
    
    /**
     * Method that returns the correct data result for a 
     * particular scheduled action.
     * @param user The user in question
     * @param pc The page control for the page
     * @return Returns the DataResult for the page.
     */
    protected abstract DataResult getDataResult(User user, PageControl pc);
    
    /**
     * The declaration of the set we are working with, must be one of the
     * constants from {@link RhnSetDecl}
     * @return the declaration of the set we are working with
     */
    protected abstract RhnSetDecl getSetDecl();
    
}
