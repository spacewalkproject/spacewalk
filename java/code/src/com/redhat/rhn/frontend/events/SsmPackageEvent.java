/**
 * Copyright (c) 2009--2013 Red Hat, Inc.
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

import java.util.Date;

/**
 * Base for SSM package install/update/remove actions. Holds the data shared between the
 * three paths.
 *
 * @author ggainey
 *
 */
public abstract class SsmPackageEvent implements EventMessage {

    protected Long                userId;
    protected Date                earliest;
    protected Long                actionChainId;

    /**
     * Creates a new event to install a set of packages on systems in the SSM.
     *
     * @param userIdIn user making the changes; cannot be <code>null</code>
     * @param earliestIn earliest time to perform the installation; can be
     *            <code>null</code>
     * @param actionChainIn the selected Action Chain or null
     */
    public SsmPackageEvent(Long userIdIn, Date earliestIn, ActionChain actionChainIn) {

        if (userIdIn == null) {
            throw new IllegalArgumentException("userIdIn cannot be null");
        }

        this.userId = userIdIn;
        this.earliest = earliestIn;
        if (actionChainIn != null) {
            this.actionChainId = actionChainIn.getId();
        }
    }

    /**
     * @return will not be <code>null</code>
     */
    public Long getUserId() {
        return userId;
    }

    /**
     * @return may be <code>null</code>
     */
    public Date getEarliest() {
        return earliest;
    }

    /**
     * Gets the Action Chain ID
     * @return the Action Chain ID or null
     */
    public Long getActionChainId() {
        return actionChainId;
    }

    /** {@inheritDoc} */
    public String toString() {
        return "SsmPackageEvent[userId=" + userId + ", " +
                (earliest != null ? "earliest=" + earliest + ", " : "") +
                "]";
    }

    /** {@inheritDoc} */
    public String toText() {
        return toString();
    }

}
