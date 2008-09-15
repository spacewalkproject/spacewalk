/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.channel.ssm;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ChildChannelConfirmAction
 * @version $Rev$
 */
public class ChildChannelConfirmAction extends RhnAction {
    
    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm form,
            HttpServletRequest request,
            HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getLoggedInUser();
        DynaActionForm daForm = (DynaActionForm)form;
        request.setAttribute("parentUrl", request.getRequestURI());
        
        // First, find the channels the user chose to operate on, as stored
        // in an RhnSet by ChildChannelAction
        List<Channel> subList = new ArrayList();
        List<Channel> unsubList = new ArrayList();
        findChannelsFromSet(user, subList, unsubList);
        
        // Next, get the Servers that are in the SSM currently
        List<Server> servers = lookupSSMServers(user);
        
        // Then, get the lists of allowed subscriptions and un-subscriptions, 
        // for each server
        Map<Server, List<Channel>> subs = getSubs(user, servers, subList);
        Map<Server, List<Channel>> unsubs = getUnsubs(user, servers, unsubList);
        
        // Now, build the object that the page knows how to render
        List<ChannelActionDAO> changes = buildActionlist(subs, unsubs);

        // If we're submitted - Do It
        if (isSubmitted(daForm)) {
            doChangeSubscriptions(user, changes, request);

            request.setAttribute("channelchanges", changes);
            return mapping.findForward("success");
        }
        // Otherside - display the proposed changes and wait for confirmation
        else {
            request.setAttribute("channelchanges", changes);
            return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
        }
    }

    // Build the DAO list that the page can render
    protected List<ChannelActionDAO> buildActionlist(Map<Server, 
            List<Channel>> subs, Map<Server, List<Channel>> unsubs) {
        List<ChannelActionDAO> changes = new ArrayList();
        for (Server s : subs.keySet()) {
            // Skip servers that have no matches
            if (subs.get(s).isEmpty() && unsubs.get(s).isEmpty()) {
                continue;
            }
            ChannelActionDAO cad = new ChannelActionDAO();
            cad.setServer(s);
            cad.setSubsAllowed(subs.get(s));
            cad.setUnsubsAllowed(unsubs.get(s));
            changes.add(cad);
        }
        return changes;
    }
    
    // Get the Servers that comprise the current SSM selection/set
    protected List<Server> lookupSSMServers(User u) {
        RhnSet ssm = RhnSetDecl.SYSTEMS.lookup(u);
        List<Server> srvs = new ArrayList<Server>();
        if (ssm == null) {
            return srvs;
        }
        for (Object elt : ssm.getElements()) {
            RhnSetElement rse = (RhnSetElement)elt;
            Long sid = rse.getElement();
            srvs.add(SystemManager.lookupByIdAndUser(sid, u));
        }
        return srvs;
    }
    
    // Create Map<System,List<Channel>> allowed-subs
    // Foreach system in SSM for this user:
    //   Foreach chan-id in subscribe-list:
    //     If chan-accessible-to-system:
    //       Channel chanel = getChannel(id)
    //       allowed-subs.get(system).add(channel)
    protected Map<Server, List<Channel>> getSubs(
            User u,
            List<Server> ssm, 
            List<Channel> subChannels) {
        Map<Server, List<Channel>> subMap = new HashMap();
        for (Server s : ssm) {
            List<Channel> allowedChans = new ArrayList();
            subMap.put(s, allowedChans);
            for (Channel chan : subChannels) {
                // Check to see if we're allowed to sub to this channel
                // Note that there are TOO DAMN MANY CHECKS one has to do -
                // everything after "!isSubscribed()" needs to be in one
                // place.
                if (!s.isSubscribed(chan) &&
                    ChannelManager.verifyChannelSubscribe(u, chan.getId()) &&
                    SystemManager.verifyArchCompatibility(s, chan) &&
                    chan.isSubscribable(u.getOrg(), s) &&
                    chan.getParentChannel().equals(s.getBaseChannel()) &&
                    SystemManager.canServerSubscribeToChannel(u.getOrg(), s, chan)) {
                    allowedChans.add(chan);
                }
            }
        }
        return subMap;
    }
    
    // Actually change the subscriptions for the servers
    protected void doChangeSubscriptions(User u, List<ChannelActionDAO> changes, 
            HttpServletRequest req) {
        ActionErrors errs = new ActionErrors();
        ActionMessages msgs = new ActionMessages();
        
        int numSubs = 0;
        int numUnsubs = 0;
        for (ChannelActionDAO cad : changes) {
            for (Channel chan : cad.getSubsAllowed()) {
                try {
                    SystemManager.subscribeServerToChannel(u, cad.getServer(), chan);
                    numSubs++;
                }
                catch (Exception e) {
                    errs.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                            "ssmchildsubs.jsp.failedSubscribe", chan.getName()));
                }
            }
            for (Channel chan : cad.getUnsubsAllowed()) {
                try {
                    SystemManager.unsubscribeServerFromChannel(u, cad.getServer(), chan);
                    numUnsubs++;
                }
                catch (Exception e) {
                    errs.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                            "ssmchildsubs.jsp.failedUnsubscribe", chan.getName()));
                }
            }
        }
        
        // TODO - message should differentiate between '1' and 'not 1'
        if (numSubs > 0) { 
            addGlobalMessage(msgs, "ssmchildsubs.jsp.successfulSubs", "" + numSubs);
        }
        if (numUnsubs > 0) {
            addGlobalMessage(msgs, "ssmchildsubs.jsp.successfulUnsubs", "" + numUnsubs);
        }
        
        if (!msgs.isEmpty()) {
            saveMessages(req, msgs);
        }

        if (!errs.isEmpty()) {
            addErrors(req, errs);
            saveMessages(req, errs);
        }
        
        
        RhnSet cset = RhnSetDecl.SSM_CHANNEL_LIST.get(u);
        cset.clear();
        RhnSetManager.store(cset);
    }
    
    // 
    // Build the list of channels we're going to unsubscribe systems from - per system,
    // we only unsubscribe if the system currently IS subscribed...
    //
    // Create Map<System,List<Channel>> allowed-unsubs
    //   Foreach chan-id in unsubscribe-list:
    //     If system-subscribed-to-channel:
    //       Channel chanel = getChannel(id)
    //       allowed-unsubs.get(system).add(channel)
    protected Map<Server, List<Channel>> getUnsubs(
            User u,
            List<Server> ssm, 
            List<Channel> unsubChannels) {
        Map<Server, List<Channel>> unsubMap = new HashMap();
        for (Server s : ssm) {
            List<Channel> allowedChans = new ArrayList();
            unsubMap.put(s, allowedChans);
            for (Channel chan : unsubChannels) {
                if (s.isSubscribed(chan)) {
                    allowedChans.add(chan);
                }
            }
        }
        return unsubMap;
    }

    // Extract the list of subscribe and unsubscribed channels from the RhNSet that 
    // was saved from the child-list page
    protected void findChannelsFromSet(User u, List<Channel> subs, List<Channel> unsubs) {
        RhnSet cset = RhnSetDecl.SSM_CHANNEL_LIST.get(u);
        Iterator itr = cset.getElements().iterator();
        while (itr.hasNext()) {
            RhnSetElement rse = (RhnSetElement)itr.next();
            Channel c = ChannelManager.lookupByIdAndUser(rse.getElement(), u);
            if (rse.getElementTwo().equals(ChannelActionDAO.SUBSCRIBE)) {
                subs.add(c);
            }
            else {
                unsubs.add(c);
            }
        }
    }
}
