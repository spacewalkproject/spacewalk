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

import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.SessionSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.profile.ProfileManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * MissingPackageSetupAction
 * @version $Rev$
 */
public class MissingPackageSetupAction extends RhnAction implements Listable {
    
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

        Long sid = requestContext.getRequiredParam(RequestContext.SID);
        Long sid1 = requestContext.getParamAsLong(RequestContext.SID1);
        Long prid = requestContext.getParamAsLong(RequestContext.PRID);
        String sync = requestContext.getParam("sync", Boolean.FALSE);
        Long time = requestContext.getRequiredParam("time");

        ListHelper helper = new ListHelper(this, request);
        helper.execute();

        if (request.getParameter(RequestContext.DISPATCH) != null) {
            Map param = new HashMap();
            param.put(RequestContext.SID, sid);
            param.put(RequestContext.SID1, sid1);
            param.put(RequestContext.PRID, prid);
            param.put(RequestContext.DISPATCH,
                    request.getParameter(RequestContext.DISPATCH));
            param.put("sync", sync);
            param.put("time", time);
            return getStrutsDelegate().forwardParams(mapping.findForward("submit"),
                    param);
        }
        requestContext.lookupAndBindServer();

        requestContext.copyParamToAttributes("time");
        return mapping.findForward("default");
    }

    /**
     * {@inheritDoc}
     */
    public List getResult(RequestContext context) {
        Long sid = context.getRequiredParam(RequestContext.SID);
        String type = context.getParam("sync", true);

        if ("system".equals(type)) {
            Long sid1 = context.getRequiredParam(RequestContext.SID1);

            Set <String> pkgIdCombos = SessionSetHelper.lookupAndBind(context.getRequest(), 
                    DECL_SYSTEM_ACTION.getDecl(sid));
            
            return ProfileManager.getMissingSystemPackages(
                    context.getCurrentUser(), sid, sid1, pkgIdCombos, null);
        }
        else if ("profile".equals(type)) {
            Long prid = context.getRequiredParam(RequestContext.PRID);
            
            Set <String> pkgIdCombos = SessionSetHelper.lookupAndBind(context.getRequest(), 
                    DECL_PROFILE_ACTION.getDecl(sid));
            
            return ProfileManager.getMissingProfilePackages(
                    context.getCurrentUser(), sid, prid, pkgIdCombos, null);
        }
        
        // if we get here we're screwed.
        throw new BadParameterException(
            "Missing one or more of the required paramters [sync,sid,sid_1,prid]"); 
    }
}
