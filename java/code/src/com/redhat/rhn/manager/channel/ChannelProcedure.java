/**
 * Copyright (c) 2010 Red Hat, Inc.
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
package com.redhat.rhn.manager.channel;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.ChannelFamily;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerHistoryEvent;
import com.redhat.rhn.domain.task.Task;
import com.redhat.rhn.domain.task.TaskFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.errata.cache.ErrataCacheManager;
import com.redhat.rhn.manager.system.IncompatibleArchException;
import com.redhat.rhn.manager.system.SystemManager;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;


/**
 * ChannelProcedure
 * @version $Rev$
 */
public class ChannelProcedure {
    private static final ChannelProcedure INSTANCE = new ChannelProcedure();
    
    private ChannelProcedure() {
        
    }
    
    /**
     * @return an instance of the channle procedure objects 
     */
    public static ChannelProcedure getInstance() {
        return INSTANCE;
    }

    /**
     * Executes the procedure to subscribe a channel to a server 
     * @param user The user object needs to have subscribe permissions
     * @param server  server object
     * @param channel the channel to subscribe
     */
    public void subscribeServer(User user, Server server,
            Channel channel) {
        subscribeServer(user, server, channel, false);
    }
    
    /**
     * Executes the procedure to subscribe a channel to a server 
     * @param user The user object needs to have subscribe permissions
     * @param server  server object
     * @param channel the channel to subscribe
     * @param asyncCacheUpdate update the cache asynchronously. False to update immediately
     */
    public void subscribeServer(User user, Server server,
            Channel channel, boolean asyncCacheUpdate) {
        
        // do not allow non-satellite or non-proxy servers to 
        // be subscribed to satellite or proxy channels respectively.
        if (channel.isSatellite()) {
            if (!server.isSatellite()) {
                return;
            }
        }
        else if (channel.isProxy()) {
            if (!server.isProxy()) {
                return;
            }
        }        
        
        if (!SystemManager.verifyArchCompatibility(server, channel)) {
            throw new IncompatibleArchException(
                    server.getServerArch(), channel.getChannelArch());
        }
        
        if (user != null && 
                !ChannelManager.verifyChannelSubscribe(user, channel.getId())) {
            //Throw an exception with a nice error message so the user
            //knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException("User does not have" +
                    " permission to subscribe this server to this channel.");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.subscribechannel"));
            pex.setLocalizedSummary(
                    ls.getMessage("permission.jsp.summary.subscribechannel"));
            throw pex;
        }
        if (!channel.isBaseChannel()) {
            //make sure that the parent is subscribed to the server
            if (!channel.getParentChannel().equals(server.getBaseChannel())) {
                return;    
            }
        }
        else if (server.getBaseChannel() != null) {
            String msg = "Attempted to subscribe a base channel [%s] while the" +
                                        " system [%s] is already subscribed to [%s]";
            throw new ChannelSubscriptionException(String.format(msg, 
                                channel, server, server.getBaseChannel()));
        }
        
        if (server.isSubscribed(channel)) {
            //already subscribed no worries :)
            return;
        }
        if (channel.getChannelFamily() == null) {
            String msg = "No channel family for channel [%s] while" +
                    " attempting to subscribe to  system [%s] ";
            throw new ChannelSubscriptionException(String.format(msg, 
                                channel, server));
        }
        
        // Use the org_id of the server only if the org_id of the channel = NULL.
        // This is required for subscribing to shared channels.
        Org org = (channel.getOrg() == null) ? server.getOrg() : channel.getOrg();
        //need do a select for update Lock on current Members
        
        ChannelFactory.lockPrivateChannelFamily(
                channel.getChannelFamily().getChannelFamilyAllocationFor(org));
        if (channel.getChannelFamily().hasAvailableSlots(org) || 
                            canConsumeVirtChannels(server, channel)) {
            ServerHistoryEvent event = new ServerHistoryEvent();
            event.setCreated(new Date());
            event.setServer(server);
            int summaryColumnLength  = 128;
            String summary = "subscribed to channel "  + channel.getLabel();
            event.setSummary(summary.substring(0, 
                    Math.min(summary.length(), summaryColumnLength)));
            event.setDetails(channel.getLabel());
            server.getHistory().add(event);
            server.addChannel(channel);
            server.setChannelsChanged(new Date());
            SystemManager.storeServer(server);
            updateChannelFamilyCounts(channel.getChannelFamily(), org);
            updateServerCache(server, asyncCacheUpdate);
        }
        else {
            String msg = "No slots available for the following channel family [%s]";
            throw new ChannelSubscriptionException(String.format(msg, 
                                            channel.getChannelFamily()));
        }
    }

    private boolean canConsumeVirtChannels(Server serverIn, Channel channelIn) {
        SelectMode m = ModeFactory.getMode("Channel_queries", 
                "can_consume_virt_channel");
        Map params = new HashMap();
        params.put("cfid", channelIn.getChannelFamily().getId());
        params.put("sid", serverIn.getId());
        DataResult dr = m.execute(params);
        return !dr.isEmpty();
    }

    private void updateServerCache(Server serverIn, boolean asyncCacheUpdate) {
        if (asyncCacheUpdate) {
            Task task = new Task();
            task.setOrg(serverIn.getOrg());
            task.setName("update_server_errata_cache");
            task.setData(serverIn.getId());
            TaskFactory.save(task);            
        }
        else {
            ErrataCacheManager.deleteServerNeededCache(serverIn.getId());
            ErrataCacheManager.insertServerNeededCache(serverIn.getId());
        }
    }


    private void updateChannelFamilyCounts(ChannelFamily channelFamilyIn,
            Org orgIn) {
        Long currentMembers  = computeCurrentMemberCounts(channelFamilyIn, orgIn);
        channelFamilyIn.setCurrentMembers(orgIn, currentMembers);
    }
    
    /**
     * COmpute current member counts.  That is the current number of
     *      systems using a channel family (basically a real time computation
     *      of rhnPrivateChannelFamily.current_members
     * @param channelFamilyIn the channel family
     * @param orgIn the Org
     * @return the Number used
     */
    public Long computeCurrentMemberCounts(ChannelFamily channelFamilyIn,
            Org orgIn) {
        SelectMode m = ModeFactory.getMode("Channel_queries", 
                                "compute_channel_family_curent_members");
        Map params = new HashMap();
        params.put("cfid", channelFamilyIn.getId());
        params.put("org_id", orgIn.getId());
        DataResult<Map<String, Object>> dr = m.execute(params);
        return (Long) dr.get(0).get("count");
        
    }


}
