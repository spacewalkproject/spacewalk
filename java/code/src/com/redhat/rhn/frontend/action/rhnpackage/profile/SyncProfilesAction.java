/**
 * Copyright (c) 2008 Red Hat, Inc.
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
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.action.rhnpackage.PackageAction;
import com.redhat.rhn.domain.rhnpackage.MissingPackagesException;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.profile.ProfileManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * SyncProfilesAction
 * @version $Rev$
 */
public class SyncProfilesAction extends BaseProfilesAction {
    
    private static Logger log = Logger.getLogger(SyncProfilesAction.class);
    

    /**
     * Schedules the synchronization of packages.
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return null because we are sending a redirect
     */
    public ActionForward scheduleSync(ActionMapping mapping,
                                   ActionForm formIn,
                                   HttpServletRequest request,
                                   HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getCurrentUser();
        Long sid = requestContext.getRequiredParam("sid");
        Long prid = requestContext.getRequiredParam("prid");
        RhnSet pkgs = getSetDecl().get(user);
        
        //get the earliest time this action should be performed from the form
        DynaActionForm form = (DynaActionForm) formIn;
        Date earliest = getStrutsDelegate().readDatePicker(form, "date",
                DatePicker.YEAR_RANGE_POSITIVE);

        if (log.isDebugEnabled()) {
            log.debug("Calling syncToProfile");
        }
        
        try {
            
            PackageAction pa = ProfileManager.syncToProfile(user, sid, prid, 
                    pkgs.getElementValues(), null, earliest);
            
            if (pa != null) {
               
                addHardwareMessage(pa, requestContext);
                
                // sid, actionid, servername, profilename
                List args = new ArrayList();
                args.add(sid.toString());
                args.add(pa.getId().toString());
                args.add(requestContext.lookupAndBindServer().getName());
                args.add(ProfileManager.lookupByIdAndOrg(prid, user.getOrg()).getName());
                
                createMessage(request, "message.syncpackages", args);
                
                
            }
            else {
                createMessage(request, "message.nopackagestosync");
            }
            
            if (log.isDebugEnabled()) {
                log.debug("Returned from syncToProfile");
            }
            
            Map params = new HashMap();
            params.put("sid", sid);
            params.put("prid", prid);
            return getStrutsDelegate().forwardParams(mapping.findForward("success"),
                    params);
        }
        catch (MissingPackagesException mpe) {
            Map params = new HashMap();
            params.put("sid", sid);
            params.put("prid", prid);
            params.put("sync", "profile");
            params.put("date", new Long(earliest.getTime()));
            return getStrutsDelegate().forwardParams(mapping.findForward("missing"),
                    params);
        }
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
        map.put("schedulesync.jsp.schedulesync", "scheduleSync");
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm form, 
                                   HttpServletRequest request, 
                                   Map params) {
        params.put("sid", request.getParameter("sid"));
        params.put("prid", request.getParameter("prid"));
        getStrutsDelegate().rememberDatePicker(params, (DynaActionForm)form, "date",
                DatePicker.YEAR_RANGE_POSITIVE);
    }
    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.PACKAGES_FOR_SYSTEM_SYNC;
    }

}
