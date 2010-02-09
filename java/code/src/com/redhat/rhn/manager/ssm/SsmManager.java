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
package com.redhat.rhn.manager.ssm;

import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.channel.ssm.ChannelActionDAO;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * The current plan for this class is to manage all SSM operations. However, as more is
 * ported from perl to java, there may be a need to break this class into multiple
 * managers to keep it from becoming unwieldly.
 *
 * @author Jason Dobies
 * @version $Revision$
 */
public class SsmManager {

    private static Log log = LogFactory.getLog(SsmManager.class);
    
    /** Private constructor to enforce the stateless nature of this class. */
    private SsmManager() {
    }

    /**
     * Given a list of servers and channels that should be subscribed, determines which
     * channels may be subscribed to by which servers. The mapping returned will be from
     * each server to a list of channels that may be subscribed. This list will not
     * be <code>null</code> but may be empty if no subscriptions are determined to be
     * allowed.
     *
     * @param user        user initiating the subscription
     * @param servers     all servers to map to channels; may not be <code>null</code>
     * @param allChannels channels to attempt to subscribe each server to; may not
     *                    be <code>null</code>
     * @return mapping of each server to a non-null (but potentially empty) list of
     *         channels that are safe to subscribe it to
     */
    public static Map<Server, List<Channel>> linkChannelsToSubscribeForServers(
        User user, List<Server> servers, List<Channel> allChannels) {

        // Mappings generated from this method 
        Map<Server, List<Channel>> result =
            new HashMap<Server, List<Channel>>(servers.size());

        // The channel roles won't change while we are processing, so it's safe to
        // cache them rather than reload them for each channel for each server
        Map<Channel, Boolean> channelToAcceptableRole =
            new HashMap<Channel, Boolean>(allChannels.size());

        // Keeps a mapping of how many entitlements are left on each channel. This map
        // will be updated as the processing continues, however changes won't be written
        // to the database until the actual subscriptions are made. This way we can keep
        // a more accurate representation of how many entitlements are left rather than
        // always loading the static value from the DB.
        Map<Channel, Long> channelToAvailableEntitlements =
            new HashMap<Channel, Long>(allChannels.size());

        for (Server server : servers) {
            List<Channel> allowedChannels = new ArrayList<Channel>();
            result.put(server, allowedChannels);

            for (Channel channel : allChannels) {

                // If the server is already subscribed, nothing to do 
                if (server.isSubscribed(channel)) {
                    continue;
                }

                // Check the architecture of the server against the channel
                if (!SystemManager.verifyArchCompatibility(server, channel)) {
                    continue;
                }

                // Check for proxy and satellite channels
                if (channel.isProxy() || channel.isSatellite()) {
                    continue;
                }

                // Make sure the parent channel and the server's base channel align
                if (!channel.getParentChannel().equals(server.getBaseChannel())) {
                    continue;
                }

                // Verify the user roles, caching the role for the channel
                Boolean hasAcceptableRole = channelToAcceptableRole.get(channel);
                if (hasAcceptableRole == null) {
                    hasAcceptableRole =
                        ChannelManager.verifyChannelSubscribe(user, channel.getId());
                    channelToAcceptableRole.put(channel, hasAcceptableRole);
                }

                if (!hasAcceptableRole) {
                    continue;
                }

                // Make sure the channel is either free to the server or we have
                // enough available entitlements to fill it
                Long availableEntitlements = channelToAvailableEntitlements.get(channel);

                if (availableEntitlements == null) {
                    availableEntitlements =
                        ChannelManager.getAvailableEntitlements(user.getOrg(), channel);
                    channelToAvailableEntitlements.put(channel, availableEntitlements);
                }

                if (!ChannelManager.isChannelFreeForSubscription(server, channel)) {

                    if (availableEntitlements != null && availableEntitlements < 1) {
                        continue;
                    }
                    else if (availableEntitlements != null) {
                        // Update our cached count for what will happen when 
                        // the subscribe is done
                        availableEntitlements = availableEntitlements - 1;
                        channelToAvailableEntitlements.put(channel, availableEntitlements);
                    }

                }

                // If we didn't punch out by now, it's allowed
                log.debug("Subscribing:: Server [" + server.getId() + " to channel [" +
                    channel.getLabel() + "]");

                allowedChannels.add(channel);
            }

        }

        return result;
    }

