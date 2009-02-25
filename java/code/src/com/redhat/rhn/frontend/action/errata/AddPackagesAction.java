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
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * AddPackagesAction
 * @version $Rev$
 */
public class AddPackagesAction extends RhnSetAction {

    /**
     * confirm handles updating the set and forwarding the user to the confirmation 
     * screen.
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request Request
     * @param response Response
     * @return Returns the action forward for the confirm mapping.
     */
    public ActionForward confirm(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        
        //update the set
        updateSet(request);
        
        //forward to the confirm mapping
        Long eid = requestContext.getRequiredParam("eid");
        return strutsDelegate.forwardParam(mapping.findForward("confirm"), 
                                      "eid", eid.toString());
    }
                                 
    /**
     * SwitchViews handles switching the view between packages available to an errata in
     * any channel and packages available to an errata in a specific channel
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request Request
     * @param response Response
     * @return Returns the default action forward without pagination
     */
    public ActionForward switchViews(ActionMapping mapping,
                                     ActionForm formIn,
                                     HttpServletRequest request,
                                     HttpServletResponse response) {
        //make sure we save any changes
        updateSet(request);
        //make our own param map *without* pagination involved
        Map params = new HashMap();
        processParamMap(formIn, request, params);
        return getStrutsDelegate().forwardParams(mapping.findForward("default"), params);
    }
    
    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User user, 
                                       ActionForm formIn, 
                                       HttpServletRequest request) {
        Errata errata = new RequestContext(request).lookupErratum();
        String viewChannel = request.getParameter("view_channel");
        if (viewChannel == null || //first time customer
            viewChannel.equals("any_channel")) {
            /*
             * Get packages for *all* channels.
             * View: All managed packages
             */
            return PackageManager.packagesAvailableToErrata(errata, user, null);
        }
        else { //must have a cid for view_channel
            Long cid = new Long(viewChannel);
            //TODO: add some error checking here
            return PackageManager.packagesAvailableToErrataInChannel(errata, cid, 
                                                                     user, null);
        }
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put("errata.edit.packages.add.viewsubmit", "switchViews");
        map.put("errata.edit.packages.add.addpackages", "confirm");
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm formIn, 
                                   HttpServletRequest request, 
                                   Map params) {
        params.put("eid", request.getParameter("eid"));
        params.put("view_channel", request.getParameter("view_channel"));
        params.put(RequestContext.FILTER_STRING, 
                   request.getParameter(RequestContext.FILTER_STRING));
    }

    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.PACKAGES_TO_ADD;
    }

}
