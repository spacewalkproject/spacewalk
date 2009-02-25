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
package com.redhat.rhn.frontend.action.errata;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * PublishedErrataSetupAction
 * @version $Rev$
 */
public class PublishedErrataSetupAction extends RhnListAction {
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        RequestContext rctx = new RequestContext(request);
        User user = rctx.getLoggedInUser();        
        PageControl pc = new PageControl();
        pc.setFilterColumn("earliest");

        clampListBounds(pc, request, user);

        DataResult dr = getDataResult(user, pc);

        RhnSet set = RhnSetDecl.ERRATA_TO_DELETE.get(user);
        
        request.setAttribute("pageList", dr);
        request.setAttribute("user", user);
        request.setAttribute("set", set);

        return mapping.findForward("default");
    }
    
    /**
     * Returns the unpublished errata for the given user bounded
     * by the values of the PageControl.
     * @param user Logged in user.
     * @param pc boundary values
     * @return List of unpublished errata for the given user 
     * bounded by the values of the PageControl.
     */
    protected DataResult getDataResult(User user, PageControl pc) {
        pc.setFilter(true);
        pc.setFilterColumn("advisorySynopsis");
        return ErrataManager.publishedOwnedErrata(user, pc);
    }
}
