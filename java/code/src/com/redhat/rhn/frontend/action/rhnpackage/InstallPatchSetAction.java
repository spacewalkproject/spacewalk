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

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PatchSet;
import com.redhat.rhn.domain.rhnpackage.WrongPackageTypeException;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
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
 * InstallPatchSetAction
 * @version $Rev$
 */
public class InstallPatchSetAction extends LookupDispatchAction {

    private StrutsDelegate getStrutsDelegate() {
        return StrutsDelegate.getInstance();
    }
    
    /**
     * Action to execute if confirm button is clicked
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     *
     * @return The ActionForward to go to next.
     * @throws WrongPackageTypeException if a patch cluster install action
     * is scheduled for a package that is not a patch cluster
     */
    public ActionForward installPatchSet(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) throws WrongPackageTypeException {
        
        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();

        User user = requestContext.getLoggedInUser();
        Long sid = requestContext.getRequiredParam("sid");
        Long pid = requestContext.getRequiredParam("pid");

        Server server = SystemManager.lookupByIdAndUser(sid, user);
        Package patchset = PackageManager.lookupByIdAndUser(pid, user);

        if (!PatchSet.class.isInstance(patchset)) {
            throw new WrongPackageTypeException(pid,
                                                patchset.getClass().getName(),
                                                PatchSet.class.getName(),
                                                "The package selected for " +
                                                "install was not a Patch Cluster");
        }

        Action installAction =
            ActionManager.createPatchSetInstallAction(user,
                                                      server,
                                                      (PatchSet) patchset);
        ActionManager.storeAction(installAction); //commit action
        ActionMessages msgs = new ActionMessages();

        msgs.add(ActionMessages.GLOBAL_MESSAGE,
                 new ActionMessage("message.patchsetinstall",
                                   patchset.getId().toString(),
                                   patchset.getPackageName().getName(),
                                   server.getId().toString(),
                                   installAction.getId().toString()
                                   ));

        strutsDelegate.saveMessages(request, msgs);
        
        Map params = makeParamMap(request);
        return strutsDelegate.forwardParams(mapping.findForward("default"), params);
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
        Map params = makeParamMap(request);
        return getStrutsDelegate().forwardParams(mapping.findForward("default"), params);
    }
    
    /**
     * Makes a parameter map containing request params that need to
     * be forwarded on to the success mapping.
     * @param request HttpServletRequest containing request vars
     * @return Returns Map of parameters
     */
    
    protected Map makeParamMap(HttpServletRequest request) {
        RequestContext requestContext = new RequestContext(request);
        
        Map params = new HashMap();
        Long sid = requestContext.getParamAsLong("sid");
        Long pid = requestContext.getParamAsLong("pid");
        
        if (sid != null) {
            params.put("sid", sid);
        }
        if (pid != null) {
            params.put("pid", pid);
        }
        
        return params;
    }
    
    /**
     * {@inheritDoc}
     */
    protected Map getKeyMethodMap() {
        Map map = new HashMap();
        map.put("install_patchset.jsp.installbutton", "installPatchSet");
        return map;
    }    
    
}
