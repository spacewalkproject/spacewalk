/**
 * Copyright (c) 2009--2011 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.systems.sdc;

import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

/**
 * SystemNoteEditAction
 * @version $Rev: 1 $
 */
public class SystemDeleteConfirmAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm form,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext rctx = new RequestContext(request);
        DynaActionForm daForm = (DynaActionForm)form;
        StrutsDelegate strutsDelegate = getStrutsDelegate();

        ActionForward forward = null;
        Map params = new HashMap();

        User loggedInUser = rctx.getLoggedInUser();
        Long sid = rctx.getRequiredParam(RequestContext.SID);
        Server server = SystemManager.lookupByIdAndUser(sid, loggedInUser);

        request.setAttribute("system", server);
        request.setAttribute("sid", sid);

        params.put(RequestContext.SID, request.getParameter(RequestContext.SID));
        forward = strutsDelegate.forwardParams(
                mapping.findForward(RhnHelper.DEFAULT_FORWARD), params);

        if (isSubmitted(daForm)) {
            if (server.hasEntitlement(EntitlementManager.MANAGEMENT)) {
                // But what if this system is in some other user's RhnSet???
                RhnSet set = RhnSetDecl.SYSTEMS.get(loggedInUser);

                // Remove from SSM if required
                if (set.getElementValues().contains(sid)) {
                    set.removeElement(sid);
                    RhnSetManager.store(set);
                }
            }

            try {
                // Now we can remove the system
                SystemManager.deleteServer(loggedInUser, sid);
                createSuccessMessage(request, "message.serverdeleted.param",
                        sid.toString());
            }
            catch (RuntimeException e) {
                if (e.getMessage().contains("cobbler")) {
                    createErrorMessage(request, "message.servernotdeleted_cobbler",
                            sid.toString());
                }
                else {
                    createErrorMessage(request, "message.servernotdeleted", sid.toString());
                    throw e;
                }
            }

            forward = strutsDelegate.forwardParams(mapping.findForward("success"), params);
        }

        return forward;
    }

}
