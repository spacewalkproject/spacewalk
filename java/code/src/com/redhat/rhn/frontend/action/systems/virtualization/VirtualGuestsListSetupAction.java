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
package com.redhat.rhn.frontend.action.systems.virtualization;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.OptionsCollectionBean;
import com.redhat.rhn.frontend.action.systems.BaseSystemListSetupAction;
import com.redhat.rhn.frontend.action.systems.SystemListHelper;
import com.redhat.rhn.frontend.action.systems.sdc.SdcHelper;
import com.redhat.rhn.frontend.dto.VirtualSystemOverview;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * VirtualGuestsListSetupAction
 * @version $Rev$
 */
public class VirtualGuestsListSetupAction extends BaseSystemListSetupAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext rctx = new RequestContext(request);
        User user = rctx.getLoggedInUser();
        PageControl pc = new PageControl();
        pc.setIndexData(true);
        pc.setFilterColumn("name");
        pc.setFilter(true);

        clampListBounds(pc, request, user);

        RhnSet set = getSetDecl().get(user);
        if (!rctx.isSubmitted()) {
            getSetDecl().clear(rctx.getLoggedInUser());
        }        

        DataResult dr = getDataResult(user, pc, request);
        if (!(dr.size() > 0)) {
            request.setAttribute(SHOW_NO_SYSTEMS, Boolean.TRUE);
        }
        
        setStatusDisplay(dr, user);

        Long sid = rctx.getRequiredParam(RequestContext.SID);
        Server server = SystemManager.lookupByIdAndUser(sid, user);

        SdcHelper.ssmCheck(request, sid, user);        
        request.setAttribute("set", set);
        request.setAttribute("pageList", dr);
        request.setAttribute("system", server);
        request.setAttribute("actionOptions", getActionOptions());
        request.setAttribute("guestSettingOptions", getGuestSettingOptions());
        return mapping.findForward("default");
    }
    
    private List getActionOptions() {
        // Set parameter for the actions dropdown:
        List actionOptions = new LinkedList();
        String [] resourceBundleKeys = {
                //"virtualguestslist.jsp.deletesystem",
                "virtualguestslist.jsp.startsystem",
                "virtualguestslist.jsp.suspendsystem",
                "virtualguestslist.jsp.resumesystem",
                "virtualguestslist.jsp.restartsystem",
                "virtualguestslist.jsp.shutdownsystem"
        };
        for (int i = 0; i < resourceBundleKeys.length; i++) {
            String value = LocalizationService.getInstance().getMessage(
                    resourceBundleKeys[i]);
            OptionsCollectionBean ocBean = new OptionsCollectionBean(value, value);
            actionOptions.add(ocBean);
        }
        return actionOptions;
    }
    
    private List getGuestSettingOptions() {
        List guestSettingOptions = new LinkedList();
        String [] resourceBundleKeys = {
                "virtualguestslist.jsp.setguestvcpus",
                "virtualguestslist.jsp.setguestmemory"
        };
        for (int i = 0; i < resourceBundleKeys.length; i++) {
            String value = LocalizationService.getInstance().getMessage(
                    resourceBundleKeys[i]);
            OptionsCollectionBean ocBean = new OptionsCollectionBean(value, value);
            guestSettingOptions.add(ocBean);
        }
        return guestSettingOptions;
    }
    
    /**
     * Sets the status and entitlementLevel variables of each System Overview
     * @param dr The list of System Overviews
     * @param user The user viewing the System List
     */
    public void setStatusDisplay(DataResult dr, User user) {
        Iterator i = dr.iterator();
        
        while (i.hasNext()) {
            
            VirtualSystemOverview next = (VirtualSystemOverview) i.next();

            // If the system is not registered with RHN, we cannot show a status
            if (next.getSystemId() != null) {
                Long instanceId = next.getId();
                next.setId(next.getSystemId());
                SystemListHelper.setSystemStatusDisplay(user, next);
                next.setId(instanceId);
            }
        }
    }

    
    // Had to override getDataResult because in
    // BaseSystemListSetupAction we have no access to the
    // HttpServletRequest.  We need the request here to find the sid.
    protected DataResult getDataResult(User user,
                                       PageControl pc,
                                       HttpServletRequest request) {
        
        RequestContext ctx = new RequestContext(request);
        Long sid = ctx.getRequiredParam(RequestContext.SID);
        
        DataResult dr = SystemManager.virtualGuestsForHostList(user, sid, pc);

        for (int i = 0; i < dr.size(); i++) {
            VirtualSystemOverview current = (VirtualSystemOverview) dr.get(i);
            current.setSystemId(current.getVirtualSystemId());
        }

        return dr;
    }

    protected DataResult getDataResult(User user, PageControl pc, ActionForm form) {
        // Never call this.
        return null;
    }

    /** 
     * Retrives the set declation item
     * where the contents of the page control
     * are to be set.
     * @return set declation item
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.VIRTUAL_SYSTEMS;
    }

}
