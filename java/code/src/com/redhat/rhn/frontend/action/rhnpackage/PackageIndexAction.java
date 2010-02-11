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
package com.redhat.rhn.frontend.action.rhnpackage;

import com.redhat.rhn.domain.action.rhnpackage.PackageAction;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.systems.sdc.SdcHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.actions.LookupDispatchAction;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * PackageIndexAction
 * @version $Rev$
 */
public class PackageIndexAction extends LookupDispatchAction {
    
    private StrutsDelegate getStrutsDelegate() {
        return StrutsDelegate.getInstance();
    }
    
    /**
     * Schedule a package profile refresh
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward update(ActionMapping mapping,
                                ActionForm formIn,
                                HttpServletRequest request,
                                HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        
        User user = requestContext.getLoggedInUser();
        Long sid = requestContext.getRequiredParam("sid");
        Server server = SystemManager.lookupByIdAndUser(sid, user);
        
        PackageAction pa = ActionManager.schedulePackageRefresh(user, server);
        
        ActionMessages msg = new ActionMessages();
        Object[] args = new Object[3];
        args[0] = pa.getId().toString();
        args[1] = sid.toString();
        args[2] = server.getName();
        
        msg.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage("message.packagerefresh", args));
        getStrutsDelegate().saveMessages(request, msg);
        SdcHelper.ssmCheck(request, sid, user);
        request.setAttribute("system", server);
        return mapping.findForward("default");
    }
    
    /**
     * Default action to execute if dispatch parameter is missing
     * or isn't in map
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward unspecified(ActionMapping mapping,
                                     ActionForm formIn,
                                     HttpServletRequest request,
                                     HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        
        User user = requestContext.getLoggedInUser();
        Long sid = requestContext.getRequiredParam("sid");
        SdcHelper.ssmCheck(request, sid, user);
        request.setAttribute("system", SystemManager.lookupByIdAndUser(sid, user));
        return mapping.findForward("default");
    }
    
    protected Map getKeyMethodMap() {
        Map params = new HashMap();
        params.put("packagesindex.jsp.update", "update");
        return params;
    }

}
