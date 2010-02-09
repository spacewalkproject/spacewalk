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
package com.redhat.rhn.frontend.action.channel.manage;

import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Handles the page display and actual deletion of a software channel. 
 *  
 * @version $Revision$ 
 */
public class DeleteChannelAction extends RhnAction {
    private static final String DISABLE_DELETE = "disableDelete";
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping actionMapping,
                                 ActionForm actionForm,
                                 HttpServletRequest request,
                                 HttpServletResponse response)
        throws Exception {

        RequestContext context = new RequestContext(request);
        User user = context.getLoggedInUser();

        String sChannelId = request.getParameter("cid");
        long channelId = Long.parseLong(sChannelId);

        // Stuff the channel object into the request so the page can use its values
        Channel channel = ChannelManager.lookupByIdAndUser(channelId, user);
        request.setAttribute("channel", channel);

        // The channel doesn't carry its subscribed system count, so add this separately
        int subscribedSystemsCount =
            SystemManager.countSystemsSubscribedToChannel(channelId, user);
        request.setAttribute("subscribedSystemsCount", subscribedSystemsCount);

        // Load the number of systems subscribed through a trust relationship to
        // the channel
        int trustedSystemsCount =
            SystemManager.countSubscribedToChannelWithoutOrg(channel.getOrg().getId(),
                channelId);
        request.setAttribute("trustedSystemsCount", trustedSystemsCount);

        if (context.isSubmitted()) {
            String channelLabel = channel.getLabel();

            boolean override = request.getParameter("unsubscribeSystems") != null;

            if (override || subscribedSystemsCount == 0) {

                try {
                    ChannelManager.deleteChannel(user, channelLabel);
                }
                catch (PermissionException e) {
                    addMessage(request, e.getMessage());
                    return actionMapping.findForward("default");
                }
                catch (ValidatorException ve) {
                    getStrutsDelegate().saveMessages(request, ve.getResult());
                    request.setAttribute(DISABLE_DELETE, Boolean.TRUE);
                    return actionMapping.findForward("default");
                }

                createSuccessMessage(request, "message.channeldeleted", channel.getName());
                return actionMapping.findForward("success");
            }
            else {
                addMessage(request, "message.channel.delete.systemssubscribed");
                return actionMapping.findForward("default");
            }
        }
        else if (channel.containsDistributions()) {
            createErrorMessage(request, 
                    "message.channel.cannot-be-deleted.has-distros", null);
            request.setAttribute(DISABLE_DELETE, Boolean.TRUE);
        }

        return actionMapping.findForward("default");
    }
}
