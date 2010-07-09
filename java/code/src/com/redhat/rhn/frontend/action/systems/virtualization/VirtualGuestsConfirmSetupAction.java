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
import com.redhat.rhn.domain.action.ActionType;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.systems.BaseSystemListSetupAction;
import com.redhat.rhn.frontend.action.systems.SystemListHelper;
import com.redhat.rhn.frontend.dto.VirtualSystemOverview;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.system.VirtualizationActionCommand;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Iterator;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * VirtualGuestsListSetupAction
 * @version $Rev$
 */
public class VirtualGuestsConfirmSetupAction extends BaseSystemListSetupAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext ctx = new RequestContext(request);
        User user = ctx.getLoggedInUser();
        PageControl pc = new PageControl();
        pc.setIndexData(true);
        pc.setFilterColumn("name");
        pc.setFilter(true);

        clampListBounds(pc, request, user);

        DataResult dr = getDataResult(user, pc, formIn);
        RhnSet set = getSetDecl().get(user);
        if (!(dr.size() > 0)) {
            request.setAttribute(SHOW_NO_SYSTEMS, Boolean.TRUE);
        }

        String actionName = request.getParameter("actionName");

        String guestSettingValue = request.getParameter("guestSettingValue");
        if (guestSettingValue != null) {
            request.setAttribute("guestSettingValue", guestSettingValue);
        }

        setStatusDisplay(dr, user);
        setActionDisplay(dr, user, actionName, guestSettingValue);
        Long sid = ctx.getRequiredParam(RequestContext.SID);
        Server server = SystemManager.lookupByIdAndUser(sid, user);

        request.setAttribute("set", set);
        request.setAttribute("pageList", dr);
        request.setAttribute("system", server);

        return mapping.findForward("default");
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

    /**
     * Set up the action information for the list
     * @param dr DataResult for this list
     * @param user User currently logged in
     * @param actionName String representation of the action name
     */
    private void setActionDisplay(DataResult dr, User user, String actionName,
        String guestSettingValue) {

        Iterator i = dr.iterator();
        LocalizationService ls = LocalizationService.getInstance();

        while (i.hasNext()) {
            VirtualSystemOverview next = (VirtualSystemOverview) i.next();

            ActionType type
                = VirtualizationActionCommand.lookupActionType(next.getStateLabel(),
                                                               actionName);

            if (actionName.equals(VirtualGuestsConfirmAction.DELETE_ACTION)) {
                next.setDoAction(true);
                next.setActionName(ls.getMessage("systems.details.virt.guest.virt.delete"));

            }
            else if (type == null) {
                next.setDoAction(false);
                next.setNoActionReason(ls.getMessage("systems.details.virt.guest.already." +
                                                     next.getStateLabel()));
            }
            else {
                next.setDoAction(true);
                // Pass the guestSettingValue, even though it may be unused:
                next.setActionName(ls.getMessage("systems.details.virt.guest." +
                    type.getLabel(), new Object [] {guestSettingValue}));
            }
        }
    }

    protected DataResult getDataResult(User user, PageControl pc, ActionForm formIn) {
        DataResult dr = SystemManager.virtualSystemsInSet(user,
                                                          this.getSetDecl().getLabel(),
                                                          pc);

        for (int i = 0; i < dr.size(); i++) {
            VirtualSystemOverview current = (VirtualSystemOverview) dr.get(i);
            current.setSystemId(current.getVirtualSystemId());
        }

        return dr;
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
