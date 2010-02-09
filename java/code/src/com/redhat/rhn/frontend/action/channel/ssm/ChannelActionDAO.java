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

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.server.Server;

import java.util.List;

/**
 * ChannelActionDAO - stores channel subscription/unsubscription info for a specific system
 * @version $Rev$
 */
public class ChannelActionDAO {
    
    public static final Long SUBSCRIBE = 1L;
    public static final Long UNSUBSCRIBE = 2L;
    
    private Server server;
    private List<Channel> subsAllowed;
    private List<Channel> unsubsAllowed;
    
    /**
     * What Server are we going to act on?
     * @return the affected server
     */
    public Server getServer() {
        return server;
    }
    
    /**
     * Set which Server we're affecting
     * @param serverIn to set.
     */
    public void setServer(Server serverIn) {
        this.server = serverIn;
    }

    /**
     * What's the Server's ID?
     * @return getServer().getId()
     */
    public Long getId() {
        return server.getId();
    }

    /**
     * What is the affected Server's name?
     * @return server name.
     */
    public String getName() {
        return server.getName();
    }
    
    /** 
     * What channels are we trying to subscribe this system to?
     * @return list of channels to subscribe to
     */
    public List<Channel> getSubsAllowed() {
        return subsAllowed;
    }
    
    /**
     * Set the list of channels-to-be-subscribed
     * @param subAllowedIn Allowed channels to set. 
     */
    public void setSubsAllowed(List<Channel> subAllowedIn) {
        this.subsAllowed = subAllowedIn;
    }
    
    /**
     * What channels are we trying to unsubscribe this system from?
     * @return list of channels to unsubscribe
     */
    public List<Channel> getUnsubsAllowed() {
        return unsubsAllowed;
    }

    /**
     * Set the list of channels-to-unubscribe-from
     * @param unsubsAllowedIn to set.
     */
    public void setUnsubsAllowed(List<Channel> unsubsAllowedIn) {
        this.unsubsAllowed = unsubsAllowedIn;
    }

}
