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
package com.redhat.rhn.frontend.action.errata;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.SetLabels;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.manager.errata.ErrataManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ErrataConfirmSetupAction
 * @version $Rev$
 */
public class ErrataConfirmSetupAction extends RhnListAction {
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        
        User user = requestContext.getLoggedInUser();
        PageControl pc = new PageControl();

        clampListBounds(pc, request, user);
        
        Errata errata = requestContext.lookupErratum();
        DataResult dr = ErrataManager.relevantSystemsInSet(user, 
                SetLabels.AFFECTED_SYSTEMS_LIST, errata.getId(), pc);
        
        //Setup the datepicker widget
        DatePicker picker = getStrutsDelegate().prepopulateDatePicker(request,
                (DynaActionForm)formIn, "date", DatePicker.YEAR_RANGE_POSITIVE);
        
        request.setAttribute("date", picker);
        request.setAttribute("pageList", dr);
        request.setAttribute("errata", errata);

        return mapping.findForward("default");
    }
}
