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

import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.action.rhnpackage.PackageAction;
import com.redhat.rhn.domain.rhnpackage.MissingPackagesException;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.SessionSetHelper;
import com.redhat.rhn.manager.profile.ProfileManager;

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
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * SyncProfilesAction
 * @version $Rev$
 */
public class SyncProfilesAction extends BaseProfilesAction {
    
    private static Logger log = Logger.getLogger(SyncProfilesAction.class);
    private static final String DATA_SET = "pageList";
    private static final CompareProfileSetupAction DECL_ACTION = 
        new CompareProfileSetupAction();
    
    /**
     * Schedules the synchronization of packages.
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return null because we are sending a redirect
     */
    /** {@inheritDoc} */
    public ActionForward scheduleSync(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getCurrentUser();
        Long sid = requestContext.getRequiredParam(RequestContext.SID);
        Long prid = requestContext.getRequiredParam(RequestContext.PRID);
        
        //get the earliest time this action should be performed from the form
        DynaActionForm form = (DynaActionForm) formIn;
        Date earliest = getStrutsDelegate().readDatePicker(form, "date",
                DatePicker.YEAR_RANGE_POSITIVE);

        if (log.isDebugEnabled()) {
            log.debug("Calling syncToProfile");
        }
        
        try {
            Set <String> pkgIdCombos = SessionSetHelper.lookupAndBind(request, 
                    getDecl(sid));

            PackageAction pa = ProfileManager.syncToProfile(user, sid, prid, 
                    pkgIdCombos, null, earliest);
            
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
            params.put(RequestContext.SID, sid);
            params.put(RequestContext.PRID, prid);
            return getStrutsDelegate().forwardParams(mapping.findForward("success"),
                    params);
        }
        catch (MissingPackagesException mpe) {
            Map params = new HashMap();
            params.put(RequestContext.SID, sid);
            params.put(RequestContext.PRID, prid);
            params.put("sync", "profile");
            params.put("date", new Long(earliest.getTime()));
            return getStrutsDelegate().forwardParams(mapping.findForward("missing"),
                    params);
        }
    }

    /**
     * {@inheritDoc}
     */
    protected Map getKeyMethodMap() {
        Map map = new HashMap();
        map.put("schedulesync.jsp.schedulesync", "scheduleSync");
        return map;
    }
    
    protected String getDecl(Long sid) {
        return DECL_ACTION.getDecl(sid);
    }
}
