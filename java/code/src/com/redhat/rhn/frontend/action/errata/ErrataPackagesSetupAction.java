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
package com.redhat.rhn.frontend.action.errata;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ChannelOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ErrataPackagesSetupAction
 * @version $Rev$
 */
public class ErrataPackagesSetupAction extends RhnAction {
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();

        User user = requestContext.getLoggedInUser();
        Errata errata = requestContext.lookupErratum();

        List<ChannelOverview> chans = new ArrayList<ChannelOverview>();

        for (Channel chan : errata.getChannels()) {
            if (UserManager.verifyChannelSubscribable(user, chan)) {
                ChannelOverview co = new ChannelOverview();
                co.setName(chan.getName());
                co.setId(chan.getId());
                co.setPackages(ChannelManager.listErrataPackages(chan, errata));
                chans.add(co);
            }
        }

        Collections.sort(chans);

        request.setAttribute("errata", errata);
        request.setAttribute("channels", chans);

        return strutsDelegate.forwardParams(mapping.findForward("default"),
                                       request.getParameterMap());
    }
}
