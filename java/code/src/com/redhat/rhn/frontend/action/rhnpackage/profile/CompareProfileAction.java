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
package com.redhat.rhn.frontend.action.rhnpackage.profile;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.profile.ProfileManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * CompareProfileAction
 * @version $Rev$
 */
public class CompareProfileAction extends RhnSetAction {

    /**
     * Takes you to the sync packages page to schedule the sync of packages.
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return null because we are sending a redirect
     */
    public ActionForward prepareForSync(ActionMapping mapping,
                                   ActionForm formIn,
                                   HttpServletRequest request,
                                   HttpServletResponse response) {
        Map params = new HashMap();
        params.put("sid", request.getParameter("sid"));
        params.put("prid", request.getParameter("prid"));
        updateSet(request);
        return getStrutsDelegate().forwardParams(mapping.findForward("sync"),
                params);
    }

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User user, 
                                       ActionForm formIn, 
                                       HttpServletRequest request) {
        RequestContext requestContext = new RequestContext(request);
        
        Long sid = requestContext.getRequiredParam("sid");
        Long prid = requestContext.getRequiredParam("prid");
        
        return ProfileManager.compareServerToProfile(sid,
                prid, user.getOrg().getId(), null);
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put("compare.jsp.syncpackageto", "prepareForSync");
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm formIn, 
                                   HttpServletRequest request, 
                                   Map params) {
        params.put("sid", request.getParameter("sid"));
        params.put("prid", request.getParameter("prid"));
    }


/*
 * get sid, prid, orgid, and pagecontrol
 * call ProfileManager.compareServerToProfile();
 * show resulting list in a listview
 */

    /**
     * {@inheritDoc}
     */
    protected String getLookupMapName(HttpServletRequest request,
            String keyName, ActionMapping mapping) throws ServletException {
        
        String f = LocalizationService.getInstance()
                                      .getMessage("compare.jsp.syncpackageto");
        int idx = f.indexOf("{0}");
        if (idx > -1) {
            String sub = f.substring(0, idx);
            if (keyName.startsWith(sub)) {
                return (String) getKeyMethodMap().get("compare.jsp.syncpackageto");
            } 
        }

        return super.getLookupMapName(request, keyName, mapping);
    }
    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.PACKAGES_FOR_SYSTEM_SYNC;
    }
}
