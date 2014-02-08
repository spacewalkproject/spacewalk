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
import com.redhat.rhn.domain.action.ActionChain;

import java.util.Collections;
import java.util.Date;
import java.util.List;

/**
 * SSM Errata Event object.
 *
 * @author Bo Maryniuk <bo@suse.de>
 */
public class SsmErrataEvent implements EventMessage {
    private final Long userId;
    private final Date earliest;
    private final Long actionChainId;
    private final List<Long> errataIds;
    private final List<Long> serverIds;

    /**
     * SSM Errata Event object constructor.
     *
     * @param uid User ID
     * @param scheduleDate Earliest possible schedule.
     * @param actionChain the selected Action Chain or null
     * @param errataList List of erratas (ID)
     * @param serverList List of relevant servers (ID)
     */
    public SsmErrataEvent(Long uid,
                          Date scheduleDate,
                          ActionChain actionChain,
                          List<Long> errataList,
                          List<Long> serverList) {
        if (uid == null) {
            throw new IllegalArgumentException("User ID cannot be null.");
        }
        else if (errataList == null) {
            throw new IllegalArgumentException("Errata IDs cannot be null");
        }
        else if (serverList == null) {
            throw new IllegalArgumentException("Server IDs cannot be null");
        }

        this.userId = uid;
        this.earliest = scheduleDate;
        if (actionChain != null) {
            this.actionChainId = actionChain.getId();
        }
        else {
            this.actionChainId = null;
        }
        this.errataIds = errataList;
        this.serverIds = serverList;
    }


    /**
     * Get UID.
     *
     * @return will not be <code>null</code>
     */
    public Long getUserId() {
        return userId;
    }

    /**
     * Get earliest possible scheduling date.
     *
     * @return may be <code>null</code>
     */
    public Date getEarliest() {
        return earliest;
    }

    /**
     * Gets the action chain id.
     *
     * @return the action chain id
     */
    public Long getActionChainId() {
        return actionChainId;
    }

    /**
     * Get errata IDs.
     *
     * @return List List of errata IDs
     */
    public List<Long> getErrataIds() {
        return Collections.unmodifiableList(this.errataIds);
    }

    /**
     * Get server IDs.
     *
     * @return List List of Server IDs
     */
    public List<Long> getServerIds() {
        return Collections.unmodifiableList(this.serverIds);
    }

    /** {@inheritDoc} */
    @Override
    public String toString() {
        return String.format("SsmErrataEvent[User: %s, Objects: %s, Systems: %s]",
                             this.getUserId(),
                             this.getErrataIds().size(),
                             this.getServerIds().size());
    }

    /** {@inheritDoc} */
    public String toText() {
        return this.toString();
    }
}