    /**
     * Given a list of servers and channels that should be unsubscribed, determines which
     * channels may be removed for which servers. The mapping returned will be from
     * each server to a list of channels that may be unsubscribed. This list will not
     * be <code>null</code> but may be empty if no subscriptions are determined to be
     * removed.
     *
     * @param servers     all servers to map to channels; may not be <code>null</code>
     * @param allChannels channels to attempt to unsubscribe each server to; may not
     *                    be <code>null</code>
     * @return mapping of each server to a non-null (but potentially empty) list of
     *         channels that are relevant to unsubscribe
     */
    public static Map<Server, List<Channel>> linkChannelsToUnsubscribeForServers(
        List<Server> servers,
        List<Channel> allChannels) {
        Map<Server, List<Channel>> unsubMap = new HashMap<Server, List<Channel>>();

        for (Server s : servers) {
            List<Channel> allowedChans = new ArrayList<Channel>();

            for (Channel chan : allChannels) {
                if (s.isSubscribed(chan)) {
                    allowedChans.add(chan);
                }
            }

            unsubMap.put(s, allowedChans);
        }

        return unsubMap;
    }

    /**
     * Performs channel subscriptions. This method assumes the changes have been validated
     * through:
     * <ul>
     * <li>{@link #linkChannelsToSubscribeForServers(User, List, List)}</li>
     * <li>{@link #linkChannelsToUnsubscribeForServers(List, List)}</li>
     * </ul>
     * <p/>
     * Furthermore, this call assumes the changes have been written to the necessary
     * RhnSets via:
     * <ul>
     * <li>{@link #populateSsmChannelServerSets(User, List)}</li>
     * </ul>
     *
     * @param user user performing the action creations
     */
    public static void performChannelActions(User user) {

        long start, duration;

        RhnSet subscribeSet = RhnSetDecl.SSM_CHANNEL_SUBSCRIBE.get(user);
        RhnSet unsubscribeSet = RhnSetDecl.SSM_CHANNEL_UNSUBSCRIBE.get(user);

        Map<String, Object> params = new HashMap<String, Object>();

        // New Subscriptions
        if (subscribeSet.size() > 0) {
            start = System.currentTimeMillis();
            WriteMode doSubscriptionsMode = ModeFactory.getWriteMode("ssm_queries",
                "subscribe_server_channels_in_set");
            doSubscriptionsMode.executeUpdate(params);
            duration = System.currentTimeMillis() - start;
            log.debug("Time to create all subscriptions: " + duration);

            start = System.currentTimeMillis();
            WriteMode logSubscriptionsMode = ModeFactory.getWriteMode("ssm_queries",
                "log_subscribe_server_channels_in_set");
            logSubscriptionsMode.executeUpdate(params);
            duration = System.currentTimeMillis() - start;
            log.debug("Time to log all subscriptions: " + duration);

            start = System.currentTimeMillis();
            params.put("set_label", "ssm_channel_subscribe");
            WriteMode subscribeFlagMode = ModeFactory.getWriteMode("ssm_queries",
                "flag_server_channels_changed_in_set");
            subscribeFlagMode.executeUpdate(params);
            duration = System.currentTimeMillis() - start;
            log.debug("Time to flag for all subscriptions: " + duration);
        }

        // Unsubscribe
        if (unsubscribeSet.size() > 0) {
            start = System.currentTimeMillis();
            WriteMode doUnsubscriptionsMode = ModeFactory.getWriteMode("ssm_queries",
                "unsubscribe_server_channels_in_set");
            doUnsubscriptionsMode.executeUpdate(params);
            duration = System.currentTimeMillis() - start;
            log.debug("Time to do all unsubscriptions: " + duration);

            start = System.currentTimeMillis();
            WriteMode logUnsubscriptionsMode = ModeFactory.getWriteMode("ssm_queries",
                "log_unsubscribe_server_channels_in_set");
            logUnsubscriptionsMode.executeUpdate(params);
            duration = System.currentTimeMillis() - start;
            log.debug("Time to log all unsubscriptions: " + duration);

            start = System.currentTimeMillis();
            params.put("set_label", "ssm_channel_unsubscribe");
            WriteMode unsubscribeFlagMode = ModeFactory.getWriteMode("ssm_queries",
                "flag_server_channels_changed_in_set");
            unsubscribeFlagMode.executeUpdate(params);
            duration = System.currentTimeMillis() - start;
            log.debug("Time to flag for all unsubscriptions: " + duration);
        }

        // Clean up the sets
        subscribeSet.clear();
        RhnSetManager.store(subscribeSet);

        unsubscribeSet.clear();
        RhnSetManager.store(unsubscribeSet);
    }

