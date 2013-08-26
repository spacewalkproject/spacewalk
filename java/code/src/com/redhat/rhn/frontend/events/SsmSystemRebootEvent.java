/**
 * Copyright (c) 2013 SUSE
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
import java.util.Date;
import java.util.List;

/**
 * SSM System Reboot scheduling event.
 *
 * @author Bo Maryniuk
 */
public class SsmSystemRebootEvent implements EventMessage {
    private final Long userId;
    private final Date earliest;
    private final List<Long> serverIds;


    /**
     * Constructor.
     *
     * @param uid User ID
     * @param scheduleDate Earliest possible schedule date.
     * @param servers List of server IDs.
     */
    public SsmSystemRebootEvent(Long uid,
                                Date scheduleDate,
                                List<Long> servers) {
        if (uid == null) {
            throw new IllegalArgumentException("User ID cannot be null.");
        }
        else if (scheduleDate == null) {
            throw new IllegalArgumentException("Earlies scheduled date cannot be null.");
        }
        else if (servers == null || servers.isEmpty()) {
            throw new IllegalArgumentException("Server ID cannot be null or empty.");
        }

        this.userId = uid;
        this.earliest = scheduleDate;
        this.serverIds = servers;
    }


    /**
     * Get user ID
     *
     * @return User ID
     */
    public Long getUserId() {
        return userId;
    }


    /**
     * Get the list of server IDs.
     *
     * @return List of server IDs
     */
    public List<Long> getServerIds() {
        return serverIds;
    }


    /**
     * Get the date of the scheduling for earliest possible time.
     *
     * @return Schedule date
     */
    public Date getEarliest() {
        return earliest;
    }


    /**
     * Convert this object to the java.lang.String
     * @return String representation
     */
    @Override
    public String toString() {
        return String.format("SsmSystemRebootEvent[User: %s, Systems: %s]",
                             this.getUserId(),
                             this.getServerIds().size());
    }


    /**
     * Represent the object in ASCII text.
     * @return String representation
     */
    public String toText() {
        return this.toString();
    }
}
