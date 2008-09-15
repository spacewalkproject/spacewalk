/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.domain.kickstart;

import com.redhat.rhn.domain.org.Org;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.io.Serializable;
import java.util.Date;

/**
 * KickstartIpRange - Class representation of the table rhnkickstartiprange.
 * @version $Rev: 1 $
 */
public class KickstartIpRange implements Serializable {

    private KickstartData ksdata;
    private Org org;
    private String min;
    private String max;
    private Date created;
    private Date modified;


    /** 
     * Getter for kickstartId 
     * @return KickstartData to get
    */
    public KickstartData getKsdata() {
        return this.ksdata;
    }

    /** 
     * Setter for ksdata
     * @param ksdataIn to set
    */
    public void setKsdata(KickstartData ksdataIn) {
        this.ksdata = ksdataIn;
    }

    /** 
     * Getter for org 
     * @return Org to get
    */
    public Org getOrg() {
        return this.org;
    }

    /** 
     * Setter for org 
     * @param orgIn to set
    */
    public void setOrg(Org orgIn) {
        this.org = orgIn;
    }

    /** 
     * Getter for min 
     * @return Long to get
    */
    public String getMin() {
        return this.min;
    }

    /** 
     * Setter for min 
     * @param minIn to set
    */
    public void setMin(String minIn) {
        this.min = minIn;
    }

    /** 
     * Getter for max 
     * @return Long to get
    */
    public String getMax() {
        return this.max;
    }

    /** 
     * Setter for max 
     * @param maxIn to set
    */
    public void setMax(String maxIn) {
        this.max = maxIn;
    }

    /** 
     * Getter for created 
     * @return Date to get
    */
    public Date getCreated() {
        return this.created;
    }

    /** 
     * Setter for created 
     * @param createdIn to set
    */
    public void setCreated(Date createdIn) {
        this.created = createdIn;
    }

    /** 
     * Getter for modified 
     * @return Date to get
    */
    public Date getModified() {
        return this.modified;
    }

    /** 
     * Setter for modified 
     * @param modifiedIn to set
    */
    public void setModified(Date modifiedIn) {
        this.modified = modifiedIn;
    }
    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (!(other instanceof KickstartIpRange)) {
            return false;
        }
        KickstartIpRange castOther = (KickstartIpRange) other;
        return new EqualsBuilder().append(ksdata, castOther.ksdata)
                                  .append(org, castOther.org)
                                  .append(min, castOther.min)
                                  .append(max, castOther.max)
                                  .isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(ksdata)
                                    .append(org)
                                    .append(min)
                                    .append(max)
                                    .toHashCode();
    }

}