    /**
     * Parses through the indicated changes, populating the necessary RhnSets. This call
     * is necessary before {@link #performChannelActions(User)} as the perform call
     * requires the sets contain the subscription change information.
     * 
     * @param user    user performing the change
     * @param actions subscription changes being made
     */
    public static void populateSsmChannelServerSets(User user,
                                                    List<ChannelActionDAO> actions) {

        RhnSet subscribeSet = RhnSetDecl.SSM_CHANNEL_SUBSCRIBE.get(user);
        RhnSet unsubscribeSet = RhnSetDecl.SSM_CHANNEL_UNSUBSCRIBE.get(user);

        for (ChannelActionDAO action : actions) {
            Server server = action.getServer();
            long serverId = server.getId();

            // New Subscriptions
            if (action.getSubsAllowed() != null) {
                for (Channel subscribeMe : action.getSubsAllowed()) {
                    subscribeSet.addElement(serverId, subscribeMe.getId());
                }
            }

            // Unsubscribe
            if (action.getUnsubsAllowed() != null) {
                for (Channel unsubscribeMe : action.getUnsubsAllowed()) {
                    unsubscribeSet.addElement(serverId, unsubscribeMe.getId());
                }
            }
        }

        RhnSetManager.store(subscribeSet);
        RhnSetManager.store(unsubscribeSet);
    }

    /**
     * Assembles a mapping of server to subscriptions and unsubscriptions.
     *
     * @param subs   mapping of server to list of subscriptions to create; the map
     *               cannot be <code>null</code> but the channel list for a server may be
     * @param unsubs mapping of server to list of subscriptions to remove; the map
     *               cannot be <code>null</code> but the channel list for a server may be
     * @return consolidated list of subscription changes
     */
    public static List<ChannelActionDAO> buildActionlist(Map<Server,
        List<Channel>> subs, Map<Server, List<Channel>> unsubs) {
        List<ChannelActionDAO> changes = new ArrayList<ChannelActionDAO>();
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

    /**
     * Adds the selected server IDs to the SSM RhnSet.
     * 
     * @param user      cannot be <code>null</code>
     * @param serverIds cannot be <code>null</code>
     */
    @SuppressWarnings("unchecked")
    public static void addServersToSsm(User user, String[] serverIds) {
        RhnSet set = RhnSetDecl.SYSTEMS.get(user);
        set.addAll(Arrays.asList(serverIds));
        RhnSetManager.store(set);
    }

    /**
     * Clears the list of servers in the SSM.
     * 
     * @param user cannot be <code>null</code>
     */
    public static void clearSsm(User user) {
        RhnSet set = RhnSetDecl.SYSTEMS.get(user);
        set.clear();
        RhnSetManager.store(set);
    }
}
