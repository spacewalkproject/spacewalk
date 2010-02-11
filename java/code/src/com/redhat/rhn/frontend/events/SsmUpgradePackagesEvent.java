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

import com.redhat.rhn.common.db.datasource.DataResult;

import com.redhat.rhn.common.messaging.EventMessage;

import java.util.Date;
import java.util.Map;
import java.util.List;

/**
 * Event fired to carry the information necessary to upgrade packages on servers in the
 * SSM.
 *
 * @see com.redhat.rhn.frontend.events.SsmUpgradePackagesAction
 */
public class SsmUpgradePackagesEvent implements EventMessage {

    private Long userId;
    private Date earliest;
    private DataResult result;
    private List<Map<String, Long>> packageListItems;

    /**
     * Creates a new SSM upgrade packages event.
     *
     * @param userIdIn ID of user scheduling this action.
     * @param earliestIn Earliest data action can be picked up.
     * @param resultIn Complex map of which packages we're upgrading on which servers.
     * @param listIn packages to upgrade
     */
    public SsmUpgradePackagesEvent(Long userIdIn, Date earliestIn,
                                   DataResult resultIn, List<Map<String, Long>> listIn) {
        userId = userIdIn;
        earliest = earliestIn;
        result = resultIn;
        packageListItems = listIn;
    }

    /** {@inheritDoc} */
    public String toText() {
        return toString();
    }

    /** {@inheritDoc} */
    public String toString() {
        return "SsmUpgradePackagesEvent[User ID: " + userId + "]";
    }

    /**
     * Gets the user for this instance.
     *
     * @return The user.
     */
    public Long getUserId() {
        return this.userId;
    }

    /**
     * Gets the earliest for this instance.
     *
     * @return The earliest.
     */
    public Date getEarliest() {
        return this.earliest;
    }

    /**
     * Gets the result for this instance.
     *
     * @return The result.
     */
    public DataResult getResult() {
        return this.result;
    }

    /**
     * Gets the packages to upgrade.
     *
     * @return list suitable for scheduling upgrade actions
     */
    public List<Map<String, Long>> getPackageListItems() {
        return packageListItems;
    }
}

