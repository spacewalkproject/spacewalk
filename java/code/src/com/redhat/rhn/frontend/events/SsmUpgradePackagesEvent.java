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

import java.util.Date;
import java.util.List;
import java.util.Map;

import com.redhat.rhn.domain.action.script.ScriptActionDetails;

/**
 * Event fired to carry the information necessary to upgrade packages on servers in the
 * SSM.
 *
 * @see com.redhat.rhn.frontend.events.SsmUpgradePackagesAction
 */
public class SsmUpgradePackagesEvent extends SsmPackageEvent {

    protected Map<Long, List<Map<String, Long>>> sysPackageSet;

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
     * @param detailsIn   optional remote-command to execute before or after the install
     * @param beforeIn    optional boolean - true if details should be executed BEFORE the
     *                    install, false if AFTER
     */
    public SsmUpgradePackagesEvent(Long userIdIn,
                                   Date earliestIn,
                                   Map<Long, List<Map<String, Long>>> sysPackageSetIn,
                                   ScriptActionDetails detailsIn,
                                   boolean beforeIn) {
        super(userIdIn, earliestIn, detailsIn, beforeIn);
        if (sysPackageSetIn == null) {
            throw new IllegalArgumentException("sysPackageSetIn cannot be null");
        }
        sysPackageSet = sysPackageSetIn;
    }

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
    public SsmUpgradePackagesEvent(Long userIdIn,
                                   Date earliestIn,
                                   Map<Long, List<Map<String, Long>>> sysPackageSetIn) {
        this(userIdIn, earliestIn, sysPackageSetIn, null, false);
    }

    /** {@inheritDoc} */
    public String toString() {
        return "SsmUpgradePackagesEvent[" + super.toString() + "]";
    }

    /**
     * @return Returns the sysPackageSet.
     */
    public Map<Long, List<Map<String, Long>>> getSysPackageSet() {
        return sysPackageSet;
    }

}

