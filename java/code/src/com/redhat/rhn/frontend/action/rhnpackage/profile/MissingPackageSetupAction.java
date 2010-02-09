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
import com.redhat.rhn.domain.rhnpackage.profile.Profile;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.SessionSetHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.profile.ProfileManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * MissingPackageSetupAction
 * @version $Rev$
 */
public class MissingPackageSetupAction extends RhnAction {
    
    private static final String DATA_SET = "pageList";
    private static final CompareProfileSetupAction DECL_PROFILE_ACTION = 
        new CompareProfileSetupAction();
    private static final CompareSystemSetupAction DECL_SYSTEM_ACTION = 
        new CompareSystemSetupAction();

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        processRequestAttributes(requestContext);

        Long sid = requestContext.getRequiredParam(RequestContext.SID);
        String type = requestContext.getParam("sync", true);
        if ("system".equals(type)) {
            Long sid1 = requestContext.getRequiredParam(RequestContext.SID1);
            request.setAttribute(ListTagHelper.PARENT_URL, 
                    request.getRequestURI() + "?sid=" + sid + "&sid_1=" + sid1);  
        }
        else if ("profile".equals(type)) {
            Long prid = requestContext.getRequiredParam(RequestContext.PRID);
            request.setAttribute(ListTagHelper.PARENT_URL, 
                    request.getRequestURI() + "?sid=" + sid + "&prid=" + prid);  
        }

        DataResult dr = getDataResult(request);
        request.setAttribute(DATA_SET, dr);        

        return getStrutsDelegate().forwardParams(mapping.findForward("default"),
                request.getParameterMap());
    }

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(HttpServletRequest request) {

        RequestContext requestContext = new RequestContext(request);

        Long sid = requestContext.getRequiredParam(RequestContext.SID);
        String type = requestContext.getParam("sync", true);

        if ("system".equals(type)) {
            Long sid1 = requestContext.getRequiredParam(RequestContext.SID1);

            Set <String> pkgIdCombos = SessionSetHelper.lookupAndBind(request, 
                    DECL_SYSTEM_ACTION.getDecl(sid));
            
            return ProfileManager.getMissingSystemPackages(
                    requestContext.getCurrentUser(), sid, sid1, pkgIdCombos, null);
        }
        else if ("profile".equals(type)) {
            Long prid = requestContext.getRequiredParam(RequestContext.PRID);
            
            Set <String> pkgIdCombos = SessionSetHelper.lookupAndBind(request, 
                    DECL_PROFILE_ACTION.getDecl(sid));
            
            return ProfileManager.getMissingProfilePackages(
                    requestContext.getCurrentUser(), sid, prid, pkgIdCombos, null);
        }
        
        // if we get here we're screwed.
        throw new BadParameterException(
            "Missing one or more of the required paramters [sync,sid,sid_1,prid]"); 
    }

    /**
     * {@inheritDoc}
     */
    protected void processRequestAttributes(RequestContext requestContext) {
        requestContext.lookupAndBindServer();

        requestContext.copyParamToAttributes(RequestContext.SID);
        requestContext.copyParamToAttributes(RequestContext.PRID);

        Long time = requestContext.getParamAsLong("date");
        if (time != null) {
            requestContext.getRequest().setAttribute("time", time);
        }
        
        String type = requestContext.getParam("sync", true);
        if ("system".equals(type)) {
            Long sid1 = requestContext.getRequiredParam(RequestContext.SID1);
            Server server1 = SystemManager.lookupByIdAndUser(sid1, 
                    requestContext.getCurrentUser());
            requestContext.getRequest().setAttribute("system1", server1);
        }
        else if ("profile".equals(type)) {
            Long prid = requestContext.getRequiredParam(RequestContext.PRID);
            Profile profile = ProfileManager.lookupByIdAndOrg(prid,
                    requestContext.getCurrentUser().getOrg());
            requestContext.getRequest().setAttribute("profilename", profile.getName());
        }
    }
}
