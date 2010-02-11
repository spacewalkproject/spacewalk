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
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListAction;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * BaseUserListSetupAction
 * @version $Rev$
 */
public abstract class BaseUserListSetupAction extends RhnListAction {
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);

        User user = requestContext.getLoggedInUser();
        PageControl pc = new PageControl();
        pc.setIndexData(true);
        pc.setFilterColumn("loginUc");
        pc.setFilter(true);

        clampListBounds(pc, request, user);

        request.setAttribute("pageList", getDataResult(user, pc));
        request.setAttribute("parentUrl", request.getRequestURI());
        return mapping.findForward("default");
    }
    
    /**
     * Returns the appropriate list of users
     * @param user The logged in user
     * @param pc The PageControl
     * @return list of Users
     */
    protected abstract DataResult getDataResult(User user, PageControl pc);

}
