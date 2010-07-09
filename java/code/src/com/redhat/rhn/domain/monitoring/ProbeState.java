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

import com.redhat.rhn.domain.monitoring.satcluster.SatCluster;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.io.Serializable;
import java.util.Date;

/**
 * ProbeState - Class representation of the table rhn_probe_state.
 * @version $Rev: 1 $
 */
public class ProbeState implements Serializable {

    private Long probeId;
    private Long scoutId;
    private String state;
    private String output;
    private Date lastCheck;

    private Probe probe;

    /**
     * Empty constructor
     */
    protected ProbeState() {
    }

    /**
     * Default constructor
     * @param clusterIn the SatCluster this ProbeState is associated with
     */
    public ProbeState(SatCluster clusterIn) {
       this.scoutId = clusterIn.getId();
    }

    /**
     * Construct a new ProbeState with specified state string
     * @param clusterIn the SatCluster this ProbeState is associated with
     * @param stateIn state desired
     */
    public ProbeState(SatCluster clusterIn, String stateIn) {
        this(clusterIn);
        this.state = stateIn;
    }

    /**
     * @return Returns the probeId.
     */
    public Long getProbeId() {
        return probeId;
    }

    /**
     * @param probeIdIn The probeId to set.
     */
    public void setProbeId(Long probeIdIn) {
        this.probeId = probeIdIn;
    }
    /**
     * Getter for scoutId
     * @return Long to get
    */
    public Long getScoutId() {
        return this.scoutId;
    }

    /**
     * Setter for scoutId
     * @param scoutIdIn to set
    */
    public void setScoutId(Long scoutIdIn) {
        this.scoutId = scoutIdIn;
    }

    /**
     * Getter for state
     * @return String to get
    */
    public String getState() {
        return this.state;
    }

    /**
     * Setter for state
     * @param stateIn to set
    */
    public void setState(String stateIn) {
        this.state = stateIn;
    }

    /**
     * Getter for output
     * @return String to get
    */
    public String getOutput() {
        return this.output;
    }

    /**
     * Setter for output
     * @param outputIn to set
    */
    public void setOutput(String outputIn) {
        this.output = outputIn;
    }

    /**
     * Getter for lastCheck
     * @return Date to get
    */
    public Date getLastCheck() {
        return this.lastCheck;
    }

    /**
     * Setter for lastCheck
     * @param lastCheckIn to set
    */
    public void setLastCheck(Date lastCheckIn) {
        this.lastCheck = lastCheckIn;
    }

    /**
     * @return Returns the probe.
     */
    public Probe getProbe() {
        return probe;
    }
    /**
     * @param probeIn The probe to set.
     */
    public void setProbe(Probe probeIn) {
        this.probe = probeIn;
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(Object other) {
        if (!(other instanceof ProbeState)) {
            return false;
        }
        ProbeState castOther = (ProbeState) other;
        return new EqualsBuilder().append(scoutId, castOther.scoutId).append(
                probe, castOther.probe).isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(scoutId).append(probe).toHashCode();
    }

}
