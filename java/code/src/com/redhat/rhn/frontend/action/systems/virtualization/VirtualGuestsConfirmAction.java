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
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.ActionType;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.VirtualInstance;
import com.redhat.rhn.domain.server.VirtualInstanceFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.systems.BaseSystemListAction;
import com.redhat.rhn.frontend.dto.VirtualSystemOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.system.VirtualizationActionCommand;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * VirtualGuestsListAction
 * @version $Rev$
 */
public class VirtualGuestsConfirmAction extends BaseSystemListAction {

    private static Logger log = Logger.getLogger(VirtualGuestsConfirmAction.class);

    public static final String DELETE_ACTION = "delete";

    /**
     * Applies the selected errata
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward scheduleActions(ActionMapping mapping,
                                         ActionForm formIn,
                                         HttpServletRequest request,
                                         HttpServletResponse response) {
        log.debug("scheduleActions() called.");
        RhnSet set = updateSet(request);
        Map params = new HashMap();

        StrutsDelegate strutsDelegate = getStrutsDelegate();

        //if they chose no systems, return to the same page with a message
        if (set.isEmpty()) {
            ActionMessages msg = new ActionMessages();
            msg.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("virtualsystems.none"));
            params = makeParamMap(formIn, request);
            strutsDelegate.saveMessages(request, msg);
            return strutsDelegate.forwardParams(mapping.findForward("default"), params);
        }

        RequestContext ctx = new RequestContext(request);
        User user = ctx.getLoggedInUser();
        Long sid = ctx.getRequiredParam(RequestContext.SID);

        Server system = SystemManager.lookupByIdAndUser(sid, user);
        String actionName = request.getParameter("actionName");
        if (log.isDebugEnabled()) {
            log.debug("actionName: " + actionName);
        }

        DataResult dr = getDataResult(user, formIn, request);
        Iterator i = dr.iterator();

        int actionCount = 0;

        String key = null;

        while (i.hasNext()) {
            VirtualSystemOverview next = (VirtualSystemOverview) i.next();

            // If we are deleting then we need a different command.
            if (actionName.equals(DELETE_ACTION)) {
                Long vid = new Long(next.getId().longValue());
                VirtualInstance virtualInstance =
                    VirtualInstanceFactory.getInstance().lookupById(vid);
                VirtualInstanceFactory.getInstance().deleteVirtualInstance(virtualInstance);
                actionCount++;
                key = "virt.deleted";
            }
            else {
                ActionType type
                    = VirtualizationActionCommand.lookupActionType(next.getStateLabel(),
                                                               actionName);

                if (log.isDebugEnabled()) {
                    log.debug("next.StateLabel() : " + next.getStateLabel());
                    log.debug("type: " + type);
                }
                // Form currently only gathers one setting, but should this change
                // down the road support exists for multiple parameters via the
                // context object defined below:
                String guestSettingValue = request.getParameter("guestSettingValue");

                if (type != null) {
                    // If we are setting memory we need to convert to
                    // kilobytes from megabytes.
                    if (type.equals(ActionFactory.TYPE_VIRTUALIZATION_SET_MEMORY)) {
                        Integer megabytes = new Integer(guestSettingValue);
                        guestSettingValue = String.valueOf((megabytes.intValue() * 1024));
                    }

                    // Create a context that will eventually trickle down to specific virt
                    // action types so they can extract any parameters they require:
                    Map context = new HashMap();
                    // Map based on the action name for now:
                    context.put(actionName, guestSettingValue);

                    actionCount++;
                    VirtualizationActionCommand cmd
                        = new VirtualizationActionCommand(user,
                                                          new Date(),
                                                          type,
                                                          system,
                                                          next.getUuid(),
                                                          context);
                    cmd.store();
                }
                key = "actions.scheduled";
            }
        }

        ActionMessages msg = new ActionMessages(); //make the message

        if (actionCount == 0) {
            msg.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("systems.details.virt.no." + key));
        }
        else if (actionCount == 1) {
            msg.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("systems.details.virt.one." + key));
        }
        else {
        msg.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage("systems.details.virt." + key,
                                  new Integer(actionCount)));
        }

        strutsDelegate.saveMessages(request, msg);

        params = makeParamMap(formIn, request);
        // Clear RhnSet as action has occurred
        set.clear();
        return strutsDelegate.forwardParams(mapping.findForward("success"), params);
    }

    protected DataResult getDataResult(User user, ActionForm formIn,
            HttpServletRequest request) {
        DataResult dr = SystemManager.virtualSystemsInSet(user,
                                                          this.getSetDecl().getLabel(),
                                                          null);

        for (int i = 0; i < dr.size(); i++) {
            VirtualSystemOverview current = (VirtualSystemOverview) dr.get(i);
            current.setSystemId(current.getVirtualSystemId());
        }

        return dr;
    }

    protected void processMethodKeys(Map map) {
        map.put("virtualguests_confirm.jsp.confirm", "scheduleActions");
    }

    protected void processParamMap(ActionForm formIn,
            HttpServletRequest request, Map params) {
        RequestContext ctx = new RequestContext(request);
        Long sid = ctx.getRequiredParam(RequestContext.SID);
        if (sid != null) {
            params.put("sid", sid);
        }
    }

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.VIRTUAL_SYSTEMS;
    }
}
