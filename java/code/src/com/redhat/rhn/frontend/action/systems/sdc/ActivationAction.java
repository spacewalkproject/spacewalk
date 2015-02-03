/**
 * Copyright (c) 2014 Red Hat, Inc.
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

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.kickstart.KickstartSessionState;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.token.ActivationKeyFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.token.ActivationKeyManager;

/**
 * SystemHardwareAction handles the interaction of the ChannelDetails page.
 * @version $Rev$
 */
public class ActivationAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext ctx = new RequestContext(request);
        User user =  ctx.getCurrentUser();
        Server server = ctx.lookupAndBindServer();
        Long sid = server.getId();

        SystemManager.ensureAvailableToUser(user, sid);

        List<ActivationKey> keys = ActivationKeyFactory.lookupByServer(server);

        // There should only be one, if multiple that's wrong. Can get in that state
        // from old version of API. Remove them if multiple.
        if (keys.size() > 1) {
            for (ActivationKey key : keys) {
                ActivationKeyFactory.removeKey(key);
            }
            keys = new ArrayList<ActivationKey>();
        }

        ActivationKey key = null;
        if (keys.size() == 1) {
            key = keys.get(0);
        }

        // if reactivation key is already used up, delete it
        if (key != null && key.isDisabled()) {
            ActivationKeyFactory.removeKey(key);
            key = null;
        }

        // if in the middle of a kickstart, warn
        KickstartSession session = KickstartFactory.lookupKickstartSessionByServer(sid);
        if (session != null &&
                !(session.getState().getLabel().equals(KickstartSessionState.COMPLETE) ||
                session.getState().getLabel().equals(KickstartSessionState.FAILED))) {
            getStrutsDelegate().saveMessage("sdc.activation.kickstarting", request);
        }

        if (ctx.isSubmitted()) {
            if (key != null) {
                ActivationKeyFactory.removeKey(key);
                key = null;
            }
            if (ctx.hasParam("generate")) {
                String note = "Reactivation key for " + server.getName() + ".";
                key = ActivationKeyManager.getInstance().createNewReActivationKey(user,
                        server, note);
                key.setUsageLimit(1L);
            }
        }

        if (key != null) {
            request.setAttribute("key", key.getKey());
        }

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

}
