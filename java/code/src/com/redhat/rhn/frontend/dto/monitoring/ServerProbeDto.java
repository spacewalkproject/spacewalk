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

import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.monitoring.MonitoringConstants;

import java.util.Date;

/**
 * Simple DTO for Probes used by Servers
 * @version $Rev: 51639 $
 */
public class ServerProbeDto extends CheckProbeDto {

    private Long probeSuiteId;
    private Long templateProbeId;
    private String state;
    private String output;
    private Date lastCheck;

    /**
     * Determine if this Probe is a member of a ProbeSuite
     * @return Returns the suiteProbe.
     */
    public boolean getIsSuiteProbe() {
        return (probeSuiteId != null);
    }

    /**
     * Convenience method to get the ID of the ProbeSuite this Probe
     * is a member of.  Throws an IllegalArgumentException if the contained
     * probe isn't a member of a Suite.
     * @return id of this Probe's Probe Suite.
     */
    public Long getProbeSuiteId() {
        if (!getIsSuiteProbe()) {
            throw new IllegalArgumentException("Shouldn't call this on a non suite probe");
        }
        return probeSuiteId;
    }

    /**
     * @param probeSuiteIdIn The probeSuiteId to set.
     */
    public void setProbeSuiteId(Long probeSuiteIdIn) {
        this.probeSuiteId = probeSuiteIdIn;
    }


    /**
     * @return Returns the templateProbeId.
     */
    public Long getTemplateProbeId() {
        return templateProbeId;
    }


    /**
     * @param templateProbeIdIn The templateProbeId to set.
     */
    public void setTemplateProbeId(Long templateProbeIdIn) {
        this.templateProbeId = templateProbeIdIn;
    }

    /**
     * Get a HTML friendly status string.  Replaces \n and \r\n with <br>
     * @return HTML friendly string
     */
    public String getStateOutputString() {
        if (output != null) {
            return StringUtil.htmlifyText(output);
        }
        else {
            return null;
        }
    }

    /**
     * @return Returns the output.
     */
    public String getOutput() {
        return output;
    }


    /**
     * @param outputIn The output to set.
     */
    public void setOutput(String outputIn) {
        this.output = outputIn;
    }


    /**
     * @return Returns the state.
     */
    public String getState() {
        return state;
    }


    /**
     * @param stateIn The state to set.
     */
    public void setState(String stateIn) {
        this.state = stateIn;
    }

    /**
     * Convenience method to get back the State string for
     * display purposes.  Defaults to "PENDING" if there
     * is no state.
     * @return String value of probestate.
     */
    public String getStateString() {
        if (state == null) {
            return MonitoringConstants.PROBE_STATE_PENDING;
        }
        else {
            return state;
        }
    }

    /**
     * @return Returns the lastCheck.
     */
    public Date getLastCheck() {
        return lastCheck;
    }


    /**
     * @param lastCheckIn The lastCheck to set.
     */
    public void setLastCheck(Date lastCheckIn) {
        this.lastCheck = lastCheckIn;
    }


}
