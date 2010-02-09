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

import java.util.Date;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.messaging.EventMessage;

/**
 * Event carrying information necessary to schedule package verifications on systems
 * in the SSM.
 */
public class SsmVerifyPackagesEvent implements EventMessage {

    private Long userId;
    private Date earliest;
    private DataResult result;

    /**
     * Creates a new event to trigger the action over the message queue.
     *
     * @param userIdIn     user making the request; cannot be <code>null</code>
     * @param earliestIn used for scheduling the verification in the future;
     *                   may be <code>null</code>
     * @param resultIn   data describing the systems and packages to verify
     *                   cannot be <code>null</code>
     */
    public SsmVerifyPackagesEvent(Long userIdIn, Date earliestIn, DataResult resultIn) {

        if (userIdIn == null) {
            throw new IllegalArgumentException("userIdIn cannot be null");
        }

        if (resultIn == null) {
            throw new IllegalArgumentException("resultIn cannot be null");
        }

        this.userId = userIdIn;
        this.earliest = earliestIn;
        this.result = resultIn;
    }

    /** @return will not be <code>null</code> */
    public Long getUserId() {
        return userId;
    }

    /** @return may be <code>null</code> */
    public Date getEarliest() {
        return earliest;
    }

    /** @return will not be <code>null</code> */
    public DataResult getResult() {
        return result;
    }

    /** {@inheritDoc} */
    public String toText() {
        return toString();
    }

    /** {@inheritDoc} */
    public String toString() {
        return "SsmPackageVerifyEvent[UserId: " + userId + "]";
    }
}
