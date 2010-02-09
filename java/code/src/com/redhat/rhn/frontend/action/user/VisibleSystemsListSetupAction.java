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
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * AddressesAction Setup the Addresses on the Request so
 * the AddressTag will be able to render
 * @version $Rev$
 */
public class VisibleSystemsListSetupAction extends RhnListAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);

        Long uid = requestContext.getRequiredParam("uid");
        
        User user = UserManager.lookupUser(requestContext.getLoggedInUser(), uid);
        request.setAttribute(RhnHelper.TARGET_USER, user);
        PageControl pc = new PageControl();
         
        clampListBounds(pc, request, requestContext.getLoggedInUser());
        DataResult dr = UserManager.visibleSystems(user, pc);
        //we want set to change for logged in user rather than the target user
        RhnSet set = RhnSetDecl.SYSTEMS.get(requestContext.getLoggedInUser());
        
        request.setAttribute("pageList", dr);
        request.setAttribute("user", user);
        request.setAttribute("set", set);
        
        return mapping.findForward("default");
    }
}
