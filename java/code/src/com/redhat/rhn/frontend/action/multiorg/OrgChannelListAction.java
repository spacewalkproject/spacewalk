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
package com.redhat.rhn.frontend.action.multiorg;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.dto.OrgChannelDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListSessionSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.org.OrgManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Handles the (un)enabling of organizations trusted to a channel. 
 */
public class OrgChannelListAction extends RhnAction implements Listable {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping actionMapping,
                                 ActionForm actionForm,
                                 HttpServletRequest request,
                                 HttpServletResponse response)
        throws Exception {

        // Before we do anything, make sure the channel is actually configured
        // with protected access
        RequestContext context = new RequestContext(request);
        Long cid = context.getParamAsLong("cid");
        Channel channel = ChannelManager.lookupByIdAndUser(cid, context.getLoggedInUser());

        if (!channel.isProtected()) {
            throw new PermissionException("Channel does not have protected access");
        }

        request.setAttribute("channel_name", channel.getName());
        request.setAttribute(ListTagHelper.PARENT_URL,
            request.getRequestURI() + "?" +
                RequestContext.CID + "=" + channel.getId());

        // Begin normal ListTag 3.0 usage
        ListSessionSetHelper helper = new ListSessionSetHelper(this, request);
        helper.ignoreEmptySelection();
        helper.execute();

        if (helper.isDispatched()) {
            Set<String> selectedItems = helper.getSet();

            handleDispatch(context.getLoggedInUser(), channel, selectedItems);

            helper.destroy();

            String messageKey =
                selectedItems.size() != 1 ?  "orgs.trust.channels.plural.jsp.enabled" :
                                             "orgs.trust.channels.single.jsp.enabled";
            getStrutsDelegate().saveMessage(messageKey,
                            new String [] {String.valueOf(selectedItems.size())}, request);

            request.setAttribute("channel_name", channel.getName());
            Map<String, String> params = new HashMap<String, String>();
            params.put(RequestContext.CID, channel.getId().toString());
            StrutsDelegate strutsDelegate = getStrutsDelegate();
            return strutsDelegate.forwardParams
                            (actionMapping.findForward("success"), params);

        }

        return actionMapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /** {@inheritDoc} */
    public List getResult(RequestContext context) {
        User user = context.getLoggedInUser();
        Org org = user.getOrg();
        Long cid = context.getParamAsLong(RequestContext.CID);
        return OrgManager.orgChannelTrusts(cid, org);
    }

    private void handleDispatch(User user, Channel channel, Set<String> selectedOrgs) {

        // Load the current list of trusts for the channel
        List<OrgChannelDto> trusts =
            OrgManager.orgChannelTrusts(channel.getId(), user.getOrg());

        Set<Org> s = channel.getTrustedOrgs();
        for (OrgChannelDto item : trusts) {
            Org org = OrgFactory.lookupById(item.getId());
            if (!item.isSelected() && selectedOrgs.contains(org.getId().toString())) {
                s.add(org);
            }
            else if (item.isSelected() && !selectedOrgs.contains(org.getId().toString())) {
                s.remove(org);
                unsubscribeSystems(org, channel);
            }
        }
    }

    @SuppressWarnings("unchecked")
    private void unsubscribeSystems(Org orgIn, Channel c) {
        User u = UserFactory.findRandomOrgAdmin(orgIn);
        DataResult<Map<String, Object>> myList =
            SystemManager.systemsSubscribedToChannel(c, u);

        for (Map<String, Object> m : myList) {
            Long sid = (Long) m.get("id");
            Server s = SystemManager.lookupByIdAndUser(sid, u);

            if (s.isSubscribed(c)) {
                // check if this is a base custom channel
                if (c.getParentChannel() == null) {
                    // unsubscribe children first if subscribed
                    List<Channel> children = c.getAccessibleChildrenFor(u);

                    for (Channel child : children) {
                        if (s.isSubscribed(child)) {
                            // unsubscribe server from child channel
                            child.getTrustedOrgs().remove(orgIn);
                            ChannelFactory.save(child);
                            s = SystemManager.unsubscribeServerFromChannel(s, child);
                        }
                    }
                }
                // unsubscribe server from channel
                SystemManager.unsubscribeServerFromChannel(s, c);
            }
        }
    }

}
