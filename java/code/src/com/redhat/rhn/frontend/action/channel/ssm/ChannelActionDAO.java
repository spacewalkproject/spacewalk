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
package com.redhat.rhn.frontend.action.channel.ssm;

import java.util.HashSet;
import java.util.Set;

/**
 * ChannelActionDAO - stores channel subscription/unsubscription info for a specific system
 * @version $Rev$
 */
public class ChannelActionDAO {

    public static final Long SUBSCRIBE = 1L;
    public static final Long UNSUBSCRIBE = 2L;
    private String name;
    private Long id;
    private Set<Long> subsAllowed = new HashSet<Long>();
    private Set<Long> unsubsAllowed = new HashSet<Long>();

    private Set<String> subNamesAllowed =  new HashSet<String>();
    private Set<String> unsubNamesAllowed = new HashSet<String>();

    /**
     * What Server are we going to act on?
     * @return the affected server
     */
    public Long getId() {
        return id;
    }

    /**
     * Set which Server we're affecting
     * @param serverIn to set.
     */
    public void setId(Long serverIn) {
        this.id = serverIn;
    }

    /**
     * What's the Server's name?
     * @param nameIn the name
     */
    public void setName(String nameIn) {
        name = nameIn;
    }

    /**
     * What is the affected Server's name?
     * @return server name.
     */
    public String getName() {
        return name;
    }

    /**
     * What channels are we trying to subscribe this system to?
     * @return list of channels to subscribe to
     */
    public Set<Long> getSubscribeChannelIds() {
        return subsAllowed;
    }


    /**
     * Add a channel name to subscribe (for display purposes only)
     * @param nameIn the nameIn
     */
    public void addSubscribeName(String nameIn) {
        subNamesAllowed.add(nameIn);
    }

    /**
     * get the list of channel names to subscribe
     * @return the list
     */
    public Set<String> getSubscribeNames() {
        return subNamesAllowed;
    }

    /**
     * Add an ubsubscribe channel name
     * @param nameIn the name
     */
    public void addUnsubcribeName(String nameIn) {
        unsubNamesAllowed.add(nameIn);
    }

    /**
     * get the names of the channels for unsubscribing
     * @return the list of names
     */
    public Set<String> getUnsubcribeNames() {
        return unsubNamesAllowed;
    }

    /**
     * add a channel for subscription
     * @param cid the channel id
     */
    public void addSubscribeChannelId(Long cid) {
        this.subsAllowed.add(cid);
    }


    /**
     * What channels are we trying to unsubscribe this system from?
     * @return list of channels to unsubscribe
     */
    public Set<Long> getUnsubscribeChannelIds() {
        return unsubsAllowed;
    }

    /**
     * Add an unsubscribe channel
     * @param cid the channel id
     */
    public void addUnsubscribeChannelId(Long cid) {
        this.unsubsAllowed.add(cid);
    }

    /**
     * Are there any unsubscribe or subscribe channels
     * @return if empty true
     */
    public boolean isEmtpy() {
        return getUnsubscribeChannelIds().isEmpty() && getSubscribeChannelIds().isEmpty();
    }


}
