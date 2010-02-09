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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.util.LabelValueBean;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * CloneErrataSubmitAction
 *
 * @version $Rev$
 */
public class CloneErrataAction extends RhnAction implements Listable {

    public static final String ANY_CHANNEL = "any_channel";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping actionMapping,
                                 ActionForm actionForm,
                                 HttpServletRequest request,
                                 HttpServletResponse response)
        throws Exception {

        ListRhnSetHelper helper =
            new ListRhnSetHelper(this, request, RhnSetDecl.ERRATA_CLONE);
        helper.execute();

        ActionForward forward;
        if (helper.isDispatched()) {
            // Nothing to do when dispatched, there is a confirmation page displayed next
            // that will do the actual work
            forward = actionMapping.findForward("continue");
        }
        else {
            RequestContext context = new RequestContext(request);
            populateChannelDropDown(context);

            forward = actionMapping.findForward("default");
        }

        return forward;
    }

    /** {@inheritDoc} */
    public List getResult(RequestContext context) {
        User user = context.getLoggedInUser();
        Long orgId = user.getOrg().getId();

        // Determine if a specific channel is being selected
        String channel = context.getParam("channel", false);

        // Determine whether or not to show already cloned errata
        boolean showAlreadyCloned = context.getParam("showalreadycloned", false) != null;

        DataResult result;

        if (channel == null || channel.equals(ANY_CHANNEL)) {
            result = ErrataManager.clonableErrata(orgId, showAlreadyCloned);
        }
        else {
            // Example value of channel parameter:  channel_141
            long channelId = Long.parseLong(channel.substring(8));

            result = ErrataManager.clonableErrataForChannel(orgId,
                channelId, showAlreadyCloned);
        }

        return result;
    }

    private void populateChannelDropDown(RequestContext rctx) {

        LocalizationService ls = LocalizationService.getInstance();

        List<LabelValueBean> displayList = new ArrayList<LabelValueBean>();
        displayList.add(new LabelValueBean(ls.getMessage("cloneerrata.anychannel"),
            ANY_CHANNEL));

        List channels = ChannelManager.
            getChannelsWithClonableErrata(rctx.getCurrentUser().getOrg());

        if (channels != null) {
            for (Iterator i = channels.iterator(); i.hasNext();) {
                Channel c = (Channel) i.next();
                // /me wonders if this shouldn't be part of the query.
                if ("rpm".equals(c.getChannelArch().getArchType().getLabel())) {
                    displayList.add(new LabelValueBean(c.getName(),
                        "channel_" + c.getId()));
                }
            }
        }

        rctx.getRequest().setAttribute("clonablechannels", displayList);
    }
}
