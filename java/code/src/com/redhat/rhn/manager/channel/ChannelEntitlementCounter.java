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
package com.redhat.rhn.manager.channel;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.org.Org;

/**
 * ChannelEntitlementCounter - simple class to extract some critical business logic
 * out into a non static method.
 * @version $Rev: 112392 $
 */
public class ChannelEntitlementCounter {
    
    /**
     * Get the available entitlements for the passed in Org
     * and Channel
     * @param orgIn to check
     * @param channelIn to check
     * @return Long count, null if unlimited.
     */
    public Long getAvailableEntitlements(Org orgIn, Channel channelIn) {
        Long retval = ChannelFactory.getAvailableEntitlements(orgIn, channelIn);
        return retval;
    }

}
