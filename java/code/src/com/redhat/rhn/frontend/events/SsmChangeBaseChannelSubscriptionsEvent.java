/**
 * Copyright (c) 2014 Red Hat, Inc.
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

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.channel.ssm.ChannelActionDAO;

import java.util.Collection;

/**
 * Event fired to carry the information necessary to perform subscription
 * changes for servers in the SSM.
 *
 * @see com.redhat.rhn.frontend.events.SsmChangeChannelSubscriptionsEvent
 * @version $Revision$
 */
public class SsmChangeBaseChannelSubscriptionsEvent extends
        SsmChangeChannelSubscriptionsEvent {

    /**
     * Constructor for SsmChangeBaseChannelSubscriptionsEvent
     * @param userIn User making the change
     * @param changesIn List of changes, each one should contain only a single
     *   base channel id
     * @param operationId Operation to link with
     */
    public SsmChangeBaseChannelSubscriptionsEvent(User userIn,
            Collection<ChannelActionDAO> changesIn, Long operationId) {
        super(userIn, changesIn, operationId);
    }

    /** {@inheritDoc} */
    public String toString() {
        return "SsmBaseChannelSubscriptionsEvent[User: " + getUser().getLogin() +
                ", Change Count: " + getChanges().size() + "]";
    }
}
