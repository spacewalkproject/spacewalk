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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.action.rhnpackage.PackageAction;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * InstallConfirmAction
 * @version $Rev$
 */
public class InstallConfirmAction extends RhnSetAction {
    public static final String PACKAGE_INSTALL = "install";
    /**
     * Runs remote packages
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward runRemoteCommand(ActionMapping mapping,
                                       ActionForm formIn,
                                       HttpServletRequest request,
                                       HttpServletResponse response) {
        Map params = new HashMap();
        RequestContext requestContext = new RequestContext(request);
        
        params.put("set_label", getSetDecl().getLabel());
        params.put("sid", requestContext.getRequiredParam("sid"));
        params.put("mode", PACKAGE_INSTALL);
        return getStrutsDelegate().forwardParams(mapping.findForward("remotecmd"), params);
    }
    /**
     * Removes Packages
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward installPackages(ActionMapping mapping,
                                       ActionForm formIn,
                                       HttpServletRequest request,
                                       HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();

        Long sid = requestContext.getRequiredParam("sid");
        User user = requestContext.getLoggedInUser();
        //updateList(newactions, user.getId());
        
        RhnSet pkgSet = getSetDecl().get(user);
        int numPackages = pkgSet.size();

        //Archive the actions
        Server server = SystemManager.lookupByIdAndUser(sid, user);
        PackageAction pa = ActionManager.schedulePackageInstall(user, server, pkgSet);
        
        //Remove the actions from the users set
        getSetDecl().clear(user);
        Map params = makeParamMap(formIn, request);
        
        ActionMessages msgs = new ActionMessages();

        /**
         * If there was only one action archived, display the "action" archived
         * message, else display the "actions" archived message.
         */
        if (numPackages == 1) {
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                     new ActionMessage("message.packageinstall",
                             LocalizationService.getInstance()
                                 .formatNumber(new Integer(numPackages)),
                             pa.getId().toString(),
                             sid.toString(),
                             server.getName()));
        }
        else {
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                     new ActionMessage("message.packageinstalls", 
                             LocalizationService.getInstance()
                             .formatNumber(new Integer(numPackages)),
                         pa.getId().toString(),
                         sid.toString(),
                         server.getName()));
        }
        strutsDelegate.saveMessages(request, msgs);
        
        return strutsDelegate.forwardParams(mapping.findForward("confirm"), params);
    }
    
    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User user, 
                                       ActionForm formIn, 
                                       HttpServletRequest request) {
        return null;
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put("installconfirm.jsp.confirm", "installPackages");
        map.put("installconfirm.jsp.runremotecommand", "runRemoteCommand");
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm formIn, 
                                   HttpServletRequest request, 
                                   Map params) {
        RequestContext requestContext = new RequestContext(request);
        Long sid = requestContext.getRequiredParam("sid");
        params.put("sid", sid);
    }
    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.PACKAGES_TO_INSTALL;
    }
}
