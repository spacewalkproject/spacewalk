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
package com.redhat.rhn.frontend.action.rhnpackage;

import com.redhat.rhn.domain.action.rhnpackage.PackageAction;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.struts.StrutsDelegateFactory;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
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
 * UpgradeConfirmAction
 * @version $Rev$
 */
public class UpgradeConfirmAction extends LookupDispatchAction {
    public static final String PACKAGE_UPGRADE = "upgrade";
    
    private StrutsDelegate getStrutsDelegate() {
        StrutsDelegateFactory factory = StrutsDelegateFactory.getInstance();
        return factory.getStrutsDelegate();
    }
    
    /**
     * Sends information about the upgrade action to be scheduled
     * to a remote command page.  Includes a answer action for
     * the packages selected. 
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return null because we are sending a redirect
     */
    public ActionForward remote(ActionMapping mapping,
                                ActionForm formIn,
                                HttpServletRequest request,
                                HttpServletResponse response) {
        Map params = new HashMap();
        params.put("set_label", RhnSetDecl.PACKAGES_UPGRADABLE.getLabel());
        params.put("sid", new RequestContext(request).getRequiredParam("sid"));
        params.put("mode", PACKAGE_UPGRADE);
        return getStrutsDelegate().forwardParams(mapping.findForward("remote"), params);
    }
    
    /**
     * Schedules a package upgrade action for the target system
     * with the packages shown.  Includes a answer action for
     * the packages selected.
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return null because we are sending a redirect
     */
    public ActionForward confirm(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        
        User user = requestContext.getLoggedInUser();
        Long sid = requestContext.getRequiredParam("sid");
        Server server = SystemManager.lookupByIdAndUser(sid, user);
        RhnSet set = RhnSetDecl.PACKAGES_UPGRADABLE.get(user);
        
        PackageAction pa = ActionManager.schedulePackageUpgrade(user, server, set);
        RhnSetDecl.PACKAGES_UPGRADABLE.clear(user);
        
        ActionMessages msgs = new ActionMessages();
        Object[] args = new Object[4];
        args[0] = new Long(set.size());
        args[1] = pa.getId().toString();
        args[2] = sid.toString();
        args[3] = server.getName();
        
        StringBuffer messageKey = new StringBuffer("message.packageinstall");
        if (set.size() != 1) {
            messageKey = messageKey.append(".plural");
        }
        
        msgs.add(ActionMessages.GLOBAL_MESSAGE, 
                new ActionMessage(messageKey.toString(), args));
        
        strutsDelegate.saveMessages(request, msgs);
        return strutsDelegate.forwardParam(mapping.findForward("confirm"), "sid",
                sid.toString());
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
        Map params = requestContext.makeParamMapWithPagination();
        params.put("sid", requestContext.getRequiredParam("sid"));

        return getStrutsDelegate().forwardParams(mapping.findForward("default"), params);
    }
    
    /**
     * {@inheritDoc}
     */
    protected Map getKeyMethodMap() {
        HashMap map = new HashMap();
        map.put("upgrade.jsp.remote", "remote");
        map.put("upgrade.jsp.confirm", "confirm");
        return map;
    }
    
}
