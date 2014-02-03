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

/**
 * Event fired to carry the information necessary to remove packages from servers in the
 * SSM.
 *
 * @see com.redhat.rhn.frontend.events.SsmRemovePackagesAction
 * @version $Revision$
 */
public class SsmRemovePackagesEvent extends SsmPackageEvent {

    private List<Map> result;

    /**
     * Creates a new SSM remove packages event.
     *
     * @param userIdIn    ID of user scheduling this action.
     * @param earliestIn  Earliest data action can be picked up.
     * @param resultIn    Complex map of which packages we're removing from which servers.
     */
    public SsmRemovePackagesEvent(Long userIdIn, Date earliestIn,
        List<Map> resultIn) {
        super(userIdIn, earliestIn);
        result = resultIn;
    }

    /** {@inheritDoc} */
    public String toString() {
        return "SsmRemovePackagesEvent[" + super.toString() + "]";
    }

    /**
     * Gets the result for this instance.
     *
     * @return The result.
     */
    public List<Map> getResult() {
        return this.result;
    }

}

