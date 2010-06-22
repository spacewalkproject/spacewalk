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

import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * Event fired to carry the information necessary to upgrade packages on servers in the
 * SSM.
 *
 * @see com.redhat.rhn.frontend.events.SsmUpgradePackagesAction
 */
public class SsmUpgradePackagesEvent implements EventMessage {

    private Long userId;
    private Date earliest;
    private  Map<Long, List<Map<String, Long>>> sysPackageSet;

    /**
     * Creates a new SSM upgrade packages event.
     *
     * @param userIdIn ID of user scheduling this action.
     * @param earliestIn Earliest data action can be picked up.
     * @param sysPackageSetIn Complex map of:
     *          system id-> List
     *                          Map
     *                              name_id -> long
     *                              evr_id -> long
     *                              arch_id -> long
     */
    public SsmUpgradePackagesEvent(Long userIdIn, Date earliestIn,
            Map<Long, List<Map<String, Long>>> sysPackageSetIn) {
        userId = userIdIn;
        earliest = earliestIn;
        sysPackageSet = sysPackageSetIn;
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
     * @return Returns the sysPackageSet.
     */
    public Map<Long, List<Map<String, Long>>> getSysPackageSet() {
        return sysPackageSet;
    }
}

