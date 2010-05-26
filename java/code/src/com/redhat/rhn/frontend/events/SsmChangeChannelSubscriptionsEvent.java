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
package com.redhat.rhn.frontend.events;

import com.redhat.rhn.common.messaging.EventMessage;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.channel.ssm.ChannelActionDAO;

import java.util.Collection;

/**
 * Event fired to carry the information necessary to perform subscription changes
 * for servers in the SSM. 
 *
 * @see com.redhat.rhn.frontend.events.SsmChangeChannelSubscriptionsAction 
 * @version $Revision$
 */
public class SsmChangeChannelSubscriptionsEvent implements EventMessage {

    private User user;
    private Collection<ChannelActionDAO> changes;

    /**
     * Creates a new SSM channel change event to fire across the message bus.
     *
     * @param userIn    user making the changes; cannot be <code>null</code>
     * @param changesIn changes to make; cannot be <code>null</code>
     */
    public SsmChangeChannelSubscriptionsEvent(User userIn,
                                              Collection<ChannelActionDAO> changesIn) {
        
        if (userIn == null) {
            throw new IllegalArgumentException("user cannot be null");
        }

        if (changesIn == null) {
            throw new IllegalArgumentException("changes cannot be null");
        }
        
        this.user = userIn;
        this.changes = changesIn;
    }

    /**
     * @return will not be <code>null</code>
     */
    public User getUser() {
        return user;
    }

    /**
     * @return will not be <code>null</code>
     */
    public Collection<ChannelActionDAO> getChanges() {
        return changes;
    }

    /** {@inheritDoc} */
    public String toText() {
        return toString();
    }

    /** {@inheritDoc} */
    public String toString() {
        return "SsmChannelSubscriptionsEvent[User: " + user.getLogin() +
            ", Change Count: " + changes.size() + "]";
    }
}
