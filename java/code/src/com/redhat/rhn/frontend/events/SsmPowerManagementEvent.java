/**
 * Copyright (c) 2013 SUSE LLC
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
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerPowerCommand.Operation;

import java.util.List;

/**
 * Encapsulates data needed for a SsmPowerManagementAction.
 * @author Silvio Moioli {@literal <smoioli@suse.de>}
 */
public class SsmPowerManagementEvent implements EventMessage {

    /** The user id. */
    private Long userId;

    /** Systems to apply the action to. */
    private List<SystemOverview> systemOverviews;

    /** Power management operation kind. */
    private Operation operation;

    /**
     * Instantiates a new SSM power management event.
     * @param userIdIn the user id
     * @param systemOverviewsIn the system overviews
     * @param operationIn the action
     */
    public SsmPowerManagementEvent(Long userIdIn, List<SystemOverview> systemOverviewsIn,
        Operation operationIn) {
        super();
        userId = userIdIn;
        systemOverviews = systemOverviewsIn;
        operation = operationIn;
    }

    /**
     * Gets the operation.
     * @return the operation
     */
    public Operation getOperation() {
        return operation;
    }

    /**
     * Gets the system overviews.
     * @return the system overviews
     */
    public List<SystemOverview> getSystemOverviews() {
        return systemOverviews;
    }

    /**
     * Gets the user id.
     * @return the user id
     */
    public Long getUserId() {
        return userId;
    }

    /**
     * {@inheritDoc}
     */
    public String toText() {
        return toString();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String toString() {
        return String
            .format(
                "SsmPowerManagementEvent[" +
                    "userId: %s " +
                    "systemOverviews: %s " +
                    "operation: %s]",
                userId,
                systemOverviews.size(),
                operation.toString());
    }
}
