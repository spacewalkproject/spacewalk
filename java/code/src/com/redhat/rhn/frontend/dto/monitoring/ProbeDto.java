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
import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.monitoring.ServerProbe;

/**
 * ProbeDto - Simple DTO around a Probe that adds a convenience method to determine 
 * if the Probe is a suite probe or not.
 * 
 * @version $Rev$
 */
public class ProbeDto implements Comparable {
    
    private Probe probe;
    
    /**
     * Constructor with probe 
     * @param probeIn probe to use with this dto.
     */
    public ProbeDto(Probe probeIn) {
        this.probe = probeIn;
    }

    /**
     * @return Returns the probe.
     */
    public Probe getProbe() {
        return probe;
    }
    
    /**
     * Determine if this Probe is a member of a ProbeSuite
     * @return Returns the suiteProbe.
     */
    public boolean getIsSuiteProbe() {
        ServerProbe sprobe = (ServerProbe) probe;
        return (sprobe.getTemplateProbe() != null);
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
        return ((ServerProbe) probe).getTemplateProbe().getProbeSuite().getId();
    }

    /**
     * Convenience method to get the ID of the TemplateProbe for this Probe 
     * is a member of.  Throws an IllegalArgumentException if the contained
     * probe isn't a member of a Suite.
     * @return id of this Probe's template probe
     */
    public Long getTemplateProbeId() {
        if (!getIsSuiteProbe()) {
            throw new IllegalArgumentException("Shouldn't call this on a non suite probe");
        }
        return ((ServerProbe) probe).getTemplateProbe().getId();
    }

    /** 
     * Get a HTML friendly status string.  Replaces \n and \r\n with <br>
     * @return HTML friendly string
     */
    public String getStateOutputString() {
        if (getProbe().getState().getOutput() != null) {
            return StringUtil.htmlifyText(getProbe().getState().getOutput());
        }
        else {
            return null;
        }
    }
    
    /**
     * {@inheritDoc}
     */
    public int compareTo(Object o) {
        Probe p1 = getProbe();
        Probe p2 = ((ProbeDto) o).getProbe();
        return p1.compareTo(p2);
    }
    
}
