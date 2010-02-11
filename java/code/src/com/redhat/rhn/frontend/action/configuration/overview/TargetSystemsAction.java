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
package com.redhat.rhn.frontend.action.configuration.overview;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * TargetSystemsAction extends RhnSetAction
 * @version $Rev$
 */
public class TargetSystemsAction extends RhnListAction {
    
    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        
        User user = requestContext.getLoggedInUser();
        PageControl pc = new PageControl();
        pc.setFilterColumn("name");
        pc.setFilter(true);

        clampListBounds(pc, request, user);
        
        DataResult dr = getDataResult(user, pc);
        request.setAttribute(RequestContext.PAGE_LIST, dr);
        
        if (!isSubmitted((DynaActionForm) formIn)) {
            getSetDecl().clear(user);
        }
        
        //Put the date picker into the form
        DynaActionForm dynaForm = (DynaActionForm) formIn;
        DatePicker picker = getStrutsDelegate().prepopulateDatePicker(request, dynaForm,
                "date", DatePicker.YEAR_RANGE_POSITIVE);
        
        RhnSet set = getSetDecl().get(user);
        request.setAttribute("date", picker);
        request.setAttribute("set", set);
        request.setAttribute("newset", trackSet(set, request));
        
        
        Map params = request.getParameterMap();
        return getStrutsDelegate().forwardParams(
                mapping.findForward(RhnHelper.DEFAULT_FORWARD), params);
    }
    
    /**
     * @return set declarative
     */
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.CONFIG_ENABLE_SYSTEMS;
    }

    /**
     * Returns the dataresult used to show the list on the page.
     * @param user currently logged in user
     * @param pcIn PageControl which controls how many items to show on the
     * page.
     * @return list of non-managed systems
     */
    protected DataResult getDataResult(User user, PageControl pcIn) {
        ConfigurationManager cm = ConfigurationManager.getInstance();
        return cm.listNonManagedSystems(user, pcIn);
    }
}
