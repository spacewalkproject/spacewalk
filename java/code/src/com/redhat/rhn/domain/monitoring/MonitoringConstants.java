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
package com.redhat.rhn.domain.monitoring;

import com.redhat.rhn.domain.monitoring.command.Command;

/**
 * MonitoringConstants
 * @version $Rev$
 */
public class MonitoringConstants {

    private MonitoringConstants() {

    }

    /** OK State **/
    public static final String PROBE_STATE_OK = "OK";
    /** UNKNOWN State **/
    public static final String PROBE_STATE_UNKNOWN = "UNKNOWN";
    /** WARN State **/
    public static final String PROBE_STATE_WARN = "WARNING";
    /** CRITICAL State **/
    public static final String PROBE_STATE_CRITICAL = "CRITICAL";
    /** PENDING State **/
    public static final String PROBE_STATE_PENDING = "PENDING";

    /**
     * All possible probe states
     */
    public static final String[] PROBE_STATES = {
        PROBE_STATE_OK, PROBE_STATE_PENDING, PROBE_STATE_WARN, PROBE_STATE_CRITICAL,
        PROBE_STATE_UNKNOWN
    };

    /**
     * Check probe type
     * @return ProbeType
     */
    public static final ProbeType getProbeTypeCheck() {
        return MonitoringFactory.lookupProbeType("check");
    }

    /**
     * Suite probe type
     * @return ProbeType
     */
    public static final ProbeType getProbeTypeSuite() {
        return MonitoringFactory.lookupProbeType("suite");
    }

    /**
     * Check tcp command
     * @return Command
     */
    public static final Command getCommandCheckTCP() {
        return MonitoringFactory.lookupCommand("check_tcp");
    }

}
