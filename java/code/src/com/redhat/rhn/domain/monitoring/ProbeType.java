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


/**
 * ProbeType - Class representation of the table rhn_probe_types.
 * @version $Rev: 1 $
 */
public class ProbeType {

    private String probeType;
    private String typeDescription;
    /** 
     * Getter for probeType 
     * @return String to get
    */
    public String getProbeType() {
        return this.probeType;
    }

    /** 
     * Setter for probeType 
     * @param probeTypeIn to set
    */
    public void setProbeType(String probeTypeIn) {
        this.probeType = probeTypeIn;
    }

    /** 
     * Getter for typeDescription 
     * @return String to get
    */
    public String getTypeDescription() {
        return this.typeDescription;
    }

    /** 
     * Setter for typeDescription 
     * @param typeDescriptionIn to set
    */
    public void setTypeDescription(String typeDescriptionIn) {
        this.typeDescription = typeDescriptionIn;
    }

}
