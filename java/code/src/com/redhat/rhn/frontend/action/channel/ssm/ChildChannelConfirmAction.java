/**
 * Copyright (c) 2009 Red Hat, Inc.
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
import com.redhat.rhn.domain.server.ServerFactory;
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
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.util.ArrayList;
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
    
    private final Log log = LogFactory.getLog(this.getClass());
    
    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm form,
            HttpServletRequest request,
            HttpServletResponse response) {

        long start, overallStart;
        
        overallStart = System.currentTimeMillis();

        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getLoggedInUser();
        DynaActionForm daForm = (DynaActionForm)form;
        request.setAttribute("parentUrl", request.getRequestURI());
        
        // First, find the channels the user chose to operate on, as stored
        // in an RhnSet by ChildChannelAction
        List<Channel> subList = new ArrayList<Channel>();
        List<Channel> unsubList = new ArrayList<Channel>();
        
        findChannelsFromSet(user, subList, unsubList);
        
        // Next, get the Servers that are in the SSM currently
        List<Server> servers = ServerFactory.listSystemsInSsm(user);
        
        // Then, get the lists of allowed subscriptions and un-subscriptions, 
        // for each server
        Map<Server, List<Channel>> subs =
            ChannelManager.linkChannelsToSubscribeForServers(user, servers, subList);
        
        Map<Server, List<Channel>> unsubs =
            ChannelManager.linkChannelsToUnsubscribeForServers(servers, unsubList);
        
        // Now, build the object that the page knows how to render
        List<ChannelActionDAO> changes = ChannelManager.buildActionlist(subs, unsubs);

        request.setAttribute("channelchanges", changes);
        
        ActionForward result;
        if (isSubmitted(daForm)) {
            start = System.currentTimeMillis();
            log.debug("Starting doChangeSubscriptions");
            ChannelManager.performChannelActions(user, changes);
            log.debug("Time for doChangeSubscriptions call: " + 
                (System.currentTimeMillis() - start));
            
            result = mapping.findForward("success");
        }
        else {
            result = mapping.findForward(RhnHelper.DEFAULT_FORWARD);
        }

        log.debug("Overall time to run: " + (System.currentTimeMillis() - overallStart));
        
        return result;
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
