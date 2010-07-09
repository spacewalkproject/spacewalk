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
package com.redhat.rhn.domain.rhnpackage;

import com.redhat.rhn.domain.BaseDomainHelper;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

/**
 * PackageProperty
 * @version $Rev$
 */
public class PackageProperty extends BaseDomainHelper {

    private Package pack;
    private PackageCapability capability;
    private Long sense;

    /**
     * @return Returns the pack.
     */
    public Package getPack() {
        return pack;
    }

    /**
     * @param packIn The pack to set.
     */
    public void setPack(Package packIn) {
        this.pack = packIn;
    }

    /**
     * @return Returns the capability.
     */
    public PackageCapability getCapability() {
        return capability;
    }

    /**
     * @param capabilityIn The capability to set.
     */
    public void setCapability(PackageCapability capabilityIn) {
        this.capability = capabilityIn;
    }

    /**
     * @return Returns the sense.
     */
    public Long getSense() {
        return sense;
    }

    /**
     * @param senseIn The sense to set.
     */
    public void setSense(Long senseIn) {
        this.sense = senseIn;
    }

    /**
     * @return a human readable representation of the sense
     */
    public String getSenseAsString() {
        Long senseIn = this.sense & 0xf;
        if (senseIn == 2) {
            return "LT";
        }
        else if (senseIn == 4) {
            return "GT";
        }
        else if (senseIn == 8) {
            return "EQ";
        }
        else if (senseIn == 10) {
            return "LE";
        }
        else { // 12
            return "GE";
        }
    }

    /**
     * @param senseIn The sense to set.
     */
    public void setSenseFromString(String senseIn) {
        Long senseVal;

        if (senseIn == "LT") {
            senseVal = 2L;
        }
        else if (senseIn == "GT") {
            senseVal = 4L;
        }
        else if (senseIn == "EQ") {
            senseVal = 8L;
        }
        else if (senseIn == "LE") {
            senseVal = 10L;
        }
        else { // "GE"
            senseVal = 12L;
        }

        this.sense = senseVal & 0xf;
    }

    /**
     *
     * {@inheritDoc}
     */
    public int hashCode() {
        HashCodeBuilder hash = new HashCodeBuilder();
        hash.append(this.getSense());
        hash.append(this.getCapability());
        hash.append(this.getPack());
        return hash.toHashCode();
    }

    /**
     *
     * {@inheritDoc}
     */
    public boolean equals(Object obj) {
        if (!(obj instanceof PackageProperty)) {
            return false;
        }
        PackageProperty prop = (PackageProperty) obj;
        EqualsBuilder eq = new EqualsBuilder();
        eq.append(this.getSense(), prop.getSense());
        eq.append(this.getPack(), prop.getPack());
        eq.append(this.getCapability(), prop.getCapability());
        return eq.isEquals();
    }

}
