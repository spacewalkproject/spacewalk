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
package com.redhat.rhn.domain.server;

import com.redhat.rhn.domain.monitoring.MonitoringConstants;
import com.redhat.rhn.domain.monitoring.ServerProbe;

import java.util.Iterator;
import java.util.List;

/**
 * MonitoredServer - extension of Server that includes ServerProbe data
 *
 * @version $Rev: 55933 $
 */
public class MonitoredServer extends Server {

    private List probes;

    /**
     * @return Returns the probes.
     */
    public List<ServerProbe> getProbes() {
        return probes;
    }

    /**
     * @param probesIn The probes to set.
     */
    public void setProbes(List<ServerProbe> probesIn) {
        this.probes = probesIn;
    }

    /**
     * Util method to fetch the overall health of the probes aligned to this
     * System
     * @return State string, one of the <code>PROBE_STATE_*</code> constants
     * in {@link MonitoringConstants}
     */
    public String getProbeStateSummary() {
        if (this.getProbes() == null || this.getProbes().size() == 0) {
            return MonitoringConstants.PROBE_STATE_PENDING;
        }
        Iterator i = this.getProbes().iterator();
        boolean pending = false;
        boolean crit = false;
        boolean warn = false;
        boolean unknown = false;
        boolean ok = false;
        // Loop over all the probes and check in decending order
        // if any states are matched.  If any one probe is critical
        // then we return that status, decending down to OK.
        while (i.hasNext()) {
            ServerProbe p = (ServerProbe) i.next();
            if (p.getState() == null || p.getState().getState() == null) {
                pending = true;
            }
            else if (p.getState().getState().equals(
                    MonitoringConstants.PROBE_STATE_PENDING)) {
                pending = true;
            }
            else if (p.getState().getState().equals(
                    MonitoringConstants.PROBE_STATE_CRITICAL)) {
                crit = true;
            }
            else if (p.getState().getState().equals(
                    MonitoringConstants.PROBE_STATE_WARN)) {
                warn = true;
            }
            else if (p.getState().getState().equals(
                    MonitoringConstants.PROBE_STATE_UNKNOWN)) {
                unknown = true;
            }
            else if (p.getState().getState().equals(
                    MonitoringConstants.PROBE_STATE_OK)) {
                ok = true;
            }
        }
        if (crit) {
            return MonitoringConstants.PROBE_STATE_CRITICAL;
        }
        if (warn) {
            return MonitoringConstants.PROBE_STATE_WARN;
        }
        if (unknown) {
            return MonitoringConstants.PROBE_STATE_UNKNOWN;
        }
        if (ok) {
            return MonitoringConstants.PROBE_STATE_OK;
        }
        if (pending) {
            return MonitoringConstants.PROBE_STATE_PENDING;
        }
        throw new IllegalStateException("No state found!  Should never get here");
    }
}
