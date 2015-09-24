/**
 * Copyright (c) 2009--2015 Red Hat, Inc.
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

import java.util.Collection;
import java.util.Date;
import java.util.Map;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.messaging.EventDatabaseMessage;
import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.action.ActionType;
import org.hibernate.Transaction;

/**
 * Event carrying information necessary to schedule config files actions
 * for systems.
 */
public class SsmConfigFilesEvent implements EventDatabaseMessage {

    private Collection<Long> systemIds;
    private Map<Long, Collection<Long>> revisionMappings;
    private Long userId;
    private ActionType type;
    private Date earliest;
    private Long actionChainId;
    private Transaction txn;

    /**
     * Creates a new event to trigger the action over the message queue.
     *
     * @param userIdIn             user making the request; cannot be <code>null</code>
     * @param revisionMappingsIn   files revisions to work with
     * @param systemsIn            target systems
     * @param typeIn               type of scheduled action
     * @param earliestIn           used for scheduling the verification in the future;
     *                             may be <code>null</code>
     * @param actionChainIn        the selected Action Chain or null
     *                             cannot be <code>null</code>
     */
    public SsmConfigFilesEvent(Long userIdIn,
            Map<Long, Collection<Long>> revisionMappingsIn,
            Collection<Long> systemsIn, ActionType typeIn, Date earliestIn,
            ActionChain actionChainIn) {

        if (userIdIn == null) {
            throw new IllegalArgumentException("userIdIn cannot be null");
        }

        this.userId = userIdIn;
        this.systemIds = systemsIn;
        this.revisionMappings = revisionMappingsIn;
        this.type = typeIn;
        this.earliest = earliestIn;
        if (actionChainIn != null) {
            this.actionChainId = actionChainIn.getId();
        }
        this.txn = HibernateFactory.getSession().getTransaction();
    }

    /** @return will not be <code>null</code> */
    public Long getUserId() {
        return userId;
    }

    /**
     * @return server - files revision mapping for config operation
     */
    public Map<Long, Collection<Long>> getRevisionMappings() {
        return revisionMappings;
    }

    /**
     * @return set of IDs of target systems
     */
    public Collection<Long> getSystemIds() {
        return systemIds;
    }

    /** @return type of scheduled action */
    public ActionType getType() {
        return type;
    }

    /** @return may be <code>null</code> */
    public Date getEarliest() {
        return earliest;
    }

    /**
     * @return the Action Chain ID or null
     */
    public Long getActionChainId() {
        return actionChainId;
    }

    /** {@inheritDoc} */
    public String toText() {
        return toString();
    }

    /** {@inheritDoc} */
    public String toString() {
        return "SsmConfigFilesEvent[UserId: " + userId + "]";
    }

    /** {@inheritDoc} */
    public Transaction getTransaction() {
        return txn;
    }
}
