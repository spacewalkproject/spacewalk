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
package com.redhat.rhn.frontend.dto.monitoring;

import com.redhat.rhn.domain.monitoring.MonitoringConstants;

import java.util.Comparator;

/**
 * ServerProbeComparator
 * @version $Rev$
 */
public class ServerProbeComparator implements Comparator {

    /**
     * {@inheritDoc}
     */
    public int compare(Object arg0, Object arg1) {
        /* Sorts in descending order
         * Probes in the Critical State
         * Probes in the Warning State
         * Probes in the Unknown State
         * Probes in the Pending State
         * Probes in the Ok State
         */
        ServerProbeDto first = (ServerProbeDto) arg0;
        ServerProbeDto second = (ServerProbeDto) arg1;

        if (numericValue(first.getState()) == numericValue(second.getState())) {
            return 0;
        }
        else if (numericValue(first.getState()) < numericValue(second.getState())) {
            return -1;
        }
        else {
            return 1;
        }


    }

    protected int numericValue(String state) {
        if (state.equals(MonitoringConstants.PROBE_STATE_CRITICAL)) {
            return 4;
        }
        else if (state.equals(MonitoringConstants.PROBE_STATE_WARN)) {
            return 3;
        }
        else if (state.equals(MonitoringConstants.PROBE_STATE_UNKNOWN)) {
            return 2;
        }
        else if (state.equals(MonitoringConstants.PROBE_STATE_PENDING)) {
            return 1;
        }
        else {
            return 0;
        }
    }

}
