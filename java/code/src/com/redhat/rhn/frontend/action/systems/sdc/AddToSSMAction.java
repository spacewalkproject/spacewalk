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
package com.redhat.rhn.frontend.action.systems.sdc;

import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserServerPreferenceId;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
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
 * SystemOverviewAction
 * @version $Rev$
 */
public class AddToSSMAction extends RhnAction {

    public static final String[] SERVER_PREFERENCES = {UserServerPreferenceId
                                                       .INCLUDE_IN_DAILY_SUMMARY,
                                                       UserServerPreferenceId
                                                       .RECEIVE_NOTIFICATIONS};

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {
        RequestContext rctx = new RequestContext(request);
        Long sid = rctx.getRequiredParam("sid");
        User user = rctx.getLoggedInUser();
        Server s  = SystemManager.lookupByIdAndUser(sid, user);

        if (s.hasEntitlement(EntitlementManager.MANAGEMENT)) {
            RhnSet set = RhnSetDecl.SYSTEMS.get(user);

            if (!set.getElementValues().contains(s.getId())) {
                set.addElement(s.getId());
                RhnSetManager.store(set);

                ActionMessages msg = new ActionMessages();
                msg.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("system.sdc.addtossm"));
                getStrutsDelegate().saveMessages(request, msg);

            }

        }

        Map params = new HashMap();
        params.put("sid", sid);
        return getStrutsDelegate().forwardParams(mapping.findForward("default"), params);


    }


}
