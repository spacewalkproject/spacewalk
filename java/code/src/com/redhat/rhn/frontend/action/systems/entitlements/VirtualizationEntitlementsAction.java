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
package com.redhat.rhn.frontend.action.systems.entitlements;

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.system.VirtEntitlementsManagerImpl;
import com.redhat.rhn.manager.system.VirtualizationEntitlementsManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.MappingDispatchAction;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * VirtualizationEntitlements
 * @version $Rev$
 */
public class VirtualizationEntitlementsAction extends MappingDispatchAction {

    public static final String PAGELIST = "pageList";
       
    /**
     * Initializes the action
     */
    public VirtualizationEntitlementsAction() {
        
    }


    /**
     * Creates a list of host systems with the <i>Virtualization</i> (guest-limited)
     * entitlement and the number of guests for each host.
     * 
     * @param mapping The action mapping
     * @param form The action form
     * @param request The servlet request
     * @param response The servlet response
     * @return An action forward
     */
    public ActionForward listGuestLimited(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {
        VirtualizationEntitlementsManager entitlementsMgr = 
            new VirtEntitlementsManagerImpl();
        request.setAttribute("parentUrl", request.getRequestURI());
        RequestContext rctx = new RequestContext(request);
        User user = rctx.getLoggedInUser();
        request.setAttribute(PAGELIST, 
                entitlementsMgr.findGuestLimitedHostsByOrg(user.getOrg()));
        return mapping.findForward("success");
    }

    /**
     * Creates a list of host systems with the <i>Virtualization Platform</i> 
     * (guest-unlimited) entitlement and the number of guests for each host.
     * 
     * @param mapping The action mapping
     * @param form The action form
     * @param request The servlet request
     * @param response The servlet response
     * @return An action forward
     */
    public ActionForward listGuestUnlimited(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {
        VirtualizationEntitlementsManager entitlementsMgr = 
            new VirtEntitlementsManagerImpl();
        request.setAttribute("parentUrl", request.getRequestURI());
        RequestContext context = new RequestContext(request);
        User user = context.getLoggedInUser();        
        request.setAttribute(PAGELIST, 
                entitlementsMgr.findGuestUnlimitedHostsByOrg(user.getOrg()));
        
        return mapping.findForward("success");
    }
    
    /**
     * Creates a list of host systems with the <i>Virtualization</i> entitlement and
     * the number of guests for each host.
     * 
     * @param mapping The action mapping
     * @param form The action form
     * @param request The servlet request
     * @param response The servlet response
     * @return An action forward
     */
    public ActionForward listPhysicalHosts(ActionMapping mapping,
            ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        VirtualizationEntitlementsManager entitlementsMgr = 
            new VirtEntitlementsManagerImpl();
        request.setAttribute("parentUrl", request.getRequestURI());
        RequestContext rctx = new RequestContext(request);
        User user = rctx.getLoggedInUser();
        request.setAttribute(PAGELIST, 
                entitlementsMgr.findGuestsWithoutHostsByOrg(user.getOrg()));
        return mapping.findForward("success");
    }
}
