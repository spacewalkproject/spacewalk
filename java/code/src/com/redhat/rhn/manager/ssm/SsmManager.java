/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.channel.ssm.ChannelActionDAO;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
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

    /** Private constructor to enforce the stateless nature of this class. */
    private SsmManager() {
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
                SystemManager.unsubscribeServerFromChannel(system.getId(), cid);
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

    /**
     * Returns a list of server-ids of the servers in the SSM selection, for the specified
     * user
     *
     * @param user user whose system-set we care about
     * @return list of server-ids
     */
    public static List<Long> listServerIds(User user) {
        RhnSet ssm = RhnSetDecl.SYSTEMS.lookup(user);
        List<Long> sids = new ArrayList<Long>();
        if (ssm != null) {
            for (RhnSetElement rse : ssm.getElements()) {
                sids.add(rse.getElement());
            }
        }
        return sids;
    }

}
