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

import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.channel.ssm.ChannelActionDAO;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

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
     * @param sysMapping     the map of ChannelActionDAO objects
     * @param allChannels channels to attempt to subscribe each server to; may not
     *                    be <code>null</code>
     * @return mapping of each server to a non-null (but potentially empty) list of
     *         channels that are safe to subscribe it to
     */
    public static Map<Long, ChannelActionDAO> verifyChildEntitlements(
        User user, Map<Long, ChannelActionDAO> sysMapping, List<Channel> allChannels) {

        //Load all of the channels in a map for easy lookup
        Map<Long, Channel> idToChan = new HashMap<Long, Channel>();
        for (Channel c : allChannels) {
            idToChan.put(c.getId(), c);
        }


        // Keeps a mapping of how many entitlements are left on each channel. This map
        // will be updated as the processing continues, however changes won't be written
        // to the database until the actual subscriptions are made. This way we can keep
        // a more accurate representation of how many entitlements are left rather than
        // always loading the static value from the DB.
        Map<Channel, Long> channelToAvailableEntitlements =
            new HashMap<Channel, Long>(allChannels.size());


        for (Long sysid : sysMapping.keySet()) {

            Set<Long> chanIds = sysMapping.get(sysid).getSubscribeChannelIds();
            //Use an iterator so i can remove from the set
            Iterator it = chanIds.iterator();
            while (it.hasNext()) {
                Channel channel = idToChan.get(it.next());
                Long availableEntitlements = channelToAvailableEntitlements.get(channel);

                if (availableEntitlements == null) {
                    availableEntitlements =
                        ChannelManager.getAvailableEntitlements(user.getOrg(), channel);
                    channelToAvailableEntitlements.put(channel, availableEntitlements);
                }
                //Most likely acustom channel1
                if (availableEntitlements == null) {
                    continue;
                }
                if (availableEntitlements > 0) {
                        // Update our cached count for what will happen when
                        // the subscribe is done
                        availableEntitlements = availableEntitlements - 1;
                        channelToAvailableEntitlements.put(channel, availableEntitlements);
                }
                else {
                    sysMapping.get(sysid).getSubscribeChannelIds().remove(channel.getId());
                    sysMapping.get(sysid).getSubscribeNames().remove(channel.getName());
                    if (sysMapping.get(sysid).isEmtpy()) {
                        sysMapping.remove(sysid);
                    }
                }
            }
        }
        return sysMapping;
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
     * @param sysMapping a collection of ChannelActionDAOs
     */
    public static void performChannelActions(User user,
                    Collection<ChannelActionDAO> sysMapping) {

        for (ChannelActionDAO system : sysMapping) {
            for (Long cid : system.getSubscribeChannelIds()) {
                subscribeChannel(system.getId(), cid, user.getId());
            }
            for (Long cid : system.getUnsubscribeChannelIds()) {
                unsubscribeChannel(system.getId(), cid);
            }
        }
    }


    private static void subscribeChannel(Long sid, Long cid, Long uid) {

        CallableMode m = ModeFactory.getCallableMode("Channel_queries",
                "subscribe_server_to_channel");

        Map in = new HashMap();
        in.put("server_id", sid);
        in.put("user_id", uid);
        in.put("channel_id", cid);
        m.execute(in, new HashMap());
    }


    private static void unsubscribeChannel(Long sid, Long cid) {

        CallableMode m = ModeFactory.getCallableMode("Channel_queries",
                "unsubscribe_server_from_channel");
        Map in = new HashMap();
        in.put("server_id", sid);
        in.put("channel_id", cid);
        m.execute(in, new HashMap());
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
                                                    Collection<ChannelActionDAO> actions) {

        RhnSet subscribeSet = RhnSetDecl.SSM_CHANNEL_SUBSCRIBE.get(user);
        RhnSet unsubscribeSet = RhnSetDecl.SSM_CHANNEL_UNSUBSCRIBE.get(user);

        for (ChannelActionDAO action : actions) {
            long serverId = action.getId();

            // New Subscriptions
            if (action.getSubscribeChannelIds() != null) {
                for (Long subscribeMe : action.getSubscribeChannelIds()) {
                    subscribeSet.addElement(serverId, subscribeMe);
                }
            }

            // Unsubscribe
            if (action.getUnsubscribeChannelIds() != null) {
                for (Long unsubscribeMe : action.getUnsubscribeChannelIds()) {
                    unsubscribeSet.addElement(serverId, unsubscribeMe);
                }
            }
        }

        RhnSetManager.store(subscribeSet);
        RhnSetManager.store(unsubscribeSet);
    }


    /**
     * Adds the selected server IDs to the SSM RhnSet.
     *
     * @param user      cannot be <code>null</code>
     * @param serverIds cannot be <code>null</code>
     */
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
